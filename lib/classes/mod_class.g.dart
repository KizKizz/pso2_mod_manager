// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mod _$ModFromJson(Map<String, dynamic> json) => Mod(
      json['name'] as String,
      json['category'] as String,
      json['itemName'] as String,
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      (json['appliedModFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      (json['modFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['previewImages'] as List<dynamic>).map((e) => e as String).toList(),
      (json['previewVideos'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ModToJson(Mod instance) => <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'itemName': instance.itemName,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'appliedModFiles': instance.appliedModFiles,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'modFiles': instance.modFiles,
      'previewImages': instance.previewImages,
      'previewVideos': instance.previewVideos,
    };
