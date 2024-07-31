import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';

// Future<List<CategoryType>> searchListBuilder(List<CategoryType> moddedList, String searchTerm) async {
//   List<CategoryType> newModdedList = [];
//   for (var type in moddedList) {
//     for (var cate in type.categories) {
//       for (var item in cate.items) {
//         for (var mod in item.mods) {
//           for (var submod in mod.submods) {
//             for (var modFile in submod.modFiles) {
//               if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) ||
//                   submod.submodName.toLowerCase().contains(searchTerm.toLowerCase()) ||
//                   mod.modName.toLowerCase().contains(searchTerm.toLowerCase()) ||
//                   item.itemName.toLowerCase().contains(searchTerm.toLowerCase()) ||
//                   cate.categoryName.toLowerCase().contains(searchTerm.toLowerCase())) {
//                 //print('$searchTerm : ${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName} > ${modFile.modFileName}',);
//                 if (!newModdedList.contains(type) && type.visible) {
//                   newModdedList.add(type);
//                 }
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   return newModdedList;
// }

List<String> searchResultCateTypesGet(List<CategoryType> moddedList, String searchTerm) {
  List<String> matchedType = [];
  for (var type in moddedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            for (var modFile in submod.modFiles) {
              if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                  submod.submodName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                  mod.modName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                  item.itemName.toLowerCase().contains(searchTerm.toLowerCase()) ||
                  cate.categoryName.toLowerCase().contains(searchTerm.toLowerCase())) {
                //print('$searchTerm : ${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName} > ${modFile.modFileName}',);
                if (!matchedType.contains(type.groupName) && type.visible) {
                  matchedType.add(type.groupName);
                }
              }
            }
          }
        }
      }
    }
  }

  return matchedType;
}

int cateItemSearchMatchesCheck(Category category, String searchTerm) {
  int matchingCount = 0;
  for (var item in category.items) {
    bool found = false;
    for (var mod in item.mods) {
      for (var submod in mod.submods) {
        for (var modFile in submod.modFiles) {
          if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) ||
              submod.submodName.toLowerCase().contains(searchTerm.toLowerCase()) ||
              mod.modName.toLowerCase().contains(searchTerm.toLowerCase()) ||
              item.itemName.toLowerCase().contains(searchTerm.toLowerCase())) {
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
        if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) || submod.submodName.toLowerCase().contains(searchTerm.toLowerCase()) || mod.modName.toLowerCase().contains(searchTerm.toLowerCase())) {
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

int modSearchMatchesCheck(Mod mod, String searchTerm) {
  int matchingCount = 0;

  for (var submod in mod.submods) {
    bool found = false;
    for (var modFile in submod.modFiles) {
      if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) || submod.submodName.toLowerCase().contains(searchTerm.toLowerCase())) {
        found = true;
        break;
      }
    }
    if (found) {
      matchingCount++;
    }
  }
  return matchingCount;
}

int submodSearchMatchesCheck(SubMod submod, String searchTerm) {
  int matchingCount = 0;

  for (var modFile in submod.modFiles) {
    if (modFile.modFileName.toLowerCase().contains(searchTerm.toLowerCase()) || submod.submodName.toLowerCase().contains(searchTerm.toLowerCase())) {
      matchingCount++;
    }
  }
  return matchingCount;
}
