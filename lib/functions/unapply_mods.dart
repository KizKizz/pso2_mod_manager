import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<ModFile> modFileUnapply(ModFile modFile) async {
  for (var bkPath in modFile.bkLocations) {
    final ogPath = bkPath.replaceFirst(modManBackupsDirPath, Uri.file('$modManPso2binPath/data').toFilePath());
    //restore
    File(bkPath).copySync(ogPath);
    //remove bk
    await File(bkPath).delete(recursive: true);
  }
  modFile.ogMd5 = '';
  modFile.bkLocations.clear();
  modFile.ogLocations.clear();
  modFile.applyDate = DateTime(0);
  modFile.applyStatus = false;

  return modFile;
}
