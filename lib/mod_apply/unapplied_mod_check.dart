import 'dart:io';

import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/system_loads/app_applied_mods_check_page.dart';

Future<List<Item>> unappliedItemsGet() async {
  List<Item> unappliedItemList = [];
  for (var type in masterModList) {
    if (type.getNumOfAppliedCates() > 0) {
      Iterable<Category> categories = type.categories.where((e) => e.getNumOfAppliedItems() > 0);
      for (var category in categories) {
        Iterable<Item> items = category.items.where((e) => e.getNumOfAppliedMods() > 0);
        for (var item in items) {
          bool added = false;
          Iterable<Mod> mods = item.mods.where((e) => e.getNumOfAppliedSubmods() > 0);
          for (var mod in mods) {
            Iterable<SubMod> submods = mod.submods.where((e) => e.applyStatus);
            for (var submod in submods) {
              for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
                if (modFile.applyStatus) {
                  unappliedItemCheckStatus.value = '${category.categoryName}\n${item.itemName}\n${mod.modName}\n${submod.submodName}\n${modFile.modFileName}';
                  await Future.delayed(const Duration(microseconds: 500));
                  for (var path in modFile.ogLocations) {
                    modFile.ogMd5s.clear();
                    if (await File(path).exists()) {
                      modFile.ogMd5s.add(await File(path).getMd5Hash());
                    } else {
                      unappliedItemList.add(item);
                      added = true;
                    }
                    if (modFile.md5.isEmpty) modFile.md5 = await File(modFile.location).getMd5Hash();
                    if (!unappliedItemList.contains(item) && modFile.ogMd5s.first != modFile.md5) {
                      unappliedItemList.add(item);
                      added = true;
                    }

                    if (added) break;
                  }
                }

                if (added) break;
              }

              if (added) break;
            }

            if (added) break;
          }
        }
      }
    }
  }

  return unappliedItemList;
}
