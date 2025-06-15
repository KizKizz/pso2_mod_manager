import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';

part 'category_class.g.dart';

@JsonSerializable()
class Category with ChangeNotifier {
  Category(this.categoryName, this.group, this.location, this.position, this.visible, this.items);
  String categoryName;
  String group;
  String location;
  int position;
  bool visible;
  List<Item> items;

  bool _isExpanded = false;

  bool getExpansionState() {
    return _isExpanded;
  }

  void setExpansionState(bool state) {
    _isExpanded = state;
  }

  void removeItem(Item? item) {
    if (item != null) {
      items.remove(item);
    }
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  List<String> getDistinctNames() {
    List<String> names = [];
    for (var item in items) {
      names.addAll(item.getDistinctNames().where((e) => !names.contains(e)));
    }

    return names;
  }

  int getNumOfAppliedItems() {
    return items.where((e) => e.applyStatus).length;
  }

  int getNumOfMods() {
    int numOfMods = 0;
    for (var item in items) {
      numOfMods += item.mods.length;
    }
    return numOfMods;
  }

  int getNumOfModVariants() {
    int numOfVariants = 0;
    for (var item in items) {
      numOfVariants += item.getSubmods().length;
    }
    return numOfVariants;
  }

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
