import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

String newVersion = '';
String patchNotes = '';
List<String> patchNoteSplit = [];
int refSheetsNewVersion = -1;
String netChecksumFileLink = '';
String netChecksumFileName = '';
String netChecksumFileMD5 = '';

//App version Check
List<String> currentVersionValues = appVersion.split('.');
Future<void> checkForUpdates(context) async {
  final jsonVal = await loadJsonFromGithub();
  if (jsonVal.entries.first.key != 'null') {
    int curMajor = int.parse(currentVersionValues[0]);
    int curMinor = int.parse(currentVersionValues[1]);
    int curPatch = int.parse(currentVersionValues[2]);

    String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
    List<String> newVersionValues = newVersionValue.split('.');
    int newMajor = int.parse(newVersionValues[0]);
    int newMinor = int.parse(newVersionValues[1]);
    int newPatch = int.parse(newVersionValues[2]);

    if (newPatch > curPatch && newMinor >= curMinor && newMajor >= curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    } else if (newPatch <= curPatch && newMinor > curMinor && newMajor >= curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    } else if (newPatch <= curPatch && newMinor <= curMinor && newMajor > curMajor) {
      newVersion = newVersionValue;
      String tempPatchNote = jsonVal.entries.firstWhere((element) => element.key == 'description').value.toString();
      patchNotes = tempPatchNote.replaceFirst('[', '', 0).replaceFirst(']', '', patchNotes.length);
      patchNoteSplit = patchNotes.split(', ');
      //debugPrint('Response: ${patchNotes.first}');
      Provider.of<StateProvider>(context, listen: false).isUpdateAvailableTrue();
    }
  }
}

Future<Map<String, dynamic>> loadJsonFromGithub() async {
  String jsonResponse = '{"null": "null"}';
  try {
    http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/app_version.json'));
    if (response.statusCode == 200) {
      jsonResponse = await http.read(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/app_version.json'));
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }
  return jsonDecode(jsonResponse);
}

//Ref Sheets version check
Future<void> checkRefSheetsForUpdates(context) async {
  List<File> sheetFiles = [];
  int sheetFilesCount = 0;
  if (Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).existsSync()) {
    sheetFiles = Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.csv').toList();
    final sheetFileList = await File(modManRefSheetListFilePath).readAsLines();
    sheetFilesCount = sheetFileList.length;
  }
  if (sheetFiles.isEmpty || (sheetFilesCount > 0 && sheetFiles.length != sheetFilesCount)) {
    final jsonVal = await loadRefSheetsJsonFromGithub();
    if (jsonVal.entries.first.key != 'null') {
      String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
      refSheetsNewVersion = int.parse(newVersionValue);
    }
    Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableTrue();
    //auto download
    downloadNewRefSheets(context, File(modManRefSheetListFilePath)).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('refSheetsVersion', refSheetsNewVersion);
      //print('complete');
      Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableFalse();
      Provider.of<StateProvider>(context, listen: false).refSheetsCountReset();
    });
  } else {
    final jsonVal = await loadRefSheetsJsonFromGithub();
    if (jsonVal.entries.first.key != 'null') {
      String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
      if (refSheetsVersion < int.parse(newVersionValue) || modManRefSheetsLocalVersion < int.parse(newVersionValue)) {
        refSheetsNewVersion = int.parse(newVersionValue);
        Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableTrue();
      }
    }
  }
}

Future<Map<String, dynamic>> loadRefSheetsJsonFromGithub() async {
  String jsonResponse = '{"null": "null"}';
  try {
    http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/ref_sheets_version.json'));
    if (response.statusCode == 200) {
      jsonResponse = await http.read(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/ref_sheets_version.json'));
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }
  return jsonDecode(jsonResponse);
}

//Checksum File check
Future<void> checkChecksumFileForUpdates(context) async {
  final jsonVal = await loadChecksumFileJsonFromGithub();
  if (jsonVal.entries.first.key != 'null') {
    netChecksumFileName = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileName').value;
    netChecksumFileLink = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileLink').value;
    netChecksumFileMD5 = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileMD5').value;

    if (modManChecksumFilePath.isNotEmpty) {
      String? checksumMD5 = await getFileHash(modManChecksumFilePath);
      if (checksumMD5.toString() != netChecksumFileMD5) {
        Provider.of<StateProvider>(context, listen: false).checksumMD5MatchFalse();
      }
    }
  }
}

Future<Map<String, dynamic>> loadChecksumFileJsonFromGithub() async {
  String jsonResponse = '{"null": "null"}';
  try {
    http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/checksum_version.json'));
    if (response.statusCode == 200) {
      jsonResponse = await http.read(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/checksum_version.json'));
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }
  return jsonDecode(jsonResponse);
}

//Language
Future<void> checkLanguageTranslationForUpdates(List<TranslationLanguage> localLangList) async {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  var jsonData = await loadLanguageTranslationJsonFromGithub();
  for (var lang in jsonData) {
    TranslationLanguage gitLangInfo = TranslationLanguage.fromJson(lang);
    int localLangInfoIndex = localLangList.indexWhere((element) => element.langInitial == gitLangInfo.langInitial);
    if (localLangInfoIndex != -1) {
      TranslationLanguage localLangInfo = localLangList[localLangInfoIndex];
      if (localLangInfo.langInitial == gitLangInfo.langInitial && localLangInfo.revision < gitLangInfo.revision) {
        await Dio().download('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/Language/${gitLangInfo.langInitial}.json', Uri.file(localLangInfo.langFilePath).toFilePath());
        localLangInfo.revision = gitLangInfo.revision;
      } else if (localLangInfo.langInitial == gitLangInfo.langInitial && !File(Uri.file(localLangInfo.langFilePath).toFilePath()).existsSync()) {
        await Dio().download('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/Language/${gitLangInfo.langInitial}.json', Uri.file(localLangInfo.langFilePath).toFilePath());
        localLangInfo.revision = gitLangInfo.revision;
      }
    } else {
      String newLangFilePath = Uri.file('$modManLanguageDirPath/${gitLangInfo.langInitial}.json').toFilePath();
      await Dio().download('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/Language/${gitLangInfo.langInitial}.json', Uri.file(newLangFilePath).toFilePath());
      gitLangInfo.langFilePath = newLangFilePath;
      localLangList.add(gitLangInfo);
    }
  }
  File(Uri.file('$modManLanguageDirPath/LanguageSettings.json').toFilePath()).writeAsStringSync(encoder.convert(localLangList));
}

Future<dynamic> loadLanguageTranslationJsonFromGithub() async {
  String jsonResponse = '{"null": "null"}';
  try {
    http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/Language/LanguageSettings.json'));
    if (response.statusCode == 200) {
      jsonResponse = await http.read(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/Language/LanguageSettings.json'));
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }
  return jsonDecode(jsonResponse);
}
