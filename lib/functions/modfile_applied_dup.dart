import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/classes/aqm_item_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/global_variables.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/loaders/language_loader.dart';

Future<ModFile?> modFileAppliedDupRestore(context, List<CategoryType> modList, ModFile modFile) async {
  for (var cateType in modList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items) {
        if (item.applyStatus) {
          for (var mod in item.mods) {
            if (mod.applyStatus) {
              for (var submod in mod.submods) {
                if (submod.applyStatus) {
                  int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
                  if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location == modFile.location) {
                    submod.modFiles[modFileIndex].applyStatus = false;
                    //removed for downloading backups from sega
                    //restoreOriginalFilesToTheGame(context, [submod.modFiles[modFileIndex]]);
                    submod.modFiles[modFileIndex].applyStatus = false;
                    submod.modFiles[modFileIndex].ogMd5s.clear();
                    submod.modFiles[modFileIndex].bkLocations.clear();
                    submod.modFiles[modFileIndex].ogLocations.clear();
                    submod.modFiles[modFileIndex].applyDate = DateTime(0);
                    if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                      submod.applyStatus = false;
                      if (submod.cmxApplied!) {
                        bool status = await cmxModRemoval(submod.cmxStartPos!, submod.cmxEndPos!);
                        if (status) {
                          submod.cmxApplied = false;
                          submod.cmxStartPos = -1;
                          submod.cmxEndPos = -1;
                        }
                      }
                      if (autoAqmInject) await aqmInjectionOnModsApply(context, submod);
                    }
                    if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                      mod.applyStatus = false;
                    }
                    if (item.mods.indexWhere((element) => element.applyStatus) == -1) {
                      item.applyStatus = false;
                      if (item.backupIconPath!.isNotEmpty) {
                        await restoreOverlayedIcon(item);
                      }
                    }
                    return submod.modFiles[modFileIndex];
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return null;
}

Future<ModFile?> modFileAppliedDupCheck(List<CategoryType> modList, ModFile modFile) async {
  for (var cateType in modList.where((e) => e.getNumOfAppliedCates() > 0)) {
    for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
      for (var item in cate.items) {
        if (item.applyStatus) {
          for (var mod in item.mods) {
            if (mod.applyStatus) {
              for (var submod in mod.submods) {
                if (submod.applyStatus) {
                  int modFileIndex = submod.modFiles.indexWhere((element) => element.modFileName == modFile.modFileName);
                  if (modFileIndex != -1 && submod.modFiles[modFileIndex].applyStatus && submod.modFiles[modFileIndex].location != modFile.location) {
                    //submod.modFiles[modFileIndex].applyStatus = false;
                    //submod.modFiles[modFileIndex] = await modFileUnapply(submod.modFiles[modFileIndex]);
                    if (modFile.applyLocations!.isEmpty) {
                      return submod.modFiles[modFileIndex];
                    } else {
                      if (submod.modFiles[modFileIndex].applyLocations!.isNotEmpty) {
                        for (var path in modFile.applyLocations!) {
                          if (submod.modFiles[modFileIndex].applyLocations!.contains(path)) {
                            return submod.modFiles[modFileIndex];
                          }
                        }
                      } else {
                        return submod.modFiles[modFileIndex];
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
  return null;
}

Future<ModFile?> modFileAqmReplacementCheck(List<AqmItem> aqmItemList, ModFile modFile) async {
  for (var item in aqmItemList) {
    ModFile tempModFile = ModFile('', item.adjustedId, item.id, modManCurActiveItemNameLanguage == 'JP' ? item.itemNameJP : item.itemNameEN, curLangText!.uiCustomAqmInjection, '', [], '', true, DateTime(0), 0, false,
        false, false, [], [], [], [], [], []);
    if (modFile.modFileName == p.basenameWithoutExtension(item.hqIcePath)) {
      tempModFile.modFileName = p.basenameWithoutExtension(item.hqIcePath);
      tempModFile.applyLocations!.add(item.hqIcePath);
      tempModFile.ogLocations.add(item.hqIcePath);
      return tempModFile;
    } else if (modFile.modFileName == p.basenameWithoutExtension(item.lqIcePath)) {
      tempModFile.modFileName = p.basenameWithoutExtension(item.lqIcePath);
      tempModFile.applyLocations!.add(item.lqIcePath);
      tempModFile.ogLocations.add(item.lqIcePath);
      return tempModFile;
    }
  }
  return null;
}
