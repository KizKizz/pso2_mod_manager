import 'dart:io';

import 'package:pso2_mod_manager/loaders/paths_loader.dart';

void clearAllTempDirs() {
  if (Directory(modManAddModsTempDirPath).existsSync()) {
    try {
      Directory(modManAddModsTempDirPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManAddModsTempDirPath)], runInShell: true);
    }
  }
  if (Directory(modManAddModsUnpackDirPath).existsSync()) {
    try {
      Directory(modManAddModsUnpackDirPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManAddModsUnpackDirPath)], runInShell: true);
    }
  }
  if (Directory(modManModsAdderPath).existsSync()) {
    try {
      Directory(modManModsAdderPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManModsAdderPath)], runInShell: true);
    }
  }
  if (Directory(modManSwapperDirPath).existsSync()) {
    try {
      Directory(modManSwapperDirPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManSwapperDirPath)], runInShell: true);
    }
  }
  if (Directory(modManTempCmxDirPath).existsSync()) {
    try {
      Directory(modManTempCmxDirPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManTempCmxDirPath)], runInShell: true);
    }
  }
  if (Directory(modManImportedDirPath).existsSync()) {
    try {
      Directory(modManImportedDirPath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (modManImportedDirPath)], runInShell: true);
    }
  }
}

Future<void> clearAllTempDirsBeforeGettingPath() async {
  if (await Directory(Uri.file('$modManDirPath/temp').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/temp').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/temp').toFilePath())], runInShell: true);
    }
  }
  if (await Directory(Uri.file('$modManDirPath/unpack').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/unpack').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/temp').toFilePath())], runInShell: true);
    }
  }
  if (await Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/modsAdder').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/modsAdder').toFilePath())], runInShell: true);
    }
  }
  if (await Directory(Uri.file('$modManDirPath/swapper').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/swapper').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/swapper').toFilePath())], runInShell: true);
    }
  }
  if (await Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/tempCmx').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/tempCmx').toFilePath())], runInShell: true);
    }
  }
  if (await Directory(Uri.file('$modManDirPath/exported').toFilePath()).exists()) {
    try {
      await Directory(Uri.file('$modManDirPath/exported').toFilePath()).delete(recursive: true);
    } catch (e) {
      await Process.run('cmd', ['rd', '/q', '/s', (Uri.file('$modManDirPath/exported').toFilePath())], runInShell: true);
    }
  }
}

void clearAppUpdateFolder() {
  String appUpdatePath = Uri.file('${Directory.current.path}/appUpdate').toFilePath();
  if (Directory(appUpdatePath).existsSync()) {
    try {
      Directory(appUpdatePath).deleteSync(recursive: true);
    } catch (e) {
      Process.runSync('cmd', ['rd', '/q', '/s', (Uri.file('${Directory.current.path}/appUpdate').toFilePath())], runInShell: true);
    }
  }
}
