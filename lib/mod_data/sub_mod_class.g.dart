// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_mod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubMod _$SubModFromJson(Map<String, dynamic> json) => SubMod(
      json['submodName'] as String,
      json['modName'] as String,
      json['itemName'] as String,
      json['category'] as String,
      json['location'] as String,
      json['applyStatus'] as bool,
      DateTime.parse(json['applyDate'] as String),
      (json['position'] as num).toInt(),
      json['isNew'] as bool,
      json['isFavorite'] as bool,
      json['isSet'] as bool,
      (json['activeInSets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['hasCmx'] as bool?,
      json['cmxApplied'] as bool?,
      (json['cmxStartPos'] as num?)?.toInt(),
      (json['cmxEndPos'] as num?)?.toInt(),
      json['cmxFile'] as String?,
      (json['setNames'] as List<dynamic>).map((e) => e as String).toList(),
      (json['applyLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      (json['previewImages'] as List<dynamic>).map((e) => e as String).toList(),
      (json['previewVideos'] as List<dynamic>).map((e) => e as String).toList(),
      (json['appliedModFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['modFiles'] as List<dynamic>)
          .map((e) => ModFile.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..creationDate = json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String)
      ..applyHQFilesOnly = json['applyHQFilesOnly'] as bool?
      ..customAQMInjected = json['customAQMInjected'] as bool?
      ..customAQMFileName = json['customAQMFileName'] as String?
      ..hqIcePath = json['hqIcePath'] as String?
      ..lqIcePath = json['lqIcePath'] as String?
      ..boundingRemoved = json['boundingRemoved'] as bool?;

Map<String, dynamic> _$SubModToJson(SubMod instance) => <String, dynamic>{
      'submodName': instance.submodName,
      'modName': instance.modName,
      'itemName': instance.itemName,
      'category': instance.category,
      'location': instance.location,
      'applyStatus': instance.applyStatus,
      'applyDate': instance.applyDate.toIso8601String(),
      'creationDate': instance.creationDate?.toIso8601String(),
      'applyHQFilesOnly': instance.applyHQFilesOnly,
      'customAQMInjected': instance.customAQMInjected,
      'customAQMFileName': instance.customAQMFileName,
      'hqIcePath': instance.hqIcePath,
      'lqIcePath': instance.lqIcePath,
      'boundingRemoved': instance.boundingRemoved,
      'position': instance.position,
      'isNew': instance.isNew,
      'isFavorite': instance.isFavorite,
      'isSet': instance.isSet,
      'activeInSets': instance.activeInSets,
      'hasCmx': instance.hasCmx,
      'cmxApplied': instance.cmxApplied,
      'cmxStartPos': instance.cmxStartPos,
      'cmxEndPos': instance.cmxEndPos,
      'cmxFile': instance.cmxFile,
      'setNames': instance.setNames,
      'applyLocations': instance.applyLocations,
      'previewImages': instance.previewImages,
      'previewVideos': instance.previewVideos,
      'appliedModFiles': instance.appliedModFiles,
      'modFiles': instance.modFiles,
    };
