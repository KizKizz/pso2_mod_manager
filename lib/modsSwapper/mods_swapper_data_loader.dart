import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_la_homepage.dart';

List<CsvIceFile> csvData = [];
List<CsvIceFile> availableItemsCsvData = [];
List<CsvAccessoryIceFile> csvAccData = [];
List<CsvAccessoryIceFile> availableAccCsvData = [];
List<CsvEmoteIceFile> csvEmotesData = [];
List<CsvEmoteIceFile> availableEmotesCsvData = [];

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

Future<bool> sheetListFetchFromFiles(List<File> csvFiles) async {
  List<List<String>> csvList = [];
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
      if (item.split(',').first == defaultCateforyDirs[0]) {
        csvAccData.add(CsvAccessoryIceFile.fromList(item.split(',')));
      } else if (item.split(',').first == defaultCateforyDirs[7]) {
        csvEmotesData.add(CsvEmoteIceFile.fromListNgs(item.split(',')));
      } else if (item.split(',').first == defaultCateforyDirs[14]) {
        csvEmotesData.add(CsvEmoteIceFile.fromListMotion(item.split(',')));
      } else if (item.split(',').first == defaultCateforyDirs[10]) {
        csvData.add(CsvIceFile.fromListHairs(item.split(',')));
      } else {
        csvData.add(CsvIceFile.fromList(item.split(',')));
      }
    }
  }
  return true;
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
  if (swapFromItem.category == 'Setwears') {
    return cvsDataInput.where((element) => element.enName.contains(categorySymbol)).toList();
  }
  if (categorySymbol.isNotEmpty) {
    return cvsDataInput.where((element) => element.category == swapFromItem.category && element.enName.contains(categorySymbol) && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  } else {
    return cvsDataInput.where((element) => element.category == swapFromItem.category && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  }
}

Future<List<CsvAccessoryIceFile>> getAccSwapToCsvList(List<CsvAccessoryIceFile> cvsAccDataInput, Item swapFromItem) async {
  return cvsAccDataInput.where((element) => element.category == swapFromItem.category && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesSwapToCsvList(List<CsvEmoteIceFile> cvsAccDataInput, Item swapFromItem) async {
  return csvEmotesData.where((element) => element.category == swapFromItem.category && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

class ModsSwapperDataLoader extends StatefulWidget {
  const ModsSwapperDataLoader({super.key, required this.fromItem, required this.fromSubmod});

  final Item fromItem;
  final SubMod fromSubmod;

  @override
  State<ModsSwapperDataLoader> createState() => _ModsSwapperDataLoaderState();
}

class _ModsSwapperDataLoaderState extends State<ModsSwapperDataLoader> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: csvData.isEmpty && csvAccData.isEmpty && csvEmotesData.isEmpty ? sheetListFetchFromFiles(getCsvFiles(widget.fromItem.category)) : null,
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curLangText!.uiLoadingItemRefSheetsData,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiErrorWhenLoadingItemRefSheets,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                    ElevatedButton(
                        child: Text(curLangText!.uiReturn),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiLoadingItemRefSheetsData,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              return FutureBuilder(
                  future: availableItemsCsvData.isEmpty && csvData.isNotEmpty
                      ? getSwapToCsvList(csvData, widget.fromItem)
                      : availableAccCsvData.isEmpty && csvAccData.isNotEmpty
                          ? getAccSwapToCsvList(csvAccData, widget.fromItem)
                          : availableEmotesCsvData.isEmpty && csvEmotesData.isNotEmpty
                              ? getEmotesSwapToCsvList(csvEmotesData, widget.fromItem)
                              : null,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting && (availableItemsCsvData.isEmpty || availableAccCsvData.isEmpty)) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              curLangText!.uiFetchingItemInfo,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const CircularProgressIndicator(),
                          ],
                        ),
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiErrorWhenFetchingItemInfo,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                              ),
                              ElevatedButton(
                                  child: Text(curLangText!.uiReturn),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiFetchingItemInfo,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        );
                      } else {
                        // swap To item list
                        if (csvAccData.isNotEmpty) {
                          availableAccCsvData = snapshot.data;
                          if (curActiveLang == 'JP') {
                            availableAccCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableAccCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperAccHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        } else if (csvEmotesData.isNotEmpty) {
                          availableEmotesCsvData = snapshot.data;
                          if (curActiveLang == 'JP') {
                            availableItemsCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableItemsCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperEmotesHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        } else {
                          availableItemsCsvData = snapshot.data;
                          if (curActiveLang == 'JP') {
                            availableItemsCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableItemsCsvData.sort(
                              (a, b) => a.enName.compareTo(b.enName),
                            );
                          }
                          return ModsSwapperHomePage(
                            fromItem: widget.fromItem,
                            fromSubmod: widget.fromSubmod,
                          );
                        }
                      }
                    }
                  });
            }
          }
        });
  }
}
