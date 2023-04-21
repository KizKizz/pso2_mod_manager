import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/functions/language_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

//All paths go here
//Main paths
Uri pso2binPath = Uri();
Uri modManDirParentDirPath = Uri();
Uri modManDirPath = Uri();
Uri modManModsDirPath = Uri();
Uri modManBackupsDirPath = Uri();
Uri modManChecksumDirPath = Uri();
Uri modManDeletedItemsDirPath = Uri();
//Misc path
Uri modManAddModsTempDirPath = Uri();
Uri modManAddModsUnpackDirPath = Uri();
//Json files path
Uri modManModsListJsonPath = Uri();
Uri modManModSetsJsonPath = Uri();
Uri modManModSettingsJsonPath = Uri();

//Default Mod Caterories
List<String> defaultCateforyDirs = [
  'Accessories',
  'Basewears',
  'Body Paints',
  'Cast Arm Parts',
  'Cast Body Parts',
  'Cast Leg Parts',
  'Costumes',
  'Emotes',
  'Eyes',
  'Face Paints',
  'Hairs',
  'Innerwears',
  'Mags',
  'Misc',
  'Motions',
  'Outerwears',
  'Setwears'
];

Future<bool> pathsLoader(context) async {
  final prefs = await SharedPreferences.getInstance();
  //pso2_bin path
  pso2binPath = Uri.directory(prefs.getString('binDirPath') ?? '');
  while (pso2binPath.path.isEmpty) {
    String? pso2binPathFromPicker = await pso2binPathGet(context);
    if (pso2binPathFromPicker != null) {
      pso2binPath = Uri.directory(pso2binPathFromPicker);
    }
  }
  //modman dir path
  modManDirParentDirPath = Uri.directory(prefs.getString('mainModManDirPath') ?? '');
  while (modManDirParentDirPath.path.isEmpty) {
    String? modManDirPathFromPicker = await modManDirPathGet(context);
    if (modManDirPathFromPicker != null) {
      modManDirParentDirPath = Uri.directory(modManDirPathFromPicker);
    } else {
      modManDirParentDirPath = pso2binPath;
    }
  }

  //Create modman folder if not already existed
  modManDirPath = Uri.directory('${modManDirParentDirPath.toFilePath()}PSO2 Mod Manager');
  Directory(modManDirPath.toFilePath()).createSync();
  //Create Mods folder and default categories
  modManModsDirPath = Uri.directory('${modManDirPath.toFilePath()}Mods');
  for (var name in defaultCateforyDirs) {
    Directory(modManModsDirPath.toFilePath() + name).createSync();
  }
  //Create Backups folder
  modManBackupsDirPath = Uri.directory('${modManDirPath.toFilePath()}Backups');
  Directory(modManBackupsDirPath.toFilePath()).createSync();
  List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  for (var name in dataFolders) {
    Directory(modManBackupsDirPath.toFilePath() + name).createSync();
  }
  //Create Checksum folder
  modManChecksumDirPath = Uri.directory('${modManDirPath.toFilePath()}Checksum');
  Directory(modManChecksumDirPath.toFilePath()).createSync();
  //Create Deleted Items folder
  modManDeletedItemsDirPath = Uri.directory('${modManDirPath.toFilePath()}Deleted Items');
  Directory(modManDeletedItemsDirPath.toFilePath());
  //Create misc folders
  modManAddModsTempDirPath = Uri.directory('${Directory.current.path}\\temp');
  Directory(modManAddModsTempDirPath.toFilePath()).createSync(recursive: true);
  modManAddModsUnpackDirPath = Uri.directory('${Directory.current.path}\\unpack');
  Directory(modManAddModsUnpackDirPath.toFilePath()).createSync(recursive: true);
  //Create Json files
  modManModsListJsonPath = Uri.file('${modManDirPath.toFilePath()}PSO2ModManModsList.json');
  modManModSetsJsonPath = Uri.file('${modManDirPath.toFilePath()}PSO2ModManModSets.json');
  modManModSettingsJsonPath = Uri.file('${modManDirPath.toFilePath()}PSO2ModManSettings.json');

  //Return true if all paths loaded
  return true;
}

Future<String?> pso2binPathGet(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: const Center(
                child: Text('Error', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text(
                curLangText!.pso2binNotFoundPopupText,
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Exit'),
                    onPressed: () async {
                      Navigator.pop(context, null);
                      await windowManager.destroy();
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Select \'pso2_bin\' folder path',
                            lockParentWindow: true,
                          ));
                    },
                    child: const Text('Yes'))
              ]));
}

Future<String?> modManDirPathGet(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.modmanFolderNotFoundLabelText, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text(
                curLangText!.modmanFolderNotFoundText,
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('No'),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Select a folder to store Mod Manager folder',
                            lockParentWindow: true,
                          ));
                    },
                    child: const Text('Yes'))
              ]));
}
