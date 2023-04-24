//Indexing reboots files
import 'dart:io';

import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<String>> dataFilesFetch() async {
  List<String> filePaths = [];
  final allDataFiles = Directory(Uri.file('$modManPso2binPath/data').toFilePath()).listSync(recursive: false).whereType<File>();
  for (var file in allDataFiles) {
    filePaths.add(file.path);
  }

  return filePaths;
}
