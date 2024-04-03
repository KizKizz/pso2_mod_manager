import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<void> modExport(List<CategoryType> baseList, SubMod exportSubmod) async {
  modManExportedDirPath = Uri.file('$modManDirPath/exported').toFilePath();
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
  String rootExportDir = '$modManExportedDirPath/PSO2NGSExportedMods_$formattedDate';
  await Directory(rootExportDir).create(recursive: true);
  for (var type in baseList) {
    for (var cate in type.categories) {
      if (cate.categoryName == exportSubmod.category && exportSubmod.location.contains(cate.location)) {
        for (var item in cate.items) {
          if (item.itemName == exportSubmod.itemName && exportSubmod.location.contains(item.location)) {
            for (var mod in item.mods) {
              if (mod.modName == exportSubmod.modName && exportSubmod.location.contains(mod.location)) {
                Directory expCateDir = Directory(cate.location.replaceFirst(modManModsDirPath, rootExportDir));
                expCateDir.createSync(recursive: true);
                Directory expItemDir = Directory(item.location.replaceFirst(modManModsDirPath, rootExportDir));
                expItemDir.createSync(recursive: true);
                Directory expModDir = Directory(mod.location.replaceFirst(modManModsDirPath, rootExportDir));
                expModDir.createSync(recursive: true);
                Directory expSubmodDir = Directory(exportSubmod.location.replaceFirst(modManModsDirPath, rootExportDir));
                expSubmodDir.createSync(recursive: true);
                for (var modFile in exportSubmod.modFiles) {
                  await File(modFile.location).copy(modFile.location.replaceFirst(modManModsDirPath, rootExportDir));
                }
                //previews for submod
                for (var filePath in exportSubmod.previewImages) {
                  await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                }
                for (var filePath in exportSubmod.previewVideos) {
                  await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                }
                //previews file for mod
                for (var filePath in mod.previewImages.where((element) => File(element).parent.path == mod.location)) {
                  await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                }
                for (var filePath in mod.previewVideos.where((element) => File(element).parent.path == mod.location)) {
                  await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                }
              }
            }
            for (var iconPath in item.icons) {
              await File(iconPath).copy(iconPath.replaceFirst(modManModsDirPath, rootExportDir));
            }
          }
        }
      }
    }
  }
  //zip
  var encoder = ZipFileEncoder();
  await encoder.zipDirectoryAsync(Directory(rootExportDir));
  Directory(rootExportDir).deleteSync(recursive: true);
}
