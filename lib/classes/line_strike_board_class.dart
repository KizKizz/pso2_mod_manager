import 'package:json_annotation/json_annotation.dart';

part 'line_strike_board_class.g.dart';

@JsonSerializable()
class LineStrikeBoard {
  LineStrikeBoard(this.icePath, this.iconIcePath, this.iceDdsName, this.iconIceDdsName, this.iconWebPath, this.replacedImagePath, this.replacedIceMd5,
      this.replacedIconIceMd5, this.isReplaced);

  String icePath;
  String iconIcePath;
  String iceDdsName;
  String iconIceDdsName;
  String iconWebPath;
  String replacedImagePath;
  String replacedIceMd5;
  String replacedIconIceMd5;
  bool isReplaced;

  factory LineStrikeBoard.fromJson(Map<String, dynamic> json) => _$LineStrikeBoardFromJson(json);
  Map<String, dynamic> toJson() => _$LineStrikeBoardToJson(this);
}
