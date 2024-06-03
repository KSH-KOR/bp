import 'dart:io';


class AddPlaceRepo{
  String? placeName;
  String? placeAddress;
  String? review;
  int? rating;
  File? image;
  String? description;
  String? category;
  String? buildingName;
  String? postcode;

  void setValueByIndex(int index, dynamic value){
    if(index == 0){
      placeName = value;
    } else if(index == 1){
      category = value;
    } else if(index == 2){
      placeAddress = value;
    } else if(index == 3){
      review = value;
    } else if(index == 4){
      description = value;
    }
  }
  String? getValueByIndex(int index){
    if(index == 0){
      return placeName;
    } else if(index == 1){
      return category;
    } else if(index == 2){
      return placeAddress;
    } else if(index == 3){
      return review;
    } else if(index == 4){
      return description;
    }
    return null;
  } 
}