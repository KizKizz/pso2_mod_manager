// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/ui_text.dart';

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
      ModFile mod = ModFile(b['appliedDate'], b['modPath'], b['modName'], b['icePath'], b['iceName'], b['iceParent'], b['originalIcePath'], b['backupIcePath'], null, b['isApplied'], b['isSFW'],
          b['isNew'], b['isFav'], null);
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
    List<String> iceFilePathSplit = iceFile.path.split(s);
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
    //iceParents = iceFile.path.split(modName).last.split('$s${iceFilePathSplit.last}').first.replaceAll('$s', ' > ').trim();
    List<String> pathSplit = iceFile.path.split(s);
    // ignore: unused_local_variable
    final iceName = pathSplit.removeLast();
    pathSplit.removeRange(0, pathSplit.indexWhere((element) => element == modName) + 1);
    iceParents = pathSplit.join(' > ').trim();
    if (iceParents == '') {
      iceParents = modName;
    }

    //Image helper
    for (var imgFile in Directory(iceFile.parent.path).listSync(recursive: false).whereType<File>()) {
      if (p.extension(imgFile.path) == '.jpg' || p.extension(imgFile.path) == '.png') {
        imgFiles.add(imgFile);
      }
    }

    //Vids helper
    for (var vidFile in Directory(iceFile.parent.path).listSync(recursive: false).whereType<File>()) {
      if (p.extension(vidFile.path) == '.mp4' || p.extension(vidFile.path) == '.webm') {
        vidFiles.add(vidFile);
      }
    }

    if (imgFiles.isEmpty || vidFiles.isEmpty) {
      List<String> filePathSplit = iceFile.path.split('$modPath\\').last.split(s);
      if (filePathSplit.isNotEmpty) {
        filePathSplit.insert(0, modName);
        String fileName = filePathSplit.removeLast();
        String tempPath = iceFile.path.split('$s$fileName').first;
        for (var folderPath in filePathSplit.reversed) {
          List<File> imgVidGet = Directory(tempPath)
              .listSync(recursive: false)
              .whereType<File>()
              .where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png' || p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm')
              .toList();
          if (imgVidGet.isNotEmpty) {
            for (var file in imgVidGet) {
              if ((p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') && imgFiles.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                imgFiles.add(file);
              }
              if ((p.extension(file.path) == '.mp4' || p.extension(file.path) == '.webm') && vidFiles.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                vidFiles.add(file);
              }
            }
          }
          tempPath = tempPath.split('$s$folderPath').first;
        }
      }
    }

    //New ModFile
    ModFile newModFile = ModFile('', modPath, modName, iceFile.path, iceFilePathSplit.last, iceParents, '', '', getImagesList(imgFiles), false, true, false, false, vidFiles);
    newModFile.categoryName = categoryName;
    newModFile.categoryPath = categoryPath;
    var jsonModFile = modFilesFromJson.firstWhere((e) => e.icePath == newModFile.icePath, orElse: () {
      return ModFile('', '', '', '', '', '', '', '', null, false, true, false, false, []);
    });
    if (jsonModFile.icePath.isNotEmpty) {
      newModFile.appliedDate = jsonModFile.appliedDate;
      newModFile.backupIcePath = jsonModFile.backupIcePath;
      newModFile.originalIcePath = jsonModFile.originalIcePath;
      newModFile.isApplied = jsonModFile.isApplied;
      newModFile.isSFW = jsonModFile.isSFW;
      newModFile.isNew = jsonModFile.isNew;
      newModFile.isFav = jsonModFile.isFav;
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
  File defaultCategoryItemIcon = File('assets/img/placeholdersquare.png');
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
      categories.add(ModCategory(dir.path.split(s).last, dir.path, [], [], 0, [], [], []));
      categories.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
    }
  }

  //Fav
  List<ModFile> favModListGet = [];
  for (var cate in categories) {
    for (var mod in cate.allModFiles) {
      if (mod.isFav) {
        favModListGet.add(mod);
      }
    }
  }

  List<String> modNames = [];
  for (var mod in favModListGet) {
    if (modNames.isEmpty || modNames.indexWhere((element) => element == mod.modName) == -1) {
      modNames.add(mod.modName);
    }
  }

  List<List<ModFile>> favModsList = [];
  for (var name in modNames) {
    List<ModFile> sameMods = [];
    for (var modFile in favModListGet) {
      if (modFile.modName == name) {
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
      favModsList.add(sameParent);
    }
  }

  ModCategory tempFavCate = ModCategory('Favorites', '', [], [], 0, [], [], []);
  for (var list in favModsList) {
    tempFavCate = addOrRemoveFav(categories, list, tempFavCate, true);
  }
  tempFavCate.itemNames.sort();
  categories.insert(0, tempFavCate);

  return categories;
}

