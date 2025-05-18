import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:path/path.dart' as p;

Future<void> jsonAutoBackup() async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy').format(now);
  Directory autoSaveDir = Directory(jsonBackupDirPath);
  autoSaveDir.createSync(recursive: true);

  Directory newBackupDir = Directory(Uri.file('${autoSaveDir.path}/$formattedDate').toFilePath());
  if (autoSaveDir.existsSync() && autoSaveDir.listSync().whereType<File>().where((element) => p.basename(element.path) == '$formattedDate.zip').isEmpty) {
    await newBackupDir.create(recursive: true);
    if (newBackupDir.existsSync()) {
      //delete oldest of 7
      List<File> backupFiles = autoSaveDir.listSync().whereType<File>().where((element) => p.extension(element.path) == '.zip').toList()
        ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
      if (backupFiles.length >= 7) {
        try {
          backupFiles.last.deleteSync();
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      await createNewBackupFile(newBackupDir);
    }
  }
}

Future<void> jsonManualBackup() async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
  Directory manualSaveDir = Directory(jsonBackupDirPath);
  manualSaveDir.createSync(recursive: true);

  Directory newBackupDir = Directory(Uri.file('${manualSaveDir.path}/$formattedDate').toFilePath());
  if (manualSaveDir.existsSync() && manualSaveDir.listSync().whereType<File>().where((element) => p.basename(element.path) == '$formattedDate.zip').isEmpty) {
    await newBackupDir.create(recursive: true);
    if (newBackupDir.existsSync()) {
      //create new backup
      await createNewBackupFile(newBackupDir);
    }
  }
}

Future<void> createNewBackupFile(Directory newBackupDir) async {
  //create new backup
  try {
    List<File> jsonFiles = [
      File('$mainDataDirPath${p.separator}PSO2ModManModsList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManSetsList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManAqmInjectedList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManVitalGaugeList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManLSCardList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManLSBoardList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManLSSleeveList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManQuickSwapApplyItemList.json'),
      File('$mainDataDirPath${p.separator}PSO2ModManCmlItemList.json')
    ];

    // Profile 1
    for (var file in jsonFiles) {
      if (file.existsSync()) {
        await file.copy(newBackupDir.path + p.separator + p.basename(file.path));
      }
    }

    // Profile 2
    for (var file in jsonFiles) {
      File profile2Json = File('${p.withoutExtension(file.path)}_profile2${p.extension(file.path)}');
      if (profile2Json.existsSync()) {
        await profile2Json.copy(newBackupDir.path + p.separator + p.basename(profile2Json.path));
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  var encoder = ZipFileEncoder();
  await encoder.zipDirectory(newBackupDir);
  newBackupDir.deleteSync(recursive: true);
}

String getLatestBackupDate() {
  Directory saveDir = Directory(jsonBackupDirPath);
  DateTime lastest = DateTime(0);
  List<File> savedFiles = saveDir.listSync().whereType<File>().where((e) => p.extension(e.path) == '.zip').toList();
  if (savedFiles.isNotEmpty) {
    savedFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    lastest = savedFiles.first.statSync().modified;
  }
  String formattedDate = DateFormat('MM-dd-yyyy kk:mm:ss').format(lastest);
  return formattedDate;
}
