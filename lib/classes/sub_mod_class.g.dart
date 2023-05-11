// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubMod _$SubModFromJson(Map<String, dynamic> json) => SubMod(
      json['submodName'] as String,
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
      (json['appliedModFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['modFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubModToJson(SubMod instance) => <String, dynamic>{
      'submodName': instance.submodName,
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
      'appliedModFiles': instance.appliedModFiles,
      'modFiles': instance.modFiles,
    };