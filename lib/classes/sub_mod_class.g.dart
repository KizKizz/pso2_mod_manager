// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubMod _$SubModFromJson(Map<String, dynamic> json) => SubMod(
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
      (json['previewImages'] as List<dynamic>)
          .map((e) => Uri.parse(e as String))
          .toList(),
      (json['previewVideos'] as List<dynamic>)
          .map((e) => Uri.parse(e as String))
          .toList(),
      (json['modFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubModToJson(SubMod instance) => <String, dynamic>{
      'name': instance.name,
      'category': instance.category,
      'itemName': instance.itemName,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'appliedModFiles': instance.appliedModFiles,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'previewImages': instance.previewImages.map((e) => e.toString()).toList(),
      'previewVideos': instance.previewVideos.map((e) => e.toString()).toList(),
      'modFiles': instance.modFiles,
    };
