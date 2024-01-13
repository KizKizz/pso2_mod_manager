import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/global_variables.dart';
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

Future<List<String>> fetchOfficialPatchFileList() async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};
  List<String> returnStatus = [];

  try {
    final response = await dio.get('${patchURL}patchlist_region1st.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      officialServerFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      returnStatus.add('Patch list 1: Success');
    }
  } catch (e) {
    try {
      final response = await dio.get('${backupPatchURL}patchlist_region1st.txt');
      if (response.statusCode == 200) {
        // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
        officialServerFileList.addAll(response.data.toString().split('\n'));
        // debugPrint(officialPatchServerFileList.toString());
        // debugPrint(officialPatchServerFileList.length.toString());
        returnStatus.add('Patch list 1: Success');
      }
    } catch (e) {
      returnStatus.add('Patch list 1: Failed');
      debugPrint(e.toString());
    }
  }
  try {
    final response = await dio.get('${patchURL}patchlist_classic.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      officialServerFileList.addAll(response.data.toString().split('\n'));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      returnStatus.add('Patch list 2: Success');
    }
  } catch (e) {
    try {
      final response = await dio.get('${backupPatchURL}patchlist_classic.txt');
      if (response.statusCode == 200) {
        // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
        officialServerFileList.addAll(response.data.toString().split('\n'));
        // debugPrint(officialPatchServerFileList.toString());
        // debugPrint(officialPatchServerFileList.length.toString());
        returnStatus.add('Patch list 2: Success');
      }
    } catch (e) {
      returnStatus.add('Patch list 2: Failed');
      debugPrint(e.toString());
    }
  }
  try {
    final response = await dio.get('${patchURL}patchlist_avatar.txt');
    if (response.statusCode == 200) {
      // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      officialServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty));
      // debugPrint(officialPatchServerFileList.toString());
      // debugPrint(officialPatchServerFileList.length.toString());
      returnStatus.add('Patch list 3: Success');
    }
  } catch (e) {
    try {
      final response = await dio.get('${backupPatchURL}patchlist_avatar.txt');
      if (response.statusCode == 200) {
        // officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
        officialServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty));
        // debugPrint(officialPatchServerFileList.toString());
        // debugPrint(officialPatchServerFileList.length.toString());
        returnStatus.add('Patch list 3: Success');
      }
    } catch (e) {
      returnStatus.add('Patch list 3: Failed');
      debugPrint(e.toString());
    }
  }

  dio.close();

  //separate servers
  List<String> tempMasterFiles = officialServerFileList.where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'm').toList();
  for (var line in tempMasterFiles) {
    officialMasterFiles.add(line.split('.pat').first);
  }

  List<String> tempPatchFiles = officialServerFileList.where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p').toList();
  for (var line in tempPatchFiles) {
    officialPatchFiles.add(line.split('.pat').first);
  }

  // String allFilePath = Uri.file('${Directory.current.path}/allFiles.txt').toFilePath();
  // if (!File(allFilePath).existsSync()) {
  //   File(allFilePath).createSync();
  // }
  // File(allFilePath).writeAsStringSync(officialServerFileList.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'));

  // String masterFilePath = Uri.file('${Directory.current.path}/masterFiles.txt').toFilePath();
  // if (!File(masterFilePath).existsSync()) {
  //   File(masterFilePath).createSync();
  // }
  // File(masterFilePath).writeAsStringSync(officialMasterFiles.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'));

  // String patchFilePath = Uri.file('${Directory.current.path}/patchFiles.txt').toFilePath();
  // if (!File(patchFilePath).existsSync()) {
  //   File(patchFilePath).createSync();
  // }
  // File(patchFilePath).writeAsStringSync(officialPatchFiles.toString().replaceAll('[', '').replaceAll(']', '').replaceAll(', ', '\n'));
  // debugPrint(officialPatchServerFileList.toString());
  // debugPrint(officialPatchServerFileList.length.toString());
  return returnStatus;
}

