import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/backup_functions.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

//return true if successfully copied
Future<bool> modFileApply(context, ModFile modFile) async {
  //retore dublicate
  //await modFileRestore(moddedItemsList, modFile);
  //modFile = await modFileBackup(modFile);
  if (modFile.ogLocations.isEmpty) {
    return false;
  }
  await localOriginalFilesBackup(context, modFile);
  //replace files in game data
  for (var ogPath in modFile.ogLocations) {
    File returnedFile = File('');
    try {
      returnedFile = await File(modFile.location).copy(ogPath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 5000));
      return false;
    }
    if (returnedFile.path.isEmpty || returnedFile.path != ogPath) {
      return false;
    }
  }
  modFile.md5 = await getFileHash(modFile.location);
  saveModdedItemListToJson();

  return true;
}
