//Indexing reboots files
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<String>> dataFilesFetch() async {
  List<String> rebootPaths = [];
  List<String> rebootDataDirs = ['win32reboot', 'win32reboot_na'];
  for (var dir in rebootDataDirs) {
    final subDirs = Directory(Uri.file('$modManPso2binPath/data/$dir').toFilePath()).listSync(recursive: false).whereType<Directory>();
    for (var subDir in subDirs) {
      rebootPaths.add(Uri.file('$dir/${XFile(subDir.path).name}').toFilePath());
    }
  }

  return rebootPaths;
}
