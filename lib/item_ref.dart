// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

import 'main.dart';
import 'package:path/path.dart' as p;

String refSheetsDirPath = '${Directory.current.path}${s}ItemRefSheets$s';
String ngsRefSheetsDirPath = '${refSheetsDirPath}Player${s}NGS$s';
Future<List<List<List<dynamic>>>> ngsRefSheetsListData = populateSheetsList(ngsRefSheetsDirPath);
var ngsRefSheetsList = [];

Future<List<List<List<dynamic>>>> populateSheetsList(String dirPath) async {
  List<FileSystemEntity> csvFiles = Directory(dirPath).listSync(recursive: true).toList();
  List<List<List<dynamic>>> sheetsList = [];
  for (var file in csvFiles) {
    //debugPrint(file.path);
    if (p.extension(file.path) == '.csv') {
      sheetsList.add([
        ['${file.path}\n']
      ]);
      sheetsList.add(await getDataFromCSV(file.path));
    }
  }
  return sheetsList;
}

Future<List<List<dynamic>>> getDataFromCSV(String filePath) async {
  final csvFile = File(filePath).openRead();
  return await csvFile
      .transform(utf8.decoder)
      .transform(
        const CsvToListConverter(),
      )
      .toList();
}
