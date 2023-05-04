import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<List<CategoryType>> modFileStructureLoader() async {
  //Get og file paths
  ogDataFiles = Directory(Uri.file('$modManPso2binPath/data').toFilePath()).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '').map((e) => e.path).toList();

  List<CategoryType> structureFromJson = [];
  List<CategoryType> cateTypes = [];

  //Load list from json
  if (File(modManModsListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManModsListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      structureFromJson.add(CategoryType.fromJson(type));
    }
  }
  //firts launch, empty json
  //Create categories
  final categoryDirsinMods = Directory(modManModsDirPath).listSync(recursive: false).whereType<Directory>();
  List<String> layerWearsGroup = ['Basewears', 'Innerwears', 'Outerwears', 'Setwears'];
  List<String> castPartsGroup = ['Cast Arm Parts', 'Cast Body Parts', 'Cast Leg Parts'];
  //List<Category> categories = [];

  for (var dir in categoryDirsinMods) {
    //Default Group categories
    int groupPosition = 3;
    String group = 'Others';
    if (layerWearsGroup.contains(p.basename(dir.path))) {
      group = 'Layering Wears';
      groupPosition = 1;
    } else if (castPartsGroup.contains(p.basename(dir.path))) {
      group = 'Cast Parts';
      groupPosition = 2;
    } else {
      group = 'Others';
      groupPosition = 3;
    }

    if (cateTypes.indexWhere((element) => element.groupName == group) == -1) {
      cateTypes.add(CategoryType(group, groupPosition, true, true, [Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), true, await itemsFetcher(dir.path))]));
    } else {
      int index = cateTypes.indexWhere((element) => element.groupName == group);
      cateTypes[index].categories.add(Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), true, await itemsFetcher(dir.path)));
    }
  }

  //Apply settings from json
  for (var type in cateTypes) {
    int typeIndex = structureFromJson.indexWhere((element) => element.groupName == type.groupName);
    if (typeIndex != -1) {
      type.position = structureFromJson[typeIndex].position;
      type.expanded = structureFromJson[typeIndex].expanded;
      type.visible = structureFromJson[typeIndex].visible;
      //Settings for categories
      for (var cate in type.categories) {
        int cateIndex = structureFromJson[typeIndex].categories.indexWhere((element) => element.categoryName == cate.categoryName);
        if (cateIndex != -1) {
          cate.group = structureFromJson[typeIndex].categories[cateIndex].group;
          //cate.location = structureFromJson[typeIndex].categories[cateIndex].location;
          cate.visible = structureFromJson[typeIndex].categories[cateIndex].visible;
          //Settings for items
          final curJsonItemsList = structureFromJson[typeIndex].categories[cateIndex].items;
          for (var item in cate.items) {
            int itemIndex = curJsonItemsList.indexWhere((element) => element.itemName == item.itemName);
            if (itemIndex != -1) {
              item.applyDate = curJsonItemsList[itemIndex].applyDate;
              item.applyStatus = curJsonItemsList[itemIndex].applyStatus;
              //item.category = curJsonItemsList[itemIndex].category;
              //item.itemName = curJsonItemsList[itemIndex].itemName;
              //item.icon = curJsonItemsList[itemIndex].icon;
              item.isFavorite = curJsonItemsList[itemIndex].isFavorite;
              item.isNew = curJsonItemsList[itemIndex].isNew;
              //item.location = curJsonItemsList[itemIndex].location;
              final curJsonModsList = curJsonItemsList[itemIndex].mods;
              for (var mod in item.mods) {
                int modIndex = curJsonModsList.indexWhere((element) => element.modName == mod.modName);
                if (modIndex != -1) {
                  mod.appliedSubMods = curJsonModsList[modIndex].appliedSubMods;
                  mod.applyDate = curJsonModsList[modIndex].applyDate;
                  mod.applyStatus = curJsonModsList[modIndex].applyStatus;
                  //mod.category = curJsonModsList[modIndex].category;
                  mod.isFavorite = curJsonModsList[modIndex].isFavorite;
                  mod.isNew = curJsonModsList[modIndex].isNew;
                  //mod.itemName = curJsonModsList[modIndex].itemName;
                  //mod.location = curJsonModsList[modIndex].location;
                  //mod.modName = curJsonModsList[modIndex].modName;
                  //mod.previewImages = curJsonModsList[modIndex].previewImages;
                  //mod.previewVideos = curJsonModsList[modIndex].previewVideos;
                  final curJsonSubmodsList = curJsonModsList[modIndex].submods;
                  for (var submod in mod.submods) {
                    int submodIndex = curJsonSubmodsList.indexWhere((element) => element.submodName == submod.submodName);
                    if (submodIndex != -1) {
                      submod.appliedModFiles = curJsonSubmodsList[submodIndex].appliedModFiles;
                      submod.applyDate = curJsonSubmodsList[submodIndex].applyDate;
                      submod.applyStatus = curJsonSubmodsList[submodIndex].applyStatus;
                      //submod.category = curJsonSubmodsList[submodIndex].category;
                      submod.isFavorite = curJsonSubmodsList[submodIndex].isFavorite;
                      submod.isNew = curJsonSubmodsList[submodIndex].isNew;
                      //submod.itemName = curJsonSubmodsList[submodIndex].itemName;
                      //submod.location = curJsonSubmodsList[submodIndex].location;
                      //submod.modName = curJsonSubmodsList[submodIndex].modName;
                      //submod.submodName = curJsonSubmodsList[submodIndex].submodName;
                      //submod.previewImages = curJsonSubmodsList[submodIndex].previewImages;
                      //submod.previewVideos = curJsonSubmodsList[submodIndex].previewVideos;
                      final curJsonModFilesList = curJsonSubmodsList[submodIndex].modFiles;
                      for (var modFile in curJsonModFilesList) {
                        int modFileIndex = curJsonModFilesList.indexWhere((element) => element.location == modFile.location);
                        if (modFileIndex != -1) {
                          modFile.applyDate = curJsonModFilesList[modFileIndex].applyDate;
                          modFile.applyStatus = curJsonModFilesList[modFileIndex].applyStatus;
                          modFile.bkLocations = curJsonModFilesList[modFileIndex].bkLocations;
                          //modFile.category = curJsonModFilesList[modFileIndex].category;
                          modFile.isFavorite = curJsonModFilesList[modFileIndex].isFavorite;
                          modFile.isNew = curJsonModFilesList[modFileIndex].isNew;
                          //modFile.itemName = curJsonModFilesList[modFileIndex].itemName;
                          //modFile.location = curJsonModFilesList[modFileIndex].location;
                          modFile.md5 = curJsonModFilesList[modFileIndex].md5;
                          //modFile.modFileName = curJsonModFilesList[modFileIndex].modFileName;
                          //modFile.modName = curJsonModFilesList[modFileIndex].modName;
                          modFile.ogLocations = curJsonModFilesList[modFileIndex].ogLocations;
                          modFile.ogMd5 = curJsonModFilesList[modFileIndex].ogMd5;
                          //modFile.submodName = curJsonModFilesList[modFileIndex].submodName;
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
  }

  //Add extra types from json to cateTypes
  final curTypes = cateTypes.map((e) => e.groupName).toList();
  for (var type in structureFromJson) {
    if (!curTypes.contains(type.groupName)) {
      cateTypes.add(type);
    }
  }

  //Sort types position
  cateTypes.sort(((a, b) => a.position.compareTo(b.position)));

  //Save to json
  cateTypes.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModsListJsonPath).writeAsStringSync(encoder.convert(cateTypes));

  //Clear refsheets
  if (itemIconRefSheetsList.isNotEmpty) {
    itemIconRefSheetsList.clear();
  }

  return cateTypes;
}

Future<List<Item>> itemsFetcher(String catePath) async {
  final itemInCategory = Directory(catePath).listSync(recursive: false).whereType<Directory>();
  List<Item> items = [];

  List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
  for (var dir in itemInCategory) {
    //Get item icon
    String itemIcon = '';
    final filesInItemDir = Directory(dir.path).listSync(recursive: false).whereType<File>();
    final imagesFoundInItemDir = filesInItemDir.where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
    if (imagesFoundInItemDir.isNotEmpty) {
      itemIcon = imagesFoundInItemDir.first.path;
    } else if (cateToIgnoreScan.contains(p.basename(dir.path))) {
      itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
    } else {
      List<File> iceFilesInCurItem = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
      if (iceFilesInCurItem.isEmpty) {
        Directory firstFolderInCurItem = Directory(dir.path).listSync(recursive: false).whereType<Directory>().first;
        iceFilesInCurItem = firstFolderInCurItem.listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
      }

      String tempItemIconPath = '';
      for (var element in iceFilesInCurItem) {
        if (tempItemIconPath.isEmpty) {
          tempItemIconPath = await itemIconFetch(XFile(element.path));
        } else {
          break;
        }
      }

      if (tempItemIconPath.isNotEmpty) {
        File(tempItemIconPath).copySync(Uri.file('${dir.path}/${p.basename(tempItemIconPath)}').toFilePath());
        itemIcon = Uri.file('${dir.path}/${p.basename(tempItemIconPath)}').toFilePath();
        //clear temp dir
        Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
          element.deleteSync(recursive: true);
        });
      } else {
        itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
      }
    }

    items.add(Item(p.basename(dir.path), itemIcon, p.basename(catePath), Uri.file(dir.path).toFilePath(), false, false, DateTime(0), false, modsFetcher(dir.path, p.basename(catePath))));
  }

  return items;
}

List<Mod> modsFetcher(String itemPath, String cateName) {
  final foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  List<Mod> mods = [];
  for (var dir in foldersInItemPath) {
    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
    for (var element in imagesInModDir) {
      modPreviewImages.add(Uri.file(element.path).toFilePath());
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [],
        subModFetcher(dir.path, cateName, p.basename(itemPath))));
  }

  return mods;
}

List<SubMod> subModFetcher(String modPath, String cateName, String itemName) {
  List<SubMod> submods = [];
  //ices in main mod dir
  final filesInMainModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
  if (filesInMainModDir.isNotEmpty) {
    List<ModFile> modFiles = [];
    for (var file in filesInMainModDir) {
      //final ogFiles = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }
      modFiles.add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', '', file.path, [], [], DateTime(0), false, false, false));
    }

    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
    for (var element in imagesInModDir) {
      modPreviewImages.add(Uri.file(element.path).toFilePath());
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], modFiles));
  }

  //ices in sub dirs
  final foldersInModDir = Directory(modPath).listSync(recursive: true).whereType<Directory>().toList();
  for (var dir in foldersInModDir) {
    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
    for (var element in imagesInModDir) {
      modPreviewImages.add(Uri.file(element.path).toFilePath());
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    final filesInDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
    List<ModFile> modFiles = [];
    for (var file in filesInDir) {
      //final ogFiles = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }

      List<String> parentPaths = file.parent.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);

      modFiles.add(ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', '', file.path, [], [], DateTime(0), false, false, false));
    }

    //Get submod name
    List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
    parentPaths.removeWhere((element) => element.isEmpty);
    submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], modFiles));
  }

  return submods;
}

// Future<List<CategoryType>> categoryTypesLoader() async {
//   List<CategoryType> categoriesFromMods = await modFilesLoader(modManModsDirPath);

//   for (var type in categoriesFromMods) {
//     if (type.groupName == 'Layering Wears') {
//       type.position = 1;
//     } else if (type.groupName == 'Cast Parts') {
//       type.position = 2;
//     } else {
//       type.position = 3;
//     }
//   }

//   categoriesFromMods.sort(((a, b) => a.position.compareTo(b.position)));

//   //Save to json
//   categoriesFromMods.map((cateType) => cateType.toJson()).toList();
//   const JsonEncoder encoder = JsonEncoder.withIndent('  ');
//   //File(modManModsListJsonPath).writeAsStringSync(encoder.convert(categoryTypes));

//   return categoriesFromMods;
// }

// Future<List<CategoryType>> modFilesLoader(String modsDirPath) async {
//   List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
//   List<CategoryType> modListFromJson = [];

//   //Load list from json
//   if (File(modManModsListJsonPath).readAsStringSync().toString().isNotEmpty) {
//     var jsonData = jsonDecode(File(modManModsListJsonPath).readAsStringSync());
//     for (var type in jsonData) {
//       modListFromJson.add(CategoryType.fromJson(type));
//     }
//   }

//   //Load Mod Files
//   List<String> modsDirFolderPaths = [];
//   final allDataFolders = Directory(Uri.file(modManModsDirPath).toFilePath()).listSync(recursive: true).whereType<Directory>();
//   for (var folder in allDataFolders) {
//     modsDirFolderPaths.add(Uri.file(folder.path).toFilePath());
//   }
//   List<String> modsDirFilePaths = [];
//   final allDataFiles = Directory(Uri.file(modManModsDirPath).toFilePath()).listSync(recursive: true).whereType<File>();
//   for (var file in allDataFiles) {
//     modsDirFilePaths.add(file.path);
//   }

//   //Remove existed
//   for (var cateType in modListFromJson) {
//     for (var cate in cateType.categories) {
//       modsDirFolderPaths.remove(cate.location);
//       for (var item in cate.items) {
//         modsDirFolderPaths.remove(item.location);
//         for (var mod in item.mods) {
//           modsDirFolderPaths.remove(mod.location);
//           for (var submod in mod.submods) {
//             modsDirFolderPaths.remove(submod.location);
//             modsDirFilePaths.removeWhere((element) => element.contains(submod.location));
//           }
//         }
//       }
//     }
//   }

//   //Preping category list
//   //List<Category> categories = [];
//   final dirsInModsDir = Directory(modManModsDirPath).listSync(recursive: false);
//   for (var cateDir in dirsInModsDir) {
//     final dirPathsInCurCategory = modsDirFolderPaths.where((element) => element.contains(cateDir.path)).toList();
//     final filePathsInCurCategory = modsDirFilePaths.where((element) => element.contains(cateDir.path)).toList();

//     //Items
//     List<Item> items = [];

//     //Listing Item paths
//     final itemDirPathsInCurCategory = dirPathsInCurCategory.where((element) => isSubOfParentDir(element, cateDir.path)).toList();
//     for (var itemDir in itemDirPathsInCurCategory) {
//       final dirPathsInCurItem = dirPathsInCurCategory.where((element) => element.contains(itemDir)).toList();
//       final filePathsInCurItem = filePathsInCurCategory.where((element) => element.contains(itemDir)).toList();

//       List<String> filesInMainItemDir = modsDirFilePaths.where((element) => isSubOfParentDir(element, itemDir)).toList();

//       //Get item icon
//       String itemIcon = '';
//       final imagesInItemDir = filesInMainItemDir.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png').toList();
//       if (imagesInItemDir.isNotEmpty) {
//         itemIcon = imagesInItemDir.first;
//       } else if (cateToIgnoreScan.contains(p.basename(cateDir.path))) {
//         itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
//       } else {
//         final icesInItem = filePathsInCurCategory.where((element) => p.extension(element) == '');
//         List<XFile> listOfIcesToFetch = [];
//         for (var element in icesInItem) {
//           if (!listOfIcesToFetch.contains(XFile(element))) {
//             listOfIcesToFetch.add(XFile(element));
//           }
//         }
//         String tempItemIconPath = '';
//         for (var element in listOfIcesToFetch) {
//           if (tempItemIconPath.isEmpty) {
//             tempItemIconPath = await itemIconFetch(element);
//           } else {
//             break;
//           }
//         }

//         if (tempItemIconPath.isNotEmpty) {
//           File(tempItemIconPath).copySync(Uri.file('$itemDir/${XFile(tempItemIconPath).name}').toFilePath());
//           itemIcon = Uri.file('$itemDir/${XFile(tempItemIconPath).name}').toFilePath();
//           //clear temp dir
//           Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
//             element.deleteSync(recursive: true);
//           });
//         } else {
//           itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
//         }
//       }

//       //   //Get mods in items
//       List<Mod> mods = [];
//       final modDirPathsInCurItem = dirPathsInCurItem.where((element) => isSubOfParentDir(element, itemDir)).toList();
//       for (var modDir in modDirPathsInCurItem) {
//         final dirPathsInCurMod = dirPathsInCurItem.where((element) => element.contains(modDir)).toList();
//         final filePathsInCurMod = filePathsInCurItem.where((element) => element.contains(modDir)).toList();

//         //Get preview images;
//         List<String> modPreviewImages = [];
//         final imagesInModDir = filePathsInCurMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
//         for (var element in imagesInModDir) {
//           modPreviewImages.add(Uri.file(element).toFilePath());
//         }
//         //Get preview videos;
//         List<String> modPreviewVideos = [];
//         final videosInModDir = filePathsInCurMod.where((element) => p.extension(element) == '.webm' || p.extension(element) == '.mp4');
//         for (var element in videosInModDir) {
//           modPreviewVideos.add(Uri.file(element).toFilePath());
//         }

//         //Get submods in mods
//         List<SubMod> submods = [];
//         //Get modfiles in mods
//         final modFilesInModDir = filePathsInCurMod.where((element) => isSubOfParentDir(element, modDir) && p.extension(element) == '');
//         if (modFilesInModDir.isNotEmpty) {
//           //Set submods
//           //Get mod files in submods
//           List<ModFile> modFilesInMainDir = [];
//           for (var modFile in modFilesInModDir) {
//             //Fetch og ice location
//             //List<String> ogIceFileLocations = [];
//             List<String> ogIceFileLocations = ogDataFilePaths.where((element) => p.basename(element) == p.basename(modFile)).toList();

//             //Populate modFiles
//             modFilesInMainDir.add(ModFile(p.basename(modFile), p.basename(modDir), p.basename(modDir), p.basename(itemDir), p.basename(cateDir.path), '', '', Uri.file(modFile).toFilePath(),
//                 ogIceFileLocations, [], DateTime(0), false, false, false));
//           }

//           //Populate submods
//           for (var cateType in modListFromJson) {
//             int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//             if (cateIndex != -1) {
//               int itemIndex = cateType.categories[cateIndex].items.indexWhere((element) => element.itemName == p.basename(itemDir));
//               if (itemIndex != -1) {
//                 int modIndex = cateType.categories[cateIndex].items[itemIndex].mods.indexWhere((element) => element.modName == p.basename(modDir));
//                 if (modIndex != -1) {
//                   int submodIndex = cateType.categories[cateIndex].items[itemIndex].mods[modIndex].submods.indexWhere((element) => element.submodName == p.basename(modDir));
//                   if (submodIndex != -1) {
//                     cateType.categories[cateIndex].items[itemIndex].mods[modIndex].submods[submodIndex].modFiles.addAll(modFilesInMainDir);
//                     break;
//                   } else {
//                     submods.add(SubMod(p.basename(modDir), p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false,
//                         modPreviewImages, modPreviewVideos, [], modFilesInMainDir));
//                     break;
//                   }
//                 }
//               }
//             }
//           }
//           // submods.add(SubMod(p.basename(modDir), p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false, modPreviewImages,
//           //     modPreviewVideos, [], modFilesInMainDir));
//         }

//         //Get submods
//         final submodDirsInMod = dirPathsInCurMod.where((element) => isSubOfParentDir(element, modDir)).toList();
//         for (var submodDir in submodDirsInMod) {
//           //final dirPathsInCurSubMod = dirPathsInCurItem.where((element) => element.contains(submodDir)).toList();
//           final filePathsInCurSubMod = filePathsInCurItem.where((element) => element.contains(submodDir)).toList();
//           //Fetch submod name
//           List<String> submodPathSegment = Uri.file(submodDir).pathSegments;
//           List<String> submodDirs = [];
//           submodDirs.addAll(submodPathSegment);
//           submodDirs.removeRange(0, submodDirs.indexOf(p.basename(modDir)) + 1);
//           final submodName = submodDirs.join(' > ');
//           //Get preview images;
//           List<String> submodPreviewImages = [];
//           final imagesInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
//           for (var element in imagesInSubmodDir) {
//             submodPreviewImages.add(Uri.file(element).toFilePath());
//           }
//           //Get preview videos;
//           List<String> submodPreviewVideos = [];
//           final videosInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
//           for (var element in videosInSubmodDir) {
//             submodPreviewVideos.add(Uri.file(element).toFilePath());
//           }
//           //Get mod files in submods
//           List<ModFile> modFiles = [];
//           final modFilesInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '').toList();
//           for (var modFile in modFilesInSubmodDir) {
//             List<String> ogIceFileLocations = ogDataFilePaths.where((element) => p.basename(element) == p.basename(modFile)).toList();

//             //Populate modFiles
//             modFiles.add(ModFile(p.basename(modFile), submodName, p.basename(modDir), p.basename(itemDir), p.basename(cateDir.path), '', '', Uri.file(modFile).toFilePath(), ogIceFileLocations, [],
//                 DateTime(0), false, false, false));
//           }

//           //Populate submods
//           for (var cateType in modListFromJson) {
//             int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//             if (cateIndex != -1) {
//               int itemIndex = cateType.categories[cateIndex].items.indexWhere((element) => element.itemName == p.basename(itemDir));
//               if (itemIndex != -1) {
//                 int modIndex = cateType.categories[cateIndex].items[itemIndex].mods.indexWhere((element) => element.modName == p.basename(modDir));
//                 if (modIndex != -1) {
//                   int submodIndex = cateType.categories[cateIndex].items[itemIndex].mods[modIndex].submods.indexWhere((element) => element.submodName == submodName);
//                   if (submodIndex != -1) {
//                     cateType.categories[cateIndex].items[itemIndex].mods[modIndex].submods[submodIndex].modFiles.addAll(modFiles);
//                     break;
//                   } else {
//                     submods.add(SubMod(submodName, p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(submodDir).toFilePath(), false, DateTime(0), false, false,
//                         submodPreviewImages, submodPreviewVideos, [], modFiles));
//                     break;
//                   }
//                 }
//               }
//             }
//           }
//           // submods.add(SubMod(submodName, p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(submodDir).toFilePath(), false, DateTime(0), false, false, submodPreviewImages,
//           //     submodPreviewVideos, [], modFiles));
//         }

//         //Populate mods
//         for (var cateType in modListFromJson) {
//           int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//           if (cateIndex != -1) {
//             int itemIndex = cateType.categories[cateIndex].items.indexWhere((element) => element.itemName == p.basename(itemDir));
//             if (itemIndex != -1) {
//               int modIndex = cateType.categories[cateIndex].items[itemIndex].mods.indexWhere((element) => element.modName == p.basename(modDir));
//               if (modIndex != -1) {
//                 cateType.categories[cateIndex].items[itemIndex].mods[modIndex].submods.addAll(submods);
//                 break;
//               } else {
//                 mods.add(Mod(p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [],
//                     submods));
//                 break;
//               }
//             }
//           }
//         }
//         //mods.add(
//         //    Mod(p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], submods));
//       }

//       //Populate items
//       for (var cateType in modListFromJson) {
//         int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//         if (cateIndex != -1) {
//           int itemIndex = cateType.categories[cateIndex].items.indexWhere((element) => element.itemName == p.basename(itemDir));
//           if (itemIndex != -1) {
//             cateType.categories[cateIndex].items[itemIndex].mods.addAll(mods);
//             break;
//           } else {
//             items.add(Item(p.basename(itemDir), itemIcon, p.basename(cateDir.path), Uri.file(itemDir).toFilePath(), false, false, DateTime(0), false, mods));
//             break;
//           }
//         }
//       }
//       //items.add(Item(p.basename(itemDir), itemIcon, p.basename(cateDir.path), Uri.file(itemDir).toFilePath(), false, false, DateTime(0), false, mods));
//     }

//     //Group categories
//     String group = 'Others';
//     if (p.basename(cateDir.path) == 'Basewears' || p.basename(cateDir.path) == 'Innerwears' || p.basename(cateDir.path) == 'Outerwears' || p.basename(cateDir.path) == 'Setwears') {
//       group = 'Layering Wears';
//     } else if (p.basename(cateDir.path) == 'Cast Arm Parts' || p.basename(cateDir.path) == 'Cast Body Parts' || p.basename(cateDir.path) == 'Cast Leg Parts') {
//       group = 'Cast Parts';
//     } else {
//       group = 'Others';
//     }
//     if (modListFromJson.isEmpty || modListFromJson.indexWhere((element) => element.groupName == group) == -1) {
//       modListFromJson.add(CategoryType(group, 0, true, true, []));
//     }

//     //Add items to categories
//     int cateTypeIndex = -1;
//     for (var cateType in modListFromJson) {
//       if (cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path)) != -1) {
//         cateTypeIndex = cateType.categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//         break;
//       }
//     }
//     if (cateTypeIndex != -1) {
//       int existedCateIndex = modListFromJson[cateTypeIndex].categories.indexWhere((element) => element.categoryName == p.basename(cateDir.path));
//       if (existedCateIndex != -1) {
//         modListFromJson[cateTypeIndex].categories[existedCateIndex].items.addAll(items);
//       }
//     } else {
//       modListFromJson.last.categories.add(Category(p.basename(cateDir.path), group, Uri.file(cateDir.path).toFilePath(), true, items));
//     }

//     //categories.add(Category(p.basename(cateDir.path), group, Uri.file(cateDir.path).toFilePath(), true, items));
//   }

//   //Clear refsheets
//   if (itemIconRefSheetsList.isEmpty) {
//     itemIconRefSheetsList.clear();
//   }

//   //Write

//   return modListFromJson;
// }

//Path helper
bool isSubOfParentDir(String path, String parentPath) {
  if (File(path).parent.path == parentPath) {
    return true;
  }
  return false;
}
