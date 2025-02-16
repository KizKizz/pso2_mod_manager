import 'dart:io';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_popup.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bounding_radius_popup.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_apply/duplicate_popups.dart';
import 'package:pso2_mod_manager/mod_apply/unapply_functions.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/item_icon_mark.dart';
import 'package:pso2_mod_manager/v3_functions/modified_ice_file_save.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';

Future<void> modToGameData(context, bool applying, Item item, Mod mod, SubMod submod) async {
  applying ? modPopupStatus.value = 'Applying files from "${submod.submodName}" to the game' : modPopupStatus.value = 'Removing files from "${submod.submodName}" to the game';
  if (applying) {
    await modApplySequence(context, applying, item, mod, submod);
    submod.applyStatus ? applySuccessNotification(submod.submodName) : applyFailedNotification(submod.submodName);
  } else {
    await modUnapplySequence(context, applying, item, mod, submod, []);
    !submod.applyStatus ? restoreSuccessNotification(submod.submodName) : restoreFailedNotification(submod.submodName);
  }
  modPopupStatus.value = 'Done!';
}

Future<void> modApplySequence(context, bool applying, Item item, Mod mod, SubMod submod) async {
  bool performApply = true;

  // Paste checksum
  await checksumToGameData();

  // Checking for duplicates in Aqm Inject
  AqmInjectedItem? dupAqmItem = duplicateAqmInjectedFilesCheck(submod);

  if (dupAqmItem != null) {
    performApply = await duplicateAqmInjectedFilesPopup(context, dupAqmItem);
    if (performApply) {
      bool result = await aqmInjectPopup(context, dupAqmItem.injectedAQMFilePath!, dupAqmItem.hqIcePath, dupAqmItem.lqIcePath, dupAqmItem.getName(), false, false, true, dupAqmItem.isAqmReplaced!, false);
      if (result) masterAqmInjectedItemList.remove(dupAqmItem);
      saveMasterAqmInjectListToJson();
    } else {
      return;
    }
  }

  // Checking for duplicates in applied
  Item? dupItem;
  Mod? dupMod;
  SubMod? dupSubmod;
  (dupItem, dupMod, dupSubmod) = duplicateAppliedModCheck(submod);

  if (dupItem != null && dupMod != null && dupSubmod != null) {
    List<ModFile> modFilesToRestore = [];
    (performApply, modFilesToRestore) = await duplicateAppliedModPopup(context, dupItem, dupMod, dupSubmod, submod);
    if (performApply) {
      await modUnapplySequence(context, false, dupItem, dupMod, dupSubmod, modFilesToRestore);
    } else {
      return;
    }
  }

  // Apply mod files to game
  if (performApply) {
    // Remove bounding radius
    if (autoBoundingRadiusRemoval && boundingRadiusCategoryDirs.contains(submod.category)) {
      await boundingRadiusPopup(context, submod);
      submod.boundingRemoved = true;
    }

    await applyingPopup(context, applying, item, mod, submod, []);
  }
}

