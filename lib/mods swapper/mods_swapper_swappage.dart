import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_popup.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String> modsSwapperIceFilesGet(context, SubMod fromSubmod) async {
  //create
  Directory(modManSwapperFromItemDirPath).createSync(recursive: true);
  Directory(modManSwapperToItemDirPath).createSync(recursive: true);

  String tempSubmodPathF = Uri.file('$modManSwapperFromItemDirPath/${fromSubmod.submodName}').toFilePath();
  String tempSubmodPathT = Uri.file('$modManSwapperToItemDirPath/${fromSubmod.submodName}').toFilePath();

  toItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  if (toItemAvailableIces.isEmpty) {
    return 'No matching ice files found in swap to item';
  }
  //get ice files
  for (var line in toItemAvailableIces) {
    //get from ice
    int fromLineIndex = -1;
    if (isReplacingNQWithHQ) {
      fromLineIndex = fromItemAvailableIces.indexWhere((element) => element.split(': ').first == line.split(': ').first.replaceAll('Normal Quality', 'High Quality'));
    } else {
      fromLineIndex = fromItemAvailableIces.indexWhere((element) => element.split(': ').first == line.split(': ').first);
    }
    if (fromLineIndex != -1) {
      final fromModFile = fromSubmod.modFiles.firstWhere((element) => element.modFileName == fromItemAvailableIces[fromLineIndex].split(': ').last);
      final copiedFIceFile = await File(fromModFile.location).copy(Uri.file('$modManSwapperFromItemDirPath/${p.basename(fromModFile.location)}').toFilePath());
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathF"', [copiedFIceFile.path]);

      //get to ices
      String toIcePathFromOgData = '';
      for (var loc in ogDataFilePaths) {
        toIcePathFromOgData = loc.firstWhere((element) => line.split(': ').last == p.basename(element));
        if (toIcePathFromOgData.isNotEmpty) {
          break;
        }
      }
      final copiedTIceFile = await File(toIcePathFromOgData).copy(Uri.file('$modManSwapperToItemDirPath/${p.basename(toIcePathFromOgData)}').toFilePath());
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathT"', [copiedTIceFile.path]);

      //clean To dirs if copy all
      if (isCopyAll) {
        Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).deleteSync();
        Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).createSync();
      }

      //change from files ids -> to files ids
      for (var file in Directory(Uri.file('$tempSubmodPathF/${fromItemAvailableIces[fromLineIndex].split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>()) {
        String newFilePath = '';
        if (file.path.contains(fromItemIds[0])) {
          newFilePath = file.path.replaceFirst(fromItemIds[0], toItemIds[1]);
        } else if (file.path.contains(fromItemIds[1])) {
          newFilePath = file.path.replaceFirst(fromItemIds[1], toItemIds[1]);
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
          if (Directory(Uri.file('$tempSubmodPathF/${fromItemAvailableIces[fromLineIndex].split(': ').last}_ext').toFilePath())
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

Future<void> swapperSwappingDialog(context, SubMod fromSubmod) async {
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
                    future: modsSwapperIceFilesGet(context, fromSubmod),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Swapping item',
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      } else {
                        if (snapshot.hasError) {
                          return SizedBox(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Error when swapping item',
                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return const SizedBox(
                            width: 250,
                            height: 250,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Swapping item',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CircularProgressIndicator(),
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
                                  Text('Successfully swapped', style: Theme.of(context).textTheme.headlineSmall),
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
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 5),
                                        child: Icon(Icons.arrow_forward_ios_rounded),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
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
                                    )
                                  ],
                                ),
                              ),
                              Wrap(
                                runAlignment: WrapAlignment.center,
                                alignment: WrapAlignment.center,
                                spacing: 5,
                                children: [
                                  ElevatedButton(
                                      child: Text(curLangText!.uiReturn),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }),
                                  ElevatedButton(
                                      onPressed: () async {
                                        await launchUrl(Uri.file(swappedModPath));
                                      },
                                      child: const Text('Open in File Explorer')),
                                  ElevatedButton(
                                      onPressed: () {
                                        newModDragDropList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                        newModMainFolderList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                        modAddHandler(context);
                                      },
                                      child: const Text('Add to Mod Manager'))
                                ],
                              )
                            ],
                          );
                        }
                      }
                    }));
          }));
}
