import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';

part 'mod_class.g.dart';

@JsonSerializable()
class Mod {
  Mod(this.modName, this.itemName, this.category, this.location, this.applyStatus, this.applyDate,  this.isNew, this.isFavorite, this.previewImages, this.previewVideos, this.appliedSubMods, this.submods);
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
  List<SubMod> appliedSubMods;
  List<SubMod> submods;

  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}
