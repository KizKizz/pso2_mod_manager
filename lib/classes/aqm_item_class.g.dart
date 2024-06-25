// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aqm_item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AqmItem _$AqmItemFromJson(Map<String, dynamic> json) => AqmItem(
      json['category'] as String,
      json['id'] as String,
      json['adjustedId'] as String,
      json['iconImagePath'] as String,
      json['itemNameEN'] as String,
      json['itemNameJP'] as String,
      json['hqIcePath'] as String,
      json['lqIcePath'] as String,
      json['iconIcePath'] as String,
      json['isApplied'] as bool,
      json['isIconReplaced'] as bool,
    );

Map<String, dynamic> _$AqmItemToJson(AqmItem instance) => <String, dynamic>{
      'category': instance.category,
      'id': instance.id,
      'adjustedId': instance.adjustedId,
      'iconImagePath': instance.iconImagePath,
      'itemNameEN': instance.itemNameEN,
      'itemNameJP': instance.itemNameJP,
      'hqIcePath': instance.hqIcePath,
      'lqIcePath': instance.lqIcePath,
      'iconIcePath': instance.iconIcePath,
      'isApplied': instance.isApplied,
      'isIconReplaced': instance.isIconReplaced,
    };
