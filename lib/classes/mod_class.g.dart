// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mod _$ModFromJson(Map<String, dynamic> json) => Mod(
      json['modName'] as String,
      json['itemName'] as String,
      json['category'] as String,
      json['location'] as String,
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      (json['previewImages'] as List<dynamic>).map((e) => e as String).toList(),
      (json['previewVideos'] as List<dynamic>).map((e) => e as String).toList(),
      (json['appliedSubMods'] as List<dynamic>)
          .map((e) => SubMod.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['submods'] as List<dynamic>)
          .map((e) => SubMod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModToJson(Mod instance) => <String, dynamic>{
      'modName': instance.modName,
      'itemName': instance.itemName,
      'category': instance.category,
      'location': instance.location,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'previewImages': instance.previewImages,
      'previewVideos': instance.previewVideos,
      'appliedSubMods': instance.appliedSubMods,
      'submods': instance.submods,
    };
