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
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

import '../main.dart';

Future<List<Category>> modFilesLoader(String modsDirPath) async {
  //Load local json
  var jsonData = jsonDecode(File(modsListJsonPath.toFilePath()).readAsStringSync());
  var jsonCategories = [];
  for (var cate in jsonData) {
    jsonCategories.add(Category.fromJson(cate));
  }

  //Load local data
  List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  List<Category> categories = [];
  final dirsInModsDir = Directory(modsDirPath).listSync(recursive: false);
  for (var cateDir in dirsInModsDir) {
    List<Item> items = [];
    for (var itemDir in Directory(cateDir.path).listSync(recursive: false)) {
      //Get item icon
      String itemIcon = '';
      final imagesInItemDir = Directory(itemDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
      if (imagesInItemDir.isNotEmpty) {
        itemIcon = Uri.file(imagesInItemDir.first.path).toFilePath();
      } else {
        itemIcon = Uri.file('assets/img/placeholdersquare.png').toFilePath();
      }

      //Get mods in items
      List<Mod> mods = [];
      for (var modDir in Directory(itemDir.path).listSync(recursive: false).whereType<Directory>()) {
        //Get preview images;
        List<String> modPreviewImages = [];
        final imagesInModDir = Directory(modDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in imagesInModDir) {
          modPreviewImages.add(Uri.file(element.path).toFilePath());
        }
        //Get preview videps;
        List<String> modPreviewVideos = [];
        final videosInModDir = Directory(modDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in videosInModDir) {
          modPreviewVideos.add(Uri.file(element.path).toFilePath());
        }

        //Get submods in mods
        List<SubMod> submods = [];
        //Get modfiles in mods
        final modFilesInModDir = Directory(modDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '');
        if (modFilesInModDir.isNotEmpty) {
          //Set submods
          //Get mod files in submods
          List<ModFile> modFilesInMainDir = [];
          for (var modFile in modFilesInModDir) {
            //Fetch og ice location
            List<String> ogIceFileLocations = [];
            for (var dataFolder in dataFolders) {
              String iceInDataFolderPath = Uri.file('$pso2binPath/data/$dataFolder').toFilePath();
              final ogFiles = Directory(iceInDataFolderPath).listSync(recursive: true).whereType<File>();
              final matchingOGFiles = ogFiles.where((element) => XFile(element.path).name == XFile(modFile.path).name);
              for (var ogFile in matchingOGFiles) {
                ogIceFileLocations.add(Uri.file(ogFile.path).toFilePath());
              }
            }

            //Populate modFiles
            modFilesInMainDir.add(ModFile(XFile(modFile.path).name, XFile(modDir.path).name, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name,
                getFileHash(modFile.path).toString(), '', Uri.file(modFile.path).toFilePath(), ogIceFileLocations, [], DateTime(0), false, false, false));
          }

          //Populate submods
          submods.add(SubMod(XFile(modDir.path).name, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, Uri.file(modDir.path).toFilePath(), false, DateTime(0), false, false,
              modPreviewImages, modPreviewVideos, [], modFilesInMainDir));
        }

        //Get submods
        for (var submodDir in Directory(modDir.path).listSync(recursive: true).whereType<Directory>()) {
          //Fetch submod name
          List<String> submodPathSegment = Uri.file(submodDir.path).pathSegments;
          List<String> submodDirs = [];
          submodDirs.addAll(submodPathSegment);
          submodDirs.removeRange(0, submodDirs.indexOf(XFile(modDir.path).name) + 1);
          final submodName = submodDirs.join(' > ');
          //Get preview images;
          List<String> submodPreviewImages = [];
          final imagesInSubmodDir =
              Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
          for (var element in imagesInSubmodDir) {
            submodPreviewImages.add(Uri.file(element.path).toFilePath());
          }
          //Get preview videos;
          List<String> submodPreviewVideos = [];
          final videosInSubmodDir =
              Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
          for (var element in videosInSubmodDir) {
            submodPreviewVideos.add(Uri.file(element.path).toFilePath());
          }
          //Get mod files in submods
          List<ModFile> modFiles = [];
          for (var modFile in Directory(submodDir.path).listSync(recursive: false).whereType<File>()) {
            if (p.extension(modFile.path) == '') {
              //Fetch og ice location
              List<String> ogIceFileLocations = [];
              for (var dataFolder in dataFolders) {
                String iceInDataFolderPath = Uri.file('$binDirPath/data/$dataFolder').toFilePath();
                final ogFiles = Directory(iceInDataFolderPath).listSync(recursive: true).whereType<File>();
                final matchingOGFiles = ogFiles.where((element) => XFile(element.path).name == XFile(modFile.path).name);
                for (var ogFile in matchingOGFiles) {
                  ogIceFileLocations.add(Uri.file(ogFile.path).toFilePath());
                }
              }

              //Populate modFiles
              modFiles.add(ModFile(XFile(modFile.path).name, submodName, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, getFileHash(modFile.path).toString(), '',
                  Uri.file(modFile.path).toFilePath(), ogIceFileLocations, [], DateTime(0), false, false, false));
            }
          }

          //Populate submods
          submods.add(SubMod(submodName, XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, Uri.file(submodDir.path).toFilePath(), false, DateTime(0), false, false, submodPreviewImages,
              submodPreviewVideos, [], modFiles));
        }

        //Populate mods
        mods.add(
            Mod(XFile(modDir.path).name, XFile(itemDir.path).name, XFile(cateDir.path).name, Uri.file(modDir.path).toFilePath(), false, DateTime(0), false, false, modPreviewImages, modPreviewVideos, [], submods));
      }

      //Populate items
      items.add(Item(XFile(itemDir.path).name, itemIcon, XFile(cateDir.path).name, Uri.file(itemDir.path).toFilePath(), false, false, DateTime(0), false, mods));
    }

    //Add items to categories
    categories.add(Category(XFile(cateDir.path).name, Uri.file(cateDir.path).toFilePath(), true, items));
  }

  //Write

  return categories;
}
