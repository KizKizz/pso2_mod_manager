import 'dart:io';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_apply/duplicate_popup.dart';
import 'package:pso2_mod_manager/mod_apply/unapply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/shared_prefs.dart';

Future<void> modToGameData(context, bool applying, Item item, Mod mod, SubMod submod) async {
  applying ? await modApplySequence(context, applying, item, mod, submod) : await modUnapplySequence(context, applying, item, mod, submod);
}

Future<void> modApplySequence(context, bool applying, Item item, Mod mod, SubMod submod) async {
  bool performApply = true;
  Item? dupItem;
  Mod? dupMod;
  SubMod? dupSubmod;
  (dupItem, dupMod, dupSubmod) = dublicateAppliedModCheck(submod);

  if (dupItem != null && dupMod != null && dupSubmod != null) {
    performApply = await duplicatePopup(context, dupItem, dupMod, dupSubmod, submod.submodName);
    if (performApply) {
      await modUnapplySequence(context, false, dupItem, dupMod, dupSubmod);
    }
  }

  if (performApply) {
    await applyingPopup(context, applying, item, mod, submod);
  }
}

Future<void> modBackupApply(Item item, Mod mod, SubMod submod) async {
  modApplyStatus.value = '';
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

(Item?, Mod?, SubMod?) dublicateAppliedModCheck(SubMod newSubmod) {
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
