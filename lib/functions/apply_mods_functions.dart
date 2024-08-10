// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

Future<bool> applyModsToTheGame(context, Item curItem, Mod curMod, SubMod curSubmod) async {
  try {
    await modFilesApply(context, curSubmod, curSubmod.modFiles).then((value) async {
      if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
        curSubmod.applyDate = DateTime.now();
        curItem.applyDate = DateTime.now();
        curMod.applyDate = DateTime.now();
        curSubmod.setApplyState(true);
        curSubmod.isNew = false;
        curMod.setApplyState(true);
        curMod.isNew = false;
        curItem.setApplyState(true);
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
        ScaffoldMessenger.of(mainPageScaffoldKey.currentState!.context)
            .showSnackBar(snackBarMessage(mainPageScaffoldKey.currentState!.context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
      }

      if (markModdedItem) {
        await applyOverlayedIcon(context, curItem);
      }

      modViewModsApplyRemoving.value = false;
      saveModdedItemListToJson();

      //apply cmx
      if (curSubmod.hasCmx!) {
        int startIndex = -1, endIndex = -1;
        (startIndex, endIndex) = await cmxModPatch(curSubmod.cmxFile!);
        if (startIndex != -1 && endIndex != -1) {
          curSubmod.cmxStartPos = startIndex;
          curSubmod.cmxEndPos = endIndex;
          curSubmod.cmxApplied = true;
          saveModdedItemListToJson();
        }
      }

      return true;
    });
  } catch (e) {
    modViewModsApplyRemoving.value = false;
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(mainPageScaffoldKey.currentState!.context).showSnackBar(snackBarMessage(mainPageScaffoldKey.currentState!.context, '${curLangText!.uiError}!', e.toString(), 5000));
    return false;
  }
  return true;
}
