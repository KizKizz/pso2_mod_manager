import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<File> originalIceDownload(String networkFilePath, String saveDirLocation, Signal status) async {
  if (networkFilePath.isNotEmpty) {
    final serverURLs = [segaMasterServerURL, segaPatchServerURL, segaMasterServerBackupURL, segaPatchServerBackupURL];
    for (var url in serverURLs) {
      final task = DownloadTask(
          url: '$url$networkFilePath',
          filename: p.basenameWithoutExtension(networkFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          directory: saveDirLocation,
          updates: Updates.statusAndProgress,
          allowPause: false);

      final result = await FileDownloader().download(task,
          onProgress: (progress) => status.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

      switch (result.status) {
        case TaskStatus.complete:
          modAqmInjectingStatus.value = appText.fileDownloadSuccessful;
          return File(saveDirLocation + p.separator + p.basenameWithoutExtension(networkFilePath));
        default:
          modAqmInjectingStatus.value = appText.fileDownloadFailed;
      }
    }
  }

  return File('');
}