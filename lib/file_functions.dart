import 'dart:convert';
import 'dart:io';
import 'package:pso2_mod_manager/contents_helper.dart';
import 'package:pso2_mod_manager/home_page.dart';

import 'main.dart';

import 'package:path/path.dart' as p;

Directory dataDir = Directory('$binDirPath\\data');

void singleModAdder(List<ModFile> modList) {
  final iceFiles = dataDir.listSync(recursive: true).whereType<File>();
  bool backupFileFound = false;

  for (var modFile in modList) {
    //Backup file check and apply
    for (var file in iceFiles) {
      final fileExtension = p.extension(file.path);

      if (fileExtension == '' &&
          file.path.split('\\').last == modFile.iceName) {
        modFile.originalIcePath = file.path;
        originalFileFound = true;

        for (var backupFile in Directory(backupDirPath)
            .listSync(recursive: true)
            .whereType<File>()) {
          if (p.extension(backupFile.path) == '' &&
              backupFile.path.split('\\').last == modFile.iceName) {
            backupFileFound = true;
            break;
          } else {
            modFile.backupIcePath = backupFile.path;
          }
        }
        if (!backupFileFound) {
          file.copySync('$backupDirPath\\${modFile.iceName}');
          modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
        }

        //Copy file to data folders
        File(modFile.icePath).copySync(file.path);
        modFile.isApplied = true;

        for (var modList in modFilesList) {
          print(modFilesList.length);
          modList.map((mod) => mod.toJson()).toList();
          File(modSettingsPath).writeAsStringSync(json.encode(modList));
        }
      } else if (fileExtension == '' &&
          file.path.split('\\').last != modFile.iceName) {
        originalFileFound = false;
      }
    }
  }
}

void modsRemover(List<ModFile> modsList) {
  for (var mod in modsList) {
    File backupFile = File(mod.backupIcePath);
    if (backupFile.existsSync()) {
      backupFileFound = true;
      backupFile.copySync(mod.originalIcePath);
      backupFile.deleteSync();

      mod.backupIcePath = '';
      mod.isApplied = false;
    } else {
      backupFileFound = false;
    }
  }

  for (var modList in modFilesList) {
    modList.map((mod) => mod.toJson()).toList();
    File(modSettingsPath).writeAsStringSync(json.encode(modList));
  }
}
