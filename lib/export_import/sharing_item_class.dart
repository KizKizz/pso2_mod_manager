import 'package:json_annotation/json_annotation.dart';

part 'sharing_item_class.g.dart';

@JsonSerializable()
class SharingItem {
  String itemName = '';
  String itemDirPath = '';
  String modName = '';
  String modDirPath = '';
  String submodName = '';
  String submodDirPath = '';

  factory SharingItem.fromJson(Map<String, dynamic> json) => _$SharingItemFromJson(json);
  Map<String, dynamic> toJson() => _$SharingItemToJson(this);
}
