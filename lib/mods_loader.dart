import 'dart:convert';
import 'dart:io';

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
      ModFile mod = ModFile(0, b['modPath'], b['modName'], b['icePath'], b['iceName'], b['iceParent'], b['originalIcePath'], b['backupIcePath'], null, b['isApplied'], b['isSFW']);
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
    iceParents = iceFile.path.split(modName).last.split('\\${iceFilePathSplit.last}').first.replaceAll('\\', ' > ');
    

    //Image helper
    for (var imgFile in Directory(iceFile.parent.path).listSync(recursive: false).whereType<File>()) {
      if (p.extension(imgFile.path) == '.jpg' || p.extension(imgFile.path) == '.png') {
        imgFiles.add(imgFile);
      }
    }
    var imgList = getImagesList(imgFiles);

    //New ModFile
    ModFile newModFile = ModFile(0, modPath, modName, iceFile.path, iceFilePathSplit.last, iceParents, '', '', imgList, false, true);
    newModFile.categoryName = categoryName;
    newModFile.categoryPath = categoryPath;
    final jsonModFile = modFilesFromJson.firstWhere((e) => e.icePath == newModFile.icePath);
    if (jsonModFile.icePath.isNotEmpty) {
      newModFile.backupIcePath = jsonModFile.backupIcePath;
      newModFile.originalIcePath = jsonModFile.originalIcePath;
      newModFile.isApplied = jsonModFile.isApplied;
      newModFile.isSFW = jsonModFile.isSFW;
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
  File defaultCategoryItemIcon = File('assets/img/placeholder-square.jpg');
  List<ModCategory> categories = [];

  //Get categories
  for (var modFile in allModFiles) {
    ModCategory newCategory = ModCategory('', '', [], [], 0, [], [], []);

    //Get Icons
    List<File> imgFiles = [];
    final files = Directory(modFile.modPath).listSync(recursive: false).whereType<File>();
    for (var file in files) {
      if (p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') {
        imgFiles.add(file);
      }
    }
    if (imgFiles.isEmpty) {
      imgFiles.add(defaultCategoryItemIcon);
    }

    //Add to list
    if (categories.isEmpty || categories.indexWhere((e) => e.categoryName == modFile.categoryName) == -1) {
      newCategory.categoryName = modFile.categoryName;
      categories.add(newCategory);
      newCategory.categoryPath = modFile.categoryPath;
      newCategory.itemNames.add(modFile.modName);
      newCategory.imageIcons.add(imgFiles);
      newCategory.numOfItems++;
      newCategory.numOfMods.add(Directory(modFile.modPath).listSync(recursive: false).whereType<Directory>().length);
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
        matchedCategory.allModFiles.add(modFile);
      } else {
        matchedCategory.itemNames.add(modFile.modName);
        matchedCategory.imageIcons.add(imgFiles);
        matchedCategory.numOfItems++;
        matchedCategory.numOfMods.add(Directory(modFile.modPath).listSync(recursive: false).whereType<Directory>().length);
        if (modFile.isApplied) {
          matchedCategory.numOfApplied.add(1);
        } else {
          matchedCategory.numOfApplied.add(0);
        }
        matchedCategory.allModFiles.add(modFile);
      }
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

Future<List<File>> getImagesList(List<File> imgFile) async {
  return imgFile.toList();
}
