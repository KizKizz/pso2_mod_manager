import 'dart:io';

import 'package:crypto/crypto.dart';

Future<String?> getFileHash(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) return null;
  try {
    final stream = file.openRead();
    final hash = await md5.bind(stream).first;

    return hash.toString();
  } catch (exception) {
    return null;
  }
}