import 'dart:io';

import 'package:pso2_mod_manager/aqmInjection/aqm_inject.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<bool> aqmInjectionOnModsApply(context, SubMod curSubmod) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  if (curSubmod.category == defaultCategoryDirs[1] ||
      curSubmod.category == defaultCategoryDirs[16]) {
    
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
    isAqmInjecting = false;
    isAqmInjectDuringApply = true;
    await modAqmInjectionHomePage(context, curSubmod);
    isAqmInjectDuringApply = false;
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
    return true;
  }
  return false;
}
