import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_mod_class.g.dart';

@JsonSerializable()
class SubMod {
  SubMod(this.name, this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate, this.isNew, this.isFavorite, this.previewImages, this.previewVideos, this.appliedModFiles,
      this.modFiles);
  String name;
  String modName;
  String itemName;
  String category;
  Uri location;
  bool applyStatus;
  DateTime applyDate;
  bool isNew;
  bool isFavorite;
  List<Uri> previewImages;
  List<Uri> previewVideos;
  List<ModFile> appliedModFiles;
  List<ModFile> modFiles;

  factory SubMod.fromJson(Map<String, dynamic> json) => _$SubModFromJson(json);
  Map<String, dynamic> toJson() => _$SubModToJson(this);
}