//Search result
List<ModCategory> searchFilterResults(List<ModCategory> paramCateList, String searchText) {
  List<ModCategory> resultList = [];

  for (var cate in paramCateList) {
    if (cate.categoryName != 'Favorites') {
      List<String> itemNameResults = [];
      if (cate.categoryName == 'Basewears' || cate.categoryName == 'Outerwears' || cate.categoryName == 'Innerwears' || cate.categoryName == 'Setwears') {
        itemNameResults = cate.itemNames.where((element) => element.replaceRange(element.length - 4, null, '').toLowerCase().contains(searchText.toLowerCase())).toList();
      } else {
        itemNameResults = cate.itemNames.where((element) => element.toLowerCase().contains(searchText.toLowerCase())).toList();
      }

      if (itemNameResults.isNotEmpty) {
        ModCategory newCate = ModCategory(cate.categoryName, cate.categoryPath, [], [], itemNameResults.length, [], [], []);
        for (var itemName in itemNameResults) {
          int itemIndex = cate.itemNames.indexOf(itemName);
          List<File> imgFiles = cate.imageIcons[itemIndex];
          int numofMod = cate.numOfMods[itemIndex];
          int numofApplied = cate.numOfApplied[itemIndex];
          List<ModFile> modsInItems = cate.allModFiles.where((element) => element.modName == itemName).toList();

          //Populate newcate
          newCate.itemNames.add(itemName);
          newCate.imageIcons.add(imgFiles);
          newCate.numOfMods.add(numofMod);
          newCate.numOfApplied.add(numofApplied);
          newCate.allModFiles.addAll(modsInItems);
        }
        resultList.add(newCate);
      } else {
        List<ModFile> modFileResults =
            cate.allModFiles.where((element) => element.iceName.toLowerCase().contains(searchText.toLowerCase()) || element.iceParent.toLowerCase().contains(searchText.toLowerCase())).toList();

        if (modFileResults.isNotEmpty) {
          // List<String> parentsFromMods = [];
          // for (var element in modFileResults) {
          //   if (parentsFromMods.indexWhere((e) => e == element.iceParent) == -1) {
          //     parentsFromMods.add(element.iceParent);
          //   }
          // }
          List<String> itemNamesfromMods = [];
          for (var element in modFileResults) {
            if (itemNamesfromMods.indexWhere((e) => e == element.modName) == -1) {
              itemNamesfromMods.add(element.modName);
            }
          }

          ModCategory newCate = ModCategory(cate.categoryName, cate.categoryPath, [], [], itemNamesfromMods.length, [], [], []);
          for (var itemName in itemNamesfromMods) {
            int itemIndex = cate.itemNames.indexOf(itemName);
            List<File> imgFiles = cate.imageIcons[itemIndex];
            List<String> parentsInItems = [];
            for (var element in modFileResults.where((element) => element.modName == itemName)) {
              if (parentsInItems.indexWhere((e) => e == element.iceParent) == -1) {
                parentsInItems.add(element.iceParent);
              }
            }
            int numofMod = parentsInItems.length;
            int numofApplied = modFileResults.where((element) => element.isApplied == true).length; // need to change
            List<ModFile> modsInItems = modFileResults.where((element) => element.modName == itemName).toList();
            //List<ModFile> modsInItems = [];
            // for (var parent in parentsFromMods) {
            //   modsInItems = modFileResults.where((element) => element.modName == itemName).toList();
            // }

            //Populate newcate
            newCate.itemNames.add(itemName);
            newCate.imageIcons.add(imgFiles);
            newCate.numOfMods.add(numofMod);
            newCate.numOfApplied.add(numofApplied);
            newCate.allModFiles.addAll(modsInItems);
          }
          resultList.add(newCate);
        }
      }
    }
  }

  return resultList;
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
  List<ModFile> actualAppliedMods = allModFiles.where((element) => element.isApplied == true).toList();
  List<String> parentPathsList = [];

  for (var file in actualAppliedMods) {
    if (parentPathsList.indexWhere((element) => element == file.icePath.replaceFirst(file.iceName, '')) == -1) {
      parentPathsList.add(file.icePath.replaceFirst(file.iceName, ''));
    }
  }

  for (var path in parentPathsList) {
    actualAppliedMods.addAll(allModFiles.where((element) => element.icePath.replaceFirst(element.iceName, '') == path && element.isApplied == false).toList());
  }

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
        appliedList.insert(0, [mod]);
      }
    }
  }

  //Applied count
  totalAppliedItems = appliedList.length;
  for (var item in appliedList) {
    totalAppliedFiles += item.length;
  }

  appliedList.sort(((a, b) => b.first.appliedDate.compareTo(a.first.appliedDate)));
  return appliedList;
}

