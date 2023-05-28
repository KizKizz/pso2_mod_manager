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
      json['position'] as int,
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      json['isSet'] as bool,
      (json['setNames'] as List<dynamic>).map((e) => e as String).toList(),
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
      'position': instance.position,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'isSet': instance.isSet,
      'setNames': instance.setNames,
      'previewImages': instance.previewImages,
      'previewVideos': instance.previewVideos,
      'appliedSubMods': instance.appliedSubMods,
      'submods': instance.submods,
    };
