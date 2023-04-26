import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/item_icons_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<List<CategoryType>> categoryTypesLoader() async {
  List<Category> categoriesFromMods = await modFilesLoader(modManModsDirPath);

  List<CategoryType> categoryTypes = [];
  for (var cate in categoriesFromMods) {
    if (categoryTypes.isEmpty) {
      categoryTypes.add(CategoryType(cate.group, 0, true, true, [cate]));
    } else {
      if (categoryTypes.indexWhere((element) => element.groupName == cate.group) != -1) {
        categoryTypes[categoryTypes.indexWhere((element) => element.groupName == cate.group)].categories.add(cate);
      } else {
        categoryTypes.add(CategoryType(cate.group, 0, true, true, [cate]));
      }
    }
  }
  for (var type in categoryTypes) {
    if (type.groupName == 'Layering Wears') {
      type.position = 1;
    } else if (type.groupName == 'Cast Parts') {
      type.position = 2;
    } else {
      type.position = 3;
    }
  }

  categoryTypes.sort(((a, b) => a.position.compareTo(b.position)));
  return categoryTypes;
}

Future<List<Category>> modFilesLoader(String modsDirPath) async {
  List<String> cateToIgnoreScan = ['Emotes', 'Motions'];
  //Load local json
  // if (File(modManModsListJsonPath).readAsStringSync().toString().isNotEmpty) {
  //   var jsonData = jsonDecode(File(modManModsListJsonPath).readAsStringSync());
  //   var jsonCategories = [];
  //   for (var cate in jsonData) {
  //     jsonCategories.add(Category.fromJson(cate));
  //   }
  // }

  //Load Mod Files
  List<String> modsDirFolderPaths = [];
  final allDataFolders = Directory(Uri.file(modManModsDirPath).toFilePath()).listSync(recursive: true).whereType<Directory>();
  for (var folder in allDataFolders) {
    modsDirFolderPaths.add(Uri.file(folder.path).toFilePath());
  }
  List<String> modsDirFilePaths = [];
  final allDataFiles = Directory(Uri.file(modManModsDirPath).toFilePath()).listSync(recursive: true).whereType<File>();
  for (var file in allDataFiles) {
    modsDirFilePaths.add(file.path);
  }

  //Preping category list
  List<Category> categories = [];
  final dirsInModsDir = Directory(modManModsDirPath).listSync(recursive: false);
  for (var cateDir in dirsInModsDir) {
    final dirPathsInCurCategory = modsDirFolderPaths.where((element) => element.contains(cateDir.path)).toList();
    final filePathsInCurCategory = modsDirFilePaths.where((element) => element.contains(cateDir.path)).toList();

    //Items
    List<Item> items = [];

    //Listing Item paths
    final itemDirPathsInCurCategory = dirPathsInCurCategory.where((element) => isSubOfParentDir(element, cateDir.path)).toList();
    for (var itemDir in itemDirPathsInCurCategory) {
      final dirPathsInCurItem = dirPathsInCurCategory.where((element) => element.contains(itemDir)).toList();
      final filePathsInCurItem = filePathsInCurCategory.where((element) => element.contains(itemDir)).toList();

      List<String> filesInMainItemDir = modsDirFilePaths.where((element) => isSubOfParentDir(element, itemDir)).toList();

      //Get item icon
      String itemIcon = '';
      final imagesInItemDir = filesInMainItemDir.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png').toList();
      if (imagesInItemDir.isNotEmpty) {
        itemIcon = imagesInItemDir.first;
      } else if (cateToIgnoreScan.contains(p.basename(cateDir.path))) {
        itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
      } else {
        final icesInItem = filePathsInCurCategory.where((element) => p.extension(element) == '');
        List<XFile> listOfIcesToFetch = [];
        for (var element in icesInItem) {
          if (!listOfIcesToFetch.contains(XFile(element))) {
            listOfIcesToFetch.add(XFile(element));
          }
        }
        String tempItemIconPath = '';
        for (var element in listOfIcesToFetch) {
          if (tempItemIconPath.isEmpty) {
            tempItemIconPath = await itemIconFetch(element);
          } else {
            break;
          }
        }

        if (tempItemIconPath.isNotEmpty) {
          File(tempItemIconPath).copySync(Uri.file('$itemDir/${XFile(tempItemIconPath).name}').toFilePath());
          itemIcon = Uri.file('$itemDir/${XFile(tempItemIconPath).name}').toFilePath();
          //clear temp dir
          Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
            element.deleteSync(recursive: true);
          });
        } else {
          itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
        }
      }

      //   //Get mods in items
      List<Mod> mods = [];
      final modDirPathsInCurItem = dirPathsInCurItem.where((element) => isSubOfParentDir(element, itemDir)).toList();
      for (var modDir in modDirPathsInCurItem) {
        final dirPathsInCurMod = dirPathsInCurItem.where((element) => element.contains(modDir)).toList();
        final filePathsInCurMod = filePathsInCurItem.where((element) => element.contains(modDir)).toList();

        //Get preview images;
        List<String> modPreviewImages = [];
        final imagesInModDir = filePathsInCurMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
        for (var element in imagesInModDir) {
          modPreviewImages.add(Uri.file(element).toFilePath());
        }
        //Get preview videos;
        List<String> modPreviewVideos = [];
        final videosInModDir = filePathsInCurMod.where((element) => p.extension(element) == '.webm' || p.extension(element) == '.mp4');
        for (var element in videosInModDir) {
          modPreviewVideos.add(Uri.file(element).toFilePath());
        }

        //Get submods in mods
        List<SubMod> submods = [];
        //Get modfiles in mods
        final modFilesInModDir = filePathsInCurMod.where((element) => isSubOfParentDir(element, modDir) && p.extension(element) == '');
        if (modFilesInModDir.isNotEmpty) {
          //Set submods
          //Get mod files in submods
          List<ModFile> modFilesInMainDir = [];
          for (var modFile in modFilesInModDir) {
            //Fetch og ice location
            //List<String> ogIceFileLocations = [];
            List<String> ogIceFileLocations = ogDataFilePaths.where((element) => p.basename(element) == p.basename(modFile)).toList();

            //Populate modFiles
            modFilesInMainDir.add(ModFile(p.basename(modFile), p.basename(modDir), p.basename(modDir), p.basename(itemDir), p.basename(cateDir.path), getFileHash(modFile).toString(), '',
                Uri.file(modFile).toFilePath(), ogIceFileLocations, [], DateTime(0), false, false, false));
          }

          //Populate submods
          submods.add(SubMod(p.basename(modDir), p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false, modPreviewImages,
              modPreviewVideos, [], modFilesInMainDir));
        }

        //Get submods
        final submodDirsInMod = dirPathsInCurMod.where((element) => isSubOfParentDir(element, modDir)).toList();
        for (var submodDir in submodDirsInMod) {
          //final dirPathsInCurSubMod = dirPathsInCurItem.where((element) => element.contains(submodDir)).toList();
          final filePathsInCurSubMod = filePathsInCurItem.where((element) => element.contains(submodDir)).toList();
          //Fetch submod name
          List<String> submodPathSegment = Uri.file(submodDir).pathSegments;
          List<String> submodDirs = [];
          submodDirs.addAll(submodPathSegment);
          submodDirs.removeRange(0, submodDirs.indexOf(p.basename(modDir)) + 1);
          final submodName = submodDirs.join(' > ');
          //Get preview images;
          List<String> submodPreviewImages = [];
          final imagesInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
          for (var element in imagesInSubmodDir) {
            submodPreviewImages.add(Uri.file(element).toFilePath());
          }
          //Get preview videos;
          List<String> submodPreviewVideos = [];
          final videosInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '.jpg' || p.extension(element) == '.png');
          for (var element in videosInSubmodDir) {
            submodPreviewVideos.add(Uri.file(element).toFilePath());
          }
          //Get mod files in submods
          List<ModFile> modFiles = [];
          final modFilesInSubmodDir = filePathsInCurSubMod.where((element) => p.extension(element) == '').toList();
          for (var modFile in modFilesInSubmodDir) {
            List<String> ogIceFileLocations = ogDataFilePaths.where((element) => p.basename(element) == p.basename(modFile)).toList();

            //Populate modFiles
            modFiles.add(ModFile(p.basename(modFile), submodName, p.basename(modDir), p.basename(itemDir), p.basename(cateDir.path), getFileHash(modFile).toString(), '',
                Uri.file(modFile).toFilePath(), ogIceFileLocations, [], DateTime(0), false, false, false));
          }

          //Populate submods
          submods.add(SubMod(submodName, p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(submodDir).toFilePath(), false, DateTime(0), false, false, submodPreviewImages,
              submodPreviewVideos, [], modFiles));
        }

        //Populate mods
        mods.add(
            Mod(p.basename(modDir), p.basename(itemDir), XFile(cateDir.path).name, Uri.file(modDir).toFilePath(), false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], submods));
      }

      //   //   //Populate items
      items.add(Item(XFile(itemDir).name, itemIcon, XFile(cateDir.path).name, Uri.file(itemDir).toFilePath(), false, false, DateTime(0), false, mods));
    }

    //Group categories
    String group = 'Others';
    if (p.basename(cateDir.path) == 'Basewears' || p.basename(cateDir.path) == 'Innerwears' || p.basename(cateDir.path) == 'Outerwears' || p.basename(cateDir.path) == 'Setwears') {
      group = 'Layering Wears';
    } else if (p.basename(cateDir.path) == 'Cast Arm Parts' || p.basename(cateDir.path) == 'Cast Body Parts' || p.basename(cateDir.path) == 'Cast Leg Parts') {
      group = 'Cast Parts';
    } else {
      group = 'Others';
    }

    //Add items to categories
    categories.add(Category(p.basename(cateDir.path), group, Uri.file(cateDir.path).toFilePath(), true, items));
  }

  //Write

  return categories;
}

//Path helper
bool isSubOfParentDir(String path, String parentPath) {
  if (File(path).parent.path == parentPath) {
    return true;
  }
  return false;
}
