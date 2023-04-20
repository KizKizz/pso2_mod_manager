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

import '../main.dart';

List<Category> startupLoader(String modsDirPath) {
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
      for (var modDir in Directory(itemDir.path).listSync(recursive: false)) {
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
        for (var submodDir in Directory(modDir.path).listSync(recursive: false)) {
          //Get preview images;
        List<Uri> submodPreviewImages = [];
        final imagesInSubmodDir = Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in imagesInSubmodDir) {
          submodPreviewImages.add(Uri.file(element.path));
        }
        //Get preview videps;
        List<Uri> submodPreviewVideos = [];
        final videosInSubmodDir = Directory(submodDir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
        for (var element in videosInSubmodDir) {
          submodPreviewVideos.add(Uri.file(element.path));
        }

        //Get mod files in submods
        List<ModFile> modfiles = [];
        for (var modfile in Directory(submodDir.path).listSync(recursive: false)) {
          if ()
        }
          
          //Populate submods
          submods.add(SubMod(XFile(submodDir.path).name, XFile(cateDir.path).name, XFile(itemDir.path).name, false, DateTime(0), [], false, false, submodPreviewImages, submodPreviewVideos, modFiles))
        }

        //Populate mods
        mods.add(Mod(XFile(modDir.path).name, XFile(cateDir.path).name, XFile(itemDir.path).name, false, DateTime(0), [], false, false, modPreviewImages, modPreviewVideos, submods));
      }

      //Populate items
      items.add(Item(XFile(itemDir.path).name, itemIcon, XFile(cateDir.path).name, itemDir.path, false, false, mods));
    }

    //Add items to categories
    categories.add(Category(XFile(cateDir.path).name, Uri.file(cateDir.path), true, items));
  }

  //Write

  return categories;
}
