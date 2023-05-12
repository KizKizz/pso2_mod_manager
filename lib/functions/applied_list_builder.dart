import 'dart:convert';

import 'package:pso2_mod_manager/classes/category_type_class.dart';

List<CategoryType> appliedListBuilder(List<CategoryType> moddedList)  {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');

  var jsonData = jsonDecode(encoder.convert(moddedList.map((cateType) => cateType.toJson()).toList()));
  // var jsonData = jsonDecode(moddedList.map((cateType) => cateType.toJson());

  List<CategoryType> newModdedList = [];
  for (var type in jsonData) {
    newModdedList.add(CategoryType.fromJson(type));
  }

  for (var cateType in newModdedList) {
    List<String> appliedCate = [];
    for (var cate in cateType.categories) {
      cate.items.retainWhere((element) => element.applyStatus == true);
      if (cate.items.isNotEmpty) {
        appliedCate.add(cate.categoryName);
      }
      for (var item in cate.items) {
        item.mods.retainWhere((element) => element.applyStatus == true);
        for (var mod in item.mods) {
          mod.submods.retainWhere((element) => element.applyStatus == true);
          for (var submod in mod.submods) {
            submod.modFiles.retainWhere((element) => element.applyStatus == true);
          }
        }
      }
    }
    cateType.categories.retainWhere((element) => appliedCate.contains(element.categoryName));
  }
  newModdedList.retainWhere((element) => element.categories.isNotEmpty);

  return newModdedList;
}
