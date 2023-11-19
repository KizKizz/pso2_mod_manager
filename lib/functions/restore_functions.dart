import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/applied_files_check.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

bool multipleModFilesCheck(List<CategoryType> appliedList, ModFile modFile) {
  for (var cateType in appliedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
            if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location != modFile.location) {
              return true;
            }
          }
        }
      }
    }
  }
  return false;
}

Future<List<ModFile>> restoreOriginalFilesFromServers(context, List<ModFile> modFiles) async {
  List<String> dataPathsToDownload = [];
  for (var modFile in modFiles) {
    for (var originalFilePath in modFile.ogLocations) {
      dataPathsToDownload.add(originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim());
    }
  }

  final restoredFiles = await downloadIceFromOfficial(dataPathsToDownload);

  for (var modFile in modFiles) {
    final pathsToRemove = restoredFiles.where((element) => element.contains(modFile.modFileName));
    modFile.ogLocations.removeWhere((element) => pathsToRemove.contains(element.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim()));
    modFile.bkLocations.removeWhere((element) => pathsToRemove.contains(element.replaceFirst(Uri.file('$modManBackupsDirPath/').toFilePath(), '').trim()) && !multipleModFilesCheck(appliedItemList, modFile));
  }
}
