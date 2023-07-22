import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_la_homepage.dart';
import 'package:pso2_mod_manager/state_provider.dart';

String unlistedItemCategoryF = '';

Future<List<File>> getCsvFiles(context, String categoryName, List<String> modFilePaths) async {
  List<File> csvFiles = [];
  String finalCategoryName = categoryName;
  if (!defaultCateforyDirs.contains(categoryName) || categoryName == 'Misc') {
    //load sheets
    if (csvInfosFromSheets.isEmpty) {
      csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
    }

    String csvItemInfo = '';
    for (var csv in csvInfosFromSheets) {
      for (var line in csv) {
        bool allFilesMatched = true;
        for (var path in modFilePaths) {
          if (!line.split(',').contains(p.basename(path))) {
            allFilesMatched = false;
          }
        }
        if (allFilesMatched) {
          csvItemInfo = line;
          break;
        }
      }
    }
    //unload sheets
    if (csvInfosFromSheets.isNotEmpty) {
      csvInfosFromSheets.clear();
    }
    if (csvItemInfo.isNotEmpty) {
      finalCategoryName = csvItemInfo.split(',').first;
      unlistedItemCategoryF = finalCategoryName;
    } else {
      finalCategoryName = await modsSwapperCategorySelect(context);
      unlistedItemCategoryF = finalCategoryName;
      if (finalCategoryName.isEmpty) {
        Navigator.pop(context);
      }
    }
  }

  //get csv files
  if (finalCategoryName.isNotEmpty) {
    int categoryIndex = defaultCateforyDirs.indexOf(finalCategoryName);
    for (var csvFileName in csvFileList[categoryIndex]) {
      final csvFilesFromPath = Directory(modManRefSheetsDirPath).listSync(recursive: true).whereType<File>().where((element) => p.basename(element.path) == csvFileName);
      for (var file in csvFilesFromPath) {
        csvFiles.add(file);
      }
    }
  }
  return csvFiles;
}

Future<String> modsSwapperCategorySelect(context) async {
  List<String> swapCategoriesF = [
    'Accessories',
    'Basewears',
    'Body Paints',
    'Cast Arm Parts',
    'Cast Body Parts',
    'Cast Leg Parts',
    'Emotes',
    'Eyes',
    'Face Paints',
    'Hairs',
    'Innerwears',
    'Motions',
    'Outerwears',
    'Setwears'
  ];
  String? selectedCategoryF;

  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiItemCategoryNotFound, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: SizedBox(
                  width: 200,
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    hint: Text(curLangText!.uiSelectACategory),
                    buttonStyleData: ButtonStyleData(
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Theme.of(context).hintColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: windowsHeight * 0.5,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                    iconStyleData: const IconStyleData(iconSize: 15),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                    ),
                    isDense: true,
                    items: swapCategoriesF
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        //fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        //color: Colors.white,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            )))
                        .toList(),
                    value: selectedCategoryF,
                    onChanged: (value) async {
                      selectedCategoryF = value.toString();

                      setState(() {});
                    },
                  )),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: selectedCategoryF == null
                          ? null
                          : () {
                              Navigator.pop(context, selectedCategoryF);
                            },
                      child: Text(curLangText!.uiNext))
                ]);
          }));
}

