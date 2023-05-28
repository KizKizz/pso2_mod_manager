import 'package:flutter/material.dart';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/functions/modfile_applied_dup.dart';
import 'package:pso2_mod_manager/global_variables.dart';

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
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: const Center(
                child: Text('Duplicate(s) in applied mods found', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Applying this mod would replace these applied mod files:',
                      style: TextStyle(fontWeight: FontWeight.w500),
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
                    child: const Text('Return'),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Sure'))
              ]));
}
