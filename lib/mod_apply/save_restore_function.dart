import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';

Future<bool> saveRestoreAllAppliedMods() async {
  bool result = false;
  for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items.where((e) => e.applyStatus)) {
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            for (var appliedModFile in submod.modFiles.where((e) => e.applyStatus)) {
              for (var path in appliedModFile.ogLocations) {
                await File(path).copy(path.replaceFirst(pso2DataDirPath, savedAppliedModFileDirPath));
                if (!result) result = true;
              }
            }
          }
        }
      }
    }
  }
  return result;
}
