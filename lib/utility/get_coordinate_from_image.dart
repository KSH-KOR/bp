import 'dart:io';

import 'package:exif/exif.dart';
import 'package:intl/intl.dart';

import '../model/image_info.dart';

Future<PickedImageInfo?> getCoordinateFromImage(String path) async {
  final Map<String, dynamic> res = {"name": path.split("/").last};
  //extract image tags with readExifFromBytes by exifts
  Map<String, IfdTag> imgTags =
      await readExifFromBytes(File(path).readAsBytesSync());

  if (imgTags.containsKey("Image DateTime")) {
    String dateString = imgTags["Image DateTime"]
        .toString();
    DateFormat format = DateFormat('yyyy:MM:dd hh:mm:ss');
    // DateTime 객체로 파싱합니다.
    DateTime dateTime = format.parse(dateString);
    res["datetime"] = dateTime;
  }

  //check if a geo tag is in imgTags
  if (imgTags.containsKey('GPS GPSLatitude') &&
      imgTags.containsKey('GPS GPSLongitude')) {
    //get coordinate from the geo tag
    final latitudeValue = imgTags['GPS GPSLatitude']!
        .values
        .toList()
        .map<double>(
            (item) => (item.numerator.toDouble() / item.denominator.toDouble()))
        .toList();

    final longitudeValue = imgTags['GPS GPSLongitude']!
        .values
        .toList()
        .map<double>(
            (item) => (item.numerator.toDouble() / item.denominator.toDouble()))
        .toList();

    double latitude =
        latitudeValue[0] + (latitudeValue[1] / 60) + (latitudeValue[2] / 3600);

    double longitude = longitudeValue[0] +
        (longitudeValue[1] / 60) +
        (longitudeValue[2] / 3600);

    res["latitude"] = latitude;
    res["longitude"] = longitude;
  }

  return res.isEmpty ? null : PickedImageInfo.fromJson(res);
}
