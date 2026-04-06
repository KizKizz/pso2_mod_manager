import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

const String itemDataGitHubVersionLink = 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/ref_sheets_version.json';

Future<(String, String)> itemDataVersionFetch() async {
  String version = '';
  String desc = '';

  itemDataInit();
  final response = await http.get(Uri.parse(itemDataGitHubVersionLink));
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    // Get version tag
    version = jsonData.entries.firstWhere((e) => e.key == 'version', orElse: () => const MapEntry('', '')).value;
    // Get patch notes
    desc = jsonData.entries.firstWhere((e) => e.key == 'description', orElse: () => const MapEntry('', '')).value.first;
  } else {
    throw Exception(appText.unableToGetItemDataVersionDataFromGitHub);
  }

  return (version, desc);
}

void itemDataInit() {
  File itemDataLocalVersionFile = File('${Directory.current.path}${p.separator}itemData${p.separator}itemDataLocalVersion.json');
  if (!itemDataLocalVersionFile.existsSync()) {
    itemDataLocalVersionFile.createSync(recursive: true);
  }
  if (itemDataLocalVersionFile.readAsStringSync().isEmpty) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    Map<String, dynamic> jsonData = {'version': '0'};
    itemDataLocalVersionFile.writeAsStringSync(encoder.convert(jsonData));
  }
}

Future<List<ItemData>> loadItemData() async {
  itemDataInit();
  List<ItemData> itemDataList = [];
  File playerItemDataFile = File('${Directory.current.path}${p.separator}itemData${p.separator}playerItemData.json');
  if (playerItemDataFile.existsSync()) {
    var data = jsonDecode(await playerItemDataFile.readAsString());
    for (var locale in data) {
      itemDataList.add(ItemData.fromJson(locale));
      await Future.delayed(const Duration(microseconds: 10));
    }
  }
  
  return itemDataList;
}
