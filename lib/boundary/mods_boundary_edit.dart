import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool isBoundaryEdited = false;
bool isBoundaryEditDuringApply = false;
List<int> boundingSelectValues = [-10, -20, -30, -40, -50, -60];
List<List<int>> boundaryValues = [
  [0, 0, 32, 193], //-10
  [0, 0, 160, 193], //-20
  [0, 0, 240, 193], //-30
  [0, 0, 32, 194], //-40
  [0, 0, 72, 194], //-50
  [0, 0, 112, 194], //-60
];

Future<bool> modsBoundaryEditHomePage(context, SubMod submod) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isBoundaryEdited) {
              isBoundaryEdited = true;
              boundaryEdit(context, submod);
            }
          });
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: ConstrainedBox(
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
                    if (context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first != curLangText!.uiError &&
                        context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first != curLangText!.uiSuccess)
                      const CircularProgressIndicator(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        context.watch<StateProvider>().boundaryEditProgressStatus,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Visibility(
                      visible: !isBoundaryEditDuringApply,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                            onPressed: context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first == curLangText!.uiError ||
                                    context.watch<StateProvider>().boundaryEditProgressStatus.split('\n').first == curLangText!.uiSuccess
                                ? () {
                                    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                      element.deleteSync(recursive: true);
                                    });
                                    isBoundaryEdited = false;
                                    Navigator.pop(context, true);
                                  }
                                : null,
                            child: Text(curLangText!.uiReturn)),
                      ),
                    ),
                  ],
                ),
              ));
        });
      });
}

void boundaryEdit(context, SubMod submod) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  List<String> boundaryRemovedFiles = [];
  List<String> boundaryNotFoundFiles = [];
  int packRetries = 0;
  //if (itemCategory == defaultCateforyDirs[16] || itemCategory == defaultCateforyDirs[1] || itemName.contains('[Fu]')) {
  // if (itemCategory == defaultCategoryDirs[1] ||
  //     itemCategory == defaultCategoryDirs[3] ||
  //     itemCategory == defaultCategoryDirs[4] ||
  //     itemCategory == defaultCategoryDirs[5] ||
  //     itemCategory == defaultCategoryDirs[15] ||
  //     itemCategory == defaultCategoryDirs[16] ||
  //     itemName.contains('[Fu]')) {
  Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${submod.category}${curLangText!.uispaceFoundExcl}');
  await Future.delayed(const Duration(milliseconds: 100));
  List<ModFile> matchingFiles = submod.modFiles.where((element) => p.extension(element.location).isEmpty).toList();
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
          if (File(aqpFile.path).existsSync()) {
            Uint8List aqpBytes = await File(aqpFile.path).readAsBytes();

            if (aqpBytes[233] == 0 && aqpBytes[234] == 0 && aqpBytes[235] == 0) {
              Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiEditingBoundaryRadiusValue);
              await Future.delayed(const Duration(milliseconds: 100));
              int selectedIndex = 0;
              switch (selectedBoundingValue) {
                case -10:
                  selectedIndex = 0;
                  break;
                case -20:
                  selectedIndex = 1;
                  break;
                case -30:
                  selectedIndex = 2;
                  break;
                case -40:
                  selectedIndex = 3;
                  break;
                case -50:
                  selectedIndex = 4;
                  break;
                case -60:
                  selectedIndex = 5;
                  break;
              }
              aqpBytes[236] = boundaryValues[selectedIndex][0];
              aqpBytes[237] = boundaryValues[selectedIndex][1];
              aqpBytes[238] = boundaryValues[selectedIndex][2];
              aqpBytes[239] = boundaryValues[selectedIndex][3];
              aqpFile.writeAsBytesSync(Uint8List.fromList(aqpBytes));
              Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiPackingFiles);
              await Future.delayed(const Duration(milliseconds: 100));
              //pack
              while (!File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).existsSync()) {
                await Process.run('$modManZamboniExePath -c -pack -outdir "${p.dirname(aqpFile.parent.path)}"', [Uri.file(p.dirname(aqpFile.parent.path)).toFilePath()]);
                packRetries++;
                debugPrint(packRetries.toString());
                if (packRetries == 10) {
                  break;
                }
              }
              packRetries = 0;
              Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiReplacingModFiles);
              await Future.delayed(const Duration(milliseconds: 100));
              try {
                File renamedFile = await File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(aqpFile.parent.path).replaceAll('_ext', '')).toFilePath());
                await renamedFile.copy(modFile.location);
              } catch (e) {
                Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${e.toString()}');
              }
              boundaryRemovedFiles.add(modFile.modFileName);
              // if (modFile.modFileName == matchingFiles.last.modFileName) {
              //   Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(
              //       modFile.applyStatus ? '${curLangText!.uiSuccess}\n${curLangText!.uiAllDone}\n${curLangText!.uiMakeSureToReapplyThisMod}' : '${curLangText!.uiSuccess}\n${curLangText!.uiAllDone} ');
              //   await Future.delayed(const Duration(milliseconds: 100));
              //   if (isBoundaryEditDuringApply) {
              //     Navigator.pop(context, true);
              //   }
              // }
            } else {
              boundaryNotFoundFiles.add(modFile.modFileName);
              // Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiBoundaryRadiusValueNotFound}');
              // await Future.delayed(const Duration(milliseconds: 100));
              // if (isBoundaryEditDuringApply) {
              //   Navigator.pop(context, true);
              // }
            }
          }
        }
      } else {
        boundaryNotFoundFiles.add(modFile.modFileName);
        // Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoAqpFileFound}');
        // await Future.delayed(const Duration(milliseconds: 100));
        // if (isBoundaryEditDuringApply) {
        //   Navigator.pop(context, true);
        // }
      }
    }
  } else {
    Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}');
    await Future.delayed(const Duration(milliseconds: 100));
    if (isBoundaryEditDuringApply) {
      Navigator.pop(context, true);
    }
  }
  // } else {
  //   Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiOnlyBasewearsAndSetwearsCanBeModified}');
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   if (isBoundaryEditDuringApply) {
  //     Navigator.pop(context, true);
  //   }
  // }
  if (boundaryRemovedFiles.isNotEmpty && boundaryNotFoundFiles.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false)
        .setBoundaryEditProgressStatus('${curLangText!.uiSuccess}\n${boundaryRemovedFiles.join('\n')}\n${curLangText!.uiNoMatchingFileFound}\n${boundaryNotFoundFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
  } else if (boundaryRemovedFiles.isNotEmpty && boundaryNotFoundFiles.isEmpty) {
    Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiSuccess}\n${boundaryRemovedFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
  } else if (boundaryRemovedFiles.isEmpty && boundaryNotFoundFiles.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}\n${boundaryNotFoundFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
  }
  if (isBoundaryEditDuringApply) {
    Navigator.pop(context, true);
  }

  isBoundaryEdited = true;
  // if (isBoundaryEditDuringApply) {
  //   Navigator.pop(context, true);
  // }
}
