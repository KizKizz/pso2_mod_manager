import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/export_import/mod_export_popup.dart';
import 'package:pso2_mod_manager/export_import/new_export_name_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Signal<String> exportStatus = Signal('');

enum ExportType { item, mods, submods }

Future<void> modExportSequence(context, ExportType exportType, String categoryName, Item item, List<Mod> mods, List<SubMod> submods) async {
  String exportFileName = await exportModNamePopup(context);
  if (exportFileName.isNotEmpty) {
    exportStatus.value = '';
    await modExportPopup(context, exportType, exportFileName, categoryName, item, mods, submods);
  }
}

Future<File?> itemExportFunction(String exportFileName, String categoryName, Item item) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;

  exportStatus.value = appText.dText(appText.exportingFile, item.itemName);

  String subPath = exportedPath + p.separator + categoryName + p.separator + p.basenameWithoutExtension(item.location);

  await io.copyPath(item.location, subPath);

  if (Directory(exportedPath).existsSync()) {
    //zip
    var encoder = ZipFileEncoder();
    await encoder.zipDirectory(Directory(exportedPath));
    String zipFilePath = '$exportedPath.zip';
    if (File(zipFilePath).existsSync()) {
      Directory(exportedPath).deleteSync(recursive: true);
      File renamedFile = await File(zipFilePath).rename('${p.withoutExtension(zipFilePath)}.pmm');
      return renamedFile;
    }
  }

  return null;
}

Future<File?> modExportFunction(String exportFileName, String categoryName, Item item, List<Mod> mods) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;
  for (var mod in mods) {
    exportStatus.value = appText.dText(appText.exportingFile, mod.modName);
    String subPath = exportedPath + p.separator + categoryName + p.separator + p.basenameWithoutExtension(item.location) + p.separator + p.basenameWithoutExtension(mod.location);

    await io.copyPath(mod.location, subPath);
  }

  if (Directory(exportedPath).existsSync()) {
    //zip
    var encoder = ZipFileEncoder();
    await encoder.zipDirectory(Directory(exportedPath));
    String zipFilePath = '$exportedPath.zip';
    if (File(zipFilePath).existsSync()) {
      Directory(exportedPath).deleteSync(recursive: true);
      File renamedFile = await File(zipFilePath).rename('${p.withoutExtension(zipFilePath)}.pmm');
      return renamedFile;
    }
  }

  return null;
}

Future<File?> submodExportFunction(String exportFileName, String categoryName, Item item, Mod mod, List<SubMod> submods) async {
  String exportedPath = exportedModsDirPath + p.separator + exportFileName;
  for (var submod in submods) {
    exportStatus.value = appText.dText(appText.exportingFile, submod.submodName);
    String subPath = exportedPath +
        p.separator +
        categoryName +
        p.separator +
        p.basenameWithoutExtension(item.location) +
        p.separator +
        p.basenameWithoutExtension(mod.location) +
        p.separator +
        p.basenameWithoutExtension(submod.location);

    await io.copyPath(submod.location, subPath);
  }

  if (Directory(exportedPath).existsSync()) {
    //zip
    var encoder = ZipFileEncoder();
    await encoder.zipDirectory(Directory(exportedPath));
    String zipFilePath = '$exportedPath.zip';
    if (File(zipFilePath).existsSync()) {
      Directory(exportedPath).deleteSync(recursive: true);
      File renamedFile = await File(zipFilePath).rename('${p.withoutExtension(zipFilePath)}.pmm');
      return renamedFile;
    }
  }

  return null;
}
