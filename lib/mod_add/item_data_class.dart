import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
part 'item_data_class.g.dart';

@JsonSerializable()
class ItemData {
  ItemData(this.csvFileName, this.csvFilePath, this.itemType, this.itemCategories, this.category, this.subCategory, this.categoryIndex, this.iconImagePath, this.infos);

  String csvFileName;
  String csvFilePath;
  String itemType;
  List<String> itemCategories;
  String category;
  String subCategory;
  int categoryIndex;
  String iconImagePath;
  Map<String, String> infos = {};

  String getJPNameOriginal() {
    return infos.entries.firstWhere((element) => element.key.contains('JP Name') || element.key.contains('Japanese Name')).value.trim();
  }

  String getENNameOriginal() {
    return infos.entries.firstWhere((element) => element.key.contains('EN Name') || element.key.contains('English Name')).value.trim();
  }

  String getJPName() {
    return infos.entries.firstWhere((element) => element.key.contains('JP Name') || element.key.contains('Japanese Name')).value.replaceAll(RegExp(charToReplace), '_').trim();
  }

  String getENName() {
    return infos.entries.firstWhere((element) => element.key.contains('EN Name') || element.key.contains('English Name')).value.replaceAll(RegExp(charToReplace), '_').trim();
  }

  String getName() {
    if (itemNameLanguage == ItemNameLanguage.jp) {
      return infos.entries.firstWhere((element) => element.key.contains('JP Name') || element.key.contains('Japanese Name')).value;
    } else {
      return infos.entries.firstWhere((element) => element.key.contains('EN Name') || element.key.contains('English Name')).value;
    }
  }

  String getItemID() {
    return infos.entries.firstWhere((e) => e.key.toLowerCase() == 'id', orElse: () => const MapEntry('', '')).value;
  }

  List<String> getItemIDs() {
    List<String> ids = [];
    ids.add(infos.entries.firstWhere((e) => e.key.toLowerCase() == 'id', orElse: () => const MapEntry('', '')).value);
    ids.add(infos.entries.firstWhere((e) => e.key == 'Adjusted Id', orElse: () => const MapEntry('', '')).value);
    return ids;
  }

  String getHQIceName() {
    return infos.entries.firstWhere((e) => e.key == 'High Quality', orElse: () => const MapEntry('', '')).value;
  }

  String getLQIceName() {
    return infos.entries.firstWhere((e) => e.key == 'Normal Quality', orElse: () => const MapEntry('', '')).value;
  }

  // String getIconImagePath() {
  //   return infos.entries.firstWhere((element) => element.key.contains('iconImagePath')).value;
  // }

  List<String> getInfos() {
    List<String> returnInfos = [];
    returnInfos.add(category);
    if (category == defaultCategoryDirs[14]) returnInfos.add(subCategory);
    returnInfos.addAll(infos.values);
    returnInfos.add(iconImagePath);

    return returnInfos;
  }

  List<String> getInfoForWeapons() {
    List<String> returnInfos = [];
    returnInfos.add(category);
    returnInfos.add(subCategory);
    returnInfos.add(itemType);
    returnInfos.add(iconImagePath);
    returnInfos.addAll(infos.values);
    return returnInfos;
  }

  String getItemNameWithoutAffix() {
    List<String> toRemove = ['[Ba]', '[Se]', '[Ou]', '[In]', '[Fu]'];
    String name = getName();
    for (var affix in toRemove) {
      name = name.replaceFirst(affix, '');
    }
    return name.trim();
  }

  // String getBaseItemJPName() {
  //   List<String> toRemove = ['[Ba]', '[Se]', '[Ou]', '[In]', '[Fu]'];
  //   String name = getJPName();
  //   // name = name.split('/').first;
  //   for (var affix in toRemove) {
  //     name = name.replaceFirst(affix, '');
  //   }
  //   return name.trim();
  // }

  String getIconIceName() {
    return infos.entries
        .firstWhere(
          (element) => element.key.contains('Icon'),
          orElse: () => const MapEntry('', ''),
        )
        .value;
  }

  String getImageIceName() {
    return infos.entries.firstWhere((element) => element.key.contains('Ice Hash - Image')).value;
  }

  bool containsCategory(List<String> filters) {
    for (var cateName in itemCategories) {
      if (filters.contains(cateName.replaceAll('NGS', '').replaceAll('PSO2', '').trim())) {
        return true;
      }
    }
    return false;
  }

