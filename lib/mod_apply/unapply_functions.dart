import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
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

Future<void> modUnapplySequence(context, bool applying, Item item, Mod mod, SubMod submod, List<ModFile> modFilesToRestore) async {
  await applyingPopup(context, applying, item, mod, submod, modFilesToRestore);
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
      if (modFile.applyStatus) {
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

  if (!item.applyStatus && item.isOverlayedIconApplied!) {
    bool result = await markedItemIconRestore(item);
    if (result) {
      item.isOverlayedIconApplied = false;
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
      if (await copiedFile.getMd5Hash() != modFile.md5) {
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
}

Future<void> restoreFromSegaServers(Item item, Mod mod, SubMod submod, ModFile modFile) async {
  final oDatas = oItemData.where((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName);
  for (var oData in oDatas) {
    if (oData.path.replaceAll('/', p.separator).isNotEmpty) {
      final downloadedFile = await restoreOriginalFileDownload(oData.path, oData.server, p.dirname(pso2binDirPath + p.separator + oData.path.replaceAll('/', p.separator)));
      if (downloadedFile.path.isNotEmpty && downloadedFile.existsSync()) {
        modApplyStatus.value = appText.dText(appText.restoringBackupFileToGameData, modFile.modFileName);
        if (await File(backupDirPath + p.separator + p.withoutExtension(oData.path).replaceAll('/', p.separator)).exists()) {
          await File(backupDirPath + p.separator + p.withoutExtension(oData.path).replaceAll('/', p.separator)).delete(recursive: true);
          modFile.bkLocations.remove(backupDirPath + p.separator + p.withoutExtension(oData.path).replaceAll('/', p.separator));
        }
        modFile.ogLocations.removeWhere((e) => e == downloadedFile.path);
        modFile.applyStatus = false;
        modApplyStatus.value = appText.successful;
      }
    }
  }

  if (!modFile.applyStatus) {
    if (!submod.getModFilesAppliedState()) submod.applyStatus = false;
    if (!mod.getSubmodsAppliedState()) mod.applyStatus = false;
    if (!item.getModsAppliedState()) item.applyStatus = false;
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
          retries: 0,
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
      }
    }
  }

  return File('');
}
