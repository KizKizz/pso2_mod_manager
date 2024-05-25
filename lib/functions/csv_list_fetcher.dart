import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<CsvAccessoryIceFile> csvAccessoryIndexFiles = [];
List<CsvEmoteIceFile> csvEmoteIndexFiles = [];
List<CsvIceFile> csvGeneralIndexFiles = [];

// Future<List<String>> itemCsvFetcher(String refSheetsPath) async {
//   List<String> csvReturnList = [];
//   final csvFilesFromPath = Directory(refSheetsPath).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.csv');
//   for (var csvFile in csvFilesFromPath) {
//     await csvFile.openRead().transform(utf8.decoder).transform(const LineSplitter()).skip(1).forEach((line) {
//       int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(csvFile.path)).isNotEmpty);
//       if (categoryIndex != -1) {
//         line = '${defaultCateforyDirs[categoryIndex]},$line';
//       } else {
//         line = curActiveLang == 'JP' ? '未知,$line' :'Unknown,$line';
//       }
//       csvReturnList.add(line);
//     });
//   }
//   return csvReturnList;
// }

// Future<List<List<String>>> itemCsvFetcher(String refSheetsPath) async {
//   List<List<String>> csvReturnList = List.generate(defaultCategoryDirs.length, (index) => []);
//   final csvFilesFromPath = Directory(refSheetsPath).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.csv');
//   for (var csvFile in csvFilesFromPath) {
//     await csvFile.openRead().transform(utf8.decoder).transform(const LineSplitter()).skip(1).forEach((line) {
//       int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(csvFile.path)).isNotEmpty);
//       if (categoryIndex != -1) {
//         line = '${defaultCategoryDirs[categoryIndex]},$line';
//         csvReturnList[categoryIndex].add(line);
//       } 
//       // else {
//       //   line = curActiveLang == 'JP' ? '未知,$line' :'Unknown,$line';
//       // }
      
//     });
//   }
//   return csvReturnList;
// }

Future<List<String>> modFileCsvFetcher(List<String> itemCsvList, List<File> iceFiles) async {
  List<String> csvReturnList = [];
  for (var iceFile in iceFiles) {
    for (var csvString in itemCsvList) {
      if (csvReturnList.where((e) => e.contains(p.basename(iceFile.path))).isEmpty && csvString.contains(p.basename(iceFile.path))) {
        csvReturnList.add(csvString);
      }
    }
  }

  return csvReturnList;
}
