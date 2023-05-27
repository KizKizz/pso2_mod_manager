import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';

Future<List<CategoryType>> searchListBuilder(List<CategoryType> moddedList, String searchTerm) async {
  
  List<CategoryType> newModdedList = [];
  for (var type in moddedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            for (var modFile in submod.modFiles) {
              if (modFile.modFileName.toLowerCase().contains(searchTerm) ||
                  submod.submodName.toLowerCase().contains(searchTerm) ||
                  mod.modName.toLowerCase().contains(searchTerm) ||
                  item.itemName.toLowerCase().contains(searchTerm) ||
                  cate.categoryName.toLowerCase().contains(searchTerm)) {print('$searchTerm : ${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName} > ${modFile.modFileName}',);
                if (!newModdedList.contains(type) && type.visible) {
                  newModdedList.add(type);
                }
              }
            }
          }
        }
      }
    }
  }

  return newModdedList;
}

int cateItemSearchMatchesCheck(Category category, String searchTerm) {
  int matchingCount = 0;
  for (var item in category.items) {
    bool found = false;
    for (var mod in item.mods) {
      for (var submod in mod.submods) {
        for (var modFile in submod.modFiles) {
          if (modFile.modFileName.toLowerCase().contains(searchTerm) || submod.submodName.toLowerCase().contains(searchTerm) || mod.modName.toLowerCase().contains(searchTerm) || item.itemName.toLowerCase().contains(searchTerm)) {
            found = true;
            break;
          }
        }
        if (found) {
          break;
        }
      }
      if (found) {
        break;
      }
    }
    if (found) {
      matchingCount++;
    }
  }

  return matchingCount;
}

int itemModSearchMatchesCheck(Item item, String searchTerm) {
  int matchingCount = 0;

  for (var mod in item.mods) {
    bool found = false;
    for (var submod in mod.submods) {
      for (var modFile in submod.modFiles) {
        if (modFile.modFileName.toLowerCase().contains(searchTerm) || submod.submodName.toLowerCase().contains(searchTerm) || mod.modName.toLowerCase().contains(searchTerm)) {
          found = true;
          break;
        }
      }
      if (found) {
        break;
      }
    }
    if (found) {
      matchingCount++;
    }
  }

  return matchingCount;
}
