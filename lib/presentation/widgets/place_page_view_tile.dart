import 'dart:io';

import 'package:flutter/material.dart';

import '../../model/place/place.dart';

class PlacePageViewTile extends StatelessWidget {
  const PlacePageViewTile({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_horiz),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PlaceInformationCard(place: place),
          ),
        ],
      ),
    );
  }
}

class PlaceImageCard extends StatelessWidget {
  const PlaceImageCard({super.key, required this.files});

  final List<File>? files;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PlaceInformationCard extends StatelessWidget {
  const PlaceInformationCard({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Text(place.placeName),
          ],
        ),
        const Icon(Icons.navigate_next),
      ],
    );
  }
}
