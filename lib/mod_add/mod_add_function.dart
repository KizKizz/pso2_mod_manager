import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_grid.dart';
import 'package:pso2_mod_manager/mod_add/new_mod_name_popup.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:signals/signals_flutter.dart';
import 'package:http/http.dart' as http;

String modAddTempUnpackedDirPath = '$modAddTempDirPath${p.separator}unpacked';
String modAddTempSortedDirPath = '$modAddTempDirPath${p.separator}sorted';

Future<void> modAddUnpack(context, List<String> addedPaths) async {
  for (var path in addedPaths) {
    String unpackedDirPath = modAddTempUnpackedDirPath + p.separator + p.basenameWithoutExtension(path);
    if (await FileSystemEntity.isFile(path)) {
      if (p.extension(path) == '.zip') {
        await extractFileToDisk(path, unpackedDirPath);
      } else if (p.extension(path) == '.rar') {
        if (Platform.isLinux) {
          Directory(unpackedDirPath).createSync(recursive: true);
          await Process.run('unrar', ['e', path, (unpackedDirPath)]);
        } else {
          await Process.run(sevenZipExePath, ['x', path, '-o$unpackedDirPath', '-r']);
        }
      } else if (p.extension(path) == '.7z') {
        await Process.run(sevenZipExePath, ['x', path, '-o$unpackedDirPath', '-r']);
      } else if (p.extension(path) == '.pmm') {
        await Directory(modAddTempUnpackedDirPath).create(recursive: true);
        File copiedFile = await File(path).copy('$modAddTempUnpackedDirPath${p.separator}${p.basenameWithoutExtension(path)}.zip');
        File renamedFile = await copiedFile.rename('${p.withoutExtension(copiedFile.path)}.zip');
        await extractFileToDisk(renamedFile.path, modAddTempUnpackedDirPath);
        await renamedFile.delete();
      } else {
        String tempParentDirPath = modAddTempUnpackedDirPath + p.separator + p.basenameWithoutExtension(await newModNamePopup(context));
        if (Directory(modAddTempUnpackedDirPath).existsSync() && Directory(tempParentDirPath).existsSync()) {
          tempParentDirPath.renameDuplicate();
        }
        Directory(tempParentDirPath).createSync(recursive: true);
        if (File(path).existsSync()) await File(path).copy(tempParentDirPath + p.separator + p.basename(path));
      }
    } else if (FileSystemEntity.isDirectorySync(path)) {
      if (Directory(modAddTempUnpackedDirPath).existsSync() && Directory(unpackedDirPath).existsSync()) {
        await io.copyPath(path, unpackedDirPath.renameDuplicate());
      } else {
        await io.copyPath(path, unpackedDirPath);
      }
    }
  }
}

