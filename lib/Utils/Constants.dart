import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_gallery/photo_gallery.dart';

const kThemeColor = Color(0xff121212);
const kIndicatorColor = Color(0xff1584F9);
const kTextColor = Color(0xff707070);

getSize(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  var size = getFile.lengthSync();

  double sizeKb = size / 1024;
  double sizeMb = sizeKb / 1024;
  if (sizeKb > 1000) {
    return '${sizeMb.toStringAsFixed(2)} MB';
  } else {
    return '${sizeKb.toStringAsFixed(2)} KB';
  }
}

getPath(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  return getFile.path;
}

getFileName(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  return getFile.path.split('/').last;
}

getLastAccessed(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  return getFile.lastAccessedSync();
}

getLastModified(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  return getFile.lastModifiedSync();
}

deleteImage(String mediumId) async {
  var getFile = await PhotoGallery.getFile(mediumId: mediumId, mediumType: MediumType.image);
  return getFile.deleteSync();
}

String formatDate(DateTime date) => new DateFormat("d MMMM yyyy").format(date);
