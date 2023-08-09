import 'dart:io';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> checksumChecker(context) async {
  await ApplicationConfig().checkChecksumFileForUpdates(context);
  final prefs = await SharedPreferences.getInstance();
  modManChecksumFilePath = (prefs.getString('checksumFilePath') ?? '');
  if (!File(modManChecksumFilePath).existsSync()) {
    modManChecksumFilePath = '';
  }

  if (modManChecksumFilePath.isEmpty || p.basename(modManChecksumFilePath) != netChecksumFileName) {
    final filesInCSFolder = Directory(modManChecksumDirPath).listSync().whereType<File>();
    if (filesInCSFolder.isNotEmpty) {
      modManChecksumFilePath = Uri.file(filesInCSFolder
              .firstWhere(
                (element) => p.basename(element.path) == netChecksumFileName,
                orElse: () => File(''),
              )
              .path)
          .toFilePath();
      if (modManChecksumFilePath.isNotEmpty && p.basename(modManChecksumFilePath) == netChecksumFileName) {
        prefs.setString('checksumFilePath', modManChecksumFilePath);
      }
    }
  }

  if (modManChecksumFilePath.isNotEmpty && File(modManChecksumFilePath).existsSync()) {
    modManLocalChecksumMD5 = await getFileHash(modManChecksumFilePath.toString());
    modManWin32CheckSumFilePath = Uri.file('$modManPso2binPath/data/win32/${p.basename(modManChecksumFilePath)}').toFilePath();
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync()) {
      modManWin32NaCheckSumFilePath = Uri.file('$modManPso2binPath/data/win32_na/${p.basename(modManChecksumFilePath)}').toFilePath();
    }

    //win32
    if (modManWin32CheckSumFilePath.isNotEmpty && File(modManWin32CheckSumFilePath).existsSync()) {
      modManWin32ChecksumMD5 = await getFileHash(modManWin32CheckSumFilePath);
    } else if (modManWin32CheckSumFilePath.isNotEmpty && !File(modManWin32CheckSumFilePath).existsSync()) {
      File(modManChecksumFilePath).copySync(modManWin32CheckSumFilePath);
      modManWin32ChecksumMD5 = await getFileHash(modManWin32CheckSumFilePath);
    }
    if (modManWin32ChecksumMD5 != modManLocalChecksumMD5) {
      File(modManChecksumFilePath).copySync(modManWin32CheckSumFilePath);
      modManWin32ChecksumMD5 = await getFileHash(modManWin32CheckSumFilePath);
    } 

    //win32_na
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync()) {
      if (modManWin32NaCheckSumFilePath.isNotEmpty && File(modManWin32NaCheckSumFilePath).existsSync()) {
        modManWin32NaChecksumMD5 = await getFileHash(modManWin32NaCheckSumFilePath);
      } else if (modManWin32NaCheckSumFilePath.isNotEmpty && !File(modManWin32NaCheckSumFilePath).existsSync()) {
        File(modManChecksumFilePath).copySync(modManWin32NaCheckSumFilePath);
        modManWin32NaChecksumMD5 = await getFileHash(modManWin32NaCheckSumFilePath);
      }
      if (modManWin32NaChecksumMD5 != modManLocalChecksumMD5) {
        File(modManChecksumFilePath).copySync(modManWin32NaCheckSumFilePath);
        modManWin32NaChecksumMD5 = await getFileHash(modManWin32NaCheckSumFilePath);
      }
    }
  }
}

Future<void> applyModsChecksumChecker(context) async {
  if (modManChecksumFilePath.isEmpty || !File(modManChecksumFilePath).existsSync() || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
    Provider.of<StateProvider>(context, listen: false).checksumDownloadingTrue();
    await Dio().download(netChecksumFileLink, Uri.file('$modManChecksumDirPath/$netChecksumFileName').toFilePath()).then((value) {
      Provider.of<StateProvider>(context, listen: false).checksumDownloadingFalse();
      checksumChecker(context);
      Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
    });
  }

  if (modManChecksumFilePath.isNotEmpty && File(modManChecksumFilePath).existsSync()) {
    //win32
    modManWin32ChecksumMD5 = await getFileHash(modManWin32CheckSumFilePath);
    if (modManWin32ChecksumMD5 != modManLocalChecksumMD5) {
      File(modManChecksumFilePath).copySync(modManWin32CheckSumFilePath);
      modManWin32ChecksumMD5 = modManLocalChecksumMD5;
    }
    //win32na
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync()) {
      modManWin32NaChecksumMD5 = await getFileHash(modManWin32NaCheckSumFilePath);
      if (modManWin32NaChecksumMD5 != modManLocalChecksumMD5) {
        File(modManChecksumFilePath).copySync(modManWin32NaCheckSumFilePath);
        modManWin32NaChecksumMD5 = modManLocalChecksumMD5;
      }
    }
  }
}
