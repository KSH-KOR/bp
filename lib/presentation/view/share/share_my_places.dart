import 'dart:developer';

import 'package:bp/model_to_widget/my_place/list_tile.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/view/display_saved_place/widgets/widget.dart';
import 'package:bp/presentation/view/share/share_view.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/auth_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final scaffoldKey = GlobalKey<ScaffoldState>();

class ShareMyPlaces extends StatefulWidget {
  const ShareMyPlaces({super.key});

  @override
  State<ShareMyPlaces> createState() => _ShareMyPlacesState();
}

class _ShareMyPlacesState extends State<ShareMyPlaces> {
  String? errMsg;
  bool didFetch = false;
  bool bottomSheetOpen = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        final String? uid =
            Provider.of<AppAuthProvider>(context, listen: false).user?.uid;
        if (uid == null) {
          throw FetchException(msg: "유저 정보가 없습니다.");
        }
        await Provider.of<PlaceProvider>(context, listen: false)
            .fetchMyPlaces(uid, context: context, shouldNotify: true);
      } catch (e) {
        if (e is FetchException) {
          errMsg = e.toString();
        } else {
          errMsg = "저장된 장소를 불러오는데 실패하였습니다.";
        }
      } finally {
        if (mounted) {
          setState(() {
            didFetch = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);
    final myPlaces = provider.getFilteredMyPlaces();
    if (!didFetch) {
      return const Scaffold(
        body: Column(
          children: [
            Spacer(),
            LinearProgressIndicator(),
          ],
        ),
      );
    }
    if (errMsg != null || myPlaces == null) {
      return Scaffold(
        body: Column(
          children: [
            const Spacer(),
            Text(errMsg ?? "내 장소를 불러오는데 실패하였습니다."),
            const Spacer(),
          ],
        ),
      );
    }
    if (!provider.hasFilter && myPlaces.isEmpty) {
      return const Scaffold(
        body: Column(
          children: [
            Spacer(),
            SizedBox(width: double.infinity),
            Text("등록된 장소가 없습니다."),
            Spacer(),
          ],
        ),
      );
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SearchTextField(),
            const AddVerticalSpace(8),
            const CategoryChipPannel(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      final func =
                          Provider.of<PlaceProvider>(context, listen: false)
                              .addMyPlaceToShare;
                      myPlaces.forEach(func);
                    },
                    child: Text(
                      "전체선택",
                      style: TextStyleManager.body5
                          .copyWith(color: ColorManager.navy),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final func =
                          Provider.of<PlaceProvider>(context, listen: false)
                              .deleteMyPlaceToShare;
                      myPlaces.forEach(func);
                    },
                    child: Text(
                      "전체취소",
                      style: TextStyleManager.body5
                          .copyWith(color: ColorManager.red),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final String? uid =
                      Provider.of<AppAuthProvider>(context, listen: false)
                          .user
                          ?.uid;
                  if (uid == null) return;
                  await Provider.of<PlaceProvider>(context, listen: false)
                      .fetchMyPlaces(uid, context: context, shouldNotify: true);
                },
                child: ListView.separated(
                  itemCount: myPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    return MyPlaceSmallListTile(
                      myPlace: myPlaces[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const AddVerticalSpace(8);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: bottomSheetOpen
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                setState(() {
                  bottomSheetOpen = true;
                });
                final controller = scaffoldKey.currentState!.showBottomSheet(
                  (BuildContext context) {
                    return const SharePlaceBottomSheet();
                  },
                );
                await controller.closed;
                setState(() {
                  bottomSheetOpen = false;
                });
              },
              label: Text(
                  provider.selectedPlacesToShare?.length.toString() ?? "0"),
              icon: const Icon(Icons.ios_share),
            ),
    );
  }
}

class SharePlaceBottomSheet extends StatefulWidget {
  const SharePlaceBottomSheet({super.key});

  @override
  State<SharePlaceBottomSheet> createState() => _SharePlaceBottomSheetState();
}

class _SharePlaceBottomSheetState extends State<SharePlaceBottomSheet> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final places = Provider.of<PlaceProvider>(context).selectedPlacesToShare;
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100.withAlpha(0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
          TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: titleController,
              autofocus: true,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                labelText: "제목을 입력해주세요.",
                labelStyle: const TextStyle(color: Colors.black),
              )),
          const AddVerticalSpace(8),
          TextField(
              textAlignVertical: TextAlignVertical.center,
              controller: descController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                labelText: "내용을 입력해주세요.",
                labelStyle: const TextStyle(color: Colors.black),
              )),
          const AddVerticalSpace(8),
          const Divider(),
          const SelectedPlaceSummaryListView(),
          PrimaryButton(
            onPress: places != null &&
                    places.isNotEmpty &&
                    titleController.text.isNotEmpty
                ? () async {
                    try {
                      final user =
                          Provider.of<AppAuthProvider>(context, listen: false)
                              .user;
                      if (user == null) return;
                      final placeZip = await Provider.of<PlaceProvider>(context,
                              listen: false)
                          .postShareZip(
                              title: titleController.text,
                              description: descController.text,
                              user: user);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return PlaceListInZipView(
                          placeZip: placeZip,
                        );
                      }));
                    } catch (e) {
                      log(e.toString());
                    }
                  }
                : null,
            buttonMsg: "공유하기",
          ),
        ],
      ),
    );
  }
}

class SelectedPlaceSummaryListView extends StatelessWidget {
  const SelectedPlaceSummaryListView({super.key});
  @override
  Widget build(BuildContext context) {
    final places = Provider.of<PlaceProvider>(context).selectedPlacesToShare;
    if (places == null || places.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text("선택한 장소가 없습니다."),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            leading: Text(
              "${index + 1}",
              style: TextStyleManager.body3,
            ),
            title: Text(places[index].place?.placeName ?? "-"),
          );
        },
        itemCount: places.length,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key, required this.onPress, required this.buttonMsg});

  final Function()? onPress;
  final String buttonMsg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        onPressed: onPress,
        child: Text(
          buttonMsg,
          style: TextStyleManager.body7white,
        ),
      ),
    );
  }
}