Future<List<File>> getImagesList(List<File> imgFile) async {
  return imgFile.toList();
}

Future<List<ModSet>> getSetsList() async {
  List<ModSet> returnSetsList = [];
  //JSON Loader
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      ModSet set = ModSet(
        b['setName'],
        b['numOfItems'],
        b['modFiles'],
        b['isApplied'],
        [],
      );
      set.filesInSetList = set.getModFiles(set.modFiles);
      returnSetsList.add(set);
    }
  }

  if (returnSetsList.isEmpty && File(modSetsSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(File(modSetsSettingsPath).readAsStringSync()));
  }

  return returnSetsList;
}

//Mod sets
Future<List<List<ModFile>>> getModFilesBySet(String modSetList) async {
  List<List<ModFile>> modFilesInSetList = [];
  List<ModFile> modFilesFromSet = [];

  List<String> modSeparated = modSetList.split('|');

  for (var modPath in modSeparated) {
    if (allModFiles.indexWhere((element) => element.icePath == modPath) != -1) {
      modFilesFromSet.add(allModFiles.firstWhere((element) => element.icePath == modPath));
    }
  }

  List<String> modNamesList = [];
  for (var modFile in modFilesFromSet) {
    modNamesList.add(modFile.modName);
  }
  modNamesList = modNamesList.toSet().toList();

  for (var name in modNamesList) {
    List<ModFile> temp = [];
    temp.addAll(modFilesFromSet.where((element) => element.modName == name));
    modFilesInSetList.add(temp);
  }

  return modFilesInSetList.toList();
}

//Language Loader
Future<List<TranslationLanguage>> translationLoader() async {
  List<TranslationLanguage> langList = [];
  void convertData(var jsonResponse) {
    for (var b in jsonResponse) {
      TranslationLanguage translation = TranslationLanguage(
        b['langInitial'],
        b['langFilePath'],
        b['selected'],
      );
      langList.add(translation);
    }
  }

  if (langList.isEmpty && File(langSettingsPath).readAsStringSync().isNotEmpty) {
    convertData(jsonDecode(File(langSettingsPath).readAsStringSync()));
  }

  return langList;
}

