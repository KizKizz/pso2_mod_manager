import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<String> _pathsToRemove = ['win32', 'win32reboot', 'win32_na', 'win32reboot_na'];
List<XFile> _newModMainFolderList = [];

//Csv lists
List<String> _accessoriesCsv = ['Accessories.csv'];
List<String> _emoteCsv = ['LobbyActionsNGS_HandPoses.csv', 'LobbyActions.csv'];
List<String> _basewearCsv = ['GenderlessNGSBasewear.csv', 'FemaleNGSBasewear.csv', 'MaleNGSBasewear.csv', 'FemaleBasewear.csv', 'MaleBasewear.csv'];
List<String> _magsCsv = ['Mags.csv', 'MagsNGS.csv'];
List<String> _stickersCsv = ['Stickers.csv'];
List<String> _innerwearCsv = ['FemaleNGSInnerwear.csv', 'MaleNGSInnerwear.csv', 'MaleInnerwear.csv', 'FemaleInnerwear.csv'];
List<String> _outerwearCsv = ['FemaleNGSOuters.csv', 'MaleNGSOuters.csv', 'FemaleOuters.csv', 'MaleOuters.csv'];
List<String> _bodyPaintCsv = ['GenderlessNGSBodyPaint.csv', 'FemaleNGSBodyPaint.csv', 'MaleNGSBodyPaint.csv', 'FemaleBodyPaint.csv', 'MaleBodyPaint.csv'];
List<String> _facePaintCsv = ['FacePaintNGS.csv', 'FacePaint.csv'];
List<String> _hairCsv = ['CasealHair.csv', 'FemaleHair.csv', 'MaleHair.csv', 'AllHairNGS.csv'];
List<String> _castBodyCsv = ['CastBodies.csv', 'CasealBodies.csv', 'CastNGSBodies.csv', 'CasealNGSBodies.csv'];
List<String> _castArmCsv = ['CastArms.csv', 'CastArms.csv', 'CasealArmsNGS.csv', 'CastArmsNGS.csv'];
List<String> _castLegCsv = ['CasealLegs.csv', 'CastLegs.csv', 'CastLegsNGS.csv', 'CasealLegsNGS.csv'];
List<String> _eyeCsv = ['EyesNGS.csv', 'EyelashesNGS.csv', 'EyebrowsNGS.csv', 'Eyes.csv', 'Eyelashes.csv', 'Eyebrows.csv'];
List<String> _costumeCsv = ['FemaleCostumes.csv', 'MaleCostumes.csv'];
List<String> _motionCsv = [
  'SubstituteMotionGlide.csv',
  'SubstituteMotionJump.csv',
  'SubstituteMotionLanding.csv',
  'SubstituteMotionPhotonDash.csv',
  'SubstituteMotionRun.csv',
  'SubstituteMotionStandby.csv',
  'SubstituteMotionSwim.csv'
];

