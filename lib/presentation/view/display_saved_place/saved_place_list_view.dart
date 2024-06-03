import 'package:bp/model_to_widget/my_place/list_tile.dart';
import 'package:bp/presentation/view/display_saved_place/widgets/widget.dart';
import 'package:bp/presentation/widgets/space.dart';
import 'package:bp/provider/auth_provider.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/kakao_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SavedPlaceListView extends StatefulWidget {
  const SavedPlaceListView({super.key});

  @override
  State<SavedPlaceListView> createState() => _SavedPlaceListViewState();
}

class _SavedPlaceListViewState extends State<SavedPlaceListView> {
  String? errMsg;
  bool didFetch = false;
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
      return const Column(
        children: [
          Spacer(),
          LinearProgressIndicator(),
        ],
      );
    }
    if (errMsg != null || myPlaces == null) {
      return Column(
        children: [
          const Spacer(),
          Text(errMsg ?? "내 장소를 불러오는데 실패하였습니다."),
          const Spacer(),
        ],
      );
    }
    if (!provider.hasFilter && myPlaces.isEmpty) {
      return const Column(
        children: [
          Spacer(),
          SizedBox(width: double.infinity),
          Text("등록된 장소가 없습니다."),
          Spacer(),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const SearchTextField(),
          const AddVerticalSpace(8),
          const CategoryChipHorizontalListView(),
          const AddVerticalSpace(8),
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
                  return MyPlaceListTile(
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
    );
  }
}
