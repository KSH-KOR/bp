import 'package:bp/service/kakao_service.dart';

class PlaceDetail {
  final String addressName;
  final String categoryGroupCode;
  final String categoryGroupMame;
  final String categoryName;
  final String distance;
  final String id;
  final String phone;
  final String placeName;
  final String placeUrl;
  final String roadAddressName;
  final String x;
  final String y;

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      addressName: json["address_name"],
      categoryGroupCode: json["category_group_code"],
      categoryGroupMame: json["category_group_name"],
      categoryName: json["category_name"],
      distance: json["distance"],
      id: json["id"],
      phone: json["phone"],
      placeName: json["place_name"],
      placeUrl: json["place_url"],
      roadAddressName: json["road_address_name"],
      x: json["x"],
      y: json["y"],
    );
  }

  PlaceDetail(
      {required this.addressName,
      required this.categoryGroupCode,
      required this.categoryGroupMame,
      required this.categoryName,
      required this.distance,
      required this.id,
      required this.phone,
      required this.placeName,
      required this.placeUrl,
      required this.roadAddressName,
      required this.x,
      required this.y});
}

class KakaoSearchMeta {
  final bool isEnd;
  final int pageableCount;
  final int totalCount;

  KakaoSearchMeta(
      {required this.isEnd,
      required this.pageableCount,
      required this.totalCount});

  factory KakaoSearchMeta.fromJson(Map<String, dynamic> json) {
    return KakaoSearchMeta(
      isEnd: json["is_end"],
      pageableCount: json["pageable_count"],
      totalCount: json["total_count"],
    );
  }
}

class KakaoSearchResult {
  final int pageNo;
  final KakaoSearchQuerySet querySet;
  final List<PlaceDetail> placeDetail;
  final KakaoSearchMeta meta;

  KakaoSearchResult(
      {required this.pageNo,
      required this.querySet,
      required this.placeDetail,
      required this.meta});

  factory KakaoSearchResult.fromJson(Map<String, dynamic> json,
      {required int pageNo, required KakaoSearchQuerySet querySet}) {
    final List<Map<String, dynamic>> docs = List<Map<String, dynamic>>.from(
        json["documents"].map((item) => Map<String, dynamic>.from(item)));
    final list = docs.map((json) => PlaceDetail.fromJson(json)).toList();
    return KakaoSearchResult(
      pageNo: pageNo,
      querySet: querySet,
      placeDetail: list,
      meta: KakaoSearchMeta.fromJson(json["meta"]),
    );
  }
}
