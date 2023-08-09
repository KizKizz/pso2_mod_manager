// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModManProfile _$ModManProfileFromJson(Map<String, dynamic> json) =>
    ModManProfile(
      json['profileName'] as String,
      json['pso2binPath'] as String,
      json['mainModManPath'] as String,
      json['modListSettingsPath'] as String,
      json['modSetSettingPath'] as String,
      json['isDefault'] as bool,
    );

Map<String, dynamic> _$ModManProfileToJson(ModManProfile instance) =>
    <String, dynamic>{
      'profileName': instance.profileName,
      'pso2binPath': instance.pso2binPath,
      'mainModManPath': instance.mainModManPath,
      'modListSettingsPath': instance.modListSettingsPath,
      'modSetSettingPath': instance.modSetSettingPath,
      'isDefault': instance.isDefault,
    };
