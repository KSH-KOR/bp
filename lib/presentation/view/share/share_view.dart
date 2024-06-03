import 'dart:developer';

import 'package:bp/constant/routes/routes.dart';
import 'package:bp/model/place/place_zip.dart';
import 'package:bp/model_to_widget/my_place/list_tile.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/view/share/places_zip_tile.dart';
import 'package:bp/presentation/widgets/rounded_corner_container.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/auth_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/firestore/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SharePlacesView extends StatefulWidget {
  const SharePlacesView({super.key});

  @override
  State<SharePlacesView> createState() => _SharePlacesViewState();
}

class _SharePlacesViewState extends State<SharePlacesView> {
  bool shareToggle = false;
  bool didFetch = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        final uid =
            Provider.of<AppAuthProvider>(context, listen: false).user?.uid;
        if (uid == null) return;
        await Provider.of<PlaceProvider>(context, listen: false)
            .fetchMyShareZip(uid, shouldNotify: false);
      } catch (e) {
        log("$e");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "장소ZIP",
          style: TextStyleManager.h6,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(shareToggle ? "공유한 ZIP 보기" : "공유 받은 ZIP 보기"),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                shareToggle ? "내가 공유 받은 장소 ZIP들이에요." : "내가 공유한 장소 ZIP들이에요.",
                style:
                    TextStyleManager.body5.copyWith(color: ColorManager.green),
              ),
            ),
            const AddVerticalSpace(14),
            _buildContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(shareMyPlacesRoute);
        },
        heroTag: null,
        label: const Text("공유하기"),
        icon: const Icon(Icons.ios_share),
      ),
    );
  }

  Widget _buildContent() {
    final provider = Provider.of<PlaceProvider>(context);
    if (!didFetch) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (shareToggle ? true : provider.mySharedPlaceZip == null) {
      return const Expanded(
        child: Center(
          child: Text("내역을 불러오는데 실패했어요."),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: provider.mySharedPlaceZip!.length,
        itemBuilder: (BuildContext context, int index) {
          return PlacesZipTile(placeZip: provider.mySharedPlaceZip![index]);
        },
      ),
    );
  }
}

class PlaceListInZipView extends StatefulWidget {
  const PlaceListInZipView({super.key, this.placeZip});

  final PlaceZip? placeZip;

  @override
  State<PlaceListInZipView> createState() => _PlaceListInZipViewState();
}

class _PlaceListInZipViewState extends State<PlaceListInZipView> {
  PlaceZip? zip;
  bool didFetch = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final arg = ModalRoute.of(context)?.settings.arguments;
      try {
        if (arg is String) {
          zip = await FirestoreService().fetchSharedPlaceZip(id: arg);
        } else {
          zip = widget.placeZip;
        }
      } catch (e) {
        log(e.toString());
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
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Text(
                zip?.title ?? "",
                style: TextStyleManager.h5,
              ),
              const AddVerticalSpace(12),
              RoundedCornerContainer(
                color: ColorManager.grey02,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "${zip?.likeCnt ?? 0}명이 좋아해요.",
                        style: TextStyleManager.body4navy,
                      ),
                      Text(
                        "${zip?.sharedCnt ?? 0}명에게 공유되었어요.",
                        style: TextStyleManager.body4navy,
                      ),
                    ],
                  ),
                ),
              ),
              const AddVerticalSpace(12),
              Expanded(
                child: didFetch
                    ? ListView.separated(
                        itemCount: zip?.places?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          final myPlace = zip?.places?[index];
                          if (myPlace == null) return const SizedBox.shrink();
                          return MyPlaceListTile(
                            myPlace: myPlace,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const AddVerticalSpace(8);
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