Future<bool> sheetListFetchFromFiles(context, String itemCategory, List<String> modFilePaths) async {
  List<List<String>> csvList = [];
  final csvFiles = await getCsvFiles(context, itemCategory, modFilePaths);

  for (var file in csvFiles) {
    csvList.add([]);
    //csvList.last.add(p.basename(file.path));
    await file.openRead().transform(utf8.decoder).transform(const LineSplitter()).skip(1).forEach((line) {
      line = line.replaceAll('"', '');
      int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(file.path)).isNotEmpty);
      if (categoryIndex != -1) {
        if (p.basename(file.path) == 'SubstituteMotionGlide.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Glide Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionJump.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Jump Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionLanding.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Landing Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionPhotonDash.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Dash Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionRun.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Run Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionStandby.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Standby Motion,$line';
        } else if (p.basename(file.path) == 'SubstituteMotionSwim.csv') {
          line = '${defaultCateforyDirs[categoryIndex]},Swim Motion,$line';
        } else {
          line = '${defaultCateforyDirs[categoryIndex]},$line';
        }
      }
      csvList.last.add(line);
    });
  }

  for (var line in csvList) {
    for (var item in line) {
      if (item.split(',').first == defaultCateforyDirs[0]) {
        csvAccData.add(CsvAccessoryIceFile.fromList(item.split(',')));
      } else if (item.split(',').first == defaultCateforyDirs[7]) {
        if (item.split(',').length == 14) {
          csvEmotesData.add(CsvEmoteIceFile.fromListNgs(item.split(',')));
        } else if (item.split(',').length == 19) {
          csvEmotesData.add(CsvEmoteIceFile.fromListPso2(item.split(',')));
        }
      } else if (item.split(',').first == defaultCateforyDirs[14]) {
        if (item.split(',').length == 9) {
          csvEmotesData.add(CsvEmoteIceFile.fromListMotion(item.split(',')));
        }
      } else if (item.split(',').first == defaultCateforyDirs[10]) {
        csvData.add(CsvIceFile.fromListHairs(item.split(',')));
      } else {
        csvData.add(CsvIceFile.fromList(item.split(',')));
      }
    }
  }
  return true;
}

Future<List<CsvIceFile>> getSwapToCsvList(List<CsvIceFile> cvsDataInput, String swapFromItemCategory) async {
  String categorySymbol = '';
  // if (swapFromItem.category == 'Basewears') {
  //   categorySymbol = '[Ba]';
  // } else if (swapFromItem.category == 'Setwears') {
  //   categorySymbol = '[Se]';
  // } else
  if (swapFromItemCategory == 'Innerwears') {
    categorySymbol = '[In]';
  }
  // if (swapFromItem.category == 'Setwears') {
  //   return cvsDataInput.where((element) => element.enName.contains(categorySymbol)).toList();
  // }
  if (swapFromItemCategory == 'Setwears' || swapFromItemCategory == 'Basewears') {
    return cvsDataInput.where((element) => element.enName.isNotEmpty && element.jpName.isNotEmpty && (element.enName.contains('[Ba]') || element.enName.contains('[Se]'))).toList();
  }
  if (categorySymbol.isNotEmpty) {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory && element.enName.contains(categorySymbol) && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  } else {
    return cvsDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
  }
}

Future<List<CsvAccessoryIceFile>> getAccSwapToCsvList(List<CsvAccessoryIceFile> cvsAccDataInput, String swapFromItemCategory) async {
  return cvsAccDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String swapFromItemCategory) async {
  return cvsEmoteDataInput.where((element) => element.category == swapFromItemCategory && element.enName.isNotEmpty && element.jpName.isNotEmpty).toList();
}

Future<List<CsvEmoteIceFile>> getEmotesToMotionsSwapToCsvList(List<CsvEmoteIceFile> cvsEmoteDataInput, String itemCategory) async {
  return cvsEmoteDataInput.where((element) => element.category == itemCategory).toList();
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
        future: csvData.isEmpty && csvAccData.isEmpty && csvEmotesData.isEmpty ? sheetListFetchFromFiles(context, widget.fromItem.category, widget.fromSubmod.getDistinctModFilePaths()) : null,
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
                      ? getSwapToCsvList(csvData, !defaultCateforyDirs.contains(widget.fromItem.category) || widget.fromItem.category == 'Misc' ? unlistedItemCategoryF : widget.fromItem.category)
                      : availableAccCsvData.isEmpty && csvAccData.isNotEmpty
                          ? getAccSwapToCsvList(
                              csvAccData, !defaultCateforyDirs.contains(widget.fromItem.category) || widget.fromItem.category == 'Misc' ? unlistedItemCategoryF : widget.fromItem.category)
                          : availableEmotesCsvData.isEmpty && csvEmotesData.isNotEmpty
                              ? getEmotesSwapToCsvList(
                                  csvEmotesData, !defaultCateforyDirs.contains(widget.fromItem.category) || widget.fromItem.category == 'Misc' ? unlistedItemCategoryF : widget.fromItem.category)
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
                            availableEmotesCsvData.sort(
                              (a, b) => a.jpName.compareTo(b.jpName),
                            );
                          } else {
                            availableEmotesCsvData.sort(
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