Future<List<AddingMod>> modAddSort() async {
  // Remove empty root parent dir
  for (var dir in Directory(modAddTempUnpackedDirPath).listSync().whereType<Directory>()) {
    final innerDirs = dir.listSync();
    if (innerDirs.length == 1 && FileSystemEntity.isDirectorySync(innerDirs.first.path)) {
      await io.copyPath(innerDirs.first.path, dir.parent.path + p.separator + p.basename(innerDirs.first.path));
      await innerDirs.first.delete(recursive: true);
    }
  }
  // Check for duplicates
  for (var dir in Directory(modAddTempUnpackedDirPath).listSync().whereType<Directory>().where((e) => e.listSync(recursive: true).whereType<File>().isNotEmpty)) {
    String sortedPath = dir.path.replaceFirst(modAddTempUnpackedDirPath, modAddTempSortedDirPath);
    if (Directory(sortedPath).existsSync()) {
      await io.copyPath(dir.path, sortedPath.renameDuplicate());
    } else {
      await io.copyPath(dir.path, sortedPath);
    }
  }
  await Directory(modAddTempUnpackedDirPath).delete(recursive: true);

  // Remove reboots
  for (var modDir in Directory(modAddTempSortedDirPath).listSync(recursive: true).whereType<Directory>().toSet()) {
    if (modDir.listSync().whereType<Directory>().isEmpty) {
      String newPath = await removeRebootPath(modDir.path);
      if (modDir.path != newPath) {
        await io.copyPath(modDir.path, newPath);
        await modDir.delete(recursive: true);
      }
    }
  }
  // Remove empty dirs
  for (var dir in Directory(modAddTempSortedDirPath).listSync(recursive: true).whereType<Directory>()) {
    if (dir.existsSync() && dir.listSync().isEmpty) await dir.delete(recursive: true);
  }

  List<AddingMod> addingModList = [];
  List<Directory> modDirs = Directory(modAddTempSortedDirPath).listSync().whereType<Directory>().toList();

  // Get files tree
  for (var modDir in modDirs) {
    List<Directory> submods = [];
    List<String> submodNames = [];
    List<ItemData> associatedItems = [];
    List<File> previewImages = [];
    List<File> previewVideos = [];
    // mod dir
    List<File> modDirFiles = modDir.listSync().whereType<File>().toList();
    if (modDirFiles.isNotEmpty && modDirFiles.indexWhere((e) => p.extension(e.path) == '') != -1) {
      submods.add(modDir);
      submodNames.add(p.basename(modDir.path));
      associatedItems.addAll(await matchItemData(associatedItems, modDirFiles.map((e) => e.path).toList()));
    }
    previewImages.addAll(modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
    previewVideos.addAll(modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
    // sub dirs
    for (var subdir in modDir.listSync(recursive: true).whereType<Directory>().toSet()) {
      List<File> files = subdir.listSync(recursive: true).whereType<File>().toList();
      if (files.isNotEmpty && files.indexWhere((e) => p.extension(e.path) == '') != -1) {
        submods.add(subdir);
        submodNames.add(subdir.path.replaceFirst(modDir.path + p.separator, '').trim().replaceAll(p.separator, ' > '));
        associatedItems.addAll(await matchItemData(associatedItems, files.map((e) => e.path).toList()));
        final previewImageFiles = files.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png');
        final previewVideoFiles = files.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4');
        previewImages.addAll(previewImageFiles);
        previewVideos.addAll(previewVideoFiles);
        if (previewImageFiles.isEmpty) {
          for (var file in modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png')) {
            await file.copy(file.path.replaceFirst(file.parent.path, subdir.path));
          }
        }
        if (previewVideoFiles.isEmpty) {
          for (var file in modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4')) {
            await file.copy(file.path.replaceFirst(file.parent.path, subdir.path));
          }
        }
      }
    }

    AddingMod newAddingModItem = AddingMod(
        modDir, true, submods, submodNames, List.generate(submods.length, (int i) => true), associatedItems, List.generate(associatedItems.length, (int i) => true), previewImages, previewVideos);

    // Rename duplicates
    for (var aItem in associatedItems) {
      String newItemDirDestPath = mainModDirPath + p.separator + aItem.category + p.separator + aItem.getName();
      bool renamed = false;
      for (var submod in newAddingModItem.submods.reversed) {
        if (submod != modDir && Directory(submod.path.replaceFirst(modAddTempSortedDirPath, newItemDirDestPath)).existsSync()) {
          await io.copyPath(submod.path, submod.path.renameDuplicate());
          await submod.delete(recursive: true);
          renamed = true;
        }
      }
      if (renamed) newAddingModItem = await modAddRenameRefresh(modDir, newAddingModItem);
    }

    addingModList.add(newAddingModItem);
  }

  return addingModList;
}

Future<List<Item>> modAddToMasterList(bool addingToSet, List<ModSet> modSets) async {
  List<Item> addedItems = [];
  for (var modAddingItem in modAddingList) {
    for (int i = 0; i < modAddingItem.associatedItems.length; i++) {
      if (modAddingItem.aItemAddingStates[i]) {
        final item = modAddingItem.associatedItems[i];

        String category = item.category;
        String itemName = item.getName().replaceAll(RegExp(charToReplace), '_');
        String newItemDirDestPath = mainModDirPath + p.separator + category + p.separator + itemName;

        for (int j = 0; j < modAddingItem.submods.length; j++) {
          if (!modAddingItem.submodAddingStates[j]) {
            await modAddingItem.submods[j].delete(recursive: true);
          }
        }

        await io.copyPath(modAddingItem.modDir.path, modAddingItem.modDir.path.replaceFirst(modAddTempSortedDirPath, newItemDirDestPath));
        if (Directory(newItemDirDestPath).existsSync() && Directory(newItemDirDestPath).listSync().whereType<File>().toList().indexWhere((e) => p.basename(e.path) == '$itemName.png') == -1) {
          final response = await http.get(Uri.parse(githubIconDatabaseLink + item.iconImagePath));
          if (response.statusCode == 200) File(newItemDirDestPath + p.separator + p.basename(item.iconImagePath)).writeAsBytesSync(response.bodyBytes);
        }

        //Add to current moddedItemList
        for (var cateType in masterModList) {
          int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == category);
          if (cateIndex != -1) {
            Category cateInList = cateType.categories[cateIndex];
            int itemInListIndex = cateInList.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              Item newItem = await newItemsFetcher('$mainModDirPath${p.separator}$category', newItemDirDestPath, addingToSet, modSets.map((e) => e.setName).toList());
              addedItems.add(newItem);
              if (addingToSet) {
                for (var set in modSets) {
                  if (set.setItems.indexWhere((e) => e.location == newItem.location) == -1) set.addItem(newItem);
                }
              }
              cateInList.items.add(newItem);
            } else {
              Item itemInList = cateInList.items[itemInListIndex];
              int modInListIndex = itemInList.mods.indexWhere((element) => element.modName.toLowerCase() == p.basename(modAddingItem.modDir.path).toLowerCase());
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, cateInList.categoryName, itemInList.itemName, addingToSet, modSets.map((e) => e.setName).toList());
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                if (addingToSet) {
                  for (var set in modSets) {
                    if (!modInList.setNames.contains(set.setName)) modInList.setNames.add(set.setName);
                  }
                }
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, cateInList.categoryName, [Directory(newItemDirDestPath + p.separator + p.basename(modAddingItem.modDir.path))], addingToSet,
                    modSets.map((e) => e.setName).toList()));
              }
              itemInList.setLatestCreationDate();
              itemInList.isNew = true;
              addedItems.add(itemInList);
              if (addingToSet) {
                for (var set in modSets) {
                  if (set.setItems.indexWhere((e) => e.location == itemInList.location) == -1) set.addItem(itemInList);
                }
              }
              //Sort
              // itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
            }
            //Sort
            // if (itemsWithNewModsOnTop) {
            //   cateInList.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
            // } else {
            //   cateInList.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            // }
            // cateInList.visible = cateInList.items.isNotEmpty ? true : false;
            // cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          } else if (cateType.groupName == defaultCategoryTypes[2]) {
            Category newCate = Category(category, cateType.groupName, Uri.file('$mainModDirPath/$category').toFilePath(), cateType.categories.length, true, []);
            int itemInListIndex = newCate.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              Item newItem = await newItemsFetcher(Uri.file('$mainModDirPath/$category').toFilePath(), newItemDirDestPath, addingToSet, modSets.map((e) => e.setName).toList());
              addedItems.add(newItem);
              if (addingToSet) {
                for (var set in modSets) {
                  if (set.setItems.indexWhere((e) => e.location == newItem.location) == -1) set.addItem(newItem);
                }
              }
              newCate.items.add(newItem);
            } else {
              Item itemInList = newCate.items[itemInListIndex];
              int modInListIndex = itemInList.mods.indexWhere((element) => element.modName.toLowerCase() == p.basename(modAddingItem.modDir.path).toLowerCase());
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, newCate.categoryName, itemInList.itemName, addingToSet, modSets.map((e) => e.setName).toList());
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                if (addingToSet) {
                  for (var set in modSets) {
                    if (!modInList.setNames.contains(set.setName)) modInList.setNames.add(set.setName);
                  }
                }
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, newCate.categoryName, [Directory(newItemDirDestPath + p.separator + p.basename(modAddingItem.modDir.path))], addingToSet,
                    modSets.map((e) => e.setName).toList()));
              }
              itemInList.isNew = true;
              addedItems.add(itemInList);
              if (addingToSet) {
                for (var set in modSets) {
                  if (set.setItems.indexWhere((e) => e.location == itemInList.location) == -1) set.addItem(itemInList);
                }
              }
              //Sort alpha
              // itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
            }
            //Sort
            // if (itemsWithNewModsOnTop) {
            //   newCate.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
            // } else {
            //   newCate.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            // }
            newCate.visible = newCate.items.isNotEmpty ? true : false;
            cateType.categories.add(newCate);
            cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          }
        }
      }
    }
    // Remove dir in sorted
    await modAddingItem.modDir.delete(recursive: true);
  }

  mainGridStatus.value = '${modAddingList.map((e) => e.submodNames).join(', ')} added';
  modAddingList.removeWhere((e) => !e.modDir.existsSync());
  return addedItems;
}

