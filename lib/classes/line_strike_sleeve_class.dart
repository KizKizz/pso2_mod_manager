import 'package:json_annotation/json_annotation.dart';

part 'line_strike_sleeve_class.g.dart';

@JsonSerializable()
class LineStrikeSleeve {
  LineStrikeSleeve(this.icePath, this.iconIcePath, this.iceDdsName, this.iconIceDdsName, this.iconWebPath, this.ogIceMd5, this.ogIconIceMd5, this.replacedImagePath, this.replacedIceMd5,
      this.replacedIconIceMd5, this.isReplaced);

  String icePath;
  String iconIcePath;
  String iceDdsName;
  String iconIceDdsName;
  String iconWebPath;
  String ogIceMd5;
  String ogIconIceMd5;
  String replacedImagePath;
  String replacedIceMd5;
  String replacedIconIceMd5;
  bool isReplaced;

  factory LineStrikeSleeve.fromJson(Map<String, dynamic> json) => _$LineStrikeSleeveFromJson(json);
  Map<String, dynamic> toJson() => _$LineStrikeSleeveToJson(this);
}
