
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedLocationModel {
  final String id;
  final String uid;
  final double latitude;
  final double longitude;
  final String method;
  final String placeId;
  final String address;
  final DateTime? visitedAt;
  final DateTime? timestamp; // Optional since it's server-generated

  SavedLocationModel({
    required this.id,
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.method,
    required this.placeId,
    required this.address,
    required this.visitedAt,
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'placeId': placeId,
      'address': address,
      'visitedAt': visitedAt?.toIso8601String(), // Convert DateTime to String
      // 'timestamp' is omitted because it's set by the server
    };
  }

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    // ignore: prefer_typing_uninitialized_variables
    late final time;
    if(json['visitedAt'] is String) {
      time = DateTime.parse(json['visitedAt']);
    } else if(json['visitedAt'] is Timestamp) {
      time = (json['timestamp'] as Timestamp).toDate();
    } else{
      time = null;
    }
    return SavedLocationModel(
      id: json['id'],
      uid: json['uid'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      method: json['method'],
      placeId: json['placeId'],
      address: json['address'],
    visitedAt: time,
      // Assuming 'timestamp' is also a Timestamp and needs conversion
      timestamp: json['timestamp'] != null
          ? (json['timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}
