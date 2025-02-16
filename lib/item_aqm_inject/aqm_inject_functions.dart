import 'dart:convert';
import 'dart:io';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/v3_functions/modified_ice_file_save.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bounding_radius_popup.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Signal<String> modAqmInjectingStatus = Signal('');
Signal<String> modAqmInjectingRefresh = Signal('');

Future<List<AqmInjectedItem>> aqmInjectedItemsFetch() async {
  List<AqmInjectedItem> structureFromJson = [];
  masterUnappliedAQMItemList = [];

  //Load list from json
  String dataFromJson = await File(mainAqmInjectListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      AqmInjectedItem newAqmItem = AqmInjectedItem.fromJson(item);
      newAqmItem.injectedHqIceMd5 ??= '';
      newAqmItem.injectedLqIceMd5 ??= '';
      newAqmItem.injectedAQMFilePath ??= '';

      if (newAqmItem.isBoundingRemoved == null) {
        if (newAqmItem.isApplied) {
          newAqmItem.isBoundingRemoved ??= true;
        } else {
          newAqmItem.isBoundingRemoved ??= false;
        }
      }
      if (newAqmItem.isAqmReplaced == null) {
        if (newAqmItem.isApplied) {
          newAqmItem.isAqmReplaced ??= true;
        } else {
          newAqmItem.isAqmReplaced ??= false;
        }
      }
      newAqmItem.hqIcePath = newAqmItem.hqIcePath.replaceFirst(pso2binDirPath + p.separator, '').replaceAll(p.separator, '/');
      newAqmItem.lqIcePath = newAqmItem.lqIcePath.replaceFirst(pso2binDirPath + p.separator, '').replaceAll(p.separator, '/');
      newAqmItem.iconIcePath = newAqmItem.iconIcePath.replaceFirst(pso2binDirPath + p.separator, '').replaceAll(p.separator, '/');
      structureFromJson.add(newAqmItem);

      // Check unapplied
      bool checked = false;
      String appliedHQIceMd5 = await File(pso2binDirPath + p.separator + newAqmItem.hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
      if (appliedHQIceMd5 != newAqmItem.injectedHqIceMd5) {
        if (!masterUnappliedAQMItemList.contains(newAqmItem)) masterUnappliedAQMItemList.add(newAqmItem);
        checked = true;
      }
      if (!checked) {
        String appliedLQIceMd5 = await File(pso2binDirPath + p.separator + newAqmItem.lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
        if (appliedLQIceMd5 != newAqmItem.injectedLqIceMd5) {
          if (!masterUnappliedAQMItemList.contains(newAqmItem)) masterUnappliedAQMItemList.add(newAqmItem);
          checked = true;
        }
      }
    }
  }

  return structureFromJson;
}

Future<bool> itemCustomAqmInject(context, String customAQMFilePath, String hqIcePath, String lqIcePath, bool fromSubmod) async {
  Directory(modAqmInjectTempDirPath).createSync(recursive: true);
  List<String> aqmInjectedFiles = [];
  int packRetries = 0;

  List<File> downloadedFiles = [];
  modAqmInjectingStatus.value = appText.fetchingFiles;
  await Future.delayed(const Duration(milliseconds: 10));
  File localHQIce = File('');
  File localLQIce = File('');

  if (fromSubmod) {
    localHQIce = File(hqIcePath);
    localLQIce = File(lqIcePath);
    if (localHQIce.existsSync()) {
      downloadedFiles.add(localHQIce);
    }
    if (localLQIce.existsSync()) {
      downloadedFiles.add(localLQIce);
    }
  } else {
    localHQIce = File(pso2binDirPath + p.separator + hqIcePath.replaceAll('/', p.separator));
    if (localHQIce.existsSync()) {
      File copiedFile = await localHQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(hqIcePath));
      downloadedFiles.add(copiedFile);
    } else {
      File dlFile = await originalIceDownload('$hqIcePath.pat', modAqmInjectTempDirPath, modAqmInjectingStatus);
      downloadedFiles.add(dlFile);
    }
    localLQIce = File(pso2binDirPath + p.separator + lqIcePath.replaceAll('/', p.separator));
    if (localLQIce.existsSync()) {
      File copiedFile = await localLQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(lqIcePath));
      downloadedFiles.add(copiedFile);
    } else {
      File dlFile = await originalIceDownload('$lqIcePath.pat', modAqmInjectTempDirPath, modAqmInjectingStatus);
      downloadedFiles.add(dlFile);
    }
  }

  if (downloadedFiles.isNotEmpty) {
    modAqmInjectingStatus.value = appText.matchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    for (var file in downloadedFiles) {
      modAqmInjectingStatus.value = appText.dText(appText.extractingFile, p.basename(file.path));
      await Future.delayed(const Duration(milliseconds: 10));
      //extract files
      await Process.run('$zamboniExePath -outdir "$modAqmInjectTempDirPath"', [file.path]);
      String extractedGroup2Path = Uri.file('$modAqmInjectTempDirPath/${p.basenameWithoutExtension(file.path)}_ext/group2').toFilePath();
      if (Directory(extractedGroup2Path).existsSync()) {
        //get id from aqp file
        modAqmInjectingStatus.value = appText.dText(appText.editingMod, p.basename(file.path));
        await Future.delayed(const Duration(milliseconds: 10));
        if (file.existsSync()) file.deleteSync();
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
        final copiedFile = File(customAQMFilePath).copySync(Uri.file('$extractedGroup2Path/pl_rbd_${id}_bw_sa${p.extension(customAQMFilePath)}').toFilePath());
        if (copiedFile.existsSync() && id > -1) {
          modAqmInjectingStatus.value = appText.dText(appText.repackingFile, p.basename(file.path));
          await Future.delayed(const Duration(milliseconds: 10));
          //pack
          while (!File(Uri.file('${p.dirname(copiedFile.parent.path)}.ice').toFilePath()).existsSync()) {
            await Process.run('$zamboniExePath -c -pack -outdir "${p.dirname(copiedFile.parent.path)}"', [Uri.file(p.dirname(copiedFile.parent.path)).toFilePath()]);
            packRetries++;
            // debugPrint(packRetries.toString());
            if (packRetries == 5) {
              break;
            }
          }
          packRetries = 0;

          modAqmInjectingStatus.value = appText.dText(appText.applyingMod, p.basename(file.path));
          await Future.delayed(const Duration(milliseconds: 10));
          try {
            File renamedFile = await File(Uri.file('${p.dirname(copiedFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(copiedFile.parent.path).replaceAll('_ext', '')).toFilePath());
            if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(hqIcePath)) {
              await renamedFile.copy(localHQIce.path);
            } else if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(lqIcePath)) {
              await renamedFile.copy(localLQIce.path);
            }
            // Add to modifiedFileList
            modifiedIceAdd(p.basenameWithoutExtension(renamedFile.path));
            aqmInjectedFiles.add('${p.basename(copiedFile.path)} -> ${p.basenameWithoutExtension(file.path)}');
          } catch (e) {
            modAqmInjectingStatus.value = e.toString();
          }
        } else {
          modAqmInjectingStatus.value = appText.noMatchingFilesFound;
          await Future.delayed(const Duration(milliseconds: 10));
        }
      } else {
        modAqmInjectingStatus.value = appText.noMatchingFilesFound;
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }

    modAqmInjectingStatus.value = appText.successful;
    await Future.delayed(const Duration(milliseconds: 10));
    return true;
  } else {
    modAqmInjectingStatus.value = appText.noMatchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    return false;
  }
}

