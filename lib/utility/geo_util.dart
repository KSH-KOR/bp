import 'dart:math';

class GeoUtils {
  static const double earthRadiusKm = 6371.0;

  static double degToRad(double degrees) {
    return degrees * pi / 180.0;
  }

  static double radToDeg(double radians) {
    return radians * 180.0 / pi;
  }

  static Map<String, double> calculateBoundingBox(
      double lat, double lon, double radiusInKm) {
    double latRad = degToRad(lat);
    double lonRad = degToRad(lon);

    double radiusRad = radiusInKm / earthRadiusKm;

    double minLat = latRad - radiusRad;
    double maxLat = latRad + radiusRad;

    double minLon, maxLon;
    if (minLat > -pi / 2 && maxLat < pi / 2) {
      double deltaLon = asin(sin(radiusRad) / cos(latRad));
      minLon = lonRad - deltaLon;
      if (minLon < -pi) minLon += 2 * pi;
      maxLon = lonRad + deltaLon;
      if (maxLon > pi) maxLon -= 2 * pi;
    } else {
      minLat = max(minLat, -pi / 2);
      maxLat = min(maxLat, pi / 2);
      minLon = -pi;
      maxLon = pi;
    }

    return {
      'minLat': radToDeg(minLat),
      'maxLat': radToDeg(maxLat),
      'minLon': radToDeg(minLon),
      'maxLon': radToDeg(maxLon),
    };
  }

  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double lat1Rad = degToRad(lat1);
    double lon1Rad = degToRad(lon1);
    double lat2Rad = degToRad(lat2);
    double lon2Rad = degToRad(lon2);

    double dlat = lat2Rad - lat1Rad;
    double dlon = lon2Rad - lon1Rad;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }
}
