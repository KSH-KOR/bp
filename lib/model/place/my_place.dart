import 'dart:async';
import 'dart:io';

import 'package:bp/model/firestore_models/storage_model.dart';
import 'package:bp/model/place/place.dart';
import 'package:bp/provider/place_provider.dart';
import 'package:bp/service/firestore/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:provider/provider.dart';

class MyPlaceRepo {
  final String uid;
  final List<File>? files; //file path
  final String? description;
  final List<String>? categories;
  final bool? public;
  final DocumentReference<Map<String, dynamic>> placeRef;
  final GeoFirePoint? geo;

  MyPlaceRepo({
    required this.uid,
    required this.files,
    required this.description,
    required this.placeRef,
    required this.categories,
    this.public,
    required this.geo,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'placeRef': placeRef,
      'description': description,
      'categories': categories,
      'public': public,
      'geo': geo?.data,
    };
  }
}

class MyPlace extends MyPlaceRepo {
  final DateTime createdAt;
  final DocumentReference<Map<String, dynamic>>? docRef;
  Place? place;
  List<FirebaseStorageModel>? photos;

  MyPlace(
      {required super.uid,
      required super.placeRef,
      required super.files, //file url address
      required super.description,
      required this.createdAt,
      required this.docRef,
      required super.categories,
      required super.geo,
      this.place});

  FutureOr<List<FirebaseStorageModel>> fetchPhotos(BuildContext context) async {
    if (photos != null) return photos!;
    if (docRef == null) return [];
    photos = await Provider.of<PlaceProvider>(context, listen: false)
        .fetchPlacePhotos(
            fileStorageType: FileStorageType.placePhotos, folderId: docRef!.id);
    return photos!;
  }

  void setPlace(Place p) {
    place = p;
  }

  Future<Place> getPlace(BuildContext context) async {
    if (place != null) return place!;
    place = await Provider.of<PlaceProvider>(context, listen: false)
        .getPlaceByRef(this);
    return place!;
  }

  factory MyPlace.fromJson(Map<String, dynamic> json) {
    GeoPoint gp = json["geo"]?["geopoint"] ??
        GeoPoint(double.parse(json["y"]), double.parse(json["x"]));
    DocumentReference<Map<String, dynamic>>? docRef = json['docRef'] == null
        ? null
        : (json['docRef'] is DocumentReference
            ? json['docRef']
            : FirebaseFirestore.instance.doc(json['docRef']));
    final millisecondsSinceEpoch = json["createdAt"] is Timestamp
        ? json['createdAt'].millisecondsSinceEpoch
        : json["createdAt"] is String
            ? DateTime.parse(json['createdAt']).millisecondsSinceEpoch
            : json['createdAt'];
    return MyPlace(
      uid: json['uid'],
      placeRef: json['placeRef'], // 문자열로부터 DocumentReference 복원
      description: json['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
      docRef: docRef,
      files: null,
      place: json["place"] != null ? Place.fromJson(json["place"]) : null,
      categories: List<String>.from(json['categories']),
      geo: GeoFlutterFire()
          .point(latitude: gp.latitude, longitude: gp.longitude),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'uid': uid,
      'placeRef': placeRef,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch, // DateTime을 timestamp로 변환
      'geo': geo?.data,
      'place': place?.toJson(),
      'docRef': docRef,
    };
  }

  String toPrettyString() {
    return place?.toPrettyString() ?? "";
  }
}
