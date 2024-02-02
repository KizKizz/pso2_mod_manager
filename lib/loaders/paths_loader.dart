// ignore_for_file: unused_import

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/functions/checksum_check.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/startup_icons_loader_popup.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/mod_files_loader.dart';
import 'package:pso2_mod_manager/pages/home_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

//All paths go here
//Main paths
String modManPso2binPath = '';
String modManDirParentDirPath = '';
String modManDirPath = '';
String modManModsDirPath = '';
String modManBackupsDirPath = '';
String modManChecksumDirPath = '';
String modManDeletedItemsDirPath = '';
String modManChecksumFilePath = '';
//Misc path
String modManAddModsTempDirPath = '';
String modManAddModsUnpackDirPath = '';
String modManZamboniExePath = Uri.file('${Directory.current.path}/Zamboni/Zamboni.exe').toFilePath();
String modManDdsPngToolExePath = Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath();
String modManRefSheetsDirPath = Uri.file('${Directory.current.path}/ItemRefSheets').toFilePath();
String modManWin32CheckSumFilePath = '';
String modManWin32NaCheckSumFilePath = '';
String modManLocalChecksumMD5 = '';
String modManWin32ChecksumMD5 = '';
String modManWin32NaChecksumMD5 = '';
String modManModsAdderPath = Uri.file('${Directory.current.path}/modsAdder').toFilePath();
String modManVitalGaugeDirPath = '';
String modManVitalGaugeOriginalsDirPath = '';
String modManTempCmxDirPath = Uri.file('${Directory.current.path}/tempCmx').toFilePath();
//Json files path
String modManModsListJsonPath = '';
String modManModSetsJsonPath = '';
String modManRefSheetListFilePath = '';
String modManRefSheetsLocalVerFilePath = '';
String modManVitalGaugeJsonPath = '';
//Log file path
String modManOpLogsFilePath = '';
//Swapper paths
String modManSwapperDirPath = Uri.file('${Directory.current.path}/swapper').toFilePath();
String modManSwapperFromItemDirPath = Uri.file('${Directory.current.path}/swapper/fromitem').toFilePath();
String modManSwapperToItemDirPath = Uri.file('${Directory.current.path}/swapper/toitem').toFilePath();
String modManSwapperOutputDirPath = Uri.file('${Directory.current.path}/swapper/Swapped Items').toFilePath();
//sega patch server links
String masterURL = '';
String patchURL = '';
String backupMasterURL = '';
String backupPatchURL = '';

