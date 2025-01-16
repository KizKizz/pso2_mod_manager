import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

part 'aqm_injected_item_class.g.dart';

@JsonSerializable()
class AqmInjectedItem {
  AqmInjectedItem(this.category, this.id, this.adjustedId, this.iconImagePath, this.itemNameEN, this.itemNameJP, this.hqIcePath, this.lqIcePath, this.iconIcePath, this.isApplied, this.isIconReplaced,
      this.isAqmReplaced, this.isBoundingRemoved);
  String category;
  String id;
  String adjustedId;
  String iconImagePath;
  String itemNameEN;
  String itemNameJP;
  String hqIcePath;
  String lqIcePath;
  String iconIcePath;
  bool isApplied;
  bool isIconReplaced;
  bool? isAqmReplaced;
  bool? isBoundingRemoved;

  String getName() {
    if (itemNameLanguage == ItemNameLanguage.jp) {
      return itemNameJP;
    } else {
      return itemNameEN;
    }
  }

  List<String> getDetailsForAqmInject() {
    return ['Id: $id', 'Adjusted Id: $adjustedId', 'Normal Quality: ${p.basename(lqIcePath)}', 'High Quality: ${p.basename(hqIcePath)}'];
  }

  factory AqmInjectedItem.fromJson(Map<String, dynamic> json) => _$AqmInjectedItemFromJson(json);
  Map<String, dynamic> toJson() => _$AqmInjectedItemToJson(this);
}
