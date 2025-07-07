import 'dart:io';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/material_app_service.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/mod_apply/item_icon_mark.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';

Future<void> modUnapplySequence(context, bool applying, Item item, Mod mod, SubMod submod, List<ModFile> modFilesToRestore) async {
  await applyingPopup(MaterialAppService.navigatorKey.currentContext, applying, item, mod, submod, modFilesToRestore);
}

Future<void> modUnapplyRestore(Item item, Mod mod, SubMod submod, List<ModFile> modFilesToRestore) async {
  if (originalFilesBackupsFromSega) {
    for (var modFile in modFilesToRestore.isNotEmpty ? modFilesToRestore : submod.modFiles.where((e) => e.applyStatus)) {
      await restoreFromSegaServers(item, mod, submod, modFile);
      if (modFile.applyStatus) {
        await restoreFromLocalBackups(item, mod, submod, modFile);
      } else {
        for (var path in modFile.bkLocations) {
          if (File(path).existsSync()) await File(path).delete(recursive: true);
        }
        modFile.bkLocations.clear();
      }
    }
  } else {
    for (var modFile in modFilesToRestore.isNotEmpty ? modFilesToRestore : submod.modFiles.where((e) => e.applyStatus)) {
      await restoreFromLocalBackups(item, mod, submod, modFile);
      if (modFile.applyStatus && !useLocalBackupOnly) {
        await restoreFromSegaServers(item, mod, submod, modFile);
      }
      if (!modFile.applyStatus) {
        for (var path in modFile.bkLocations) {
          if (File(path).existsSync()) await File(path).delete(recursive: true);
        }
        modFile.bkLocations.clear();
      }
    }
  }
  saveMasterModListToJson();
}

Future<void> restoreFromLocalBackups(Item item, Mod mod, SubMod submod, ModFile modFile) async {
  for (var backupPath in modFile.bkLocations) {
    File backedupFile = File(backupPath);
    if (backedupFile.existsSync()) {
      modApplyStatus.value = appText.dText(appText.localBackupFoundForModFile, modFile.modFileName);
      final copiedFile = await backedupFile.copy(backedupFile.path.replaceFirst(backupDirPath, pso2DataDirPath));
      modApplyStatus.value = appText.dText(appText.restoringBackupFileToGameData, modFile.modFileName);
      if (await copiedFile.getMd5Hash() != await modFile.getMd5Hash()) {
        if (await backedupFile.exists()) await backedupFile.delete(recursive: true);
        modFile.ogLocations.removeWhere((e) => e == copiedFile.path);
        modFile.applyStatus = false;
        modApplyStatus.value = appText.successful;
      }
    }
  }

  modFile.bkLocations.removeWhere((e) => !File(e).existsSync());
  if (!modFile.applyStatus) {
    if (!submod.getModFilesAppliedState()) submod.applyStatus = false;
    if (!mod.getSubmodsAppliedState()) mod.applyStatus = false;
    if (!item.getModsAppliedState()) item.applyStatus = false;
  }
  if (!item.applyStatus && item.isOverlayedIconApplied! && !useLocalBackupOnly) {
    bool result = await markedItemIconRestore(item);
    if (result) item.isOverlayedIconApplied = false;
  }
}

Future<void> restoreFromSegaServers(Item item, Mod mod, SubMod submod, ModFile modFile) async {
  List<String> restoredPaths = [];
  for (var ogPath in modFile.ogLocations) {
    final downloadedFile = await originalIceDownload(ogPath, p.dirname(ogPath).replaceAll('/', p.separator), modApplyStatus);
    if (downloadedFile != null && await downloadedFile.getMd5Hash() != await modFile.getMd5Hash()) {
      restoredPaths.add(ogPath);
      modApplyStatus.value = appText.dText(appText.restoringBackupFileToGameData, modFile.modFileName);
      File backedUpFile = File(ogPath.replaceFirst(pso2DataDirPath, backupDirPath).replaceAll('/', p.separator));
      if (await backedUpFile.exists()) {
        await backedUpFile.delete(recursive: true);
        modFile.bkLocations.removeWhere((e) => !File(e).existsSync());
      }
    }
  }

  modFile.ogLocations.removeWhere((e) => restoredPaths.contains(e));
  if (modFile.ogLocations.isEmpty) {
    modFile.applyStatus = false;
    modApplyStatus.value = appText.successful;
    if (!submod.getModFilesAppliedState()) submod.applyStatus = false;
    if (!mod.getSubmodsAppliedState()) mod.applyStatus = false;
    if (!item.getModsAppliedState()) item.applyStatus = false;
  }
  if (!item.applyStatus && item.isOverlayedIconApplied!) {
    bool result = await markedItemIconRestore(item);
    if (result) item.isOverlayedIconApplied = false;
  }
}
