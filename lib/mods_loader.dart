// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:path/path.dart' as p;

import 'mod_classes.dart';

Future<List<ModFile>> modsLoader() async {
  final allFiles = Directory(modsDirPath).listSync(recursive: true).whereType<File>();
  List<ModFile> allModFiles = [];
  List<File> iceFiles = [];
  List<ModFile> modFilesFromJson = [];

  //Fetch files from Mods Folder
  for (var file in allFiles) {
    if (p.extension(file.path) == '') {
      iceFiles.add(file);
    }
  }

  //JSON Loader
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      ModFile mod =
          ModFile(0, b['modPath'], b['modName'], b['icePath'], b['iceName'], b['iceParent'], b['originalIcePath'], b['backupIcePath'], null, b['isApplied'], b['isSFW'], b['isNew'], null);
      mod.categoryPath = b['categoryPath'];
      mod.categoryName = b['categoryName'];
      modFilesFromJson.add(mod);
    }
  }

  if (modFilesFromJson.isEmpty && File(modSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(File(modSettingsPath).readAsStringSync()));
  }

  //Create ModFiles
  for (var iceFile in iceFiles) {
    List<String> iceFilePathSplit = iceFile.path.split('\\');
    String categoryName = '', categoryPath = '';
    String modName = '', modPath = '';
    String iceParents = '';
    List<File> imgFiles = [];
    List<File> vidFiles = [];

    //Helpers
    for (var element in iceFilePathSplit) {
      if (element == 'Mods') {
        categoryName = iceFilePathSplit[iceFilePathSplit.indexWhere((e) => e == element) + 1];
        categoryPath = iceFile.path.split(categoryName).first + categoryName;
      }
      if (element == categoryName) {
        modName = iceFilePathSplit[iceFilePathSplit.indexWhere((e) => e == categoryName) + 1];
        modPath = iceFile.path.split(modName).first + modName;
      }
    }
    iceParents = iceFile.path.split(modName).last.split('\\${iceFilePathSplit.last}').first.replaceAll('\\', ' > ').trim();
    if (iceParents == '') {
      iceParents = '> $modName';
    }

    //Image helper
    for (var imgFile in Directory(iceFile.parent.path).listSync(recursive: false).whereType<File>()) {
      if (p.extension(imgFile.path) == '.jpg' || p.extension(imgFile.path) == '.png') {
        imgFiles.add(imgFile);
      }
    }
    var imgList = getImagesList(imgFiles);

    //Vids helper
    for (var vidFile in Directory(iceFile.parent.path).listSync(recursive: false).whereType<File>()) {
      if (p.extension(vidFile.path) == '.mp4' || p.extension(vidFile.path) == '.webm') {
        vidFiles.add(vidFile);
      }
    }

    //New ModFile
    ModFile newModFile = ModFile(0, modPath, modName, iceFile.path, iceFilePathSplit.last, iceParents, '', '', imgList, false, true, false, vidFiles);
    newModFile.categoryName = categoryName;
    newModFile.categoryPath = categoryPath;
    var jsonModFile = modFilesFromJson.firstWhere((e) => e.icePath == newModFile.icePath, orElse: () {
      return ModFile(0, '', '', '', '', '', '', '', null, false, true, false, []);
    });
    if (jsonModFile.icePath.isNotEmpty) {
      newModFile.backupIcePath = jsonModFile.backupIcePath;
      newModFile.originalIcePath = jsonModFile.originalIcePath;
      newModFile.isApplied = jsonModFile.isApplied;
      newModFile.isSFW = jsonModFile.isSFW;
      newModFile.isNew = jsonModFile.isNew;
    }
    allModFiles.add(newModFile);
  }

  //Json Write
  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));

  return allModFiles;
}