Future<bool> itemCustomAqmBounding(context, String hqIcePath, String lqIcePath, String itemName) async {
  ModFile hqModFile = ModFile(p.basename(hqIcePath), itemName, itemName, itemName, '', '', [], pso2binDirPath + p.separator + hqIcePath.replaceAll('/', p.separator), false, DateTime(0), 0, false,
      false, false, [], [], [], [], [], []);
  ModFile lqModFile = ModFile(p.basename(lqIcePath), itemName, itemName, itemName, '', '', [], pso2binDirPath + p.separator + lqIcePath.replaceAll('/', p.separator), false, DateTime(0), 0, false,
      false, false, [], [], [], [], [], []);
  SubMod submod = SubMod(itemName, itemName, itemName, '', '', false, DateTime(0), 0, false, false, false, [], false, false, 0, 0, '', [], [], [], [], [], [hqModFile, lqModFile]);
  await boundingRadiusPopup(context, submod);
  return true;
}

Future<bool> itemCustomAqmRestoreAll(String hqIcePath, String lqIcePath) async {
  List<bool> restoredCheck = [false, false];
  final filePaths = [hqIcePath, lqIcePath];
  for (var filePath in filePaths) {
    if (filePath.isNotEmpty) {
      modAqmInjectingStatus.value = appText.dText(appText.restoringFile, p.basename(filePath));
      File downloadedFile = await originalIceDownload('$filePath.pat', pso2binDirPath + p.separator + p.dirname(filePath.replaceAll('/', p.separator)), modAqmInjectingStatus);
      if (downloadedFile.existsSync()) restoredCheck[filePaths.indexOf(filePath)] = true;
    }
  }

  if (restoredCheck.where((e) => !e).isEmpty) {
    modAqmInjectingStatus.value = appText.success;
    return true;
  } else {
    modAqmInjectingStatus.value = appText.failed;
    return false;
  }
}

