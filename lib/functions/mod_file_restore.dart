import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/unapply_mods.dart';

Future<ModFile?> modFileRestore(List<CategoryType> moddedList, ModFile modFile) async {
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
            if (modFileIndex != -1 && submod.modFiles[modFileIndex] != modFile) {
              //submod.modFiles[modFileIndex].applyStatus = false;
              //submod.modFiles[modFileIndex] = await modFileUnapply(submod.modFiles[modFileIndex]);
              return modFile;
            }
            if (submod.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
              submod.applyStatus = false;
            }
          }
          if (mod.submods.indexWhere((element) => element.applyStatus == true) == -1) {
            mod.applyStatus = false;
          }
        }
        if (item.mods.indexWhere((element) => element.applyStatus == true) == -1) {
          item.applyStatus = false;
        }
      }
    }
  }
  return null;
}
