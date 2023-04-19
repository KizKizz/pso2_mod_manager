// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      json['name'] as String,
      json['location'] as String,
      (json['items'] as List<dynamic>)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['visible'] as bool,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'items': instance.items,
      'visible': instance.visible,
    };