//Category List
List<ModCategory> categories(List<ModFile> allModFiles) {
  File defaultCategoryItemIcon = File('assets/img/placeholdersquare.jpg');
  List<ModCategory> categories = [];

  //Get categories
  for (var modFile in allModFiles) {
    ModCategory newCategory = ModCategory('', '', [], [], 0, [], [], []);

    //Get Icons
    List<File> imgFiles = [];
    final filesGet = Directory(modFile.modPath).listSync(recursive: false).whereType<File>();
    if (filesGet.isNotEmpty) {
      List<File> imgFilesGet = [];
      for (var file in filesGet) {
        if (p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') {
          imgFilesGet.add(file);
        }
      }
      
      if (imgFilesGet.isNotEmpty) {
        imgFiles.addAll(imgFilesGet);
      } else {
        imgFiles.add(defaultCategoryItemIcon);
      }
    } else {
      imgFiles.add(defaultCategoryItemIcon);
    }
    //print('${modFile.modName} ==== ${imgFiles.first.path}');

    //Add to list
    if (categories.isEmpty || categories.indexWhere((e) => e.categoryName == modFile.categoryName) == -1) {
      newCategory.categoryName = modFile.categoryName;
      categories.add(newCategory);
      newCategory.categoryPath = modFile.categoryPath;
      newCategory.itemNames.add(modFile.modName);
      newCategory.imageIcons.add(imgFiles);
      newCategory.numOfItems++;
      int curItemIndex = 0;
      if (newCategory.itemNames.isNotEmpty) {
        curItemIndex = newCategory.itemNames.indexOf(modFile.modName);
      }
      List<ModFile> sameMod = newCategory.allModFiles.where((element) => element.modName == modFile.modName).toList();
      List<String> parentsList = [];
      if (sameMod.isNotEmpty) {
        parentsList.add(modFile.iceParent);
        for (var file in sameMod) {
          if (parentsList.indexWhere((element) => element == file.iceParent) == -1) {
            parentsList.add(file.iceParent);
          }
        }
      }
      if (newCategory.numOfMods.isEmpty) {
        newCategory.numOfMods.add(1);
      } else {
        newCategory.numOfMods[curItemIndex] = parentsList.length;
      }

      if (modFile.isApplied) {
        newCategory.numOfApplied.add(1);
      } else {
        newCategory.numOfApplied.add(0);
      }
      newCategory.allModFiles.add(modFile);
    } else {
      ModCategory matchedCategory = categories.firstWhere((e) => e.categoryName == modFile.categoryName);

      if (matchedCategory.itemNames.indexWhere((element) => element == modFile.modName) != -1) {
        if (modFile.isApplied && matchedCategory.itemNames.indexWhere((element) => element == modFile.modName) == -1) {
          matchedCategory.numOfApplied[matchedCategory.itemNames.indexWhere((element) => element == modFile.modName)]++;
        }
        int curItemIndex = 0;
        if (matchedCategory.itemNames.isNotEmpty) {
          curItemIndex = matchedCategory.itemNames.indexOf(modFile.modName);
        }
        List<ModFile> sameMod = matchedCategory.allModFiles.where((element) => element.modName == modFile.modName).toList();
        List<String> parentsList = [];
        if (sameMod.isNotEmpty) {
          parentsList.add(modFile.iceParent);
          for (var file in sameMod) {
            if (parentsList.indexWhere((element) => element == file.iceParent) == -1) {
              parentsList.add(file.iceParent);
            }
          }
        }
        matchedCategory.numOfMods[curItemIndex] = parentsList.length;
        if (modFile.isApplied) {
          matchedCategory.numOfApplied[curItemIndex]++;
        }
        matchedCategory.allModFiles.add(modFile);
      } else {
        matchedCategory.itemNames.add(modFile.modName);
        matchedCategory.imageIcons.add(imgFiles);
        matchedCategory.numOfItems++;
        matchedCategory.numOfMods.add(1);
        //matchedCategory.numOfMods.add(Directory(modFile.modPath).listSync(recursive: true).whereType<Directory>().length);
        if (modFile.isApplied) {
          matchedCategory.numOfApplied.add(1);
        } else {
          matchedCategory.numOfApplied.add(0);
        }
        matchedCategory.allModFiles.add(modFile);
      }
    }
  }

  //Add Empty Category
  final cateDirs = Directory(modsDirPath).listSync(recursive: false).whereType<Directory>();
  for (var dir in cateDirs) {
    final emptyCateDirs = dir.listSync(recursive: false);
    if (emptyCateDirs.isEmpty) {
      categories.add(ModCategory(dir.path.split('\\').last, dir.path, [], [], 0, [], [], []));
      categories.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
    }
  }

  return categories;
}

//Mod List
Future<List<List<ModFile>>> getModFilesByCategory(List<ModFile> allModFiles, String modName) async {
  List<List<ModFile>> modFilesList = [];

  List<ModFile> sameMods = [];
  for (var modFile in allModFiles) {
    if (modFile.modName == modName) {
      sameMods.add(modFile);
    }
  }

  List<String> parents = [];
  for (var modFile in sameMods) {
    if (parents.indexWhere((element) => element == modFile.iceParent) == -1) {
      parents.add(modFile.iceParent);
    }
  }

  for (var parent in parents) {
    List<ModFile> sameParent = sameMods.where((element) => element.iceParent == parent).toList();
    modFilesList.add(sameParent);
  }

  return modFilesList.toList();
}

//Applied List
Future<List<List<ModFile>>> getAppliedModsList() async {
  List<List<ModFile>> appliedList = [];
  //Applied mods list add
  final actualAppliedMods = allModFiles.where((element) => element.isApplied == true).toList();

  //Applied mods list add
  for (var mod in actualAppliedMods) {
    if (appliedList.isEmpty) {
      appliedList.add([mod]);
    } else {
      final tempMods = appliedList.firstWhere(
        (modList) => modList.indexWhere((applied) => applied.iceParent == mod.iceParent && applied.modName == mod.modName) != -1,
        orElse: () {
          return [];
        },
      );
      if (tempMods.isNotEmpty) {
        tempMods.add(mod);
      } else {
        appliedList.add([mod]);
      }
    }
  }
  return appliedList;
}

Future<List<File>> getImagesList(List<File> imgFile) async {
  return imgFile.toList();
}
