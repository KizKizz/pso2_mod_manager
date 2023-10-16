import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/backup_mods.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';

//return true if successfully copied
Future<bool> modFileApply(ModFile modFile) async {
  //retore dublicate
  //await modFileRestore(moddedItemsList, modFile);
  //modFile = await modFileBackup(modFile);
  //replace files in game data
  for (var ogPath in modFile.ogLocations) {
    if (ogPath.contains('win32_na') || ogPath.contains('win32reboot_na')) {
      modFile = await modFileBackup(modFile);
    }
    File returnedFile = File('');
    try {
      returnedFile = await File(modFile.location).copy(ogPath);
    } catch (e) {
      if (File(ogPath).existsSync()) {
        await File(ogPath).delete();
      }
      returnedFile = await File(modFile.location).copy(ogPath);
    }
    if (returnedFile.path.isEmpty || returnedFile.path != ogPath) {
      return false;
    }
    String newOGMD5 = await getFileHash(ogPath);
    if (!modFile.ogMd5s.contains(newOGMD5)) {
      modFile.ogMd5s.add(newOGMD5);
    }
  }
  modFile.md5 = await getFileHash(modFile.location);
  saveModdedItemListToJson();

  return true;
}
