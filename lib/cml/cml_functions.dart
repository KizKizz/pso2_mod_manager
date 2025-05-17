import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

Future<List<Cml>> cmlItemsLoad() async {
  File jsonFile = File(mainCmlItemListJsonPath);
  if (!jsonFile.existsSync()) await jsonFile.create();

  List<Cml> cmlList = [];
  String dataFromJson = await jsonFile.readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      cmlList.add(Cml.fromJson(item));
    }
  }

  List<ItemData> newItemList = pItemData.where((e) => e.category == defaultCategoryDirs[1] && (e.getName().contains('[To]'))).toList();
  newItemList.removeWhere((e) => cmlList.indexWhere((i) => i.id == e.getItemID() && i.aId == e.getItemAdjustedID()) != -1);
  for (var data in newItemList) {
    cmlList.add(Cml().fromItemData(data));
  }

  return cmlList;
}

void saveMasterCmlItemListToJson() {
  //Save to json
  masterCMLItemList.map((item) => item.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainCmlItemListJsonPath).writeAsStringSync(encoder.convert(masterCMLItemList));
}