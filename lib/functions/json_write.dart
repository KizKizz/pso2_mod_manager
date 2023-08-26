import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

void saveModdedItemListToJson() {
  //Save to json
  moddedItemsList.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModsListJsonPath).writeAsStringSync(encoder.convert(moddedItemsList));
}

void saveSetListToJson() {
  //Save to json
  modSetList.map((modSet) => modSet.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModSetsJsonPath).writeAsStringSync(encoder.convert(modSetList));
}

void saveVitalGaugesInfoToJson(List<VitalGaugeBackground> vgList) {
  //Save to json
  vgList.map((vg) => vg.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManVitalGaugeJsonPath).writeAsStringSync(encoder.convert(vgList));
}