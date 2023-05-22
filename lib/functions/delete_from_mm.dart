import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<String> deleteFilesFromModMan(List<String> filePaths) {
  String deletedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
  String todayDirPath = Uri.file('$modManDeletedItemsDirPath/$deletedDate').toFilePath();
  //create today dir to store deleted files
  Directory(todayDirPath).createSync(recursive: true);
  for (var path in filePaths) {
    String deletedPath = path.replaceFirst(modManModsDirPath, todayDirPath);
    File(path).copy(deletedPath).then((value) {
      // File(path).deleteSync();
      // if (Directory(p.basename(path)).listSync().isEmpty) {
      //   Directory(p.basename(path)).deleteSync();
      // }
    });
  }

  return filePaths;
}
