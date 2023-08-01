import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<String>> getPatchServerList() async {
  String managenentLink = 'http://patch01.pso2gs.net/patch_prod/patches/management_beta.txt';
  List<String> patchList = [];

  String managementFileStream = '';
  try {
    http.Response response = await http.get(Uri.parse(managenentLink));
    if (response.statusCode == 200) {
      managementFileStream = await http.read(Uri.parse(managenentLink));
    }
  } on TimeoutException catch (e) {
    debugPrint('Timeout Error: $e');
  } on SocketException catch (e) {
    debugPrint('Socket Error: $e');
  } on Error catch (e) {
    debugPrint('General Error: $e');
  }

  List<String> managementFileLines = managementFileStream.trim().split('\n');
  //debugPrint(managementFileLines.last);
  for (var line in managementFileLines) {
    if (line.contains('MasterURL=') || line.contains('PatchURL=') || line.contains('BackupMasterURL=') || line.contains('BackupPatchURL=')) {
      patchList.add(line);
    }
  }

  return patchList;
}

Future<List<String>> downloadIceFromOfficial(List<String> dataIcePaths) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  List<String> downloadedIceList = [];

  for (var path in dataIcePaths) {
    String webLinkPath = path.replaceAll('\\', '/');
    try {
      await dio.download('$masterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
      //debugPrint('$modManPso2binPath\\$path');
      downloadedIceList.add(path);
    } catch (e) {
      try {
        await dio.download('$patchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
        downloadedIceList.add(path);
      } catch (e) {
        try {
          await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
          downloadedIceList.add(path);
        } catch (e) {
          try {
            await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
            downloadedIceList.add(path);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
    }
  }

  dio.close();
  return downloadedIceList;
}

Future<File> swapperIceFileDownload(String dataIcePath, String saveToDirPath) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  String webLinkPath = dataIcePath.replaceFirst(Uri.file('$modManPso2binPath\\').toFilePath(), '').replaceAll('\\', '/').trim();
  String saveToPath = Uri.file('$saveToDirPath/${p.basenameWithoutExtension(dataIcePath)}').toFilePath();
  try {
    await dio.download('$masterURL$webLinkPath.pat', saveToPath);
    //debugPrint('$modManPso2binPath\\$path');
    dio.close();
    return File(saveToPath);
  } catch (e) {
    try {
      await dio.download('$patchURL$webLinkPath.pat', saveToPath);
      dio.close();
      return File(saveToPath);
    } catch (e) {
      try {
        await dio.download('$backupMasterURL$webLinkPath.pat', saveToPath);
        dio.close();
        return File(saveToPath);
      } catch (e) {
        try {
          await dio.download('$backupPatchURL$webLinkPath.pat', saveToPath);
          dio.close();
          return File(saveToPath);
        } catch (e) {
          //debugPrint(e.toString());
          dio.close();
          return File('');
        }
      }
    }
  }
}

Future<void> testDownload() async {
  final fileList = ['data\\win32\\372340de8e902ef7aa236aef87429f44', 'data\\win32\\94364983bfbe6d547a26b5d9fc1dd20d'];
  final filesDown = await downloadIceFromOfficial(fileList);
  debugPrint(filesDown.toString());
}
