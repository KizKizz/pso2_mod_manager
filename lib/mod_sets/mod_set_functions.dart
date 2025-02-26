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
      ModSet jsonSet = ModSet.fromJson(set);
      jsonSet.setItems = modSetItemsFromMasterList.where((e) => e.isSet && e.setNames.contains(jsonSet.setName)).toList();
      newModSets.add(jsonSet);
      modsetLoadingStatus.value = jsonSet.setName;
      await Future.delayed(const Duration(microseconds: 1000));
    }
  }

  //remove nonexistence set name
  List<String> setNames = newModSets.map((e) => e.setName).toList();
  for (var set in newModSets) {
    set.setItems.removeWhere((e) => e.mods.indexWhere((m) => m.setNames.contains(set.setName)) == -1);
    for (var item in set.setItems) {
      item.setNames.removeWhere((element) => !setNames.contains(element));
      for (var mod in item.mods.where((e) => e.setNames.contains(set.setName))) {
        for (var submod in mod.submods.where((e) => e.setNames.contains(set.setName))) {
          if (!submod.isSet) submod.isSet = true;
        }
        if (mod.submods.indexWhere((e) => e.isSet) != 1 || mod.setNames.contains(set.setName)) {
          mod.isSet = true;
        } else {
          mod.isSet = false;
        }
      }
      if (item.mods.indexWhere((e) => e.isSet) != 1) {
        item.isSet = true;
      } else {
        item.isSet = false;
      }
    }
    set.appliedDate ??= DateTime.now();
  }

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
        }
        mod.setNames.removeWhere((e) => e == modset.setName);
      }
      item.setNames.removeWhere((e) => e == modset.setName);
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
