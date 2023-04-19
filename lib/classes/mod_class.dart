
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mod_class.g.dart';

@JsonSerializable()
class Mod {
  Mod(this.name, this.category, this.itemName, this.applyStatus, this.applyDate, this.appliedModFiles, this.isNew, this.isFavorite, this.modFiles, this.previewImages, this.previewVideos);
  String name;
  String category;
  String itemName;
  bool applyStatus;
  DateTime applyDate;
  List<ModFile> appliedModFiles;
  bool isNew;
  bool isFavorite;
  List<ModFile> modFiles;
  List<String> previewImages;
  List<String> previewVideos;
  
  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}


