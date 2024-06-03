import 'dart:developer';

import 'package:flutter/material.dart';

class FormException implements Exception {
  final String msg;

  FormException({required this.msg});

  @override
  String toString() {
    return msg;
  }
}

class FormDataModel {
  final String id;
  final String displayTitle;
  final dynamic value;

  FormDataModel({
    required this.id,
    required this.displayTitle,
    required this.value,
  });
  
  FormDataModel copyWith({required value}) {
    return FormDataModel(displayTitle: displayTitle, value: value, id: id);
  }
}

class FormProvider with ChangeNotifier {
  final List<FormDataModel> repo = [];

  FormDataModel getModelById(String id) {
    final found = repo.where((element) => element.id == id);
    if (found.isEmpty) {
      log("key not found: [$id]");
      throw Exception("key not found: [$id]");
    }
    return found.first;
  }
  bool removeModelById(String id, {bool shouldNotify = true}){
    final originalLen = repo.length;
    repo.removeWhere((element) => element.id == id);
    final didDeleted = originalLen != repo.length;
    if(didDeleted && shouldNotify) notifyListeners();
    return didDeleted;
  }

  void setFormData(FormDataModel formDataModel, {bool shouldNotify = true}){
    try{
      final existModel = getModelById(formDataModel.id);
      if(removeModelById(formDataModel.id)){
        repo.add(existModel.copyWith(value: formDataModel.value));
      }
    } catch(e){
      repo.add(formDataModel);
    }
    
    if(shouldNotify) notifyListeners();
  }

  void initFormData(List<FormDataModel> repo) {
    repo = repo;
  }

  void reset() {
    repo.clear();
  }
}
