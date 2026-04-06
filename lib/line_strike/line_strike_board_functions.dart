import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import 'package:pso2_mod_manager/v3_functions/modified_ice_file_save.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

Future<List<LineStrikeBoard>> lineStrikeBoardsFetch() async {
  //Load list from json
  List<LineStrikeBoard> boardData = [];
  if (File(mainLineStrikeBoardListJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(mainLineStrikeBoardListJsonPath).readAsStringSync());
    for (var type in jsonData) {
      boardData.add(LineStrikeBoard.fromJson(type));
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  List<ItemData> boardItemData = pItemData.where((element) => element.csvFileName == 'Line Duel Boards.csv').toList();

  for (var data in boardItemData.where((e) => boardData.indexWhere((b) => e.iconImagePath.contains(b.iconIceDdsName)) == -1)) {
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
    boardData.add(LineStrikeBoard(icePath, iconIcePath, iceDdsName, iconIceDdsName, iconWebPath, '', '', '', false));
    await Future.delayed(const Duration(milliseconds: 50));
  }

  saveMasterLineStrikeBoardListToJson(boardData);

  return boardData;
}

Future<List<File>> customBoardImageFetch() async {
  return Directory(lineStrikeBoardsDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
}

Future<bool> customBoardImageApply(String imgPath, LineStrikeBoard boardDataFile) async {
  if (Directory(lineStrikeBoardTempDirPath).existsSync()) {
    Directory(lineStrikeBoardTempDirPath).deleteSync(recursive: true);
    Directory(lineStrikeBoardTempDirPath).createSync(recursive: true);
  } else {
    Directory(lineStrikeBoardTempDirPath).createSync(recursive: true);
  }

  img.Image? iconTemplate;
  img.Image? boardTemplate;
  if (kDebugMode) {
    iconTemplate = await img.decodePngFile('assets/img/line_strike_board_icon_template.png');
    boardTemplate = await img.decodePngFile('assets/img/line_strike_board_template.png');
  } else {
    iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_board_icon_template.png').toFilePath());
    boardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_board_template.png').toFilePath());
  }
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedReplaceIconImage = img.copyResize(replaceImage!, width: 226, height: 128);

  //download and replace
  //icon
  File? downloadedIconIceFile = await originalIceDownload(boardDataFile.iconIcePath.replaceFirst(pso2binDirPath + p.separator, ''), lineStrikeBoardTempDirPath, lineStrikeStatus);
  if (downloadedIconIceFile == null) return false;
  if (Platform.isLinux) {
    await Process.run('wine $zamboniExePath -outdir "$lineStrikeBoardTempDirPath"', [downloadedIconIceFile.path]);
  } else {
    await Process.run('$zamboniExePath -outdir "$lineStrikeBoardTempDirPath"', [downloadedIconIceFile.path]);
  }
  String newTempIconIcePath = Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext/group2').toFilePath();

  if (Directory(newTempIconIcePath).existsSync()) {
    if (Platform.isLinux) {
      await Process.run('wine $pngDdsConvExePath',
          [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
    } else {
      await Process.run(pngDdsConvExePath,
          [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
    }
    img.Image? iconImage = await img.decodePngFile(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath());
    for (var templatePixel in iconTemplate!.data!) {
      if (templatePixel.a > 0) {
        try {
          iconImage!.setPixel(templatePixel.x, templatePixel.y, resizedReplaceIconImage.getPixel(templatePixel.x - 15, templatePixel.y - 64));
          // debugPrint(resizedReplaceIconImage.getPixel(templatePixel.x - 37, templatePixel.y - 64).toString());
        } catch (e) {
          break;
        }
      }
    }

    await File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(iconImage!));

    if (Platform.isLinux) {
      await Process.run('wine $pngDdsConvExePath',
          [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
    } else {
      await Process.run(pngDdsConvExePath,
          [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
    }
    await File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath()).existsSync()) {
    if (Platform.isLinux) {
      await Process.run('wine $zamboniExePath -c -pack -outdir "$lineStrikeBoardTempDirPath"', [Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext').toFilePath()]);
    } else {
      await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeBoardTempDirPath"', [Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext').toFilePath()]);
    }
    Directory(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext.ice').toFilePath())
        .rename(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.iconIcePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copiedFile = renamedFile.copySync(boardDataFile.iconIcePath);
          //cache
          String cachePath = boardDataFile.iconIcePath.replaceFirst(Uri.file('$pso2binDirPath/data').toFilePath(), lineStrikeCustomizedCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          boardDataFile.replacedIconIceMd5 = await copiedFile.getMd5Hash();
          modifiedIceAdd(p.basenameWithoutExtension(copiedFile.path));
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        lineStrikeStatus.value = appText.failedToReplaceBoard;
        return false;
      }
    }

    Directory(lineStrikeBoardTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  //board
  // String downloadedIceFilePath = await downloadIconIceFromOfficial(boardDataFile.icePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), ''), lineStrikeBoardTempDirPath);
  // await Process.run('$zamboniExePath -outdir "$lineStrikeBoardTempDirPath"', [downloadedIceFilePath]);
  String newTempIcePath = Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);

  if (Directory(newTempIcePath).existsSync()) {
    // await Process.run(
    //     pngDdsConvExePath, [Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath(), Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath(), '-ddstopng']);
    // img.Image? iceImage = await img.decodePngFile(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath());
    for (var templatePixel in boardTemplate!.data!) {
      if (templatePixel.a > 0) {
        try {
          templatePixel.set(replaceImage.getPixel(templatePixel.x - 77, templatePixel.y - 12));
          // iceImage!.setPixel(templatePixel.x, templatePixel.y, replaceImage.getPixel(templatePixel.x, templatePixel.y));
        } catch (e) {
          break;
        }
      }
    }

    await File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(boardTemplate));

    if (Platform.isLinux) {
      await Process.run(
          'wine $pngDdsConvExePath', [Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
    } else {
      await Process.run(
          pngDdsConvExePath, [Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
    }
    await File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath()).existsSync()) {
    if (Platform.isLinux) {
      await Process.run('wine $zamboniExePath -c -pack -outdir "$lineStrikeBoardTempDirPath"', [Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath()]);
    } else {
      await Process.run('$zamboniExePath -c -pack -outdir "$lineStrikeBoardTempDirPath"', [Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath()]);
    }
    Directory(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}.ice').toFilePath())
        .rename(Uri.file('$lineStrikeBoardTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copiedFile = renamedFile.copySync(boardDataFile.icePath);
          //cache
          String cachePath = boardDataFile.icePath.replaceFirst(Uri.file('$pso2binDirPath/data').toFilePath(), lineStrikeCustomizedCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          boardDataFile.replacedIceMd5 = await copiedFile.getMd5Hash();
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        lineStrikeStatus.value = appText.failedToReplaceBoardIcon;
        return false;
      }
    }

    Directory(lineStrikeBoardTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  return true;
}

Future<bool> customBoardImageRemove(LineStrikeBoard board, List<LineStrikeBoard> lineStrikeBoardList) async {
  File? downloadedIceFile = await originalIceDownload(board.icePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), ''), p.dirname(board.icePath), lineStrikeStatus);
  File? downloadedIconIceFile = await originalIceDownload(board.iconIcePath.replaceFirst(Uri.file('$pso2binDirPath/').toFilePath(), ''), p.dirname(board.iconIcePath), lineStrikeStatus);

  if (downloadedIceFile != null) board.replacedIceMd5 = '';
  if (downloadedIconIceFile != null) board.replacedIconIceMd5 = '';
  if (board.replacedIceMd5.isEmpty && board.replacedIconIceMd5.isEmpty) {
    board.replacedImagePath = '';
    board.isReplaced = false;
    // Remove cache
    File iceCache = File(board.icePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath));
    if (iceCache.existsSync()) await iceCache.delete(recursive: true);
    File iconIceCache = File(board.iconIcePath.replaceFirst(pso2DataDirPath, lineStrikeCustomizedCacheDirPath));
    if (iconIceCache.existsSync()) await iconIceCache.delete(recursive: true);
    saveMasterLineStrikeBoardListToJson(lineStrikeBoardList);
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

void saveMasterLineStrikeBoardListToJson(List<LineStrikeBoard> boardList) {
  //Save to json
  boardList.map((board) => board.toJson()).toList();
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  File(mainLineStrikeBoardListJsonPath).writeAsStringSync(encoder.convert(boardList));
}
