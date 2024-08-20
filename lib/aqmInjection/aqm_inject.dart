import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool isAqmInjecting = false;
bool isAqmInjectDuringApply = false;

Future<bool> modAqmInjectionHomePage(context, SubMod submod) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!isAqmInjecting) {
              isAqmInjecting = true;
              aqmInject(context, submod);
            }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            contentPadding: const EdgeInsets.all(10),
            title: Center(
              child: Text(
                curLangText!.uiCustomAqmInjection,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first != curLangText!.uiError &&
                      context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first != curLangText!.uiSuccess)
                    const CircularProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      context.watch<StateProvider>().aqmInjectionProgressStatus,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            actions: [
              ElevatedButton(
                  onPressed: context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first == curLangText!.uiError ||
                          context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first == curLangText!.uiSuccess
                      ? () {
                          Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                            element.deleteSync(recursive: true);
                          });
                          isAqmInjecting = false;
                          Navigator.pop(context, true);
                        }
                      : null,
                  child: Text(curLangText!.uiReturn))
            ],
          );
        });
      });
}

void aqmInject(context, SubMod submod) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  List<String> aqmInjectedFiles = [];
  int packRetries = 0;

  //player item data
  List<CsvItem> basewearsItemData = playerItemData.where((e) => e.category == defaultCategoryDirs[1]).toList();
  List<ModFile> filteredModFile = [];
  Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiFetchingHQandLQFiles);
  await Future.delayed(const Duration(milliseconds: 100));
  for (var modFile in submod.modFiles) {
    if (basewearsItemData
        .where(
            (e) => e.infos.entries.firstWhere((k) => k.key == 'Normal Quality').value == modFile.modFileName || e.infos.entries.firstWhere((k) => k.key == 'High Quality').value == modFile.modFileName)
        .isNotEmpty) {
      filteredModFile.add(modFile);
    }
  }
  if (filteredModFile.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiMatchingFilesFound);
    await Future.delayed(const Duration(milliseconds: 100));
    for (var modFile in filteredModFile) {
      Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiExtractingFiles);
      await Future.delayed(const Duration(milliseconds: 100));
      //extract files
      await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [modFile.location]);
      String extractedGroup2Path = Uri.file('$modManAddModsTempDirPath/${modFile.modFileName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2Path).existsSync()) {
        //get id from aqp file
        Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiFetchingItemID);
        await Future.delayed(const Duration(milliseconds: 100));
        File aqpFile = Directory(extractedGroup2Path).listSync().whereType<File>().firstWhere((e) => p.extension(e.path) == '.aqp', orElse: () => File(''));
        int id = -1;
        if (aqpFile.existsSync()) {
          final aqpFileNameParts = p.basenameWithoutExtension(aqpFile.path).split('_');
          for (var part in aqpFileNameParts) {
            if (int.tryParse(part) != null) {
              id = int.parse(part);
              break;
            }
          }
        }
        //copy custom aqm file
        final copiedFile = File(modManCustomAqmFilePath).copySync(Uri.file('$extractedGroup2Path/pl_rbd_${id}_bw_sa${p.extension(modManCustomAqmFilePath)}').toFilePath());
        if (copiedFile.existsSync() && id > -1) {
          Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiPackingFiles);
          await Future.delayed(const Duration(milliseconds: 100));
          //pack
          while (!File(Uri.file('${p.dirname(copiedFile.parent.path)}.ice').toFilePath()).existsSync()) {
            await Process.run('$modManZamboniExePath -c -pack -outdir "${p.dirname(copiedFile.parent.path)}"', [Uri.file(p.dirname(copiedFile.parent.path)).toFilePath()]);
            packRetries++;
            // debugPrint(packRetries.toString());
            if (packRetries == 10) {
              break;
            }
          }
          packRetries = 0;

          Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus(curLangText!.uiReplacingModFiles);
          await Future.delayed(const Duration(milliseconds: 100));
          try {
            File renamedFile = await File(Uri.file('${p.dirname(copiedFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(copiedFile.parent.path).replaceAll('_ext', '')).toFilePath());
            await renamedFile.copy(modFile.location);
            aqmInjectedFiles.add('${p.basename(copiedFile.path)} -> ${modFile.modFileName}');
          } catch (e) {
            Provider.of<StateProvider>(context, listen: false).setBoundaryEditProgressStatus('${curLangText!.uiError}\n${e.toString()}');
          }
        } else {
          Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiCustomAqmFileOrItemIDNotFound}');
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } else {
        Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiGroup2IsNotFoundInextractedIce}');
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // String extractedGroup1Path = Uri.file('$modManAddModsTempDirPath/${modFile.modFileName}_ext/group1').toFilePath();
      // if (Directory(extractedGroup1Path).existsSync()) {}
    }
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiSuccess}\n${aqmInjectedFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
  } else {
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}');
    await Future.delayed(const Duration(milliseconds: 100));
    if (isAqmInjectDuringApply) {
      Navigator.pop(context, true);
    }
  }
  // } else {
  //   Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiOnlyBasewearsAndSetwearsCanBeModified}');
  //   await Future.delayed(const Duration(milliseconds: 100));
  //   if (isAqmInjectDuringApply) {
  //     Navigator.pop(context, true);
  //   }
  // }
  // if (boundaryRemovedFiles.isNotEmpty && boundaryNotFoundFiles.isNotEmpty) {
  //   Provider.of<StateProvider>(context, listen: false)
  //       .setAqmInjectionProgressStatus('${curLangText!.uiSuccess}\n${boundaryRemovedFiles.join('\n')}\n${curLangText!.uiNoMatchingFileFound}\n${boundaryNotFoundFiles.join('\n')}');
  //   await Future.delayed(const Duration(milliseconds: 100));
  // } else if (boundaryRemovedFiles.isNotEmpty && boundaryNotFoundFiles.isEmpty) {
  //   Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiSuccess}\n${boundaryRemovedFiles.join('\n')}');
  //   await Future.delayed(const Duration(milliseconds: 100));
  // } else if (boundaryRemovedFiles.isEmpty && boundaryNotFoundFiles.isNotEmpty) {
  //   Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}\n${boundaryNotFoundFiles.join('\n')}');
  //   await Future.delayed(const Duration(milliseconds: 100));
  // }
  if (isAqmInjectDuringApply) {
    Navigator.pop(context, true);
  }

  isAqmInjecting = true;
  // if (isAqmInjectDuringApply) {
  //   Navigator.pop(context, true);
  // }
}
