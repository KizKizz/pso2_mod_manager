import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:path/path.dart' as p;

Future<List<File>> modSwapRename(List<File> lItemFiles, List<File> rItemFiles, List<String> rItemIds, String rItemAccItemId, bool isBodyPaintToInnerwear, bool isInnerwearToBodyPaint) async {
  List<File> renamedFiles = [];
  //ah to rac
  //Look for corresponding T file
  final fileTWithRac = rItemFiles.where((element) => p.basenameWithoutExtension(element.path).contains('rac'));
  if (fileTWithRac.isNotEmpty) {
    List<File> renamedFilesF = [];
    for (var fFile in lItemFiles) {
      if (fFile.existsSync()) {
        List<String> namePartsF = p.basenameWithoutExtension(fFile.path).split('_');
        if (namePartsF.length > 3) {
          namePartsF[1] == 'ah' ? namePartsF[1] = 'rac' : null;
          namePartsF[3] == 'x' ? namePartsF.removeRange(3, namePartsF.length) : namePartsF.removeRange(4, namePartsF.length);
          String newFileNameF = namePartsF.join('_') + p.extension(fFile.path);
          String newFilePathF = Uri.file('${p.dirname(fFile.path)}/$newFileNameF').toFilePath();
          renamedFilesF.add(fFile.renameSync(newFilePathF));
        } else if (namePartsF[0] == 'pl' && namePartsF.length <= 3) {
          renamedFilesF.add(fFile);
        }
      }
    }
    lItemFiles = renamedFilesF;
  }

  for (var fileF in lItemFiles) {
    if (fileF.existsSync()) {
      List<String> fileNamePartsF = p.basenameWithoutExtension(fileF.path).split('_');
      String fileIdF = fileNamePartsF.firstWhere(
        (element) => int.tryParse(element) != null,
        orElse: () => '',
      );
      if (fileIdF.isNotEmpty) {
        final fileNamePartsWoId = p.basename(fileF.path).split(fileIdF);
        // final matchingFileT =
        //     rItemFiles.firstWhere((element) => p.basename(element.path).contains(fileNamePartsWoId.first) && p.basename(element.path).split('_').last == fileNamePartsWoId.last.replaceAll('_', ''), orElse: () => File(''));
        File matchingFileT = File('');
        for (var fileT in rItemFiles) {
          String fileIdT = p.basenameWithoutExtension(fileT.path).split('_').firstWhere(
                (element) => int.tryParse(element) != null,
                orElse: () => '',
              );
          final fileNamePartsWoIdT = p.basename(fileT.path).split(fileIdT);
          if (fileNamePartsWoIdT.first == fileNamePartsWoId.first && fileNamePartsWoIdT.last == fileNamePartsWoId.last) {
            matchingFileT = fileT;
            break;
          }
        }
        if (matchingFileT.path.isNotEmpty) {
          String newPath = fileF.path.replaceFirst(p.basenameWithoutExtension(fileF.path), p.basenameWithoutExtension(matchingFileT.path));
          renamedFiles.add(await fileF.rename(newPath));
        } else {
          final matchingFileNameT = rItemFiles.firstWhere(
              (element) =>
                  p.basenameWithoutExtension(element.path).contains(fileNamePartsWoId.first) && p.basenameWithoutExtension(element.path).contains(p.basenameWithoutExtension(fileNamePartsWoId.last)),
              orElse: () => File(''));
          if (matchingFileNameT.path.isNotEmpty) {
            String newPath = fileF.path.replaceFirst(p.basenameWithoutExtension(fileF.path), p.basenameWithoutExtension(matchingFileNameT.path));
            renamedFiles.add(await fileF.rename(newPath));
          } else if (p.extension(fileF.path) == '.aqm') {
            final matchingFileNameT =
                rItemFiles.firstWhere((element) => p.basenameWithoutExtension(element.path).contains(fileNamePartsWoId.first) && p.extension(element.path) == '.aqn', orElse: () => File(''));
            if (matchingFileNameT.path.isNotEmpty) {
              String matchingFileIdF = p.basenameWithoutExtension(matchingFileNameT.path).split('_').firstWhere((element) => int.tryParse(element) != null, orElse: () => '');
              if (matchingFileIdF.isNotEmpty) {
                String newPath = fileF.path.replaceFirst(fileIdF, matchingFileIdF);
                renamedFiles.add(await fileF.rename(newPath));
              }
            } else {
              if (rItemIds.isNotEmpty && rItemIds[1].isNotEmpty) {
                String newPath = fileF.path.replaceFirst(fileIdF, rItemIds[1]);
                renamedFiles.add(await fileF.rename(newPath));
              } else if (rItemIds.isNotEmpty && rItemIds[0].isNotEmpty) {
                String newPath = fileF.path.replaceFirst(fileIdF, rItemIds[0]);
                renamedFiles.add(await fileF.rename(newPath));
              } else if (rItemAccItemId.isNotEmpty) {
                String newPath = fileF.path.replaceFirst(fileIdF, rItemAccItemId);
                renamedFiles.add(await fileF.rename(newPath));
              }
            }
          } else if (p.extension(fileF.path) == '.dds') {
            final ddsFilesT = rItemFiles.where((element) => p.extension(element.path) == '.dds');
            if (ddsFilesT.isNotEmpty) {
              final ddsFilePartsT = p.basenameWithoutExtension(ddsFilesT.first.path).split('_');
              String matchingDdsFileIdT = ddsFilePartsT.firstWhere(
                (element) => int.tryParse(element) != null,
                orElse: () => '',
              );
              List<String> newDdsFileParts = p.basename(fileF.path).split('_');
              int indexOfItemIdInFileName = newDdsFileParts.indexOf(fileIdF);
              if (indexOfItemIdInFileName != -1) {
                newDdsFileParts[indexOfItemIdInFileName] = matchingDdsFileIdT;
              }
              //modification for body paints to inners
              if (isBodyPaintToInnerwear) {
                int rbaIndex = newDdsFileParts.indexOf('rba');
                if (rbaIndex != -1) {
                  newDdsFileParts[rbaIndex] = 'rbd';
                }
                if (indexOfItemIdInFileName != -1) {
                  newDdsFileParts.insert(indexOfItemIdInFileName + 1, 'iw');
                }
              }
              //modification for inners to body paints
              if (isInnerwearToBodyPaint) {
                int rbdIndex = newDdsFileParts.indexOf('rbd');
                if (rbdIndex != -1) {
                  newDdsFileParts[rbdIndex] = 'rba';
                }
                int iwIndex = newDdsFileParts.indexOf('iw');
                if (iwIndex != -1) {
                  newDdsFileParts.removeAt(iwIndex);
                }
              }
              String newFileName = newDdsFileParts.join('_');
              String newPath = Uri.file('${p.dirname(fileF.path)}/$newFileName').toFilePath();

              renamedFiles.add(await fileF.rename(newPath));
            }
          }
        }
      }
    }
  }

  return renamedFiles;
}

