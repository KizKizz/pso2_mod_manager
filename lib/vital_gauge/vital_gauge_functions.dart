import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals_flutter.dart';

Signal<String> vitalGaugeStatus = Signal('');

Future<List<VitalGaugeBackground>> vitalGaugeBackgroundFetch() async {
  List<VitalGaugeBackground> vitalGaugeData = [];

  // Load saved data from json
  if (File(mainVitalGaugeListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(mainVitalGaugeListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      vitalGaugeData.add(VitalGaugeBackground.fromJson(type));
    }
  }

  // Load from player data
  final vitalGaugeInfoFromPlayerData = pItemData.where((e) => e.itemCategories.contains('Vital Gauge'));

  for (var info in vitalGaugeInfoFromPlayerData.where((e) => vitalGaugeData.indexWhere((i) => e.getImageIceName().contains(i.iceName)) == -1)) {
    String ddsName = p.basenameWithoutExtension(info.infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
    String iceName = info.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last;
    String icePath = p.withoutExtension(pso2binDirPath + p.separator + oItemData.firstWhere((e) => e.path.contains(iceName)).path.replaceAll('/', p.separator));
    String pngPath = '$githubIconDatabaseLink${info.iconImagePath.replaceAll('\\', '/')}';
    vitalGaugeData.add(VitalGaugeBackground(icePath, iceName, ddsName, pngPath, '', '', '', '', false));
  }

  vitalGaugeData.sort((a, b) => a.ddsName.compareTo(b.ddsName));
  saveMasterVitalGaugeToJson(vitalGaugeData);

  return vitalGaugeData;
}

List<File> customVitalGaugeImagesFetch() {
  return Directory(vitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
}

void saveMasterVitalGaugeToJson(List<VitalGaugeBackground> vitalGaugeBackgroundList) {
  //Save to json
  vitalGaugeBackgroundList.map((vg) => vg.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainVitalGaugeListJsonPath).writeAsStringSync(encoder.convert(vitalGaugeBackgroundList));
}

Future<bool> customVgBackgroundApply(context, String imgPath, VitalGaugeBackground vgDataFile) async {
  Directory(modVitalGaugeTempDirPath).createSync(recursive: true);

  String newTempIcePath = Uri.file('$modVitalGaugeTempDirPath/${vgDataFile.iceName}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);
  if (Directory(newTempIcePath).existsSync()) {
    await Process.run(pngDdsConvExePath, [imgPath, Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath(), '-pngtodds']);
    vitalGaugeStatus.value = appText.dText(appText.convertingFileToDds, p.basename(imgPath));
    Future.delayed(const Duration(microseconds: 10));
    // logs += 'Create: $newTempIcePath\n';
  }
  if (File(Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath()).existsSync()) {
    // logs += 'Convert: ${Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath().toString()}\n';
    await Process.run('$zamboniExePath -c -pack -outdir "$modVitalGaugeTempDirPath"', [Uri.file('$modVitalGaugeTempDirPath/${vgDataFile.iceName}').toFilePath()]);
    Directory(Uri.file('$modVitalGaugeTempDirPath/${vgDataFile.iceName}').toFilePath()).deleteSync(recursive: true);
    vitalGaugeStatus.value = appText.generatingIceFile;
    Future.delayed(const Duration(microseconds: 10));

    File renamedFile = await File(Uri.file('$modVitalGaugeTempDirPath/${vgDataFile.iceName}.ice').toFilePath()).rename(Uri.file('$modVitalGaugeTempDirPath/${vgDataFile.iceName}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      await checksumToGameData();
      // logs += 'Pack: ${renamedFile.path.toString()}\n';
      int i = 0;
      while (i < 10) {
        try {
          File copiedFile = await renamedFile.copy(vgDataFile.icePath);
          vgDataFile.replacedMd5 = await copiedFile.getMd5Hash();
          i = 10;
          vitalGaugeStatus.value = appText.dText(appText.copyingModFileToGameData, p.basename(vgDataFile.iceName));
          Future.delayed(const Duration(microseconds: 10));
          // logs += 'Copy: ${copied.path.toString()}\n';
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        vitalGaugeStatus.value = appText.failed;
        Future.delayed(const Duration(microseconds: 10));
        return false;
      }
    }
    Directory(modVitalGaugeTempDirPath).delete(recursive: true);
  }
  vitalGaugeStatus.value = appText.success;
  Future.delayed(const Duration(microseconds: 10));

  return true;
}

Future<(File, String)> vitalGaugeOriginalFileDownload(String filePath) async {
  String networkFilePath = '${filePath.replaceFirst(pso2binDirPath + p.separator, '').trim()}.pat'.replaceAll(p.separator, '/');
  if (networkFilePath.isNotEmpty) {
    final serverURLs = [segaMasterServerURL, segaPatchServerURL, segaMasterServerBackupURL, segaPatchServerBackupURL];
    for (var url in serverURLs) {
      final task = DownloadTask(
          url: '$url$networkFilePath',
          filename: p.basenameWithoutExtension(networkFilePath),
          headers: {"User-Agent": "AQUA_HTTP"},
          directory: p.dirname(filePath),
          updates: Updates.statusAndProgress,
          allowPause: false);

      final result = await FileDownloader().download(task,
          onProgress: (progress) => vitalGaugeStatus.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

      switch (result.status) {
        case TaskStatus.complete:
          vitalGaugeStatus.value = appText.fileDownloadSuccessful;
          File returnedFile = File(filePath);
          return (returnedFile, await returnedFile.getMd5Hash());
        default:
          vitalGaugeStatus.value = appText.fileDownloadFailed;
      }
    }
  }

  return (File(''), '');
}

Future<List<VitalGaugeBackground>> unappliedVitalGaugeCheck() async {
  List<VitalGaugeBackground> unappliedList = [];
  for (var vitalGauge in masterVitalGaugeBackgroundList.where((e) => e.isReplaced)) {
    if (await File(vitalGauge.icePath).getMd5Hash() != vitalGauge.replacedMd5) {
      unappliedList.add(vitalGauge);
    }
  }
  return unappliedList;
}
