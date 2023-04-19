
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';

part 'mod_class.g.dart';

@JsonSerializable()
class Mod {
  Mod(this.name, this.category, this.itemName, this.applyStatus, this.applyDate, this.appliedSubMods, this.isNew, this.isFavorite,this.previewImages, this.previewVideos, this.subMods);
  String name;
  String category;
  String itemName;
  bool applyStatus;
  DateTime applyDate;
  List<SubMod> appliedSubMods;
  bool isNew;
  bool isFavorite;
  List<Uri> previewImages;
  List<Uri> previewVideos;
  List<SubMod> subMods;
  
  
  factory Mod.fromJson(Map<String, dynamic> json) => _$ModFromJson(json);
  Map<String, dynamic> toJson() => _$ModToJson(this);
}


