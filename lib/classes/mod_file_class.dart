import 'package:json_annotation/json_annotation.dart';

part 'mod_file_class.g.dart';
@JsonSerializable()
class ModFile {
  ModFile(this.name, this.modName, this.itemName, this.md5, this.location, this.ogLocation, this.bkLocation, this.applyDate, this.applyStatus, this.isNew, this.isFavorite);
  String name;
  String modName;
  String itemName;
  String md5;
  String location;
  String ogLocation;
  String bkLocation;
  DateTime applyDate;
  bool applyStatus;
  bool isNew;
  bool isFavorite;

  factory ModFile.fromJson(Map<String, dynamic> json) => _$ModFileFromJson(json);
  Map<String, dynamic> toJson() => _$ModFileToJson(this);
}
