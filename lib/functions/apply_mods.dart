import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/backup_mods.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/mod_file_restore.dart';
import 'package:pso2_mod_manager/global_variables.dart';

Future<ModFile> modFileApplier(ModFile modFile) async {
  //retore dublicate
  modFileRestore(moddedItemsList, modFile);
  modFile = await modFileBackup(modFile);
  modFile.md5 = await getFileHash(modFile.location);
  //replace files in game data
  for (var ogPath in modFile.ogLocations) {
    File(modFile.location).copySync(ogPath);
  }
  
  modFile.applyStatus = true;
  modFile.applyDate = DateTime.now();
  return modFile;
}
