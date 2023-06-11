import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<String>> deleteModFileFromModMan(String iceFilePath, String submodPath, String modPath) async {
  List<String> deletedPaths = [];
  String deletedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
  String todayDirPath = Uri.file('$modManDeletedItemsDirPath/$deletedDate').toFilePath();
  //create today dir to store deleted files
  Directory(todayDirPath).createSync(recursive: true);
  final files = Directory(submodPath).listSync(recursive: true).whereType<File>().toList();
  final iceFiles = files.where((element) => p.extension(element.path) == '');

  if (iceFiles.length < 2) {
    for (var file in files) {
      String filePath = file.path;
      String deletedPath = filePath.replaceFirst(modManModsDirPath, todayDirPath);
      Directory(p.dirname(deletedPath)).createSync(recursive: true);
      File(filePath).copy(deletedPath).then((value) {
        File(filePath).deleteSync();
        if (Directory(submodPath).existsSync() && Directory(submodPath).listSync(recursive: true).whereType<File>().isEmpty) {
          Directory(submodPath).deleteSync(recursive: true);
        }
        if (Directory(modPath).existsSync() && Directory(modPath).listSync(recursive: true).whereType<File>().isEmpty) {
          Directory(modPath).deleteSync(recursive: true);
        }
      });
    }
  } else {
    File file = iceFiles.firstWhere((element) => element.path == iceFilePath);
    String icePath = file.path;
    String deletedPath = icePath.replaceFirst(modManModsDirPath, todayDirPath);
    Directory(p.dirname(deletedPath)).createSync(recursive: true);
    File(icePath).copy(deletedPath).then((value) {
      File(icePath).deleteSync();
      if (Directory(submodPath).existsSync() && Directory(submodPath).listSync(recursive: true).whereType<File>().isEmpty) {
        Directory(submodPath).deleteSync(recursive: true);
      }
      if (Directory(modPath).existsSync() && Directory(modPath).listSync(recursive: true).whereType<File>().isEmpty) {
        Directory(modPath).deleteSync(recursive: true);
      }
    });
  }

  return deletedPaths;
}

Future<List<String>> deleteModFromModMan(String submodPath, String modPath) async {
  List<String> deletedPaths = [];
  String deletedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
  String todayDirPath = Uri.file('$modManDeletedItemsDirPath/$deletedDate').toFilePath();
  //create today dir to store deleted files
  Directory(todayDirPath).createSync(recursive: true);
  final files = Directory(submodPath).listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    String filePath = file.path;
    String deletedPath = filePath.replaceFirst(modManModsDirPath, todayDirPath);
    Directory(p.dirname(deletedPath)).createSync(recursive: true);
    File(filePath).copy(deletedPath).then((value) {
      File(filePath).deleteSync();
      if (Directory(submodPath).existsSync() && Directory(submodPath).listSync(recursive: true).whereType<File>().isEmpty) {
        Directory(submodPath).deleteSync(recursive: true);
      }
      if (Directory(modPath).existsSync()&& Directory(modPath).listSync(recursive: true).whereType<File>().isEmpty) {
        Directory(modPath).deleteSync(recursive: true);
      }
    });
  }

  return deletedPaths;
}

Future<List<String>> deleteItemFromModMan(String itemPath) async {
  List<String> deletedPaths = [];
  String deletedDate = DateFormat('MM-dd-yyyy').format(DateTime.now());
  String todayDirPath = Uri.file('$modManDeletedItemsDirPath/$deletedDate').toFilePath();
  //create today dir to store deleted files
  Directory(todayDirPath).createSync(recursive: true);
  final files = Directory(itemPath).listSync(recursive: true).whereType<File>().toList();

  for (var file in files) {
    String modPath = file.path;
    String deletedPath = modPath.replaceFirst(modManModsDirPath, todayDirPath);
    Directory(p.dirname(deletedPath)).createSync(recursive: true);
    File(modPath).copy(deletedPath).then((value) async {
      File(modPath).deleteSync();
      if (Directory(itemPath).existsSync() && Directory(itemPath).listSync(recursive: true).whereType<File>().isEmpty) {
        Directory(itemPath).deleteSync(recursive: true);
      }
    });
  }

  return deletedPaths;
}
