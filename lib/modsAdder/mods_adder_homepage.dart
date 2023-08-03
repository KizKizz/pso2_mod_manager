import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
//import 'package:collection/collection.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/mods_adder.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:window_manager/window_manager.dart';
import 'package:io/io.dart' as io;

bool dropZoneMax = true;
bool _newModDragging = false;
List<XFile> modAdderDragDropFiles = [];
List<ModsAdderFile> processedFileList = [];

void modsAdderHomePage(context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: Scaffold(
                  backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                  body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return FutureBuilder(
                        future: itemCsvFetcher(modManRefSheetsDirPath),
                        builder: ((
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
                          if (snapshot.connectionState == ConnectionState.waiting && csvInfosFromSheets.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiPreparing,
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
                                      curLangText!.uiErrorWhenLoadingAddModsData,
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
                                        onPressed: () {
                                          windowManager.destroy();
                                        },
                                        child: Text(curLangText!.uiExit))
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
                                      curLangText!.uiPreparing,
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
                              csvInfosFromSheets = snapshot.data;
                              return Row(
                                children: [
                                  RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        'ADD MODS',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 10),
                                      )),
                                  VerticalDivider(
                                    width: 10,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ),
                                  SizedBox(
                                      width: dropZoneMax
                                          ? constraints.maxWidth * 0.7
                                          : modAdderDragDropFiles.isEmpty
                                              ? constraints.maxWidth * 0.3
                                              : constraints.maxWidth * 0.45,
                                      child: Column(
                                        children: [
                                          DropTarget(
                                            //enable: true,
                                            onDragDone: (detail) async {
                                              for (var element in detail.files) {
                                                if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                                  modsAdderUnsupportedFileTypeDialog(context, p.basename(element.path));
                                                } else if (modAdderDragDropFiles.indexWhere((file) => file.path == element.path) == -1) {
                                                  modAdderDragDropFiles.add(element);
                                                  //newModMainFolderList.add(element);
                                                }
                                              }
                                              setState(
                                                () {},
                                              );
                                            },
                                            onDragEntered: (detail) {
                                              setState(() {
                                                _newModDragging = true;
                                              });
                                            },
                                            onDragExited: (detail) {
                                              setState(() {
                                                _newModDragging = false;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(3),
                                                    border: Border.all(color: Theme.of(context).hintColor),
                                                    color: _newModDragging ? Colors.blue.withOpacity(0.4) : Colors.black26.withAlpha(20),
                                                  ),
                                                  height: constraints.maxHeight - 42,
                                                  //width: constraints.maxWidth * 0.45,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      if (modAdderDragDropFiles.isEmpty)
                                                        Center(
                                                            child: Text(
                                                          curLangText!.uiDragDropFiles,
                                                          style: const TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                      if (modAdderDragDropFiles.isNotEmpty)
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(right: 5),
                                                            child: SizedBox(
                                                                width: constraints.maxWidth,
                                                                height: constraints.maxHeight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                  child: ListView.builder(
                                                                      itemCount: modAdderDragDropFiles.length,
                                                                      itemBuilder: (BuildContext context, int index) {
                                                                        return ListTile(
                                                                          //dense: true,
                                                                          // leading: const Icon(
                                                                          //     Icons.list),
                                                                          trailing: SizedBox(
                                                                            width: 40,
                                                                            child: ModManTooltip(
                                                                              message: curLangText!.uiRemove,
                                                                              child: MaterialButton(
                                                                                child: const Icon(Icons.remove_circle),
                                                                                onPressed: () {
                                                                                  modAdderDragDropFiles.removeAt(index);
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          title: Text(modAdderDragDropFiles[index].name),
                                                                          subtitle: Text(
                                                                            modAdderDragDropFiles[index].path,
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            softWrap: false,
                                                                          ),
                                                                        );
                                                                      }),
                                                                )),
                                                          ),
                                                        )
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          SizedBox(
                                            //width: constraints.maxWidth * 0.7,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5, bottom: 4),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: modAdderDragDropFiles.isNotEmpty
                                                            ? (() {
                                                                modAdderDragDropFiles.clear();
                                                                //newModMainFolderList.clear();
                                                                setState(
                                                                  () {},
                                                                );
                                                              })
                                                            : null,
                                                        child: Text(curLangText!.uiClearAll)),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: modAdderDragDropFiles.isNotEmpty
                                                            ? (() async {
                                                                processedFileList = await modsAdderFilesProcess(modAdderDragDropFiles);
                                                                modAdderDragDropFiles.clear();
                                                                dropZoneMax = false;
                                                                setState(
                                                                  () {},
                                                                );
                                                              })
                                                            : null,
                                                        child: Text(curLangText!.uiProcess)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              );
                            }
                          }
                        }));
                  }),
                ),
              ));
        });
      });
}

