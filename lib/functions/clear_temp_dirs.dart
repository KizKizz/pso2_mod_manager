import 'dart:io';

import 'package:pso2_mod_manager/loaders/paths_loader.dart';

void clearAllTempDirs() {
  if (Directory(modManAddModsTempDirPath).existsSync()) {
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  }
  if (Directory(modManAddModsUnpackDirPath).existsSync()) {
    Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  }
  if (Directory(modManModsAdderPath).existsSync()) {
    Directory(modManModsAdderPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  }
  if (Directory(modManSwapperDirPath).existsSync()) {
    Directory(modManSwapperDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });
  }
}
