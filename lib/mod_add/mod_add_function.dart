import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;
import 'package:pso2_mod_manager/app_paths/main_paths.dart';

String modAddTempUnpackedDirPath = '$modAddTempUnpackedDirPath${p.separator}unpacked';

Future<void> modAddUnpack(List<String> addedPaths) async {
  for (var path in addedPaths) {
    String unpackedDirPath = modAddTempUnpackedDirPath + p.separator + p.basenameWithoutExtension(path);
    if (true) {
      if (p.extension(path) == '.zip') {
        await extractFileToDisk(path, unpackedDirPath);
      } else if (p.extension(path) == '.rar') {
        if (Platform.isLinux) {
          Directory(unpackedDirPath).createSync(recursive: true);
          await Process.run('unrar', ['e', path, (unpackedDirPath)]);
        } else {
          await Process.run(sevenZipExePath, ['x', path, '-o$unpackedDirPath', '-r']);
        }
      } else if (p.extension(path) == '.7z') {
        await Process.run(sevenZipExePath, ['x', path, '-o$unpackedDirPath', '-r']);
      } else {
        String tempParentDirPath = modAddTempUnpackedDirPath + p.separator + p.basenameWithoutExtension(p.dirname(path));
        if (Directory(modAddTempUnpackedDirPath).existsSync() && Directory(tempParentDirPath).existsSync()) {
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
          tempParentDirPath += '_$formattedDate';
        }
        Directory(tempParentDirPath).createSync(recursive: true);
        if (File(path).existsSync()) await File(path).copy(tempParentDirPath + p.separator + p.basename(path));
      }
    } else if (FileSystemEntity.isDirectorySync(path)) {
      if (Directory(modAddTempUnpackedDirPath).existsSync() && Directory(unpackedDirPath).existsSync()) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
        await io.copyPath(path, '${unpackedDirPath}_$formattedDate');
      } else {
        await io.copyPath(path, unpackedDirPath);
      }
    }
  }
}
