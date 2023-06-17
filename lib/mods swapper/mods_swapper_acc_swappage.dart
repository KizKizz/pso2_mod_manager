import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_popup.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String> modsSwapperAccIceFilesGet(context, SubMod fromSubmod) async {
  //create
  Directory(modManSwapperFromItemDirPath).createSync(recursive: true);
  Directory(modManSwapperToItemDirPath).createSync(recursive: true);

  String tempSubmodPathF = Uri.file('$modManSwapperFromItemDirPath/${fromSubmod.submodName}').toFilePath();
  String tempSubmodPathT = Uri.file('$modManSwapperToItemDirPath/${fromSubmod.submodName}').toFilePath();

  toAccItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  if (toAccItemAvailableIces.isEmpty) {
    return curLangText!.uiNoMatchingIceFoundToSwap;
  }
  //get ice files
  for (var line in toAccItemAvailableIces) {
    //get from ice
    int fromLineIndex = -1;
    if (isReplacingNQWithHQ) {
      fromLineIndex = fromAccItemAvailableIces.indexWhere((element) => element.split(': ').first == line.split(': ').first.replaceAll('Normal Quality', 'High Quality'));
    } else {
      fromLineIndex = fromAccItemAvailableIces.indexWhere((element) => element.split(': ').first == line.split(': ').first);
    }
    if (fromLineIndex != -1) {
      final fromModFile = fromSubmod.modFiles.where((element) => element.modFileName == fromAccItemAvailableIces[fromLineIndex].split(': ').last);
      if (fromModFile.isNotEmpty) {
        final copiedFIceFile = await File(fromModFile.first.location).copy(Uri.file('$modManSwapperFromItemDirPath/${p.basename(fromModFile.first.location)}').toFilePath());
        await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathF"', [copiedFIceFile.path]);
      }

      //get to ices
      String toIcePathFromOgData = '';
      for (var loc in ogDataFilePaths) {
        toIcePathFromOgData = loc.firstWhere(
          (element) => line.split(': ').last == p.basename(element),
          orElse: () => '',
        );
        if (toIcePathFromOgData.isNotEmpty) {
          break;
        }
      }
      if (toIcePathFromOgData.isNotEmpty) {
        final copiedTIceFile = await File(toIcePathFromOgData).copy(Uri.file('$modManSwapperToItemDirPath/${p.basename(toIcePathFromOgData)}').toFilePath());
        await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathT"', [copiedTIceFile.path]);
      }

      //clean To dirs if copy all
      if (isCopyAll) {
        Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).deleteSync(recursive: true);
        Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).createSync(recursive: true);
      }

      //change from files ids -> to files ids
      for (var file in Directory(Uri.file('$tempSubmodPathF/${fromAccItemAvailableIces[fromLineIndex].split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>()) {
        String newFilePath = '';
        if (file.path.contains(fromAccItemId)) {
            newFilePath = file.path.replaceFirst(fromAccItemId, toAccItemId);
          } else {
            newFilePath = file.path;
          }

        //copy file
        File renamedFile = await file.rename(Uri.file(newFilePath).toFilePath());
        if (isCopyAll) {
          renamedFile.copySync(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext/${p.basename(renamedFile.path)}').toFilePath());
        } else {
          final extractedFilesInTItem = Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
          File matchingTFile = extractedFilesInTItem
              .firstWhere((element) => p.basename(element.parent.path) == p.basename(renamedFile.parent.path) && p.basename(element.path) == p.basename(renamedFile.path), orElse: () {
            return File('');
          });
          if (matchingTFile.path.isNotEmpty) {
            renamedFile.copySync(matchingTFile.path);
          }
        }
      }

      //remove extra file in To dir

      if (isRemoveExtras) {
        for (var file in Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>()) {
          if (Directory(Uri.file('$tempSubmodPathF/${fromAccItemAvailableIces[fromLineIndex].split(': ').last}_ext').toFilePath())
              .listSync(recursive: true)
              .whereType<File>()
              .where((element) => p.basename(element.path) == p.basename(file.path))
              .isEmpty) {
            file.deleteSync();
          }
        }
      }

      //pack
      List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
      for (var char in charToReplace) {
        toItemName = toItemName.replaceAll(char, '_');
      }
      String packDirPath = '';
      if (fromSubmod.modName == fromSubmod.submodName) {
        packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName}').toFilePath();
      } else {
        packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName}/${fromSubmod.submodName}').toFilePath();
      }
      Directory(packDirPath).createSync(recursive: true);
      await Process.run('$modManZamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()]);
      File(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext.ice').toFilePath()).renameSync(Uri.file('$packDirPath/${line.split(': ').last}').toFilePath());
      //image
      for (var imagePath in fromSubmod.previewImages) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(imagePath)).isEmpty) {
          File(imagePath).copySync(Uri.file('$packDirPath/${p.basename(imagePath)}').toFilePath());
        }
      }
      //video
      for (var videoPath in fromSubmod.previewVideos) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(videoPath)).isEmpty) {
          File(videoPath).copySync(Uri.file('$packDirPath/${p.basename(videoPath)}').toFilePath());
        }
      }
    }
  }

  return Uri.file('$modManSwapperOutputDirPath/$toItemName').toFilePath();
}

Future<void> swapperAccSwappingDialog(context, SubMod fromSubmod) async {
  String swappedModPath = '';
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                contentPadding: const EdgeInsets.all(16),
                content: FutureBuilder(
                    future: swappedModPath.isEmpty ? modsSwapperAccIceFilesGet(context, fromSubmod) : null,
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
                                  curLangText!.uiSwappingItem,
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
                                  curLangText!.uiErrorWhenSwapping,
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
                                    curLangText!.uiSwappingItem,
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
                          swappedModPath = snapshot.data;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    curLangText!.uiSuccessfullySwapped,
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                fromSubmod.itemName,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              Text('${fromSubmod.modName} > ${fromSubmod.submodName}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                        child: Icon(Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                toItemName,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              Text('${fromSubmod.modName} > ${fromSubmod.submodName}'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 450),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Wrap(
                                      runAlignment: WrapAlignment.center,
                                      alignment: WrapAlignment.center,
                                      spacing: 5,
                                      children: [
                                        ElevatedButton(
                                            child: Text(curLangText!.uiReturn),
                                            onPressed: () {
                                              //clear
                                              if (Directory(modManSwapperFromItemDirPath).existsSync()) {
                                                Directory(modManSwapperFromItemDirPath).deleteSync(recursive: true);
                                              }
                                              if (Directory(modManSwapperToItemDirPath).existsSync()) {
                                                Directory(modManSwapperToItemDirPath).deleteSync(recursive: true);
                                              }
                                              Navigator.pop(context);
                                            }),
                                        ElevatedButton(
                                            onPressed: () async {
                                              await launchUrl(Uri.file(swappedModPath));
                                            },
                                            child: Text('${curLangText!.uiOpen} ${curLangText!.uiInFileExplorer}')),
                                        ElevatedButton(
                                            onPressed: () {
                                              newModDragDropList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                              newModMainFolderList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                              modAddHandler(context);
                                            },
                                            child: Text(curLangText!.uiAddToModManager))
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                      }
                    }));
          }));
}
