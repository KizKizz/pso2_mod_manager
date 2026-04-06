// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqm_injected_item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AqmInjectedItem _$AqmInjectedItemFromJson(Map<String, dynamic> json) =>
    AqmInjectedItem(
      json['category'] as String,
      json['id'] as String,
      json['adjustedId'] as String,
      json['iconImagePath'] as String,
      json['itemNameEN'] as String,
      json['itemNameJP'] as String,
      json['hqIcePath'] as String,
      json['lqIcePath'] as String,
      json['iconIcePath'] as String,
      json['injectedAQMFilePath'] as String?,
      json['injectedHqIceMd5'] as String?,
      json['injectedLqIceMd5'] as String?,
      json['isApplied'] as bool,
      json['isIconReplaced'] as bool,
      json['isAqmReplaced'] as bool?,
      json['isBoundingRemoved'] as bool?,
    );

Map<String, dynamic> _$AqmInjectedItemToJson(AqmInjectedItem instance) =>
    <String, dynamic>{
      'category': instance.category,
      'id': instance.id,
      'adjustedId': instance.adjustedId,
      'iconImagePath': instance.iconImagePath,
      'itemNameEN': instance.itemNameEN,
      'itemNameJP': instance.itemNameJP,
      'hqIcePath': instance.hqIcePath,
      'lqIcePath': instance.lqIcePath,
      'iconIcePath': instance.iconIcePath,
      'injectedAQMFilePath': instance.injectedAQMFilePath,
      'injectedHqIceMd5': instance.injectedHqIceMd5,
      'injectedLqIceMd5': instance.injectedLqIceMd5,
      'isApplied': instance.isApplied,
      'isIconReplaced': instance.isIconReplaced,
      'isAqmReplaced': instance.isAqmReplaced,
      'isBoundingRemoved': instance.isBoundingRemoved,
    };
