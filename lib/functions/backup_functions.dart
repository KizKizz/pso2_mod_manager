import 'dart:io';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

Future<void> localOriginalFilesBackup(List<ModFile> modFiles) async {
  for (var modFile in modFiles) {
    List<String> backupFilePaths = [];
    for (var originalFilePath in modFile.ogLocations) {
      String fileInBackupFolderPath = originalFilePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath);
      if (File(originalFilePath).existsSync() && !File(fileInBackupFolderPath).existsSync()) {
        final backupFile = await File(originalFilePath).copy(fileInBackupFolderPath);
        backupFilePaths.add(backupFile.path);
      } else if (File(fileInBackupFolderPath).existsSync()) {
        backupFilePaths.add(fileInBackupFolderPath);
      }
    }
    modFile.bkLocations = backupFilePaths;
  }
}
