import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<List<ModSet>> modSetLoader() async {
  List<ModSet> newModSets = [];
  //Load list from json
  if (File(modManModSetsJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManModSetsJsonPath).readAsStringSync());
    for (var set in jsonData) {
      newModSets.add(ModSet.fromJson(set));
    }
  }

  for (var set in newModSets) {
    set.setItems = allSetItems.where((element) => element.setNames.contains(set.setName)).toList();
  }

  newModSets.sort(
    (a, b) => b.addedDate.compareTo(a.addedDate),
  );

  //saveSetListToJson()

  return newModSets;
}

List<Item> itemsFromAppliedListFetch(List<CategoryType> appliedList) {
  List<Item> newItemList = [];
  for (var type in appliedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        if (item.applyStatus == true) {
          item.isSet = true;
          newItemList.add(item);
        }
      }
    }
  }

  return newItemList;
}

void setModSetNameToItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.applyStatus) {
      item.isSet = true;
      if (!item.setNames.contains(modSetName)) {
        item.setNames.add(modSetName);
      }
      for (var mod in item.mods) {
        if (mod.applyStatus) {
          mod.isSet = true;
          if (!mod.setNames.contains(modSetName)) {
            mod.setNames.add(modSetName);
          }
          for (var submod in mod.submods) {
            if (submod.applyStatus) {
              submod.isSet = true;
              if (!submod.setNames.contains(modSetName)) {
                submod.setNames.add(modSetName);
              }
              for (var modFile in submod.modFiles) {
                if (modFile.applyStatus) {
                  modFile.isSet = true;
                  if (!modFile.setNames.contains(modSetName)) {
                    modFile.setNames.add(modSetName);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

void removeModSetNameFromItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.isSet) {
      item.setNames.removeWhere(
        (element) => element == modSetName,
      );
      if (item.setNames.isEmpty) {
        item.isSet = false;
      }
      for (var mod in item.mods) {
        if (mod.isSet) {
          mod.setNames.removeWhere(
            (element) => element == modSetName,
          );
          if (mod.setNames.isEmpty) {
            mod.isSet = false;
          }
          for (var submod in mod.submods) {
            if (submod.isSet) {
              submod.setNames.removeWhere(
                (element) => element == modSetName,
              );
              if (submod.setNames.isEmpty) {
                submod.isSet = false;
              }
              for (var modFile in submod.modFiles) {
                if (modFile.isSet) {
                  modFile.setNames.removeWhere(
                    (element) => element == modSetName,
                  );
                  if (modFile.setNames.isEmpty) {
                    modFile.isSet = false;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
