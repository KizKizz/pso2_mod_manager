import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';

String newVersion = '';
String patchNotes = '';
List<String> patchNoteSplit = [];
int refSheetsNewVersion = -1;
String checksumFileLink = '';
String checksumFileName = '';
String checksumFileMD5 = '';

class ApplicationConfig {
  //App version Check
  static List<String> currentVersionValues = appVersion.split('.');

  Future<void> checkForUpdates(context) async {
    final jsonVal = await loadJsonFromGithub();
    if (jsonVal.entries.first.key != 'null') {
      String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
      List<String> newVersionValues = newVersionValue.split('.');
      int major = int.parse(newVersionValues[0]);
      int minor = int.parse(newVersionValues[1]);
      int patch = int.parse(newVersionValues[2]);
      if (major > int.parse(currentVersionValues[0]) || minor > int.parse(currentVersionValues[1]) || patch > int.parse(currentVersionValues[2])) {
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
    int timeout = 10;
    try {
      http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/app_version.json')).timeout(Duration(seconds: timeout));
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
    final jsonVal = await loadRefSheetsJsonFromGithub();
    if (jsonVal.entries.first.key != 'null') {
      String newVersionValue = jsonVal.entries.firstWhere((element) => element.key == 'version').value;
      if (refSheetsVersion < int.parse(newVersionValue)) {
        refSheetsNewVersion = int.parse(newVersionValue);
        Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableTrue();
      }
    }
  }

  Future<Map<String, dynamic>> loadRefSheetsJsonFromGithub() async {
    String jsonResponse = '{"null": "null"}';
    int timeout = 5;
    try {
      http.Response response =
          await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/ref_sheets_version.json')).timeout(Duration(seconds: timeout));
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
    final jsonVal = await loadRefSheetsJsonFromGithub();
    if (jsonVal.entries.first.key != 'null') {
      checksumFileName = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileName').value;
      checksumFileLink = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileLink').value;
      checksumFileMD5 = jsonVal.entries.firstWhere((element) => element.key == 'checksumFileMD5').value;
    }
  }

  Future<Map<String, dynamic>> loadChecksumFileJsonFromGithub() async {
    String jsonResponse = '{"null": "null"}';
    int timeout = 5;
    try {
      http.Response response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/main/app_version_check/checksum_version.json')).timeout(Duration(seconds: timeout));
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
}
