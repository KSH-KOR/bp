import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageModel{
  final Reference ref;
  final String downloadLink;
  final FullMetadata? meta;

  FirebaseStorageModel( {required this.ref, required this.downloadLink, required this.meta,});
}