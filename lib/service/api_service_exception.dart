
import '../constant/message/error_msg.dart';

class ServerException implements Exception{
  final ServerExceptionModel model;

  ServerException({required this.model});

  @override
  String toString() {
    return super.toString() + model.toString();
  }
} 

class ServerExceptionModel{
  final int statusCode;
  final String detail;

  static String? getDetailMsg(int statusCode){
    switch(statusCode){
      case 402:
        return ErrorMsg.insufficientCoinBalance;
      case 403:
        return ErrorMsg.forbidden;
    }
    return null;
  }

  factory ServerExceptionModel.fromJson(Map<String, dynamic> json) {

    return ServerExceptionModel(
      statusCode: json["statusCode"],
      detail: getDetailMsg(json["statusCode"]) ?? json["detail"].toString(),
    );
  }

  @override
  String toString(){
    return "$statusCode\n$detail";
  }

  ServerExceptionModel({required this.statusCode, required this.detail});
}