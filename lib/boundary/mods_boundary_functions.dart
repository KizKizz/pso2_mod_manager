import 'dart:io';

import 'package:pso2_mod_manager/boundary/mods_boundary_edit.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<bool> removeBoundaryOnModsApply(context, SubMod curSubmod) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  if (curSubmod.category == defaultCategoryDirs[1] ||
      curSubmod.category == defaultCategoryDirs[3] ||
      curSubmod.category == defaultCategoryDirs[4] ||
      curSubmod.category == defaultCategoryDirs[5] ||
      curSubmod.category == defaultCategoryDirs[15] ||
      curSubmod.category == defaultCategoryDirs[16]) {
    
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
    isBoundaryEdited = false;
    isBoundaryEditDuringApply = true;
    await modsBoundaryEditHomePage(context, curSubmod);
    isBoundaryEditDuringApply = false;
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
    return true;
  }
  return false;
}
