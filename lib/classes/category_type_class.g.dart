// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_type_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryType _$CategoryTypeFromJson(Map<String, dynamic> json) => CategoryType(
      json['groupName'] as String,
      json['position'] as int,
      json['visible'] as bool,
      json['expanded'] as bool,
      (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryTypeToJson(CategoryType instance) =>
    <String, dynamic>{
      'groupName': instance.groupName,
      'position': instance.position,
      'visible': instance.visible,
      'expanded': instance.expanded,
      'categories': instance.categories,
    };