// Helpers
Future<List<ItemData>> matchItemData(List<ItemData> matchedItemData, List<String> filePaths) async {
  List<ItemData> associatedItems = [];

  for (var filePath in filePaths.where((e) => p.extension(e) == '')) {
    modAddProcessingStatus.value = p.basename(filePath).toString();
    await Future.delayed(const Duration(microseconds: 10));

    if (matchedItemData.where((e) => e.containsIce(p.basename(filePath))).isNotEmpty || associatedItems.where((e) => e.containsIce(p.basename(filePath))).isNotEmpty) {
      continue;
    } else {
      for (var itemData in pItemData) {
        if (itemData.getName().isNotEmpty &&
            itemData.containsIce(p.basename(filePath)) &&
            matchedItemData.indexWhere((e) => e.getName() == itemData.getName()) == -1 &&
            associatedItems.indexWhere((e) => e.getName() == itemData.getName()) == -1) {
          associatedItems.add(itemData);
        }
      }
    }
  }

  return associatedItems;
}

Future<String> removeRebootPath(String dirPath) async {
  if (dirPath.isEmpty) return dirPath;

  String oFilePath = '';
  for (var file in Directory(dirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '')) {
    oFilePath = oItemData
        .firstWhere(
          (e) => p.basenameWithoutExtension(e.path) == p.basename(file.path),
          orElse: () => OfficialIceFile('', '', 0, ''),
        )
        .path;
    if (oFilePath.isNotEmpty) {
      String newPath = '';
      final oFilePathDetails = p.dirname(oFilePath).split('/');
      List<String> filePathDetails = dirPath.split(p.separator);
      filePathDetails.removeWhere((e) => oFilePathDetails.contains(e));
      newPath = p.joinAll(filePathDetails);
      if (Platform.isLinux) newPath = p.separator + newPath;
      return newPath;
    }
  }

  return dirPath;
}

