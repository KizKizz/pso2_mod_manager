import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/category_type_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/system_loads/app_mod_load_page.dart';

List<Item> modSetItemsFromMasterList = [];

Future<List<CategoryType>> modFileStructureLoader(context, bool reload) async {
  // ogModFilesLoader();

  List<CategoryType> structureFromJson = [];
  List<CategoryType> cateTypes = [];
  modSetItemsFromMasterList = [];
  masterUnappliedItemList = [];
  // bool isEmptyCatesHide = false;

  // Load item data
  // gItemData = await loadItemData();

  //Load list from json
  String modSettingsFromJson = await File(mainModListJsonPath).readAsString();
  if (modSettingsFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(modSettingsFromJson);
    for (var type in jsonData) {
      structureFromJson.add(CategoryType.fromJson(type));
    }
  }
  //firts launch, empty json
  //Create categories
  final categoryDirsinMods = Directory(mainModDirPath).listSync(recursive: false).whereType<Directory>();
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
      cateTypes.add(CategoryType(group, groupPosition, true, true, [Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), 0, true, await itemsFetcher(context, dir.path, reload))]));
    } else {
      int index = cateTypes.indexWhere((element) => element.groupName == group);
      cateTypes[index].categories.add(Category(p.basename(dir.path), group, Uri.file(dir.path).toFilePath(), 0, true, await itemsFetcher(context, dir.path, reload)));
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
      // type.position = typeIndex;
      type.expanded = structureFromJson[typeIndex].expanded;
      // type.visible = isEmptyCatesHide && type.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : structureFromJson[typeIndex].visible;
      //Settings for categories
      for (var cate in type.categories) {
        int cateIndex = structureFromJson[typeIndex].categories.indexWhere((element) => element.categoryName == cate.categoryName);
        if (cateIndex != -1) {
          cate.group = structureFromJson[typeIndex].categories[cateIndex].group;
          cate.position = cateIndex;
          //cate.location = structureFromJson[typeIndex].categories[cateIndex].location;
          // cate.visible = isEmptyCatesHide && cate.items.isNotEmpty ? true : structureFromJson[typeIndex].categories[cateIndex].visible;
          //Settings for items
          final curJsonItemsList = structureFromJson[typeIndex].categories[cateIndex].items;
          for (var item in cate.items) {
            int itemIndex = curJsonItemsList.indexWhere((element) => element.itemName == item.itemName);
            if (itemIndex != -1) {
              item.applyDate = curJsonItemsList[itemIndex].applyDate;
              item.applyStatus = curJsonItemsList[itemIndex].applyStatus;
              curJsonItemsList[itemIndex].subCategory == null ? item.subCategory = item.getSubCategory() : item.subCategory = curJsonItemsList[itemIndex].subCategory;
              //item.category = curJsonItemsList[itemIndex].category;
              //item.itemName = curJsonItemsList[itemIndex].itemName;
              //item.icon = curJsonItemsList[itemIndex].icon;
              if (curJsonItemsList[itemIndex].iconPath != null) item.iconPath = curJsonItemsList[itemIndex].iconPath;
              if (curJsonItemsList[itemIndex].overlayedIconPath != null) item.overlayedIconPath = curJsonItemsList[itemIndex].overlayedIconPath;
              if (curJsonItemsList[itemIndex].backupIconPath != null) item.backupIconPath = curJsonItemsList[itemIndex].backupIconPath;
              if (curJsonItemsList[itemIndex].isOverlayedIconApplied != null) item.isOverlayedIconApplied = curJsonItemsList[itemIndex].isOverlayedIconApplied;
              item.isFavorite = curJsonItemsList[itemIndex].isFavorite;
              item.isNew = curJsonItemsList[itemIndex].isNew;
              item.isSet = curJsonItemsList[itemIndex].isSet;
              item.setNames = curJsonItemsList[itemIndex].setNames;
              //item.location = curJsonItemsList[itemIndex].location;
              //Populate modset items
              if (item.isSet || item.setNames.isNotEmpty) modSetItemsFromMasterList.add(item);
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
                      curJsonSubmodsList[submodIndex].customAQMInjected == null ? submod.customAQMInjected = false : submod.customAQMInjected = curJsonSubmodsList[submodIndex].customAQMInjected;
                      curJsonSubmodsList[submodIndex].customAQMFileName == null ? submod.customAQMFileName = '' : submod.customAQMFileName = curJsonSubmodsList[submodIndex].customAQMFileName;
                      curJsonSubmodsList[submodIndex].hqIcePath == null ? submod.hqIcePath = '' : submod.hqIcePath = curJsonSubmodsList[submodIndex].hqIcePath;
                      curJsonSubmodsList[submodIndex].lqIcePath == null ? submod.lqIcePath = '' : submod.lqIcePath = curJsonSubmodsList[submodIndex].lqIcePath;
                      curJsonSubmodsList[submodIndex].boundingRemoved == null ? submod.boundingRemoved = false : submod.boundingRemoved = curJsonSubmodsList[submodIndex].boundingRemoved;
                      curJsonSubmodsList[submodIndex].applyHQFilesOnly == null ? submod.applyHQFilesOnly = false : submod.applyHQFilesOnly = curJsonSubmodsList[submodIndex].applyHQFilesOnly;
                      //submod.itemName = curJsonSubmodsList[submodIndex].itemName;
                      //submod.location = curJsonSubmodsList[submodIndex].location;
                      //submod.modName = curJsonSubmodsList[submodIndex].modName;
                      //submod.submodName = curJsonSubmodsList[submodIndex].submodName;
                      //submod.previewImages = curJsonSubmodsList[submodIndex].previewImages;
                      //submod.previewVideos = curJsonSubmodsList[submodIndex].previewVideos;
                      curJsonSubmodsList[submodIndex].hasCmx == null ? submod.hasCmx = false : submod.hasCmx = curJsonSubmodsList[submodIndex].hasCmx;
                      curJsonSubmodsList[submodIndex].cmxApplied == null ? submod.cmxApplied = false : submod.cmxApplied = curJsonSubmodsList[submodIndex].cmxApplied;
                      curJsonSubmodsList[submodIndex].cmxStartPos == null ? submod.cmxStartPos = 0 : submod.cmxStartPos = curJsonSubmodsList[submodIndex].cmxStartPos;
                      curJsonSubmodsList[submodIndex].cmxEndPos == null ? submod.cmxEndPos = 0 : submod.cmxEndPos = curJsonSubmodsList[submodIndex].cmxEndPos;
                      //submod.cmxFile = curJsonSubmodsList[submodIndex].cmxFile;
                      submod.isSet = curJsonSubmodsList[submodIndex].isSet;
                      curJsonSubmodsList[submodIndex].activeInSets == null ? submod.activeInSets = [] : submod.activeInSets = curJsonSubmodsList[submodIndex].activeInSets;
                      submod.setNames = curJsonSubmodsList[submodIndex].setNames;
                      curJsonSubmodsList[submodIndex].applyLocations == null ? submod.applyLocations = [] : submod.applyLocations = curJsonSubmodsList[submodIndex].applyLocations;
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
                          if (curJsonModFilesList[modFileIndex].applyLocations != null) modFile.applyLocations = curJsonModFilesList[modFileIndex].applyLocations;
                          // if (curJsonModFilesList[modFileIndex].previewImages != null) modFile.previewImages = curJsonModFilesList[modFileIndex].previewImages;
                          // if (curJsonModFilesList[modFileIndex].previewVideos != null) modFile.previewVideos = curJsonModFilesList[modFileIndex].previewVideos;
                          modFile.isSet = curJsonModFilesList[modFileIndex].isSet;
                          modFile.setNames = curJsonModFilesList[modFileIndex].setNames;

                          // Check applied mods for changes
                          if (modFile.applyStatus) {
                            for (var path in modFile.ogLocations) {
                              modFile.ogMd5s.clear();
                              modFile.ogMd5s.add(await File(path).getMd5Hash());
                              if (modFile.md5.isEmpty) modFile.md5 = await File(modFile.location).getMd5Hash();
                              if (!masterUnappliedItemList.contains(item) && modFile.ogMd5s.first != modFile.md5) {
                                masterUnappliedItemList.add(item);
                              }
                            }
                          }
                        } else {
                          modFile.isNew = true;
                          submod.isNew = true;
                          mod.isNew = true;
                          item.isNew = true;
                        }
                      }
                    } else {
                      submod.isNew = true;
                      mod.isNew = true;
                      item.isNew = true;
                    }
                    //creation date
                    submod.setLatestCreationDate();
                    if (mod.creationDate == DateTime(0) || submod.creationDate!.isAfter(mod.creationDate!)) mod.creationDate = submod.creationDate;
                    if (item.creationDate == DateTime(0) || submod.creationDate!.isAfter(item.creationDate!)) item.creationDate = submod.creationDate;
                  }
                } else {
                  mod.isNew = true;
                  item.isNew = true;
                }
                // sort
                // if (newModsOnTop) {
                //   mod.submods.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
                // } else {
                //   mod.submods.sort((a, b) => a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase()));
                // }
              }
            } else {
              item.isNew = true;
            }
            if (item.applyStatus && item.mods.where((element) => element.applyStatus).isEmpty) {
              item.applyStatus = false;
            }
            // sort
            // if (newModsOnTop) {
            //   item.mods.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
            // } else {
            //   item.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
            // }
          }
          // sort
          // if (itemsWithNewModsOnTop) {
          //   cate.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
          // } else {
          //   cate.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
          // }
        }
      }
      //sort cates in catetype
      // type.categories.sort(((a, b) => a.position.compareTo(b.position)));
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
  // cateTypes.map((cateType) => cateType.toJson()).toList();
  // const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  // File(mainModListJsonPath).writeAsStringSync(encoder.convert(cateTypes));

  //Get hidden catetypes and cates
  // if (isEmptyCatesHide) {
  //   hideAllEmptyCategories(cateTypes);
  // }
  // hiddenItemCategories = await hiddenCategoriesGet(cateTypes);

  return cateTypes;
}

