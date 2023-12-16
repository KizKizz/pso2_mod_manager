// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/functions/item_variants_fetcher.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/show_hide_cates.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<CategoryType>> modFileStructureLoader(context, bool reload) async {
  ogModFilesLoader();

  List<CategoryType> structureFromJson = [];
  List<CategoryType> cateTypes = [];

  if (isAutoFetchingIconsOnStartup != 'off') {
    //load sheets
    if (csvInfosFromSheets.isEmpty) {
      csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
    }
  }

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
      type.position = typeIndex;
      type.expanded = structureFromJson[typeIndex].expanded;
      type.visible = isEmptyCatesHide && type.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : structureFromJson[typeIndex].visible;
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
                  }
                } else {
                  mod.isNew = true;
                  item.isNew = true;
                }
              }
            } else {
              item.isNew = true;
            }
            if (item.applyStatus && item.mods.where((element) => element.applyStatus).isEmpty) {
              item.applyStatus = false;
            }
          }
          cate.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
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
  cateTypes.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModsListJsonPath).writeAsStringSync(encoder.convert(cateTypes));

  //Clear refsheets
  // if (itemIconRefSheetsList.isNotEmpty) {
  //   itemIconRefSheetsList.clear();
  // }
  if (csvInfosFromSheets.isNotEmpty) {
    csvInfosFromSheets.clear();
  }

  //Get hidden catetypes and cates
  if (isEmptyCatesHide) {
    hideAllEmptyCategories(cateTypes);
  }
  hiddenItemCategories = await hiddenCategoriesGet(cateTypes);

  return cateTypes;
}

Future<List<Item>> itemsFetcher(context, String catePath, bool reload) async {
  final itemInCategory = Directory(catePath).listSync(recursive: false).whereType<Directory>();
  List<Item> items = [];
  //List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
  for (var dir in itemInCategory) {
    List<Mod> modList = modsFetcher(dir.path, p.basename(catePath));

    //Get item icon
    List<String> itemIcons = [];
    List<String> nameVariants = [];

    //CLear temp dir
    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      if (element.existsSync()) {
        element.deleteSync(recursive: true);
      }
    });

    if (cateToIgnoreScan.contains(p.basename(catePath))) {
      itemIcons.add('assets/img/placeholdersquare.png');
    } else {
      final iconFilesInDir = dir.listSync().whereType<File>().where((element) => p.extension(element.path) == '.png');
      if (isAutoFetchingIconsOnStartup == 'off') {
        if (iconFilesInDir.where((element) => p.basenameWithoutExtension(element.path) == p.basenameWithoutExtension(dir.path)).isNotEmpty) {
          itemIcons.addAll(iconFilesInDir.map((e) => e.path));
        }
      } else if (isAutoFetchingIconsOnStartup == 'minimal') {
        if (iconFilesInDir.where((element) => p.basenameWithoutExtension(element.path) == p.basenameWithoutExtension(dir.path)).isNotEmpty) {
          itemIcons.addAll(iconFilesInDir.map((e) => e.path));
        } else {
          final iconIceDownloadPath = await autoItemIconFetcherMinimal(dir.path, modList);
          if (iconIceDownloadPath.isNotEmpty) {
            String tempIconUnpackDirPath = Uri.file('$modManAddModsTempDirPath/${p.basename(dir.path)}/tempItemIconUnpack').toFilePath();
            final downloadedconIcePath = await downloadIconIceFromOfficial(iconIceDownloadPath, tempIconUnpackDirPath);
            //unpack and convert dds to png
            if (downloadedconIcePath.isNotEmpty) {
              //debugPrint(downloadedconIcePath);
              await Process.run('$modManZamboniExePath -outdir "$tempIconUnpackDirPath"', [downloadedconIcePath]);
              File ddsItemIcon =
                  Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
              if (ddsItemIcon.path.isNotEmpty) {
                File newItemIcon = File(Uri.file('${dir.path}/${p.basename(dir.path)}.png').toFilePath());
                await Process.run(modManDdsPngToolExePath, [ddsItemIcon.path, newItemIcon.path, '-ddstopng']);
                itemIcons.add(newItemIcon.path);
              }
            }
          }
        }
      } else if (isAutoFetchingIconsOnStartup == 'all') {
        itemIcons.addAll(iconFilesInDir.map((e) => e.path));
        if (!reload) {
          final iconIceDownloadPaths = await autoItemIconFetcherFull(dir.path, modList, iconFilesInDir.toList());
          if (iconIceDownloadPaths.isNotEmpty) {
            for (var iconIceDownloadPath in iconIceDownloadPaths) {
              String tempIconUnpackDirPath = Uri.file('$modManAddModsTempDirPath/${p.basename(dir.path)}/tempItemIconUnpack').toFilePath();
              final downloadedconIcePath = await downloadIconIceFromOfficial(iconIceDownloadPath.last, tempIconUnpackDirPath);
              //unpack and convert dds to png
              if (downloadedconIcePath.isNotEmpty) {
                //debugPrint(downloadedconIcePath);
                await Process.run('$modManZamboniExePath -outdir "$tempIconUnpackDirPath"', [downloadedconIcePath]);
                File ddsItemIcon =
                    Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
                if (ddsItemIcon.path.isNotEmpty) {
                  File newItemIcon = File(Uri.file('${dir.path}/${iconIceDownloadPath.first}.png').toFilePath());
                  await Process.run(modManDdsPngToolExePath, [ddsItemIcon.path, newItemIcon.path, '-ddstopng']);
                  itemIcons.add(newItemIcon.path);
                }
              }
            }
          }
        }
      }
      if (itemIcons.isEmpty) {
        itemIcons.add('assets/img/placeholdersquare.png');
      }
    }

    items.add(Item(p.basename(dir.path), nameVariants, itemIcons, p.basename(catePath), Uri.file(dir.path).toFilePath(), false, DateTime(0), 0, false, false, false, [], modList));
    if (isAutoFetchingIconsOnStartup != 'off' && !reload) {
      Provider.of<StateProvider>(context, listen: false).setModsLoaderProgressStatus('${p.basename(dir.parent.path)}\n${p.basename(dir.path)}');
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });

  return items;
}

