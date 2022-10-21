// ignore_for_file: unused_import
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:pso2_mod_manager/main.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import 'home_page.dart';

class ModCategory {
  ModCategory(
    this.categoryName,
    this.categoryPath,
    this.itemNames,
    this.imageIcons,
    this.numOfItems,
    this.numOfMods,
    this.numOfApplied,
    this.allModFiles,
  );

  String categoryName;
  String categoryPath;
  List<String> itemNames;
  List<List<File>> imageIcons;
  int numOfItems;
  List<int> numOfMods;
  List<int> numOfApplied;
  List<ModFile> allModFiles;
}

class ModFile extends ModCategory {
  ModFile(
      this.appliedDate,
      this.modPath, //mod folder path
      this.modName, //mod folder name,
      this.icePath,
      this.iceName,
      this.iceParent,
      this.originalIcePath,
      this.backupIcePath,
      this.images,
      this.isApplied,
      this.isSFW,
      this.isNew,
      this.isFav,
      this.previewVids)
      : super('', '', [], [], 0, [], [], []);

  String appliedDate;
  String modPath;
  String modName;
  String icePath;
  String iceName;
  String iceParent;
  String originalIcePath;
  String backupIcePath;
  Future? images;
  bool isApplied;
  bool isSFW;
  bool isNew;
  bool isFav;
  List<File>? previewVids;

  fromJson(Map<String, dynamic> json) {
    categoryName = json['categoryName'];
    categoryPath = json['categoryPath'];
    appliedDate = json['appliedDate'];
    modPath = json['modPath'];
    modName = json['modName'];
    icePath = json['icePath'];
    iceName = json['iceName'];
    iceParent = json['iceParent'];
    originalIcePath = json['originalIcePath'];
    backupIcePath = json['backupIcePath'];
    isApplied = json['isApplied'];
    isSFW = json['isSFW'];
    isNew = json['isNew'];
    isFav = json['isFav'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryPath'] = categoryPath;
    data['categoryName'] = categoryName;
    data['appliedDate'] = appliedDate;
    data['modPath'] = modPath;
    data['modName'] = modName;
    data['iceName'] = iceName;
    data['icePath'] = icePath;
    data['iceParent'] = iceParent;
    data['originalIcePath'] = originalIcePath;
    data['backupIcePath'] = backupIcePath;
    data['isApplied'] = isApplied;
    data['isSFW'] = isSFW;
    data['isNew'] = isNew;
    data['isFav'] = isFav;

    return data;
  }
}

class ModSet {
  ModSet(this.setName, this.numOfItems, this.modFiles, this.isApplied, this.filesInSetList);

  String setName;
  int numOfItems;
  String modFiles;
  bool isApplied;
  List<ModFile> filesInSetList;

  List<ModFile> getModFiles(String filesString) {
    List<ModFile> returnList = [];
    if (filesString.isNotEmpty) {
      List<String> tempList = filesString.split('|');
      for (var fileLoc in tempList) {
        if (allModFiles.indexWhere((element) => element.icePath == fileLoc) != -1) {
          returnList.add(allModFiles.firstWhere((element) => element.icePath == fileLoc));
        } else {
          removeNotFoundFiles(fileLoc);
        }
      }

      List<String> modNamesList = [];
      for (var modFile in returnList) {
        modNamesList.add(modFile.modName);
      }
      modNamesList = modNamesList.toSet().toList();
      numOfItems = modNamesList.length;
    }

    return returnList;
  }

  void removeNotFoundFiles(String removeItem) {
    List<String> tempList = modFiles.split('|');
    tempList.remove(removeItem);
    modFiles = tempList.join('|');
  }

  fromJson(Map<String, dynamic> json) {
    setName = json['setName'];
    numOfItems = json['numOfItems'];
    modFiles = json['modFiles'];
    isApplied = json['isApplied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['setName'] = setName;
    data['numOfItems'] = numOfItems;
    data['modFiles'] = modFiles;
    data['isApplied'] = isApplied;

    return data;
  }
}
