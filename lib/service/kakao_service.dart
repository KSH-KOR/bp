import 'dart:convert';
import 'dart:developer';
import 'package:bp/model/kakao_map/place_detail.dart';
import 'package:http/http.dart' as http;

class FetchException implements Exception {
  final String msg;

  FetchException({required this.msg});

  @override
  String toString() {
    return msg;
  }
}

class KakaoSearchQuerySet {
  final String query;
  final String? categoryGroupCode;
  final String? x;
  final String? y;
  final int? radius;
  final String? rect;
  final int? page;
  final int? size;
  final String? sort;

  KakaoSearchQuerySet(
      {required this.query,
      this.categoryGroupCode,
      this.x,
      this.y,
      this.radius,
      this.rect,
      this.page,
      this.size,
      this.sort});
}

class KakaoSearchService {
  final String apiKey; // 카카오 API 키

  KakaoSearchService({this.apiKey = "925ea62365b0a59eceb4f215a7e22d21"});

  Future<KakaoSearchResult> searchPlaces(
      {required KakaoSearchQuerySet querySet}) async {
    // 매개변수를 URI 쿼리 스트링으로 변환
    var parameters = {
      'query': querySet.query,
      if (querySet.categoryGroupCode != null)
        'category_group_code': querySet.categoryGroupCode,
      if (querySet.x != null && querySet.y != null) 'x': querySet.x,
      'y': querySet.y,
      if (querySet.radius != null) 'radius': querySet.radius.toString(),
      if (querySet.rect != null) 'rect': querySet.rect,
      if (querySet.page != null) 'page': querySet.page.toString(),
      if (querySet.size != null) 'size': querySet.size.toString(),
      if (querySet.sort != null) 'sort': querySet.sort,
    };
    const String baseUrl =
        'https://dapi.kakao.com/v2/local/search/keyword.json';

    try {
      final response = await http.get(
        Uri.parse(baseUrl).replace(queryParameters: parameters),
        headers: {'Authorization': 'KakaoAK $apiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return KakaoSearchResult.fromJson(data,
            pageNo: querySet.page ?? 1, querySet: querySet);
      } else {
        throw FetchException(
            msg: '서버로부터 데이터를 받아오는 데 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      log('에러가 발생했습니다: $e');
      throw Exception("에러가 발생했습니다:");
    }
  }
}
