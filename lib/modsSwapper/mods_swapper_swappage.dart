import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_functions.dart';
//import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<String> modsSwapperIceFilesGet(
    context, bool isVanillaItemSwap, SubMod fromSubmod, List<String> fromItemAvailableIces, List<String> toItemAvailableIces, String toItemName, String fromItemId, String toItemId) async {
  //clean
  if (Directory(modManSwapperOutputDirPath).existsSync()) {
    Directory(modManSwapperOutputDirPath).deleteSync(recursive: true);
  }
  //create
  Directory(modManSwapperFromItemDirPath).createSync(recursive: true);
  Directory(modManSwapperToItemDirPath).createSync(recursive: true);
  Directory(modManSwapperOutputDirPath).createSync(recursive: true);

  String tempSubmodPathF = Uri.file('$modManSwapperFromItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  String tempSubmodPathT = Uri.file('$modManSwapperToItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  List<List<String>> iceSwappingList = [];

  toItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  if (toItemAvailableIces.isEmpty) {
    return curLangText!.uiNoMatchingIceFoundToSwap;
  }

  //map coresponding files to swap
  for (var itemT in toItemAvailableIces) {
    String curIceType = '';
    //change T ices to HD types
    if (fromItemAvailableIces.where((element) => element.contains('High Quality')).isNotEmpty && isReplacingNQWithHQ) {
      String tempIceTypeT = itemT.replaceFirst('Normal Quality', 'High Quality');
      curIceType = tempIceTypeT.split(': ').first;
    } else {
      curIceType = itemT.split(': ').first;
    }
    int matchingItemFIndex = fromItemAvailableIces.indexWhere((element) => element.split(': ').first == curIceType);
    if (matchingItemFIndex != -1) {
      iceSwappingList.add([fromItemAvailableIces[matchingItemFIndex].split(': ').last, itemT.split(': ').last]);
    }
  }

  for (var pair in iceSwappingList) {
    //F ice prep
    String iceNameF = pair[0];
    String iceNameT = pair[1];
    List<File> extractedGroup1FilesF = [];
    List<File> extractedGroup2FilesF = [];
    List<File> extractedGroup1FilesT = [];
    List<File> extractedGroup2FilesT = [];

    //copy or download files to temp fromitem dir
    File iceFileInTempF = File('');
    if (isVanillaItemSwap) {
      //get ice path
      String icePathFromOgDataF = '';
      if (icePathFromOgDataF.isEmpty) {
        for (var type in ogDataFilePaths) {
          icePathFromOgDataF = type.firstWhere(
            (element) => p.basename(element) == iceNameF,
            orElse: () => '',
          );
          if (icePathFromOgDataF.isNotEmpty) {
            break;
          }
        }
      }
      iceFileInTempF = await swapperIceFileDownload(icePathFromOgDataF, modManSwapperFromItemDirPath);
    } else {
      int modFileIndexF = fromSubmod.modFiles.indexWhere((element) => element.modFileName == iceNameF);
      if (modFileIndexF != -1) {
        final modFileF = fromSubmod.modFiles[modFileIndexF];
        iceFileInTempF = await File(modFileF.location).copy(Uri.file('$modManSwapperFromItemDirPath/$iceNameF').toFilePath());
      }
    }
    //extract F ice to
    if (iceFileInTempF.path.isNotEmpty) {
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathF"', [iceFileInTempF.path]);
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathF).existsSync()) {
        extractedGroup1FilesF = Directory(extractedGroup1PathF).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathF).existsSync()) {
        extractedGroup2FilesF = Directory(extractedGroup2PathF).listSync(recursive: true).whereType<File>().toList();
      }
    }

    //copy to temp toitem dir
    List<String> fileTPaths = await originalFilePathGet(context, iceNameT);
    if (fileTPaths.isNotEmpty) {
      String icePathFromOgDataT = '';
      icePathFromOgDataT = fileTPaths.first;
      //final iceFileInTempT = await File(icePathFromOgDataT).copy(Uri.file('$modManSwapperToItemDirPath/${p.basename(icePathFromOgDataT)}').toFilePath());
      //download from file from server
      final iceFileInTempT = await swapperIceFileDownload(icePathFromOgDataT, modManSwapperToItemDirPath);
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathT"', [iceFileInTempT.path]);
      String extractedGroup1PathT = Uri.file('$tempSubmodPathT/${iceNameT}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathT).existsSync()) {
        extractedGroup1FilesT = Directory(extractedGroup1PathT).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathT = Uri.file('$tempSubmodPathT/${iceNameT}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathT).existsSync()) {
        extractedGroup2FilesT = Directory(extractedGroup2PathT).listSync(recursive: true).whereType<File>().toList();
      }
    }

    //group2 > group2
    List<File> renamedExtractedGroup2Files = [];
    if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await modsSwapRename(extractedGroup2FilesF, extractedGroup2FilesT);
    } else if (extractedGroup2FilesF.isEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await modsSwapRename(extractedGroup1FilesF, extractedGroup2FilesT);
    } else if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isEmpty) {
      renamedExtractedGroup2Files = await modsSwapRename(extractedGroup2FilesF, extractedGroup1FilesT);
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group1').toFilePath();
      if (!Directory(extractedGroup1PathF).existsSync()) {
        Directory(extractedGroup1PathF).createSync();
        for (var file in renamedExtractedGroup2Files) {
          file.renameSync(Uri.file('$extractedGroup1PathF/${p.basename(file.path)}').toFilePath());
        }
      }
    }

    //group1 > group1
    List<File> renamedExtractedGroup1Files = [];
    if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await modsSwapRename(extractedGroup1FilesF, extractedGroup1FilesT);
    } else if (extractedGroup1FilesF.isEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await modsSwapRename(extractedGroup2FilesF, extractedGroup1FilesT);
    } else if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isEmpty) {
      renamedExtractedGroup1Files = await modsSwapRename(extractedGroup1FilesF, extractedGroup2FilesT);
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group2').toFilePath();
      if (!Directory(extractedGroup2PathF).existsSync()) {
        Directory(extractedGroup2PathF).createSync();
        for (var file in renamedExtractedGroup1Files) {
          file.renameSync(Uri.file('$extractedGroup2PathF/${p.basename(file.path)}').toFilePath());
        }
      }
    }

    //copy extra files
    if (renamedExtractedGroup1Files.isNotEmpty && !isRemoveExtras) {
      for (var extractedFileT in extractedGroup1FilesT) {
        if (renamedExtractedGroup1Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup1Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }
    if (renamedExtractedGroup2Files.isNotEmpty && !isRemoveExtras) {
      for (var extractedFileT in extractedGroup2FilesT) {
        if (renamedExtractedGroup2Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup2Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }

    //pack
    toItemName = toItemName.replaceAll(RegExp(charToReplace), '_');
    String packDirPath = '';
    if (fromSubmod.modName == fromSubmod.submodName) {
      packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath();
    } else {
      packDirPath = Uri.file('$modManSwapperOutputDirPath/$toItemName/${fromSubmod.modName}/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}')
          .toFilePath();
    }
    Directory(packDirPath).createSync(recursive: true);
    await Process.run('$modManZamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathF/${iceNameF}_ext').toFilePath()]);
    File(Uri.file('$tempSubmodPathF/${iceNameF}_ext.ice').toFilePath()).renameSync(Uri.file('$packDirPath/$iceNameT').toFilePath());
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
    //cmx
    if (fromSubmod.hasCmx! && fromSubmod.cmxFile!.isNotEmpty && File(fromSubmod.cmxFile!).existsSync()) {
      File cmxFileF = File(fromSubmod.cmxFile!);
      String cmxData = await cmxFileF.readAsString();
      String newCmxData = cmxData.replaceFirst(fromItemId, toItemId);
      File cmxFileT = File(Uri.file('$packDirPath/${p.basename(cmxFileF.path).replaceFirst(fromItemId, toItemId)}').toFilePath());
      if (!cmxFileT.existsSync()) {
        await cmxFileT.create(recursive: true);
      }
      await cmxFileT.writeAsString(newCmxData);
    }
  }

  return Uri.file('$modManSwapperOutputDirPath/$toItemName').toFilePath();
}

