import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';

Future<ModFile?> modFileAppliedDupRestore(List<CategoryType> moddedList, ModFile modFile) async {
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
            if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location == modFile.location) {
              //submod.modFiles[modFileIndex].applyStatus = false;
              //removed for downloading backup
              //submod.modFiles[modFileIndex] = await modFileUnapply(submod.modFiles[modFileIndex]);
              submod.modFiles[modFileIndex].applyStatus = false;
              submod.modFiles[modFileIndex].ogMd5s.clear();
              submod.modFiles[modFileIndex].bkLocations.clear();
              submod.modFiles[modFileIndex].ogLocations.clear();
              submod.modFiles[modFileIndex].applyDate = DateTime(0);
              if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                submod.applyStatus = false;
              }
              if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                mod.applyStatus = false;
              }
              if (item.mods.indexWhere((element) => element.applyStatus) == -1) {
                item.applyStatus = false;
              }
              return submod.modFiles[modFileIndex];
            }
          }
        }
      }
    }
  }
  return null;
}

Future<ModFile?> modFileAppliedDupCheck(List<CategoryType> moddedList, ModFile modFile) async {
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
            if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location != modFile.location) {
              //submod.modFiles[modFileIndex].applyStatus = false;
              //submod.modFiles[modFileIndex] = await modFileUnapply(submod.modFiles[modFileIndex]);
              return submod.modFiles[modFileIndex];
            }
          }
        }
      }
    }
  }
  return null;
}