List<Mod> modsFetcher(String itemPath, String cateName) {
  final foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  List<Mod> mods = [];
  //Get modfiles in item folder
  List<ModFile> modFilesInItemDir = [];
  List<File> iceFilesInItemDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
  if (iceFilesInItemDir.isNotEmpty) {
    for (var iceFile in iceFilesInItemDir) {
      modFilesInItemDir.add(
          ModFile(p.basename(iceFile.path), p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, '', [], iceFile.path, false, DateTime(0), 0, false, false, false, [], [], []));
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
    SubMod subModInItemDir = SubMod(p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, false, false, false, -1, -1, [], [],
        modPreviewImages, modPreviewVideos, [], modFilesInItemDir);

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

    //get cmx file
    bool hasCmx = false;
    final cmxFiles = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig')).map((e) => e.path).toList();
    if (cmxFiles.isNotEmpty) {
      hasCmx = true;
    }

    if (modFiles.isNotEmpty) {
      submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, false, false, false, hasCmx, false, -1, -1, cmxFiles, [], modPreviewImages,
          modPreviewVideos, [], modFiles));
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
    }

    //get cmx file
    bool hasCmx = false;
    final cmxFiles = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig')).map((e) => e.path).toList();
    if (cmxFiles.isNotEmpty) {
      hasCmx = true;
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
      submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, false, false, false, hasCmx, false, -1, -1, cmxFiles, [], modPreviewImages,
          modPreviewVideos, [], modFiles));
    }
  }

  return submods;
}

void ogModFilesReset() {
  ogWin32FilePaths.clear();
  ogWin32NAFilePaths.clear();
  ogWin32RebootFilePaths.clear();
  ogWin32RebootNAFilePaths.clear();
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
    final mainDirs = Directory(Uri.file('$modManPso2binPath/data/win32reboot').toFilePath()).listSync().whereType<Directory>().where((element) => p.basename(element.path).length == 2);
    for (var dir in mainDirs) {
      ogWin32RebootFilePaths.addAll(dir.listSync().whereType<File>().where((element) => p.extension(element.path) == '').map((e) => e.path).toList());
    }

    // ogWin32RebootFilePaths = Directory(Uri.file('$modManPso2binPath/data/win32reboot').toFilePath())
    //     .listSync(recursive: true)
    //     .whereType<File>()
    //     .where((element) => p.extension(element.path) == '')
    //     .map((e) => e.path)
    //     .toList();
  }
  if (ogWin32RebootNAFilePaths.isEmpty && Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath()).existsSync()) {
    final mainDirs = Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath()).listSync().whereType<Directory>().where((element) => p.basename(element.path).length == 2);
    for (var dir in mainDirs) {
      ogWin32RebootNAFilePaths.addAll(dir.listSync().whereType<File>().where((element) => p.extension(element.path) == '').map((e) => e.path).toList());
    }

    // ogWin32RebootNAFilePaths = Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath())
    //     .listSync(recursive: true)
    //     .whereType<File>()
    //     .where((element) => p.extension(element.path) == '')
    //     .map((e) => e.path)
    //     .toList();
  }
}
