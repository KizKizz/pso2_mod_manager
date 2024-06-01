// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      json['itemName'] as String,
      (json['variantNames'] as List<dynamic>).map((e) => e as String).toList(),
      (json['icons'] as List<dynamic>).map((e) => e as String).toList(),
      json['iconPath'] as String?,
      json['overlayedIconPath'] as String?,
      json['backupIconPath'] as String?,
      json['isOverlayedIconApplied'] as bool?,
      json['category'] as String,
      json['location'] as String,
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      json['position'] as int,
      json['isFavorite'] as bool,
      json['isSet'] as bool,
      json['isNew'] as bool,
      (json['setNames'] as List<dynamic>).map((e) => e as String).toList(),
      (json['mods'] as List<dynamic>)
          .map((e) => Mod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'itemName': instance.itemName,
      'variantNames': instance.variantNames,
      'icons': instance.icons,
      'iconPath': instance.iconPath,
      'overlayedIconPath': instance.overlayedIconPath,
      'backupIconPath': instance.backupIconPath,
      'isOverlayedIconApplied': instance.isOverlayedIconApplied,
      'category': instance.category,
      'location': instance.location,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'position': instance.position,
      'isFavorite': instance.isFavorite,
      'isSet': instance.isSet,
      'isNew': instance.isNew,
      'setNames': instance.setNames,
      'mods': instance.mods,
    };
