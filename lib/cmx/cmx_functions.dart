import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pso2_mod_manager/cmx/cmx_classes.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<(int startIndex, int endIndex)> cmxModPatch(String cmxModPath) async {
  //parse cmx from mod
  List<String> cmxDataFromMod = [];
  await File(cmxModPath)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((line) {
    if (line.contains(':')) {
      final lineSplit = line.split(':');
      cmxDataFromMod.add(lineSplit.first.trim());
      cmxDataFromMod.add(lineSplit.last.trim());
    } else {
      final lineSplit = line.split('=');
      cmxDataFromMod.add(lineSplit.last.trim());
    }
  });

  final cmxMod = CmxModData.parseCmxFromModNoMask(cmxDataFromMod);

  //CmxModData cmxModData = CmxModData.parseCmxFromMod(cmxDataFromMod);
  List<CmxBody> cmxCostumeList = [], cmxBasewearList = [], cmxOuterwearList = [], cmxCastArmList = [], cmxCastLegList = [], cmxHairList = [];
  (cmxCostumeList, cmxBasewearList, cmxOuterwearList, cmxCastArmList, cmxCastLegList, cmxHairList) = await cmxToObjects();
  //final testCmx = cmxOuterwearList.where((element) => element.id == 20000).toList();
  CmxBody? matchingCmxData;
  if (cmxMod.type == 'costume') {
    matchingCmxData = cmxCostumeList.firstWhere((element) => element.id == int.parse(cmxMod.id));
  } else if (cmxMod.type == 'basewear') {
    matchingCmxData = cmxBasewearList.firstWhere((element) => element.id == int.parse(cmxMod.id));
  } else if (cmxMod.type == 'outerwear') {
    matchingCmxData = cmxOuterwearList.firstWhere((element) => element.id == int.parse(cmxMod.id));
  }

  Int32List? cmxData = await cmxFileData();
    List<int> partialList = cmxData!.getRange(matchingCmxData!.startIndex, matchingCmxData.endIndex).toList();
    //replace data
    partialList[8] = int.parse(cmxMod.i20);
    partialList[13] = int.parse(cmxMod.i24);
    partialList[14] = int.parse(cmxMod.i28);
    partialList[15] = int.parse(cmxMod.i2C);
    partialList[16] = int.parse(cmxMod.costumeSoundId);
    partialList[17] = int.parse(cmxMod.headId);
    partialList[18] = int.parse(cmxMod.i38);
    partialList[19] = int.parse(cmxMod.i3C);
    partialList[20] = int.parse(cmxMod.linkedInnerId);
    partialList[21] = int.parse(cmxMod.i44);
    partialList[22] = floatTo32bitInt(double.parse(cmxMod.legLength));
    partialList[23] = floatTo32bitInt(double.parse(cmxMod.f4C));
    partialList[24] = floatTo32bitInt(double.parse(cmxMod.f50));
    partialList[25] = floatTo32bitInt(double.parse(cmxMod.f54));
    partialList[26] = floatTo32bitInt(double.parse(cmxMod.f58));
    partialList[27] = floatTo32bitInt(double.parse(cmxMod.f5C));
    partialList[28] = floatTo32bitInt(double.parse(cmxMod.f60));
    partialList[29] = int.parse(cmxMod.i64);
    if (cmxMod.redMaskMapping.isNotEmpty) partialList[9] = int.parse(cmxMod.redMaskMapping);
    if (cmxMod.greenMaskMapping.isNotEmpty) partialList[10] = int.parse(cmxMod.greenMaskMapping);
    if (cmxMod.blueMaskMapping.isNotEmpty) partialList[11] = int.parse(cmxMod.blueMaskMapping);
    if (cmxMod.alphaMaskMapping.isNotEmpty) partialList[12] = int.parse(cmxMod.alphaMaskMapping);

    int pIndex = 0;
    for (int i = matchingCmxData.startIndex; i < matchingCmxData.endIndex; i++) {
      cmxData[i] = partialList[pIndex];
      pIndex++;
  }

  //write
  String modManTempCmxDirPath = Uri.file('${Directory.current.path}/tempCmx').toFilePath();
  File cmxIceFile = File(Uri.file('$modManPso2binPath/data/win32/1c5f7a7fbcdd873336048eaf6e26cd87').toFilePath());
  File cmxFile = File(Uri.file('$modManTempCmxDirPath/${p.basename(cmxIceFile.path)}_ext/group1/pl_data_info.cmx').toFilePath());
  Uint8List newFileData = cmxData.buffer.asUint8List();
  await cmxFile.writeAsBytes(newFileData);
  //pack
  await Process.run('$modManZamboniExePath -c -pack -outdir "${p.dirname(cmxFile.parent.path)}"', [Uri.file(p.dirname(cmxFile.parent.path)).toFilePath()]);
  File packedCmxIceFile =
      File(Uri.file('$modManTempCmxDirPath/${p.basename(cmxIceFile.path)}_ext.ice').toFilePath()).renameSync(Uri.file('$modManTempCmxDirPath/${p.basename(cmxIceFile.path)}').toFilePath());
  //copy
  await packedCmxIceFile.copy(cmxIceFile.path);
  

  return (matchingCmxData.startIndex, matchingCmxData.endIndex);
}

int floatTo32bitInt(double value) {
  var valueFloat = Float32List(1);
  valueFloat.first = value;
  var listOfBytes = valueFloat.buffer.asInt32List();

  return listOfBytes.first;
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