Future<List<Item>> itemsFetcher(context, String catePath, bool reload) async {
  final itemInCategory = Directory(catePath).listSync(recursive: false).whereType<Directory>();
  List<Item> items = [];
  //List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
  for (var dir in itemInCategory) {
    List<Mod> modList = await modsFetcher(dir.path, p.basename(catePath));

    //Get item icon
    List<String> itemIcons = [];
    List<String> nameVariants = [];

    //CLear temp dir
    // clearModAdderDirs();

    if (!cateToIgnoreScan.contains(p.basename(catePath))) {
      final iconFilesInDir = dir.listSync().whereType<File>().where((element) => p.extension(element.path) == '.png' || p.extension(element.path) == '.jpg');
      // if (isAutoFetchingIconsOnStartup == 'off') {
      //   if (iconFilesInDir.where((element) => p.basenameWithoutExtension(element.path) == p.basename(dir.path)).isNotEmpty) {
      //     itemIcons.addAll(iconFilesInDir.map((e) => e.path));
      //   }
      // } else if (isAutoFetchingIconsOnStartup == 'minimal') {
      //   if (iconFilesInDir.where((element) => p.basenameWithoutExtension(element.path) == p.basename(dir.path)).isNotEmpty) {
      //     itemIcons.addAll(iconFilesInDir.map((e) => e.path));
      //   } else {
      //     final downloadedIconPath = await autoItemIconFetcherMinimal(playerItemData, dir.path, modList);
      //     if (downloadedIconPath.isNotEmpty) {
      //       itemIcons.add(downloadedIconPath);
      //     }
      //   }
      // } else if (isAutoFetchingIconsOnStartup == 'all') {
      //   itemIcons.addAll(iconFilesInDir.map((e) => e.path));
      //   if (!reload) {
      //     final downloadedIconPaths = await autoItemIconFetcherFull(playerItemData, dir.path, modList);
      //     if (downloadedIconPaths.isNotEmpty) {
      //       itemIcons.addAll(downloadedIconPaths);
      //     }
      //   }
      // }
      // if (iconFilesInDir.where((element) => p.basenameWithoutExtension(element.path) == p.basename(dir.path)).isNotEmpty) {
      itemIcons.addAll(iconFilesInDir.where((e) => e.existsSync()).map((e) => e.path));
      // }
      // if (itemIcons.isEmpty) {
      // itemIcons.add('assets/img/placeholdersquare.png');
      // }
    }

    items.add(
        Item(p.basename(dir.path), '', nameVariants, itemIcons, '', '', '', false, p.basename(catePath), Uri.file(dir.path).toFilePath(), false, DateTime(0), 0, false, false, false, [], modList));
  }
  // clearModAdderDirs();

  //backup all json files
  // await jsonAutoBackup();

  return items;
}