Future<void> swapperSwappingDialog(
    context, bool isVanillaItemSwap, SubMod fromSubmod, List<String> fromItemAvailableIces, List<String> toItemAvailableIces, String toItemName, String fromItemId, String toItemId) async {
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
                    future:
                        swappedModPath.isEmpty ? modsSwapperIceFilesGet(context, isVanillaItemSwap, fromSubmod, fromItemAvailableIces, toItemAvailableIces, toItemName, fromItemId, toItemId) : null,
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
                                    swappedModPath.contains(modManSwapperOutputDirPath) ? curLangText!.uiSuccessfullySwapped : curLangText!.uiFailedToSwap,
                                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                child: swappedModPath.contains(modManSwapperOutputDirPath)
                                    ? Row(
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
                                                    if (!fromSubmod.modName.contains('_${curLangText!.uiSwap}') && !fromSubmod.submodName.contains('_${curLangText!.uiSwap}'))
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
                                      )
                                    : ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: MaterialStateProperty.resolveWith((states) {
                                            if (states.contains(MaterialState.hovered)) {
                                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                            }
                                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                          }),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: Text(
                                                  curLangText!.uiUnableToSwapTheseFilesBelow,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              Text(swappedModPath)
                                            ],
                                          ),
                                        ),
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
                                              if (Directory(modManSwapperOutputDirPath).existsSync()) {
                                                Directory(modManSwapperOutputDirPath).deleteSync(recursive: true);
                                              }
                                              Navigator.pop(context);
                                            }),
                                        ElevatedButton(
                                            onPressed: !swappedModPath.contains(modManSwapperOutputDirPath)
                                                ? null
                                                : () async {
                                                    await launchUrl(Uri.file(swappedModPath));
                                                  },
                                            child: Text('${curLangText!.uiOpen} ${curLangText!.uiInFileExplorer}')),
                                        ElevatedButton(
                                            onPressed: !swappedModPath.contains(modManSwapperOutputDirPath)
                                                ? null
                                                : () {
                                                    // newModDragDropList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                                    // newModMainFolderList.add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName}').toFilePath()));
                                                    // modAddHandler(context);
                                                    modAdderDragDropFiles
                                                        .add(XFile(Uri.file('$swappedModPath/${fromSubmod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath()));
                                                    modsAdderHomePage(context);
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
