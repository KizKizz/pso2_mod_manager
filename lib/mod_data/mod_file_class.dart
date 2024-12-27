import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';
import 'package:path/path.dart' as p;

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

  List<Widget> getPreviewWidgets() {
    List<Widget> widgets = [];
    if (previewImages!.isNotEmpty) {
      widgets.addAll(previewImages!.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(itemName).last)));
    }
    if (previewVideos!.isNotEmpty) {
      widgets.addAll(previewVideos!.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(itemName).last)));
    }
    return widgets;
  }

  factory ModFile.fromJson(Map<String, dynamic> json) => _$ModFileFromJson(json);
  Map<String, dynamic> toJson() => _$ModFileToJson(this);
}
