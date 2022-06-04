import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mods_loader.dart';

import 'main.dart';

import 'package:path/path.dart' as p;

Directory dataDir = Directory('$binDirPath\\data');

void modsToDataAdder(List<ModFile> modList) async {
  final iceFiles = dataDir.listSync(recursive: true).whereType<File>();
  List<List<ModFile>> duplicateModsApplied = [];
  //Checksum
  if (checkSumFilePath != null) {
    File(checkSumFilePath!).copySync('$binDirPath\\data\\win32\\${checkSumFilePath!.split('\\').last}');
  }

  for (var modFile in modList) {
    //Backup file check and apply

    final matchedFile = iceFiles.firstWhere(
      (e) => e.path.split('\\').last == modFile.iceName,
      orElse: () {
        return File('');
      },
    );

    if (matchedFile.path != '') {
      modFile.originalIcePath = matchedFile.path;
      originalFileFound = true;

      final backupFiles = Directory(backupDirPath).listSync(recursive: true).whereType<File>();
      final matchedBackup = backupFiles.firstWhere(
        (e) => p.extension(e.path) == '' && e.path.split('\\').last == modFile.iceName,
        orElse: () {
          return File('');
        },
      );

      if (matchedBackup.path == '') {
        modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
        //Backup file if not already
        File(modFile.originalIcePath).copySync(modFile.backupIcePath);
      } else {
        //check for dub applied mod
        modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
        duplicateModsApplied = modFilesList.where((element) => element.indexWhere((e) => e.iceName == modFile.iceName && e.isApplied == true) != -1).toList();

        for (var modList in duplicateModsApplied) {
          for (var element in modList) {
            modAppliedDup.add(element);
            File(element.backupIcePath).copySync(element.originalIcePath);
            element.isApplied = false;
            //print('${element.backupIcePath} ==== ${element.originalIcePath}');
          }
        }
        //print(duplicateModsApplied.first.first.icePath);
      }

      //File actions

      File(modFile.icePath).copySync(modFile.originalIcePath);
      modFile.isApplied = true;
      modFile.isNew = false;

      // for (var modList in modFilesList) {
      //   modList.map((mod) => mod.toJson()).toList();
      //   File(modSettingsPath).writeAsStringSync(json.encode(modList));
      // }
    } else {
      originalFileFound = false;
    }
  }

  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
}

void modsRemover(List<ModFile> modsList) {
  final backupFiles = Directory(backupDirPath).listSync(recursive: true).whereType<File>();
  for (var mod in modsList) {
    final matchedBackup = backupFiles.firstWhere(
      (e) => p.extension(e.path) == '' && e.path.split('\\').last == mod.iceName,
      orElse: () {
        return File('');
      },
    );

    if (matchedBackup.path != '') {
      backupFileFound = true;
      File(mod.backupIcePath).copySync(mod.originalIcePath);
      mod.isApplied = false;
      File(mod.backupIcePath).deleteSync();
    } else {
      backupFileFound = false;
    }
  }

  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
}

// New File Adders
void dragDropFilesAdd(List<XFile> newItemDragDropList, String? selectedCategoryName, String newItemName) {
  final categoryName = selectedCategoryName;
  final catePath = cateList.firstWhere((element) => element.categoryName == categoryName).categoryPath;

  for (var xFile in newItemDragDropList) {
    final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
    if (files.isNotEmpty) {
      for (var file in files) {
        final xFileTail = file.path.split(xFile.name).last;
        String newPath = '';
        if (newItemName.isEmpty) {
          newPath = '$catePath\\${xFile.name}$xFileTail';
        } else {
          newPath = '$catePath\\$newItemName$xFileTail';
        }

        //Write to Folder
        File(newPath).createSync(recursive: true);
        File(file.path).copySync(newPath);
      }
    }

    String modName = '';
    String newItemPath = '';
    bool dubItemFound = false;
    if (newItemName.isEmpty) {
      modName = xFile.name;
      newItemPath = '$catePath\\${xFile.name}';
    } else {
      modName = newItemName;
      newItemPath = '$catePath\\$newItemName';
    }

    //Add to list
    List<ModFile> newModList = [];
    final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
    for (var file in filesList) {
      if (p.extension(file.path) == '') {
        final iceName = file.path.split('\\').last;
        String iceParents = file.path.split(modName).last.split('\\$iceName').first.replaceAll('\\', ' > ');
        if (iceParents == '') {
          iceParents = '> $modName';
        }

        List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

        ModFile newModFile = ModFile(0, newItemPath, modName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true);
        newModFile.categoryName = selectedCategoryName.toString();
        newModFile.categoryPath = catePath;
        newModList.add(newModFile);

        //Json Write
        allModFiles.add(newModFile);
        allModFiles.map((mod) => mod.toJson()).toList();
        File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
      }
    }

    //Update Cate list
    final newModRoot = Directory(newItemPath).listSync(recursive: false).whereType<File>();
    final thumbnails = newModRoot.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png').toList();
    if (thumbnails.isEmpty) {
      thumbnails.add(File('assets/img/placeholdersquare.jpg'));
    }
    final selectedCategory = cateList.firstWhere((element) => element.categoryName == categoryName);
    if (selectedCategory.itemNames.indexWhere((element) => element == modName) == -1) {
      dubItemFound = false;
      selectedCategory.itemNames.add(modName);
    } else {
      dubItemFound = true;
    }

    if (!dubItemFound) {
      for (var cate in cateList) {
        if (cate.itemNames.indexWhere((e) => e == modName) != -1) {
          cate.allModFiles.addAll(newModList);
          //cate.allModFiles = [];
          cate.imageIcons.add(thumbnails);
          cate.numOfMods.add(newModList.length);
          cate.numOfItems++;
          cate.numOfApplied.add(0);
        }
      }
    }
  }
}

// New Mod Adders
void dragDropModsAdd(List<XFile> newModDragDropList, String curItemName, String itemPath, int index, String newItemName) {
  for (var xFile in newModDragDropList) {
    final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
    if (files.isNotEmpty) {
      for (var file in files) {
        final xFileTail = file.path.split(xFile.name).last;
        String newPath = '';
        if (newItemName.isEmpty) {
          newPath = '$itemPath\\${xFile.name}$xFileTail';
        } else {
          newPath = '$itemPath\\$newItemName$xFileTail';
        }

        File(newPath).createSync(recursive: true);
        File(file.path).copySync(newPath);
      }
    }

    String newModPath = '';
    if (newItemName.isEmpty) {
      newModPath = '$itemPath\\${xFile.name}';
    } else {
      newModPath = '$itemPath\\$newItemName';
    }

    //Add to list
    List<ModFile> newMods = [];
    final matchedCategory = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
    final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
    for (var file in filesList) {
      if (p.extension(file.path) == '') {
        final iceName = file.path.split('\\').last;
        final iceParents = file.path.split(curItemName).last.split('\\$iceName').first.replaceAll('\\', ' > ');
        List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

        ModFile newModFile = ModFile(0, newModPath, curItemName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true);
        newModFile.categoryName = matchedCategory.categoryName;
        newModFile.categoryPath = matchedCategory.categoryPath;
        newMods.add(newModFile);

        //Json Write
        allModFiles.add(newModFile);
        allModFiles.map((mod) => mod.toJson()).toList();
        File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
      }
    }

    modFilesList.add(newMods);

    matchedCategory.allModFiles.addAll(newMods);
    matchedCategory.numOfMods.add(newMods.length);
  }
}
