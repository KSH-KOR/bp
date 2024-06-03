import 'package:bp/model/google_maps/place_detail.dart';
import 'package:flutter/material.dart';

class LocationDetail extends StatelessWidget {
  const LocationDetail({super.key, required this.placeDetail});

  final PlaceDetail placeDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Text(placeDetail.formattedAddress),
        Text(placeDetail.name),
        Text(placeDetail.url),
        Text(placeDetail.types.join(', ')),
        Text(placeDetail.viewport.toString()),
      ]),
    );
  }
}
