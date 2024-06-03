import 'dart:convert';
import 'dart:developer';
import 'package:bp/model/google_maps/place_detail.dart';
import 'package:http/http.dart' as http;

class GoogleMapAPIService {
  static const apiKey = 'AIzaSyDcHdPwb3D-asJ-8-FbP5iB9Z6wnwSC90s';

  static Future<PlaceDetail?> getDetailFromPlaceId(String placeId) async {
    const fields = [
      'formatted_address',
      'geometry/viewport',
      'name',
      'photos',
      'type',
      'url',
      'formatted_phone_number',
      'opening_hours',
      'website',
      'reviews'
    ];
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?fields=${fields.join('%2C')}&place_id=$placeId&key=$apiKey');
    try {
      final response = await http.get(url);
      final body = json.decode(response.body);
      if (body['status'] != "OK") throw Exception("status is not ok");
      final model = PlaceDetail.fromJson(body['result']);
      return model;
    } catch (e) {
      log("getDetailFromPlaceId: $e");
    }
    return null;
  }

  static Future<Map<String, String>?> getAddressFromCoordinate(
      double lat, double long) async {
    // Replace with your actual API key
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey');

    try {
      final response = await http.get(url);
      final body = json.decode(response.body);

      if (body['status'] == 'OK') {
        final results = body['results'];
        if (results.isNotEmpty) {
          // Typically the most relevant address is the first result
          final address = results[0]['formatted_address'];
          final placeId = results[0]['place_id'];

          log('Address: $address');
          log('Place ID: $placeId');
          return {
            'address': address,
            'placeId': placeId,
          };
        } else {
          log('No results found for the given coordinates.');
        }
      } else {
        log('Error retrieving data: ${body['status']}');
      }
    } catch (e) {
      log('Error occurred: $e');
    }
    return null;
  }
}
