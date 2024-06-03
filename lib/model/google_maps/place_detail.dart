class PlaceDetail {
  final String formattedAddress;
  final ViewPort? viewport;
  final String name;
  final List<String> types;
  final String url;

  PlaceDetail({
    required this.formattedAddress,
    required this.viewport,
    required this.name,
    required this.types,
    required this.url,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      formattedAddress: json["formatted_address"],
      viewport: json["viewport"] != null ? ViewPort.fromJson(json["viewport"]) : null,
      name: json["name"],
      types: List<String>.from(json["types"]),
      url: json["url"],
    );
  }
}

class ViewPort {
  final Coordinates northeast;
  final Coordinates southwest;

  ViewPort({required this.northeast, required this.southwest});

  factory ViewPort.fromJson(Map<String, dynamic> json) {
    return ViewPort(
      northeast: Coordinates.fromJson(json['northeast']),
      southwest: Coordinates.fromJson(json['southwest']),
    );
  }

  @override
  String toString() {
    return "northeast: {lat: ${northeast.lat}}, long:${northeast.lng}\nsouthwest: {lat: ${southwest.lat}}, long:${southwest.lng}";
  }
}

class Coordinates {
  final String lat;
  final String lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(lat: json['lat'], lng: json['lng']);
  }
}
