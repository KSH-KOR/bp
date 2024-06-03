import 'package:bp/presentation/view/display_saved_place/saved_place_list_view.dart';
import 'package:bp/presentation/view/profile/components/profile_image.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/fireabse_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../../provider/auth_provider.dart';
import '../../styles/text_style_manager.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool didFetch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [
          AppBarPopUpMenu(),
        ],
      ),
      body: const ProfileContent(),
    );
  }
}

class AppBarPopUpMenu extends StatelessWidget {
  const AppBarPopUpMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(itemBuilder: (context) {
      return const [
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "로그아웃",
            style: TextStyleManager.body3,
          ),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Text(""),
        ),
      ];
    }, onSelected: (value) async {
      if (value == 0) {
        FirebaseAuthService().signOut(context);
      }
    });
  }
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppAuthProvider>(context).user;
    if (user == null) {
      return const Center(child: Text("No User Found"));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(width: double.infinity),
              ProfileTop(
                user: user,
              ),
              const SizedBox(height: 8),
              const ContentsInfoPanel(),
            ],
          ),
        ),
        Expanded(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: const Color(0xffF8F8FA),
              child: const SavedPlaceListView()),
        ),
      ],
    );
  }
}

class ProfileTop extends StatelessWidget {
  const ProfileTop({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProfileImage(url: user.profileImageUrl),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name ?? "no name", style: TextStyleManager.h7),
              const SizedBox(height: 8),
              Text(user.email, style: TextStyleManager.body3),
            ],
          ),
        ),
      ],
    );
  }
}

class ContentsInfoPanel extends StatelessWidget {
  const ContentsInfoPanel({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context, listen: true);
    return RoundedCornerContainer(
      bgColor: const Color(0x00faf7ff),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text("saved"),
            Text(provider.myPlaces?.length.toString() ?? "-"),
          ],
        ),
        const Column(
          children: [
            Text("liked"),
            Text("304"),
          ],
        ),
      ]),
    );
  }
}

class RoundedCornerContainer extends StatelessWidget {
  const RoundedCornerContainer(
      {super.key,
      required this.bgColor,
      required this.child,
      this.radius = 12,
      this.padding = 8});

  final Color bgColor;
  final Widget child;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: child,
    );
  }
}
