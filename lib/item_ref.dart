// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

import 'package:path/path.dart' as p;

//String playerRefSheetsDirPath = '$refSheetsDirPath${s}Player';
List<List<String>> itemRefSheetsList = [];

Future<List<List<String>>> popSheetsList(String csvDirPath) async {
  List<FileSystemEntity> dirList = Directory(csvDirPath).listSync(recursive: true).toList();
  List<List<String>> csvList = [];
  for (var files in dirList) {
    if (p.extension(files.path) == '.csv') {
      csvList.add([]);
      csvList.last.add(XFile(files.path).name);
      await File(files.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) => csvList.last.add(line));
    }
  }

  return csvList;
}

Future<void> downloadNewRefSheets(context, List<String> filePaths) async {
  final dio = Dio();
  for (var path in filePaths) {
    String localPath = path.replaceAll(s, '/');
    String githubPath = localPath.replaceFirst(modManRefSheetsDirPath.replaceAll(s, '/'), 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/ItemRefSheets');

    await dio.download(githubPath, path);
    Provider.of<StateProvider>(context, listen: false).refSheetsCountUp();
  }
}
