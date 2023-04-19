import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_class.g.dart';

@JsonSerializable()
class Item {
  Item(this.name, this.icon, this.category, this.location, this.isNew, this.isFavorite, this.mods);
  String name;
  String icon;
  String category;
  String location;
  bool isFavorite;
  bool isNew;
  List<Mod> mods;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
