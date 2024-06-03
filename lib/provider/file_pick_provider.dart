
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum CustomFileType{
  image, audio, video, document, undefined

}

CustomFileType stringToCustomFileType(String? type){
  if(type == null) return CustomFileType.undefined;
  final lowercase = type.toLowerCase();
  for(final compare in CustomFileType.values){
    if(compare.name == lowercase){
      return compare;
    }
  }
  return CustomFileType.undefined;
}

class PickedFile{
  final String id;
  final CustomFileType type;
  final String path;
  final String name;
  final int size;

  PickedFile({required this.name, required this.type, required this.path, required this.size}) : id = const Uuid().v4();

  factory PickedFile.fromPlatformFile(PlatformFile platformFile, CustomFileType type){
    return PickedFile(path: platformFile.path!, type: type, size: platformFile.size,name: platformFile.name);
  }
}

class FilePickProvider with ChangeNotifier {
  List<PickedFile> pickedFiles = [];
  bool _isPicking = false;

  Iterable<PickedFile> getPickedFilesByType(CustomFileType type) => pickedFiles.where((element) => element.type == type,);
  Iterable<PickedFile> get imageFiles => pickedFiles.where((element) => element.type == CustomFileType.image,);
  Iterable<PickedFile> get audioFiles => pickedFiles.where((element) => element.type == CustomFileType.audio,);

  Future<void> pickImage({bool shouldNotify = true}) async {
    await pickFile(type: CustomFileType.image, shouldNotify: shouldNotify);
  }
  Future<void> pickAudio({bool shouldNotify = true}) async {
    await pickFile(type: CustomFileType.audio, shouldNotify: shouldNotify);
  }
  Future<void> pickDocumentation({bool shouldNotify = true}) async {
    await pickFile(type: CustomFileType.document, shouldNotify: shouldNotify);
  }

  Future<void> pickFile({required CustomFileType type, bool shouldNotify = true}) async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: getAllowedExtensions(type),
      );
      if(result == null) throw Exception("pickFile: result == null");

      final target = result.files.where((element) => element.path!=null).map((e) => PickedFile.fromPlatformFile(e, type));
      
      addAll(target, shouldNotify: shouldNotify);
    } catch (e) {
      log(e.toString());
    } finally {
      _isPicking = false;
    }
  }

  List<String> getAllowedExtensions(CustomFileType type){
    switch(type){
      case CustomFileType.image:
        return ['jpg', 'jpeg', 'png'];
      case CustomFileType.audio:
        return ["mp3", "wav"];
      case CustomFileType.video:
        return ["mp4"];
      case CustomFileType.document:
        return ["xls", "xlsx", "txt", "doc", "docx", "pdf"];
      case CustomFileType.undefined:
        return [];
    }
  }

  void add(PickedFile file, {bool shouldNotify = true}){
    pickedFiles.add(file);
    if(shouldNotify) notifyListeners();
  }

  void addAll(Iterable<PickedFile> files, {bool shouldNotify = true}){
    pickedFiles.addAll(files);
    if(shouldNotify) notifyListeners();
  }

  void removeById(String id, {bool shouldNotify = true}){
    int oldLen = pickedFiles.length;
    pickedFiles.removeWhere((element) => element.id == id);
    final bool didDelete = oldLen != pickedFiles.length;
    if(didDelete && shouldNotify) notifyListeners();
  }

  void reset({bool shouldNotify = true}){
    pickedFiles.clear();
    if(shouldNotify) notifyListeners();
  }
}
