import 'package:json_annotation/json_annotation.dart';

part 'quick_apply_item_class.g.dart';

@JsonSerializable()
class QuickApplyItem {
  QuickApplyItem(this.category, this.id, this.adjustedId, this.iconImagePath, this.itemNameEN, this.itemNameJP, this.isApplied);
  String category;
  String id;
  String adjustedId;
  String iconImagePath;
  String itemNameEN;
  String itemNameJP;
  bool isApplied;

  factory QuickApplyItem.fromJson(Map<String, dynamic> json) => _$QuickApplyItemFromJson(json);
  Map<String, dynamic> toJson() => _$QuickApplyItemToJson(this);
}
