// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool isAqmInjecting = false;
bool isAqmInjectDuringApply = false;

Future<bool> itemAqmInjectionHomePage(context, String hqIcePath, String lqIcePath, String iconIcePath, bool boundaryRemoval) async {
  bool result = false;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (!isAqmInjecting && !boundaryRemoval) {
              isAqmInjecting = true;
              result = await itemAqmInject(context, hqIcePath, lqIcePath, iconIcePath);
            }
            if (!isAqmInjecting && boundaryRemoval) {
              isAqmInjecting = true;
              await itemBoundaryRemoval(context, hqIcePath, lqIcePath);
            }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            contentPadding: const EdgeInsets.all(10),
            titlePadding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            title: Center(
              child: Text(
                !boundaryRemoval && aqmAutoBoundingRadius
                    ? '${curLangText!.uiCustomAqmInjection} & ${curLangText!.uiBoundaryRadiusModification}'
                    : boundaryRemoval
                        ? curLangText!.uiBoundaryRadiusModification
                        : curLangText!.uiCustomAqmInjection,
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
            actionsPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            actions: [
              ElevatedButton(
                  onPressed: context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first == curLangText!.uiError ||
                          context.watch<StateProvider>().aqmInjectionProgressStatus.split('\n').first == curLangText!.uiSuccess
                      ? () {
                          Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                            element.deleteSync(recursive: true);
                          });
                          isAqmInjecting = false;
                          Navigator.pop(context, result);
                        }
                      : null,
                  child: Text(curLangText!.uiReturn))
            ],
          );
        });
      });
}

Future<bool> itemAqmInject(context, String hqIcePath, String lqIcePath, String iconIcePath) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  List<String> aqmInjectedFiles = [];
  int packRetries = 0;

  List<File> downloadedFiles = [];
  Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiFetchingHQandLQFiles);
  await Future.delayed(const Duration(milliseconds: 100));

  if (hqIcePath.isNotEmpty) {
    File hqIceFile = await swapperIceFileDownload(hqIcePath, modManAddModsTempDirPath);
    if (hqIceFile.existsSync()) downloadedFiles.add(hqIceFile);
  }
  if (lqIcePath.isNotEmpty) {
    File lqIceFile = await swapperIceFileDownload(lqIcePath, modManAddModsTempDirPath);
    if (lqIceFile.existsSync()) downloadedFiles.add(lqIceFile);
  }

  if (downloadedFiles.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiMatchingFilesFound);
    await Future.delayed(const Duration(milliseconds: 100));
    for (var file in downloadedFiles) {
      Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiExtractingFiles);
      await Future.delayed(const Duration(milliseconds: 100));
      //extract files
      await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [file.path]);
      String extractedGroup2Path = Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(file.path)}_ext/group2').toFilePath();
      if (Directory(extractedGroup2Path).existsSync()) {
        //get id from aqp file
        Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiFetchingItemID);
        await Future.delayed(const Duration(milliseconds: 100));
        file.deleteSync();
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

          Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiReplacingModFiles);
          await Future.delayed(const Duration(milliseconds: 100));
          try {
            File renamedFile = await File(Uri.file('${p.dirname(copiedFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(copiedFile.parent.path).replaceAll('_ext', '')).toFilePath());
            if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(hqIcePath)) {
              await renamedFile.copy(hqIcePath);
            } else if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(lqIcePath)) {
              await renamedFile.copy(lqIcePath);
            }
            aqmInjectedFiles.add('${p.basename(copiedFile.path)} -> ${p.basenameWithoutExtension(file.path)}');
          } catch (e) {
            Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${e.toString()}');
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

    if (aqmAutoBoundingRadius && !isAqmInjectDuringApply) {
      itemBoundaryRemoval(context, hqIcePath, lqIcePath);
    }

    //icon patching
    File cachedIconIceFile = Directory(modManOverlayedItemIconsDirPath).listSync().whereType<File>().firstWhere((e) => p.basename(e.path) == p.basename(iconIcePath), orElse: () => File(''));
    if (iconIcePath.isNotEmpty && Provider.of<StateProvider>(context, listen: false).markModdedItem && cachedIconIceFile.existsSync()) {
      Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiApplyingOverlayToIngameItemIcon);
      await Future.delayed(const Duration(milliseconds: 100));
      cachedIconIceFile.copySync(iconIcePath);
    } else if (iconIcePath.isNotEmpty && Provider.of<StateProvider>(context, listen: false).markModdedItem && !cachedIconIceFile.existsSync()) {
      Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiApplyingOverlayToIngameItemIcon);
      await Future.delayed(const Duration(milliseconds: 100));
      File iconIceFile = await swapperIceFileDownload(iconIcePath, modManAddModsTempDirPath);
      if (iconIceFile.existsSync()) {
        await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [iconIceFile.path]);
        Directory extractedIceDir = Directory(Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(iconIceFile.path)}_ext').toFilePath());
        if (extractedIceDir.existsSync()) {
          File ddsFile = extractedIceDir.listSync(recursive: true).whereType<File>().firstWhere(
                (element) => p.extension(element.path) == '.dds',
                orElse: () => File(''),
              );
          if (ddsFile.existsSync()) {
            await Process.run(modManDdsPngToolExePath, [ddsFile.path, Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath(), '-ddstopng']);
            File convertedPng = File(Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath());
            if (convertedPng.existsSync()) {
              ddsFile.deleteSync();
              File? overlayedPng = await iconOverlay(convertedPng.path);
              if (overlayedPng != null) {
                await Process.run(
                    modManDdsPngToolExePath, [overlayedPng.path, Uri.file('${p.dirname(overlayedPng.path)}/${p.basenameWithoutExtension(overlayedPng.path)}.dds').toFilePath(), '-pngtodds']);
                overlayedPng.deleteSync();
                await Process.run(
                    '$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(iconIceFile.path)}_ext').toFilePath()]);
                Directory(modManOverlayedItemIconsDirPath).createSync(recursive: true);
                File renamedIconFile = await File(Uri.file('${iconIceFile.path}_ext.ice').toFilePath())
                    .rename(Uri.file(iconIceFile.path.replaceFirst(modManAddModsTempDirPath, modManOverlayedItemIconsDirPath)).toFilePath());
                if (renamedIconFile.existsSync()) {
                  renamedIconFile.copySync(iconIcePath);
                }
              }
            }
          }
        }
      }
    }

    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiSuccess}\n${aqmInjectedFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  } else {
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}');
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
    // if (isAqmInjectDuringApply) {
    //   Navigator.pop(context, false);
    // } else {
    //   return false;
    // }
  }

  // if (isAqmInjectDuringApply) {
  //   Navigator.pop(context, true);
  // } else {
  //   return true;
  // }
}

