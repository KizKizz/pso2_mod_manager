import 'dart:io';

import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<void> modsExport(List<CategoryType> baseList, List<SubMod> exportSubmods) async {
  await Directory(modManExportedPath).create(recursive: true);
  List<Category> exportCateList = [];
  for (var exportSub in exportSubmods) {
    Directory exportingModDir = Directory(exportSub.location).parent;
    Directory exportingItemDir = Directory(exportSub.location).parent.parent;
    //item
    Item exportingItem = Item('${exportSub.itemName} - ${curLangText!.uiImported}', [], icons, exportSub.category, expo, applyStatus, applyDate, position, isFavorite, isSet, isNew, setNames, mods)
    //mod
    
    final exportingModImages =
        exportingModDir.listSync(recursive: false).whereType<File>().where(((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png')).map((e) => e.path).toList();
    final exportingModVids =
        exportingModDir.listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4').map((e) => e.path).toList();
    Mod exportingMod = Mod('${exportSub.modName} - ${curLangText!.uiImported}', exportSub.itemName, exportSub.category, exportingModDir.path, false, DateTime(0), 0, true, false, false, [],
        exportingModImages, exportingModVids, [], []);
    //submod
    SubMod exportingSub = SubMod(
        '${exportSub.submodName} - ${curLangText!.uiImported}',
        '${exportSub.modName} - ${curLangText!.uiImported}',
        exportSub.itemName,
        exportSub.category,
        exportSub.location,
        false,
        DateTime(0),
        0,
        true,
        false,
        false,
        exportSub.hasCmx,
        false,
        0,
        0,
        exportSub.cmxFile,
        [],
        exportSub.previewImages.toList(),
        exportSub.previewVideos.toList(),
        [],
        exportSub.modFiles.toList());
  }
}