Future<AddingMod> modAddRenameRefresh(Directory modDir, AddingMod currentAddingMod) async {
  List<Directory> submods = [];
  List<String> submodNames = [];
  List<File> previewImages = [];
  List<File> previewVideos = [];
  // mod dir
  List<File> modDirFiles = modDir.listSync().whereType<File>().toList();
  if (modDirFiles.isNotEmpty && modDirFiles.indexWhere((e) => p.extension(e.path) == '') != -1) {
    submods.add(modDir);
    submodNames.add(p.basename(modDir.path));
    previewImages.addAll(modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
    previewVideos.addAll(modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
  }
  // sub dirs
  for (var subdir in modDir.listSync(recursive: true).whereType<Directory>().toSet()) {
    List<File> files = subdir.listSync(recursive: true).whereType<File>().toList();
    if (files.isNotEmpty && files.indexWhere((e) => p.extension(e.path) == '') != -1) {
      submods.add(subdir);
      submodNames.add(subdir.path.replaceFirst(modDir.path + p.separator, '').trim().replaceAll(p.separator, ' > '));
      previewImages.addAll(files.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
      previewVideos.addAll(files.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
    }
  }

  return AddingMod(modDir, true, submods, submodNames, currentAddingMod.submodAddingStates, currentAddingMod.associatedItems, currentAddingMod.aItemAddingStates, previewImages, previewVideos);
}

Future<List<String>> modAddFilterListFetch() async {
  if (!File(modAddFilterListFilePath).existsSync()) {
    await File(modAddFilterListFilePath).create(recursive: true);
  }
  return (await File(modAddFilterListFilePath).readAsString()).split(', ');
}

// Add to master list helpers
Future<Item> newItemsFetcher(String catePath, String itemPath, bool addingToSet, List<String> modSetNames) async {
  //Get icons from dir
  List<String> itemIcons = [];
  final imagesFoundInItemDir = Directory(itemPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
  if (imagesFoundInItemDir.isNotEmpty) {
    itemIcons = imagesFoundInItemDir.map((e) => e.path).toList();
  } else {
    itemIcons = ['assets/img/placeholdersquare.png'];
  }

  Item newItem = Item(p.basename(itemPath), [], itemIcons, '', '', '', false, p.basename(catePath), Uri.file(itemPath).toFilePath(), false, DateTime(0), 0, false, addingToSet ? true : false, true,
      addingToSet ? modSetNames : [], newModsFetcher(itemPath, p.basename(catePath), [], addingToSet, modSetNames));
  newItem.setLatestCreationDate();

  return newItem;
}

List<Mod> newModsFetcher(String itemPath, String cateName, List<Directory> newModFolders, bool addingToSet, List<String> modSetNames) {
  List<Directory> foldersInItemPath = [];
  if (newModFolders.isEmpty) {
    foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  } else {
    foldersInItemPath = newModFolders;
  }
  List<Mod> mods = [];

  //Get modfiles in item folder
  List<ModFile> modFilesInItemDir = [];
  List<File> iceFilesInItemDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
  if (iceFilesInItemDir.isNotEmpty) {
    for (var iceFile in iceFilesInItemDir) {
      modFilesInItemDir.add(ModFile(p.basename(iceFile.path), p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, '', [], iceFile.path, false, DateTime(0), 0, false,
          addingToSet ? true : false, true, addingToSet ? modSetNames : [], [], [], [], [], []));
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
    SubMod subModInItemDir = SubMod(p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, addingToSet ? true : false, [], false,
        false, -1, -1, '', addingToSet ? modSetNames : [], [], modPreviewImages, modPreviewVideos, [], modFilesInItemDir);
    subModInItemDir.setLatestCreationDate();

    //add to mod
    Mod newMod = Mod(p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, addingToSet ? true : false, addingToSet ? modSetNames : [], modPreviewImages,
        modPreviewVideos, [], [subModInItemDir]);
    newMod.setLatestCreationDate();
    mods.add(newMod);
  }

  // get submods in mod folders
  for (var dir in foldersInItemPath) {
    //Get preview images;
    List<String> modPreviewImages = [];
    List<String> modPreviewVideos = [];

    if (dir.existsSync()) {
      final imagesInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
      for (var element in imagesInModDir) {
        modPreviewImages.add(Uri.file(element.path).toFilePath());
      }
      //Get preview videos;

      final videosInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
      for (var element in videosInModDir) {
        modPreviewVideos.add(Uri.file(element.path).toFilePath());
      }
    }

    Mod newMod = Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, true, false, addingToSet ? true : false, addingToSet ? modSetNames : [], modPreviewImages,
        modPreviewVideos, [], newSubModFetcher(dir.path, cateName, p.basename(itemPath), addingToSet, modSetNames));
    newMod.setLatestCreationDate();
    mods.add(newMod);
  }

  //Sort alpha
  // mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));

  return mods;
}

List<SubMod> newSubModFetcher(String modPath, String cateName, String itemName, bool addingToSet, List<String> modSetNames) {
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
      modFiles.add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, addingToSet ? true : false, true,
          addingToSet ? modSetNames : [], [], [], [], [], []));
      //Sort alpha
      modFiles.sort((a, b) => a.modFileName.toLowerCase().compareTo(b.modFileName.toLowerCase()));
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
    final cmxFile = Directory(modPath)
        .listSync(recursive: false)
        .whereType<File>()
        .firstWhere((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig'), orElse: () => File(''))
        .path;
    if (cmxFile.isNotEmpty) {
      hasCmx = true;
    }

    SubMod newSubmod = SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, true, false, addingToSet ? true : false, [], hasCmx, false, -1, -1, cmxFile,
        addingToSet ? modSetNames : [], [], modPreviewImages, modPreviewVideos, [], modFiles);
    newSubmod.setLatestCreationDate();

    submods.add(newSubmod);
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

      modFiles.add(ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, addingToSet ? true : false, true,
          addingToSet ? modSetNames : [], [], [], [], [], []));
      //Sort alpha
      modFiles.sort((a, b) => a.modFileName.toLowerCase().compareTo(b.modFileName.toLowerCase()));
    }

    //Get submod name
    List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
    parentPaths.removeWhere((element) => element.isEmpty);
    SubMod newSubmod = SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, true, false, addingToSet ? true : false, [], hasCmx, false, -1, -1,
        cmxFile, addingToSet ? modSetNames : [], [], modPreviewImages, modPreviewVideos, [], modFiles);
    newSubmod.setLatestCreationDate();

    submods.add(newSubmod);
  }

  //remove empty submods
  submods.removeWhere((element) => element.modFiles.isEmpty);

  //Sort alpha
  // submods.sort((a, b) => a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase()));

  return submods;
}

Future<String> modAdderNewModSetDialog(context) async {
  TextEditingController newModSetName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                // title: Text(curLangText!.uiCreateASetForImportedMods, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                actionsPadding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                content: Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newModSetName,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (masterModSetList.where((element) => element.setName == newModSetName.text).isNotEmpty) {
                        return appText.nameAlreadyExists;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: appText.enterNewNameHere,
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        //isCollapsed: true,
                        //isDense: true,
                        contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                        constraints: const BoxConstraints.tightForFinite(),
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(2),
                        )),
                    onChanged: (value) async {
                      setState(() {});
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      onPressed: newModSetName.value.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newModSetName.text);
                              }
                            },
                      child: Text(appText.add)),
                  ElevatedButton(
                      child: Text(appText.returns),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                ]);
          }));
}
