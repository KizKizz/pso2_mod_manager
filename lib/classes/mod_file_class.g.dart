// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_file_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModFile _$ModFileFromJson(Map<String, dynamic> json) => ModFile(
      json['name'] as String,
      json['modName'] as String,
      json['itemName'] as String,
      json['md5'] as String,
      json['location'] as String,
      json['ogLocation'] as String,
      json['bkLocation'] as String,
      DateTime.parse(json['applyDate'] as String),
      json['applyStatus'] as bool,
      json['isNew'] as bool,
      json['isFavorite'] as bool,
    );

Map<String, dynamic> _$ModFileToJson(ModFile instance) => <String, dynamic>{
      'name': instance.name,
      'modName': instance.modName,
      'itemName': instance.itemName,
      'md5': instance.md5,
      'location': instance.location,
      'ogLocation': instance.ogLocation,
      'bkLocation': instance.bkLocation,
      'applyDate': instance.applyDate.toIso8601String(),
      'applyStatus': instance.applyStatus,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
    };
