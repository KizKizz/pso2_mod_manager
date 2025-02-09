import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';

Future<Directory> modSwapAccessories(
    context, bool isVanillaItemSwap, Mod fromMod, SubMod fromSubmod, List<String> lItemAvailableIces, List<String> rItemAvailableIces, String rItemName, String rItemID) async {
  // Clean and create temp dirs
  await modSwapTempDirsRemove();
  await modSwapTempDirsCreate();

  String tempSubmodPathF = Uri.file('$modSwapTempLItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  String tempSubmodPathT = Uri.file('$modSwapTempRItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  List<List<String>> iceSwappingList = [];

  rItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  rItemAvailableIces.isEmpty ? itemSwapWorkingStatus.value = appText.noMatchingFilesBetweenItemsToSwap : appText.sortingFileData;

  //map coresponding files to swap
  for (var itemT in rItemAvailableIces) {
    String curIceType = '';
    //change T ices to HD types
    if (lItemAvailableIces.where((element) => element.contains('High Quality')).isNotEmpty && replaceLQTexturesWithHQ) {
      String tempIceTypeT = itemT.replaceFirst('Normal Quality', 'High Quality');
      curIceType = tempIceTypeT.split(': ').first;
    } else {
      curIceType = itemT.split(': ').first;
    }
    int matchingLItemIndex = lItemAvailableIces.indexWhere((element) => element.split(': ').first == curIceType);
    if (matchingLItemIndex != -1) {
      iceSwappingList.add([lItemAvailableIces[matchingLItemIndex].split(': ').last, itemT.split(': ').last]);
    }
  }

  if (iceSwappingList.isEmpty) {
    itemSwapWorkingStatus.value = appText.noMatchingFilesBetweenItemsToSwap;
    return Directory(Uri.file('$modSwapTempOutputDirPath/$rItemName').toFilePath());
  }

  for (var pair in iceSwappingList) {
    //F ice prep
    String lItemIceName = pair[0];
    String rItemIceName = pair[1];
    List<File> extractedGroup1FilesF = [];
    List<File> extractedGroup2FilesF = [];
    List<File> extractedGroup1FilesT = [];
    List<File> extractedGroup2FilesT = [];

    //copy or download files to temp fromitem dir
    File lItemIceFileInTemp = File('');
    if (isVanillaItemSwap) {
      //get ice path
      final matchedlItemData = oItemData.firstWhere(
        (e) => p.basenameWithoutExtension(e.path) == lItemIceName,
        orElse: () => OfficialIceFile('', '', 0, ''),
      );
      lItemIceFileInTemp = await modSwapOriginalFileDownload(matchedlItemData.path, matchedlItemData.server, modSwapTempLItemDirPath);
    } else {
      int modFileIndexF = fromSubmod.modFiles.indexWhere((element) => element.modFileName == lItemIceName);
      if (modFileIndexF != -1) {
        final modFileF = fromSubmod.modFiles[modFileIndexF];
        lItemIceFileInTemp = await File(modFileF.location).copy(Uri.file('$modSwapTempLItemDirPath/$lItemIceName').toFilePath());
      }
    }
    //extract F ice to
    if (lItemIceFileInTemp.path.isNotEmpty) {
      await Process.run('$zamboniExePath -outdir "$tempSubmodPathF"', [lItemIceFileInTemp.path]);
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathF).existsSync()) {
        extractedGroup1FilesF = Directory(extractedGroup1PathF).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathF).existsSync()) {
        extractedGroup2FilesF = Directory(extractedGroup2PathF).listSync(recursive: true).whereType<File>().toList();
      }
    }

    //copy to temp toitem dir
    final matchedrItemData = oItemData.firstWhere(
      (e) => p.basenameWithoutExtension(e.path) == rItemIceName,
      orElse: () => OfficialIceFile('', '', 0, ''),
    );
    String icePathFromOgDataT = matchedrItemData.path;
    if (icePathFromOgDataT.isNotEmpty) {
      //final iceFileInTempT = await File(icePathFromOgDataT).copy(Uri.file('$modSwapTempRItemDirPath/${p.basename(icePathFromOgDataT)}').toFilePath());
      //download from file from server
      final iceFileInTempT = await modSwapOriginalFileDownload(icePathFromOgDataT, matchedrItemData.server, modSwapTempRItemDirPath);
      await Process.run('$zamboniExePath -outdir "$tempSubmodPathT"', [iceFileInTempT.path]);
      String extractedGroup1PathT = Uri.file('$tempSubmodPathT/${rItemIceName}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathT).existsSync()) {
        extractedGroup1FilesT = Directory(extractedGroup1PathT).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathT = Uri.file('$tempSubmodPathT/${rItemIceName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathT).existsSync()) {
        extractedGroup2FilesT = Directory(extractedGroup2PathT).listSync(recursive: true).whereType<File>().toList();
      }
    }

    //group1 > group1
    List<File> renamedExtractedGroup1Files = [];
    if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await modSwapRename(extractedGroup1FilesF, extractedGroup1FilesT, [], rItemID, false, false);
    } else if (extractedGroup1FilesF.isEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await modSwapRename(extractedGroup2FilesF, extractedGroup1FilesT, [], rItemID, false, false);
    } else if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isEmpty) {
      renamedExtractedGroup1Files = await modSwapRename(extractedGroup1FilesF, extractedGroup2FilesT, [], rItemID, false, false);
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath();
      if (!Directory(extractedGroup2PathF).existsSync()) {
        Directory(extractedGroup2PathF).createSync();
        for (var file in renamedExtractedGroup1Files) {
          file.renameSync(Uri.file('$extractedGroup2PathF/${p.basename(file.path)}').toFilePath());
        }
      }
    }

    //group2 > group2
    List<File> renamedExtractedGroup2Files = [];
    if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await modSwapRename(extractedGroup2FilesF, extractedGroup2FilesT, [], rItemID, false, false);
    } else if (extractedGroup2FilesF.isEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await modSwapRename(extractedGroup1FilesF, extractedGroup2FilesT, [], rItemID, false, false);
    } else if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isEmpty) {
      renamedExtractedGroup2Files = await modSwapRename(extractedGroup2FilesF, extractedGroup1FilesT, [], rItemID, false, false);
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath();
      if (!Directory(extractedGroup1PathF).existsSync()) {
        Directory(extractedGroup1PathF).createSync();
        for (var file in renamedExtractedGroup2Files) {
          file.renameSync(Uri.file('$extractedGroup1PathF/${p.basename(file.path)}').toFilePath());
        }
      }
    }

    //copy extra files & remove extras
    if (renamedExtractedGroup1Files.isNotEmpty) {
      for (var extractedFileT in extractedGroup1FilesT) {
        if (renamedExtractedGroup1Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup1Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }
    if (renamedExtractedGroup2Files.isNotEmpty) {
      for (var extractedFileT in extractedGroup2FilesT) {
        if (renamedExtractedGroup2Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup2Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }

    //rename texture in aqp
    //group1
    String group1ExtractedItemPathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath();
    if (Directory(group1ExtractedItemPathF).existsSync()) {
      //get renamed dds in F
      final renamedDdsFilesF = Directory(group1ExtractedItemPathF).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.dds');
      final renamedDdsNamesF = renamedDdsFilesF.map((e) => p.basename(e.path)).toList();
      //get old dds in F
      List<String> ogDdsNamesF = [];
      if (extractedGroup1FilesF.isNotEmpty) {
        ogDdsNamesF = extractedGroup1FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      } else {
        ogDdsNamesF = extractedGroup2FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      }
      //get .aqp
      File aqpInDirF = Directory(group1ExtractedItemPathF).listSync(recursive: true).whereType<File>().firstWhere(
            (element) => p.extension(element.path) == '.aqp',
            orElse: () => File(''),
          );
      if (aqpInDirF.path.isNotEmpty) {
        Uint8List aqpBytesRead = await aqpInDirF.readAsBytes();
        List<int> aqpBytes = [];
        aqpBytes.addAll(aqpBytesRead);
        for (var ddsF in ogDdsNamesF) {
          List<String> ddsFParts = ddsF.split('_');
          String ddsFId = ddsFParts.firstWhere((element) => element.length > 3 && int.tryParse(element) != null);
          List<String> ddsWoId = ddsF.split(ddsFId);
          int ddsIndex = -1;
          List<String> ddsTypes = ['d.dds', 'm.dds', 'n.dds', 's.dds'];
          if (renamedDdsNamesF.where((element) => element.split('_').length > 1 && element.split('_')[1] == 'rac' && !ddsTypes.contains(element.split('_').last)).isNotEmpty) {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').split('_').first);
          } else if (renamedDdsNamesF.where((element) => element.split('_').length > 1 && element.split('_')[1] == 'rac' && ddsTypes.contains(element.split('_').last)).isNotEmpty) {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basename(element).contains(ddsWoId.last));
            //pso2 textures to ngs texture in aqp
            if (ddsIndex == -1 && renamedDdsNamesF.where((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').trim().split('_').first).isNotEmpty) {
              ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').trim().split('_').first);
            }
          } else {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => element.contains(ddsWoId.first) && element.contains(ddsWoId.last));
          }
          if (ddsIndex != -1) {
            Uint8List ddsFBytes = Uint8List.fromList(ddsF.codeUnits);
            Uint8List ddsTBytes = Uint8List.fromList(renamedDdsNamesF[ddsIndex].codeUnits);
            int firstMatchingIndex = aqpBytesRead.indexOfElements(ddsFBytes);
            // if (firstMatchingIndex != -1) {
            //   if (ddsFBytes.length > ddsTBytes.length) {
            //     List<String> paddingTextList = List.filled(ddsFBytes.length - ddsTBytes.length, String.fromCharCode(aqpBytes[firstMatchingIndex + ddsFBytes.length + 1]));
            //     Uint8List paddingText = Uint8List.fromList(paddingTextList.join().codeUnits);
            //     aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsFBytes.length, ddsTBytes + paddingText);
            //   } else {
            //     aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsTBytes.length, ddsTBytes);
            //   }
            //   aqpInDirF.writeAsBytesSync(Uint8List.fromList(aqpBytes));
            // }
            while (firstMatchingIndex != -1) {
              if (ddsFBytes.length > ddsTBytes.length) {
                List<String> paddingTextList = List.filled(ddsFBytes.length - ddsTBytes.length, String.fromCharCode(aqpBytes[firstMatchingIndex + ddsFBytes.length + 1]));
                Uint8List paddingText = Uint8List.fromList(paddingTextList.join().codeUnits);
                aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsFBytes.length, ddsTBytes + paddingText);
              } else {
                aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsTBytes.length, ddsTBytes);
              }
              aqpInDirF.writeAsBytesSync(Uint8List.fromList(aqpBytes));
              firstMatchingIndex = aqpBytes.indexOfElements(ddsFBytes);
            }
          }
        }
      }
    }

    //group2
    String group2ExtractedItemPathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath();
    if (Directory(group2ExtractedItemPathF).existsSync()) {
      //get renamed dds in F
      final renamedDdsFilesF = Directory(group2ExtractedItemPathF).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.dds');
      final renamedDdsNamesF = renamedDdsFilesF.map((e) => p.basename(e.path)).toList();
      //get old dds in F
      List<String> ogDdsNamesF = [];
      if (extractedGroup2FilesF.isNotEmpty) {
        ogDdsNamesF = extractedGroup2FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      } else {
        ogDdsNamesF = extractedGroup1FilesF.where((element) => p.extension(element.path) == '.dds').map((e) => p.basename(e.path)).toList();
      }
      //get .aqp
      File aqpInDirF = Directory(group2ExtractedItemPathF).listSync(recursive: true).whereType<File>().firstWhere(
            (element) => p.extension(element.path) == '.aqp',
            orElse: () => File(''),
          );
      if (aqpInDirF.path.isNotEmpty) {
        Uint8List aqpBytesRead = await aqpInDirF.readAsBytes();
        List<int> aqpBytes = [];
        aqpBytes.addAll(aqpBytesRead);
        for (var ddsF in ogDdsNamesF) {
          List<String> ddsFParts = ddsF.split('_');
          String ddsFId = ddsFParts.firstWhere(
            (element) => element.length > 3 && int.tryParse(element) != null,
            orElse: () => '',
          );
          List<String> ddsWoId = ddsF.split(ddsFId);
          int ddsIndex = -1;
          List<String> ddsTypes = ['d.dds', 'm.dds', 'n.dds', 's.dds'];
          if (renamedDdsNamesF.where((element) => element.split('_').length > 1 && element.split('_')[1] == 'rac' && !ddsTypes.contains(element.split('_').last)).isNotEmpty) {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').split('_').first);
          } else if (renamedDdsNamesF.where((element) => element.split('_').length > 1 && element.split('_')[1] == 'rac' && ddsTypes.contains(element.split('_').last)).isNotEmpty) {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basename(element).contains(ddsWoId.last));
            //pso2 textures to ngs texture in aqp
            if (ddsIndex == -1 && renamedDdsNamesF.where((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').trim().split('_').first).isNotEmpty) {
              ddsIndex = renamedDdsNamesF.indexWhere((element) => p.basenameWithoutExtension(element).split('_').last == ddsWoId.last.replaceFirst('_', '').trim().split('_').first);
            }
          } else {
            ddsIndex = renamedDdsNamesF.indexWhere((element) => element.contains(ddsWoId.first) && element.contains(ddsWoId.last));
          }
          if (ddsIndex != -1) {
            Uint8List ddsFBytes = Uint8List.fromList(ddsF.codeUnits);
            Uint8List ddsTBytes = Uint8List.fromList(renamedDdsNamesF[ddsIndex].codeUnits);
            int firstMatchingIndex = aqpBytesRead.indexOfElements(ddsFBytes);
            // if (firstMatchingIndex != -1) {
            //   if (ddsFBytes.length > ddsTBytes.length) {
            //     List<String> paddingTextList = List.filled(ddsFBytes.length - ddsTBytes.length, String.fromCharCode(aqpBytes[firstMatchingIndex + ddsFBytes.length + 1]));
            //     Uint8List paddingText = Uint8List.fromList(paddingTextList.join().codeUnits);
            //     aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsFBytes.length, ddsTBytes + paddingText);
            //   } else {
            //     aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsTBytes.length, ddsTBytes);
            //   }
            //   aqpInDirF.writeAsBytesSync(Uint8List.fromList(aqpBytes));
            // }
            while (firstMatchingIndex != -1) {
              if (ddsFBytes.length > ddsTBytes.length) {
                List<String> paddingTextList = List.filled(ddsFBytes.length - ddsTBytes.length, String.fromCharCode(aqpBytes[firstMatchingIndex + ddsFBytes.length + 1]));
                Uint8List paddingText = Uint8List.fromList(paddingTextList.join().codeUnits);
                aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsFBytes.length, ddsTBytes + paddingText);
              } else {
                aqpBytes.replaceRange(firstMatchingIndex, firstMatchingIndex + ddsTBytes.length, ddsTBytes);
              }
              aqpInDirF.writeAsBytesSync(Uint8List.fromList(aqpBytes));
              firstMatchingIndex = aqpBytes.indexOfElements(ddsFBytes);
            }
          }
        }
      }
    }

    //pack

    rItemName = rItemName.replaceAll(RegExp(charToReplace), '_').trim();
    String packDirPath = '';
    if (fromSubmod.modName == fromSubmod.submodName) {
      packDirPath = Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath();
    } else {
      packDirPath =
          Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName}/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
    }
    Directory(packDirPath).createSync(recursive: true);
    await Process.run('$zamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathF/${lItemIceName}_ext').toFilePath()]);
    if (File(Uri.file('$tempSubmodPathF/${lItemIceName}_ext.ice').toFilePath()).existsSync()) {
      File(Uri.file('$tempSubmodPathF/${lItemIceName}_ext.ice').toFilePath()).renameSync(Uri.file('$packDirPath/$rItemIceName').toFilePath());
    }
    //mod previews
    //image
    for (var imagePath in fromMod.previewImages) {
      if (Directory(Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath())
          .listSync()
          .whereType<File>()
          .where((element) => p.basename(element.path) == p.basename(imagePath))
          .isEmpty) {
        File(imagePath).copySync(Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}/${p.basename(imagePath)}').toFilePath());
      }
    }
    //video
    for (var videoPath in fromMod.previewVideos) {
      if (Directory(Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath())
          .listSync()
          .whereType<File>()
          .where((element) => p.basename(element.path) == p.basename(videoPath))
          .isEmpty) {
        File(videoPath).copySync(Uri.file('$modSwapTempOutputDirPath/$rItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}/${p.basename(videoPath)}').toFilePath());
      }
    }
    //submod previews
    //image
    for (var imagePath in fromSubmod.previewImages) {
      if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(imagePath)).isEmpty) {
        File(imagePath).copySync(Uri.file('$packDirPath/${p.basename(imagePath)}').toFilePath());
      }
    }
    //video
    for (var videoPath in fromSubmod.previewVideos) {
      if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(videoPath)).isEmpty) {
        File(videoPath).copySync(Uri.file('$packDirPath/${p.basename(videoPath)}').toFilePath());
      }
    }
    //modfile previews
    //image
    for (var imagePaths in fromSubmod.modFiles.map((e) => e.previewImages!).toList()) {
      for (var imagePath in imagePaths) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(imagePath)).isEmpty) {
          File(imagePath).copySync(Uri.file('$packDirPath/${p.basename(imagePath)}').toFilePath());
        }
      }
    }
    //video
    for (var videoPaths in fromSubmod.modFiles.map((e) => e.previewVideos!).toList()) {
      for (var videoPath in videoPaths) {
        if (Directory(packDirPath).listSync().whereType<File>().where((element) => p.basename(element.path) == p.basename(videoPath)).isEmpty) {
          File(videoPath).copySync(Uri.file('$packDirPath/${p.basename(videoPath)}').toFilePath());
        }
      }
    }
  }

  itemSwapWorkingStatus.value = appText.itemSwapFinished;

  return Directory(Uri.file('$modSwapTempOutputDirPath/$rItemName').toFilePath());
}
