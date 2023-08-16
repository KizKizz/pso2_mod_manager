import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool isBoundaryEdited = false;

void modsBoundaryEditHomePage(context, SubMod submod) {
  Future csvLoader = itemCsvFetcher(modManRefSheetsDirPath);
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: FutureBuilder(
                  future: csvLoader,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 250,
                        height: 250,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                curLangText!.uiFetchingItemInfo,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                        return SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiErrorWhenFetchingItemInfo,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      } else {
                        csvInfosFromSheets = snapshot.data;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!isBoundaryEdited) {
                            boundaryEdit(context, submod);
                          }
                        });
                        return ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 250, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Boundary Radius Edit',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              const CircularProgressIndicator(),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(context.watch<StateProvider>().boundaryEditProgressStatus),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                    onPressed: context.watch<StateProvider>().boundaryEditProgressStatus.split(',').first != curLangText!.uiError
                                        ? null
                                        : () {
                                            isBoundaryEdited = false;
                                            csvInfosFromSheets.clear();
                                            Navigator.pop(context, true);
                                          },
                                    child: Text(curLangText!.uiReturn)),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  }));
        });
      });
}

void boundaryEdit(context, SubMod submod) async {
  List<String> charsToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('Indexing files');
  //fetch csv
  // if (csvInfosFromSheets.isEmpty) {
  //   csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  // }
  List<String> csvFileInfos = [];
  for (var modFile in submod.modFiles) {
    File iceFile = File(modFile.location);
    //look in csv infos
    if (csvFileInfos.where((element) => element.contains(p.basename(iceFile.path))).isEmpty) {
      for (var csvFile in csvInfosFromSheets) {
        final csv = csvFile.firstWhere(
          (line) => line.contains(p.basenameWithoutExtension(iceFile.path)) && !csvFileInfos.contains(line) && line.split(',')[1].isNotEmpty,
          orElse: () => '',
        );
        if (csv.isNotEmpty) {
          csvFileInfos.add(csv);
        }
      }
    }
  }

  for (var infoLine in csvFileInfos) {
    final infos = infoLine.split(',');
    String itemName = '';
    curActiveLang == 'JP' ? itemName = infos[1] : itemName = infos[2];
    for (var char in charsToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    String itemCategory = infos[0];
    if (itemName.contains('[Se]')) {
      itemCategory = defaultCateforyDirs[16];
    }

    if (itemCategory == defaultCateforyDirs[16] || itemCategory == defaultCateforyDirs[1]) {
      Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('$itemCategory found!');
      await Future.delayed(const Duration(milliseconds: 100));

    } else {
      isBoundaryEdited = true;
      Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}, only Basewears and Setwears are editable');
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  isBoundaryEdited = true;
}
