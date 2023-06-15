import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_swappage.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<CsvIceFile> csvData = [];
String modManSwapperDirPath = Uri.file('${Directory.current.path}/swapper').toFilePath();
String modManSwapperFromItemDirPath = Uri.file('${Directory.current.path}/swapper/fromitem').toFilePath();
String modManSwapperToItemDirPath = Uri.file('${Directory.current.path}/swapper/toitem').toFilePath();
CsvIceFile? selectedFromCsvFile;
CsvIceFile? selectedToCsvFile;
List<CsvIceFile> availableItemsCsvData = [];
List<String> fromItemIds = [];
List<String> toItemIds = [];
String toItemName = '';
List<String> fromItemAvailableIces = [];
List<String> toItemAvailableIces = [];

List<File> getCsvFiles(String categoryName) {
  List<File> csvFiles = [];
  int categoryIndex = defaultCateforyDirs.indexOf(categoryName);
  for (var csvFileName in csvFileList[categoryIndex]) {
    final csvFilesFromPath = Directory(modManRefSheetsDirPath).listSync(recursive: true).whereType<File>().where((element) => p.basename(element.path) == csvFileName);
    for (var file in csvFilesFromPath) {
      csvFiles.add(file);
    }
  }
  return csvFiles;
}

Future<List<CsvIceFile>> sheetListFetchFromFiles(List<File> csvFiles) async {
  List<List<String>> csvList = [];
  List<CsvIceFile> csvIceFileList = [];
  for (var file in csvFiles) {
    csvList.add([]);
    //csvList.last.add(p.basename(file.path));
    await file.openRead().transform(utf8.decoder).transform(const LineSplitter()).skip(1).forEach((line) {
      int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(file.path)).isNotEmpty);
      if (categoryIndex != -1) {
        line = '${defaultCateforyDirs[categoryIndex]},$line';
      }
      csvList.last.add(line);
    });
  }

  for (var line in csvList) {
    for (var item in line) {
      csvIceFileList.add(CsvIceFile.fromList(item.split(',')));
    }
  }
  return csvIceFileList;
}

Future<List<CsvIceFile>> getSwapToCsvList(List<CsvIceFile> cvsDataInput, Item swapFromItem) async {
  String categorySymbol = '';
  if (swapFromItem.category == 'Basewears') {
    categorySymbol = '[Ba]';
  } else if (swapFromItem.category == 'Setwears') {
    categorySymbol = '[Se]';
  } else if (swapFromItem.category == 'Innerwears') {
    categorySymbol = '[In]';
  }
  return cvsDataInput.where((element) => element.category == swapFromItem.category && element.enName.contains(categorySymbol)).toList();
}

void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            contentPadding: const EdgeInsets.all(5),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: !Provider.of<StateProvider>(context, listen: false).modsSwapperSwitchToSwapPage
                    ? ModsSwapperDataLoader(fromItem: fromItem, fromSubmod: fromSubmod)
                    : ModsSwapperSwapPage(fromSubmod: fromSubmod)));
      });
}
