// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mod _$ModFromJson(Map<String, dynamic> json) => Mod(
      json['name'] as String,
      json['itemName'] as String,
      json['category'] as String,
      Uri.parse(json['location'] as String),
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      (json['previewImages'] as List<dynamic>)
          .map((e) => Uri.parse(e as String))
          .toList(),
      (json['previewVideos'] as List<dynamic>)
          .map((e) => Uri.parse(e as String))
          .toList(),
      (json['appliedSubMods'] as List<dynamic>)
          .map((e) => SubMod.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['subMods'] as List<dynamic>)
          .map((e) => SubMod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModToJson(Mod instance) => <String, dynamic>{
      'name': instance.name,
      'itemName': instance.itemName,
      'category': instance.category,
      'location': instance.location.toString(),
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'previewImages': instance.previewImages.map((e) => e.toString()).toList(),
      'previewVideos': instance.previewVideos.map((e) => e.toString()).toList(),
      'appliedSubMods': instance.appliedSubMods,
      'subMods': instance.subMods,
    };
