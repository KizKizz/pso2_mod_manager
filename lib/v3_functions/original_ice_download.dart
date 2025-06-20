import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<File?> originalIceDownload(String iceFilePath, String saveDirLocation, Signal status) async {
  if (iceFilePath.isNotEmpty) {
    final serverURLs = [segaPatchServerURL, segaMasterServerURL, segaPatchServerBackupURL, segaMasterServerBackupURL];
    int index = oItemData.indexWhere((e) => e.path.contains(p.basenameWithoutExtension(iceFilePath)));
    if (index != -1) {
      final matchedFile = oItemData[index];
      if (matchedFile.server.isNotEmpty) {
        final serverIndex = matchedFile.server == 'm' ? 1 : 0;
        final task = DownloadTask(
          url: '${serverURLs[serverIndex]}${matchedFile.path}',
          filename: p.basenameWithoutExtension(iceFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          baseDirectory: BaseDirectory.root,
          directory: saveDirLocation,
          updates: Updates.statusAndProgress,
          allowPause: false,
        );

        final result = await FileDownloader()
            .download(task, onProgress: (progress) => status.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(iceFilePath))} [ ${(progress * 100).round()}% ]');

        switch (result.status) {
          case TaskStatus.complete:
            status.value = appText.fileDownloadSuccessful;
            return File(saveDirLocation + p.separator + p.basenameWithoutExtension(iceFilePath));
          default:
            status.value = appText.fileDownloadFailed;
        }
      } else {
        for (var url in serverURLs) {
          final task = DownloadTask(
            url: '$url${matchedFile.path}',
            filename: p.basenameWithoutExtension(iceFilePath),
            headers: {"User-Agent": "AQUA_HTTP"},
            baseDirectory: BaseDirectory.root,
            directory: saveDirLocation,
            updates: Updates.statusAndProgress,
            allowPause: false,
          );

          final result = await FileDownloader()
              .download(task, onProgress: (progress) => status.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(iceFilePath))} [ ${(progress * 100).round()}% ]');

          switch (result.status) {
            case TaskStatus.complete:
              status.value = appText.fileDownloadSuccessful;
              return File(saveDirLocation + p.separator + p.basenameWithoutExtension(iceFilePath));
            default:
              status.value = appText.fileDownloadFailed;
          }
        }
      }
    }
  }

  return null;
}
