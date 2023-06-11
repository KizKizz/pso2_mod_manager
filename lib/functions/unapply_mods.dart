import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<ModFile> modFileUnapply(ModFile modFile) async {
  for (var bkPath in modFile.bkLocations) {
    final ogPath = bkPath.replaceFirst(modManBackupsDirPath, Uri.file('$modManPso2binPath/data').toFilePath());
    //restore
    File(bkPath).copySync(ogPath);
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
      File(bkPath).deleteSync(recursive: true);
    }
  }
  return modFile;
}
