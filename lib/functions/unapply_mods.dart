import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<ModFile> modFileUnapply(ModFile modFile) async {
  for (var bkPath in modFile.bkLocations) {
    //final ogPath = bkPath.replaceFirst(modManBackupsDirPath, Uri.file('$modManPso2binPath/data').toFilePath());
    final ogPathInModFile = modFile.ogLocations.firstWhere(
      (element) => element.contains(bkPath.replaceFirst(modManBackupsDirPath, '')),
      orElse: () => '',
    );
    if (ogPathInModFile.isNotEmpty) {
      //restore
      await File(bkPath).copy(ogPathInModFile);
    } else {
      final ogPath = bkPath.replaceFirst(modManBackupsDirPath, Uri.file('$modManPso2binPath/data').toFilePath());
      //restore
      await File(bkPath).copy(ogPath);
    }

    //remove bk if no file needs it
    List<String> dontRemoveList = [];
    for (var type in appliedItemList) {
      for (var cate in type.categories) {
        for (var item in cate.items) {
          if (item.applyStatus == true) {
            for (var mod in item.mods) {
              if (mod.applyStatus == true) {
                for (var submod in mod.submods) {
                  if (submod.applyStatus == true) {
                    for (var appliedModFile in submod.modFiles) {
                      if (appliedModFile.applyStatus == true) {
                        if (appliedModFile.bkLocations.contains(bkPath) && appliedModFile.location != modFile.location) {
                          dontRemoveList.add(bkPath);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    if (!dontRemoveList.contains(bkPath)) {
      File(bkPath).deleteSync(recursive: false);
    }
  }
  return modFile;
}
