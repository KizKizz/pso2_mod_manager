import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_functions.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
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
  List<List<String>> iceSwappingList = [];

  toAccItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  if (toAccItemAvailableIces.isEmpty) {
    return curLangText!.uiNoMatchingIceFoundToSwap;
  }

  //map coresponding files to swap
  for (var itemT in toAccItemAvailableIces) {
    String curIceType = '';
    //change T ices to HD types
    if (isReplacingNQWithHQ) {
      String tempIceTypeT = itemT.replaceFirst('Normal Quality', 'High Quality');
      curIceType = tempIceTypeT.split(': ').first;
    } else {
      curIceType = itemT.split(': ').first;
    }
    int matchingItemFIndex = fromAccItemAvailableIces.indexWhere((element) => element.split(': ').first == curIceType);
    if (matchingItemFIndex != -1) {
      iceSwappingList.add([fromAccItemAvailableIces[matchingItemFIndex].split(': ').last, itemT.split(': ').last]);
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

    //copy to temp fromitem dir
    int modFileIndexF = fromSubmod.modFiles.indexWhere((element) => element.modFileName == iceNameF);
    if (modFileIndexF != -1) {
      final modFileF = fromSubmod.modFiles[modFileIndexF];
      final iceFileInTempF = await File(modFileF.location).copy(Uri.file('$modManSwapperFromItemDirPath/$iceNameF').toFilePath());
      //extract F ice to
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
    String icePathFromOgDataT = '';
    for (var type in ogDataFilePaths) {
      icePathFromOgDataT = type.firstWhere(
        (element) => p.basename(element) == iceNameT,
        orElse: () => '',
      );
      if (icePathFromOgDataT.isNotEmpty) {
        break;
      }
    }
    if (icePathFromOgDataT.isNotEmpty) {
      final iceFileInTempT = await File(icePathFromOgDataT).copy(Uri.file('$modManSwapperToItemDirPath/${p.basename(icePathFromOgDataT)}').toFilePath());
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
      Directory(extractedGroup1PathF).createSync();
      for (var file in renamedExtractedGroup2Files) {
        file.renameSync(Uri.file('$extractedGroup1PathF/${p.basename(file.path)}').toFilePath());
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
      Directory(extractedGroup2PathF).createSync();
      for (var file in renamedExtractedGroup1Files) {
        file.renameSync(Uri.file('$extractedGroup2PathF/${p.basename(file.path)}').toFilePath());
      }
    }

    //rename texture in aqp
    //group1
    String group1ExtractedItemPathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group1').toFilePath();
    if (Directory(group1ExtractedItemPathF).existsSync()) {
      //get renamed dds in F
      final renamedDdsFilesF = Directory(group1ExtractedItemPathF).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.dds');
      final renamedDdsNamesF = renamedDdsFilesF.map((e) => p.basename(e.path)).toList();
      //get old dds in F
      List<String> ogDdsNamesF = [];
      if (extractedGroup1FilesF.isNotEmpty) {
        ogDdsNamesF = extractedGroup1FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      } else {
        ogDdsNamesF = extractedGroup2FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      }
      //get .aqp
      File aqpInDirF = Directory(group1ExtractedItemPathF).listSync(recursive: true).whereType<File>().firstWhere(
            (element) => p.extension(element.path) == '.aqp',
            orElse: () => File(''),
          );
      if (aqpInDirF.path.isNotEmpty) {
        var aqpBytes = await aqpInDirF.readAsBytes();
        String aqpBytesString = String.fromCharCodes(aqpBytes);
        for (var ddsF in ogDdsNamesF) {
          List<String> ddsFParts = ddsF.split('_');
          String ddsFId = ddsFParts.firstWhere((element) => element.length > 3 && int.tryParse(element) != null);
          List<String> ddsWoId = ddsF.split(ddsFId);
          int ddsIndex = renamedDdsNamesF.indexWhere((element) => element.contains(ddsWoId.first) && element.contains(ddsWoId.last));
          if (ddsIndex != -1) {
            aqpBytesString = aqpBytesString.replaceFirst(ddsF, renamedDdsNamesF[ddsIndex]);
          }
        }
        Uint8List ddsFileTBytes = Uint8List.fromList(aqpBytesString.codeUnits);
        aqpInDirF.writeAsBytesSync(ddsFileTBytes);
      }
    }
    //group2
    String group2ExtractedItemPathF = Uri.file('$tempSubmodPathF/${iceNameF}_ext/group2').toFilePath();
    if (Directory(group2ExtractedItemPathF).existsSync()) {
      //get renamed dds in F
      final renamedDdsFilesF = Directory(group2ExtractedItemPathF).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.dds');
      final renamedDdsNamesF = renamedDdsFilesF.map((e) => p.basename(e.path)).toList();
      //get old dds in F
      List<String> ogDdsNamesF = [];
      if (extractedGroup2FilesF.isNotEmpty) {
        ogDdsNamesF = extractedGroup2FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      } else {
        ogDdsNamesF = extractedGroup1FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      }
      //get .aqp
      File aqpInDirF = Directory(group2ExtractedItemPathF).listSync(recursive: true).whereType<File>().firstWhere(
            (element) => p.extension(element.path) == '.aqp',
            orElse: () => File(''),
          );
      if (aqpInDirF.path.isNotEmpty) {
        var aqpBytes = await aqpInDirF.readAsBytes();
        String aqpBytesString = String.fromCharCodes(aqpBytes);
        for (var ddsF in ogDdsNamesF) {
          List<String> ddsFParts = ddsF.split('_');
          String ddsFId = ddsFParts.firstWhere((element) => element.length > 3 && int.tryParse(element) != null);
          List<String> ddsWoId = ddsF.split(ddsFId);
          int ddsIndex = renamedDdsNamesF.indexWhere((element) => element.contains(ddsWoId.first) && element.contains(ddsWoId.last));
          if (ddsIndex != -1) {
            aqpBytesString = aqpBytesString.replaceFirst(ddsF, renamedDdsNamesF[ddsIndex]);
          }
        }
        Uint8List ddsFileTBytes = Uint8List.fromList(aqpBytesString.codeUnits);
        aqpInDirF.writeAsBytesSync(ddsFileTBytes);
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
                                        )),
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
