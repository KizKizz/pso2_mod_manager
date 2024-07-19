// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_strike_board_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineStrikeBoard _$LineStrikeBoardFromJson(Map<String, dynamic> json) =>
    LineStrikeBoard(
      json['icePath'] as String,
      json['iconIcePath'] as String,
      json['iceDdsName'] as String,
      json['iconIceDdsName'] as String,
      json['iconWebPath'] as String,
      json['replacedImagePath'] as String,
      json['replacedIceMd5'] as String,
      json['replacedIconIceMd5'] as String,
      json['isReplaced'] as bool,
    );

Map<String, dynamic> _$LineStrikeBoardToJson(LineStrikeBoard instance) =>
    <String, dynamic>{
      'icePath': instance.icePath,
      'iconIcePath': instance.iconIcePath,
      'iceDdsName': instance.iceDdsName,
      'iconIceDdsName': instance.iconIceDdsName,
      'iconWebPath': instance.iconWebPath,
      'replacedImagePath': instance.replacedImagePath,
      'replacedIceMd5': instance.replacedIceMd5,
      'replacedIconIceMd5': instance.replacedIconIceMd5,
      'isReplaced': instance.isReplaced,
    };
