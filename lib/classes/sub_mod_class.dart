import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_mod_class.g.dart';

@JsonSerializable()
class SubMod {
  SubMod(this.submodName, this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate, this.position, this.isNew, this.isFavorite, this.isSet, this.setNames,
      this.previewImages, this.previewVideos, this.appliedModFiles, this.modFiles);
  String submodName;
  String modName;
  String itemName;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  int position;
  bool isNew;
  bool isFavorite;
  bool isSet;
  List<String> setNames;
  List<String> previewImages;
  List<String> previewVideos;
  List<ModFile> appliedModFiles;
  List<ModFile> modFiles;

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

  factory SubMod.fromJson(Map<String, dynamic> json) => _$SubModFromJson(json);
  Map<String, dynamic> toJson() => _$SubModToJson(this);
}