  // bool compareNames(Item bItem) {
  //   String jpName = infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
  //   String bItemJPName = bItem.infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
  //   if (jpName == 'null' || bItemJPName == 'null') return false;
  //   if (jpName == bItemJPName && jpName.isNotEmpty && bItemJPName.isNotEmpty) {
  //     return true;
  //   } else if (jpName.isEmpty && bItemJPName.isEmpty) {
  //     String enName = infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
  //     String bItemENName = bItem.infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
  //     if (enName == 'null' || bItemENName == 'null' || enName.isEmpty || bItemENName.isEmpty) return false;
  //     if (enName == bItemENName) return true;
  //   }
  //   return false;
  // }

  bool compareNames(ItemData bItem) {
    if (csvFileName != bItem.csvFileName ||
            csvFilePath != bItem.csvFilePath ||
            // itemType != bItem.itemType ||
            itemCategories.length != bItem.itemCategories.length
        //iconImagePath != bItem.iconImagePath ||
        // infos.entries.length != bItem.infos.entries.length
        ) {
      return false;
    } else {
      for (int i = 0; i < itemCategories.length; i++) {
        if (itemCategories[i] != bItem.itemCategories[i]) {
          return false;
        }
      }
      String jpName = infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
      String bItemJPName = bItem.infos.entries.firstWhere((element) => element.key == 'Japanese Name', orElse: () => const MapEntry('null', 'null')).value;
      String enName = infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
      String bItemENName = bItem.infos.entries.firstWhere((element) => element.key == 'English Name', orElse: () => const MapEntry('null', 'null')).value;
      if (jpName != bItemJPName && (jpName != 'null' || bItemJPName != 'null') && jpName.isNotEmpty && bItemJPName.isNotEmpty) {
        return false;
      }
      if (enName != bItemENName && (enName != 'null' || bItemENName != 'null') && enName.isNotEmpty && bItemENName.isNotEmpty) {
        return false;
      }

      if (infos.entries.length == bItem.infos.entries.length && infos.entries.length > 2 && bItem.infos.entries.length > 2) {
        for (int i = 2; i < infos.entries.length; i++) {
          if (infos.entries.elementAt(i).key != bItem.infos.entries.elementAt(i).key || infos.entries.elementAt(i).value != bItem.infos.entries.elementAt(i).value) {
            return false;
          }
        }
      }
      return true;
    }
  }

  bool compare(ItemData bItem) {
    if (csvFileName != bItem.csvFileName ||
        csvFilePath != bItem.csvFilePath ||
        // itemType != bItem.itemType ||
        itemCategories.length != bItem.itemCategories.length ||
        //iconImagePath != bItem.iconImagePath ||
        infos.entries.length != bItem.infos.entries.length) {
      return false;
    } else {
      for (int i = 0; i < itemCategories.length; i++) {
        if (itemCategories[i] != bItem.itemCategories[i]) {
          return false;
        }
      }
      for (int i = 0; i < infos.entries.length; i++) {
        if (infos.entries.elementAt(i).key != bItem.infos.entries.elementAt(i).key || infos.entries.elementAt(i).value != bItem.infos.entries.elementAt(i).value) {
          return false;
        }
      }
      return true;
    }
  }

  bool containsIce(String iceName) {
    for (int i = 0; i < infos.entries.length; i++) {
      if (infos.entries.elementAt(i).value.contains(iceName)) {
        return true;
      }
    }
    // if (infos.values.contains(iceName)) {
    //   return true;
    // }
    return false;
  }

  bool containsIceFiles(List<String> iceNameList) {
    for (var iceName in iceNameList) {
      for (int i = 0; i < infos.entries.length; i++) {
        if (infos.entries.elementAt(i).value.contains(iceName)) {
          return true;
        }
      }
    }

    return false;
  }

