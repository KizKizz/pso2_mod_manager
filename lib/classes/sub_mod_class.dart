import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_mod_class.g.dart';

@JsonSerializable()
class SubMod with ChangeNotifier{
  SubMod(this.submodName, this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate, this.position, this.isNew, this.isFavorite, this.isSet, this.hasCmx,
      this.cmxApplied, this.cmxStartPos, this.cmxEndPos, this.cmxFile, this.setNames, this.applyLocations, this.previewImages, this.previewVideos, this.appliedModFiles, this.modFiles);
  String submodName;
  String modName;
  String itemName;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  DateTime? creationDate = DateTime(0);
  int position;
  bool isNew;
  bool isFavorite;
  bool isSet;
  bool? hasCmx = false;
  bool? cmxApplied = false;
  int? cmxStartPos = -1;
  int? cmxEndPos = -1;
  String? cmxFile = '';
  List<String> setNames;
  List<String>? applyLocations = [];
  List<String> previewImages;
  List<String> previewVideos;
  List<ModFile> appliedModFiles;
  List<ModFile> modFiles;

  void setApplyState(bool state) {
    applyStatus = state;
    notifyListeners();
  }

  //helpers

  List<String> getModFileNames() {
    List<String> names = [];
    for (var modFile in modFiles) {
      if (!names.contains(modFile.modFileName)) {
        names.add(modFile.modFileName);
      }
    }
    return names;
  }

  List<String> getDistinctModFilePaths() {
    List<String> paths = [];
    for (var modFile in modFiles) {
      if (!paths.contains(modFile.location)) {
        paths.add(modFile.location);
      }
    }
    return paths;
  }

  bool getModFilesAppliedState() {
    final appliedModFiles = modFiles.where((element) => element.applyStatus);
    if (appliedModFiles.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool getModFilesIsNewState() {
    if (modFiles.where((element) => element.isNew).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void setLatestCreationDate() {
    List<String> allModFilePaths = getDistinctModFilePaths();
    creationDate = Directory(location).statSync().changed;
    if (allModFilePaths.isNotEmpty) {
      List<DateTime> latestCreationDates = allModFilePaths.map((e) => File(e).statSync().changed).where((element) => element.isAfter(creationDate!)).toList();
      for (var latestDate in latestCreationDates) {
        if (latestDate.isAfter(creationDate!)) creationDate = latestDate;
      }
    }
  }

  factory SubMod.fromJson(Map<String, dynamic> json) => _$SubModFromJson(json);
  Map<String, dynamic> toJson() => _$SubModToJson(this);
}
