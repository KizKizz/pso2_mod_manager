import 'dart:io';

import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';

//Auto Files adder
Future<bool> modsAdderModFilesAdder(context, List<ModsAdderItem> itemsToAddList) async {
  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('');
  //List<List<String>> addedItems = [];
  for (var item in itemsToAddList) {
    if (item.toBeAdded) {
      String category = item.category;
      String itemName = item.itemName;
      List<String> mainNames = [];

      //copy files to Mods
      String newItemPath = item.itemDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
      //copy files in item dir
      for (var file in Directory(item.itemDirPath).listSync().whereType<File>()) {
        if (file.existsSync()) {
          String newFileDirPath = file.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
          Directory(p.dirname(newFileDirPath)).createSync(recursive: true);
          file.copySync(newFileDirPath);
        }
      }
      for (var mod in item.modList) {
        if (mod.toBeAdded) {
          mainNames.add(mod.modName);
          String newmodDirPath = mod.modDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
          Directory(newmodDirPath).createSync(recursive: true);
          for (var file in mod.filesInMod) {
            if (file.existsSync()) {
              String newFilePath = file.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
              file.copySync(newFilePath);
            }
          }
          for (var submod in mod.submodList) {
            if (submod.toBeAdded) {
              String newSubmodDirPath = submod.submodDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
              Directory(newSubmodDirPath).createSync(recursive: true);
              for (var file in submod.files) {
                if (file.existsSync()) {
                  String newFilePath = file.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
                  Directory(p.dirname(newFilePath)).createSync(recursive: true);
                  file.copySync(newFilePath);
                  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('$category > $itemName > ${mod.modName} > ${submod.submodName} > ${p.basename(file.path)}');
                  await Future.delayed(const Duration(milliseconds: 10));
                }
              }
            }
          }
        }
      }
      //io.copyPathSync(item.itemDirPath, newItemPath);

      if (mainNames.isNotEmpty) {
        List<Directory> foldersInNewItemPath = [];
        for (var mod in item.modList) {
          if (mod.toBeAdded) {
            String newmodDirPath = mod.modDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
            if (foldersInNewItemPath.indexWhere((element) => element.path == newmodDirPath) == -1) {
              foldersInNewItemPath.add(Directory(newmodDirPath));
            }
          }
        }

        //Add to current moddedItemList
        for (var cateType in moddedItemsList) {
          int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == category);
          if (cateIndex != -1) {
            Category cateInList = cateType.categories[cateIndex];
            int itemInListIndex = cateInList.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              cateInList.items.add(await newItemsFetcher(Uri.file('$modManModsDirPath/$category').toFilePath(), newItemPath));
            } else {
              Item itemInList = cateInList.items[itemInListIndex];
              int modInListIndex = itemInList.mods.indexWhere((element) => mainNames.where((name) => name.toLowerCase() == element.modName.toLowerCase()).isNotEmpty);
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, cateInList.categoryName, itemInList.itemName);
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, cateInList.categoryName, foldersInNewItemPath));
              }
              itemInList.isNew = true;
              //Sort alpha
              itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
            }
            //Sort alpha
            cateInList.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            cateInList.visible = cateInList.items.isNotEmpty ? true : false;
            cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          } else if (cateType.groupName == defaultCategoryTypeNames[2]) {
            Category newCate = Category(category, cateType.groupName, Uri.file('$modManModsDirPath/$category').toFilePath(), cateType.categories.length, true, []);
            int itemInListIndex = newCate.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              newCate.items.add(await newItemsFetcher(Uri.file('$modManModsDirPath/$category').toFilePath(), newItemPath));
            } else {
              Item itemInList = newCate.items[itemInListIndex];
              int modInListIndex = itemInList.mods.indexWhere((element) => mainNames.where((name) => name.toLowerCase() == element.modName.toLowerCase()).isNotEmpty);
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, newCate.categoryName, itemInList.itemName);
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, newCate.categoryName, foldersInNewItemPath));
              }
              itemInList.isNew = true;
              //Sort alpha
              itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
            }
            //Sort alpha
            newCate.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            newCate.visible = newCate.items.isNotEmpty ? true : false;
            cateType.categories.add(newCate);
            cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          }
        }

        Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
      }
    }
  }
  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('');

  //Save to json
  saveModdedItemListToJson();

  //clear sheets
  // if (csvInfosFromSheets.isNotEmpty) {
  //   csvInfosFromSheets.clear();
  // }

  return true;
}

//Helpers
Future<Item> newItemsFetcher(String catePath, String itemPath) async {
  //Get icons from dir
  List<String> itemIcons = [];
  final imagesFoundInItemDir = Directory(itemPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
  if (imagesFoundInItemDir.isNotEmpty) {
    itemIcons = imagesFoundInItemDir.map((e) => e.path).toList();
  } else {
    itemIcons = ['assets/img/placeholdersquare.png'];
  }

  return Item(p.basename(itemPath), [], itemIcons, '', '', '', false, p.basename(catePath), Uri.file(itemPath).toFilePath(), false, DateTime(0), 0, false, false, true, [],
      newModsFetcher(itemPath, p.basename(catePath), []));
}

List<Mod> newModsFetcher(String itemPath, String cateName, List<Directory> newModFolders) {
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
      modFilesInItemDir.add(ModFile(
          p.basename(iceFile.path), p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, '', [], iceFile.path, false, DateTime(0), 0, false, false, true, [], [], [], []));
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
    SubMod subModInItemDir = SubMod(p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, false, false, false, -1, -1, '', [], [],
        modPreviewImages, modPreviewVideos, [], modFilesInItemDir);

    //add to mod
    mods.add(Mod(p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, false, [], modPreviewImages, modPreviewVideos, [], [subModInItemDir]));
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

    mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, true, false, false, [], modPreviewImages, modPreviewVideos, [],
        newSubModFetcher(dir.path, cateName, p.basename(itemPath))));
  }

  //Sort alpha
  mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));

  return mods;
}

List<SubMod> newSubModFetcher(String modPath, String cateName, String itemName) {
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
      modFiles.add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, false, true, [], [], [], []));
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

    submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, true, false, false, hasCmx, false, -1, -1, cmxFile, [], [], modPreviewImages,
        modPreviewVideos, [], modFiles));
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

      modFiles.add(ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, false, true, [], [], [], []));
      //Sort alpha
      modFiles.sort((a, b) => a.modFileName.toLowerCase().compareTo(b.modFileName.toLowerCase()));
    }

    //Get submod name
    List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
    parentPaths.removeWhere((element) => element.isEmpty);
    submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, true, false, false, hasCmx, false, -1, -1, cmxFile, [], [], modPreviewImages,
        modPreviewVideos, [], modFiles));
  }

  //remove empty submods
  submods.removeWhere((element) => element.modFiles.isEmpty);

  //Sort alpha
  submods.sort((a, b) => a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase()));

  return submods;
}