//suport functions
Future<List<ModsAdderFile>> modsAdderFilesProcess(List<XFile> xFilePaths) async {
  List<String> charsToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  //copy files to temp
  for (var xFile in xFilePaths) {
    if (p.extension(xFile.path) == '.zip') {
      await extractFileToDisk(xFile.path, Uri.file('$modManAddModsTempDirPath/${xFile.name.replaceAll('.zip', '')}').toFilePath(), asyncWrite: true);
    } else if (File(xFile.path).statSync().type == FileSystemEntityType.directory) {
      await io.copyPath(xFile.path, Uri.file('$modManAddModsTempDirPath/${xFile.name}').toFilePath());
    } else {
      final tempPath = Uri.file('$modManAddModsTempDirPath/${p.basename(File(xFile.path).parent.path)}').toFilePath();
      Directory(tempPath).createSync(recursive: true);
      File(xFile.path).copySync(Uri.file('$tempPath/${xFile.name}').toFilePath());
    }
  }
  //listing ice files in temp
  List<File> iceFileList = [];
  for (var dir in Directory(modManAddModsTempDirPath).listSync(recursive: false).whereType<Directory>()) {
    iceFileList.addAll(dir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path).isEmpty));
  }
  //fetch csv
  if (csvInfosFromSheets.isEmpty) {
    csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  }
  List<String> csvFileInfos = [];
  for (var iceFile in iceFileList) {
    //look in csv infos
    for (var csvFile in csvInfosFromSheets) {
      csvFileInfos.addAll(csvFile.where((line) => line.contains(p.basenameWithoutExtension(iceFile.path)) && !csvFileInfos.contains(line) && line.split(',')[1].isNotEmpty));
    }
  }
  if (csvInfosFromSheets.isNotEmpty) {
    csvInfosFromSheets.clear();
  }
  //create new item structures
  List<File> csvMatchedIceFiles = [];
  for (var infoLine in csvFileInfos) {
    final infos = infoLine.split(',');
    String itemName = '';
    curActiveLang == 'JP' ? itemName = infos[1] : itemName = infos[2];
    for (var char in charsToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    //move files from temp
    for (var iceFile in iceFileList) {
      if (infoLine.contains(p.basenameWithoutExtension(iceFile.path))) {
        String newItemDirPath = Uri.file('$modManModsAdderPath/${infos[0]}/$itemName${iceFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
        await Directory(p.dirname(newItemDirPath)).create(recursive: true);
        iceFile.copySync(newItemDirPath);
        csvMatchedIceFiles.add(iceFile);
      }
    }
    //get item icon
    if (infos[0] != defaultCateforyDirs[7] && infos[0] != defaultCateforyDirs[14]) {
      String ogIconIcePath = '';
      //find og icon path
      if (infos[5].isNotEmpty) {
        int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == infos[5]);
        int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == infos[5]);
        int win32RebootPathIndex = ogWin32RebootFilePaths.indexWhere((element) => p.basename(element) == infos[5]);
        int win32RebootNAPathIndex = ogWin32RebootNAFilePaths.indexWhere((element) => p.basename(element) == infos[5]);
        if (win32PathIndex != -1) {
          ogIconIcePath = ogWin32FilePaths[win32PathIndex];
        } else if (win32NAPathIndex != -1) {
          ogIconIcePath = ogWin32NAFilePaths[win32NAPathIndex];
        } else if (win32RebootPathIndex != -1) {
          ogIconIcePath = ogWin32RebootFilePaths[win32RebootPathIndex];
        } else if (win32RebootNAPathIndex != -1) {
          ogIconIcePath = ogWin32RebootNAFilePaths[win32RebootNAPathIndex];
        } else {
          ogIconIcePath = '';
        }
      }
      if (ogIconIcePath.isNotEmpty) {
        String tempIconUnpackDirPath = Uri.file('$modManModsAdderPath/${infos[0]}/$itemName/tempItemIconUnpack').toFilePath();
        final downloadedconIcePath = await downloadIconIceFromOfficial(ogIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), tempIconUnpackDirPath);
        //unpack and convert dds to png
        if (downloadedconIcePath.isNotEmpty) {
          //debugPrint(downloadedconIcePath);
          await Process.run('$modManZamboniExePath -outdir "$tempIconUnpackDirPath"', [downloadedconIcePath]);
          File ddsItemIcon = Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
          if (ddsItemIcon.path.isNotEmpty) {
            await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsItemIcon.path]);
            File pngItemIcon =
                Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.png', orElse: () => File(''));
            if (pngItemIcon.path.isNotEmpty) {
              pngItemIcon.renameSync(Uri.file('$modManModsAdderPath/${infos[0]}/$itemName/$itemName.png').toFilePath());
            }
          }
          Directory(tempIconUnpackDirPath).deleteSync(recursive: true);
        }
      }
    }
  }

  return [];
}

void modsAdderUnsupportedFileTypeDialog(context, String fileName) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            titlePadding: const EdgeInsets.all(16),
            title: Text(curLangText!.uiError),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            content: Text('"$fileName" ${curLangText!.uiAchiveCurrentlyNotSupported}'),
            actionsPadding: const EdgeInsets.all(16),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(curLangText!.uiReturn))
            ],
          ));
}
