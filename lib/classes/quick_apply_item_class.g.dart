// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_apply_item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickApplyItem _$QuickApplyItemFromJson(Map<String, dynamic> json) =>
    QuickApplyItem(
      json['category'] as String,
      json['id'] as String,
      json['adjustedId'] as String,
      json['iconImagePath'] as String,
      json['itemNameEN'] as String,
      json['itemNameJP'] as String,
      json['isApplied'] as bool,
    );

Map<String, dynamic> _$QuickApplyItemToJson(QuickApplyItem instance) =>
    <String, dynamic>{
      'category': instance.category,
      'id': instance.id,
      'adjustedId': instance.adjustedId,
      'iconImagePath': instance.iconImagePath,
      'itemNameEN': instance.itemNameEN,
      'itemNameJP': instance.itemNameJP,
      'isApplied': instance.isApplied,
    };