Future<bool> pathsLoader(context) async {
  final prefs = await SharedPreferences.getInstance();
  //get profile
  modManCurActiveProfile = (prefs.getInt('modManCurActiveProfile') ?? 1);
  //pso2_bin path
  modManPso2binPath = Uri.file(prefs.getString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2') ?? '').toFilePath();
  if (!Directory(modManPso2binPath).existsSync()) {
    modManPso2binPath = '';
  }
  while ((modManPso2binPath.isEmpty || p.basename(modManPso2binPath) != 'pso2_bin')) {
    String? pso2binPathFromPicker = await pso2binPathGet(context);
    if (pso2binPathFromPicker != null && p.basename(pso2binPathFromPicker) == 'pso2_bin') {
      modManPso2binPath = Uri.file(pso2binPathFromPicker).toFilePath();
      prefs.setString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2', modManPso2binPath);
    }
  }
  //modman dir path
  modManDirParentDirPath = Uri.file(prefs.getString('mainModManDirPath') ?? '').toFilePath();
  if (!Directory(modManDirParentDirPath).existsSync()) {
    modManDirParentDirPath = '';
  } else {
    if (Directory(Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath()).existsSync()) {
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
    }
  }
  while (modManDirParentDirPath.isEmpty || modManDirPath.isEmpty) {
    String? modManDirPathFromPicker = await modManDirPathGet(context);
    if (modManDirPathFromPicker != null) {
      if (p.basename(modManDirPathFromPicker) == 'PSO2 Mod Manager') {
        modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
        modManDirPath = modManDirParentDirPath;
        modManDirParentDirPath = Uri.file(p.dirname(modManDirParentDirPath)).toFilePath();
        prefs.setString('mainModManDirPath', modManDirParentDirPath);
      } else {
        modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
        modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
        Directory(modManDirPath).createSync();
        prefs.setString('mainModManDirPath', modManDirParentDirPath);
      }
    } else {
      //final documentDir = await getApplicationDocumentsDirectory();
      modManDirParentDirPath = Uri.file('C:\\').toFilePath();
      //Create modman folder if not already existed
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
      Directory(modManDirPath).createSync();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
    }
  }

  //Create Mods folder and default categories
  modManModsDirPath = Uri.file('$modManDirPath/Mods').toFilePath();
  Directory(modManModsDirPath).createSync(recursive: true);
  for (var name in defaultCategoryDirs) {
    Directory(Uri.file('$modManModsDirPath/$name').toFilePath()).createSync();
  }
  //Create Backups folder
  modManBackupsDirPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Backups').toFilePath() : Uri.file('$modManDirPath/Backups_profile2').toFilePath();
  Directory(modManBackupsDirPath).createSync();
  List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  for (var name in dataFolders) {
    Directory(Uri.file('$modManBackupsDirPath/$name').toFilePath()).createSync();
  }
  //Remove backup folder if existing
  // if (Directory(Uri.file('$modManDirPath/Backups').toFilePath()).existsSync()) {
  //   Directory(Uri.file('$modManDirPath/Backups').toFilePath()).deleteSync(recursive: true);
  // }
  //Create Vital gauge folder
  modManVitalGaugeDirPath = Uri.file('$modManDirPath/Vital Gauge').toFilePath();
  Directory(modManVitalGaugeDirPath).createSync();
  modManVitalGaugeOriginalsDirPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Vital Gauge/Originals').toFilePath() : Uri.file('$modManDirPath/Vital Gauge/Originals_profile2').toFilePath();
  Directory(modManVitalGaugeOriginalsDirPath).createSync();
  //Create Checksum folder
  modManChecksumDirPath = Uri.file('$modManDirPath/Checksum').toFilePath();
  Directory(modManChecksumDirPath).createSync();
  //Create Deleted Items folder
  modManDeletedItemsDirPath = Uri.file('$modManDirPath/Deleted Items').toFilePath();
  Directory(modManDeletedItemsDirPath);
  //Create misc folders
  modManAddModsTempDirPath = Uri.file('${Directory.current.path}/temp').toFilePath();
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  modManAddModsUnpackDirPath = Uri.file('${Directory.current.path}/unpack').toFilePath();
  Directory(modManAddModsUnpackDirPath).createSync(recursive: true);
  modManModsAdderPath = Uri.file('${Directory.current.path}/modsAdder').toFilePath();
  Directory(modManModsAdderPath).createSync(recursive: true);
  Directory(modManTempCmxDirPath).createSync(recursive: true);
  //Create Json files
  modManModsListJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath();
  File(modManModsListJsonPath).createSync();
  modManModSetsJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath();
  File(modManModSetsJsonPath).createSync();
  modManVitalGaugeJsonPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath();
  File(modManVitalGaugeJsonPath).createSync();
  // modManModSettingsJsonPath = Uri.file('$modManDirPath/PSO2ModManSettings.json').toFilePath();
  // File(modManModSettingsJsonPath).createSync();
  modManRefSheetListFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetList.txt').toFilePath();
  if (!File(modManRefSheetListFilePath).existsSync()) {
    File(modManRefSheetListFilePath).createSync();
  }
  modManRefSheetsLocalVerFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetsVer.txt').toFilePath();
  if (!File(modManRefSheetsLocalVerFilePath).existsSync()) {
    File(modManRefSheetsLocalVerFilePath).createSync();
    File(modManRefSheetsLocalVerFilePath).writeAsString('0');
  }
  //Create log file
  // modManOpLogsFilePath = Uri.file('$modManDirPath/PSO2ModManSettings.json').toFilePath();
  // File(modManOpLogsFilePath).createSync();

  //Checksum check
  //await ApplicationConfig().checkChecksumFileForUpdates(context);
  await checksumChecker(context);

  //Profanity filter
  if (profanityFilterRemoval) {
    if (Directory(Uri.file('$modManPso2binPath/data/win32').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
    }
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
    }
  }
  // if (!profanityFilterRemoval) {
  //   if (!File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileJP();
  //   }
  //   if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && !File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileNA();
  //   }
  // } else {
  //   if (File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
  //   }
  //   if (File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
  //   }
  // }

  //ref sheets check load files
  if (kDebugMode && Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).existsSync()) {
    final sheetFiles = Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).listSync(recursive: true).where((element) => p.extension(element.path) == '.csv');
    List<String> sheetPaths = sheetFiles.map((e) => Uri.file(e.path.replaceAll(modManRefSheetsDirPath, '')).toFilePath()).toList();
    File(modManRefSheetListFilePath).writeAsStringSync(sheetPaths.join('\n').trim());
    File(modManRefSheetsLocalVerFilePath).writeAsStringSync(refSheetsVersion.toString());
  }

  //ref sheets check
  modManRefSheetsLocalVersion = int.parse(File(modManRefSheetsLocalVerFilePath).readAsStringSync());
  await checkRefSheetsForUpdates(context);

  //startup icons loader
  if (firstTimeUser) {
    isAutoFetchingIconsOnStartup = await startupItemIconDialog(context);
    prefs.setString('isAutoFetchingIconsOnStartup', isAutoFetchingIconsOnStartup);
  }

  //sega patch server loader
  final patchLinks = await getPatchServerList();
  if (patchLinks.isNotEmpty) {
    masterURL = patchLinks.firstWhere((element) => element.contains('MasterURL=')).split('=').last.trim();
    patchURL = patchLinks.firstWhere((element) => element.contains('PatchURL=')).split('=').last.trim();
    backupMasterURL = patchLinks.firstWhere((element) => element.contains('BackupMasterURL=')).split('=').last.trim();
    backupPatchURL = patchLinks.firstWhere((element) => element.contains('BackupPatchURL=')).split('=').last.trim();
  }

  //Get patch file lists
  //await fetchOfficialPatchFileList();

  //Return true if all paths loaded
  return true;
}

