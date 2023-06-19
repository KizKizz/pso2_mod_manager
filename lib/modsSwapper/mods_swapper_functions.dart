import 'dart:io';

import 'package:pso2_mod_manager/modsSwapper/mods_swapper_homepage.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<File>> modsSwapRename(List<File> fFiles, List<File> tFiles) async {
  List<File> renamedFiles = [];
  for (var fileF in fFiles) {
    List<String> fileNamePartsF = p.basename(fileF.path).split('_');
    String fileId = fileNamePartsF.firstWhere(
      (element) => element.length > 3 && int.tryParse(element) != null,
      orElse: () => '',
    );
    final fileNamePartsWoId = p.basename(fileF.path).split(fileId);
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
      } else {

        if (toItemIds[1].isNotEmpty) {
          String newPath = fileF.path.replaceFirst(fileId, toItemIds[1]);
          renamedFiles.add(await fileF.rename(newPath));
        } else {
          String newPath = fileF.path.replaceFirst(fileId, toItemIds[0]);
          renamedFiles.add(await fileF.rename(newPath));
        }
      }
    }
  }
  return renamedFiles;
}
