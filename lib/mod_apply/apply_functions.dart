import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/shared_prefs.dart';

void modApplySequence(Item item, Mod mod, SubMod submod, ModFile modFile) {
  final oData = oItemData.firstWhere((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName, orElse: () => OfficialIceFile.empty());

  // Backup
  modFileLocalBackup(modFile, oData);
  // Apply
  modApply(item, mod, submod, modFile, oData);
}

Future<void> modFileLocalBackup(ModFile modFile, OfficialIceFile oData) async {
  // Look for path in oFileData
  // final oData = oItemData.firstWhere((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName, orElse: () => OfficialIceFile.empty());
  if (oData.path.isNotEmpty) {
    final oFile = File(pso2binDirPath + p.separator + p.withoutExtension(oData.path));
    if (await oFile.exists()) {
      final backupFilePath = oFile.path.replaceFirst(pso2DataDirPath, backupDirPath);
      await Directory(p.dirname(backupFilePath)).create(recursive: true);
      final backedFile = await oFile.copy(backupFilePath);
      if (backedFile.existsSync()) modFile.bkLocations.add(backedFile.path);
    }
  }
}

Future<void> modApply(Item item, Mod mod, SubMod submod, ModFile modFile, OfficialIceFile oData) async {
  File file = File(modFile.location);
  if (file.existsSync()) {
    if (oData.path.isNotEmpty) {
      final copiedFile = await file.copy(pso2binDirPath + p.separator + p.withoutExtension(oData.path));
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
        final copiedFile = await file.copy(pso2binDirPath + p.separator + p.withoutExtension(oData.path));
        modFile.ogLocations.add(copiedFile.path);
      }
    }
    if (modFile.ogLocations.isNotEmpty) {
      final appliedDate = DateTime.now();
      modFile.applyStatus = true;
      modFile.md5 = await modFile.getMd5Hash();
      modFile.applyDate = appliedDate;

      submod.applyStatus = true;
      submod.applyDate = appliedDate;

      mod.applyStatus = true;
      mod.applyDate = appliedDate;

      item.applyStatus = true;
      item.applyDate = appliedDate;
    }
  }
}
