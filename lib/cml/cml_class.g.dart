// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cml_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cml _$CmlFromJson(Map<String, dynamic> json) => Cml()
  ..id = json['id'] as String
  ..aId = json['aId'] as String
  ..itemNameEN = json['itemNameEN'] as String
  ..itemNameJP = json['itemNameJP'] as String
  ..isReplaced = json['isReplaced'] as bool
  ..replacedCmlFileName = json['replacedCmlFileName'] as String
  ..cloudItemIconPath = json['cloudItemIconPath'] as String
  ..itemIconWebPath = json['itemIconWebPath'] as String
  ..itemIconReplaced = json['itemIconReplaced'] as bool;

Map<String, dynamic> _$CmlToJson(Cml instance) => <String, dynamic>{
      'id': instance.id,
      'aId': instance.aId,
      'itemNameEN': instance.itemNameEN,
      'itemNameJP': instance.itemNameJP,
      'isReplaced': instance.isReplaced,
      'replacedCmlFileName': instance.replacedCmlFileName,
      'cloudItemIconPath': instance.cloudItemIconPath,
      'itemIconWebPath': instance.itemIconWebPath,
      'itemIconReplaced': instance.itemIconReplaced,
    };