Future<List<List<String>>> fetchItemName(List<XFile> inputFiles) async {
  List<List<String>> filesList = [];
  //getting main dirs
  List<String> mainDirPaths = [];
  for (var file in _newModMainFolderList) {
    if (p.extension(file.path) == '.zip') {
      final ext = file.name.substring(file.name.lastIndexOf('.'));
      String nameAfterExtract = file.name.replaceAll(ext, '');
      mainDirPaths.add('${Directory.current.path}${s}unpack$s$nameAfterExtract');
    } else if (_pathsToRemove.indexWhere((element) => element == file.name) != -1) {
      mainDirPaths.add(file.path.replaceFirst('$s${file.name}', ''));
    } else {
      mainDirPaths.add(file.path);
    }
  }

  //copy files to temp with new folder structures
  List<List<String>> extraFiles = [];
  //int unknownModsCounter = 1;
  for (var inputFile in inputFiles) {
    if (File(inputFile.path).existsSync() && !inputFile.path.contains(modManAddModsTempDirPath)) {
      for (var mainPath in mainDirPaths) {
        //Paths have main path and continue with /
        if (inputFile.path.contains('$mainPath$s')) {
          String mainDirName = mainPath.split(s).last;
          List<String> curPathSplit = inputFile.path.split(s);
          String subDirName = '';
          if (_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element)) != -1) {
            curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
            curPathSplit.removeRange(
                curPathSplit.indexWhere((element) => element == _pathsToRemove[_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element))]), curPathSplit.length);
            subDirName = curPathSplit.join(' - ');
          } else {
            curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
            curPathSplit.remove(inputFile.name);
            subDirName = curPathSplit.join(' - ');
          }

          //moving files to temp with sorted paths
          if (!Directory('$modManAddModsTempDirPath$s$mainDirName$s$subDirName').existsSync()) {
            Directory('$modManAddModsTempDirPath$s$mainDirName$s$subDirName').createSync(recursive: true);
          }
          File(inputFile.path).copySync('$modManAddModsTempDirPath$s$mainDirName$s$subDirName$s${inputFile.name}');

          //get category and item name
          int indexInFilesList = -1;
          if (p.extension(inputFile.path) == '') {
            List<String> itemInfo = await findItemInCsv(inputFile);
            if (itemInfo.isNotEmpty) {
              if (filesList.indexWhere((element) => element[1].contains(itemInfo[1])) != -1 && filesList.indexWhere((element) => element[2].contains(itemInfo[2])) != -1) {
                indexInFilesList = filesList.indexWhere((element) => element[1].contains(itemInfo[1]));
                itemInfo = filesList[indexInFilesList];
              }
            } else {
              itemInfo = ['Misc', '不明な項目', 'Unknown Items', ''];
              // itemInfo = ['Misc', '不明な項目 $unknownModsCounter', 'Unknown Item $unknownModsCounter'];
              // unknownModsCounter++;
            }

            if (itemInfo.length < 5) {
              itemInfo.add(mainDirName);
            } else {
              if (!itemInfo[4].split('|').contains(mainDirName)) {
                itemInfo[4] += '|$mainDirName';
              }
            }
            if (itemInfo.length < 6) {
              itemInfo.add(subDirName);
            } else {
              if (!itemInfo[5].split('|').contains(subDirName)) {
                itemInfo[5] += '|$subDirName';
              }
            }
            if (itemInfo.length < 7) {
              itemInfo.add('$mainDirName:$subDirName:${inputFile.name}');
            } else {
              if (!itemInfo[6].split('|').contains('$mainDirName:$subDirName:${inputFile.name}')) {
                itemInfo[6] += '|$mainDirName:$subDirName:${inputFile.name}';
              }
            }

            //[0catname, 1jpname, 2enname, 3maindir, 4subdirs, 5files]
            if (indexInFilesList != -1) {
              filesList[indexInFilesList] = itemInfo;
            } else {
              filesList.add(itemInfo);
            }
          } else {
            extraFiles.add(['', '', '', '', mainDirName, subDirName, '$mainDirName:$subDirName:${inputFile.name}']);
          }

          //print('Sub: $subDirName');
        }
      }
    }
  }
  for (var extraFile in extraFiles) {
    for (var file in filesList) {
      if (file[4].split('|').contains(extraFile[4]) && file[5].split('|').contains(extraFile[5])) {
        file[6] += '|${extraFile[6]}';
      }
    }
  }

  return filesList;
}

Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
    if (iceFiles.indexWhere((element) => element.path.split(s).last == iceName) != -1) {
      XFile iconFile = XFile(iceFiles.firstWhere((element) => element.path.split(s).last == iceName).path);

      String itemName = '';
      if (curActiveLang == 'JP') {
        itemName = itemNameJP;
      } else {
        itemName = itemNameEN;
      }

      XFile ddsIcon = XFile('');
      await Process.run(zamboniExePath, [iconFile.path]).then((value) {
        if (Directory('${Directory.current.path}$s${iceName}_ext').existsSync()) {
          final files = Directory('${Directory.current.path}$s${iceName}_ext').listSync(recursive: true).whereType<File>();
          ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
          if (ddsIcon.path.isNotEmpty) {
            final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
            ddsIcon = XFile(iconNewName.path);
          }
        }
      });

      if (ddsIcon.path.isNotEmpty) {
        await Process.run('${Directory.current.path}${s}ddstopngtool${s}DDStronk.exe', [ddsIcon.path]).then((value) {
          //processTrigger = true;
        });
        final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
            .copySync('$modManAddModsTempDirPath$s${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}');
        if (await newPath.exists()) {
          Directory('${Directory.current.path}$s${iceName}_ext').deleteSync(recursive: true);
        }
        //processTrigger = true;
        return newPath.path;
      }
    }

    //processTrigger = true;

    return '';
  }

  Future<List<String>> findItemInCsv(XFile inputFile) async {
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    for (var file in itemRefSheetsList) {
      for (var line in file) {
        if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
          var lineSplit = line.split(',');
          String jpItemName = lineSplit[0];
          String enItemName = lineSplit[1];
          for (var char in charToReplace) {
            jpItemName = jpItemName.replaceAll(char, '_');
            enItemName = enItemName.replaceAll(char, '_');
          }
          //[0 Category, 1 JP name, 2 EN name, 3 icon]
          if (_emoteCsv.indexWhere((element) => file.first == element) != -1) {
            String jpEmoteName = lineSplit[1];
            String enEmoteName = lineSplit[2];
            for (var char in charToReplace) {
              jpEmoteName = jpEmoteName.replaceAll(char, '_');
              enEmoteName = enEmoteName.replaceAll(char, '_');
            }
            return (['Emotes', jpEmoteName, enEmoteName, '']);
          } else if (_basewearCsv.indexWhere((element) => element == file.first) != -1) {
            if (lineSplit[0].contains('[Ba]') || lineSplit[1].contains('[Ba]')) {
              return (['Basewears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
            } else if (lineSplit[0].contains('[Se]') || lineSplit[1].contains('[Se]')) {
              return (['Setwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
            } else {
              return (['Misc', jpItemName, enItemName, '']);
            }
          } else if (_accessoriesCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Accessories', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
          } else if (_innerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Innerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_outerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Outerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_bodyPaintCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Body Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_magsCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Mags', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
          } else if (_stickersCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Stickers', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_facePaintCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Face Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_hairCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Hairs', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_castBodyCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Body Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_castArmCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Arm Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_castLegCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Leg Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_eyeCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Eyes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_costumeCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Costumes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (_motionCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Motions', jpItemName, enItemName, '']);
          } else {
            return ([file.first, jpItemName, enItemName, '']);
          }
        }
      }
    }

    return [];
  }
