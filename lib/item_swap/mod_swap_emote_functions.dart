import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';

final validCharacters = RegExp(r'^[a-zA-Z0-9]+$');

Future<Directory> modSwapEmotes(context, bool isVanillaItemSwap, Mod fromMod, SubMod fromSubmod, String rSelectedItemName, List<String> lItemAvailableIces, List<String> rItemAvailableIces) async {
  List<String> iceTypes = ['human hash', 'reboot human hash', 'fig hash', 'vfx hash'];
  String newToSelectedItemName = rSelectedItemName;

  String tempSubmodPathF = Uri.file('$modSwapTempLItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  String tempSubmodPathT = Uri.file('$modSwapTempRItemDirPath/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath();
  List<List<String>> iceSwappingList = [];

  lItemAvailableIces.removeWhere((element) => !fromSubmod.getModFileNames().contains(p.basenameWithoutExtension(element.split(': ').last)));
  rItemAvailableIces.isEmpty ? itemSwapWorkingStatus.value = appText.noMatchingFilesBetweenItemsToSwap : appText.sortingFileData;

  //map coresponding files to swap
  for (var rItem in rItemAvailableIces) {
    String curIceType = rItem.split(': ').first.toLowerCase();
    int rItemTypeIndex = iceTypes.indexWhere((e) => curIceType.contains(e));
    if (rItemTypeIndex != -1) {
      int lItemMatchingIndex = lItemAvailableIces.indexWhere((e) => e.split(': ').first.toLowerCase().contains(iceTypes[rItemTypeIndex]));
      if (lItemMatchingIndex != -1) {
        iceSwappingList.add([p.basename(lItemAvailableIces[lItemMatchingIndex].split(': ').last), p.basename(rItem.split(': ').last)]);
      }
    }
  }

  if (iceSwappingList.isEmpty) {
    itemSwapWorkingStatus.value = appText.noMatchingFilesBetweenItemsToSwap;
    return Directory(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName').toFilePath());
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
    File? lItemIceFileInTemp;
    if (isVanillaItemSwap) {
      //get ice path
      // final matchedlItemData = oItemData.firstWhere(
      //   (e) => p.basenameWithoutExtension(e.path) == lItemIceName,
      //   orElse: () => OfficialIceFile('', '', 0, ''),
      // );
      lItemIceFileInTemp = await originalIceDownload(lItemIceName, modSwapTempLItemDirPath, itemSwapWorkingStatus);
      // await modSwapOriginalFileDownload(matchedlItemData.path, matchedlItemData.server, modSwapTempLItemDirPath);
    } else {
      int modFileIndexF = fromSubmod.modFiles.indexWhere((element) => element.modFileName == lItemIceName);
      if (modFileIndexF != -1) {
        final modFileF = fromSubmod.modFiles[modFileIndexF];
        lItemIceFileInTemp = await File(modFileF.location).copy(Uri.file('$modSwapTempLItemDirPath/$lItemIceName').toFilePath());
      }
    }
    //extract F ice to
    if (lItemIceFileInTemp != null) {
      if (Platform.isLinux) {
        await Process.run('wine $zamboniExePath -outdir "$tempSubmodPathF"', [lItemIceFileInTemp.path]);
      } else {
        await Process.run('$zamboniExePath -outdir "$tempSubmodPathF"', [lItemIceFileInTemp.path]);
      }
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathF).existsSync()) {
        extractedGroup1FilesF = Directory(extractedGroup1PathF)
            .listSync(recursive: true)
            .whereType<File>()
            .where((element) => validCharacters.hasMatch(p.basenameWithoutExtension(element.path).split('_').first))
            .toList();
      }
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathF).existsSync()) {
        extractedGroup2FilesF = Directory(extractedGroup2PathF)
            .listSync(recursive: true)
            .whereType<File>()
            .where((element) => validCharacters.hasMatch(p.basenameWithoutExtension(element.path).split('_').first))
            .toList();
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
      File? iceFileInTempT = await originalIceDownload(icePathFromOgDataT, modSwapTempRItemDirPath, itemSwapWorkingStatus);
      // await modSwapOriginalFileDownload(icePathFromOgDataT, matchedrItemData.server, modSwapTempRItemDirPath);
      if (iceFileInTempT != null) {
        if (Platform.isLinux) {
          await Process.run('wine $zamboniExePath -outdir "$tempSubmodPathT"', [iceFileInTempT.path]);
        } else {
          await Process.run('$zamboniExePath -outdir "$tempSubmodPathT"', [iceFileInTempT.path]);
        }
      }
      String extractedGroup1PathT = Uri.file('$tempSubmodPathT/${rItemIceName}_ext/group1').toFilePath();
      if (Directory(extractedGroup1PathT).existsSync()) {
        extractedGroup1FilesT = Directory(extractedGroup1PathT).listSync(recursive: true).whereType<File>().toList();
      }
      String extractedGroup2PathT = Uri.file('$tempSubmodPathT/${rItemIceName}_ext/group2').toFilePath();
      if (Directory(extractedGroup2PathT).existsSync()) {
        extractedGroup2FilesT = Directory(extractedGroup2PathT).listSync(recursive: true).whereType<File>().toList();
      }
    }

    //group2 > group2
    List<File> renamedExtractedGroup2Files = [];
    if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await emoteSwapRename(extractedGroup2FilesF, extractedGroup2FilesT, emoteToIdleMotion, idleMotionToEmote);
    } else if (extractedGroup2FilesF.isEmpty && extractedGroup2FilesT.isNotEmpty) {
      renamedExtractedGroup2Files = await emoteSwapRename(extractedGroup1FilesF, extractedGroup2FilesT, emoteToIdleMotion, idleMotionToEmote);
    } else if (extractedGroup2FilesF.isNotEmpty && extractedGroup2FilesT.isEmpty) {
      renamedExtractedGroup2Files = await emoteSwapRename(extractedGroup2FilesF, extractedGroup1FilesT, emoteToIdleMotion, idleMotionToEmote);
      String extractedGroup1PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath();
      if (!Directory(extractedGroup1PathF).existsSync()) {
        Directory(extractedGroup1PathF).createSync();
        for (var file in renamedExtractedGroup2Files) {
          file.renameSync(Uri.file('$extractedGroup1PathF/${p.basename(file.path)}').toFilePath());
        }
      }
    }

    //group1 > group1
    List<File> renamedExtractedGroup1Files = [];
    if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await emoteSwapRename(extractedGroup1FilesF, extractedGroup1FilesT, emoteToIdleMotion, idleMotionToEmote);
    } else if (extractedGroup1FilesF.isEmpty && extractedGroup1FilesT.isNotEmpty) {
      renamedExtractedGroup1Files = await emoteSwapRename(extractedGroup2FilesF, extractedGroup1FilesT, emoteToIdleMotion, idleMotionToEmote);
    } else if (extractedGroup1FilesF.isNotEmpty && extractedGroup1FilesT.isEmpty) {
      renamedExtractedGroup1Files = await emoteSwapRename(extractedGroup1FilesF, extractedGroup2FilesT, emoteToIdleMotion, idleMotionToEmote);
      String extractedGroup2PathF = Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath();
      if (!Directory(extractedGroup2PathF).existsSync()) {
        Directory(extractedGroup2PathF).createSync();
        for (var file in renamedExtractedGroup1Files) {
          file.renameSync(Uri.file('$extractedGroup2PathF/${p.basename(file.path)}').toFilePath());
        }
      }
      // extra step for renaming .bti for idles to emotes
      if (idleMotionToEmote) {
        File btiToRename = extractedGroup1FilesF.firstWhere(
            (e) =>
                p.extension(e.path) == '.bti' &&
                p.basenameWithoutExtension(e.path).split('_')[0] == 'pl' &&
                p.basenameWithoutExtension(e.path).split('_')[1] == 'std' &&
                p.basenameWithoutExtension(e.path).split('_').last == 'lp',
            orElse: () => File(''));
        if (btiToRename.path.isNotEmpty && btiToRename.existsSync()) {
          File matchingAQMFile = extractedGroup2FilesT.firstWhere(
              (e) => p.extension(e.path) == '.aqm' && p.basenameWithoutExtension(e.path).split('_')[0] == 'pl' && p.basenameWithoutExtension(e.path).split('_')[1] == 'hum',
              orElse: () => File(''));
          if (matchingAQMFile.path.isNotEmpty && matchingAQMFile.existsSync()) {
            await btiToRename.rename(btiToRename.path.replaceFirst(p.basenameWithoutExtension(btiToRename.path), p.basenameWithoutExtension(matchingAQMFile.path)));
          }
        }
      }
    }

    //copy extra files
    if (renamedExtractedGroup1Files.isNotEmpty) {
      for (var extractedFileT in extractedGroup1FilesT) {
        if (renamedExtractedGroup1Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup1Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    } else if (renamedExtractedGroup1Files.isEmpty) {
      for (var extractedFileT in extractedGroup1FilesT) {
        if (renamedExtractedGroup1Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty &&
            Directory(Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1').toFilePath()).existsSync()) {
          extractedFileT.copySync(Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group1/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }
    if (renamedExtractedGroup2Files.isNotEmpty) {
      for (var extractedFileT in extractedGroup2FilesT) {
        if (renamedExtractedGroup2Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty) {
          extractedFileT.copySync(Uri.file('${p.dirname(renamedExtractedGroup2Files.first.path)}/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    } else if (renamedExtractedGroup2Files.isEmpty) {
      for (var extractedFileT in extractedGroup2FilesT) {
        if (renamedExtractedGroup2Files.where((element) => p.basename(element.path) == p.basename(extractedFileT.path)).isEmpty &&
            Directory(Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2').toFilePath()).existsSync()) {
          extractedFileT.copySync(Uri.file('$tempSubmodPathF/${lItemIceName}_ext/group2/${p.basename(extractedFileT.path)}').toFilePath());
        }
      }
    }

    //extra step for swapping LAs to Idles
    //if (selectedMotionType.isEmpty) {
    String rebootFigHashlItemIceName = lItemAvailableIces
        .firstWhere(
          (element) => element.split(': ').first == 'Reboot Fig Hash Ice' || element.split(': ').first == 'Reboot Fig Hash',
          orElse: () => '',
        )
        .split(': ')
        .last
        .split('\\')
        .last;
    String rebootHumanHashlItemIceName = lItemAvailableIces
        .firstWhere(
          (element) => element.split(': ').first == 'Reboot Human Hash Ice' || element.split(': ').first == 'Reboot Human Hash',
          orElse: () => '',
        )
        .split(': ')
        .last
        .split('\\')
        .last;

    // if bti file in reboot human
    if (Directory(Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group1').toFilePath()).existsSync() &&
        Directory(Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group1').toFilePath())
            .listSync()
            .whereType<File>()
            .where((element) => p.extension(element.path) == '.bti')
            .isNotEmpty) {
      //bti in group 1 human hash
      String rebootHumanHashGroup1PathF = Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group1').toFilePath();
      if (Directory(rebootHumanHashGroup1PathF).existsSync()) {
        List<File> rebootHumanGroup1Bti = Directory(rebootHumanHashGroup1PathF)
            .listSync()
            .whereType<File>()
            .where((element) => p.extension(element.path) == '.bti' && validCharacters.hasMatch(p.basenameWithoutExtension(element.path).split('_').first))
            .toList();

        //get new name for bti from aqm
        String rebootHumanHashGroup2PathF = Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group2').toFilePath();
        File rebootHumanGroup2Aqm = Directory(rebootHumanHashGroup2PathF).listSync().whereType<File>().firstWhere(
            (element) => p.extension(element.path) == '.aqm' && (p.basenameWithoutExtension(element.path).contains('_00120_') || p.basenameWithoutExtension(element.path).contains('pl_hum')),
            orElse: () => File(''));
        if (rebootHumanGroup1Bti.isNotEmpty && rebootHumanGroup2Aqm.path.isNotEmpty) {
          for (var group1BtiFileF in rebootHumanGroup1Bti) {
            if (p.basenameWithoutExtension(group1BtiFileF.path).contains('_00110_')) {
              //rename bti in human group1
              await group1BtiFileF.rename(
                  Uri.file('$rebootHumanHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path).replaceFirst('_00120_', '_00110_').replaceFirst('_lp', '_st')}.bti').toFilePath());
            } else if (p.basenameWithoutExtension(group1BtiFileF.path).contains('_00120_')) {
              await group1BtiFileF.rename(Uri.file('$rebootHumanHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path)}.bti').toFilePath());
            } else if (p.basenameWithoutExtension(group1BtiFileF.path).contains('pl_hum') || p.basenameWithoutExtension(group1BtiFileF.path).contains('pl_la')) {
              await group1BtiFileF.rename(Uri.file('$rebootHumanHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path)}.bti').toFilePath());
            }
          }
        }
      }
    } else if (pair == iceSwappingList.last) {
      if (rebootFigHashlItemIceName.isNotEmpty) {
        // bti in group1 fig hash
        String rebootFigHashGroup1PathF = Uri.file('$tempSubmodPathF/${rebootFigHashlItemIceName}_ext/group1').toFilePath();
        if (Directory(rebootFigHashGroup1PathF).existsSync()) {
          List<File> rebootFigGroup1Bti = Directory(rebootFigHashGroup1PathF).listSync().whereType<File>().where((element) => p.extension(element.path) == '.bti').toList();
          //String rebootHumanHashGroup1PathF = Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group1').toFilePath();

          //get new name for bti from aqm
          String rebootHumanHashGroup2PathF = Uri.file('$tempSubmodPathF/${rebootHumanHashlItemIceName}_ext/group2').toFilePath();
          File rebootHumanGroup2Aqm = File('');
          if (Directory(rebootHumanHashGroup2PathF).existsSync()) {
            Directory(rebootHumanHashGroup2PathF).listSync().whereType<File>().firstWhere(
                (element) => p.extension(element.path) == '.aqm' && (p.basenameWithoutExtension(element.path).contains('_00120_') || (p.basenameWithoutExtension(element.path).contains('pl_hum'))),
                orElse: () => File(''));
          }

          //copy bti from fig to human
          //Directory(rebootHumanHashGroup1PathF).createSync(recursive: true);
          if (rebootFigGroup1Bti.isNotEmpty && rebootHumanGroup2Aqm.path.isNotEmpty) {
            for (var rebootFigGroup1BtiFileF in rebootFigGroup1Bti) {
              if (p.basenameWithoutExtension(rebootFigGroup1BtiFileF.path).contains('_00110_')) {
                //rename bti in human group1
                await rebootFigGroup1BtiFileF.rename(
                    Uri.file('$rebootFigHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path).replaceFirst('_00120_', '_00110_').replaceFirst('_lp', '_st')}.bti').toFilePath());
              } else if (p.basenameWithoutExtension(rebootFigGroup1BtiFileF.path).contains('_00120_')) {
                await rebootFigGroup1BtiFileF.rename(Uri.file('$rebootFigHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path)}.bti').toFilePath());
              } else if (p.basenameWithoutExtension(rebootFigGroup1BtiFileF.path).contains('pl_hum') || p.basenameWithoutExtension(rebootFigGroup1BtiFileF.path).contains('pl_la')) {
                await rebootFigGroup1BtiFileF.rename(Uri.file('$rebootFigHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path)}.bti').toFilePath());
              }
            }
            // await rebootFigGroup1Bti.rename(Uri.file('$rebootFigHashGroup1PathF/${p.basenameWithoutExtension(rebootHumanGroup2Aqm.path)}.bti').toFilePath());
          }
        }
      }
    }
    //}

    // copy files in .fig hash
    String figHashLItemIceName = lItemAvailableIces
        .firstWhere(
          (element) => element.split(': ').first == '.fig Hash',
          orElse: () => '',
        )
        .split(': ')
        .last;
    String figHashRItemIceName = rItemAvailableIces
        .firstWhere(
          (element) => element.split(': ').first == '.fig Hash',
          orElse: () => '',
        )
        .split(': ')
        .last;
    Directory lItemFigHashExtractedDir = Directory(Uri.file('$tempSubmodPathF/${figHashLItemIceName}_ext/group2').toFilePath());
    Directory rItemFigHashExtractedDir = Directory(Uri.file('$tempSubmodPathT/${figHashRItemIceName}_ext/group2').toFilePath());
    if (lItemFigHashExtractedDir.existsSync() && rItemFigHashExtractedDir.existsSync()) {
      for (var file in lItemFigHashExtractedDir.listSync(recursive: true).whereType<File>()) {
        await file.copy(file.path.replaceFirst(lItemFigHashExtractedDir.path, rItemFigHashExtractedDir.path));
      }
    }

    //pack
    newToSelectedItemName = newToSelectedItemName.replaceAll(RegExp(charToReplace), '_');
    String packDirPath = '';
    if (fromSubmod.modName == fromSubmod.submodName) {
      packDirPath = Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath();
    } else {
      packDirPath =
          Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName}/${fromSubmod.submodName.replaceAll(' > ', '/').replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}')
              .toFilePath();
    }
    Directory(packDirPath).createSync(recursive: true);
    if (Platform.isLinux) {
      await Process.run('wine $zamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathF/${lItemIceName}_ext').toFilePath()]);
    } else {
      await Process.run('$zamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathF/${lItemIceName}_ext').toFilePath()]);
    }
    if (File(Uri.file('$tempSubmodPathF/${lItemIceName}_ext.ice').toFilePath()).existsSync()) {
      File(Uri.file('$tempSubmodPathF/${lItemIceName}_ext.ice').toFilePath()).renameSync(Uri.file('$packDirPath/$rItemIceName').toFilePath());
    }
    //mod previews
    //image
    for (var imagePath in fromMod.previewImages) {
      if (Directory(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath())
          .listSync()
          .whereType<File>()
          .where((element) => p.basename(element.path) == p.basename(imagePath))
          .isEmpty) {
        File(imagePath).copySync(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}/${p.basename(imagePath)}').toFilePath());
      }
    }
    //video
    for (var videoPath in fromMod.previewVideos) {
      if (Directory(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}').toFilePath())
          .listSync()
          .whereType<File>()
          .where((element) => p.basename(element.path) == p.basename(videoPath))
          .isEmpty) {
        File(videoPath).copySync(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName/${fromSubmod.modName.replaceAll(RegExp(charToReplace), '_')}/${p.basename(videoPath)}').toFilePath());
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

  return Directory(Uri.file('$modSwapTempOutputDirPath/$newToSelectedItemName').toFilePath());
}