TranslationText defaultUILangLoader() {
  return TranslationText(
    //Header buttons
    'Paths Reselect',
    'Folders',
    'Mods',
    'Backups',
    'Deleted Items',
    'Checksum:',
    'Checksum missing. Click!',
    'Mod Sets',
    'Mod List',
    'Preview:',
    'Light',
    'Dark',

    //Header buttons tooltips
    'Reselect path for pso2_bin, Mod Manager folder',
    'Open Mods, Backups, Deleted Items folder',
    'modsFolderTooltipText',
    'Open Checksum folder',
    'Manage Mod Sets',
    'Show/Hide Preview window',
    'Switch to Dark theme',
    'Switch to Light theme',
    'Language select',

    //Main Headers
    'Items',
    'Available Mods',
    'Preview',
    'Applied Mods',
    'Sets',
    'Mods in Set',

    //Mod Items
    'Refresh Mod List',
    'Add New Category',
    'Add New Item',
    ' in File Explorer',
    'Search for mods',
    'New Category Name',
    'Add Category',
    'Single Item',
    'Multiple Items',
    'Drop modded .ice files and folder(s)\nhere to add',
    'Drop modded item folder(s) here to add',
    'Drop item\'s\nicon here\n(Optional)',
    'Select a Category',
    'Item Name',
    'Mod Name (Optional)',
    'Add Mods',
    'Add mods to',
    'Favorite',
    'Accessories',
    'Basewears',
    'Body Paints',
    'Emotes',
    'Innerwears',
    'Misc',
    'Motions',
    'Outerwears',
    'Setwears',
    'Unapply this mod from the game',
    'Apply this mod to the game',
    'Mod Name',
    'Save all mods in applied list to sets',
    'Click on \'Mod Sets\' button to add new set',
    'Apply all mods under ',
    ' to the game',
    'Unapply all mods under ',
    ' from the game',
    'New Set Name',
    'Add New Set',
    'Add Set',
    'Hold to delete ',
    'Hold to remove ',
    'Hold to reapply all mods to the game',
    'Hold to remove all applied mods from the game',
  

    //Misc
    ' Items',
    ' Item',
    'Files applied:',
    'Files applied',
    'Close',
    'Open ',
    'Add',
    'Add ',
    'Remove ',
    'Delete ',
    'Refreshing',
    'Mods:',
    'Applied:',
    ' to favorites',
    ' from favorites',
    'Done',
    ' Files',
    ' File',
    'One or more mod files in this set currently being applied to the game',
    'Delete Category',
    ' and move it to Deleted Items folder?\nThis will also remove all items in this category',
    'Cannot delete ',
    '. Unaplly these mods first:\n\n',
    'Delete Item',
    ' and move it to Deleted Items folder?\nThis will also delete all mods in this item',
    'Delete Mod',
    ' and move it to Deleted Items folder?\nThis will also delete all files in this mod',
    '. Unapply these files first:\n\n',
    '. Remove from Favorites first',
    'No Results Found',
    ' from ',
    'Loading UI',
    'Select your checksum file',
    'New Update Available!',
    'New Version:',
    'Your Version:',
    'Patch Notes...',
    'Update',
    'Dismiss',
    'Waiting for user\'s action',
    'pso2_bin Path Reselect',
    'Mod Manager Folder Path Reselect',
    'Current path:',
    'Choose a new path?',

    //Error messages
    'Category name can\'t be empty',
    'Category name already exist',
    'Name can\'t be empty',
    'The name already exists',
    'The file(s) bellow won\'t be added. Use the \'Single Item\' Tab or \'Add Mod\' instead.',
    'Original file of ',
    ' is not found!',
    'Replaced: ',
    'Backup file of ',
    'There are mod files currently being applied. Unapply them first!',
    'pso2_bin folder not found. Select it now?\nSelect \'Exit\' will close the app',
    'Mod Manager Folder not found',
    'Select a path to store your mods?\nSelect \'No\' will create a folder inside \'pso2_bin\' folder'
  );
}
