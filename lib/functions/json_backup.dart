import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:path/path.dart' as p;

Future<void> jsonAutoBackup() async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy').format(now);

  Directory newBackupDir = Directory(Uri.file('$modManJsonAutoSaveDir/$formattedDate').toFilePath());
  if (Directory(modManJsonAutoSaveDir).existsSync() && Directory(modManJsonAutoSaveDir).listSync().whereType<File>().where((element) => p.basename(element.path) == '$formattedDate.zip').isEmpty) {
    await newBackupDir.create(recursive: true);
    if (newBackupDir.existsSync()) {
      //delete oldest of 7
      List<File> backupFiles = Directory(modManJsonAutoSaveDir).listSync().whereType<File>().where((element) => p.extension(element.path) == '.zip').toList();
      // ..sort((l, r) => r.statSync().modified.compareTo(l.statSync().modified));
      if (backupFiles.length >= 7) {
        try {
          backupFiles.last.deleteSync();
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      //create new backup
      try {
        //profile1
        if (File(Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManModsList.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManSetsList.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManVitalGaugeList.json').toFilePath());
        }
        //profile2
        if (File(Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManModsList_profile2.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManSetsList_profile2.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManVitalGaugeList_profile2.json').toFilePath());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      var encoder = ZipFileEncoder();
      await encoder.zipDirectoryAsync(newBackupDir);
      newBackupDir.deleteSync(recursive: true);
    }
  }
}

Future<void> jsonManualBackup() async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);

  Directory newBackupDir = Directory(Uri.file('$modManJsonManualSaveDir/$formattedDate').toFilePath());
  if (Directory(modManJsonManualSaveDir).existsSync() && Directory(modManJsonManualSaveDir).listSync().whereType<File>().where((element) => p.basename(element.path) == '$formattedDate.zip').isEmpty) {
    await newBackupDir.create(recursive: true);
    if (newBackupDir.existsSync()) {
      //create new backup
      try {
        //profile1
        if (File(Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManModsList.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManSetsList.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManVitalGaugeList.json').toFilePath());
        }
        //profile2
        if (File(Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManModsList_profile2.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManSetsList_profile2.json').toFilePath());
        }
        if (File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath()).existsSync()) {
          await File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath()).copy(Uri.file('${newBackupDir.path}/PSO2ModManVitalGaugeList_profile2.json').toFilePath());
        }
      } catch (e) {
        debugPrint(e.toString());
      }
      var encoder = ZipFileEncoder();
      await encoder.zipDirectoryAsync(newBackupDir);
      newBackupDir.deleteSync(recursive: true);
    }
  }
}
