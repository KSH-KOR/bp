import 'package:bp/model/place/my_place.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PlaceZip {
  final String uid;
  final String id;
  final String? creatorName;
  final String? creatorProfileUrl;
  final String? title;
  final String? description;
  final List<String> categories;
  final DateTime createdAt;
  final int? likeCnt;
  final int? sharedCnt;
  final List<MyPlace>? places;

  PlaceZip({
    required this.uid,
    this.likeCnt,
    this.sharedCnt,
    this.places,
    this.creatorName,
    this.creatorProfileUrl,
    this.title,
    this.description,
    required this.categories,
    required this.createdAt,
    required this.id,
  });

  // fromJson method
  factory PlaceZip.fromJson(Map<String, dynamic> json) {
    final millisecondsSinceEpoch = json["createdAt"] is Timestamp
        ? json['createdAt'].millisecondsSinceEpoch
        : json["createdAt"] is String
            ? DateTime.parse(json['createdAt']).millisecondsSinceEpoch
            : json['createdAt'];
    return PlaceZip(
      uid: json["uid"],
      id: json["id"],
      creatorName: json['creatorName'],
      creatorProfileUrl: json['creatorProfileUrl'],
      title: json['title'],
      description: json['description'] as String?,
      categories: List<String>.from(json['categories']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
      likeCnt: json['likeCnt'],
      sharedCnt: json['sharedCnt'],
      places: (List<Map<String, dynamic>>.from(json['places']))
          .map((place) => MyPlace.fromJson(place))
          .toList(),
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'id': id,
      'creatorName': creatorName,
      'creatorProfileUrl': creatorProfileUrl,
      'title': title,
      'description': description,
      'categories': categories,
      'createdAt': createdAt.toIso8601String(),
      'likeCnt': likeCnt,
      'sharedCnt': sharedCnt,
      'places': places?.map((place) => place.toJson()).toList(),
    };
  }

  String toPrettyString() {
    return """
${creatorName ?? "익명"} 님께서 만든 공간 리스트입니다.

${title ?? ""}
${description ?? ""}

---
${places?.map((e) => e.toPrettyString()).join("\n") ?? "장소가 없어요.."}
---

공유시각: ${DateFormat('yyyy년 MM월 dd일 HH시 mm분').format(DateTime.now())}
""";
  }
}
