// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_file_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModFile _$ModFileFromJson(Map<String, dynamic> json) => ModFile(
      json['modFileName'] as String,
      json['submodName'] as String,
      json['modName'] as String,
      json['itemName'] as String,
      json['category'] as String,
      json['md5'] as String,
      json['ogMd5'] as String,
      json['location'] as String,
      (json['ogLocations'] as List<dynamic>).map((e) => e as String).toList(),
      (json['bkLocations'] as List<dynamic>).map((e) => e as String).toList(),
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      json['position'] as int,
      json['isFavorite'] as bool,
      json['isSet'] as bool,
      json['isNew'] as bool,
    );

Map<String, dynamic> _$ModFileToJson(ModFile instance) => <String, dynamic>{
      'modFileName': instance.modFileName,
      'submodName': instance.submodName,
      'modName': instance.modName,
      'itemName': instance.itemName,
      'category': instance.category,
      'md5': instance.md5,
      'ogMd5': instance.ogMd5,
      'location': instance.location,
      'ogLocations': instance.ogLocations,
      'bkLocations': instance.bkLocations,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'position': instance.position,
      'isFavorite': instance.isFavorite,
      'isSet': instance.isSet,
      'isNew': instance.isNew,
    };
