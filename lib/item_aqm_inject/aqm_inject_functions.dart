import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Signal<String> modAqmInjectingStatus = Signal('');
Signal<bool> modAqmInjectedrefresh = Signal(false);

Future<List<AqmInjectedItem>> aqmInjectedItemsFetch() async {
  List<AqmInjectedItem> structureFromJson = [];

  //Load list from json
  String dataFromJson = await File(mainAqmInjectListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      structureFromJson.add(AqmInjectedItem.fromJson(item));
    }
  }

  return structureFromJson;
}

Future<bool> itemCustomAqmInject(context, String hqIcePath, String lqIcePath) async {
  modAqmInjectingStatus.value = '';
  modAqmInjectedrefresh.value = false;
  Directory(modAqmInjectTempDirPath).createSync(recursive: true);
  List<String> aqmInjectedFiles = [];
  int packRetries = 0;

  List<File> downloadedFiles = [];
  modAqmInjectingStatus.value = appText.fetchingFiles;
  await Future.delayed(const Duration(milliseconds: 10));

  File localHQIce = File(pso2binDirPath + p.separator + hqIcePath.replaceAll('\\', '/'));
  if (localHQIce.existsSync()) {
    File copiedFile = await localHQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(hqIcePath));
    downloadedFiles.add(copiedFile);
  } else {
    File dlFile = await aqmInjectOriginalFileDownload('$hqIcePath.pat', 'm', modAqmInjectTempDirPath);
    downloadedFiles.add(dlFile);
  }
  File localLQIce = File(pso2binDirPath + p.separator + lqIcePath.replaceAll('\\', '/'));
  if (localLQIce.existsSync()) {
    File copiedFile = await localLQIce.copy(modAqmInjectTempDirPath + p.separator + p.basename(lqIcePath));
    downloadedFiles.add(copiedFile);
  } else {
    File dlFile = await aqmInjectOriginalFileDownload('$lqIcePath.pat', 'm', modAqmInjectTempDirPath);
    downloadedFiles.add(dlFile);
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
        final copiedFile = File(selectedCustomAQMFilePath.value).copySync(Uri.file('$extractedGroup2Path/pl_rbd_${id}_bw_sa${p.extension(selectedCustomAQMFilePath.value)}').toFilePath());
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
    await Directory(modAqmInjectTempDirPath).delete(recursive: true);
    return true;
  } else {
    modAqmInjectingStatus.value = appText.noMatchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    await Directory(modAqmInjectTempDirPath).delete(recursive: true);
    return false;
  }
}

Future<File> aqmInjectOriginalFileDownload(String networkFilePath, String server, String saveLocation) async {
  if (networkFilePath.isNotEmpty) {
    final serverURLs = [segaMasterServerURL, segaPatchServerURL, segaMasterServerBackupURL, segaPatchServerBackupURL];
    for (var url in serverURLs) {
      final task = DownloadTask(
          url: '$url$networkFilePath',
          filename: p.basenameWithoutExtension(networkFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          directory: saveLocation,
          updates: Updates.statusAndProgress,
          allowPause: false);

      final result = await FileDownloader().download(task,
          onProgress: (progress) => modAqmInjectingStatus.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

      switch (result.status) {
        case TaskStatus.complete:
          modAqmInjectingStatus.value = appText.fileDownloadSuccessful;
          return File(saveLocation + p.separator + p.basenameWithoutExtension(networkFilePath));
        default:
          modAqmInjectingStatus.value = appText.fileDownloadFailed;
      }
    }
  }

  return File('');
}
