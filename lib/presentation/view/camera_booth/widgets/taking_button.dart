import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:bp/presentation/widgets/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'display_picture.dart';

class TakingPictureWidget extends StatefulWidget {
  const TakingPictureWidget({
    super.key,
    required GlobalKey<State<StatefulWidget>> repaintKey,
    required this.controller,
  }) : _repaintKey = repaintKey;

  final GlobalKey<State<StatefulWidget>> _repaintKey;
  final CameraController controller;

  @override
  State<TakingPictureWidget> createState() => _TakingPictureWidgetState();
}

class _TakingPictureWidgetState extends State<TakingPictureWidget> {
  Future<File> takePhotoWithRepaintKey() async {
    RenderRepaintBoundary boundary = widget._repaintKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Get the temporary directory of the app
    Directory tempDir = await getTemporaryDirectory();

    // Create a file in the temporary directory
    File imgFile = File('${tempDir.path}/image.png');
    await imgFile.writeAsBytes(pngBytes);
    return imgFile;
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              LoadingIndicatorDialog().show(context, text: "촬영중..");

              File imgFile;
              // imgFile = takePhotoWithRepaintKey();
              imgFile = File((await widget.controller.takePicture()).path);
              if (!context.mounted) return;

              LoadingIndicatorDialog().dismiss();

              // Navigate to the DisplayPicture screen and pass the imagePath.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPicture(imagePath: imgFile.path),
                ),
              );
            } catch (e) {
              LoadingIndicatorDialog().dismiss();
              log("TakingPictureWidget: $e");
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff9F5BF4), width: 4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