//Get main paths
Future<String?> pso2binPathGet(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiError, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text(
                curLangText!.uiPso2binFolderNotFoundSelect,
              ),
              actions: <Widget>[
                // if (Provider.of<StateProvider>(context, listen: false).reloadProfile)
                //   ElevatedButton(
                //       child: Text(curLangText!.uiReturn),
                //       onPressed: () async {
                //         Navigator.pop(context, null);
                //         final prefs = await SharedPreferences.getInstance();
                //         if (modManCurActiveProfile == 1) {
                //           modManCurActiveProfile = 2;
                //         } else if (modManCurActiveProfile == 2) {
                //           modManCurActiveProfile = 1;
                //         }
                //         prefs.setInt('modManCurActiveProfile', modManCurActiveProfile);
                //       }),
                // if (!Provider.of<StateProvider>(context, listen: false).reloadProfile)
                ElevatedButton(
                    child: Text(curLangText!.uiExit),
                    onPressed: () async {
                      Navigator.pop(context, null);
                      await windowManager.destroy();
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          // await FilePicker.platform.getDirectoryPath(
                          //   dialogTitle: curLangText!.uiSelectPso2binFolderPath,
                          //   lockParentWindow: true,
                          // )
                          await getDirectoryPath());
                    },
                    child: Text(curLangText!.uiYes))
              ]));
}

Future<String?> modManDirPathGet(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiMMFolderNotFound, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text(
                curLangText!.uiSelectPathToStoreMMFolder,
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiNo),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          // await FilePicker.platform.getDirectoryPath(
                          //   dialogTitle: curLangText!.uiSelectAFolderToStoreMMFolder,
                          //   lockParentWindow: true,
                          // )
                          await getDirectoryPath());
                    },
                    child: Text(curLangText!.uiYes))
              ]));
}

