import 'package:bp/model/google_maps/place_detail.dart';

import 'firestore_models/saved_location.dart';

class UserSavedLocation {
  final SavedLocationModel location;
  PlaceDetail? placeDetail;

  UserSavedLocation({required this.location, this.placeDetail});

  void setPlaceDetailCallBack(PlaceDetail? placeDetail) {
    this.placeDetail = placeDetail;
  }
}
