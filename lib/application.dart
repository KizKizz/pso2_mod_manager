import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pso2_mod_manager/main.dart';

class ApplicationConfig {
  static List<String> currentVersionNums = appVersion.split('.');
}

Future<void> _checkForUpdates() async {
  final jsonVal = await loadJsonFromGithub();
  debugPrint('Response: $jsonVal');
  showUpdateNotif(jsonVal);
}

Future<Map<String, dynamic>> loadJsonFromGithub() async {
  final response = await
}
