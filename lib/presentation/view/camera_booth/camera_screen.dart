// ignore_for_file: unnecessary_null_comparison

import 'package:bp/presentation/styles/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'widgets/taking_button.dart';

class MemorialParkPhotoBoothView extends StatefulWidget {
  const MemorialParkPhotoBoothView({super.key});

  @override
  State<MemorialParkPhotoBoothView> createState() =>
      _MemorialParkPhotoBoothViewState();
}

class _MemorialParkPhotoBoothViewState extends State<MemorialParkPhotoBoothView>
    with WidgetsBindingObserver {
  final GlobalKey _repaintKey = GlobalKey();
  late CameraController controller;
  late List<CameraDescription> cameras;
  bool isInitialized = false;
  CameraLensDirection direction = CameraLensDirection.front; // 전면 카메라를 기본으로 선택

  bool didFetch = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    initCamera();
  }

  // 종료
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();

    super.dispose();
  }

  // 생명주기 변경 시
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    }
    if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        initCamera();
      }
    }
  }

  // 카메라 초기화
  Future<void> initCamera() async {
    cameras = await availableCameras();
    final description =
        cameras.firstWhere((element) => element.lensDirection == direction);
    controller = CameraController(description, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        isInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            Navigator.pop(context);
            break;
          default:
            // Handle other errors here.
            Navigator.pop(context);
            break;
        }
      }
    });
  }

  // 전후면 카메라 전환
  void switchCamera() {
    if (direction == CameraLensDirection.front) {
      direction = CameraLensDirection.back;
    } else {
      direction = CameraLensDirection.front;
    }
    final cd =
        cameras.firstWhere((element) => element.lensDirection == direction);
    CameraController newController = CameraController(
      cd,
      ResolutionPreset.max,
    );

    newController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        controller = newController;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 카메라 초기화 중이면 로딩 화면 표시
    if (!isInitialized ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: buildCameraSection(_repaintKey, context, controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewPadding.bottom),
        decoration: BoxDecoration(color: ColorManager.black.withOpacity(0.5)),
        child: Row(
          children: [
            const IconButton(
              icon: Icon(
                Icons.photo,
                color: Colors.transparent,
              ),
              onPressed: null,
            ),
            const Spacer(),
            TakingPictureWidget(
                repaintKey: _repaintKey, controller: controller),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.repeat,
                color: Colors.white,
              ),
              onPressed: switchCamera,
            ),
          ],
        ),
      ),
    );
  }
}

// 카메라 화면
Widget buildCameraSection(GlobalKey<State<StatefulWidget>> repaintKey,
    BuildContext context, CameraController controller) {
  final double aspectRatio = controller.value.aspectRatio;
  const double previewAspectRatio = 9 / 16;

  return AspectRatio(
    aspectRatio: 9 / 16,
    child: RepaintBoundary(
      key: repaintKey,
      child: ClipRect(
        child: Transform.scale(
          scale: aspectRatio * previewAspectRatio,
          child: Center(
            child: CameraPreview(controller),
          ),
        ),
      ),
    ),
  );
}

// 버튼 영역
Widget buildButtons(GlobalKey<State<StatefulWidget>> repaintKey,
    CameraController controller, switchCamera, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.fromLTRB(0, 15, 0, 25),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(),
        // 촬영 버튼
        TakingPictureWidget(repaintKey: repaintKey, controller: controller),
        // 전후면 화면 전환 버튼
        IconTheme(
          data: const IconThemeData(size: 32),
          child: IconButton(
            icon: const Icon(Icons.repeat),
            onPressed: switchCamera,
          ),
        )
      ],
    ),
  );
}
