// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      json['itemName'] as String,
      json['icon'] as String,
      json['category'] as String,
      json['location'] as String,
      json['isNew'] as bool,
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      json['isFavorite'] as bool,
      (json['mods'] as List<dynamic>)
          .map((e) => Mod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'itemName': instance.itemName,
      'icon': instance.icon,
      'category': instance.category,
      'location': instance.location,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'isFavorite': instance.isFavorite,
      'isNew': instance.isNew,
      'mods': instance.mods,
    };
