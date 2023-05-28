import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';

List<Item> itemsFromAppliedListFetch(List<CategoryType> appliedList) {
  List<Item> newItemList = [];
  for (var type in appliedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        if (item.applyStatus == true) {
          item.isSet = true;
          newItemList.add(item);
        }
      }
    }
  }

  return newItemList;
}

void setModSetNameToItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.applyStatus) {
      item.setNames.add(modSetName);
      for (var mod in item.mods) {
        if (mod.applyStatus) {
          mod.isSet = true;
          mod.setNames.add(modSetName);
          for (var submod in mod.submods) {
            if (submod.applyStatus) {
              submod.isSet = true;
              submod.setNames.add(modSetName);
              for (var modFile in submod.modFiles) {
                if (modFile.applyStatus) {
                  modFile.isSet = true;
                  modFile.setNames.add(modSetName);
                }
              }
            }
          }
        }
      }
    }
  }
}
