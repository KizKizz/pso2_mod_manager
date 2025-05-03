import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/new_set_name_popup.dart';
import 'package:pso2_mod_manager/system_loads/app_modset_load_page.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';

Future<List<ModSet>> modSetLoader() async {
  List<ModSet> newModSets = [];
  // Load list from json
  String dataFromFile = File(mainModSetListJsonPath).readAsStringSync();
  if (dataFromFile.isNotEmpty) {
    var jsonData = jsonDecode(dataFromFile);
    for (var set in jsonData) {
      newModSets.add(ModSet.fromJson(set));
      // modsetLoadingStatus.value = newModSets.last.setName;
      await Future.delayed(const Duration(microseconds: 100));
    }
  }

  //remove nonexistence set name
  List<String> existingSetNames = newModSets.map((e) => e.setName).toList();
  for (var item in modSetItemsFromMasterList) {
    for (var mod in item.mods) {
      for (var submod in mod.submods) {
        for (var modFile in submod.modFiles) {
          modFile.setNames.removeWhere((e) => !existingSetNames.contains(e));
          if (modFile.setNames.isEmpty) modFile.isSet = false;
        }
        submod.setNames.removeWhere((e) => !existingSetNames.contains(e));
        submod.setNames.isNotEmpty ? submod.isSet = true : submod.isSet = false;
      }
      mod.setNames.removeWhere((e) => !existingSetNames.contains(e));
      mod.setNames.isNotEmpty ? mod.isSet = true : mod.isSet = false;
    }
    item.setNames.removeWhere((e) => !existingSetNames.contains(e));
    item.setNames.isNotEmpty ? item.isSet = true : item.isSet = false;
    await Future.delayed(const Duration(microseconds: 100));
  }

  // Populate sets with items
  for (var set in newModSets) {
    modsetLoadingStatus.value = set.setName;
    set.setItems = modSetItemsFromMasterList.where((e) => e.setNames.contains(set.setName)).toList();
    set.appliedDate ??= DateTime.now();
    await Future.delayed(const Duration(microseconds: 1000));
  }

  // List<String> setNames = newModSets.map((e) => e.setName).toList();
  // for (var set in newModSets) {
  //   for (var item in set.setItems) {
  //     for (var mod in item.mods.where((e) => e.setNames.isNotEmpty)) {
  //       for (var submod in mod.submods.where((e) => e.setNames.isNotEmpty)) {
  //         submod.setNames.removeWhere((e) => !setNames.contains(e));
  //         submod.activeInSets!.removeWhere((e) => !setNames.contains(e));
  //         submod.setNames.isEmpty ? submod.isSet = false : submod.isSet = true;
  //       }
  //       mod.setNames.removeWhere((e) => !setNames.contains(e));
  //       mod.setNames.isEmpty ? mod.isSet = false : mod.isSet = true;
  //     }
  //     item.setNames.removeWhere((e) => !setNames.contains(e));
  //     item.setNames.isEmpty ? item.isSet = false : item.isSet = true;
  //   }
  //   set.appliedDate ??= DateTime.now();
  // }

  return newModSets;
}

void saveMasterModSetListToJson() {
  //Save to json
  masterModSetList.map((modset) => modset.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainModSetListJsonPath).writeAsStringSync(encoder.convert(masterModSetList));
}

Future<void> newModSetCreate(context) async {
  String? setName = await newModSetNamePopup(context);
  if (setName != null) {
    masterModSetList.add(ModSet(setName, 0, true, false, DateTime.now(), DateTime(0), []));
    saveMasterModSetListToJson();
  }
}

Future<void> modSetDelete(context, ModSet modset) async {
  bool confirmation = await deleteConfirmPopup(context, modset.setName);
  if (confirmation) {
    for (var item in modset.setItems) {
      for (var mod in item.mods.where((e) => e.modName.contains(modset.setName))) {
        for (var submod in mod.submods.where((e) => e.modName.contains(modset.setName))) {
          submod.setNames.removeWhere((e) => e == modset.setName);
          submod.activeInSets!.removeWhere((e) => e == modset.setName);
          if (submod.setNames.isEmpty) submod.isSet = false;
        }
        mod.setNames.removeWhere((e) => e == modset.setName);
        if (mod.setNames.isEmpty) mod.isSet = false;
      }
      item.setNames.removeWhere((e) => e == modset.setName);
      if (item.setNames.isEmpty) item.isSet = false;
    }
    masterModSetList.remove(modset);
    saveMasterModSetListToJson();
    saveMasterModListToJson();
    deletedNotification(modset.setName);
  }
}

Future<bool> submodsAddToSet(context, Item item, Mod mod, SubMod submod, List<ModSet> toAddSets) async {
  for (var modset in toAddSets) {
    if (modset.setItems.indexWhere((e) => e.location == item.location) == -1) modset.setItems.add(item);
    if (!item.setNames.contains(modset.setName)) item.setNames.add(modset.setName);
    if (!mod.setNames.contains(modset.setName)) mod.setNames.add(modset.setName);
    if (!submod.setNames.contains(modset.setName)) submod.setNames.add(modset.setName);
  }

  submod.setNames.isNotEmpty ? submod.isSet = true : submod.isSet = false;
  mod.setNames.isNotEmpty ? mod.isSet = true : mod.isSet = false;
  item.setNames.isNotEmpty ? item.isSet = true : item.isSet = false;

  if (toAddSets.isNotEmpty && toAddSets.indexWhere((e) => e.setItems.contains(item)) != -1) {
    saveMasterModSetListToJson();
    saveMasterModListToJson();
    return true;
  } else {
    return false;
  }
}
