import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';

String modAddTempUnpackedDirPath = '$modAddTempDirPath${p.separator}unpacked';
String modAddTempSortedDirPath = '$modAddTempDirPath${p.separator}sorted';


Future<void> modAddUnpack(List<String> addedPaths) async {
  for (var path in addedPaths) {
    String unpackedDirPath = modAddTempUnpackedDirPath + p.separator + p.basenameWithoutExtension(path);
    if (await FileSystemEntity.isFile(path)) {
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

List<AddingMod> modAddSort() {
  List<AddingMod> addingModList = [];
  List<Directory> modDirs = Directory(modAddTempUnpackedDirPath).listSync().whereType<Directory>().toList();
  List<File> previewImages = [];
  List<File> previewVideos = [];
  // Get files tree
  for (var modDir in modDirs) {
    Map<Directory, List<File>> submods = {};
    List<ItemData> associatedItems = [];
    // mod dir
    List<File> modDirFiles = modDir.listSync().whereType<File>().toList();
    if (modDirFiles.isNotEmpty) {
      submods.addEntries({modDir: modDirFiles}.entries);
      associatedItems.addAll(pItemData.where((e) => !associatedItems.contains(e) && e.containsIceFiles(modDirFiles.where((f) => p.extension(f.path) == '').map((f) => p.basename(f.path)).toList())));
      previewImages.addAll(modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
      previewVideos.addAll(modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
    }
    // sub dirs
    for (var subdir in modDir.listSync().whereType<Directory>()) {
      List<File> files = subdir.listSync(recursive: true).whereType<File>().toList();
      if (files.isNotEmpty) {
        submods.addEntries({subdir: files}.entries);
        associatedItems.addAll(pItemData.where((e) => !associatedItems.contains(e) && e.containsIceFiles(files.where((f) => p.extension(f.path) == '').map((f) => p.basename(f.path)).toList())));
        previewImages.addAll(files.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
        previewVideos.addAll(files.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
      }
    }

    addingModList.add(AddingMod(modDir, submods, associatedItems, previewImages, previewVideos));
  }

  return addingModList;
}
