import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:json_annotation/json_annotation.dart';

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

  int getNumOfAppliedItems() {
    return items.where((e) => e.applyStatus).length;
  }

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
