import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/cmx/cmx_classes.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

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
  List<CmxBody> cmxCostumeList = [], cmxBasewearList = [], cmxOuterwearList = [], cmxCastArmList = [], cmxCastLegList = [], cmxHairList = [];
  (cmxCostumeList, cmxBasewearList, cmxOuterwearList, cmxCastArmList, cmxCastLegList, cmxHairList) = await cmxToObjects();
  final testCmx = cmxOuterwearList.where((element) => element.id == 20000).toList();

  return true;
}

Future<(List<CmxBody>, List<CmxBody>, List<CmxBody>, List<CmxBody>, List<CmxBody>, List<CmxBody>)> cmxToObjects() async {
  List<CmxBody> cmxCostumeList = [], cmxBasewearList = [], cmxOuterwearList = [], cmxCastArmList = [], cmxCastLegList = [], cmxHairList = [];
  List<int> costumeOuterwearSepValues = List.generate(11, (index) => 100);
  List<int> bodySepValues = List.generate(4, (index) => -1082130432);
  Int32List? cmxData = await cmxFileData();
  List<int> costumeIndexes = [], outerwearIndexes = [], basewearIndexes = [];
  bool headerRemoved = false;
  int startIndex = 0;
  String curDataMark = 'costume';

  //remove header
  if (!headerRemoved) {
    int headerEndIndex = cmxData!.indexWhere((element) => element == -1);
    if (headerEndIndex != -1) {
      startIndex = headerEndIndex++;
      costumeIndexes.add(headerEndIndex++);
    }
  }

  while (startIndex < cmxData.length) {
    int costumeOuterSepIndex = cmxData.indexOfSeparatorElements(costumeOuterwearSepValues, startIndex);
    if (costumeOuterSepIndex != -1) {
      curDataMark = 'outerwear';
      outerwearIndexes.add(costumeOuterSepIndex);
    }

    int itemIndex = cmxData.indexOfSeparatorElements(bodySepValues, startIndex);
    if (itemIndex != -1) {
      //outer and basewear break
      if (cmxData[itemIndex] == 20000 && outerwearIndexes.indexWhere((index) => cmxData[index] == 20000) != -1) {
        curDataMark = 'basewear';
      }
      if (curDataMark == 'costume') {
        costumeIndexes.add(itemIndex);
      } else if (curDataMark == 'outerwear') {
        outerwearIndexes.add(itemIndex);
      } else if (curDataMark == 'basewear') {
        basewearIndexes.add(itemIndex);
      }
      startIndex = itemIndex;
    } else {
      startIndex++;
    }
  }

  for (int i = 0; i < costumeIndexes.length; i++) {
    int start = costumeIndexes[i];
    int last = 0;
    if (i + 1 == costumeIndexes.length) {
      last = costumeIndexes[i] + 50;
    } else {
      last = costumeIndexes[i + 1] - 1;
    }
    cmxCostumeList.add(CmxBody.parseFromCostumeDataList('costume', cmxData.sublist(start, last), start, last));
  }

  for (int i = 0; i < outerwearIndexes.length; i++) {
    int start = outerwearIndexes[i];
    int last = 0;
    if (i + 1 == outerwearIndexes.length) {
      last = outerwearIndexes[i] + 50;
    } else {
      last = outerwearIndexes[i + 1] - 1;
    }
    cmxOuterwearList.add(CmxBody.parseFromCostumeDataList('outerwear', cmxData.sublist(start, last), start, last));
  }

  for (int i = 0; i < basewearIndexes.length; i++) {
    int start = basewearIndexes[i];
    int last = 0;
    if (i + 1 == basewearIndexes.length) {
      last = basewearIndexes[i] + 50;
    } else {
      last = basewearIndexes[i + 1] - 1;
    }
    cmxBasewearList.add(CmxBody.parseFromCostumeDataList('basewear', cmxData.sublist(start, last), start, last));
  }

  return (cmxCostumeList, cmxBasewearList, cmxOuterwearList, cmxCastArmList, cmxCastLegList, cmxHairList);
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

Uint8List int32bytes(int value) => Uint8List(4)..buffer.asInt32List()[0] = value;

extension IndexOfSeparatorElements<T> on List<T> {
  int indexOfSeparatorElements(List<T> elements, [int start = 0]) {
    if (start + elements.length > length) return -1;

    List<bool> found = List.generate(elements.length, (index) => false);

    int traverseIndex = start;
    for (int i = 0; i < elements.length; i++) {
      if (this[traverseIndex] == elements[i]) {
        found[i] = true;
      }
      traverseIndex++;
    }

    if (found.where((element) => element == false).isEmpty) {
      return traverseIndex++;
    } else {
      return -1;
    }
  }
}
