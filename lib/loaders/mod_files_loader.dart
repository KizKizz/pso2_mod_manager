// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/show_hide_cates.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<List<CategoryType>> modFileStructureLoader() async {
  ogModFilesLoader();

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
      groupPosition = 0;
    } else if (castPartsGroup.contains(p.basename(dir.path))) {
      group = 'Cast Parts';
      groupPosition = 1;
    } else {
      group = 'Others';
      groupPosition = 2;
    }

    if (cateTypes.indexWhere((element) => element.groupName == group) == -1) {
      cateTypes.add(CategoryType(group, groupPosition, true, true, [Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), 0, true, await itemsFetcher(dir.path))]));
    } else {
      int index = cateTypes.indexWhere((element) => element.groupName == group);
      cateTypes[index].categories.add(Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), 0, true, await itemsFetcher(dir.path)));
    }
  }

  //Create missing cate types
  for (var jsonCateType in structureFromJson) {
    if (cateTypes.indexWhere((element) => element.groupName == jsonCateType.groupName) == -1) {
      cateTypes.add(CategoryType(jsonCateType.groupName, jsonCateType.position, jsonCateType.visible, jsonCateType.expanded, []));
    }
  }

  //Sort categories
  for (var type in structureFromJson) {
    int cateTypeIndex = cateTypes.indexWhere((element) => element.groupName == type.groupName);
    for (var cate in type.categories) {
      int cateIndex = cateTypes[cateTypeIndex].categories.indexWhere((element) => element.categoryName == cate.categoryName);
      if (cateIndex == -1) {
        //print(cate.categoryName);
        int mainCateTypeIndex = cateTypes.indexWhere((element) => element.categories.indexWhere((e) => e.categoryName == cate.categoryName) != -1);
        if (mainCateTypeIndex != -1) {
          int mainCateIndex = cateTypes[mainCateTypeIndex].categories.indexWhere((element) => element.categoryName == cate.categoryName);
          if (mainCateIndex != -1) {
            Category cateToMove = cateTypes[mainCateTypeIndex].categories[mainCateIndex];
            cateTypes[cateTypeIndex].categories.insert(cate.position, cateToMove);
            cateTypes[mainCateTypeIndex].categories.remove(cateToMove);
          }
        }
      }
    }
  }

  //Apply settings from json
  for (var type in cateTypes) {
    int typeIndex = structureFromJson.indexWhere((element) => element.groupName == type.groupName);
    if (typeIndex != -1) {
      type.position = typeIndex;
      type.expanded = structureFromJson[typeIndex].expanded;
      type.visible = isEmptyCatesHide && type.categories.where((element) => element.items.isNotEmpty).length > 1 ? true : structureFromJson[typeIndex].visible;
      //Settings for categories
      for (var cate in type.categories) {
        int cateIndex = structureFromJson[typeIndex].categories.indexWhere((element) => element.categoryName == cate.categoryName);
        if (cateIndex != -1) {
          cate.group = structureFromJson[typeIndex].categories[cateIndex].group;
          cate.position = cateIndex;
          //cate.location = structureFromJson[typeIndex].categories[cateIndex].location;
          cate.visible = isEmptyCatesHide && cate.items.isNotEmpty ? true : structureFromJson[typeIndex].categories[cateIndex].visible;
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
              item.isSet = curJsonItemsList[itemIndex].isSet;
              item.setNames = curJsonItemsList[itemIndex].setNames;
              //item.location = curJsonItemsList[itemIndex].location;
              //Populate modset items
              if (item.isSet) {
                allSetItems.add(item);
              }
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
                  mod.isSet = curJsonModsList[modIndex].isSet;
                  mod.setNames = curJsonModsList[modIndex].setNames;
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
                      submod.isSet = curJsonSubmodsList[submodIndex].isSet;
                      submod.setNames = curJsonSubmodsList[submodIndex].setNames;
                      final curJsonModFilesList = curJsonSubmodsList[submodIndex].modFiles;
                      for (var modFile in submod.modFiles) {
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
                          modFile.ogMd5s = curJsonModFilesList[modFileIndex].ogMd5s;
                          //modFile.submodName = curJsonModFilesList[modFileIndex].submodName;
                          modFile.isSet = curJsonModFilesList[modFileIndex].isSet;
                          modFile.setNames = curJsonModFilesList[modFileIndex].setNames;
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
      //sort cates in catetype
      type.categories.sort(((a, b) => a.position.compareTo(b.position)));
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
  saveModdedItemListToJson();

  //Clear refsheets
  if (itemIconRefSheetsList.isNotEmpty) {
    itemIconRefSheetsList.clear();
  }

  //Get hidden catetypes and cates
  if (isEmptyCatesHide) {
    hideAllEmptyCategories(cateTypes);
  }
  hiddenItemCategories = await hiddenCategoriesGet(cateTypes);

  return cateTypes;
}

Future<List<Item>> itemsFetcher(String catePath) async {
  final itemInCategory = Directory(catePath).listSync(recursive: false).whereType<Directory>();
  List<Item> items = [];

  List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
  for (var dir in itemInCategory) {
    //Get item icon
    List<String> itemIcons = [];
    final imagesFoundInItemDir =
        Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
    if (imagesFoundInItemDir.isNotEmpty) {
      itemIcons = imagesFoundInItemDir.map((e) => e.path).toList();
    } else if (!isAutoFetchingIconsOnStartup || cateToIgnoreScan.contains(p.basename(catePath))) {
      itemIcons.add('assets/img/placeholdersquare.png');
    } else {
      List<File> iceFilesInCurItem = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '').toList();
      List<File> iceFilesInCurItemNoDup = [];
      for (var file in iceFilesInCurItem) {
        if (iceFilesInCurItemNoDup.where((element) => p.basename(element.path) == p.basename(file.path)).isEmpty) {
          iceFilesInCurItemNoDup.add(file);
        }
      }
      // if (iceFilesInCurItem.isEmpty) {
      //   Directory firstFolderInCurItem = Directory(dir.path).listSync(recursive: false).whereType<Directory>().first;
      //   iceFilesInCurItem = firstFolderInCurItem.listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
      // }

      List<String> tempItemIconPaths = await itemIconFetch(iceFilesInCurItemNoDup);

      if (tempItemIconPaths.isNotEmpty) {
        for (var tempItemIconPath in tempItemIconPaths) {
          File(tempItemIconPath).copySync(Uri.file('${dir.path}/${p.basename(tempItemIconPath)}').toFilePath());
          itemIcons.add(Uri.file('${dir.path}/${p.basename(tempItemIconPath)}').toFilePath());
        }
        //clear temp dir
        Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
          element.deleteSync(recursive: true);
        });
      } else {
        itemIcons.add('assets/img/placeholdersquare.png');
      }
    }

    items.add(
        Item(p.basename(dir.path), [], itemIcons, p.basename(catePath), Uri.file(dir.path).toFilePath(), false, DateTime(0), 0, false, false, false, [], modsFetcher(dir.path, p.basename(catePath))));
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

    List<SubMod> newMod = subModFetcher(dir.path, cateName, p.basename(itemPath));
    if (newMod.isNotEmpty) {
      mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], newMod));
    }
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
      //final ogFilePaths = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }
      modFiles.add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, false, false, [], [], []));
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

    if (modFiles.isNotEmpty) {
      submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], modFiles));
    }
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
      //final ogFilePaths = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }

      List<String> parentPaths = file.parent.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);

      modFiles.add(ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, false, false, [], [], []));
    }

    //Get submod name
    if (modFiles.isNotEmpty) {
      List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);
      submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], modFiles));
    }
  }

  return submods;
}