Future<void> modBackupApply(Item item, Mod mod, SubMod submod, List<ModFile> modFilesToApply) async {
  for (var modFile in modFilesToApply.isEmpty ? submod.modFiles : modFilesToApply) {
    List<OfficialIceFile> oDataList = oItemData.where((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName).toList();
    oDataList.addAll(oItemDataNA.where((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName).toList());

    for (var oData in oDataList) {
      final oDataPaths = p.split(oData.path.replaceAll('/', p.separator));
      if (submod.applyLocations!.isEmpty || submod.applyLocations!.contains(oDataPaths[1])) {
        // Backup
        await modFileLocalBackup(modFile, oData);
        // Apply
        await modApply(item, mod, submod, modFile, oData);

        await Future.delayed(const Duration(microseconds: 10));
      }
    }
  }

  // Mark item icon
  if (markIconCategoryDirs.contains(item.category)) {
  if (replaceItemIconOnApplied && item.applyStatus && !item.isOverlayedIconApplied!) {
    await markedItemIconApply(item);
  } else if (replaceItemIconOnApplied && item.applyStatus && item.overlayedIconPath!.isNotEmpty && await File(item.overlayedIconPath!).getMd5Hash() != await File(item.iconPath!).getMd5Hash()) {
    await markedItemIconApply(item);
  }}

  saveMasterModListToJson();
}

Future<void> modFileLocalBackup(ModFile modFile, OfficialIceFile oData) async {
  if (oData.path.replaceAll('/', p.separator).isNotEmpty) {
    modApplyStatus.value = appText.dText(appText.creatingBackupForModFile, modFile.modFileName);
    final oFile = File(pso2binDirPath + p.separator + p.withoutExtension(oData.path.replaceAll('/', p.separator)));
    if (await oFile.exists()) {
      final backupFilePath = oFile.path.replaceFirst(pso2DataDirPath, backupDirPath);
      if (!File(backupFilePath).existsSync()) {
        await Directory(p.dirname(backupFilePath)).create(recursive: true);
        final backedFile = await oFile.copy(backupFilePath);
        if (backedFile.existsSync()) modFile.bkLocations.add(backedFile.path);
        modApplyStatus.value = appText.backupSuccess;
      }
    }
  } else {
    modApplyStatus.value = appText.failed;
  }
}

Future<void> modApply(Item item, Mod mod, SubMod submod, ModFile modFile, OfficialIceFile oData) async {
  File file = File(modFile.location);
  if (file.existsSync()) {
    if (oData.path.replaceAll('/', p.separator).isNotEmpty) {
      modApplyStatus.value = appText.dText(appText.copyingModFileToGameData, modFile.modFileName);
      String gameDataFilePath = pso2binDirPath + p.separator + p.withoutExtension(oData.path.replaceAll('/', p.separator));
      await Directory(p.dirname(gameDataFilePath)).create(recursive: true);
      final copiedFile = await file.copy(gameDataFilePath);
      if (!modFile.ogLocations.contains(copiedFile.path)) modFile.ogLocations.add(copiedFile.path);
    } else {
      final oFilePath = Directory(pso2DataDirPath)
          .listSync(recursive: true)
          .whereType<File>()
          .firstWhere(
            (e) => p.extension(e.path) == '' && p.basename(e.path) == modFile.modFileName,
            orElse: () => File(''),
          )
          .path;
      if (oFilePath.isNotEmpty) {
        modApplyStatus.value = appText.dText(appText.copyingModFileToGameData, modFile.modFileName);
        String gameDataFilePath = pso2binDirPath + p.separator + p.withoutExtension(oData.path.replaceAll('/', p.separator));
        await Directory(p.dirname(gameDataFilePath)).create(recursive: true);
        final copiedFile = await file.copy(gameDataFilePath);
        if (!modFile.ogLocations.contains(copiedFile.path)) modFile.ogLocations.add(copiedFile.path);
      }
    }
    if (modFile.ogLocations.isNotEmpty) {
      modApplyStatus.value = appText.successful;
      final appliedDate = DateTime.now();
      modFile.applyStatus = true;
      modFile.md5 = await modFile.getMd5Hash();
      modFile.applyDate = appliedDate;
      modFile.isNew = false;
      modifiedIceAdd(modFile.modFileName);

      submod.applyStatus = true;
      submod.applyDate = appliedDate;
      submod.isNew = false;

      mod.applyStatus = true;
      mod.applyDate = appliedDate;
      mod.isNew = false;

      item.applyStatus = true;
      item.applyDate = appliedDate;
      item.isNew = false;
    }
  }
}

(Item?, Mod?, SubMod?) duplicateAppliedModCheck(SubMod newSubmod) {
  for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items.where((e) => e.applyStatus)) {
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            if (submod.getModFileNames().where((e) => newSubmod.getModFileNames().contains(e)).isNotEmpty) {
              return (item, mod, submod);
            }
          }
        }
      }
    }
  }

  return (null, null, null);
}

AqmInjectedItem? duplicateAqmInjectedFilesCheck(SubMod newSubmod) {
  for (var item in masterAqmInjectedItemList) {
    if (newSubmod.getModFileNames().contains(p.basenameWithoutExtension(item.hqIcePath)) || newSubmod.getModFileNames().contains(p.basenameWithoutExtension(item.lqIcePath))) {
      return item;
    }
  }
  return null;
}
