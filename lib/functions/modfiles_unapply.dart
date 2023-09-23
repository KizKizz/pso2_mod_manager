import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<ModFile>> modFilesUnapply(context, List<ModFile> modFiles) async {
  //apply mods
  List<ModFile> unappliedModFiles = [];
  List<String> unapplyModFileDataPaths = [];
  for (var modFile in modFiles) {
    //check for mods that use the same file
    bool sameModFileFound = false;
    for (var type in appliedItemList) {
      for (var cate in type.categories) {
        for (var item in cate.items) {
          if (item.applyStatus) {
            for (var mod in item.mods) {
              if (mod.applyStatus) {
                for (var submod in mod.submods) {
                  if (submod.applyStatus) {
                    for (var file in submod.modFiles) {
                      if (file.applyStatus) {
                        if (file.modFileName == modFile.modFileName && file.location != modFile.location) {
                          sameModFileFound = true;
                          break;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    if (!sameModFileFound) {
      for (var ogFilePath in modFile.ogLocations) {
        String dataFilePath = ogFilePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '').trim();
        unapplyModFileDataPaths.add(dataFilePath);
      }
    }
  }

  final restoredFiles = await downloadIceFromOfficial(unapplyModFileDataPaths);
  //final restoredFileNames = restoredFiles.map((e) => p.basename(e)).toList();
  final restoredOGFilePaths = restoredFiles.map((e) => Uri.file('$modManPso2binPath/$e').toFilePath()).toList();

  for (var modFile in modFiles) {
    modFile.ogLocations.removeWhere((element) => restoredOGFilePaths.contains(element));

    List<String> bkPathsToRemove = [];
    for (var ogPath in modFile.ogLocations) {
      //restore backups for win32_na and win32reboot_na
      if (ogPath.contains('win32_na') || ogPath.contains('win32reboot_na')) {
        for (var bkPath in modFile.bkLocations) {
          if (File(bkPath).existsSync() && ogPath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), '') == bkPath.replaceFirst(modManBackupsDirPath, '')) {
            final restoredFile = await File(bkPath).copy(ogPath);
            if (restoredFile.path == ogPath) {
              File(bkPath).deleteSync();
              if (bkPath.contains('win32reboot_na') && Directory(p.dirname(bkPath)).listSync(recursive: true).whereType<File>().isEmpty) {
                Directory(p.dirname(bkPath)).deleteSync(recursive: true);
              }
              bkPathsToRemove.add(bkPath);
            }
          }
        }
      }
    }
    for (var bkPath in bkPathsToRemove) {
      modFile.bkLocations.remove(bkPath);
      modFile.ogLocations.removeWhere((element) => element.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), '') == bkPath.replaceFirst(modManBackupsDirPath, ''));
    }
    if (modFile.bkLocations.isEmpty && modFile.ogLocations.isEmpty) {
      modFile.ogMd5s.clear();
      modFile.bkLocations.clear();
      modFile.ogLocations.clear();
      modFile.applyDate = DateTime(0);
      modFile.applyStatus = false;
      unappliedModFiles.add(modFile);
    }
  }

  return unappliedModFiles;
}


// Future<List<ModFile>> modFilesUnapply(context, List<ModFile> modFiles) async {
//   //apply mods
//   List<ModFile> unappliedModFiles = [];
//   for (var modFile in modFiles) {
//     modFile = await modFileUnapply(modFile);
//     modFile.ogMd5s.clear();
//     modFile.bkLocations.clear();
//     modFile.ogLocations.clear();
//     modFile.applyDate = DateTime(0);
//     modFile.applyStatus = false;
//     unappliedModFiles.add(modFile);
//   }

//   return unappliedModFiles;
// }


