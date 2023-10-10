import 'dart:io';

import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';

Future<List<ModFile>> appliedFileCheck(List<CategoryType> appliedList) async {
  List<ModFile> filesToApplyAndBackup = [];
  List<ModFile> filesToApplyOnly = [];
  for (var cateType in appliedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        if (item.applyStatus) {
          for (var mod in item.mods) {
            if (mod.applyStatus) {
              for (var submod in mod.submods) {
                if (submod.applyStatus) {
                  for (var modFile in submod.modFiles) {
                    if (modFile.applyStatus) {
                      String modFileMD5 = modFile.md5;
                      final ogFileMD5 = modFile.ogMd5s.toList();
                      //compare data files with modded file
                      for (var ogPath in modFile.ogLocations) {
                        String curDataMD5 = await getFileHash(ogPath);
                        if (curDataMD5 != modFileMD5) {
                          if (ogFileMD5.isEmpty || ogFileMD5.length != modFile.ogLocations.length) {
                            // String newOGMD5 = await getFileHash(ogPath);
                            // if (!modFile.ogMd5s.contains(newOGMD5)) {
                            //   modFile.ogMd5s.add(newOGMD5);
                            // }
                            //reapply with backup
                            filesToApplyAndBackup.add(modFile);
                          } else if (curDataMD5 != ogFileMD5[modFile.ogLocations.indexOf(ogPath)]) {
                            //reapply with backup
                            filesToApplyAndBackup.add(modFile);
                          } else {
                            //reapply only
                            filesToApplyOnly.add(modFile);
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
    }
  }

  List<ModFile> allReappliedFiles = [];

  for (var modFile in filesToApplyAndBackup) {
    bool replacedStatus = await modFileApply(modFile);
    if (replacedStatus) {
      allReappliedFiles.add(modFile);
    }
  }

  for (var modFile in filesToApplyOnly) {
    for (var ogPath in modFile.ogLocations) {
      File(modFile.location).copySync(ogPath);
    }
    allReappliedFiles.add(modFile);
  }

  return allReappliedFiles;
}
