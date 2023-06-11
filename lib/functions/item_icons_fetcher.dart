import 'dart:io';

import 'package:cross_file/cross_file.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';

List<String> itemIconRefSheetsList = [];

Future<List<String>> modLoaderItemIconFetch(List<String> itemInCsv, String category) async {
  //CLear temp dir
  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    element.deleteSync(recursive: true);
  });

  List<CsvAccessoryIceFile> csvAccFiles = [];
  List<CsvIceFile> csvGenFiles = [];

  //Find item in csv

  for (var csvLine in itemInCsv) {
    final lineToList = csvLine.split(',');
    if (lineToList[0] != 'Emotes' && lineToList[0] != 'Motions' && lineToList[0] != 'Unknown' && lineToList[0] != '未知') {
      if (lineToList[0] == 'Accessories') {
        csvAccFiles.add(CsvAccessoryIceFile.fromList(lineToList));
      } else {
        csvGenFiles.add(CsvIceFile.fromList(lineToList));
      }
    }
  }

  List<String> iconImagePaths = [];

  for (var file in csvAccFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  for (var file in csvGenFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  return iconImagePaths;
}


Future<List<String>> modAdderItemIconFetch(List<String> itemInCsv, String category) async {
  //CLear temp dir
  // Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
  //   element.deleteSync(recursive: true);
  // });

  List<CsvAccessoryIceFile> csvAccFiles = [];
  List<CsvIceFile> csvGenFiles = [];

  //Find item in csv

  for (var csvLine in itemInCsv) {
    final lineToList = csvLine.split(',');
    if (lineToList[0] != 'Emotes' && lineToList[0] != 'Motions' && lineToList[0] != 'Unknown' && lineToList[0] != '未知') {
      if (lineToList[0] == 'Accessories') {
        csvAccFiles.add(CsvAccessoryIceFile.fromList(lineToList));
      } else {
        csvGenFiles.add(CsvIceFile.fromList(lineToList));
      }
    }
  }

  List<String> iconImagePaths = [];

  for (var file in csvAccFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  for (var file in csvGenFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  return iconImagePaths;
}

Future<List<String>> itemIconFetch(List<File> moddedIceList, String category) async {
  //CLear temp dir
  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    element.deleteSync(recursive: true);
  });

  //populate sheets
  // if (itemIconRefSheetsList.isEmpty) {
  //   itemIconRefSheetsList = await itemCsvFetcher(modManRefSheetsDirPath);
  // }

  //load sheets
  if (csvInfosFromSheets.isEmpty) {
    csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  }

  List<CsvAccessoryIceFile> csvAccFiles = [];
  List<CsvIceFile> csvGenFiles = [];

  //Find item in csv
  int defaultCateIndex = defaultCateforyDirs.indexOf(category);
  if (defaultCateIndex != -1) {
    List<String> itemInCsv = await modFileCsvFetcher(csvInfosFromSheets[defaultCateIndex], moddedIceList);
    for (var csvLine in itemInCsv) {
      final lineToList = csvLine.split(',');
      if (lineToList[0] != 'Emotes' && lineToList[0] != 'Motions' && lineToList[0] != 'Unknown' && lineToList[0] != '未知') {
        if (lineToList[0] == 'Accessories') {
          csvAccFiles.add(CsvAccessoryIceFile.fromList(lineToList));
        } else {
          csvGenFiles.add(CsvIceFile.fromList(lineToList));
        }
      }
    }
  }

  List<String> iconImagePaths = [];

  for (var file in csvAccFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  for (var file in csvGenFiles) {
    List<String> iconIcePaths = [];
    final iconPaths = ogWin32FilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)).toList();
    if (iconPaths.isNotEmpty) {
      iconIcePaths.addAll(iconPaths);
    } else {
      iconIcePaths.addAll(ogWin32NAFilePaths.where((element) => file.iconIceName.isNotEmpty && p.basename(element) == p.basename(file.iconIceName)));
    }
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    String itemName = curActiveLang == 'JP' ? file.jpName : file.enName;
    for (var char in charToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }
    for (var path in iconIcePaths) {
      iconImagePaths.add(await getIconFromIceFile(itemName, path));
    }
  }

  return iconImagePaths;
}

