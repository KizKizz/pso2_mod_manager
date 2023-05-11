import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_class.g.dart';

@JsonSerializable()
class Item {
  Item(this.itemName, this.icon, this.category, this.location, this.isNew, this.applyStatus, this.applyDate, this.isFavorite, this.mods);
  String itemName;
  String icon;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  bool isFavorite;
  bool isNew;
  List<Mod> mods;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}