import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bp/model_to_widget/my_place/list_tile.dart';
import 'package:bp/provider/place_provider.dart';

class ExplorePlaceView extends StatefulWidget {
  const ExplorePlaceView({super.key});

  @override
  State<ExplorePlaceView> createState() => _ExplorePlaceViewState();
}

class _ExplorePlaceViewState extends State<ExplorePlaceView> {
  String? errMsg;
  bool didFetch = false;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      await Provider.of<PlaceProvider>(context, listen: false)
          .fetchPublicPlacesList(context: context, shouldNotify: false);
    } catch (e) {
      setState(() {
        if (e is FetchException) {
          errMsg = e.toString();
        } else {
          errMsg = "저장된 장소를 불러오는데 실패하였습니다.";
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          didFetch = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);
    final publicPlaces = provider.publicPlaces;

    if (!didFetch) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errMsg != null || publicPlaces == null) {
      return Center(
        child: Text(errMsg ?? "이웃들의 장소를 불러오는데 실패하였습니다."),
      );
    }
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchPlaces,
            child: publicPlaces.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: Text(
                          "아직 이웃이 올린 공간이 없어요! \n공간을 추가해보세요!",
                          style: TextStyleManager.body3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                : PageView.builder(
                    itemCount: publicPlaces.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return MyPlaceListTile(
                        myPlace: publicPlaces.elementAt(index),
                        forFeed: true,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
