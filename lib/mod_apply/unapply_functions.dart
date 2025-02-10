import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/item_icon_mark.dart';

Future<void> modUnapplySequence(context, bool applying, Item item, Mod mod, SubMod submod) async {
  await applyingPopup(context, applying, item, mod, submod);
}

Future<void> modUnapplyRestore(Item item, Mod mod, SubMod submod) async {
  modApplyStatus.value = '';
  if (originalFilesBackupsFromSega) {
    for (var modFile in submod.modFiles) {
      await restoreFromSegaServers(item, mod, submod, modFile);
      await Future.delayed(const Duration(microseconds: 10));
    }
    if (submod.getModFilesAppliedState()) {
      for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
        await restoreFromLocalBackups(item, mod, submod, modFile);
        await Future.delayed(const Duration(microseconds: 10));
      }
    }
  } else {
    for (var modFile in submod.modFiles) {
      await restoreFromLocalBackups(item, mod, submod, modFile);
      await Future.delayed(const Duration(microseconds: 10));
    }
    if (submod.getModFilesAppliedState()) {
      for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
        await restoreFromSegaServers(item, mod, submod, modFile);
        await Future.delayed(const Duration(microseconds: 10));
      }
    }
  }

  if (!item.applyStatus && item.isOverlayedIconApplied!) {
    await markedItemIconRestore(item);
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
      if (await copiedFile.getMd5Hash() != modFile.md5) {
        if (await backedupFile.exists()) await backedupFile.delete(recursive: true);
        modFile.ogLocations.removeWhere((e) => e == copiedFile.path);
        modFile.applyStatus = false;
        modApplyStatus.value = appText.successful;
      }
    }
  }

  modFile.bkLocations.removeWhere((e) => !File(e).existsSync());

  if (modFile.bkLocations.isEmpty) {
    submod.applyStatus = false;
    mod.applyStatus = false;
    item.applyStatus = false;
  }
}

Future<void> restoreFromSegaServers(Item item, Mod mod, SubMod submod, ModFile modFile) async {
  for (var backupPath in modFile.bkLocations) {
    final oData = oItemData.firstWhere((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName, orElse: () => OfficialIceFile.empty());
    if (oData.path.replaceAll('/', p.separator).isNotEmpty) {
      final downloadedFile = await restoreOriginalFileDownload(oData.path, oData.server, p.dirname(backupPath.replaceFirst(backupDirPath, pso2DataDirPath)));
      modApplyStatus.value = appText.dText(appText.restoringBackupFileToGameData, modFile.modFileName);
      if (downloadedFile.path.isNotEmpty && downloadedFile.existsSync()) {
        if (await File(backupPath).exists()) await File(backupPath).delete(recursive: true);
        modFile.ogLocations.removeWhere((e) => e == downloadedFile.path);
        modFile.applyStatus = false;
        modApplyStatus.value = appText.successful;
      }
    }
  }

  modFile.bkLocations.removeWhere((e) => !File(e).existsSync());

  if (modFile.bkLocations.isEmpty) {
    submod.applyStatus = false;
    mod.applyStatus = false;
    item.applyStatus = false;
  }
}

Future<File> restoreOriginalFileDownload(String networkFilePath, String server, String saveLocation) async {
  if (networkFilePath.isNotEmpty) {
    final serverURLs = [segaMasterServerURL, segaPatchServerURL, segaMasterServerBackupURL, segaPatchServerBackupURL];
    for (var url in serverURLs) {
      final task = DownloadTask(
          url: '$url$networkFilePath',
          filename: p.basenameWithoutExtension(networkFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          directory: saveLocation,
          updates: Updates.statusAndProgress,
          allowPause: false);

      final result = await FileDownloader().download(task,
          onProgress: (progress) => modApplyStatus.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

      switch (result.status) {
        case TaskStatus.complete:
          modApplyStatus.value = appText.fileDownloadSuccessful;
          return File(saveLocation + p.separator + p.basenameWithoutExtension(networkFilePath));
        default:
          modApplyStatus.value = appText.fileDownloadFailed;
          return File('');
      }
    }
  }

  return File('');
}
