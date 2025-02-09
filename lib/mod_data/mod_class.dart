import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';

part 'mod_class.g.dart';

@JsonSerializable()
class Mod with ChangeNotifier {
  Mod(this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate, this.position, this.isNew, this.isFavorite, this.isSet, this.setNames, this.previewImages,
      this.previewVideos, this.appliedSubMods, this.submods);
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
  List<String> setNames;
  List<String> previewImages;
  List<String> previewVideos;
  List<SubMod> appliedSubMods;
  List<SubMod> submods;

  void setApplyState(bool state) {
    applyStatus = state;
    notifyListeners();
  }

  // helpers
  List<String> getDistinctNames() {
    List<String> names = [];
    if (!names.contains(modName)) names.add(modName);
    for (var submod in submods) {
      if (!names.contains(submod.submodName)) names.add(submod.submodName);
      names.addAll(submod.getModFileNames().where((e) => !names.contains(e)));
    }
    return names;
  }

  List<String> getModFileNames() {
    List<String> names = [];
    for (var submod in submods) {
      names.addAll(submod.getModFileNames());
    }
    return names;
  }

  List<String> getDistinctModFilePaths() {
    List<String> paths = [];
    for (var submod in submods) {
      paths.addAll(submod.getDistinctModFilePaths());
    }
    return paths;
  }

  bool getSubmodsAppliedState() {
    if (submods.where((element) => element.getModFilesAppliedState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool getSubmodsIsNewState() {
    if (submods.where((element) => element.getModFilesIsNewState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void setLatestCreationDate() {
    if (creationDate == DateTime(0)) creationDate = Directory(location).statSync().changed;
    for (var sub in submods) {
      if (sub.creationDate != DateTime(0) && sub.creationDate!.isAfter(creationDate!)) creationDate = sub.creationDate;
    }
  }

  int getNumOfAppliedSubmods() {
    return submods.where((e) => e.applyStatus).length;
  }

  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}
