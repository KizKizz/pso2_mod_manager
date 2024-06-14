import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<void> saveModdedItemListToJson() async {
  //Save to json
  moddedItemsList.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await File(modManModsListJsonPath).writeAsString(encoder.convert(moddedItemsList));
}

Future<void> saveSetListToJson() async {
  //Save to json
  modSetList.map((modSet) => modSet.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await File(modManModSetsJsonPath).writeAsString(encoder.convert(modSetList));
}

Future<void> saveVitalGaugesInfoToJson(List<VitalGaugeBackground> vgList) async {
  //Save to json
  vgList.map((vg) => vg.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  await File(modManVitalGaugeJsonPath).writeAsString(encoder.convert(vgList));
}