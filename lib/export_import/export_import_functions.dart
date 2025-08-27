import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/export_import/mod_export_popup.dart';
import 'package:pso2_mod_manager/export_import/new_export_name_popup.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Signal<String> exportStatus = Signal('');

enum ExportType { item, mods, submods, applied, modsets }

Future<void> modExportSequence(context, ExportType exportType, Item? item, Mod? mod, SubMod? submod, ModSet? modSet) async {
  String exportFileName = await exportModNamePopup(context);
  if (exportFileName.isNotEmpty) {
    exportStatus.value = '';
    await modExportPopup(context, exportType, exportFileName, item, mod, submod, modSet);
  }
}

Future<File?> appliedModsExportFunction(String exportFileName) async {
  await Future.delayed(Duration(milliseconds: 10));
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;

  for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items.where((e) => e.applyStatus)) {
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            exportStatus.value = appText.dText(appText.exportingFile, '${submod.itemName} > ${submod.modName} > ${submod.submodName}');
            String subPath = exportedPath + p.separator + p.basenameWithoutExtension(mod.location) + p.separator + p.basenameWithoutExtension(submod.location);
            await io.copyPath(submod.location, subPath);
            await Future.delayed(Duration(milliseconds: 1));
          }
        }
      }
    }
  }

  return await zipExportedDir(exportedPath);
}

Future<File?> modSetExportFunction(String exportFileName, ModSet? modSet) async {
  await Future.delayed(Duration(milliseconds: 10));
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;

  for (var item in modSet!.setItems) {
    for (var mod in item.mods.where((e) => e.setNames.contains(modSet.setName))) {
      for (var submod in mod.submods.where((e) => e.setNames.contains(modSet.setName) && e.activeInSets!.contains(modSet.setName))) {
        exportStatus.value = appText.dText(appText.exportingFile, '${modSet.setName} > ${submod.itemName} > ${submod.modName} > ${submod.submodName}');
        String subPath = exportedPath + p.separator + p.basenameWithoutExtension(mod.location) + p.separator + p.basenameWithoutExtension(submod.location);
        await io.copyPath(submod.location, subPath);
        await Future.delayed(Duration(milliseconds: 1));
      }
    }
  }

  return await zipExportedDir(exportedPath);
}

Future<File?> itemExportFunction(String exportFileName, Item item) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;

  for (var mod in item.mods) {
    exportStatus.value = appText.dText(appText.exportingFile, mod.modName);
    await io.copyPath(mod.location, exportedPath + p.separator + p.basenameWithoutExtension(mod.location));
  }

  return await zipExportedDir(exportedPath);
}

Future<File?> modExportFunction(String exportFileName, Mod? mod) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;
  exportStatus.value = appText.dText(appText.exportingFile, mod!.modName);
  await io.copyPath(mod.location, exportedPath + p.separator + p.basenameWithoutExtension(mod.location));

  return await zipExportedDir(exportedPath);
}

Future<File?> submodExportFunction(String exportFileName, Mod? mod, SubMod? submod) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;

  exportStatus.value = appText.dText(appText.exportingFile, submod!.submodName);
  String subPath = exportedPath + p.separator + p.basenameWithoutExtension(mod!.location) + p.separator + p.basenameWithoutExtension(submod.location);

  await io.copyPath(submod.location, subPath);

  return await zipExportedDir(exportedPath);
}

Future<File?> zipExportedDir(String exportedPath) async {
  if (Directory(exportedPath).existsSync()) {
    //zip
    var encoder = ZipFileEncoder();
    await encoder.zipDirectory(Directory(exportedPath));
    String zipFilePath = '$exportedPath.zip';
    if (File(zipFilePath).existsSync()) {
      Directory(exportedPath).deleteSync(recursive: true);
      File renamedFile = await File(zipFilePath).rename('${p.withoutExtension(zipFilePath)}.pmm');
      if (await renamedFile.exists()) return renamedFile;
    }
  }

  return null;
}
