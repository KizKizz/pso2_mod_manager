import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

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
  String itemIconWebPath = '';
  bool itemIconReplaced = false;

  Cml fromItemData(ItemData data) {
    id = data.getItemID();
    aId = data.getItemAdjustedID();
    itemNameEN = data.getENName();
    itemNameJP = data.getJPName();
    cloudItemIconPath = data.iconImagePath;
    itemIconWebPath = p.withoutExtension(oItemData
        .firstWhere(
          (e) => e.path.contains(data.getIconIceName()),
          orElse: () => OfficialIceFile.empty(),
        )
        .path);
    return this;
  }

  String getName() {
    return itemNameLanguage == ItemNameLanguage.jp ? itemNameJP : itemNameEN;
  }

  factory Cml.fromJson(Map<String, dynamic> json) => _$CmlFromJson(json);
  Map<String, dynamic> toJson() => _$CmlToJson(this);
}
