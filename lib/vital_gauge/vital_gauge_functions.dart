import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

List<VitalGaugeBackground> vitalGaugeBackgroundFetch() {
  // Load saved data from json
  List<VitalGaugeBackground> vitalGaugesDataFromJson = [];
  bool refetchData = false;
  if (File(mainVitalGaugeListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(mainVitalGaugeListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      vitalGaugesDataFromJson.add(VitalGaugeBackground.fromJson(type));
      if (!refetchData && (!File(vitalGaugesDataFromJson.last.icePath).existsSync())) {
        refetchData = true;
      }
    }
  }
  // Load from player data
  final vitalGaugeInfoFromPlayerData = pItemData.where((e) => e.itemCategories.contains('Vital Gauge'));
  List<VitalGaugeBackground> vitalGaugeData = [];
  if (refetchData || vitalGaugeInfoFromPlayerData.length > vitalGaugesDataFromJson.length) {
    for (var info in vitalGaugeInfoFromPlayerData) {
      if (vitalGaugesDataFromJson.indexWhere((e) => e.pngPath == info.iconImagePath) == -1) {
        String ddsName = p.basenameWithoutExtension(info.infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
        String iceName = info.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last;
        String icePath = pso2binDirPath + p.separator + oItemData.firstWhere((e) => e.path.contains(iceName)).path.replaceAll('\\', p.separator);
        String pngPath = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main${info.iconImagePath.replaceAll('\\', p.separator)}';
        vitalGaugeData.add(VitalGaugeBackground(icePath, iceName, ddsName, pngPath, '', '', '', '', false));
      }
    }
  }

  if (vitalGaugeData.isNotEmpty) {
    vitalGaugesDataFromJson.addAll(vitalGaugeData);
  }

  vitalGaugesDataFromJson.sort((a, b) => a.ddsName.compareTo(b.ddsName));
  saveMasterVitalGaugeToJson(vitalGaugesDataFromJson);

  return vitalGaugesDataFromJson;
}

List<File> customVitalGaugeImagesFetch() {
  return Directory(vitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
}

void saveMasterVitalGaugeToJson(List<VitalGaugeBackground> vitalGaugeBackgroundList) {
  //Save to json
  vitalGaugeBackgroundList.map((vg) => vg.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainVitalGaugeListJsonPath).writeAsStringSync(encoder.convert(vitalGaugeBackgroundList));
}
