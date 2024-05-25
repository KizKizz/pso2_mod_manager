import 'package:pso2_mod_manager/loaders/language_loader.dart';

class CsvIceFile {
  CsvIceFile(this.category, this.jpName, this.enName, this.id, this.adjustedId, this.iconIceName, this.nqIceName, this.hqIceName, this.nqRpIceName, this.hqRpIceName, this.nqLiIceName,
      this.hqLiIceName, this.soundIceName, this.castSoundIceName, this.maIceName, this.maExIceName, this.handTextureIceName, this.hqhandTextureIceName, this.itemType, this.iconImageWebPath);
  CsvIceFile.fromList(List<String> items)
      : this(
            items[0],
            items[1].isEmpty ? curLangText!.uiUnknownItem : items[1],
            items[2].isEmpty ? curLangText!.uiUnknownItem : items[2],
            items[3].isNotEmpty
                ? int.tryParse(items[3]) != null
                    ? int.parse(items[3])
                    : -1
                : -1,
            items[4].isNotEmpty
                ? int.tryParse(items[4]) != null
                    ? int.parse(items[4])
                    : -1
                : -1,
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
            '',
            items.last);
  CsvIceFile.fromListHairs(List<String> items)
      : this(
            items[0],
            items[1].isEmpty ? curLangText!.uiUnknownItem : items[1],
            items[2].isEmpty ? curLangText!.uiUnknownItem : items[2],
            items[3].isNotEmpty
                ? int.tryParse(items[3]) != null
                    ? int.parse(items[3])
                    : -1
                : -1,
            items[4].isNotEmpty
                ? int.tryParse(items[4]) != null
                    ? int.parse(items[4])
                    : -1
                : -1,
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
            '',
            items.last);

  CsvIceFile.fromListMags(List<String> items)
      : this(
            items[0],
            items[1].isEmpty ? curLangText!.uiUnknownItem : items[1],
            items[2].isEmpty ? curLangText!.uiUnknownItem : items[2],
            0,
            0,
            '',
            items[4].split(Uri.file('\\').toFilePath()).length <= 1 ? items[4] : '',
            items[4].split(Uri.file('\\').toFilePath()).length > 1 ? items[4].split(Uri.file('\\').toFilePath()).last : '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            items[4].split(Uri.file('\\').toFilePath()).length > 1 ? 'NGS' : 'PSO2',
            items.last);

  //np = normal quality, hq = high quality, li = linked inner, ma = material animation
  String category; //0
  String jpName; //1
  String enName; //2
  int id; //3
  int adjustedId; //4
  String iconIceName; //5
  String nqIceName; //6
  String hqIceName; //7
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
  String itemType;
  String iconImageWebPath;

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

  List<String> getDetailedListIceInfosOnly() {
    return [
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
  CsvAccessoryIceFile(this.category, this.jpName, this.enName, this.id, this.iconIceName, this.nqIceName, this.hqIceName, this.iconImageWebPath);
  CsvAccessoryIceFile.fromList(List<String> items)
      : this(items[0], items[1].isEmpty ? curLangText!.uiUnknownAccessory : items[1], items[2].isEmpty ? curLangText!.uiUnknownAccessory : items[2],
            int.tryParse(items[3]) == null ? -1 : int.parse(items[3]), items[4], items[5], items[6], items.last);
  //np = normal quality, hq = high quality
  String category;
  String jpName;
  String enName;
  int id;
  String iconIceName;
  String nqIceName;
  String hqIceName;
  String iconImageWebPath;

  List<String> getDetailedList() {
    return ['Category: $category', 'JP Name: $jpName', 'EN Name: $enName', 'ID: $id', 'Icon Ice: $iconIceName', 'Normal Quality Ice: $nqIceName', 'High Quality Ice: $hqIceName'];
  }

  List<String> getDetailedListIceInfosOnly() {
    return ['Normal Quality Ice: $nqIceName', 'High Quality Ice: $hqIceName'];
  }
}

class CsvEmoteIceFile {
  CsvEmoteIceFile(this.category, this.subCategory, this.jpName, this.enName, this.command, this.pso2HashIceName, this.rbHumanHashIceName, this.rbCastMaleHashIceName, this.rbCastFemaleHashIceName,
      this.rbFigHashIceName, this.pso2VfxHashIceName, this.rbVfxHashIceName, this.gender, this.iconImageWebPath);
  CsvEmoteIceFile.fromListPso2(List<String> items)
      : this(
            items[0],
            '',
            items[1].isEmpty ? curLangText!.uiUnknownEmote : items[1],
            items[2].isEmpty ? curLangText!.uiUnknownEmote : items[2],
            items[3],
            items[5].split('\\').last,
            items[7].split('\\').last,
            items[9].split('\\').last,
            items[11].split('\\').last,
            items[13].split('\\').last,
            items[15].split('\\').last,
            items[17].split('\\').last,
            items[18].isNotEmpty ? items[18] : 'Both',
            items[19]);
  CsvEmoteIceFile.fromListNgs(List<String> items)
      : this(items[0], '', items[1].isEmpty ? curLangText!.uiUnknownEmote : items[1], items[2].isEmpty ? curLangText!.uiUnknownEmote : items[2], items[3], '', items[5].split('\\').last,
            items[7].split('\\').last, items[9].split('\\').last, items[11].split('\\').last, '', items[13].split('\\').last, items[14].isNotEmpty ? items[14] : curLangText!.uiGenderBoth, items[15]);
  CsvEmoteIceFile.fromListMotion(List<String> items)
      : this(items[0], items[1].isEmpty ? curLangText!.uiUnknownMotion : items[1], items[2].isEmpty ? curLangText!.uiUnknownMotion : items[2], items[3], '', '', items[5].split('\\').last,
            items[6].split('\\').last, items[7].split('\\').last, items[8].split('\\').last, '', '', '', items[9]);
  //np = normal quality, hq = high quality, li = linked inner, ma = material animation
  String category;
  String subCategory;
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
  String iconImageWebPath;

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

  List<String> getDetailedListIceInfosOnly() {
    return [
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
