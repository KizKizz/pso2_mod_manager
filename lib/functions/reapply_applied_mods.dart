import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';

Future<List<String>> reapplyAppliedMods(context) async {
  List<String> reappliedFileNames = [];
  for (var cateType in appliedItemList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        if (item.applyStatus) {
          for (var mod in item.mods) {
            if (mod.applyStatus) {
              for (var submod in mod.submods) {
                if (submod.applyStatus) {
                  for (var modFile in submod.modFiles) {
                    if (modFile.applyStatus) {
                      //print('${modFile.category} > ${modFile.itemName} > ${modFile.modName} > ${modFile.submodName} > ${modFile.modFileName}');
                      await modFileApply(context, modFile);
                      String reappliedString = '${item.itemName} > ${mod.modName} > ${submod.submodName}';
                      if (!reappliedFileNames.contains(reappliedString)) {
                        reappliedFileNames.add(reappliedString);
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
  return ['${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyAppliedAllModsIn}\n${reappliedFileNames.join('\n')}'];
}
