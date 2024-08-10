import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';

part 'mod_set_class.g.dart';

@JsonSerializable()
class ModSet with ChangeNotifier {
  ModSet(this.setName, this.position, this.visible, this.expanded, this.addedDate, this.setItems);
  String setName;
  int position;
  bool visible;
  bool expanded;
  DateTime addedDate;
  List<Item> setItems;

  void addItem(Item item) {
    setItems.add(item);
    notifyListeners();
  }

  void removeItem(Item item) {
    setItems.remove(item);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  factory ModSet.fromJson(Map<String, dynamic> json) => _$ModSetFromJson(json);
  Map<String, dynamic> toJson() => _$ModSetToJson(this);
}