Future<List<String>> fetchOfficialPatchFileListForModsAdder() async {
  List<String> patchFileList = [];
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  try {
    final response = await dio.get('${patchURL}patchlist_region1st.txt');
    if (response.statusCode == 200) {
      patchFileList.addAll(response.data.toString().split('\n'));
      //debugPrint(officialPatchFileList.toString());
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_classic.txt');
    if (response.statusCode == 200) {
      patchFileList.addAll(response.data.toString().split('\n'));
      //debugPrint(officialPatchFileList.toString());
    }
  } catch (e) {
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_avatar.txt');
    if (response.statusCode == 200) {
      patchFileList.addAll(response.data.toString().split('\n'));
      //debugPrint(officialPatchFileList.toString());
    }
  } catch (e) {
    debugPrint(e.toString());
  }

  dio.close();
  return patchFileList;
}

Future<List<String>> downloadIceFromOfficial(List<String> dataIcePaths) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  List<String> downloadedIceList = [];

  for (var path in dataIcePaths) {
    String webLinkPath = path.replaceAll('\\', '/');
    if (webLinkPath.contains('win32reboot_na')) {
      webLinkPath = webLinkPath.replaceFirst('win32reboot_na', 'win32reboot');
    } else if (webLinkPath.contains('win32_na')) {
      webLinkPath = webLinkPath.replaceFirst('win32_na', 'win32');
    }

    if (officialPatchFiles.contains(webLinkPath)) {
      try {
        await dio.download('$patchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
        debugPrint('patch');
        downloadedIceList.add(path);
      } on DioException {
        try {
          await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
          downloadedIceList.add(path);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    } else if (officialMasterFiles.contains(webLinkPath)) {
      try {
        await dio.download('$masterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
        debugPrint('master');
        downloadedIceList.add(path);
      } on DioException {
        try {
          await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
          downloadedIceList.add(path);
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    } else {
      try {
        await dio.download('$patchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
        //debugPrint('patch ${file.statusCode}');
        downloadedIceList.add(path);
      } on DioException {
        try {
          await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
          downloadedIceList.add(path);
        } on DioException {
          try {
            await dio.download('$masterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
            //debugPrint('master ${file.statusCode}');
            downloadedIceList.add(path);
          } on DioException {
            try {
              await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
              downloadedIceList.add(path);
            } catch (e) {
              debugPrint(e.toString());
            }
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
  File downloadedFile = File('');
  try {
    await dio.download('$patchURL$webLinkPath.pat', saveToPath);
    //debugPrint('$modManPso2binPath\\$path');
    dio.close();
    return File(saveToPath);
  } on DioException {
    try {
      await dio.download('$backupPatchURL$webLinkPath.pat', saveToPath);
      downloadedFile = File(saveToPath);
    } on DioException {
      try {
        final test = await dio.download('$masterURL$webLinkPath.pat', saveToPath);
        debugPrint(test.statusCode.toString());
        downloadedFile = File(saveToPath);
      } on DioException {
        try {
          await dio.download('$backupMasterURL$webLinkPath.pat', saveToPath);
          downloadedFile = File(saveToPath);
        } catch (e) {
          //debugPrint(e.toString());
          downloadedFile = File('');
        }
      }
    }
  }

  dio.close();
  return downloadedFile;
}

Future<String> downloadIconIceFromOfficial(String iconIcePath, String saveLocation) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  String downloadedIceFile = '';

  String webLinkPath = iconIcePath.replaceAll('\\', '/');

  if (officialPatchFiles.contains(webLinkPath)) {
    try {
      await dio.download('$patchURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
      //debugPrint('patch ${file.statusCode}');
      downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
    } on DioException {
      try {
        await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
        downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  } else if (officialMasterFiles.contains(webLinkPath)) {
    try {
      await dio.download('$masterURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
      //debugPrint('master ${file.statusCode}');
      downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
    } on DioException {
      try {
        await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
        downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  } else {
    try {
      await dio.download('$patchURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
      //debugPrint('patch ${file.statusCode}');
      downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
    } on DioException {
      try {
        await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
        downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
      } on DioException {
        try {
          await dio.download('$masterURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
          //debugPrint('master ${file.statusCode}');
          downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
        } on DioException {
          try {
            await dio.download('$backupMasterURL$webLinkPath.pat', Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath());
            downloadedIceFile = Uri.file('$saveLocation/${p.basenameWithoutExtension(iconIcePath)}').toFilePath();
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      }
    }
  }

  dio.close();
  return downloadedIceFile;
}

Future<bool> downloadProfanityFileJP() async {
  final returnedResult = await downloadIceFromOfficial(['data/win32/$profanityFilterIce']);
  if (returnedResult.isNotEmpty && returnedResult.contains('data/win32/$profanityFilterIce')) {
    return true;
  } else {
    return false;
  }
}

Future<bool> downloadProfanityFileNA() async {
  final returnedResult = await Dio().download(
      'https://github.com/KizKizz/pso2_mod_manager/raw/main/profanityFilterNA/ffbff2ac5b7a7948961212cefd4d402c', Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath());
  if (returnedResult.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future<void> testDownload() async {
  final fileList = ['data\\win32\\000a686a27ade4d971ac5e27a664a5a3'];
  final filesDown = await downloadIceFromOfficial(fileList);
  debugPrint(filesDown.toString());
}
