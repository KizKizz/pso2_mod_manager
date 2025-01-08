// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_set_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModSet _$ModSetFromJson(Map<String, dynamic> json) => ModSet(
      json['setName'] as String,
      (json['position'] as num).toInt(),
      json['visible'] as bool,
      json['expanded'] as bool,
      DateTime.parse(json['addedDate'] as String),
      (json['setItems'] as List<dynamic>)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModSetToJson(ModSet instance) => <String, dynamic>{
      'setName': instance.setName,
      'position': instance.position,
      'visible': instance.visible,
      'expanded': instance.expanded,
      'addedDate': instance.addedDate.toIso8601String(),
      'setItems': instance.setItems,
    };