Future<bool> itemCustomAqmRestoreAqm(String hqIcePath, String lqIcePath, bool fromSubmod) async {
  Directory(modAqmInjectTempDirPath).createSync(recursive: true);
  int packRetries = 0;
  List<File> filesToRemove = [];
  modAqmInjectingStatus.value = appText.fetchingFiles;
  await Future.delayed(const Duration(milliseconds: 10));

  File localHQIce = File('');
  File localLQIce = File('');

  if (fromSubmod) {
    localHQIce = File(hqIcePath);
    localLQIce = File(lqIcePath);
    if (localHQIce.existsSync()) {
      filesToRemove.add(localHQIce);
    }
    if (localLQIce.existsSync()) {
      filesToRemove.add(localLQIce);
    }
  } else {
    localHQIce = File(pso2binDirPath + p.separator + hqIcePath.replaceAll('/', p.separator));
    if (localHQIce.existsSync()) {
      File copiedFile = await localHQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(hqIcePath));
      filesToRemove.add(copiedFile);
    }
    localLQIce = File(pso2binDirPath + p.separator + lqIcePath.replaceAll('/', p.separator));
    if (localLQIce.existsSync()) {
      File copiedFile = await localLQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(lqIcePath));
      filesToRemove.add(copiedFile);
    }
  }

  if (filesToRemove.isNotEmpty) {
    modAqmInjectingStatus.value = appText.matchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    for (var file in filesToRemove) {
      modAqmInjectingStatus.value = appText.dText(appText.extractingFile, p.basename(file.path));
      await Future.delayed(const Duration(milliseconds: 10));
      //extract files
      await Process.run('$zamboniExePath -outdir "$modAqmInjectTempDirPath"', [file.path]);
      String extractedGroup2Path = Uri.file('$modAqmInjectTempDirPath/${p.basenameWithoutExtension(file.path)}_ext/group2').toFilePath();
      if (Directory(extractedGroup2Path).existsSync()) {
        //get id from aqp file
        modAqmInjectingStatus.value = appText.dText(appText.editingMod, p.basename(file.path));
        await Future.delayed(const Duration(milliseconds: 10));
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
        final customAqmFile = File(Uri.file('$extractedGroup2Path/pl_rbd_${id}_bw_sa.aqm').toFilePath());
        if (customAqmFile.existsSync()) {
          await customAqmFile.delete();
          modAqmInjectingStatus.value = appText.dText(appText.repackingFile, p.basename(file.path));
          await Future.delayed(const Duration(milliseconds: 10));
          //pack
          while (!File(Uri.file('${p.dirname(customAqmFile.parent.path)}.ice').toFilePath()).existsSync()) {
            await Process.run('$zamboniExePath -c -pack -outdir "${p.dirname(customAqmFile.parent.path)}"', [Uri.file(p.dirname(customAqmFile.parent.path)).toFilePath()]);
            packRetries++;
            // debugPrint(packRetries.toString());
            if (packRetries == 10) {
              break;
            }
          }
          packRetries = 0;

          modAqmInjectingStatus.value = appText.dText(appText.applyingMod, p.basename(file.path));
          await Future.delayed(const Duration(milliseconds: 10));
          try {
            File renamedFile =
                await File(Uri.file('${p.dirname(customAqmFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(customAqmFile.parent.path).replaceAll('_ext', '')).toFilePath());
            if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(hqIcePath)) {
              await renamedFile.copy(localHQIce.path);
            } else if (p.basenameWithoutExtension(file.path) == p.basenameWithoutExtension(lqIcePath)) {
              await renamedFile.copy(localLQIce.path);
            }
          } catch (e) {
            modAqmInjectingStatus.value = e.toString();
          }
        } else {
          modAqmInjectingStatus.value = appText.noMatchingFilesFound;
          await Future.delayed(const Duration(milliseconds: 10));
        }
      } else {
        modAqmInjectingStatus.value = appText.noMatchingFilesFound;
        await Future.delayed(const Duration(milliseconds: 10));
      }
      // String extractedGroup1Path = Uri.file('$modAqmInjectTempDirPath/${modFile.modFileName}_ext/group1').toFilePath();
      // if (Directory(extractedGroup1Path).existsSync()) {}
    }
    modAqmInjectingStatus.value = appText.successful;
    await Future.delayed(const Duration(milliseconds: 10));
    return true;
  } else {
    modAqmInjectingStatus.value = appText.noMatchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    return false;
  }
}

Future<bool> itemCustomAqmRestoreBounding(context, String customAQMFilePath, String hqIcePath, String lqIcePath, bool aqmInjected) async {
  bool restoreAllResult = await itemCustomAqmRestoreAll(hqIcePath, lqIcePath);
  if (restoreAllResult && aqmInjected) {
    bool result = await itemCustomAqmInject(context, customAQMFilePath, hqIcePath, lqIcePath, false);
    if (result) {
      modAqmInjectingStatus.value = appText.success;
      return true;
    } else {
      modAqmInjectingStatus.value = appText.failed;
      return false;
    }
  } else {
    return restoreAllResult ? true : false;
  }
}

void saveMasterAqmInjectListToJson() {
  //Save to json
  masterAqmInjectedItemList.map((item) => item.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainAqmInjectListJsonPath).writeAsStringSync(encoder.convert(masterAqmInjectedItemList));
}
