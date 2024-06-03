import 'package:bp/service/google_map_api_service.dart';
import 'package:flutter/material.dart';

import '../model/user_saved_location.dart';
import '../service/firestore/firestore_service.dart';

class LocationProvider with ChangeNotifier {
  bool didFetch = false;
  List<UserSavedLocation>? userSavedLocation;

  static const userSavedLocationHiveBoxName = "userSavedLocation";

  Future<void> fetchUserSavedLocation(String uid,
      {bool shouldNotify = true}) async {
    final locations = await FirestoreService().getSavedLocationsByUid(uid);
    List<Future> futures = [];
    userSavedLocation = locations.map((location) {
      final futurePlaceDetail =
          GoogleMapAPIService.getDetailFromPlaceId(location.placeId);
      final model = UserSavedLocation(location: location);
      futures.add(futurePlaceDetail
          .then((placeDetail) => model.setPlaceDetailCallBack(placeDetail)));
      return model;
    }).toList();

    await Future.wait(futures);

    if (shouldNotify) notifyListeners();
  }
}
