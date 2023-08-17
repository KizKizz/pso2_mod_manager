import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
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
                            isBoundaryEdited = true;
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  curLangText!.uiBoundaryRadiusModification,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              if (context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first != curLangText!.uiError && context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first != curLangText!.uiSuccess)
                              const CircularProgressIndicator(),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(context.watch<StateProvider>().boundaryEditProgressStatus),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: ElevatedButton(
                                    onPressed: context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first == curLangText!.uiError ||
                                            context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first == curLangText!.uiSuccess
                                        ? () {
                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                              element.deleteSync(recursive: true);
                                            });
                                            isBoundaryEdited = false;
                                            csvInfosFromSheets.clear();
                                            Navigator.pop(context, true);
                                          }
                                        : null,
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
  Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiIndexingFiles);
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

    if (itemCategory == defaultCateforyDirs[16] || itemCategory == defaultCateforyDirs[1] || itemName.contains('[Fu]')) {
      Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('$itemCategory${curLangText!.uispaceFoundExcl}');
      await Future.delayed(const Duration(milliseconds: 100));
      List<ModFile> matchingFiles = submod.modFiles.where((element) => element.modFileName == infoLine.split(',')[6] || element.modFileName == infoLine.split(',')[7]).toList();
      if (matchingFiles.isNotEmpty) {
        Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiMatchingFilesFound);
        await Future.delayed(const Duration(milliseconds: 100));
        for (var modFile in matchingFiles) {
          Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiExtractingFiles);
          await Future.delayed(const Duration(milliseconds: 100));
          List<File> extractedGroup1Files = [];
          List<File> extractedGroup2Files = [];
          //extract files
          await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [modFile.location]);
          String extractedGroup1Path = Uri.file('$modManAddModsTempDirPath/${modFile.modFileName}_ext/group1').toFilePath();
          if (Directory(extractedGroup1Path).existsSync()) {
            extractedGroup1Files = Directory(extractedGroup1Path).listSync(recursive: true).whereType<File>().toList();
          }
          String extractedGroup2PathF = Uri.file('$modManAddModsTempDirPath/${modFile.modFileName}_ext/group2').toFilePath();
          if (Directory(extractedGroup2PathF).existsSync()) {
            extractedGroup2Files = Directory(extractedGroup2PathF).listSync(recursive: true).whereType<File>().toList();
          }
          //Get aqp files
          List<File> aqpFiles = [];
          aqpFiles.addAll(extractedGroup1Files.where((element) => p.extension(element.path) == '.aqp'));
          aqpFiles.addAll(extractedGroup2Files.where((element) => p.extension(element.path) == '.aqp'));
          if (aqpFiles.isNotEmpty) {
            for (var aqpFile in aqpFiles) {
              Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiReadingspace}${p.basename(aqpFile.path)}');
              await Future.delayed(const Duration(milliseconds: 100));
              Uint8List aqpBytes = await File(aqpFile.path).readAsBytes();
              if (aqpBytes[233] == 0 && aqpBytes[234] == 0 && aqpBytes[235] == 0) {
                Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiEditingBoundaryRadiusValue);
                await Future.delayed(const Duration(milliseconds: 100));
                //-10
                aqpBytes[236] = 0;
                aqpBytes[237] = 0;
                aqpBytes[238] = 32;
                aqpBytes[239] = 193;
                aqpFile.writeAsBytesSync(Uint8List.fromList(aqpBytes));
                Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiPackingFiles);
                await Future.delayed(const Duration(milliseconds: 100));
                //pack
                await Process.run('$modManZamboniExePath -c -pack -outdir "${p.dirname(aqpFile.parent.path)}"', [Uri.file(p.dirname(aqpFile.parent.path)).toFilePath()]);
                Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiReplacingModFiles);
                await Future.delayed(const Duration(milliseconds: 100));
                await File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).rename(modFile.location);
                if (modFile.modFileName == matchingFiles.last.modFileName) {
                  Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(modFile.applyStatus ? '${curLangText!.uiSuccess}\n${curLangText!.uiAllDone}}\n${curLangText!.uiMakeSureToReapplyThisMod}' : '${curLangText!.uiSuccess}\n${curLangText!.uiAllDone} ');
                  await Future.delayed(const Duration(milliseconds: 100));
                }
              } else {
                Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiBoundaryRadiusValueNotFound}');
                await Future.delayed(const Duration(milliseconds: 100));
              }
            }
          } else {
            Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoAqpFileFound}');
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      } else {
        Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}');
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } else {
      Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiOnlyBasewearsAndSetwearsCanBeModified}');
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  isBoundaryEdited = true;
}
