import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';

part 'mod_class.g.dart';

@JsonSerializable()
class Mod {
  Mod(this.name, this.itemName, this.category, this.location, this.applyStatus, this.applyDate,  this.isNew, this.isFavorite, this.previewImages, this.previewVideos, this.appliedSubMods, this.subMods);
  String name;
  String itemName;
  String category;
  Uri location;
  bool applyStatus;
  DateTime applyDate;
  bool isNew;
  bool isFavorite;
  List<Uri> previewImages;
  List<Uri> previewVideos;
  List<SubMod> appliedSubMods;
  List<SubMod> subMods;

  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}
