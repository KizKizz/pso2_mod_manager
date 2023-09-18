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

void clearAllTempDirsBeforeGettingPath() {
  if (Directory(Uri.file('${Directory.current.path}/temp').toFilePath()).existsSync()) {
    Directory(Uri.file('${Directory.current.path}/temp').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(Uri.file('${Directory.current.path}/unpack').toFilePath()).existsSync()) {
    Directory(Uri.file('${Directory.current.path}/unpack').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(Uri.file('${Directory.current.path}/modsAdder').toFilePath()).existsSync()) {
    Directory(Uri.file('${Directory.current.path}/modsAdder').toFilePath()).deleteSync(recursive: true);
    //   Directory(Uri.file('${Directory.current.path}/modsAdder').toFilePath()).listSync(recursive: false).forEach((element) {
    //   if (element.existsSync()) {
    //     element.deleteSync(recursive: true);
    //   }
    // });
  }
  if (Directory(Uri.file('${Directory.current.path}/swapper').toFilePath()).existsSync()) {
    Directory(Uri.file('${Directory.current.path}/swapper').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
}
