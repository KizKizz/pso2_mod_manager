import 'package:json_annotation/json_annotation.dart';

part 'line_strike_card_class.g.dart';

@JsonSerializable()
class LineStrikeCard {
  LineStrikeCard(
      this.cardZeroIcePath,
      this.cardZeroIconIcePath,
      this.cardZeroDdsName,
      this.cardZeroIconDdsName,
      this.cardZeroIconWebPath,
      this.cardZeroSquareIconWebPath,
      this.cardZeroReplacedIceMd5,
      this.cardZeroReplacedIconIceMd5,
      this.cardOneIcePath,
      this.cardOneIconIcePath,
      this.cardOneDdsName,
      this.cardOneIconDdsName,
      this.cardOneIconWebPath,
      this.cardOneSquareIconWebPath,
      this.cardOneReplacedIceMd5,
      this.cardOneReplacedIconIceMd5,
      this.replacedImagePath,
      this.isReplaced);

  //card0
  String cardZeroIcePath;
  String cardZeroIconIcePath;
  String cardZeroDdsName;
  String cardZeroIconDdsName;
  String cardZeroIconWebPath;
  String cardZeroSquareIconWebPath;
  String cardZeroReplacedIceMd5;
  String cardZeroReplacedIconIceMd5;
  //card1
  String cardOneIcePath;
  String cardOneIconIcePath;
  String cardOneDdsName;
  String cardOneIconDdsName;
  String cardOneIconWebPath;
  String cardOneSquareIconWebPath;
  String cardOneReplacedIceMd5;
  String cardOneReplacedIconIceMd5;
  //extra
  String replacedImagePath;
  bool isReplaced;

  factory LineStrikeCard.fromJson(Map<String, dynamic> json) => _$LineStrikeCardFromJson(json);
  Map<String, dynamic> toJson() => _$LineStrikeCardToJson(this);
}
