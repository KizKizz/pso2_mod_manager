import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

Future<void> profanityRemove() async {
  File win32FilterFile = File('$pso2DataDirPath${p.separator}win32${p.separator}ffbff2ac5b7a7948961212cefd4d402c');
  File win32NAFilterFile = File('$pso2DataDirPath${p.separator}win32_na${p.separator}ffbff2ac5b7a7948961212cefd4d402c');
  if (removeProfanityFilter) {
    if (win32FilterFile.existsSync()) await win32FilterFile.delete();
    if (win32NAFilterFile.existsSync()) await win32NAFilterFile.delete();
  } else {
    if (!win32FilterFile.existsSync()) {
      // Future.delayed(const Duration(milliseconds: 50));
      String networkFilePath = oItemData.firstWhere((e) => e.path.contains(p.basenameWithoutExtension(win32FilterFile.path))).path;
      final serverURLs = [segaMasterServerURL, segaPatchServerURL, segaMasterServerBackupURL, segaPatchServerBackupURL];
      for (var url in serverURLs) {
        final task = DownloadTask(
            url: '$url$networkFilePath',
            filename: p.basenameWithoutExtension(networkFilePath),
            headers: {"User-Agent": "AQUA_HTTP"},
            baseDirectory: BaseDirectory.root,
            directory: p.dirname(win32FilterFile.path),
            updates: Updates.none,
            allowPause: false);

        final result = await FileDownloader().download(task);
        if (result.status == TaskStatus.complete) break;
      }
    }
    if (!win32NAFilterFile.existsSync() && Directory(p.dirname(win32NAFilterFile.path)).existsSync()) {
      final task = DownloadTask(
          url: 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/profanityFilterNA/ffbff2ac5b7a7948961212cefd4d402c',
          filename: p.basenameWithoutExtension(win32NAFilterFile.path),
          headers: {"User-Agent": "AQUA_HTTP"},
          baseDirectory: BaseDirectory.root,
          directory: p.dirname(win32NAFilterFile.path),
          updates: Updates.none,
          allowPause: false);

      await FileDownloader().download(task);
    }
  }
}
