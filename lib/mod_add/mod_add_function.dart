import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_grid.dart';

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

Future<List<AddingMod>> modAddSort() async {
  // Check for duplicates
  for (var dir in Directory(modAddTempUnpackedDirPath).listSync().whereType<Directory>()) {
    String sortedPath = dir.path.replaceFirst(modAddTempUnpackedDirPath, modAddTempSortedDirPath);
    if (Directory(sortedPath).existsSync()) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
      await io.copyPath(dir.path, '${sortedPath}_$formattedDate');
    } else {
      await io.copyPath(dir.path, sortedPath);
    }
  }
  await Directory(modAddTempUnpackedDirPath).delete(recursive: true);

  // Remove reboots
  for (var modDir in Directory(modAddTempSortedDirPath).listSync(recursive: true).whereType<Directory>().toSet()) {
    if (modDir.listSync().whereType<Directory>().isEmpty) {
      String newPath = await removeRebootPath(modDir.path);
      await io.copyPath(modDir.path, newPath.replaceFirst(modAddTempUnpackedDirPath, modAddTempSortedDirPath));
      await modDir.delete(recursive: true);
    } 
    // else {
    //   for (var file in modDir.listSync().whereType<File>()) {
    //     await Directory(file.parent.path.replaceFirst(modAddTempUnpackedDirPath, modAddTempSortedDirPath)).create(recursive: true);
    //     await file.copy(file.path.replaceFirst(modAddTempUnpackedDirPath, modAddTempSortedDirPath));
    //   }
    // }
  }

  List<AddingMod> addingModList = [];
  List<Directory> modDirs = Directory(modAddTempSortedDirPath).listSync().whereType<Directory>().toList();

  // Get files tree
  for (var modDir in modDirs) {
    List<Directory> submods = [];
    List<String> submodNames = [];
    List<ItemData> associatedItems = [];
    List<File> previewImages = [];
    List<File> previewVideos = [];
    // mod dir
    List<File> modDirFiles = modDir.listSync().whereType<File>().toList();
    if (modDirFiles.isNotEmpty && modDirFiles.indexWhere((e) => p.extension(e.path) == '') != -1) {
      submods.add(modDir);
      submodNames.add(p.basename(modDir.path));
      associatedItems.addAll(await matchItemData(associatedItems, modDirFiles.map((e) => e.path).toList()));
      previewImages.addAll(modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
      previewVideos.addAll(modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
    }
    // sub dirs
    for (var subdir in modDir.listSync(recursive: true).whereType<Directory>().toSet()) {
      List<File> files = subdir.listSync(recursive: true).whereType<File>().toList();
      if (files.isNotEmpty && files.indexWhere((e) => p.extension(e.path) == '') != -1) {
        submods.add(subdir);
        submodNames.add(subdir.path.replaceFirst(modDir.path + p.separator, '').trim().replaceAll(p.separator, ' > '));
        associatedItems.addAll(await matchItemData(associatedItems, files.map((e) => e.path).toList()));
        previewImages.addAll(files.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
        previewVideos.addAll(files.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
      }
    }

    addingModList.add(AddingMod(
        modDir, true, submods, submodNames, List.generate(submods.length, (int i) => true), associatedItems, List.generate(associatedItems.length, (int i) => true), previewImages, previewVideos));
  }

  return addingModList;
}

modAddToMasterList() {
  
}

// Helpers
Future<List<ItemData>> matchItemData(List<ItemData> matchedItemData, List<String> filePaths) async {
  List<ItemData> associatedItems = [];

  for (var filePath in filePaths.where((e) => p.extension(e) == '')) {
    modAddProcessingStatus.value = p.basename(filePath).toString();
    await Future.delayed(const Duration(microseconds: 10));

    if (matchedItemData.where((e) => e.containsIce(p.basename(filePath))).isNotEmpty || associatedItems.where((e) => e.containsIce(p.basename(filePath))).isNotEmpty) {
      continue;
    } else {
      for (var itemData in pItemData) {
        if (itemData.getName().isNotEmpty &&
            itemData.containsIce(p.basename(filePath)) &&
            matchedItemData.indexWhere((e) => e.getName() == itemData.getName()) == -1 &&
            associatedItems.indexWhere((e) => e.getName() == itemData.getName()) == -1) {
          associatedItems.add(itemData);
        }
      }
    }
  }

  return associatedItems;
}

Future<String> removeRebootPath(String dirPath) async {
  if (dirPath.isEmpty) return dirPath;

  String oFilePath = '';
  for (var file in Directory(dirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '')) {
    oFilePath = oItemData
        .firstWhere(
          (e) => p.basenameWithoutExtension(e.path) == p.basename(file.path),
          orElse: () => OfficialIceFile('', '', 0, ''),
        )
        .path;
    if (oFilePath.isNotEmpty) {
      String newPath = '';
      final oFilePathDetails = p.dirname(oFilePath).split('/');
      List<String> filePathDetails = dirPath.split(p.separator);
      filePathDetails.removeWhere((e) => oFilePathDetails.contains(e));
      newPath = p.joinAll(filePathDetails);
      if (Platform.isLinux) newPath = p.separator + newPath;
      return newPath;
    }
  }

  return dirPath;
}

Future<AddingMod> modAddRenameRefresh(Directory modDir, AddingMod currentAddingMod) async {
  List<Directory> submods = [];
  List<String> submodNames = [];
  List<File> previewImages = [];
  List<File> previewVideos = [];
  // mod dir
  List<File> modDirFiles = modDir.listSync().whereType<File>().toList();
  if (modDirFiles.isNotEmpty && modDirFiles.indexWhere((e) => p.extension(e.path) == '') != -1) {
    submods.add(modDir);
    submodNames.add(p.basename(modDir.path));
    previewImages.addAll(modDirFiles.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
    previewVideos.addAll(modDirFiles.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
  }
  // sub dirs
  for (var subdir in modDir.listSync(recursive: true).whereType<Directory>().toSet()) {
    List<File> files = subdir.listSync(recursive: true).whereType<File>().toList();
    if (files.isNotEmpty && files.indexWhere((e) => p.extension(e.path) == '') != -1) {
      submods.add(subdir);
      submodNames.add(subdir.path.replaceFirst(modDir.path + p.separator, '').trim().replaceAll(p.separator, ' > '));
      previewImages.addAll(files.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png'));
      previewVideos.addAll(files.where((e) => p.extension(e.path) == '.webm' || p.extension(e.path) == '.mp4'));
    }
  }

  return AddingMod(modDir, true, submods, submodNames, currentAddingMod.submodAddingStates, currentAddingMod.associatedItems, currentAddingMod.aItemAddingStates, previewImages, previewVideos);
}
