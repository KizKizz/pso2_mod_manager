import 'package:json_annotation/json_annotation.dart';

part 'aqm_item_class.g.dart';

@JsonSerializable()
class AqmItem {
  AqmItem(this.category, this.id, this.adjustedId, this.iconImagePath, this.itemNameEN, this.itemNameJP, this.hqIcePath, this.lqIcePath, this.isApplied);
  String category;
  String id;
  String adjustedId;
  String iconImagePath;
  String itemNameEN;
  String itemNameJP;
  String hqIcePath;
  String lqIcePath;
  bool isApplied;

  factory AqmItem.fromJson(Map<String, dynamic> json) => _$AqmItemFromJson(json);
  Map<String, dynamic> toJson() => _$AqmItemToJson(this);
}
