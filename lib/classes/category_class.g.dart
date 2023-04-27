// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      json['categoryName'] as String,
      json['group'] as String,
      json['location'] as String,
      json['visible'] as bool,
      (json['items'] as List<dynamic>)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'categoryName': instance.categoryName,
      'group': instance.group,
      'location': instance.location,
      'visible': instance.visible,
      'items': instance.items,
    };
