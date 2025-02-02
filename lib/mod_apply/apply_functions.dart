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

Future<void> modToGameData(context, bool applying, Item item, Mod mod, SubMod submod) async {
  applying ? modPopupStatus.value = 'Applying files from "${submod.submodName}" to the game' : modPopupStatus.value = 'Removing files from "${submod.submodName}" to the game';
  applying ? await modApplySequence(context, applying, item, mod, submod) : await modUnapplySequence(context, applying, item, mod, submod);
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
      bool result = await aqmInjectPopup(context, dupAqmItem.hqIcePath, dupAqmItem.lqIcePath, dupAqmItem.getName(), false, false, true, dupAqmItem.isAqmReplaced!, false);
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
    performApply = await duplicateAppliedModPopup(context, dupItem, dupMod, dupSubmod, submod.submodName);
    if (performApply) {
      await modUnapplySequence(context, false, dupItem, dupMod, dupSubmod);
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

    await applyingPopup(context, applying, item, mod, submod);
  }
}

Future<void> modBackupApply(Item item, Mod mod, SubMod submod) async {
  for (var modFile in submod.modFiles) {
    List<OfficialIceFile> oDataList = oItemData.where((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName).toList();
    oDataList.addAll(oItemDataNA.where((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName).toList());

    for (var oData in oDataList) {
      // Backup
      await modFileLocalBackup(modFile, oData);
      // Apply
      await modApply(item, mod, submod, modFile, oData);

      await Future.delayed(const Duration(microseconds: 10));
    }
  }

  // Mark item icon
  if (replaceItemIconOnApplied && item.applyStatus && !item.isOverlayedIconApplied!) {
    await markedItemIconApply(item);
  } else if (replaceItemIconOnApplied && item.applyStatus && item.overlayedIconPath!.isNotEmpty && await File(item.overlayedIconPath!).getMd5Hash() != await File(item.iconPath!).getMd5Hash()) {
    await markedItemIconApply(item);
  }

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
        modApplyStatus.value = appText.successful;
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
      final copiedFile = await file.copy(pso2binDirPath + p.separator + p.withoutExtension(oData.path.replaceAll('/', p.separator)));
      modFile.ogLocations.add(copiedFile.path);
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
        final copiedFile = await file.copy(pso2binDirPath + p.separator + p.withoutExtension(oData.path.replaceAll('/', p.separator)));
        modFile.ogLocations.add(copiedFile.path);
      }
    }
    if (modFile.ogLocations.isNotEmpty) {
      modApplyStatus.value = appText.successful;
      final appliedDate = DateTime.now();
      modFile.applyStatus = true;
      modFile.md5 = await modFile.getMd5Hash();
      modFile.applyDate = appliedDate;
      modFile.isNew = false;

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
