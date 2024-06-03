class PickedImageInfo {
  final double? lat;
  final double? long;
  final DateTime? datetime;
  final String? name;

  PickedImageInfo({required this.lat, required this.long, required this.datetime, required this.name});

  factory PickedImageInfo.fromJson(Map<String, dynamic> json){
    return PickedImageInfo(lat: json["latitude"], long: json["longitude"], datetime: json["datetime"], name: json["name"]);
  }

  bool hasCoordinate(){
    return lat != null && long != null;
  }
  String coordinateToString(){
    if(!hasCoordinate()) return "No Coordinate";
    return "lat: $lat\nlong: $long";
  }
}