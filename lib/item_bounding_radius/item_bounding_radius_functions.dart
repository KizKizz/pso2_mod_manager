import 'dart:io';
import 'dart:typed_data';

import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bits_convert.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/modified_ice_file_save.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Signal<String> modRemovingBoundingStatus = Signal('');

Future<bool> itemBoundingRadiusRemove(context, SubMod submod) async {
  Directory(modBoundingRadiusTempDirPath).createSync(recursive: true);
  List<String> boundaryRemovedFiles = [];
  List<String> boundaryNotFoundFiles = [];
  int packRetries = 0;
  await Future.delayed(const Duration(milliseconds: 10));
  List<ModFile> matchingFiles = submod.modFiles.where((element) => p.extension(element.location).isEmpty).toList();
  if (matchingFiles.isNotEmpty) {
    modRemovingBoundingStatus.value = appText.matchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
    for (var modFile in matchingFiles) {
      modRemovingBoundingStatus.value = appText.dText(appText.extractingFile, modFile.modFileName);
      await Future.delayed(const Duration(milliseconds: 10));
      List<File> extractedGroup1Files = [];
      List<File> extractedGroup2Files = [];
      //extract files
      if (Platform.isLinux) {
        await Process.run('wine $zamboniExePath -outdir "$modBoundingRadiusTempDirPath"', [modFile.location]);
      } else {
        await Process.run('$zamboniExePath -outdir "$modBoundingRadiusTempDirPath"', [modFile.location]);
      }
      String extractedGroup1Path = Uri.file('$modBoundingRadiusTempDirPath/${modFile.modFileName}_ext/group1').toFilePath();
      if (Directory(extractedGroup1Path).existsSync()) {
        extractedGroup1Files = Directory(extractedGroup1Path).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathF = Uri.file('$modBoundingRadiusTempDirPath/${modFile.modFileName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathF).existsSync()) {
        extractedGroup2Files = Directory(extractedGroup2PathF).listSync(recursive: true).whereType<File>().toList();
      }
      //Get aqp files
      List<File> aqpFiles = [];
      aqpFiles.addAll(extractedGroup1Files.where((element) => p.extension(element.path) == '.aqp'));
      aqpFiles.addAll(extractedGroup2Files.where((element) => p.extension(element.path) == '.aqp'));
      if (aqpFiles.isNotEmpty) {
        for (var aqpFile in aqpFiles) {
          modRemovingBoundingStatus.value = appText.dText(appText.readingFile, p.basename(aqpFile.path));
          await Future.delayed(const Duration(milliseconds: 10));
          if (File(aqpFile.path).existsSync()) {
            Uint8List aqpBytes = await File(aqpFile.path).readAsBytes();
            File('${Directory.current.path}${p.separator}${p.basenameWithoutExtension(modFile.modFileName)} - ${p.basenameWithoutExtension(aqpFile.path)}.txt').writeAsStringSync(aqpBytes.join(' '));

            if (aqpBytes[233] == 0 && aqpBytes[234] == 0 && aqpBytes[235] == 0) {
              modRemovingBoundingStatus.value = appText.dText(appText.boundingValueFoundReplacingWithNewValue, boundingRadiusRemovalValue.toString());
              await Future.delayed(const Duration(milliseconds: 10));

              // Get new value
              final boundingRadiusValue = float32ToIntListConvert(boundingRadiusRemovalValue);

              aqpBytes[236] = boundingRadiusValue[0];
              aqpBytes[237] = boundingRadiusValue[1];
              aqpBytes[238] = boundingRadiusValue[2];
              aqpBytes[239] = boundingRadiusValue[3];
              aqpFile.writeAsBytesSync(Uint8List.fromList(aqpBytes));

              //pack
              while (!File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).existsSync()) {
                modRemovingBoundingStatus.value = appText.dText(appText.repackingFile, p.basenameWithoutExtension(aqpFile.parent.path));
                await Future.delayed(const Duration(milliseconds: 10));
                if (Platform.isLinux) {
                  await Process.run('wine $zamboniExePath -c -pack -outdir "${p.dirname(aqpFile.parent.path)}"', [Uri.file(p.dirname(aqpFile.parent.path)).toFilePath()]);
                } else {
                  await Process.run('$zamboniExePath -c -pack -outdir "${p.dirname(aqpFile.parent.path)}"', [Uri.file(p.dirname(aqpFile.parent.path)).toFilePath()]);
                }
                packRetries++;
                if (packRetries == 5) {
                  break;
                }
              }
              packRetries = 0;
              try {
                File renamedFile = await File(Uri.file('${p.dirname(aqpFile.parent.path)}.ice').toFilePath()).rename(Uri.file(p.dirname(aqpFile.parent.path).replaceAll('_ext', '')).toFilePath());
                await renamedFile.copy(modFile.location);
                // Add to modified
                modifiedIceAdd(p.basenameWithoutExtension(renamedFile.path));
                modRemovingBoundingStatus.value = appText.successful;
                await Future.delayed(const Duration(milliseconds: 10));
              } catch (e) {
                modRemovingBoundingStatus.value = e.toString();
              }
              boundaryRemovedFiles.add(modFile.modFileName);
            } else {
              modRemovingBoundingStatus.value = appText.dText(appText.boundingValueNotFoundInFile, modFile.modFileName);
              boundaryNotFoundFiles.add(modFile.modFileName);
            }
          }
        }
      } else {
        boundaryNotFoundFiles.add(modFile.modFileName);
      }
    }
    if (boundaryNotFoundFiles.isNotEmpty) return true;
  } else {
    modRemovingBoundingStatus.value = appText.noMatchingFilesFound;
    await Future.delayed(const Duration(milliseconds: 10));
  }
  return false;
}
