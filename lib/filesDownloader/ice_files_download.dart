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
      officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      //debugPrint(officialPatchFileList.toString());
      returnStatus.add('Patch list 1: Success');
    }
  } catch (e) {
    returnStatus.add('Patch list 1: Failed');
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_classic.txt');
    if (response.statusCode == 200) {
      officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      //debugPrint(officialPatchFileList.toString());
      returnStatus.add('Patch list 2: Success');
    }
  } catch (e) {
    returnStatus.add('Patch list 2: Failed');
    debugPrint(e.toString());
  }
  try {
    final response = await dio.get('${patchURL}patchlist_avatar.txt');
    if (response.statusCode == 200) {
      officialPatchServerFileList.addAll(response.data.toString().split('\n').where((element) => element.isNotEmpty && element.trim().substring(element.length - 2, element.length - 1) == 'p'));
      //debugPrint(officialPatchFileList.toString());
      returnStatus.add('Patch list 3: Success');
    }
  } catch (e) {
    returnStatus.add('Patch list 3: Failed');
    debugPrint(e.toString());
  }

  dio.close();
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
    }

    if (officialPatchServerFileList.isNotEmpty) {
      bool fileFound = officialPatchServerFileList
          .firstWhere(
            (element) => element.contains(p.basenameWithoutExtension(path)),
            orElse: () => '',
          )
          .isNotEmpty;

      if (fileFound) {
        try {
          await dio.download('$patchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
          //debugPrint('patch ${file.statusCode}');
          downloadedIceList.add(path);
        } on DioException {
          try {
            await dio.download('$backupPatchURL$webLinkPath.pat', Uri.file('$modManPso2binPath/$path').toFilePath());
            downloadedIceList.add(path);
          } catch (e) {
            debugPrint(e.toString());
          }
        }
      } else {
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
  try {
    await dio.download('$patchURL$webLinkPath.pat', saveToPath);
    //debugPrint('$modManPso2binPath\\$path');
    dio.close();
    return File(saveToPath);
  } catch (e) {
    try {
      await dio.download('$backupPatchURL$webLinkPath.pat', saveToPath);
      dio.close();
      return File(saveToPath);
    } catch (e) {
      try {
        final test = await dio.download('$masterURL$webLinkPath.pat', saveToPath);
        debugPrint(test.statusCode.toString());
        dio.close();
        return File(saveToPath);
      } catch (e) {
        try {
          await dio.download('$backupMasterURL$webLinkPath.pat', saveToPath);
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

Future<String> downloadIconIceFromOfficial(String iconIcePath, String saveLocation) async {
  Dio dio = Dio();
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};

  String downloadedIceFile = '';

  String webLinkPath = iconIcePath.replaceAll('\\', '/');

  if (officialPatchServerFileList.isNotEmpty) {
    bool fileFound = officialPatchServerFileList
        .firstWhere(
          (element) => element.contains(p.basenameWithoutExtension(iconIcePath)),
          orElse: () => '',
        )
        .isNotEmpty;

    if (fileFound) {
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
    } else {
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

Future<void> testDownload() async {
  final fileList = ['data\\win32\\372340de8e902ef7aa236aef87429f44', 'data\\win32\\94364983bfbe6d547a26b5d9fc1dd20d'];
  final filesDown = await downloadIceFromOfficial(fileList);
  debugPrint(filesDown.toString());
}
