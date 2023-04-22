// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_file_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModFile _$ModFileFromJson(Map<String, dynamic> json) => ModFile(
      json['name'] as String,
      json['submodName'] as String,
      json['modName'] as String,
      json['itemName'] as String,
      json['category'] as String,
      json['md5'] as String,
      json['ogMd5'] as String,
      json['location'] as String,
      (json['ogLocations'] as List<dynamic>).map((e) => e as String).toList(),
      (json['bkLocations'] as List<dynamic>).map((e) => e as String).toList(),
      DateTime.parse(json['applyDate'] as String),
      json['applyStatus'] as bool,
      json['isNew'] as bool,
      json['isFavorite'] as bool,
    );

Map<String, dynamic> _$ModFileToJson(ModFile instance) => <String, dynamic>{
      'name': instance.name,
      'submodName': instance.submodName,
      'modName': instance.modName,
      'itemName': instance.itemName,
      'category': instance.category,
      'md5': instance.md5,
      'ogMd5': instance.ogMd5,
      'location': instance.location,
      'ogLocations': instance.ogLocations,
      'bkLocations': instance.bkLocations,
      'applyDate': instance.applyDate.toIso8601String(),
      'applyStatus': instance.applyStatus,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
    };
