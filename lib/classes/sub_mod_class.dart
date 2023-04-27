import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_mod_class.g.dart';

@JsonSerializable()
class SubMod {
  SubMod(this.submodName, this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate, this.isNew, this.isFavorite, this.previewImages, this.previewVideos, this.appliedModFiles,
      this.modFiles);
  String submodName;
  String modName;
  String itemName;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  bool isNew;
  bool isFavorite;
  List<String> previewImages;
  List<String> previewVideos;
  List<ModFile> appliedModFiles;
  List<ModFile> modFiles;

  factory SubMod.fromJson(Map<String, dynamic> json) => _$SubModFromJson(json);
  Map<String, dynamic> toJson() => _$SubModToJson(this);
}
