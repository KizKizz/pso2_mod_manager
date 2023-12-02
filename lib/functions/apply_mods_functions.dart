import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

Future<bool> applyModsToTheGame(context, Item curItem, Mod curMod, SubMod curSubmod) async {
  try {
    await modFilesApply(context, curSubmod.modFiles).then((value) async {
      if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
        curSubmod.applyDate = DateTime.now();
        curItem.applyDate = DateTime.now();
        curMod.applyDate = DateTime.now();
        curSubmod.applyStatus = true;
        curSubmod.isNew = false;
        curMod.applyStatus = true;
        curMod.isNew = false;
        curItem.applyStatus = true;
        if (curItem.mods.where((element) => element.isNew).isEmpty) {
          curItem.isNew = false;
        }
        List<ModFile> appliedModFiles = value;
        String fileAppliedText = '';
        for (var element in appliedModFiles) {
          if (fileAppliedText.isEmpty) {
            fileAppliedText = '${curLangText!.uiSuccessfullyApplied} ${curMod.modName} > ${curSubmod.submodName}:\n';
          }
          fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
        appliedItemList = await appliedListBuilder(moddedItemsList);
      }

      isModViewModsApplying = false;
      saveModdedItemListToJson();
      return true;
    });
  } catch (e) {
    isModViewModsApplying = false;
    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 5000));
  }

  return false;
}
