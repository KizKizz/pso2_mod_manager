// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_data_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemData _$ItemDataFromJson(Map<String, dynamic> json) => ItemData(
      json['csvFileName'] as String,
      json['csvFilePath'] as String,
      json['itemType'] as String,
      (json['itemCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['category'] as String,
      json['subCategory'] as String,
      (json['categoryIndex'] as num).toInt(),
      json['iconImagePath'] as String,
      Map<String, String>.from(json['infos'] as Map),
    );

Map<String, dynamic> _$ItemDataToJson(ItemData instance) => <String, dynamic>{
      'csvFileName': instance.csvFileName,
      'csvFilePath': instance.csvFilePath,
      'itemType': instance.itemType,
      'itemCategories': instance.itemCategories,
      'category': instance.category,
      'subCategory': instance.subCategory,
      'categoryIndex': instance.categoryIndex,
      'iconImagePath': instance.iconImagePath,
      'infos': instance.infos,
    };
