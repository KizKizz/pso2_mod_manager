import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

void saveModdedItemListToJson() {
  //Save to json
  moddedItemsList.map((cateType) => cateType.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(modManModsListJsonPath).writeAsStringSync(encoder.convert(moddedItemsList));
}
