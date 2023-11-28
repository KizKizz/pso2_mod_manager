import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/widgets/snackbar.dart';

Future<List<ModFile>> restoreOriginalFilesToTheGame(context, List<ModFile> modFiles) async {
  List<ModFile> unappliedModFiles = [];
  if (prioritizeLocalBackup) {
    await restoreOriginalFilesLocalBackups(context, modFiles);
    await restoreOriginalFilesFromServers(context, modFiles);
  } else {
    await restoreOriginalFilesFromServers(context, modFiles);
    await restoreOriginalFilesLocalBackups(context, modFiles);
  }

  for (var modFile in modFiles) {
    if (modFile.ogLocations.isEmpty) {
      modFile.ogMd5s.clear();
      modFile.applyDate = DateTime(0);
      //add to result if applied then unapplied
      if (modFile.applyStatus) {
        unappliedModFiles.add(modFile);
      }
      modFile.applyStatus = false;
    }
  }

  selectedModFilesInAppliedList.removeWhere((element) => unappliedModFiles.where((e) => e.location == element.location).isNotEmpty);
  appliedItemList = await appliedListBuilder(moddedItemsList);
  saveModdedItemListToJson();

  return unappliedModFiles;
}

bool multipleModFilesCheck(List<CategoryType> appliedList, ModFile modFile) {
  for (var cateType in appliedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        if (item.applyStatus) {
          for (var mod in item.mods) {
            if (mod.applyStatus) {
              for (var submod in mod.submods) {
                if (submod.applyStatus) {
                  int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
                  if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location != modFile.location) {
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return false;
}

Future<void> restoreOriginalFilesFromServers(context, List<ModFile> modFiles) async {
  List<String> dataPathsToDownload = [];
  for (var modFile in modFiles) {
    for (var originalFilePath in modFile.ogLocations) {
      dataPathsToDownload.add(originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim());
    }
  }
  final restoredFiles = await downloadIceFromOfficial(dataPathsToDownload);
  for (var modFile in modFiles) {
    final pathsToRemove = restoredFiles.where((element) => element.contains(modFile.modFileName));
    modFile.ogLocations.removeWhere((element) => pathsToRemove.contains(element.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim()));
    for (var pathToRemove in pathsToRemove) {
      File fileToRemove = File(Uri.file('$modManBackupsDirPath/${pathToRemove.replaceFirst(Uri.file('data/').toFilePath(), '')}').toFilePath());
      if (fileToRemove.existsSync() && !multipleModFilesCheck(appliedItemList, modFile)) {
        final deletedFile = await fileToRemove.delete();
        if (!deletedFile.existsSync()) {
          modFile.bkLocations.remove(fileToRemove.path);
        }
        if (p.basename(fileToRemove.parent.parent.path) == 'win32reboot' && fileToRemove.parent.listSync(recursive: true).whereType<File>().isEmpty ||
            p.basename(fileToRemove.parent.parent.path) == 'win32reboot_na' && fileToRemove.parent.listSync(recursive: true).whereType<File>().isEmpty) {
          await fileToRemove.parent.delete(recursive: true);
        }
      }
    }
  }
}

Future<void> restoreOriginalFilesLocalBackups(context, List<ModFile> modFiles) async {
  for (var modFile in modFiles) {
    List<String> originalPathsToRemove = [];
    for (var originalFilePath in modFile.ogLocations) {
      String backupFilePath = originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath).trim();
      File backupFile = File(backupFilePath);
      if (backupFile.existsSync()) {
        try {
          await backupFile.copy(originalFilePath);
          if (!multipleModFilesCheck(appliedItemList, modFile) && backupFile.existsSync()) {
            final deletedFile = await backupFile.delete();
            if (!deletedFile.existsSync()) {
              modFile.bkLocations.remove(backupFile.path);
            }
            if (p.basename(backupFile.parent.parent.path) == 'win32reboot' && backupFile.parent.listSync(recursive: true).whereType<File>().isEmpty ||
                p.basename(backupFile.parent.parent.path) == 'win32reboot_na' && backupFile.parent.listSync(recursive: true).whereType<File>().isEmpty) {
              await backupFile.parent.delete(recursive: true);
            }
          }
          originalPathsToRemove.add(originalFilePath);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', e.toString(), 1000));
        }
      }
    }
    if (originalPathsToRemove.isNotEmpty) {
      modFile.ogLocations.removeWhere((element) => originalPathsToRemove.contains(element));
    }
  }
}
