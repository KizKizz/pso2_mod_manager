import 'dart:io';

import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';

Future<List<Item>> appliedModsCheck() async {
  if (masterModList.isEmpty) {
    return [];
  } else {
    List<Item> unappliedItems = [];
    for (var cateType in masterModList) {
      for (var cate in cateType.categories) {
        for (var item in cate.items.where((e) => e.applyStatus)) {
          for (var mod in item.mods.where((e) => e.applyStatus)) {
            for (var submod in mod.submods.where((e) => e.applyStatus)) {
              for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
                for (var path in modFile.ogLocations) {
                  modFile.ogMd5s.clear();
                  modFile.ogMd5s.add(await File(path).getMd5Hash());
                  if (modFile.md5.isEmpty) modFile.md5 = await File(modFile.location).getMd5Hash();
                  if (modFile.ogMd5s.first != modFile.md5) {
                    unappliedItems.add(item);
                    break;
                  }
                }
                if (unappliedItems.contains(item)) break;
              }
              if (unappliedItems.contains(item)) break;
            }
            if (unappliedItems.contains(item)) break;
          }
        }
      }
    }
    return unappliedItems;
  }
}

Future<List<Item>> appliedModsFetch() async {
  if (masterModList.isEmpty) {
    return [];
  } else {
    List<Item> unappliedItems = [];
    for (var cateType in masterModList) {
      for (var cate in cateType.categories) {
        for (var item in cate.items.where((e) => e.applyStatus)) {
          if (item.getModsAppliedState()) {
            unappliedItems.add(item);
          }
        }
      }
    }
    return unappliedItems;
  }
}
