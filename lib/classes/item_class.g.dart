// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      json['name'] as String,
      json['icon'] as String,
      json['category'] as String,
      json['location'] as String,
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      (json['mods'] as List<dynamic>)
          .map((e) => Mod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'name': instance.name,
      'icon': instance.icon,
      'category': instance.category,
      'location': instance.location,
      'isFavorite': instance.isFavorite,
      'isNew': instance.isNew,
      'mods': instance.mods,
    };
