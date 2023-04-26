import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_type_class.g.dart';

@JsonSerializable()
class CategoryType {
  CategoryType(this.groupName, this.position, this.visible, this.expanded, this.categories);
  String groupName;
  int position;
  bool visible;
  bool expanded;
  List<Category> categories;

  factory CategoryType.fromJson(Map<String, dynamic> json) => _$CategoryTypeFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);
}
