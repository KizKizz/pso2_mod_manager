import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_swapper_homepage.dart';

Future<List<VitalGaugeBackground>> appliedVitalGaugesCheck(context) async {
  List<VitalGaugeBackground> reappliedList = [];

  //Load list from json
  List<VitalGaugeBackground> vitalGaugesData = [];
  if (File(modManVitalGaugeJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManVitalGaugeJsonPath).readAsStringSync());
    for (var type in jsonData) {
      vitalGaugesData.add(VitalGaugeBackground.fromJson(type));
    }
  }

  for (var vg in vitalGaugesData) {
    if (vg.isReplaced) {
      String curIceMd5 = await getFileHash(vg.icePath);
      if (curIceMd5 != vg.replacedMd5) {
        customVgBackgroundApply(context, vg.replacedImagePath, vg).then((value) {
          if (value) {
            reappliedList.add(vg);
          }
        });
      }
    }
  }
  return reappliedList;
}
