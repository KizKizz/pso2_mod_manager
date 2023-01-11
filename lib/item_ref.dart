// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';

import 'main.dart';
import 'package:path/path.dart' as p;

String refSheetsDirPath = '${Directory.current.path}${s}ItemRefSheets$s';
String ngsRefSheetsDirPath = '${refSheetsDirPath}Player${s}NGS$s';
List<List<String>> ngsRefSheetsList = [];

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
