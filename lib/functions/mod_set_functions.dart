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
      item.setNames.add(modSetName);
      for (var mod in item.mods) {
        if (mod.applyStatus) {
          mod.isSet = true;
          mod.setNames.add(modSetName);
          for (var submod in mod.submods) {
            if (submod.applyStatus) {
              submod.isSet = true;
              submod.setNames.add(modSetName);
              for (var modFile in submod.modFiles) {
                if (modFile.applyStatus) {
                  modFile.isSet = true;
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

void removeModSetNameFromItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.isSet) {
      item.isSet = false;
      item.setNames.remove(modSetName);
      for (var mod in item.mods) {
        if (mod.isSet) {
          mod.isSet = false;
          mod.setNames.remove(modSetName);
          for (var submod in mod.submods) {
            if (submod.isSet) {
              submod.isSet = false;
              submod.setNames.remove(modSetName);
              for (var modFile in submod.modFiles) {
                if (modFile.isSet) {
                  modFile.isSet = false;
                  modFile.setNames.remove(modSetName);
                }
              }
            }
          }
        }
      }
    }
  }
}
