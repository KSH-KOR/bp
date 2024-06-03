class AlreadyExistException implements Exception{
  final String? msg;

  AlreadyExistException(this.msg);

  @override
  String toString() {
    return msg ?? super.toString();
  }
}