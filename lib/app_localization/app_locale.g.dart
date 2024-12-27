// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_locale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppLocale _$AppLocaleFromJson(Map<String, dynamic> json) => AppLocale()
  ..language = json['language'] as String
  ..version = (json['version'] as num).toInt()
  ..translationFilePath = json['translationFilePath'] as String
  ..isActive = json['isActive'] as bool;

Map<String, dynamic> _$AppLocaleToJson(AppLocale instance) => <String, dynamic>{
      'language': instance.language,
      'version': instance.version,
      'translationFilePath': instance.translationFilePath,
      'isActive': instance.isActive,
    };