Future<List<Mod>> modsFetcher(String itemPath, String cateName) async {
  final foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  List<Mod> mods = [];
  //Get modfiles in item folder
  List<ModFile> modFilesInItemDir = [];
  List<File> iceFilesInItemDir =
      Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '' && p.basenameWithoutExtension(element.path).length > 29).toList();
  if (iceFilesInItemDir.isNotEmpty) {
    for (var iceFile in iceFilesInItemDir) {
      final previewFilesInMainModDir = Directory(iceFile.parent.path)
          .listSync(recursive: false)
          .whereType<File>()
          .where((element) => p.extension(element.path) != '' && p.basenameWithoutExtension(element.path) == p.basename(iceFile.path))
          .toList();
      modFilesInItemDir.add(ModFile(
          p.basename(iceFile.path),
          p.basename(itemPath),
          p.basename(itemPath),
          p.basename(itemPath),
          cateName,
          '',
          [],
          iceFile.path,
          false,
          DateTime(0),
          0,
          false,
          false,
          false,
          [],
          [],
          [],
          [],
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.png' || p.extension(element.path) == '.jpg').map((e) => e.path).toList(),
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.mp4' || p.extension(element.path) == '.webm').map((e) => e.path).toList()));
    }
    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where(((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png'));
    for (var element in imagesInModDir) {
      bool isIconImage = false;
      for (var part in p.basenameWithoutExtension(itemPath).split(' ')) {
        if (p.basenameWithoutExtension(element.path).contains(part)) {
          isIconImage = true;
          break;
        }
      }
      if (!isIconImage) {
        modPreviewImages.add(Uri.file(element.path).toFilePath());
      }
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    //add to submod
    SubMod subModInItemDir = SubMod(p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, false, [], false, false, -1, -1, '', [],
        [], modPreviewImages, modPreviewVideos, [], modFilesInItemDir);

    //add to mod
    mods.add(Mod(p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], [subModInItemDir]));
  }

  //Get modfiles in mod folders
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

    List<SubMod> newMod = await subModFetcher(dir.path, cateName, p.basename(itemPath));
    if (newMod.isNotEmpty) {
      mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], newMod));
    }
  }

  return mods;
}

