import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({super.key, required this.url, this.size = 100});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: url != null
          ? Image.network(
              url!,
              height: size,
              width: size,
              fit: BoxFit.cover,
            )
          : Image.asset(
              "assets/images/card_default_bg.jpg",
              height: size,
              width: size,
              fit: BoxFit.cover,
            ),
    );
  }
}
