import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';

void removeCateTypeFromFav(CategoryType originalList) {
  for (var cate in originalList.categories) {
    if (cate.items.where((element) => element.isFavorite).isNotEmpty) {
      for (var item in cate.items) {
        if (item.isFavorite) {
          for (var mod in item.mods) {
            if (mod.isFavorite) {
              for (var submod in mod.submods) {
                if (submod.isFavorite) {
                  submod.isFavorite = false;
                }
              }
              mod.isFavorite = false;
            }
          }
          item.isFavorite = false;
        }
      }
    }
  }
}

void removeCateFromFav(Category category) {
  if (category.items.where((element) => element.isFavorite).isNotEmpty) {
    for (var item in category.items) {
      if (item.isFavorite) {
        for (var mod in item.mods) {
          if (mod.isFavorite) {
            for (var submod in mod.submods) {
              if (submod.isFavorite) {
                submod.isFavorite = false;
              }
            }
            mod.isFavorite = false;
          }
        }
        item.isFavorite = false;
      }
    }
  }
}

void removeItemFromFav(Item item) {
  for (var mod in item.mods) {
    if (mod.isFavorite) {
      for (var submod in mod.submods) {
        if (submod.isFavorite) {
          submod.isFavorite = false;
        }
      }
      mod.isFavorite = false;
    }
  }
  item.isFavorite = false;
}
