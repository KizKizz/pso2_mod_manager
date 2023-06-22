import 'dart:io';

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
      List<String> namePartsF = p.basenameWithoutExtension(fFile.path).split('_');
      namePartsF[1] == 'ah' ? namePartsF[1] = 'rac' : null;
      namePartsF[3] == 'x' ? namePartsF.removeRange(3, namePartsF.length) : namePartsF.removeRange(4, namePartsF.length);
      String newFileNameF = namePartsF.join('_') + p.extension(fFile.path);
      String newFilePathF = Uri.file('${p.dirname(fFile.path)}/$newFileNameF').toFilePath();
      renamedFilesF.add(fFile.renameSync(newFilePathF));
    }
    fFiles = renamedFilesF;
  }

  for (var fileF in fFiles) {
    List<String> fileNamePartsF = p.basename(fileF.path).split('_');
    String fileIdF = fileNamePartsF.firstWhere(
      (element) => int.tryParse(element) != null,
      orElse: () => '',
    );
    final fileNamePartsWoId = p.basename(fileF.path).split(fileIdF);
    final matchingFileT =
        tFiles.firstWhere((element) => p.basename(element.path).contains(fileNamePartsWoId.first) && p.basename(element.path).contains(fileNamePartsWoId.last), orElse: () => File(''));
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
      }
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
