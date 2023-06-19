
class CsvIceFile {
  CsvIceFile(this.category, this.jpName, this.enName, this.id, this.adjustedId, this.iconIceName, this.nqIceName, this.hqIceName, this.nqRpIceName, this.hqRpIceName, this.nqLiIceName,
      this.hqLiIceName, this.soundIceName, this.castSoundIceName, this.maIceName, this.maExIceName, this.handTextureIceName, this.hqhandTextureIceName);
  CsvIceFile.fromList(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          items[3].isNotEmpty ? int.parse(items[3]) : -1,
          items[4].isNotEmpty ? int.parse(items[4]) : -1,
          items[5],
          items[6],
          items[7],
          items[8],
          items[9],
          items[10],
          items[11],
          items[12],
          items[13],
          items[14],
          items[15],
          items[16],
          items[17],
        );
  CsvIceFile.fromListHairs(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          items[3].isNotEmpty ? int.parse(items[3]) : -1,
          items[4].isNotEmpty ? int.parse(items[4]) : -1,
          items[5],
          items[8],
          items[9],
          items[10],
          items[11],
          items[12],
          items[13],
          items[14],
          items[15],
          items[16],
          items[17],
          items[18],
          items[19],
        );
  //np = normal quality, hq = high quality, li = linked inner, ma = material animation
  String category;
  String jpName;
  String enName;
  int id;
  int adjustedId;
  String iconIceName;
  String nqIceName;
  String hqIceName;
  String nqRpIceName;
  String hqRpIceName;
  String nqLiIceName;
  String hqLiIceName;
  String soundIceName;
  String castSoundIceName;
  String maIceName;
  String maExIceName;
  String handTextureIceName;
  String hqhandTextureIceName;

  List<String> getDetailedList() {
    return [
      'Category: $category',
      'JP Name: $jpName',
      'EN Name: $enName',
      'ID: $id',
      'Ajusted ID: $adjustedId',
      'Icon Ice: $iconIceName',
      'Normal Quality Ice: $nqIceName',
      'High Quality Ice: $hqIceName',
      'Normal Quality RP Ice: $nqRpIceName',
      'High Quality RP Ice: $hqRpIceName',
      'Normal Quality Linked Inner Ice: $nqLiIceName',
      'High Quality Linked Inner Ice: $hqLiIceName',
      'Sound Ice: $soundIceName',
      'Cast Sound Ice: $castSoundIceName',
      'Material Animation Ice: $maIceName',
      'Material Animation EX Ice: $maExIceName',
      'Normal Quality Hand Texture Ice: $handTextureIceName',
      'High Quality Hand Texture Ice: $hqhandTextureIceName'
    ];
  }
}

class CsvAccessoryIceFile {
  CsvAccessoryIceFile(this.category, this.jpName, this.enName, this.id, this.iconIceName, this.nqIceName, this.hqIceName);
  CsvAccessoryIceFile.fromList(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          int.tryParse(items[3]) == null ? -1 : int.parse(items[3]),
          items[4],
          items[5],
          items[6],
        );
  //np = normal quality, hq = high quality
  String category;
  String jpName;
  String enName;
  int id;
  String iconIceName;
  String nqIceName;
  String hqIceName;

  List<String> getDetailedList() {
    return [
      'Category: $category',
      'JP Name: $jpName',
      'EN Name: $enName',
      'ID: $id',
      'Icon Ice: $iconIceName',
      'Normal Quality Ice: $nqIceName',
      'High Quality Ice: $hqIceName'
    ];
  }
}


class CsvEmoteIceFile {
  CsvEmoteIceFile(this.category, this.jpName, this.enName, this.command, this.pso2HashIceName, this.rbHumanHashIceName, this.rbCastMaleHashIceName, this.rbCastFemaleHashIceName, this.rbFigHashIceName, this.pso2VfxHashIceName, this.rbVfxHashIceName,
      this.gender);
  CsvEmoteIceFile.fromList(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          items[3],
          items[5],
          items[7],
          items[9],
          items[11],
          items[13],
          items[15],
          items[17],
          items[18]
        );
  CsvEmoteIceFile.fromListNgs(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          items[3],
          '',
          items[5],
          items[7],
          items[9],
          items[11],
          '',
          items[13],
          items[14]
        );
  CsvEmoteIceFile.fromListMotion(List<String> items)
      : this(
          items[0],
          items[1],
          items[2],
          '',
          items[3],
          items[4],
          items[5],
          items[6],
          items[7],
          '',
          '',
          '',
        );
  //np = normal quality, hq = high quality, li = linked inner, ma = material animation
  String category;
  String jpName;
  String enName;
  String command;
  String pso2HashIceName;
  String rbHumanHashIceName;
  String rbCastMaleHashIceName;
  String rbCastFemaleHashIceName;
  String rbFigHashIceName;
  String pso2VfxHashIceName;
  String rbVfxHashIceName;
  String gender;

  List<String> getDetailedList() {
    return [
      'Category: $category',
      'JP Name: $jpName',
      'EN Name: $enName',
      'PSO2 Hash Ice: $pso2HashIceName',
      'Reboot Human Hash Ice: $rbHumanHashIceName',
      'Reboot Cast Male Hash Ice: $rbCastMaleHashIceName',
      'Reboot Cast Female Hash Ice: $rbCastFemaleHashIceName',
      'Reboot Fig Hash Ice: $rbFigHashIceName',
      'PSO2 VFX Hash Ice: $pso2VfxHashIceName',
      'Reboot VFX Hash Ice: $rbVfxHashIceName',
      'Gender: $gender'
    ];
  }
}