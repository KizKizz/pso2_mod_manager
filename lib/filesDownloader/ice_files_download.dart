import 'package:dio/dio.dart';
import 'package:flutter/material.dart';



Future<void> downloadFile() async {
  Dio dio = Dio();
  
  dio.options.headers = {"User-Agent": "AQUA_HTTP"};
  await dio.download("http://download.pso2.jp/patch_prod/v70800_rc_98_masterbase/patches/data/win32reboot/9c/a433e75e9cef9c6d0a318bde62bda6.pat",
      Uri.file('E:\\Steam\\steamapps\\common\\PHANTASYSTARONLINE2_NA_STEAM\\pso2_bin\\PSO2 Mod Manager\\Checksum/a433e75e9cef9c6d0a318bde62bda6').toFilePath());
  debugPrint("saved");
}
