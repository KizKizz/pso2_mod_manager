import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';

part 'item_class.g.dart';

@JsonSerializable()
class Item with ChangeNotifier {
  Item(this.itemName, this.variantNames, this.icons, this.iconPath, this.overlayedIconPath, this.backupIconPath, this.isOverlayedIconApplied, this.category, this.location, this.applyStatus,
      this.applyDate, this.position, this.isFavorite, this.isSet, this.isNew, this.setNames, this.mods);
  String itemName;
  List<String> variantNames;
  List<String> icons;
  String? iconPath = '';
  String? overlayedIconPath = '';
  String? backupIconPath = '';
  bool? isOverlayedIconApplied = false;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  DateTime? creationDate = DateTime(0);
  int position;
  bool isFavorite;
  bool isSet;
  bool isNew;
  List<String> setNames;
  List<Mod> mods;

  void removeMod(Mod mod) {
    mods.remove(mod);
    notifyListeners();
  }

  void setApplyState(bool state) {
    applyStatus = state;
    notifyListeners();
  }

  // helpers
  List<String> getDistinctNames() {
    List<String> names = [];
    if (!names.contains(itemName)) names.add(itemName);
    for (var mod in mods) {
      names.addAll(mod.getDistinctNames().where((e) => !names.contains(e)));
    }
    return names;
  }

  int getNumOfAppliedMods() {
    return mods.where((e) => e.applyStatus).length;
  }

  List<String> getDistinctModFilePaths() {
    List<String> paths = [];
    for (var mod in mods) {
      paths.addAll(mod.getDistinctModFilePaths());
    }
    return paths;
  }

  bool getModsAppliedState() {
    if (mods.where((element) => element.getSubmodsAppliedState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool getModsIsNewState() {
    if (mods.where((element) => element.getSubmodsIsNewState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  void setLatestCreationDate() {
    if (creationDate == DateTime(0)) creationDate = Directory(location).statSync().changed;
    for (var mod in mods) {
      if (mod.creationDate != DateTime(0) && mod.creationDate!.isAfter(creationDate!)) creationDate = mod.creationDate;
    }
  }

  List<SubMod> getSubmods() {
    List<SubMod> submods = [];
    for (var mod in mods) {
      submods.addAll(mod.submods);
    }
    return submods;
  }

  (Mod?, SubMod?) getActiveInSet(String setName) {
    if (!setNames.contains(setName)) return (null, null);
    for (var mod in mods.where((e) => e.isSet && e.setNames.contains(setName))) {
      int aIndex = mod.submods.indexWhere(
        (e) => e.isSet && e.setNames.contains(setName) && e.activeInSets!.contains(setName),
      );
      if (aIndex != -1) {
        return (mod, mod.submods[aIndex]);
      }
    }
    Mod mod = mods.firstWhere((e) => e.isSet && e.setNames.contains(setName));
    SubMod submod = mod.submods.firstWhere((e) => e.isSet && e.setNames.contains(setName));
    submod.activeInSets!.add(setName);
    saveMasterModListToJson();
    saveMasterModSetListToJson();
    return (mod, submod);
  }

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
