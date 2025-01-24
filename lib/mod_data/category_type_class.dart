import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';

part 'category_type_class.g.dart';

@JsonSerializable()
class CategoryType with ChangeNotifier {
  CategoryType(this.groupName, this.position, this.visible, this.expanded, this.categories);
  String groupName;
  int position;
  bool visible;
  bool expanded;
  List<Category> categories;

  void refresh() {
    notifyListeners();
  }

  int getNumOfAppliedCates() {
    return categories.where((e) => e.getNumOfAppliedItems() > 0).length;
  }

  List<String> getDistinctNames() {
    List<String> names = [];
    for (var category in categories) {
      names.addAll(category.getDistinctNames().where((e) => !names.contains(e)));
    }

    return names;
  }

  bool containsCategory(String categoryName) {
    if (categories.indexWhere((e) => e.categoryName == categoryName) != -1) {
      return true;
    } else {
      return false;
    }
  }

  factory CategoryType.fromJson(Map<String, dynamic> json) => _$CategoryTypeFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);
}
