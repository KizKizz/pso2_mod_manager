import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';

Future<void> modifiedIceFetch() async {
  if (!File(modifiedIceListFilePath).existsSync()) await File(modifiedIceListFilePath).create(recursive: true);
  modifiedIceList = await File(modifiedIceListFilePath).readAsLines();
}

void modifiedIceAdd(String iceName) {
  if (!modifiedIceList.contains(iceName) && iceName.isNotEmpty) {
    modifiedIceList.add(iceName);
    File(modifiedIceListFilePath).writeAsStringSync(modifiedIceList.join('\n'));
  }
}
