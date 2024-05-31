import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'item_class.g.dart';

@JsonSerializable()
class Item {
  Item(this.itemName, this.variantNames, this.icons, this.iconPath, this.overlayedIconPath, this.backupIconPath, this.isOverlayedIconApplied, this.category, this.location, this.applyStatus, this.applyDate, this.position, this.isFavorite, this.isSet, this.isNew, this.setNames, this.mods);
  String itemName;
  List<String> variantNames;
  List<String> icons;
  String? iconPath = '';
  String? overlayedIconPath = '';
  String? backupIconPath = '';
  bool? isOverlayedIconApplied = false;
  String category;
  String location;
  bool applyStatus;
  DateTime applyDate;
  int position;
  bool isFavorite;
  bool isSet;
  bool isNew;
  List<String> setNames;
  List<Mod> mods;

  List<String> getDistinctModFilePaths() {
    List<String> paths = [];
    for (var mod in mods) {
      paths.addAll(mod.getDistinctModFilePaths());
    }
    return paths;
  }

  bool getModsAppliedState() {
    if (mods.where((element) => element.getSubmodsAppliedState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  bool getModsIsNewState() {
    if (mods.where((element) => element.getSubmodsIsNewState()).isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}
