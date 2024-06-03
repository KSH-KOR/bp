import 'package:bp/model/kakao_map/place_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class Place {
  final String placeName;
  final String placeAddress;
  final String phoneNumber;
  final String placeCategory;
  final List<String> categories;
  final String mapUrl;
  final DocumentReference<Map<String, dynamic>>? docRef;
  final String kakaoPlaceId;
  final int savedCnt;
  final GeoFirePoint? geo;

  Place({
    required this.savedCnt,
    required this.placeName,
    required this.placeAddress,
    required this.phoneNumber,
    required this.placeCategory,
    required this.categories,
    required this.mapUrl,
    required this.docRef,
    required this.kakaoPlaceId,
    required this.geo,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    GeoPoint gp = json["geo"]?["geopoint"] ??
        GeoPoint(double.parse(json["y"]), double.parse(json["x"]));
    DocumentReference<Map<String, dynamic>> docRef =
        json['docRef'] is DocumentReference
            ? json['docRef']
            : FirebaseFirestore.instance.doc(json['docRef']);
    return Place(
      placeName: json['placeName'],
      placeAddress: json['placeAddress'],
      phoneNumber: json['phoneNumber'],
      placeCategory: json['placeCategory'],
      categories: List<String>.from(json['categories']),
      mapUrl: json['mapUrl'],
      docRef: docRef,
      kakaoPlaceId: json['kakaoPlaceId'],
      savedCnt: json["savedCnt"] ?? 0,
      geo: GeoFlutterFire()
          .point(latitude: gp.latitude, longitude: gp.longitude),
    );
  }

  factory Place.fromPlaceDetail(PlaceDetail detail) {
    return Place(
      docRef: null,
      kakaoPlaceId: detail.id,
      placeName: detail.placeName,
      placeAddress: detail.addressName,
      phoneNumber: detail.phone,
      placeCategory: detail.categoryGroupMame,
      categories: detail.categoryName
          .split(">")
          .map((e) => e.replaceAll(" ", ""))
          .toList(),
      mapUrl: detail.placeUrl,
      savedCnt: 0,
      geo: GeoFlutterFire().point(
          latitude: double.parse(detail.y), longitude: double.parse(detail.x)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
      'placeAddress': placeAddress,
      'phoneNumber': phoneNumber,
      'placeCategory': placeCategory,
      'categories': categories,
      'mapUrl': mapUrl,
      'docRef': docRef,
      'kakaoPlaceId': kakaoPlaceId,
      'geo': geo?.data,
    };
  }

  Place copyWith({int? savedCnt}) {
    return Place(
      savedCnt: savedCnt ?? this.savedCnt,
      placeName: placeName,
      placeAddress: placeAddress,
      phoneNumber: phoneNumber,
      placeCategory: placeCategory,
      categories: categories,
      mapUrl: mapUrl,
      docRef: docRef,
      kakaoPlaceId: kakaoPlaceId,
      geo: geo,
    );
  }

  String toPrettyString() {
    return """$placeName
$placeAddress
${categories.map((e) => "#$e").join(" ")}
바로가기: $mapUrl
""";
  }
}