Future<String> getIconFromIceFile(String itemName, String icePath) async {
  XFile ddsIcon = XFile('');
  await Process.run(modManZamboniExePath, [icePath]).then((value) {
    if (Directory(Uri.file('${Directory.current.path}/${p.basename(icePath)}_ext').toFilePath()).existsSync()) {
      final files = Directory(Uri.file('${Directory.current.path}/${p.basename(icePath)}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
      ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
      if (ddsIcon.path.isNotEmpty) {
        final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
        ddsIcon = XFile(iconNewName.path);
      }
    }
  });

  String returnPath = '';
  if (ddsIcon.path.isNotEmpty) {
    await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsIcon.path]).then((value) {
      //processTrigger = true;
    });
    final newPath = await File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
        .copy(Uri.file('$modManAddModsTempDirPath/${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}').toFilePath());
    if (await newPath.exists()) {
      Directory(Uri.file('${Directory.current.path}/${p.basename(icePath)}_ext').toFilePath()).deleteSync(recursive: true);
      returnPath = newPath.path;
    }
    //processTrigger = true;
  }
  return returnPath;
}

//Helper functions

// Future<List<String>> findItemInCsv(XFile inputFile) async {
//   List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
//   for (var file in itemIconRefSheetsList) {
//     for (var line in file) {
//       if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
//         var lineSplit = line.split(',');
//         String jpItemName = lineSplit[0];
//         String enItemName = lineSplit[1];
//         for (var char in charToReplace) {
//           jpItemName = jpItemName.replaceAll(char, '_');
//           enItemName = enItemName.replaceAll(char, '_');
//         }
//         //[0 Category, 1 JP name, 2 EN name, 3 icon]
//         if (emoteCsv.indexWhere((element) => file.first == element) != -1) {
//           String jpEmoteName = lineSplit[1];
//           String enEmoteName = lineSplit[2];
//           for (var char in charToReplace) {
//             jpEmoteName = jpEmoteName.replaceAll(char, '_');
//             enEmoteName = enEmoteName.replaceAll(char, '_');
//           }
//           return (['Emotes', jpEmoteName, enEmoteName, '']);
//         } else if (basewearCsv.indexWhere((element) => element == file.first) != -1) {
//           if (lineSplit[0].contains('[Ba]') || lineSplit[1].contains('[Ba]')) {
//             return (['Basewears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//           } else if (lineSplit[0].contains('[Se]') || lineSplit[1].contains('[Se]')) {
//             return (['Setwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//           } else {
//             return (['Misc', jpItemName, enItemName, '']);
//           }
//         } else if (accessoriesCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Accessories', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
//         } else if (innerwearCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Innerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (outerwearCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Outerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (bodyPaintCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Body Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (magsCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Mags', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
//         } else if (stickersCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Stickers', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (facePaintCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Face Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (hairCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Hairs', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (castBodyCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Cast Body Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (castArmCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Cast Arm Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (castLegCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Cast Leg Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (eyeCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Eyes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (costumeCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Costumes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
//         } else if (motionCsv.indexWhere((element) => file.first == element) != -1) {
//           return (['Motions', jpItemName, enItemName, '']);
//         } else {
//           return ([file.first, jpItemName, enItemName, '']);
//         }
//       }
//     }
//   }

//   return [];
// }

// Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
//   String ogIcePath = '';
//   int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
//   int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   int win32RebootPathIndex = ogWin32RebootFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   int win32RebootNAPathIndex = ogWin32RebootNAFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   if (win32PathIndex != -1) {
//     ogIcePath = ogWin32FilePaths[win32PathIndex];
//   } else if (win32NAPathIndex != -1) {
//     ogIcePath = ogWin32NAFilePaths[win32NAPathIndex];
//   } else if (win32RebootPathIndex != -1) {
//     ogIcePath = ogWin32RebootFilePaths[win32RebootPathIndex];
//   } else if (win32RebootNAPathIndex != -1) {
//     ogIcePath = ogWin32RebootNAFilePaths[win32RebootNAPathIndex];
//   } else {
//     ogIcePath = '';
//   }

//   if (ogIcePath.isNotEmpty) {
//     XFile iconIce = XFile(ogIcePath);

//     String itemName = '';
//     if (curActiveLang == 'JP') {
//       itemName = itemNameJP;
//     } else {
//       itemName = itemNameEN;
//     }

//     XFile ddsIcon = XFile('');
//     await Process.run(modManZamboniExePath, [iconIce.path]).then((value) {
//       if (Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).existsSync()) {
//         final files = Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
//         ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
//         if (ddsIcon.path.isNotEmpty) {
//           final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
//           ddsIcon = XFile(iconNewName.path);
//         }
//       }
//     });

//     if (ddsIcon.path.isNotEmpty) {
//       await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsIcon.path]).then((value) {
//         //processTrigger = true;
//       });
//       final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
//           .copySync(Uri.file('$modManAddModsTempDirPath/${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}').toFilePath());
//       if (await newPath.exists()) {
//         Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).deleteSync(recursive: true);
//       }
//       //processTrigger = true;
//       return newPath.path;
//     }
//   }

//   //processTrigger = true;

//   return '';
// }
