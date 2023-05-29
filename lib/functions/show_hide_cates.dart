import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';

void hideCategory(CategoryType categoryType, Category category) {
  category.visible = false;
  if (categoryType.categories.where((element) => element.visible).isEmpty) {
    categoryType.visible = false;
  }
}

Future<List<CategoryType>> hideAllEmptyCategories(List<CategoryType> originalList) async {
  List<CategoryType> hiddenList = [];
  for (var cateType in originalList) {
    for (var cate in cateType.categories) {
      if (cate.items.isEmpty && cate.visible) {
        cate.visible = false;
      }
    }
    if (cateType.categories.isNotEmpty && cateType.categories.where((element) => element.visible).isEmpty) {
      cateType.visible = false;
    }
    if (cateType.categories.isNotEmpty && cateType.categories.where((element) => !element.visible).isNotEmpty) {
      hiddenList.add(cateType);
    }
  }

  return hiddenList;
}

Future<List<CategoryType>> hiddenCategoriesGet(List<CategoryType> originalList) async {
  List<CategoryType> hiddenList = [];
  for (var cateType in originalList) {
    if (cateType.categories.where((element) => !element.visible).isNotEmpty) {
      hiddenList.add(cateType);
    }
  }

  return hiddenList;
}

void showAllEmptyCategories(List<CategoryType> originalList) {
  for (var cateType in originalList) {
    for (var cate in cateType.categories) {
      if (cate.items.isEmpty && !cate.visible) {
        cate.visible = true;
      }
    }
    if (cateType.categories.where((element) => element.visible).isNotEmpty) {
      cateType.visible = true;
    }
  }
}

void showHiddenCategory(List<CategoryType> hiddenList, CategoryType categoryType, Category category) {
  category.visible = true;
  if (categoryType.categories.where((element) => element.visible).isNotEmpty) {
    categoryType.visible = true;
  }
  if (categoryType.categories.where((element) => !element.visible).isEmpty) {
    hiddenList.remove(categoryType);
  }
}

void showAllHiddenCategory(List<CategoryType> hiddenList, CategoryType categoryType, Category category) {
  category.visible = true;
  if (categoryType.categories.where((element) => element.visible).isNotEmpty) {
    categoryType.visible = true;
  }
}
