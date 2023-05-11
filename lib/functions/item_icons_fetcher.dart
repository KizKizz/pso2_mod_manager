import 'dart:io';

import 'package:cross_file/cross_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

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

List<List<String>> itemIconRefSheetsList = [];

Future<String> itemIconFetch(XFile moddedIceList) async {
  //CLear temp dir
  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    element.deleteSync(recursive: true);
  });

  //populate sheets
  if (itemIconRefSheetsList.isEmpty) {
    itemIconRefSheetsList = await popSheetsList(modManRefSheetsDirPath);
  }

  //Find item in csv
  List<String> itemInCsv = [];
  //itemInCsv = await compute(findItemInCsv, moddedIceList);
  itemInCsv = await findItemInCsv(moddedIceList);

  if (itemInCsv.isNotEmpty) {
    return itemInCsv[3];
  } else {
    return '';
  }
}

//Helper functions

Future<List<String>> findItemInCsv(XFile inputFile) async {
  List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  for (var file in itemIconRefSheetsList) {
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

Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
  String pso2binDataDirPath = Uri.file('$modManPso2binPath/data').toFilePath();
  XFile? iconIce;
  List<String> subDataDirs = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  for (var dir in subDataDirs) {
    if (dir == 'win32' || dir == 'win32_na') {
      String icePath = Uri.file('$pso2binDataDirPath/$dir/$iceName').toFilePath();
      if (File(icePath).existsSync() && iconIce == null) {
        iconIce = XFile(icePath);
        break;
      }
    } else {
      final rebootIces = Directory(Uri.file('$pso2binDataDirPath/$dir').toFilePath()).listSync().whereType<File>();
      String icePath = '';
      if (rebootIces.isNotEmpty) {
        icePath = rebootIces.firstWhere((element) => XFile(element.path).name == iceName).path;
      }
      if (icePath.isNotEmpty && File(icePath).existsSync() && iconIce == null) {
        iconIce = XFile(icePath);
        break;
      }
    }
  }

  if (iconIce != null) {
    String itemName = '';
    if (curActiveLang == 'JP') {
      itemName = itemNameJP;
    } else {
      itemName = itemNameEN;
    }

    XFile ddsIcon = XFile('');
    await Process.run(modManZamboniExePath, [iconIce.path]).then((value) {
      if (Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).existsSync()) {
        final files = Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
        ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
        if (ddsIcon.path.isNotEmpty) {
          final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
          ddsIcon = XFile(iconNewName.path);
        }
      }
    });

    if (ddsIcon.path.isNotEmpty) {
      await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsIcon.path]).then((value) {
        //processTrigger = true;
      });
      final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
          .copySync(Uri.file('$modManAddModsTempDirPath/${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}').toFilePath());
      if (await newPath.exists()) {
        Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).deleteSync(recursive: true);
      }
      //processTrigger = true;
      return newPath.path;
    }
  }

  //processTrigger = true;

  return '';
}