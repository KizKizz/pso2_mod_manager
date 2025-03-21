import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:path/path.dart' as p;

void saveRestoreAppliedModsCheck() {
  if (Directory(savedAppliedModFileDirPath).existsSync() && Directory(savedAppliedModFileDirPath).listSync(recursive: true).whereType<File>().isNotEmpty) {
    saveRestoreAppliedModsActive.value = true;
  } else {
    saveRestoreAppliedModsActive.value = false;
  }
}

Future<bool> saveRestoreAllAppliedMods() async {
  bool result = false;
  await Directory(savedAppliedModFileDirPath).create(recursive: true);
  for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items.where((e) => e.applyStatus)) {
        bool modFilesCopied = false;
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            for (var appliedModFile in submod.modFiles.where((e) => e.applyStatus)) {
              for (var path in appliedModFile.ogLocations) {
                // save
                String saveFilePath = path.replaceFirst(pso2DataDirPath, savedAppliedModFileDirPath);
                await Directory(p.dirname(saveFilePath)).create(recursive: true);
                await File(path).copy(saveFilePath);
                // restore
                if (originalFilesBackupsFromSega) {
                  String iceWebPath = ('${path.replaceFirst(pso2binDirPath + p.separator, '')}.pat').replaceAll(p.separator, '/');
                  File downloadedFile = await originalIceDownload(iceWebPath, p.dirname(path), modApplyStatus);
                  if (!downloadedFile.existsSync()) {
                    File localBackupFile = File(path.replaceFirst(pso2DataDirPath, backupDirPath));
                    if (localBackupFile.existsSync()) {
                      await localBackupFile.copy(path);
                    }
                  }
                } else {
                  File localBackupFile = File(path.replaceFirst(pso2DataDirPath, backupDirPath));
                  if (localBackupFile.existsSync()) {
                    await localBackupFile.copy(path);
                  }
                }

                if (!result) result = true;
                if (!modFilesCopied) modFilesCopied = true;
              }
            }
          }
        }
        if (modFilesCopied && item.isOverlayedIconApplied!) {
          if (File(item.iconPath!).existsSync()) {
            String saveFilePath = item.iconPath!.replaceFirst(pso2DataDirPath, savedAppliedModFileDirPath);
            Directory(p.dirname(saveFilePath)).create(recursive: true);
            await File(item.iconPath!).copy(saveFilePath);
            String iconWebPath = ('${p.withoutExtension(item.iconPath!).replaceFirst(pso2binDirPath + p.separator, '')}.pat').replaceAll(p.separator, '/');
            await originalIceDownload(iconWebPath, p.dirname(item.iconPath!), modApplyStatus);
          }
        }
      }
    }
  }
  return result;
}

Future<void> reApplySavedMods() async {
  List<File> savedFiles = Directory(savedAppliedModFileDirPath).listSync(recursive: true).whereType<File>().toList();
  for (var file in savedFiles) {
    String dataFilePath = file.path.replaceFirst(savedAppliedModFileDirPath, pso2DataDirPath);
    await Directory(p.dirname(dataFilePath)).create(recursive: true);
    await file.copy(dataFilePath);
  }
  await Directory(savedAppliedModFileDirPath).delete(recursive: true);
}