Future<List<File>> emoteSwapRename(List<File> lItemFiles, List<File> rItemFiles, bool isEmotesToStandbyMotions) async {
  List<File> renamedFiles = [];
  for (var fileF in lItemFiles) {
    List<String> fileNamePartsF = p.basenameWithoutExtension(fileF.path).split('_');
    File matchingFileT = File('');
    if (p.extension(fileF.path) == '.bti') {
      matchingFileT = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == fileNamePartsF[3] &&
              p.extension(element.path) == '.bti',
          orElse: () => File(''));
    } else if (fileNamePartsF.length > 3 && fileNamePartsF[1] == 'std') {
      matchingFileT = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == fileNamePartsF[3] &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
    } else if (fileNamePartsF.length > 2 && fileNamePartsF[1] == 'sb') {
      //copy .fig file over instead of rename
      File figFile = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.basenameWithoutExtension(element.path).split('_')[2] == fileNamePartsF[2] &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
      if (figFile.path.isNotEmpty) {
        figFile.copySync(fileF.path);
      }
    } else if (fileNamePartsF.length > 2 && fileNamePartsF[1] == 'la' && p.extension(fileF.path) == '.fig') {
      //copy .fig file over instead of rename
      File figFile = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
      if (figFile.path.isNotEmpty) {
        figFile.copySync(fileF.path);
      }
    } else if (isEmotesToStandbyMotions &&
        fileNamePartsF[0] == 'pl' &&
        p.extension(fileF.path) == '.aqm' &&
        (p.basenameWithoutExtension(fileF.path).contains('_std_') || p.basenameWithoutExtension(fileF.path).contains('_hum_'))) {
      //emotes to motions
      File aqmFile = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == '00120' &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
      if (aqmFile.path.isNotEmpty) {
        renamedFiles.add(await fileF.rename(Uri.file('${fileF.parent.path}/${p.basename(aqmFile.path)}').toFilePath()));
      }
    } else if (fileNamePartsF.length > 2 && rItemFiles.where((element) => p.basename(element.path) == p.basename(fileF.path)).isNotEmpty) {
      renamedFiles.add(fileF);
    } else if (fileNamePartsF.length > 2) {
      matchingFileT = rItemFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
    }
    if (matchingFileT.path.isNotEmpty) {
      String newPath = fileF.path.replaceFirst(p.basenameWithoutExtension(fileF.path), p.basenameWithoutExtension(matchingFileT.path));
      renamedFiles.add(await fileF.rename(newPath));
    }
  }

  return renamedFiles;
}