//Reselect main paths
Future<bool> pso2PathsReloader(context) async {
  final prefs = await SharedPreferences.getInstance();
  //pso2_bin path
  String? pso2binPathFromPicker = await pso2binPathReselect(context);
  if (pso2binPathFromPicker != null && p.basename(pso2binPathFromPicker) == 'pso2_bin') {
    modManPso2binPath = Uri.file(pso2binPathFromPicker).toFilePath();
    prefs.setString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2', modManPso2binPath);
    modManChecksumFilePath = '';
    ogModFilesLoader();
  } else {
    return false;
  }

  //Checksum
  await checksumChecker(context);

  //Profanity filter
  if (profanityFilterRemoval) {
    if (Directory(Uri.file('$modManPso2binPath/data/win32').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
    }
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
    }
  }
  // if (!profanityFilterRemoval) {
  //   if (!File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileJP();
  //   }
  //   if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && !File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileNA();
  //   }
  // } else {
  //   if (File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
  //   }
  //   if (File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
  //   }
  // }

  //Apply mods to new data folder
  for (var type in appliedItemList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        if (item.applyStatus == true) {
          for (var mod in item.mods) {
            if (mod.applyStatus == true) {
              for (var submod in mod.submods) {
                if (submod.applyStatus == true) {
                  for (var modFile in submod.modFiles) {
                    if (modFile.applyStatus == true) {
                      modFile.ogLocations = fetchOriginalIcePaths(modFile.modFileName);
                      modFileApply(context, modFile);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //Return true if all paths loaded
  return true;
}

Future<String?> pso2binPathReselect(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiReselectPso2binPath, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Text('${curLangText!.uiCurrentPath}:\n$modManPso2binPath'),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiReturn),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      getDirectoryPath().then((value) {
                        if (value!.isNotEmpty && p.basename(value) == 'pso2_bin') {
                          Navigator.pop(context, value);
                        }
                      });
                      // Navigator.pop(
                      //     context,
                      //     // await FilePicker.platform.getDirectoryPath(
                      //     //   dialogTitle: curLangText!.uiSelectPso2binFolderPath,
                      //     //   lockParentWindow: true,
                      //     // )
                      //     await getDirectoryPath());
                    },
                    child: Text(curLangText!.uiReselect))
              ]));
}

Future<bool> modManPathReloader(context) async {
  final prefs = await SharedPreferences.getInstance();
  String? modManDirPathFromPicker = await modManDirPathReselect(context);
  if (modManDirPathFromPicker != null) {
    if (p.basename(modManDirPathFromPicker) == 'PSO2 Mod Manager') {
      modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
      modManDirPath = modManDirParentDirPath;
      modManDirParentDirPath = Uri.file(p.dirname(modManDirParentDirPath)).toFilePath();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
    } else {
      modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
      Directory(modManDirPath).createSync();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
    }
  } else {
    return false;
  }

  listsReloading = true;
  Provider.of<StateProvider>(context, listen: false).reloadSplashScreenTrue();

  //Check modman folder
  // if (p.basename(modManDirParentDirPath) == 'PSO2 Mod Manager') {
  //   modManDirPath = modManDirParentDirPath;
  // } else {
  //   modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
  //   Directory(modManDirPath).createSync();
  // }

  //Create Mods folder and default categories
  modManModsDirPath = Uri.file('$modManDirPath/Mods').toFilePath();
  Directory(modManModsDirPath).createSync(recursive: true);
  for (var name in defaultCategoryDirs) {
    Directory(Uri.file('$modManModsDirPath/$name').toFilePath()).createSync();
  }
  //Create Backups folder
  modManBackupsDirPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Backups').toFilePath() : Uri.file('$modManDirPath/Backups_profile2').toFilePath();
  Directory(modManBackupsDirPath).createSync();
  List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  for (var name in dataFolders) {
    Directory(Uri.file('$modManBackupsDirPath/$name').toFilePath()).createSync();
  }
  //Create Vital gauge folder
  modManVitalGaugeDirPath = Uri.file('$modManDirPath/Vital Gauge').toFilePath();
  Directory(modManVitalGaugeDirPath).createSync();
  modManVitalGaugeOriginalsDirPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Vital Gauge/Originals').toFilePath() : Uri.file('$modManDirPath/Vital Gauge/Originals_profiles2').toFilePath();
  Directory(modManVitalGaugeOriginalsDirPath).createSync();
  //Create Checksum folder
  modManChecksumDirPath = Uri.file('$modManDirPath/Checksum').toFilePath();
  Directory(modManChecksumDirPath).createSync();
  //Create Deleted Items folder
  modManDeletedItemsDirPath = Uri.file('$modManDirPath/Deleted Items').toFilePath();
  Directory(modManDeletedItemsDirPath);
  //Create misc folders
  modManAddModsTempDirPath = Uri.file('${Directory.current.path}/temp').toFilePath();
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  modManAddModsUnpackDirPath = Uri.file('${Directory.current.path}/unpack').toFilePath();
  Directory(modManAddModsUnpackDirPath).createSync(recursive: true);
  modManModsAdderPath = Uri.file('${Directory.current.path}/modsAdder').toFilePath();
  Directory(modManModsAdderPath).createSync(recursive: true);
  Directory(modManTempCmxDirPath).createSync(recursive: true);
  //Create Json files
  modManModsListJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath();
  File(modManModsListJsonPath).createSync();
  modManModSetsJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath();
  File(modManModSetsJsonPath).createSync();
  modManVitalGaugeJsonPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath();
  File(modManVitalGaugeJsonPath).createSync();
  // modManModSettingsJsonPath = Uri.file('$modManDirPath/PSO2ModManSettings.json').toFilePath();
  // File(modManModSettingsJsonPath).createSync();
  modManRefSheetListFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetList.txt').toFilePath();
  File(modManRefSheetListFilePath).createSync();
  modManRefSheetsLocalVerFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetsVer.txt').toFilePath();
  if (!File(modManRefSheetsLocalVerFilePath).existsSync()) {
    File(modManRefSheetsLocalVerFilePath).createSync();
    File(modManRefSheetsLocalVerFilePath).writeAsString('0');
  }

  //Create log file
  // modManOpLogsFilePath = Uri.file('$modManDirPath/PSO2ModManSettings.json').toFilePath();
  // File(modManOpLogsFilePath).createSync();

  //Checksum check
  //await ApplicationConfig().checkChecksumFileForUpdates(context);
  await checksumChecker(context);

  //Profanity filter
  if (profanityFilterRemoval) {
    if (Directory(Uri.file('$modManPso2binPath/data/win32').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
    }
    if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
      await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
    }
  }
  // if (!profanityFilterRemoval) {
  //   if (!File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileJP();
  //   }
  //   if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && !File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await downloadProfanityFileNA();
  //   }
  // } else {
  //   if (File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32/$profanityFilterIce').toFilePath()).delete();
  //   }
  //   if (File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).existsSync()) {
  //     await File(Uri.file('$modManPso2binPath/data/win32_na/$profanityFilterIce').toFilePath()).delete();
  //   }
  // }

  //sega patch server loader
  final patchLinks = await getPatchServerList();
  if (patchLinks.isNotEmpty) {
    masterURL = patchLinks.firstWhere((element) => element.contains('MasterURL=')).split('=').last.trim();
    patchURL = patchLinks.firstWhere((element) => element.contains('PatchURL=')).split('=').last.trim();
    backupMasterURL = patchLinks.firstWhere((element) => element.contains('BackupMasterURL=')).split('=').last.trim();
    backupPatchURL = patchLinks.firstWhere((element) => element.contains('BackupPatchURL=')).split('=').last.trim();
  }

  //Get patch file lists
  await fetchOfficialPatchFileList();
  // moddedItemsList = await modFileStructureLoader(context, true);
  // appliedItemList = await appliedListBuilder(moddedItemsList);
  // modSetList = await modSetLoader();

  //listsReloading = true;

  // Future.delayed(const Duration(milliseconds: 100), () {
  modFileStructureLoader(context, false).then((mValue) {
    moddedItemsList.clear();
    moddedItemsList.addAll(mValue);
    appliedListBuilder(moddedItemsList).then((aValue) {
      appliedItemList.clear();
      appliedItemList.addAll(aValue);
      modSetLoader().then((sValue) {
        modSetList.clear();
        modSetList.addAll(sValue);
        Future.delayed(const Duration(milliseconds: 100), () {
          Provider.of<StateProvider>(context, listen: false).reloadSplashScreenFalse();
          listsReloading = false;
        });
      });
    });
  });
  // });

  //Return true if all paths loaded
  return true;
}

Future<String?> modManDirPathReselect(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiReselectModManFolderPath, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text('${curLangText!.uiMMPathReselectNoteCurrentPath}\n$modManDirPath'),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiReturn),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          // await FilePicker.platform.getDirectoryPath(
                          //   dialogTitle: curLangText!.uiSelectAFolderToStoreMMFolder,
                          //   lockParentWindow: true,
                          // )
                          await getDirectoryPath());
                    },
                    child: Text(curLangText!.uiReselect))
              ]));
}
