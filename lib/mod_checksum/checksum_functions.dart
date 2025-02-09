import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';

Future<bool> checksumFileFetch() async {
  File checksum = File(modChecksumFilePath);
  if (!checksum.existsSync()) {
    await checksum.parent.create(recursive: true);
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/checksum/d4455ebc2bef618f29106da7692ebc1a'));
    if (response.statusCode == 200) {
      await checksum.writeAsBytes(response.bodyBytes);
      await checksumToGameData();
      return true;
    } else {
      return false;
    }
  } else {
    await checksumToGameData();
    return true;
  }
}

Future<void> checksumFileSelect() async {
  final XFile? checksumFile = await openFile();

  if (checksumFile != null) {
    final copiedFile = await File(checksumFile.path).copy(modChecksumFilePath);
    if (copiedFile.existsSync()) {
      checksumAvailability.value = true;
      await checksumToGameData();
    }
  }
}

Future<bool> checksumToGameData() async {
  File checksum = File(modChecksumFilePath);
  String win32Path = '$pso2DataDirPath${p.separator}win32';
  String win32NAPath = '$pso2DataDirPath${p.separator}win32_na';
  if (checksum.existsSync()) {
    File copiedFile = await checksum.copy(win32Path + p.separator + p.basenameWithoutExtension(checksum.path));
    if (Directory(win32NAPath).existsSync()) {
      await checksum.copy(win32NAPath + p.separator + p.basenameWithoutExtension(checksum.path));
    }
    if (copiedFile.getMd5Hash() == checksum.getMd5Hash()) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}
