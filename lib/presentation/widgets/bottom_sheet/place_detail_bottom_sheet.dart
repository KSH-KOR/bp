import 'package:bp/model/kakao_map/place_detail.dart';
import 'package:bp/presentation/styles/text_style_manager.dart';
import 'package:flutter/material.dart';

class PlaceDetailBottomSheet extends StatelessWidget {
  const PlaceDetailBottomSheet({
    super.key,
    required this.placeDetail,
  });

  final PlaceDetail placeDetail;

  @override
  Widget build(BuildContext context) {
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
          Text(
            placeDetail.placeName,
            style: TextStyleManager.h3,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            placeDetail.addressName,
            style: TextStyleManager.body5,
          ),
          Text(
            placeDetail.roadAddressName,
            style: TextStyleManager.body5,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Icon(Icons.phone),
              const SizedBox(
                width: 4,
              ),
              Text(placeDetail.phone),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(placeDetail.categoryGroupMame),
          const SizedBox(
            height: 8,
          ),
          Text(placeDetail.categoryName),
          const SizedBox(
            height: 8,
          ),
          Text("${placeDetail.distance} 미터"),
          const SizedBox(
            height: 8,
          ),
          Text(placeDetail.placeUrl),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
