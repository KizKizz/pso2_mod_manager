import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<File?> originalIceDownload(String networkFilePath, String saveDirLocation, Signal status) async {
  if (networkFilePath.isNotEmpty) {
    final serverURLs = [segaPatchServerURL, segaMasterServerURL, segaPatchServerBackupURL, segaMasterServerBackupURL];
    for (var url in serverURLs) {
      final task = DownloadTask(
          url: '$url$networkFilePath',
          filename: p.basenameWithoutExtension(networkFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          baseDirectory: BaseDirectory.root,
          directory: saveDirLocation,
          updates: Updates.statusAndProgress,
          allowPause: false,
          );

      final result = await FileDownloader()
          .download(task, onProgress: (progress) => status.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

      switch (result.status) {
        case TaskStatus.complete:
          status.value = appText.fileDownloadSuccessful;
          return File(saveDirLocation + p.separator + p.basenameWithoutExtension(networkFilePath));          
        default:
          status.value = appText.fileDownloadFailed;
      }
    }
  }

  return null;
}
