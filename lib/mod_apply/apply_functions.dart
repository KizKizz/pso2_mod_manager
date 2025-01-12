
import 'dart:io';

import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;
import 'package:pso2_mod_manager/shared_prefs.dart';

void modApplySequence() {}

Future<void> modLocalBackup(SubMod submod) async {
  for (var modFile in submod.modFiles) {
    // Look for path in oFileData
    final oData = oItemData.firstWhere((e) => p.basenameWithoutExtension(e.path) == modFile.modFileName, orElse: () => OfficialIceFile.empty());
    if (oData.path.isNotEmpty) {
      final oFile = File(pso2binDirPath + p.separator + p.withoutExtension(oData.path));
      if (await oFile.exists()) {
        final backupFilePath = oFile.path.replaceFirst(pso2DataDirPath, backupDirPath);
        await Directory(p.dirname(backupFilePath)).create(recursive: true);
        await oFile.copy(backupFilePath);
      }
    }
    
    
    final file = File(modFile.);
    if (await file.exists()) {
      file.copy(newPath)
      }
  }
}

Future<void> modApply(Item item, Mod mod, SubMod submod) async {
  
}