import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';

//Auto Files adder
Future<void> modFilesAdder(context, List<List<String>> sortedList) async {
  //List<List<String>> addedItems = [];
  //print(sortedList);
  for (var sortedLine in sortedList) {
    if (sortedLine[4].isNotEmpty) {
      //Get mods info
      String category = sortedLine[0];
      String itemName = '';
      if (curActiveLang == 'JP') {
        itemName = sortedLine[1];
      } else {
        itemName = sortedLine[2];
      }

      List<String> subNames = [];
      if (sortedLine[5].isNotEmpty) {
        for (var name in sortedLine[5].split('|')) {
          if (name.isNotEmpty) {
            subNames.add(name.split(':')[1]);
          }
        }
      }

      List<String> fileInfos = sortedLine[6].split('|');

      List<String> modFolders = [];
      for (var fileInfo in fileInfos) {
        List<String> temp = fileInfo.split(':');
        modFolders.add('${temp.first}:${temp[1]}');
      }
      //final finalModFolders = modFolders.toSet();

      String newItemPath = Uri.file('$modManModsDirPath/$category/$itemName').toFilePath();
      List<Directory> foldersInNewItemPath = [];

      //Copy icon image to main item dir
      if (sortedLine[3].isNotEmpty && p.extension(sortedLine[3]) == '.png' && !File(Uri.file('$newItemPath/$itemName.png').toFilePath()).existsSync()) {
        Directory(newItemPath).createSync(recursive: true);
        File(sortedLine[3]).copySync(Uri.file('$newItemPath/$itemName.png').toFilePath());
      }

      //Create folders inside Mods folder
      for (var field in fileInfos) {
        String curMainName = field.split(':')[0];
        String curSubName = field.split(':')[1];
        String curFile = field.split(':')[2];
        if (subNames.isEmpty) {
          Directory(Uri.directory('$modManModsDirPath$category/$itemName/$curMainName').toFilePath()).createSync(recursive: true);
          File(Uri.file('$modManAddModsTempDirPath/$curMainName/$curFile').toFilePath()).copySync(Uri.file('$modManModsDirPath/$category/$itemName/$curMainName/$curFile').toFilePath());
        } else {
          Directory(Uri.directory('$modManModsDirPath/$category/$itemName/$curMainName/$curSubName').toFilePath()).createSync(recursive: true);
          File(Uri.file('$modManAddModsTempDirPath/$curMainName/$curSubName/$curFile').toFilePath())
              .copySync(Uri.file('$modManModsDirPath/$category/$itemName/$curMainName/$curSubName/$curFile').toFilePath());
        }

        if (foldersInNewItemPath.indexWhere((element) => element.path == Uri.file('$modManModsDirPath/$category/$itemName/$curMainName').toFilePath()) == -1) {
          foldersInNewItemPath.add(Directory(Uri.file('$modManModsDirPath/$category/$itemName/$curMainName').toFilePath()));
        }
      }

      //Add to current moddedItemList
      for (var cateType in moddedItemsList) {
        int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == category);
        if (cateIndex != -1) {
          Category cateInList = cateType.categories[cateIndex];
          int itemInListIndex = cateInList.items.indexWhere((element) => element.itemName == itemName);
          if (itemInListIndex == -1) {
            cateInList.items.add(await newItemsFetcher(Uri.file('$modManModsDirPath/$category').toFilePath(), newItemPath));
          } else {
            cateInList.items[itemInListIndex].mods.addAll(newModsFetcher(cateInList.items[itemInListIndex].location, cateInList.categoryName, foldersInNewItemPath));
            cateInList.items[itemInListIndex].isNew = true;
          }

          break;
        }
      }

      Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
    }
  }

  //Save to json
  moddedItemsList.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModsListJsonPath).writeAsStringSync(encoder.convert(moddedItemsList));
}

//Helpers
Future<Item> newItemsFetcher(String catePath, String itemPath) async {
  //Get item icon
  String itemIcon = '';
  final filesInItemDir = Directory(itemPath).listSync(recursive: false).whereType<File>();
  final imagesFoundInItemDir = filesInItemDir.where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
  if (imagesFoundInItemDir.isNotEmpty) {
    itemIcon = imagesFoundInItemDir.first.path;
  } else {
    itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
  }

  return Item(p.basename(itemPath), itemIcon, p.basename(catePath), Uri.file(itemPath).toFilePath(), true, DateTime(0), 0, false, false, true, [], newModsFetcher(itemPath, p.basename(catePath), []));
}

List<Mod> newModsFetcher(String itemPath, String cateName, List<Directory> newModFolders) {
  List<Directory> foldersInItemPath = [];
  if (newModFolders.isEmpty) {
    foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  } else {
    foldersInItemPath = newModFolders;
  }
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

    mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, true, false, false, [], modPreviewImages, modPreviewVideos, [],
        newSubModFetcher(dir.path, cateName, p.basename(itemPath))));
  }

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
      modFiles.add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', '', file.path, false, DateTime(0), 0, false, false, false, [], [], []));
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

    submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, true, false, false, [], modPreviewImages, modPreviewVideos, [], modFiles));
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

      modFiles.add(ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', '', file.path, false, DateTime(0), 0, false, false, true, [], [], []));
    }

    //Get submod name
    List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
    parentPaths.removeWhere((element) => element.isEmpty);
    submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, true, false, false, [], modPreviewImages, modPreviewVideos, [], modFiles));
  }

  return submods;
}
