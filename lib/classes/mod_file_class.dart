import 'package:json_annotation/json_annotation.dart';

part 'mod_file_class.g.dart';

@JsonSerializable()
class ModFile {
  ModFile(this.modFileName, this.submodName, this.modName, this.itemName, this.category, this.md5, this.ogMd5, this.location, this.ogLocations, this.bkLocations, this.applyStatus, this.applyDate,
      this.position, this.isFavorite, this.isSet, this.isNew);
  String modFileName;
  String submodName;
  String modName;
  String itemName;
  String category;
  String md5;
  String ogMd5;
  String location;
  List<String> ogLocations;
  List<String> bkLocations;
  bool applyStatus;
  DateTime applyDate;
  int position;
  bool isFavorite;
  bool isSet;
  bool isNew;

  factory ModFile.fromJson(Map<String, dynamic> json) => _$ModFileFromJson(json);
  Map<String, dynamic> toJson() => _$ModFileToJson(this);
}
