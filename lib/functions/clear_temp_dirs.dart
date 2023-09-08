import 'dart:io';

import 'package:pso2_mod_manager/loaders/paths_loader.dart';

void clearAllTempDirs() {
  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  Directory(modManModsAdderPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  Directory(modManSwapperDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
}
