import 'package:json_annotation/json_annotation.dart';

part 'profile_class.g.dart';

@JsonSerializable()
class ModManProfile {
  ModManProfile(this.profileName, this.pso2binPath, this.mainModManPath, this.modListSettingsPath, this.modSetSettingPath, this.isDefault);

  String profileName;
  String pso2binPath;
  String mainModManPath;
  String modListSettingsPath;
  String modSetSettingPath;
  bool isDefault;

  factory ModManProfile.fromJson(Map<String, dynamic> json) => _$ModManProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ModManProfileToJson(this);
}
