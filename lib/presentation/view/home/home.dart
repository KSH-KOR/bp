import 'package:bp/constant/routes/routes.dart';
import 'package:bp/presentation/styles/color_manager.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:bp/presentation/view/explore/explore_view.dart';
import 'package:bp/presentation/view/map/map_view.dart';
import 'package:bp/presentation/view/profile/profile_view.dart';
import 'package:bp/presentation/view/share/share_view.dart';
import 'package:flutter/material.dart';
import '../add_place/constants/page_contents.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int pageNo = 0;
  List<Widget> pages = [
    const ExplorePlaceView(),
    const PlacesOnMapView(),
    const SharePlacesView(),
    const ProfileView(),
  ];
  void onTap(value) {
    if (value >= pages.length) return;
    setState(() {
      pageNo = value;
    });
  }

  final items = [
    const Column(
      children: [
        Icon(Icons.home),
        Text("피드", style: TextStyleManager.body3),
      ],
    ),
    const Column(
      children: [
        Icon(Icons.map),
        Text("지도", style: TextStyleManager.body3),
      ],
    ),
    const SizedBox(),
    const Column(
      children: [
        Icon(Icons.folder_shared),
        Text("공유", style: TextStyleManager.body3),
      ],
    ),
    const Column(
      children: [
        Icon(Icons.person),
        Text("프로필", style: TextStyleManager.body3),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[pageNo]),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(formRoute, arguments: pageContents);
        },
        shape: RoundedRectangleBorder(
            side:
                BorderSide(width: 1, color: ColorManager.botCardColorPersonal),
            borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        color: ColorManager.grey01,
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            items.length,
            (index) => IconButton(
              icon: items[index],
              color: pageNo == (index > pages.length / 2 ? index - 1 : index)
                  ? ColorManager.primary
                  : null,
              onPressed: index != pages.length / 2
                  ? () => onTap(index > pages.length / 2 ? index - 1 : index)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
