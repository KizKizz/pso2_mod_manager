// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_gauge_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VitalGaugeBackground _$VitalGaugeBackgroundFromJson(
        Map<String, dynamic> json) =>
    VitalGaugeBackground(
      json['icePath'] as String,
      json['iceName'] as String,
      json['ddsName'] as String,
      json['ogMd5'] as String,
      json['replacedImagePath'] as String,
      json['replacedImageName'] as String,
      json['replacedMd5'] as String,
      json['isReplaced'] as bool,
    );

Map<String, dynamic> _$VitalGaugeBackgroundToJson(
        VitalGaugeBackground instance) =>
    <String, dynamic>{
      'icePath': instance.icePath,
      'iceName': instance.iceName,
      'ddsName': instance.ddsName,
      'ogMd5': instance.ogMd5,
      'replacedImagePath': instance.replacedImagePath,
      'replacedImageName': instance.replacedImageName,
      'replacedMd5': instance.replacedMd5,
      'isReplaced': instance.isReplaced,
    };
