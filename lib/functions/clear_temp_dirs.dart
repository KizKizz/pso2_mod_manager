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

void clearAllTempDirsBeforeGettingPath() {
  if (Directory(Uri.file('$modManDirPath/temp').toFilePath()).existsSync()) {
    Directory(Uri.file('$modManDirPath/temp').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(Uri.file('$modManDirPath/unpack').toFilePath()).existsSync()) {
    // Directory(Uri.file('$modManDirPath/unpack').toFilePath()).listSync(recursive: false).forEach((element) {
    //   if (element.existsSync()) {
    //     element.deleteSync(recursive: true);
    //   }
    // });
    Directory(Uri.file('$modManDirPath/unpack').toFilePath()).deleteSync(recursive: true);
  }
  if (Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).existsSync()) {
    //Directory(Uri.file('${Directory.current.path}/modsAdder').toFilePath()).deleteSync(recursive: true);
    // Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).listSync(recursive: true).whereType<File>().forEach((element) {
    //   if (element.existsSync()) {
    //     element.deleteSync(recursive: true);
    //   }
    // });
    Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).deleteSync(recursive: true);
  }
  if (Directory(Uri.file('$modManDirPath/swapper').toFilePath()).existsSync()) {
    Directory(Uri.file('$modManDirPath/swapper').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).existsSync()) {
    Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
  if (Directory(Uri.file('$modManDirPath/exported').toFilePath()).existsSync()) {
    Directory(Uri.file('$modManDirPath/exported').toFilePath()).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });
  }
}

void clearAppUpdateFolder() {
  String appUpdatePath = Uri.file('${Directory.current.path}/appUpdate').toFilePath();
  if (Directory(appUpdatePath).existsSync()) {
    Directory(appUpdatePath).deleteSync(recursive: true);
  }
}
