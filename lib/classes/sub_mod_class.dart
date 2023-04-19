import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sub_mod_class.g.dart';

@JsonSerializable()
class SubMod {
  SubMod(this.name, this.category, this.itemName, this.applyStatus, this.applyDate, this.appliedModFiles, this.isNew, this.isFavorite, this.previewImages, this.previewVideos, this.modFiles);
  String name;
  String category;
  String itemName;
  bool applyStatus;
  DateTime applyDate;
  List<ModFile> appliedModFiles;
  bool isNew;
  bool isFavorite;
  List<Uri> previewImages;
  List<Uri> previewVideos;
  List<ModFile> modFiles;

  factory SubMod.fromJson(Map<String, dynamic> json) => _$SubModFromJson(json);
  Map<String, dynamic> toJson() => _$SubModToJson(this);
}
