import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';

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
  List<Widget> getPreviewWidgets() {
    List<Widget> widgets = [];
    if (previewImages.isNotEmpty) {
      widgets.addAll(previewImages.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(itemName).last)));
    }
    if (previewVideos.isNotEmpty) {
      widgets.addAll(previewVideos.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(itemName).last)));
    }
    return widgets;
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

  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}