void ogModFilesLoader() {
  //Get og file paths
  if (ogWin32FilePaths.isEmpty && Directory(Uri.file('$modManPso2binPath/data/win32').toFilePath()).existsSync()) {
    ogWin32FilePaths =
        Directory(Uri.file('$modManPso2binPath/data/win32').toFilePath()).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').map((e) => e.path).toList();
  }
  if (ogWin32NAFilePaths.isEmpty && Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync()) {
    ogWin32NAFilePaths = Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath())
        .listSync(recursive: false)
        .whereType<File>()
        .where((element) => p.extension(element.path) == '')
        .map((e) => e.path)
        .toList();
  }
  if (ogWin32RebootFilePaths.isEmpty && Directory(Uri.file('$modManPso2binPath/data/win32reboot').toFilePath()).existsSync()) {
    ogWin32RebootFilePaths = Directory(Uri.file('$modManPso2binPath/data/win32reboot').toFilePath())
        .listSync(recursive: true)
        .whereType<File>()
        .where((element) => p.extension(element.path) == '')
        .map((e) => e.path)
        .toList();
  }
  if (ogWin32RebootFilePaths.isEmpty && Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath()).existsSync()) {
    ogWin32RebootFilePaths = Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath())
        .listSync(recursive: true)
        .whereType<File>()
        .where((element) => p.extension(element.path) == '')
        .map((e) => e.path)
        .toList();
  }
}
