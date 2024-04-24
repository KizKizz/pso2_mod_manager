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
  if (Directory(modManTempCmxDirPath).existsSync()) {
    Directory(modManTempCmxDirPath).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(modManImportedDirPath).existsSync()) {
    Directory(modManImportedDirPath).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
}

Future<void> clearAllTempDirsBeforeGettingPath() async {
  if (await Directory(Uri.file('$modManDirPath/temp').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/temp').toFilePath()).delete(recursive: true);
  if (await Directory(Uri.file('$modManDirPath/unpack').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/unpack').toFilePath()).delete(recursive: true);
  if (await Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).delete(recursive: true);
  if (await Directory(Uri.file('$modManDirPath/swapper').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/swapper').toFilePath()).delete(recursive: true);
  if (await Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).delete(recursive: true);
  if (await Directory(Uri.file('$modManDirPath/exported').toFilePath()).exists()) await Directory(Uri.file('$modManDirPath/exported').toFilePath()).delete(recursive: true);
}

void clearAppUpdateFolder() {
  String appUpdatePath = Uri.file('${Directory.current.path}/appUpdate').toFilePath();
  if (Directory(appUpdatePath).existsSync()) {
    Directory(appUpdatePath).deleteSync(recursive: true);
  }
}
