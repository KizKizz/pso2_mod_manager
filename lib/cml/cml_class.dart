import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

part 'cml_class.g.dart';

@JsonSerializable()
class Cml {
  Cml();

  String id = '';
  String aId = '';
  String itemNameEN = '';
  String itemNameJP = '';
  bool isReplaced = false;
  String replacedCmlFileName = '';
  String cloudItemIconPath = '';
  String itemIconIceName = '';

  Cml fromItemData(ItemData data) {
    id = data.getItemID();
    aId = data.getItemAdjustedID();
    itemNameEN = data.getENName();
    itemNameJP = data.getJPName();
    cloudItemIconPath = data.iconImagePath;
    itemIconIceName = data.getIconIceName();
    return this;
  }

  String getName() {
    return itemNameLanguage == ItemNameLanguage.jp ? itemNameJP : itemNameEN;
  }

  factory Cml.fromJson(Map<String, dynamic> json) => _$CmlFromJson(json);
  Map<String, dynamic> toJson() => _$CmlToJson(this);
}
