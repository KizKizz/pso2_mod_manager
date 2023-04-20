import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/file_functions.dart';

import '../main.dart';

Future<List<Category>> startupLoader(String modsDirPath) async {
  //Load local json
  var jsonData = jsonDecode(File(modsListJsonPath.toFilePath()).readAsStringSync());
  var jsonCategories = [];
  for (var cate in jsonData) {
    jsonCategories.add(Category.fromJson(cate));
  }

  //Load local data
  List<Category> categories = [];
  final dirsInModsDir = Directory(modsDirPath).listSync(recursive: false);
  for (var cateDir in dirsInModsDir) {
    List<Item> items = [];
    for (var itemDir in Directory(cateDir.path).listSync(recursive: false)) {
      //Get item icon
      Uri itemIcon = Uri();
      final imagesInItemDir = Directory(itemDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
      if (imagesInItemDir.isNotEmpty) {
        itemIcon = Uri.file(imagesInItemDir.first.path);
      } else {
        itemIcon = Uri.file('assets/img/placeholdersquare.png');
      }

      //Get mods in items
      List<Mod> mods = [];
      for (var modDir in Directory(itemDir.path).listSync(recursive: false).whereType<Directory>()) {
        //Get preview images;
        List<Uri> modPreviewImages = [];
        final imagesInModDir = Directory(modDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in imagesInModDir) {
          modPreviewImages.add(Uri.file(element.path));
        }
        //Get preview videps;
        List<Uri> modPreviewVideos = [];
        final videosInModDir = Directory(modDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in videosInModDir) {
          modPreviewVideos.add(Uri.file(element.path));
        }

        //Get submods in mods
        List<SubMod> submods = [];
        for (var submodDir in Directory(modDir.path).listSync(recursive: true).whereType<Directory>()) {
          //print(submodDir.path);
          //Fetch submod name
          List<String> submodPathSegment = Uri.file(submodDir.path).pathSegments;
          List<String> submodDirs = [];
          submodDirs.addAll(submodPathSegment);
          submodDirs.removeRange(0, submodDirs.indexOf(XFile(modDir.path).name) + 1);

          final submodName = submodDirs.join(' > ');
          //Get preview images;
          List<Uri> submodPreviewImages = [];
          final imagesInSubmodDir =
              Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
          for (var element in imagesInSubmodDir) {
            submodPreviewImages.add(Uri.file(element.path));
          }
          //Get preview videos;
          List<Uri> submodPreviewVideos = [];
          final videosInSubmodDir =
              Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
          for (var element in videosInSubmodDir) {
            submodPreviewVideos.add(Uri.file(element.path));
          }
          //Get mod files in submods
          List<ModFile> modFiles = [];
          for (var modFile in Directory(submodDir.path).listSync(recursive: false).whereType<File>()) {
            if (p.extension(modFile.path) == '') {
              //Fetch og ice location
              List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
              List<Uri> ogIceFileLocations = [];
              for (var dataFolder in dataFolders) {
                Uri iceInDataFolderPath = Uri.file('$binDirPath\\data\\$dataFolder');
                //final ogFiles = Directory(iceInDataFolderPath.toFilePath()).listSync(recursive: true).whereType<File>();
                //final matchingOGFiles = ogFiles.where((element) => XFile(element.path).name == XFile(modFile.path).name);
                // for (var ogFile in matchingOGFiles) {
                //   ogIceFileLocations.add(ogFile.uri);
                // }
                
              }

              //Populate modFiles
              modFiles.add(ModFile(XFile(modFile.path).name, submodName, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, getFileHash(modFile.path).toString(), '',
                  Uri.file(modFile.path), ogIceFileLocations, [], DateTime(0), false, false, false));
            }
          }

          //Populate submods
          submods.add(SubMod(submodName, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, Uri.file(submodDir.path), false, DateTime(0), false, false, submodPreviewImages,
              submodPreviewVideos, [], modFiles));
        }

        //Populate mods
        mods.add(
            Mod(XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, Uri.file(modDir.path), false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], submods));
      }

      //Populate items
      items.add(Item(XFile(itemDir.path).name, itemIcon, XFile(cateDir.path).name, Uri.file(itemDir.path), false, false, DateTime(0), false, mods));
    }

    //Add items to categories
    categories.add(Category(XFile(cateDir.path).name, Uri.file(cateDir.path), true, items));
  }

  //Write

  return categories;
}
