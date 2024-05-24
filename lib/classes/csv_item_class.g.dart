// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CsvItem _$CsvItemFromJson(Map<String, dynamic> json) => CsvItem(
      json['csvFileName'] as String,
      json['csvFilePath'] as String,
      json['itemType'] as String,
      (json['itemCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['category'] as String,
      json['categoryIndex'] as int,
      json['iconImagePath'] as String,
      Map<String, String>.from(json['infos'] as Map),
    );

Map<String, dynamic> _$CsvItemToJson(CsvItem instance) => <String, dynamic>{
      'csvFileName': instance.csvFileName,
      'csvFilePath': instance.csvFilePath,
      'itemType': instance.itemType,
      'itemCategories': instance.itemCategories,
      'category': instance.category,
      'categoryIndex': instance.categoryIndex,
      'iconImagePath': instance.iconImagePath,
      'infos': instance.infos,
    };
