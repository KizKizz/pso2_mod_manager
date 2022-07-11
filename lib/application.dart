import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/main.dart';

class ApplicationConfig {
  static List<String> currentVersionNums = appVersion.split('.');
}

Future<void> checkForUpdates() async {
  final jsonVal = await loadJsonFromGithub();
  debugPrint('Response: $jsonVal');
}

Future<Map<String, dynamic>> loadJsonFromGithub() async {
  final response = await http.read(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/blob/main/app_version_check/app_version.json'));
  return jsonDecode(response);
}
