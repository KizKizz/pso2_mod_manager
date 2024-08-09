// ignore_for_file: unused_import

import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';

Future<List<String>> unapplySelectedAppliedMods(context) async {
  String unappliedFileNames = '';
  List<ModFile> reappliedModFiles = await restoreOriginalFilesToTheGame(context, selectedModFilesInAppliedList);

  List<Item> matchedItems = [];
  List<Mod> matchedMods = [];
  List<SubMod> matchedSubmods = [];
  for (var modFile in reappliedModFiles) {
    var matchingTypes = moddedItemsList.where((element) => element.categories.where((cate) => cate.categoryName == modFile.category).isNotEmpty);
    for (var type in matchingTypes) {
      var matchingCates = type.categories.where((element) => modFile.location.contains(element.location));
      for (var cate in matchingCates) {
        var matchingItems = cate.items.where((element) => modFile.location.contains(element.location));
        for (var item in matchingItems) {
          if (matchedItems.where((element) => element.location == item.location).isEmpty) {
            matchedItems.add(item);
          }
          var matchingMods = item.mods.where((element) => modFile.location.contains(element.location));
          for (var mod in matchingMods) {
            if (matchedMods.where((element) => element.location == mod.location).isEmpty) {
              matchedMods.add(mod);
            }
            var matchingSubmods = mod.submods.where((element) => modFile.location.contains(element.location));
            for (var submod in matchingSubmods) {
              if (matchedSubmods.where((element) => element.location == submod.location).isEmpty) {
                matchedSubmods.add(submod);
              }
            }
          }
        }
      }
    }
  }

  for (var item in matchedItems) {
    for (var mod in item.mods.where((element) => matchedMods.where((e) => e.location == element.location).isNotEmpty)) {
      for (var submod in mod.submods.where((element) => matchedSubmods.where((e) => e.location == element.location).isNotEmpty)) {
        if (submod.applyStatus) {
          unappliedFileNames += '${item.itemName} > ${mod.modName} > ${submod.submodName}\n';
          submod.setApplyState(false);
          submod.applyDate = DateTime(0);
          previewImages.clear();
          //videoPlayer.remove(0);
          previewModName = '';
        }

        if (mod.submods.where((element) => element.applyStatus).isEmpty) {
          mod.setApplyState(false);
          mod.applyDate = DateTime(0);
        }
        if (item.mods.where((element) => element.applyStatus).isEmpty) {
          item.setApplyState(false);
          item.applyDate = DateTime(0);
          if (item.isOverlayedIconApplied!) {
            await restoreOverlayedIcon(item);
          }
        }
      }
    }
  }

  saveModdedItemListToJson();

  return ['${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemovedTheseMods}\n${unappliedFileNames.trim()}'];
}
