import 'dart:io';

import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<File>> modsSwapRename(List<File> fFiles, List<File> tFiles) async {
  List<File> renamedFiles = [];
  //ah to rac
  //Look for corresponding T file
  final fileTWithRac = tFiles.where((element) => p.basenameWithoutExtension(element.path).contains('rac'));
  if (fileTWithRac.isNotEmpty) {
    List<File> renamedFilesF = [];
    for (var fFile in fFiles) {
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
    fFiles = renamedFilesF;
  }

  for (var fileF in fFiles) {
    if (fileF.existsSync()) {
      List<String> fileNamePartsF = p.basenameWithoutExtension(fileF.path).split('_');
      String fileIdF = fileNamePartsF.firstWhere(
        (element) => int.tryParse(element) != null,
        orElse: () => '',
      );
      final fileNamePartsWoId = p.basename(fileF.path).split(fileIdF);
      // final matchingFileT =
      //     tFiles.firstWhere((element) => p.basename(element.path).contains(fileNamePartsWoId.first) && p.basename(element.path).split('_').last == fileNamePartsWoId.last.replaceAll('_', ''), orElse: () => File(''));
      File matchingFileT = File('');
      for (var fileT in tFiles) {
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
        final matchingFileNameT = tFiles.firstWhere(
            (element) =>
                p.basenameWithoutExtension(element.path).contains(fileNamePartsWoId.first) && p.basenameWithoutExtension(element.path).contains(p.basenameWithoutExtension(fileNamePartsWoId.last)),
            orElse: () => File(''));
        if (matchingFileNameT.path.isNotEmpty) {
          String newPath = fileF.path.replaceFirst(p.basenameWithoutExtension(fileF.path), p.basenameWithoutExtension(matchingFileNameT.path));
          renamedFiles.add(await fileF.rename(newPath));
        } else if (p.extension(fileF.path) == '.aqm') {
          final matchingFileNameT =
              tFiles.firstWhere((element) => p.basenameWithoutExtension(element.path).contains(fileNamePartsWoId.first) && p.extension(element.path) == '.aqn', orElse: () => File(''));
          if (matchingFileNameT.path.isNotEmpty) {
            String matchingFileIdF = p.basenameWithoutExtension(matchingFileNameT.path).split('_').firstWhere((element) => int.tryParse(element) != null, orElse: () => '');
            if (matchingFileIdF.isNotEmpty) {
              String newPath = fileF.path.replaceFirst(fileIdF, matchingFileIdF);
              renamedFiles.add(await fileF.rename(newPath));
            }
          } else {
            if (toItemIds.isNotEmpty && toItemIds[1].isNotEmpty) {
              String newPath = fileF.path.replaceFirst(fileIdF, toItemIds[1]);
              renamedFiles.add(await fileF.rename(newPath));
            } else if (toItemIds.isNotEmpty && toItemIds[0].isNotEmpty) {
              String newPath = fileF.path.replaceFirst(fileIdF, toItemIds[0]);
              renamedFiles.add(await fileF.rename(newPath));
            } else if (toAccItemId.isNotEmpty) {
              String newPath = fileF.path.replaceFirst(fileIdF, toAccItemId);
              renamedFiles.add(await fileF.rename(newPath));
            }
          }
        } else if (p.extension(fileF.path) == '.dds') {
          final ddsFilesT = tFiles.where((element) => p.extension(element.path) == '.dds');
          if (ddsFilesT.isNotEmpty) {
            final ddsFilePartsF = p.basenameWithoutExtension(ddsFilesT.first.path).split('_');
            String matchingDdsFileIdT = ddsFilePartsF.firstWhere(
              (element) => int.tryParse(element) != null,
              orElse: () => '',
            );
            String newPath = fileF.path.replaceFirst(fileIdF, matchingDdsFileIdT);
            renamedFiles.add(await fileF.rename(newPath));
          }
        }
      }
    }
  }

  return renamedFiles;
}

Future<List<File>> lasSwapRename(List<File> fFiles, List<File> tFiles) async {
  List<File> renamedFiles = [];
  for (var fileF in fFiles) {
    List<String> fileNamePartsF = p.basenameWithoutExtension(fileF.path).split('_');
    File matchingFileT = File('');
    if (p.extension(fileF.path) == '.bti') {
      matchingFileT = tFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == fileNamePartsF[3] &&
              p.extension(element.path) == '.bti',
          orElse: () => File(''));
    } else if (fileNamePartsF.length > 3 && fileNamePartsF[1] == 'std') {
      matchingFileT = tFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[1] == fileNamePartsF[1] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == fileNamePartsF[3] &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
    } else if (fileNamePartsF.length > 2 && fileNamePartsF[1] == 'sb') {
      //copy .fig file over instead of rename
      File figFile = tFiles.firstWhere(
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
      File figFile = tFiles.firstWhere(
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
      File aqmFile = tFiles.firstWhere(
          (element) =>
              p.basenameWithoutExtension(element.path).split('_')[0] == fileNamePartsF[0] &&
              p.basenameWithoutExtension(element.path).split('_')[3] == '00120' &&
              p.extension(element.path) == p.extension(fileF.path),
          orElse: () => File(''));
      if (aqmFile.path.isNotEmpty) {
        renamedFiles.add(await fileF.rename(Uri.file('${fileF.parent.path}/${p.basename(aqmFile.path)}').toFilePath()));
      }
    } else if (fileNamePartsF.length > 2 && tFiles.where((element) => p.basename(element.path) == p.basename(fileF.path)).isNotEmpty) {
      renamedFiles.add(fileF);
    } else if (fileNamePartsF.length > 2) {
      matchingFileT = tFiles.firstWhere(
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
