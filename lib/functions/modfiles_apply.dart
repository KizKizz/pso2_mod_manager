import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/functions/modfile_applied_dup.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<List<ModFile>> modFilesApply(context, List<ModFile> modFiles) async {
  List<ModFile> alreadyAppliedModFiles = [];
  bool applyMods = true;
  //check for applied file
  for (var modFile in modFiles) {
    if (!modFile.applyStatus) {
      ModFile? appliedFile = await modFileAppliedDupCheck(moddedItemsList, modFile);
      if (appliedFile != null) {
        alreadyAppliedModFiles.add(appliedFile);
      }
    }
  }
  if (alreadyAppliedModFiles.isNotEmpty) {
    String dupAppliedFiles = '';
    for (var modFile in alreadyAppliedModFiles) {
      dupAppliedFiles += '${modFile.itemName} > ${modFile.modName} > ${modFile.submodName} > ${modFile.modFileName}\n';
    }
    applyMods = await duplicateAppliedDialog(context, dupAppliedFiles.trim());
    if (applyMods) {
      for (var modFile in alreadyAppliedModFiles) {
        modFile = (await modFileAppliedDupRestore(moddedItemsList, modFile))!;
      }
    }
  }

  //apply mods
  List<ModFile> appliedModFiles = [];
  if (applyMods) {
    for (var modFile in modFiles) {
      modFile = await modFileApply(modFile);
      modFile.applyStatus = true;
      modFile.applyDate = DateTime.now();
      if (modFile.isNew) {
        modFile.isNew = false;
      }
      appliedModFiles.add(modFile);
    }
  }

  return appliedModFiles;
}

Future<bool> duplicateAppliedDialog(context, String fileList) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiDuplicatesInAppliedModsFound, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${curLangText!.uiApplyingWouldReplaceModFiles}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(fileList),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiReturn),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                    },
                    child: Text(curLangText!.uiSure))
              ]));
}
