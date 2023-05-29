import 'package:json_annotation/json_annotation.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';

part 'mod_set_class.g.dart';

@JsonSerializable()
class ModSet {
  ModSet(this.setName, this.position, this.visible, this.expanded, this.addedDate, this.setItems);
  String setName;
  int position;
  bool visible;
  bool expanded;
  DateTime addedDate;
  List<Item> setItems;

  factory ModSet.fromJson(Map<String, dynamic> json) => _$ModSetFromJson(json);
  Map<String, dynamic> toJson() => _$ModSetToJson(this);
}
