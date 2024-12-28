import 'dart:io';

import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

String mainModDirPath = '$mainDataDirPath${p.separator}Mods';
String backupDirPath = '';
String mainModListJsonPath = '';
String mainModSetListJsonPath = '';
String backgroundDirPath = '$mainDataDirPath${p.separator}BackgroundImages';

Future<(bool, bool)> appMainPathsCheck() async {
  bool pso2bin = true;
  bool mainDir = true;
  if (pso2binDirPath.isEmpty || !await Directory(pso2binDirPath).exists()) pso2bin = false;
  if (mainDataDirPath.isEmpty || !await Directory(mainDataDirPath).exists()) mainDir = false;

  return (pso2bin, mainDir);
}

void createMainDirs() {
  // Create Mods folder and default categories
  Directory(mainModDirPath).createSync(recursive: true);
  for (var dirName in defaultCategoryDirs) {
    Directory(mainModDirPath + p.separator + dirName).createSync(recursive: true);
  }

  // Create background folder
  Directory(backgroundDirPath).createSync(recursive: true);

  // Profile 1
  if (modManCurActiveProfile == 1) {
    // Create Mod backup folders
    backupDirPath = '$mainDataDirPath${p.separator}Backups';
    Directory(backupDirPath).createSync(recursive: true);
    List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
    for (var name in dataFolders) {
      Directory('$backupDirPath${p.separator}$name').createSync(recursive: true);
    }

    // Main mod list
    mainModListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManModsList.json';

    // Main mod set list
    mainModSetListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManSetsList.json';
  }

  // Profile 2
  if (modManCurActiveProfile == 2) {
    // Create Mod backup folders
    backupDirPath = '$mainDataDirPath${p.separator}Backups_profile2';
    Directory(backupDirPath).createSync(recursive: true);
    List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
    for (var name in dataFolders) {
      Directory('$backupDirPath${p.separator}$name').createSync(recursive: true);
    }
  }

  // Main mod list
  mainModListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManModsList_profile2.json';

  // Main mod set list
  mainModSetListJsonPath = '$mainDataDirPath${p.separator}PSO2ModManSetsList_profile2.json';
}
