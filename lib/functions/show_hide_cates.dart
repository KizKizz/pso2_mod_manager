import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';

List<CategoryType> hideAllEmptyCategories(List<CategoryType> originalList) {
  List<CategoryType> hiddenList = [];
  for (var cateType in originalList) {
    bool isEmptyCatesFound = false;
    for (var cate in cateType.categories) {
      if (cate.items.isEmpty) {
        cate.visible = false;
        if (!isEmptyCatesFound) {
          isEmptyCatesFound = true;
        }
      }
    }
    hiddenList.add(cateType);
  }

  return hiddenList;
}

void showAllEmptyCategories(List<CategoryType> originalList) {
  for (var cateType in originalList) {
    for (var cate in cateType.categories) {
      if (!cate.visible) {
        cate.visible = true;
      }
    }
  }
}
