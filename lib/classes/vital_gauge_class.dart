import 'package:json_annotation/json_annotation.dart';

part 'vital_gauge_class.g.dart';

@JsonSerializable()
class VitalGaugeBackground {
  VitalGaugeBackground(this.icePath, this.iceName, this.ddsName, this.ogMd5, this.replacedImagePath, this.replacedImageName, this.replacedMd5, this.isReplaced);

  String icePath;
  String iceName;
  String ddsName;
  String ogMd5;
  String replacedImagePath;
  String replacedImageName;
  String replacedMd5;
  bool isReplaced;

  factory VitalGaugeBackground.fromJson(Map<String, dynamic> json) => _$VitalGaugeBackgroundFromJson(json);
  Map<String, dynamic> toJson() => _$VitalGaugeBackgroundToJson(this);
}
