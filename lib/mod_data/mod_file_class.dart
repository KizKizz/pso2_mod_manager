import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:crypto/crypto.dart';

part 'mod_file_class.g.dart';

@JsonSerializable()
class ModFile with ChangeNotifier {
  ModFile(this.modFileName, this.submodName, this.modName, this.itemName, this.category, this.md5, this.ogMd5s, this.location, this.applyStatus, this.applyDate, this.position, this.isFavorite,
      this.isSet, this.isNew, this.setNames, this.applyLocations, this.ogLocations, this.bkLocations, this.previewImages, this.previewVideos);
  String modFileName;
  String submodName;
  String modName;
  String itemName;
  String category;
  String md5;
  List<String> ogMd5s;
  String location;
  bool applyStatus;
  DateTime applyDate;
  int position;
  bool isFavorite;
  bool isSet;
  bool isNew;
  List<String> setNames;
  List<String>? applyLocations = [];
  List<String> ogLocations;
  List<String> bkLocations;
  List<String>? previewImages = [];
  List<String>? previewVideos = [];

  void setApplyState(bool state) {
    applyStatus = state;
    notifyListeners();
  }

  factory ModFile.fromJson(Map<String, dynamic> json) => _$ModFileFromJson(json);
  Map<String, dynamic> toJson() => _$ModFileToJson(this);
}

extension GetMd5Hash on ModFile {
  Future<String> getMd5Hash() async {
    final file = File(location);
    if (!file.existsSync()) return '';
    try {
      final stream = file.openRead();
      final hashsum = await md5.bind(stream).first;

      return hashsum.toString();
    } catch (exception) {
      return '';
    }
  }
}

extension GetMd5HashFile on File {
  Future<String> getMd5Hash() async {
    if (!existsSync()) return '';
    try {
      final stream = openRead();
      final hashsum = await md5.bind(stream).first;

      return hashsum.toString();
    } catch (exception) {
      return '';
    }
  }
}
