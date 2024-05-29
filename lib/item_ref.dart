// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';

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

// Future<void> downloadNewRefSheets(context, File refSheetListFile) async {
//   final dio = Dio();
//   final fileList = refSheetListFile.readAsLinesSync();
//   for (var path in fileList) {
//     String localPath = path.replaceAll(Uri.file('/').toFilePath(), '/');
//     String githubPath = 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/ItemRefSheets$localPath';

//     await dio.download(githubPath, Uri.file('$modManRefSheetsDirPath$path').toFilePath());
//     Provider.of<StateProvider>(context, listen: false).refSheetsCountUp();
//   }
// }