Future<List<SubMod>> subModFetcher(String modPath, String cateName, String itemName) async {
  List<SubMod> submods = [];
  //ices in main mod dir
  final filesInMainModDir =
      Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '' && p.basenameWithoutExtension(element.path).length > 29).toList();
  if (filesInMainModDir.isNotEmpty) {
    List<ModFile> modFiles = [];
    for (var file in filesInMainModDir) {
      //final ogFilePaths = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }
      final previewFilesInMainModDir = Directory(file.parent.path)
          .listSync(recursive: false)
          .whereType<File>()
          .where((element) => p.extension(element.path) != '' && p.basenameWithoutExtension(element.path) == p.basename(file.path))
          .toList();
      modFiles.add(ModFile(
          p.basename(file.path),
          p.basename(modPath),
          p.basename(modPath),
          itemName,
          cateName,
          '',
          [],
          file.path,
          false,
          DateTime(0),
          0,
          false,
          false,
          false,
          [],
          [],
          [],
          [],
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.png' || p.extension(element.path) == '.jpg').map((e) => e.path).toList(),
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.mp4' || p.extension(element.path) == '.webm').map((e) => e.path).toList()));
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
      if (!await File('${p.withoutExtension(element.path)}.png').exists()) {
        final previewThumbnailData = await getVideoThumbnail(element.path);
        if (previewThumbnailData != null) {
          await File('${p.withoutExtension(element.path)}.png').writeAsBytes(previewThumbnailData);
        }
      }
    }

    //get cmx file
    bool hasCmx = false;
    final cmxFile = Directory(modPath)
        .listSync(recursive: false)
        .whereType<File>()
        .firstWhere((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig'), orElse: () => File(''))
        .path;
    if (cmxFile.isNotEmpty) {
      hasCmx = true;
    }

    if (modFiles.isNotEmpty) {
      submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, false, false, false, [], hasCmx, false, -1, -1, cmxFile, [], [],
          modPreviewImages, modPreviewVideos, [], modFiles));
      modLoadingStatus.value = '$cateName\n$itemName\n${p.basename(modPath)}\n${p.basename(modPath)}';
      await Future.delayed(const Duration(microseconds: 1000));
    }
  }

  //ices in submod dirs
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
      if (!await File('${p.withoutExtension(element.path)}.png').exists()) {
        final previewThumbnailData = await getVideoThumbnail(element.path);
        if (previewThumbnailData != null) {
          await File('${p.withoutExtension(element.path)}.png').writeAsBytes(previewThumbnailData);
        }
      }
    }

    //get cmx file
    bool hasCmx = false;
    final cmxFile = Directory(dir.path)
        .listSync(recursive: false)
        .whereType<File>()
        .firstWhere((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig'), orElse: () => File(''))
        .path;
    if (cmxFile.isNotEmpty) {
      hasCmx = true;
    }

    final filesInDir =
        Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '' && p.basenameWithoutExtension(element.path).length > 29).toList();
    List<ModFile> modFiles = [];
    for (var file in filesInDir) {
      //final ogFilePaths = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }

      List<String> parentPaths = file.parent.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);

      final previewFilesInMainModDir = Directory(file.parent.path)
          .listSync(recursive: false)
          .whereType<File>()
          .where((element) => p.extension(element.path) != '' && p.basenameWithoutExtension(element.path) == p.basename(file.path))
          .toList();

      modFiles.add(ModFile(
          p.basename(file.path),
          parentPaths.join(' > '),
          p.basename(modPath),
          itemName,
          cateName,
          '',
          [],
          file.path,
          false,
          DateTime(0),
          0,
          false,
          false,
          false,
          [],
          [],
          [],
          [],
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.png' || p.extension(element.path) == '.jpg').map((e) => e.path).toList(),
          previewFilesInMainModDir.where((element) => p.extension(element.path) == '.mp4' || p.extension(element.path) == '.webm').map((e) => e.path).toList()));
    }

    //Get submod name
    if (modFiles.isNotEmpty) {
      List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);
      submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, false, false, false, [], hasCmx, false, -1, -1, cmxFile, [], [],
          modPreviewImages, modPreviewVideos, [], modFiles));
      modLoadingStatus.value = '$cateName\n$itemName\n${p.basename(modPath)}\n${parentPaths.join(' > ')}';
      await Future.delayed(const Duration(microseconds: 1000));
    }
  }

  return submods;
}

void saveMasterModListToJson() {
  //Save to json
  masterModList.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainModListJsonPath).writeAsStringSync(encoder.convert(masterModList));
}

Future<Uint8List?> getVideoThumbnail(String videoPath) async {
  Player tempPlayer = Player();
  final controller = VideoController(tempPlayer);
  await controller.player.open(Media(videoPath), play: false);
  await controller.player.setVolume(0);
  await controller.player.seek(Duration(seconds: 4));
  await controller.player.pause();
  final videoThumbnail = await controller.player.screenshot(format: 'image/png');
  tempPlayer.dispose();

  return videoThumbnail;
}
