import 'package:bp/model/place/my_place.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/view/profile/profile_view.dart';
import 'package:bp/presentation/widgets/bottom_sheet/my_place_bottom_sheet.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyPlaceListTile extends StatefulWidget {
  const MyPlaceListTile(
      {super.key, required this.myPlace, this.forFeed = false});

  final MyPlace myPlace;
  final bool forFeed;

  @override
  State<MyPlaceListTile> createState() => _MyPlaceListTileState();
}

class _MyPlaceListTileState extends State<MyPlaceListTile> {
  bool didFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await widget.myPlace.getPlace(context);
        if (!mounted) return;
        await widget.myPlace.fetchPhotos(context);
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
    if (!didFetch) {
      return _buildLoadingIndicator();
    }
    if (widget.myPlace.place == null) {
      return FutureBuilder(
        future: Future.delayed(
            Duration.zero, () => widget.myPlace.getPlace(context)),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (widget.myPlace.place == null) return const SizedBox.shrink();
              return _buildPlaceDetailWidget();
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      );
    }

    return _buildPlaceDetailWidget();
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildPlaceDetailWidget()),
            ],
          ),
          const Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceDetailWidget() {
    return InkWell(
      onTap: didFetch
          ? () {
              showBottomSheet(
                context: context,
                enableDrag: false,
                builder: (BuildContext context) {
                  return MyPlaceBottomSheet(
                    myPlace: widget.myPlace,
                  );
                },
              );
            }
          : null,
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.myPlace.photos?.isNotEmpty == true
                  ? widget.myPlace.photos!.length
                  : 1,
              itemBuilder: (BuildContext context, int index) {
                if (widget.myPlace.photos?.isNotEmpty != true) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage(
                            "assets/images/card_default_bg.jpg"), // 배경 이미지 경로
                        fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                      ),
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget
                            .myPlace.photos![index].downloadLink), // 배경 이미지 경로
                        fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                      ),
                    ),
                  );
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white70),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AddHorizontalSpace(double.infinity),
                      Text(
                        widget.myPlace.place?.placeName ??
                            (didFetch ? "장소 이름" : ''),
                        style: TextStyleManager.h5,
                      ),
                      Text(
                        widget.myPlace.place?.categories.join(", ") ??
                            (didFetch ? "장소 카테고리" : ''),
                        style: TextStyleManager.body3,
                      ),
                      const Divider(),
                      widget.forFeed
                          ? Text(
                              widget.myPlace.place?.placeAddress ??
                                  (didFetch ? "장소 주소" : ''),
                              style: TextStyleManager.body3,
                            )
                          : Text(
                              DateFormat('yyyy년 MM월 dd일 HH시 mm분')
                                  .format(widget.myPlace.createdAt),
                              style: TextStyleManager.body3,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPlaceSmallListTile extends StatefulWidget {
  const MyPlaceSmallListTile({
    super.key,
    required this.myPlace,
  });

  final MyPlace myPlace;

  @override
  State<MyPlaceSmallListTile> createState() => _MyPlaceSmallListTileState();
}

class _MyPlaceSmallListTileState extends State<MyPlaceSmallListTile> {
  bool didFetch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await widget.myPlace.getPlace(context);
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
    if (!didFetch) {
      return _buildLoadingIndicator();
    }
    if (widget.myPlace.place == null) {
      return FutureBuilder(
        future: Future.delayed(
            Duration.zero, () => widget.myPlace.getPlace(context)),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (widget.myPlace.place == null) return const SizedBox.shrink();
              return _buildPlaceDetailWidget();
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      );
    }

    return _buildPlaceDetailWidget();
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildPlaceDetailWidget()),
            ],
          ),
          const Center(
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceDetailWidget() {
    final nonListenableProvider =
        Provider.of<PlaceProvider>(context, listen: false);
    return InkWell(
      onTap: didFetch
          ? () {
              nonListenableProvider.addOrDeleteMyPlaceToShare(widget.myPlace);
            }
          : null,
      child: RoundedCornerContainer(
        bgColor:
            nonListenableProvider.containesMyPlacesToShare(widget.myPlace) ==
                    true
                ? ColorManager.green01
                : ColorManager.grey02,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AddHorizontalSpace(double.infinity),
              Text(
                widget.myPlace.place?.placeName ?? (didFetch ? "장소 이름" : ''),
                style: TextStyleManager.h5,
              ),
              Text(
                widget.myPlace.place?.categories.map((e) => "#$e").join(" ") ??
                    (didFetch ? "장소 카테고리" : ''),
                style: TextStyleManager.body3
                    .copyWith(color: ColorManager.primary),
              ),
              Text(
                widget.myPlace.place?.placeAddress ?? (didFetch ? "장소 주소" : ''),
                style: TextStyleManager.body3,
              ),
              Text(
                DateFormat('yyyy년 MM월 dd일 HH시 mm분에 추가했어요.')
                    .format(widget.myPlace.createdAt),
                style: TextStyleManager.body3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