  List<String> getDetails() {
    return infos.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.key != 'Japanese Name' &&
            e.key != 'English Name' &&
            !e.key.contains('Bone') &&
            e.key != 'JP Name' &&
            e.key != 'EN Name' &&
            e.key != 'Reboot Human' &&
            e.key != 'Reboot Cast Male' &&
            e.key != 'Reboot Cast Female' &&
            e.key != 'Reboot Fig' &&
            e.key != 'Reboot VFX' &&
            e.key != 'PSO2 VFX' &&
            e.key != 'PSO2 File')
        .map((e) => '${e.key}: ${e.value}'.trim())
        .toList();
  }

  List<String> getModSwapDetails(SubMod submod) {
    return infos.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.key != 'Japanese Name' &&
            e.key != 'English Name' &&
            !e.key.contains('Bone') &&
            e.key != 'JP Name' &&
            e.key != 'EN Name' &&
            e.key != 'Reboot Human' &&
            e.key != 'Reboot Cast Male' &&
            e.key != 'Reboot Cast Female' &&
            e.key != 'Reboot Fig' &&
            e.key != 'Reboot VFX' &&
            e.key != 'PSO2 VFX' &&
            e.key != 'PSO2 File')
        .where((e) => !e.key.contains('Hash') || (e.key.contains('Hash') && submod.getModFileNames().contains(e.value.split('\\').last)))
        .map((e) => '${e.key}: ${e.value}'.trim())
        .toList();
  }

  List<String> getDetailsForAqmInject() {
    return infos.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.key != 'Japanese Name' &&
            e.key != 'English Name' &&
            e.key != 'Icon' &&
            e.key != 'Sounds' &&
            !e.key.contains('Bone') &&
            e.key != 'JP Name' &&
            e.key != 'EN Name' &&
            e.key != 'Reboot Human' &&
            e.key != 'Reboot Cast Male' &&
            e.key != 'Reboot Cast Female' &&
            e.key != 'Reboot Fig' &&
            e.key != 'Reboot VFX' &&
            e.key != 'PSO2 VFX' &&
            e.key != 'PSO2 File')
        .map((e) => '${e.key}: ${e.value}'.trim())
        .toList();
  }

  List<String> getIceDetails() {
    return infos.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.key != 'Japanese Name' &&
            e.key.toLowerCase() != 'id' &&
            e.key != 'Icon' &&
            e.key != 'Adjusted Id' &&
            e.key != 'English Name' &&
            !e.key.contains('Bone') &&
            e.key != 'JP Name' &&
            e.key != 'EN Name' &&
            e.key != 'Reboot Human' &&
            e.key != 'Reboot Cast Male' &&
            e.key != 'Reboot Cast Female' &&
            e.key != 'Reboot Fig' &&
            e.key != 'Reboot VFX' &&
            e.key != 'PSO2 VFX' &&
            e.key != 'PSO2 File' &&
            e.key != 'Gender' &&
            e.key != 'Gender (Blank usually follows previous)' &&
            e.key != 'Chat Command' &&
            e.key != 'Sounds')
        .map((e) => '${e.key}: ${e.value}'.trim())
        .toList();
  }

  List<String> getIceDetailsWithoutKeys() {
    return infos.entries
        .where((e) =>
            e.value.isNotEmpty &&
            e.key != 'Japanese Name' &&
            e.key.toLowerCase() != 'id' &&
            e.key != 'Icon' &&
            e.key != 'Adjusted Id' &&
            e.key != 'English Name' &&
            !e.key.contains('Bone') &&
            e.key != 'JP Name' &&
            e.key != 'EN Name' &&
            e.key != 'Reboot Human' &&
            e.key != 'Reboot Cast Male' &&
            e.key != 'Reboot Cast Female' &&
            e.key != 'Reboot Fig' &&
            e.key != 'Reboot VFX' &&
            e.key != 'PSO2 VFX' &&
            e.key != 'PSO2 File' &&
            e.key != 'Gender' &&
            e.key != 'Gender (Blank usually follows previous)' &&
            e.key != 'Chat Command' &&
            e.key != 'Sounds')
        .map((e) => e.value.trim().split('\\').last)
        .toList();
  }

  ItemData.fromMap(
      String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String category, String subCategory, int categoryIndex, String iconImagePath, Map<String, String> infos)
      : this(csvFileName = csvFileName, csvFilePath = csvFilePath, itemType = itemType, itemCategories = itemCategories, category = category, subCategory = subCategory, categoryIndex = categoryIndex,
            iconImagePath = iconImagePath, infos = infos);

  factory ItemData.fromJson(Map<String, dynamic> json) => _$ItemDataFromJson(json);
  Map<String, dynamic> toJson() => _$ItemDataToJson(this);
}