Future<bool> itemBoundaryRemoval(context, String hqIcePath, String lqIcePath) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  List<String> aqmInjectedFiles = [];
  int packRetries = 0;

  List<File> downloadedFiles = [];
  Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiFetchingHQandLQFiles);
  await Future.delayed(const Duration(milliseconds: 100));

  if (hqIcePath.isNotEmpty) {
    // File hqIceFile = await swapperIceFileDownload(hqIcePath, modManAddModsTempDirPath);
    File hqTempFile = File(hqIcePath.replaceFirst(modManPso2binPath, modManAddModsTempDirPath));
    hqTempFile.parent.createSync(recursive: true);
    File hqIceFile = await File(hqIcePath).copy(hqTempFile.path);
    if (hqIceFile.existsSync()) downloadedFiles.add(hqIceFile);
  }
  if (lqIcePath.isNotEmpty) {
    // File lqIceFile = await swapperIceFileDownload(lqIcePath, modManAddModsTempDirPath);
    File lqTempFile = File(lqIcePath.replaceFirst(modManPso2binPath, modManAddModsTempDirPath));
    lqTempFile.parent.createSync(recursive: true);
    File lqIceFile = await File(lqIcePath).copy(lqTempFile.path);
    if (lqIceFile.existsSync()) downloadedFiles.add(lqIceFile);
  }

  if (downloadedFiles.isNotEmpty) {
    for (var file in downloadedFiles) {
      Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiExtractingFiles);
      await Future.delayed(const Duration(milliseconds: 100));
      List<File> extractedGroup1Files = [];
      List<File> extractedGroup2Files = [];
      //extract files
      await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [file.path]);
      String extractedGroup1Path = Uri.file('$modManAddModsTempDirPath/${p.basename(file.path)}_ext/group1').toFilePath();
      if (Directory(extractedGroup1Path).existsSync()) {
        extractedGroup1Files = Directory(extractedGroup1Path).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathF = Uri.file('$modManAddModsTempDirPath/${p.basename(file.path)}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathF).existsSync()) {
        extractedGroup2Files = Directory(extractedGroup2PathF).listSync(recursive: true).whereType<File>().toList();
      }
      //Get aqp files
      List<File> aqpFiles = [];
      aqpFiles.addAll(extractedGroup1Files.where((element) => p.extension(element.path) == '.aqp'));
      aqpFiles.addAll(extractedGroup2Files.where((element) => p.extension(element.path) == '.aqp'));
      if (aqpFiles.isNotEmpty) {
        for (var aqpFile in aqpFiles) {
          Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiReadingspace}${p.basename(aqpFile.path)}');
          await Future.delayed(const Duration(milliseconds: 100));
          if (File(aqpFile.path).existsSync()) {
            Uint8List aqpBytes = await File(aqpFile.path).readAsBytes();

            if (aqpBytes[233] == 0 && aqpBytes[234] == 0 && aqpBytes[235] == 0) {
              Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiEditingBoundaryRadiusValue);
              await Future.delayed(const Duration(milliseconds: 100));
              //-10
              aqpBytes[236] = 0;
              aqpBytes[237] = 0;
              aqpBytes[238] = 32;
              aqpBytes[239] = 193;
              aqpFile.writeAsBytesSync(Uint8List.fromList(aqpBytes));
              Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiPackingFiles);
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
              Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus(curLangText!.uiReplacingModFiles);
              await Future.delayed(const Duration(milliseconds: 100));
              try {
                File renamedFile = await File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(aqpFile.parent.path).replaceAll('_ext', '')).toFilePath());
                if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(hqIcePath)) {
                  await renamedFile.copy(hqIcePath);
                } else if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(lqIcePath)) {
                  await renamedFile.copy(lqIcePath);
                }
                aqmInjectedFiles.add(p.basenameWithoutExtension(file.path));
              } catch (e) {
                Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${e.toString()}');
              }
            }
          }
        }
      }
    }

    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiSuccess}\n${aqmInjectedFiles.join('\n')}');
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  } else {
    Provider.of<StateProvider>(context, listen: false).setAqmInjectionProgressStatus('${curLangText!.uiError}\n${curLangText!.uiNoMatchingFileFound}');
    await Future.delayed(const Duration(milliseconds: 100));
    return false;
  }
}
