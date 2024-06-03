import 'dart:developer';

class FirestoreException implements Exception{
  final String logMsg;
  final String errMsg;

  FirestoreException({required this.logMsg, required this.errMsg}){
    log(logMsg);
  }

  @override
  String toString() {
    return errMsg;
  }
}
class UserNotFound implements Exception{
  final String errMsg;

  UserNotFound({required this.errMsg});
  @override
  String toString() {
    return errMsg;
  }
}