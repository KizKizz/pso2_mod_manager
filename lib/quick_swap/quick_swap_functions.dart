import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

Future<List<ItemData>> quickSwapItemsFetch() async {
  List<ItemData> structureFromJson = [];

  // Load list from json
  String dataFromJson = await File(mainQuickSwapListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      structureFromJson.add(ItemData.fromJson(item));
    }
  }

  return structureFromJson;
}