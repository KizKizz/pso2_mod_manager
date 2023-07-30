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
                      if (file.applyStatus == true) {
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
  final restoredFileNames = restoredFiles.map((e) => p.basename(e)).toList();

  for (var modFile in modFiles) {
    if (restoredFileNames.contains(modFile.modFileName)) {
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


