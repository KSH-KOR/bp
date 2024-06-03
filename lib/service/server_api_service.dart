import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bp/service/api_service_exception.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

class ServerAPI {
  // ignore: non_constant_identifier_names
  String BASE_URL = "https://";
  String? token;
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<dynamic> sendRequest(String method, String endpoint,
      {Map<String, dynamic>? data,
      List<Map<String, dynamic>>? filedata,
      String responseType = "json"}) async {
    final url = Uri.parse('$BASE_URL/$endpoint');

    if (token != null) {
      headers['Authorization'] = 'Token $token';
    }

    http.Response response;

    if (filedata != null && filedata.isNotEmpty) {
      response =
          await sendMultipartRequest(filedata: filedata, url: url, data: data);
    } else {
      response = await sendHttpRequest(method: method, data: data, url: url);
    }

    if (response.statusCode == 204) {
      return 204;
    } else if (response.statusCode >= 200 && response.statusCode < 400) {
      return await processBodyBytes(response.bodyBytes, responseType);
    } else {
      final json = constructResponseData(response: response);
      throw ServerException(model: ServerExceptionModel.fromJson(json));
    }
  }

  Map<String, dynamic> getNotFoundError() {
    return {
      "detail": "Not Found",
      "statusCode": 404,
    };
  }

  Map<String, dynamic> constructResponseData(
      {required http.Response response}) {
    if (response.statusCode == 404) return getNotFoundError();

    return {
      "detail": convertBodyBytesToJson(response.bodyBytes)["detail"] ??
          "Unknown detail",
      "statusCode": response.statusCode,
    };
  }

  Future<http.Response> sendHttpRequest({
    required Uri url,
    Map<String, dynamic>? data,
    required String method,
  }) async {
    late final http.Response response;
    switch (method) {
      case 'POST':
        response =
            await http.post(url, headers: headers, body: jsonEncode(data));
        break;
      case 'GET':
        response = await http.get(url, headers: headers);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      case 'PATCH':
        response =
            await http.patch(url, headers: headers, body: jsonEncode(data));
        break;
      default:
        throw Exception('Invalid HTTP method');
    }
    return response;
  }

  Future<http.Response> sendMultipartRequest(
      {required Uri url,
      Map<String, dynamic>? data,
      required List<Map<String, dynamic>> filedata}) async {
    var request = http.MultipartRequest("POST", url)..headers.addAll(headers);

    for (final element in filedata) {
      final multipartFile = await http.MultipartFile.fromPath(
          element["fileFieldName"], element["file"].path,
          contentType: element["contentType"]);
      request.files.add(multipartFile);
    }

    if (data != null) {
      String jsonData = jsonEncode(data);
      request.fields['json_data'] = jsonData;
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<dynamic> processBodyBytes(Uint8List bodyBytes, responseType) async {
    if (responseType == "json") {
      return convertBodyBytesToJson(bodyBytes);
    } else if (responseType == "audio") {
      return await convertBodyBytesToFile(bodyBytes);
    } else {
      throw Exception("Unsupported response type: $responseType");
    }
  }

  Future<File> convertBodyBytesToFile(Uint8List bodyBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/temp/retrievedAudio.wav';

    // Write the bytes to a file and return it
    final file = File(filePath);
    await file.writeAsBytes(bodyBytes);
    return file;
  }

  dynamic convertBodyBytesToJson(Uint8List bodyBytes) {
    final decodedBody = utf8.decode(bodyBytes);
    final decodedJson = json.decode(decodedBody);

    if (decodedJson is Map<String, dynamic>) {
      return decodedJson;
    } else if (decodedJson is List) {
      return decodedJson
          .map<Map<String, dynamic>>((e) => e as Map<String, dynamic>)
          .toList();
    } else if (decodedJson is String) {
      return {"detail": decodedJson};
    } else {
      throw Exception(
          "Unsupported type for bodyBytes: [${decodedJson.runtimeType.toString()}]");
    }
  }

  static ServerAPI? _instance;

  factory ServerAPI() {
    _instance ??= ServerAPI._privateConstructor();
    return _instance!;
  }

  ServerAPI._privateConstructor();
}
