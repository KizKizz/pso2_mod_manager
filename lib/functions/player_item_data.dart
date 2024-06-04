import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int totalCount = 0;

Future<void> downloadPlayerItemData(context) async {
  final dio = Dio();
  String githubPath = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/playerItemData.json';

  await dio.download(githubPath, modManPlayerItemDataPath, onReceiveProgress: (count, total) {
    totalCount += count;
    String percentage = ((totalCount / 17321211633) * 100).toStringAsPrecision(1);
    Provider.of<StateProvider>(context, listen: false).playerItemDataDownloadPercentSet(double.parse(percentage));
  });
  if (File(modManPlayerItemDataPath).existsSync()) {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('refSheetsVersion', refSheetsNewVersion);
    refSheetsVersion = refSheetsNewVersion;
    modManRefSheetsLocalVersion = refSheetsNewVersion;
    File(modManRefSheetsLocalVerFilePath).writeAsString(refSheetsNewVersion.toString());
    Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableFalse();
    Provider.of<StateProvider>(context, listen: false).playerItemDataDownloadPercentReset();
    // debugPrint('itemdatajson size: $totalCount');
    totalCount = 0;
  }
}

Future<List<CsvItem>> playerItemDataGet(context) async {
  if (Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailable || !File(modManPlayerItemDataPath).existsSync()) {
    await downloadPlayerItemData(context);
  }
  List<CsvItem> returnList = [];
  if (File(modManPlayerItemDataPath).existsSync()) {
    await Future.delayed(const Duration(milliseconds: 500));
    
    File playerItemDataJson = File(modManPlayerItemDataPath);
    if (playerItemDataJson.existsSync()) {
      final dataFromJson = await playerItemDataJson.readAsString();
      if (dataFromJson.isNotEmpty) {
        var jsonData = jsonDecode(dataFromJson);
        for (var data in jsonData) {
          returnList.add(CsvItem.fromJson(data));
        }
      }
    }
  }

  return returnList;
}
