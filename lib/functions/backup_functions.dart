import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

Future<void> localOriginalFilesBackup(context, ModFile modFile) async {
  List<String> backupFilePaths = [];
  for (var originalFilePath in modFile.ogLocations) {
    String fileInBackupFolderPath = originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath);
    if (File(originalFilePath).existsSync() && !File(fileInBackupFolderPath).existsSync()) {
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
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 5000));
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

// Future<void> localOriginalFilesBackup(List<ModFile> modFiles) async {
//   for (var modFile in modFiles) {
//     List<String> backupFilePaths = [];
//     for (var originalFilePath in modFile.ogLocations) {
//       String fileInBackupFolderPath = originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath);
//       if (File(originalFilePath).existsSync() && !File(fileInBackupFolderPath).existsSync()) {
//         final backupFile = await File(originalFilePath).copy(fileInBackupFolderPath);
//         backupFilePaths.add(backupFile.path);
//       } else if (File(fileInBackupFolderPath).existsSync()) {
//         backupFilePaths.add(fileInBackupFolderPath);
//       }
//     }
//     modFile.bkLocations = backupFilePaths;
//   }
// }
