import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/line_strike_board_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_sleeve_class.dart';
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

void saveLineStrikeSleeveInfoToJson(List<LineStrikeSleeve> sleeveList) {
  //Save to json
  sleeveList.map((sleeve) => sleeve.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManLineStrikeSleeveJsonPath).writeAsStringSync(encoder.convert(sleeveList));
}

void saveLineStrikeBoardInfoToJson(List<LineStrikeBoard> boardList) {
  //Save to json
  boardList.map((board) => board.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManLineStrikeBoardJsonPath).writeAsStringSync(encoder.convert(boardList));
}