import 'dart:io';

import 'package:pso2_mod_manager/boundary/mods_boundary_edit.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<bool> removeBoundaryOnModsApply(context, SubMod curSubmod) async {
  if (curSubmod.category == defaultCateforyDirs[1] ||
      curSubmod.category == defaultCateforyDirs[3] ||
      curSubmod.category == defaultCateforyDirs[4] ||
      curSubmod.category == defaultCateforyDirs[5] ||
      curSubmod.category == defaultCateforyDirs[15] ||
      curSubmod.category == defaultCateforyDirs[16]) {
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
