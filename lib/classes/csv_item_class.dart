import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/global_variables.dart';
part 'csv_item_class.g.dart';

@JsonSerializable()
class CsvItem {
  CsvItem(this.csvFileName, this.csvFilePath, this.itemType, this.itemCategories, this.category, this.subCategory, this.categoryIndex, this.iconImagePath, this.infos);

  String csvFileName;
  String csvFilePath;
  String itemType;
  List<String> itemCategories;
  String category;
  String subCategory;
  int categoryIndex;
  String iconImagePath;
  Map<String, String> infos = {};

  String getJPName() {
    return infos.entries.firstWhere((element) => element.key.contains('JP Name') || element.key.contains('Japanese Name')).value;
  }

  String getENName() {
    return infos.entries.firstWhere((element) => element.key.contains('EN Name') || element.key.contains('English Name')).value;
  }

  String getIconImagePath() {
    return infos.entries.firstWhere((element) => element.key.contains('iconImagePath')).value;
  }

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

  String getBaseItemENName() {
    List<String> toRemove = ['[Ba]', '[Se]', '[Ou]', '[In]', '[Fu]'];
    String name = getENName();
    // name = name.split('/').first;
    for (var affix in toRemove) {
      name = name.replaceFirst(affix, '');
    }
    return name.trim();
  }

  String getBaseItemJPName() {
    List<String> toRemove = ['[Ba]', '[Se]', '[Ou]', '[In]', '[Fu]'];
    String name = getJPName();
    // name = name.split('/').first;
    for (var affix in toRemove) {
      name = name.replaceFirst(affix, '');
    }
    return name.trim();
  }

  String getIconIceName() {
    return infos.entries.firstWhere((element) => element.key.contains('Icon')).value;
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

  bool compareNames(CsvItem bItem) {
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

  bool compare(CsvItem bItem) {
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
      if (infos.values.contains(iceName)) {
        return true;
      }
    }
    return false;
  }

  CsvItem.fromMap(
      String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String category, String subCategory, int categoryIndex, String iconImagePath, Map<String, String> infos)
      : this(csvFileName = csvFileName, csvFilePath = csvFilePath, itemType = itemType, itemCategories = itemCategories, category = category, subCategory = subCategory, categoryIndex = categoryIndex,
            iconImagePath = iconImagePath, infos = infos);

  factory CsvItem.fromJson(Map<String, dynamic> json) => _$CsvItemFromJson(json);
  Map<String, dynamic> toJson() => _$CsvItemToJson(this);
}
