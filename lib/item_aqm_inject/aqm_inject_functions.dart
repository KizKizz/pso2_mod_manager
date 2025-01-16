import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';

Future<List<AqmInjectedItem>> aqmInjectedItemsFetch() async {
  List<AqmInjectedItem> structureFromJson = [];

  //Load list from json
  String dataFromJson = await File(mainAqmInjectListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      structureFromJson.add(AqmInjectedItem.fromJson(item));
    }
  }

  return structureFromJson;
}