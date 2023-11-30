import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/cmx/cmx_classes.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

int cmxCostumeSeparationValue = -1082130432;

Future<bool> cmxModPatch(String cmxModPath) async {
  //parse cmx from mod
  // List<String> cmxDataFromMod = [];
  // await File(cmxModPath).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
  //   if (line.contains(':')) {
  //     final lineSplit = line.split(':');
  //     cmxDataFromMod.add(lineSplit.first.trim());
  //     cmxDataFromMod.add(lineSplit.last.trim());
  //   } else {
  //     final lineSplit = line.split('=');
  //     cmxDataFromMod.add(lineSplit.last.trim());
  //   }
  // });

  //CmxModData cmxModData = CmxModData.parseCmxFromMod(cmxDataFromMod);
  List<CmxBody> cmxCostumeList = [], cmxBasewearList = [], cmxOuterwearList = [], cmxCastArmList = [], cmxCastLegList = [];
  (cmxCostumeList, cmxBasewearList, cmxOuterwearList, cmxCastArmList, cmxCastLegList) = await cmxToObjects();

  return true;
}

Future<(List<CmxBody>, List<CmxBody>, List<CmxBody>, List<CmxBody>, List<CmxBody>)> cmxToObjects() async {
  List<CmxBody> cmxCostumeList = [], cmxBasewearList = [], cmxOuterwearList = [], cmxCastArmList = [], cmxCastLegList = [];
  Int32List? cmxData = await cmxFileData();
  bool headerRemoved = false;
  int startIndex = 0;
  while (startIndex <= cmxData!.length) {
    //remove header
    if (!headerRemoved) {
      int headerEndIndex = cmxData.indexWhere((element) => element == -1);
      if (headerEndIndex != -1) {
        startIndex = headerEndIndex + 1;
        headerRemoved = true;
      }
    } else {
      //listing costume cmx
      int firstSeparatorIndex = -1;
      int curIndex = startIndex;
      while (firstSeparatorIndex == -1) {
        if (cmxData[curIndex] != cmxCostumeSeparationValue) {
          curIndex++;
        } else {
          debugPrint('${cmxData[curIndex + 1]}\n${cmxData[curIndex + 2]}\n${cmxData[curIndex + 3]}');

          if (cmxData[curIndex + 1] == cmxCostumeSeparationValue && cmxData[curIndex + 2] == cmxCostumeSeparationValue && cmxData[curIndex + 3] == cmxCostumeSeparationValue) {
            
            cmxCostumeList.add(CmxBody.parseFromCostumeDataList('costume', cmxData.sublist(startIndex, curIndex), startIndex, curIndex - 1));
            firstSeparatorIndex = curIndex;
            startIndex = 99999999999999999;
            break;
          } else {
            curIndex++;
          }
        }
      }
      // if (firstSeparatorIndex != -1) {
      //   List<int> valueList = cmxIntList.getRange(0, firstSeparatorIndex).toList();
      //   cmxCostumeList.add(CmxBody.parseFromCostumeDataList('costume', valueList, startIndex, firstSeparatorIndex + startIndex - 1));
      //   startIndex = firstSeparatorIndex + startIndex - 1;
      //   cmxIntList.removeRange(0, firstSeparatorIndex + 4);
      // }
    }
  }

  return (cmxCostumeList, cmxBasewearList, cmxOuterwearList, cmxCastArmList, cmxCastLegList);
}

Future<Int32List?> cmxFileData() async {
  File cmxIceFile = File(Uri.file('$modManPso2binPath/data/win32/1c5f7a7fbcdd873336048eaf6e26cd87').toFilePath());
  if (cmxIceFile.existsSync()) {
    String modManTempCmxDirPath = Uri.file('${Directory.current.path}/tempCmx').toFilePath();
    Directory(modManTempCmxDirPath).createSync(recursive: true);
    await Process.run('$modManZamboniExePath -outdir "$modManTempCmxDirPath"', [cmxIceFile.path]);
    File cmxFile = File(Uri.file('$modManTempCmxDirPath/${p.basename(cmxIceFile.path)}_ext/group1/pl_data_info.cmx').toFilePath());
    if (cmxFile.existsSync()) {
      Uint8List cmxBytes = await cmxFile.readAsBytes();
      return Int32List.fromList(cmxBytes.buffer.asInt32List());
    }
  }

  return null;
}