extension IndexOfElements<T> on List<T> {
  int indexOfElements(List<T> elements, [int start = 0]) {
    if (elements.isEmpty) return start;
    var end = length - elements.length;
    if (start > end) return -1;
    var first = elements.first;
    var pos = start;
    while (true) {
      pos = indexOf(first, pos);
      if (pos < 0 || pos >= end) return -1;
      for (var i = 1; i < elements.length; i++) {
        if (this[pos + i] != elements[i]) {
          if (pos < 0 || pos >= end) return -1;
          pos++;
          i = 1;
          continue;
        }
      }
      return pos;
    }
  }
}

Future<void> modSwapTempDirsCreate() async {
  await Directory(modSwapTempLItemDirPath).create(recursive: true);
  await Directory(modSwapTempRItemDirPath).create(recursive: true);
  await Directory(modSwapTempOutputDirPath).create(recursive: true);
}

Future<void> modSwapTempDirsRemove() async {
  if (Directory(modSwapTempDirPath).existsSync()) await Directory(modSwapTempDirPath).delete(recursive: true);
}

Future<File> modSwapOriginalFileDownload(String networkFilePath, String server, String saveLocation) async {
  String fileServerURL = server == 'm' ? segaMasterServerURL : segaPatchServerURL;
  if (networkFilePath.isNotEmpty) {
    final task = DownloadTask(
        url: '$fileServerURL$networkFilePath',
        filename: p.basenameWithoutExtension(networkFilePath),
        headers: {"User-Agent": "AQUA_HTTP"},
        directory: saveLocation,
        updates: Updates.statusAndProgress,
        retries: 1,
        allowPause: false);

    final result = await FileDownloader().download(task,
        onProgress: (progress) => itemSwapWorkingStatus.value = '${appText.dText(appText.downloadingFileName, p.basenameWithoutExtension(networkFilePath))} [ ${(progress * 100).round()}% ]');

    switch (result.status) {
      case TaskStatus.complete:
        itemSwapWorkingStatus.value = appText.fileDownloadSuccessful;
        return File(saveLocation + p.separator + p.basenameWithoutExtension(networkFilePath));
      default:
        itemSwapWorkingStatus.value = appText.fileDownloadFailed;
    }
  }
  return File('');
}

SubMod lItemSubmodGet(ItemData lItemData) {
  List<ModFile> modFileList = [];
  String fromItemNameSwap = '${lItemData.getName().replaceAll('/', '_')}_${appText.swap}';
  for (var iceNameWithType in lItemData.getIceDetails()) {
    String iceName = p.basenameWithoutExtension(iceNameWithType.split(': ').last);

    //look in backupDir first
    // final iceFileInBackupDir =
    //     Directory(Uri.file(modManBackupsDirPath).toFilePath()).listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '', orElse: () => File(''));
    // if (p.basename(iceFileInBackupDir.path) == iceName) {
    //   modFileList
    //       .add(ModFile(iceName, fromItemNameSwap, fromItemNameSwap, fromItemNameSwap, selectedCategoryF!, '', [], iceFileInBackupDir.path, false, DateTime(0), 0, false, false, false, [], [], []));
    // } else {
    final icePathFromOgData = oItemData
        .firstWhere(
          (element) => p.basenameWithoutExtension(element.path) == iceName,
          orElse: () => OfficialIceFile('', '', 0, ''),
        )
        .path;
    if (p.basenameWithoutExtension(icePathFromOgData) == iceName) {
      modFileList.add(ModFile(iceName, fromItemNameSwap, fromItemNameSwap, fromItemNameSwap, lItemData.category, '', [], pso2DataDirPath + p.separator + p.fromUri(Uri.parse(icePathFromOgData)), false,
          DateTime(0), 0, false, false, false, [], [], [], [], [], []));
    }
    //}
  }

  return SubMod(fromItemNameSwap, fromItemNameSwap, lItemData.getName(), lItemData.category, '', false, DateTime(0), 0, false, false, false, false, false, -1, -1, '', [], [], [], [], [], modFileList);
}

Mod lItemModGet() {
  return Mod('', '', '', '', false, DateTime(0), 0, false, false, false, [], [], [], [], []);
}
