import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/backup_mods.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';

Future<ModFile> modFileApply(ModFile modFile) async {
  //retore dublicate
  //await modFileRestore(moddedItemsList, modFile);
  //modFile = await modFileBackup(modFile);
  //replace files in game data
  for (var ogPath in modFile.ogLocations) {
    if (ogPath.contains('win32_na') || ogPath.contains('win32reboot_na')) {
      modFile = await modFileBackup(modFile);
    }
    File(modFile.location).copySync(ogPath);
    String newOGMD5 = await getFileHash(ogPath);
    if (!modFile.ogMd5s.contains(newOGMD5)) {
      modFile.ogMd5s.add(newOGMD5);
    }
  }
  modFile.md5 = await getFileHash(modFile.location);
  saveModdedItemListToJson();

  return modFile;
}
