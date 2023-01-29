import 'dart:io';

import 'package:cross_file/cross_file.dart';
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
    if (File(inputFile.path).existsSync() && !inputFile.path.contains(tempDirPath)) {
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
          if (!Directory('$tempDirPath$s$mainDirName$s$subDirName').existsSync()) {
            Directory('$tempDirPath$s$mainDirName$s$subDirName').createSync(recursive: true);
          }
          File(inputFile.path).copySync('$tempDirPath$s$mainDirName$s$subDirName$s${inputFile.name}');

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

Future<List<String>> findItemInCsv(XFile inputFile) async {
  for (var file in itemRefSheetsList) {
    for (var line in file) {
      if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
        var lineSplit = line.split(',');
        //[0 Category, 1 JP name, 2 EN name, 3 icon]
        if (_emoteCsv.indexWhere((element) => file.first == element) != -1) {
          return (['Emotes', lineSplit[1].replaceAll('/', '_'), lineSplit[2].replaceAll('/', '_'), '']);
        } else if (_basewearCsv.indexWhere((element) => element == file.first) != -1) {
          if (lineSplit[0].contains('[Ba]') || lineSplit[1].contains('[Ba]')) {
            return ([
              'Basewears',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (lineSplit[0].contains('[Se]') || lineSplit[1].contains('[Se]')) {
            return ([
              'Setwears',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else {
            return (['Misc', lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
          }
        } else if (_accessoriesCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Accessories',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[3], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_innerwearCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Innerwears',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_outerwearCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Outerwears',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_bodyPaintCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Body Paints',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_magsCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Mags',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[3], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_stickersCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Stickers',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_facePaintCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Face Paints',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_hairCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Hairs',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_castBodyCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Cast Body Parts',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_castArmCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Cast Arm Parts',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_castLegCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Cast Leg Parts',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_eyeCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Eyes',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_costumeCsv.indexWhere((element) => file.first == element) != -1) {
          return ([
            'Costumes',
            lineSplit[0].replaceAll('/', '_'),
            lineSplit[1].replaceAll('/', '_'),
            await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
          ]);
        } else if (_motionCsv.indexWhere((element) => file.first == element) != -1) {
          return (['Motions', lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
        } else {
          return ([file.first, lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
        }
      }
    }
  }

  return [];
}

Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
  if (iceFiles.indexWhere((element) => element.path.split(s).last == iceName) != -1) {
    XFile iconFile = XFile(iceFiles.firstWhere((element) => element.path.split(s).last == iceName).path);

    String itemName = '';
    if (curActiveLang == 'JP') {
      itemName = itemNameJP.replaceAll('/', '_');
      itemName = itemName.replaceAll(':', '_');
    } else {
      itemName = itemNameEN.replaceAll('/', '_');
      itemName = itemName.replaceAll(':', '_');
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
      await Process.run('${Directory.current.path}${s}ddstopngtool${s}DDStronk.exe', [ddsIcon.path]);
      final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
          .copySync('$tempDirPath$s${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}');
      if (await newPath.exists()) {
        Directory('${Directory.current.path}$s${iceName}_ext').deleteSync(recursive: true);
      }
      return newPath.path;
    }
  }

  return '';
}
