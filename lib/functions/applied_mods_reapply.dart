import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<bool> modFileApplyForReApply(context, ModFile modFile) async {
  //retore dublicate
  //await modFileRestore(moddedItemsList, modFile);
  //modFile = await modFileBackup(modFile);
  await localOriginalFilesBackupForReApply(context, modFile);
  //replace files in game data
  for (var ogPath in modFile.ogLocations) {
    File returnedFile = File('');
    try {
      returnedFile = await File(modFile.location).copy(ogPath);
    } catch (e) {
      //ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 5000));
      debugPrint(e.toString());
    }
    if (returnedFile.path.isEmpty || returnedFile.path != ogPath) {
      return false;
    }
  }
  modFile.md5 = await getFileHash(modFile.location);
  saveModdedItemListToJson();

  return true;
}

Future<void> localOriginalFilesBackupForReApply(context, ModFile modFile) async {
  List<String> backupFilePaths = [];
  for (var originalFilePath in modFile.ogLocations) {
    String fileInBackupFolderPath = originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath);
    if (File(originalFilePath).existsSync()) {
      if (!File(fileInBackupFolderPath).parent.existsSync()) {
        File(fileInBackupFolderPath).parent.createSync();
      }
      try {
        final backupFile = await File(originalFilePath).copy(fileInBackupFolderPath);
        backupFilePaths.add(backupFile.path);
        //get md5 of og files
        // String newOGMD5 = await getFileHash(backupFile.path);
        // if (!modFile.ogMd5s.contains(newOGMD5)) {
        //   modFile.ogMd5s.add(newOGMD5);
        // }
      } catch (e) {
        //ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 5000));
        debugPrint(e.toString());
      }
    } else if (File(fileInBackupFolderPath).existsSync()) {
      backupFilePaths.add(fileInBackupFolderPath);
      //get md5 of og files
      // String newOGMD5 = await getFileHash(fileInBackupFolderPath);
      // if (!modFile.ogMd5s.contains(newOGMD5)) {
      //   modFile.ogMd5s.add(newOGMD5);
      // }
    }
  }
  modFile.bkLocations = backupFilePaths;
}
