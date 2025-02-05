import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/v3_functions/modified_ice_file_save.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

Future<List<LineStrikeSleeve>> lineStrikeSleevesFetch() async {
  //Load list from json
  List<LineStrikeSleeve> sleeveData = [];
  if (File(mainLineStrikeSleeveListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(mainLineStrikeSleeveListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      sleeveData.add(LineStrikeSleeve.fromJson(type));
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  List<ItemData> sleeveItemData = pItemData.where((element) => element.csvFileName == 'Line Duel Sleeves.csv').toList();

  for (var data in sleeveItemData.where((e) => sleeveData.indexWhere((b) => e.iconImagePath.contains(b.iconIceDdsName)) == -1)) {
    await Future.delayed(const Duration(milliseconds: 50));
    String icePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData.firstWhere((e) => e.path.contains(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last)).path.replaceAll('/', p.separator));
    String iconIcePath = p.withoutExtension(pso2binDirPath +
        p.separator +
        oItemData.firstWhere((e) => e.path.contains(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last)).path.replaceAll('/', p.separator));
    String iceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String iconIceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'ImagePath').value.split('/').last);
    String iconWebPath = '$githubIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
    sleeveData.add(LineStrikeSleeve(icePath, iconIcePath, iceDdsName, iconIceDdsName, iconWebPath, '', '', '', false));
    await Future.delayed(const Duration(milliseconds: 10));
  }

  saveMasterLineStrikeSleeveListToJson(sleeveData);

  return sleeveData;
}

Future<List<File>> customSleeveImageFetch() async {
  return Directory(lineStrikeSleevesDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
}

Future<bool> customSleeveImageApply(String imgPath, LineStrikeSleeve sleeveDataFile) async {
  if (Directory(lineStrikeSleeveTempDirPath).existsSync()) {
    Directory(lineStrikeSleeveTempDirPath).deleteSync(recursive: true);
    Directory(lineStrikeSleeveTempDirPath).createSync(recursive: true);
  } else {
    Directory(lineStrikeSleeveTempDirPath).createSync(recursive: true);
  }
  //prep image
  img.Image? iconTemplate;
  img.Image? sleeveTemplate;
  if (kDebugMode) {
    iconTemplate = await img.decodePngFile('assets/img/line_strike_sleeve_icon_template.png');
    sleeveTemplate = await img.decodePngFile('assets/img/line_strike_sleeve_template.png');
  } else {
    iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_sleeve_icon_template.png').toFilePath());
    sleeveTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_sleeve_template.png').toFilePath());
  }
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedReplaceImage = img.copyResize(replaceImage!, width: 159, height: 224);

  //download and replace
  //icon
  File downloadedIconIceFile = await originalIceDownload('${sleeveDataFile.iconIcePath.replaceFirst(pso2binDirPath + p.separator, '')}.pat', lineStrikeSleeveTempDirPath, lineStrikeStatus);
  await Process.run('$zamboniExePath -outdir "$lineStrikeSleeveTempDirPath"', [downloadedIconIceFile.path]);
  String newTempIconIcePath = Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext/group2').toFilePath();

  if (Directory(newTempIconIcePath).existsSync()) {
    await Process.run(pngDdsConvExePath,
        [Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
    img.Image? iconImage = await img.decodePngFile(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath());
    for (var templatePixel in iconTemplate!.data!) {
      if (templatePixel.a > 0) {
        iconImage!.setPixel(templatePixel.x, templatePixel.y, resizedReplaceImage.getPixel(templatePixel.x - 49, templatePixel.y - 16));
      }
    }

    await File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(iconImage!));

    await Process.run(pngDdsConvExePath,
        [Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeSleeveTempDirPath"', [Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext').toFilePath()]);
    Directory(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext.ice').toFilePath())
        .rename(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copiedFile = renamedFile.copySync(sleeveDataFile.iconIcePath);
          //cache
          String cachePath = sleeveDataFile.iconIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          sleeveDataFile.replacedIconIceMd5 = await copiedFile.getMd5Hash();
          modifiedIceAdd(p.basenameWithoutExtension(copiedFile.path));
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        lineStrikeStatus.value = appText.failedToReplaceSleeve;
        return false;
      }
    }

    Directory(lineStrikeSleeveTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  //sleeve
  // String downloadedIceFilePath = await downloadIconIceFromOfficial(sleeveDataFile.icePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), ''), lineStrikeSleeveTempDirPath);
  // await Process.run('$zamboniExePath -outdir "$lineStrikeSleeveTempDirPath"', [downloadedIceFilePath]);
  String newTempIcePath = Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);

  if (Directory(newTempIcePath).existsSync()) {
    // await Process.run(
    //     pngDdsConvExePath, [Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath(), Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath(), '-ddstopng']);
    // img.Image? iceImage = await img.decodePngFile(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath());
    for (var templatePixel in sleeveTemplate!.data!) {
      if (templatePixel.a > 0) {
        templatePixel.set(replaceImage.getPixel(templatePixel.x, templatePixel.y));
        // iceImage!.setPixel(templatePixel.x, templatePixel.y, replaceImage.getPixel(templatePixel.x, templatePixel.y));
      }
    }

    await File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(sleeveTemplate));

    await Process.run(
        pngDdsConvExePath, [Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeSleeveTempDirPath"', [Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath()]);
    Directory(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.icePath)}.ice').toFilePath())
        .rename(Uri.file('$lineStrikeSleeveTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copiedFile = renamedFile.copySync(sleeveDataFile.icePath);
          //cache
          String cachePath = sleeveDataFile.icePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          sleeveDataFile.replacedIceMd5 = await copiedFile.getMd5Hash();
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        lineStrikeStatus.value = appText.failedToReplaceSleeveIcon;
        return false;
      }
    }

    Directory(lineStrikeSleeveTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  lineStrikeStatus.value = appText.success;
  return true;
}

Future<bool> customSleeveImageRemove(LineStrikeSleeve sleeve, List<LineStrikeSleeve> lineStrikeSleeveList) async {
  File downloadedIceFile = await originalIceDownload('${sleeve.icePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), '')}.pat', p.dirname(sleeve.icePath), lineStrikeStatus);
  File downloadedIconIceFile = await originalIceDownload('${sleeve.iconIcePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), '')}.pat', p.dirname(sleeve.iconIcePath), lineStrikeStatus);

  if (downloadedIceFile.existsSync()) sleeve.replacedIceMd5 = '';
  if (downloadedIconIceFile.existsSync()) sleeve.replacedIconIceMd5 = '';
  if (sleeve.replacedIceMd5.isEmpty && sleeve.replacedIconIceMd5.isEmpty) {
    sleeve.replacedImagePath = '';
    sleeve.isReplaced = false;
    // Remove cache
    File iceCache = File(sleeve.icePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath));
    if (iceCache.existsSync()) await iceCache.delete(recursive: true);
    File iconIceCache = File(sleeve.iconIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath));
    if (iconIceCache.existsSync()) await iconIceCache.delete(recursive: true);
    saveMasterLineStrikeSleeveListToJson(lineStrikeSleeveList);
    // Status
    lineStrikeStatus.value = appText.success;
    Future.delayed(const Duration(microseconds: 10));
    return true;
  }
  // Status
  lineStrikeStatus.value = appText.failed;
  Future.delayed(const Duration(microseconds: 10));
  return false;
}

void saveMasterLineStrikeSleeveListToJson(List<LineStrikeSleeve> sleeveList) {
  //Save to json
  sleeveList.map((board) => board.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainLineStrikeSleeveListJsonPath).writeAsStringSync(encoder.convert(sleeveList));
}
