// ignore_for_file: unused_import, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/applied_vital_gauge_check.dart';
import 'package:pso2_mod_manager/functions/apply_mod_file.dart';
import 'package:pso2_mod_manager/functions/checksum_check.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
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
String modManAddModsIgnoreListPath = '';
String modManZamboniExePath = Uri.file('${Directory.current.path}/Zamboni/Zamboni.exe').toFilePath();
String modManDdsPngToolExePath = Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath();
String modMan7zipExePath = Uri.file('${Directory.current.path}/7zip-x64/7z.exe').toFilePath();
String modManRefSheetsDirPath = Uri.file('${Directory.current.path}/ItemRefSheets').toFilePath();
String modManPlayerItemDataPath = Uri.file('${Directory.current.path}/ItemRefSheets/playerItemData.json').toFilePath();
String modManWin32CheckSumFilePath = '';
String modManWin32NaCheckSumFilePath = '';
String modManLocalChecksumMD5 = '';
String modManWin32ChecksumMD5 = '';
String modManWin32NaChecksumMD5 = '';
String modManModsAdderPath = '';
String modManVitalGaugeDirPath = '';
String modManVitalGaugeOriginalsDirPath = '';
String modManTempCmxDirPath = '';
String modManExportedDirPath = '';
String modManImportedDirPath = '';
String modManOverlayedItemIconsDirPath = '';
String modManJsonAutoSaveDir = '';
String modManJsonManualSaveDir = '';
String modManCustomAqmDir = '';
//Json files path
String modManModsListJsonPath = '';
String modManModSetsJsonPath = '';
// String modManRefSheetListFilePath = '';
String modManRefSheetsLocalVerFilePath = '';
String modManVitalGaugeJsonPath = '';
String modManAppliedModsJsonPath = '';
//Log file path
String modManOpLogsFilePath = '';
//Swapper paths
String modManSwapperDirPath = '';
String modManSwapperFromItemDirPath = '';
String modManSwapperToItemDirPath = '';
String modManSwapperOutputDirPath = '';
//sega patch server links
String masterURL = '';
String patchURL = '';
String backupMasterURL = '';
String backupPatchURL = '';
//extras
String modManMAIconDatabaseLink = 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main';

Future<bool> pathsLoader(context) async {
  final prefs = await SharedPreferences.getInstance();
  //get profile
  modManCurActiveProfile = (prefs.getInt('modManCurActiveProfile') ?? 1);
  //pso2_bin path
  modManPso2binPath = Uri.file(prefs.getString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2') ?? '').toFilePath();
  String oldPso2binDirPath = '';
  if (!Directory(modManPso2binPath).existsSync()) {
    if (modManPso2binPath.isNotEmpty) {
      oldPso2binDirPath = modManPso2binPath;
    }
    modManPso2binPath = '';
  }
  while ((modManPso2binPath.isEmpty || (p.basename(modManPso2binPath) != 'pso2_bin') && p.basename(modManPso2binPath) != 'Content')) {
    String? pso2binPathFromPicker = await pso2binPathGet(context);
    if (pso2binPathFromPicker != null && (p.basename(pso2binPathFromPicker) == 'pso2_bin' || p.basename(pso2binPathFromPicker) == 'Content')) {
      modManPso2binPath = Uri.file(pso2binPathFromPicker).toFilePath();
      prefs.setString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2', modManPso2binPath);
    }
  }

  //modman dir path
  String savedModManDirParentDirPath = prefs.getString('mainModManDirPath') ?? '';
  if (savedModManDirParentDirPath.endsWith(':')) savedModManDirParentDirPath += '\\';
  modManDirParentDirPath = Uri.file(savedModManDirParentDirPath).toFilePath();
  if (modManDirParentDirPath.endsWith('\\')) {
    modManDirParentDirPath = modManDirParentDirPath.replaceRange(modManDirParentDirPath.length - 1, null, '');
  }
  String oldModManDirPath = '';
  if (!Directory(modManDirParentDirPath).existsSync()) {
    if (modManDirParentDirPath.isNotEmpty) {
      oldModManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
    }
    modManDirParentDirPath = '';
  } else {
    if (Directory(Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath()).existsSync()) {
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
    } else {
      oldModManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
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
      if (modManDirParentDirPath.endsWith('\\')) {
        modManDirParentDirPath = modManDirParentDirPath.replaceRange(modManDirParentDirPath.length - 1, null, '');
      }
      //Create modman folder if not already existed
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
      Directory(modManDirPath).createSync();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
    }
  }

  //create/load folders
  await createSubDirs(context);

  //rename json
  jsonPso2binPathsRename(context, oldPso2binDirPath);

  // modManRefSheetListFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetList.txt').toFilePath();
  // if (!File(modManRefSheetListFilePath).existsSync()) {
  //   File(modManRefSheetListFilePath).createSync();
  // }
  modManRefSheetsLocalVerFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetsVer.txt').toFilePath();
  if (!File(modManRefSheetsLocalVerFilePath).existsSync()) {
    File(modManRefSheetsLocalVerFilePath).createSync();
    File(modManRefSheetsLocalVerFilePath).writeAsString('0');
  }

  //rename modman path in json
  jsonModManPathsRename(oldModManDirPath);

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

  // get edition
  File editionFile = File(Uri.file('$modManPso2binPath/edition.txt').toFilePath());
  if (editionFile.existsSync()) {
    Provider.of<StateProvider>(context, listen: false).setGameEdition((await editionFile.readAsString()).trim());
  }

  //ref sheets check load files
  // if (kDebugMode && Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).existsSync()) {
  //   final sheetFiles = Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).listSync(recursive: true).where((element) => p.extension(element.path) == '.csv');
  //   List<String> sheetPaths = sheetFiles.map((e) => Uri.file(e.path.replaceAll(modManRefSheetsDirPath, '')).toFilePath()).toList();
  //   File(modManRefSheetListFilePath).writeAsStringSync(sheetPaths.join('\n').trim());
  //   File(modManRefSheetsLocalVerFilePath).writeAsStringSync(refSheetsVersion.toString());
  // }

  //ref sheets check
  modManRefSheetsLocalVersion = int.parse(File(modManRefSheetsLocalVerFilePath).readAsStringSync());
  await checkPlayerItemdataForUpdates(context);

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

  //clear
  // clearAllTempDirsBeforeGettingPath();

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
                '${curLangText!.uiPso2binFolderNotFoundSelect}\n${curLangText!.uiWindowsStoreVerNote}',
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
  String oldPso2binDirPath = modManPso2binPath;
  //pso2_bin path
  String? pso2binPathFromPicker = await pso2binPathReselect(context);
  if (pso2binPathFromPicker != null && (p.basename(pso2binPathFromPicker) == 'pso2_bin' || p.basename(pso2binPathFromPicker) == 'Content')) {
    modManPso2binPath = Uri.file(pso2binPathFromPicker).toFilePath();
    prefs.setString(modManCurActiveProfile == 1 ? 'binDirPath' : 'binDirPath_profile2', modManPso2binPath);
    modManChecksumFilePath = '';
    ogModFilesLoader();
  } else {
    return false;
  }

  //rename json
  await jsonPso2binPathsRename(context, oldPso2binDirPath);

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

  // get edition
  File editionFile = File(Uri.file('$modManPso2binPath/edition.txt').toFilePath());
  if (editionFile.existsSync()) {
    Provider.of<StateProvider>(context, listen: false).setGameEdition((await editionFile.readAsString()).trim());
  }

  //Apply mods to new data folder
  // for (var type in appliedItemList) {
  //   for (var cate in type.categories) {
  //     for (var item in cate.items) {
  //       if (item.applyStatus == true) {
  //         for (var mod in item.mods) {
  //           if (mod.applyStatus == true) {
  //             for (var submod in mod.submods) {
  //               if (submod.applyStatus == true) {
  //                 for (var modFile in submod.modFiles) {
  //                   if (modFile.applyStatus == true) {
  //                     modFile.ogLocations = fetchOriginalIcePaths(modFile.modFileName);
  //                     modFileApply(context, modFile);
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }
  //   }
  // }

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
              content: Text('${curLangText!.uiWindowsStoreVerNote}\n${curLangText!.uiCurrentPath}:\n$modManPso2binPath'),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiReturn),
                    onPressed: () async {
                      Navigator.pop(context, null);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      getDirectoryPath().then((value) {
                        if (value!.isNotEmpty && (p.basename(value) == 'pso2_bin' || p.basename(value) == 'Content')) {
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
  String oldModManDirPath = modManDirPath.toString();
  String? modManDirPathFromPicker = await modManDirPathReselect(context);
  if (modManDirPathFromPicker != null) {
    if (p.basename(modManDirPathFromPicker) == 'PSO2 Mod Manager') {
      modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
      modManDirPath = modManDirParentDirPath;
      modManDirParentDirPath = Uri.file(p.dirname(modManDirParentDirPath)).toFilePath();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
      prefs.setString('checksumFilePath', modManChecksumFilePath.replaceFirst(oldModManDirPath, modManDirPath));
    } else {
      modManDirParentDirPath = Uri.file(modManDirPathFromPicker).toFilePath();
      if (modManDirParentDirPath.endsWith('\\')) {
        modManDirParentDirPath = modManDirParentDirPath.replaceRange(modManDirParentDirPath.length - 1, null, '');
      }
      modManDirPath = Uri.file('$modManDirParentDirPath/PSO2 Mod Manager').toFilePath();
      Directory(modManDirPath).createSync();
      prefs.setString('mainModManDirPath', modManDirParentDirPath);
      prefs.setString('checksumFilePath', modManChecksumFilePath.replaceFirst(oldModManDirPath, modManDirPath));
    }
  } else {
    return false;
  }

  listsReloading = true;
  Provider.of<StateProvider>(context, listen: false).reloadSplashScreenTrue();

  //create/load folders
  await createSubDirs(context);

  // modManRefSheetListFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetList.txt').toFilePath();
  // File(modManRefSheetListFilePath).createSync();
  modManRefSheetsLocalVerFilePath = Uri.file('$modManRefSheetsDirPath/PSO2ModManRefSheetsVer.txt').toFilePath();
  if (!File(modManRefSheetsLocalVerFilePath).existsSync()) {
    File(modManRefSheetsLocalVerFilePath).createSync();
    File(modManRefSheetsLocalVerFilePath).writeAsString('0');
  }

  // Rename paths in jsons
  jsonModManPathsRename(oldModManDirPath);

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

  // get edition
  File editionFile = File(Uri.file('$modManPso2binPath/edition.txt').toFilePath());
  if (editionFile.existsSync()) {
    Provider.of<StateProvider>(context, listen: false).setGameEdition((await editionFile.readAsString()).trim());
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
  await fetchOfficialPatchFileList();
  // moddedItemsList = await modFileStructureLoader(context, true);
  // appliedItemList = await appliedListBuilder(moddedItemsList);
  // modSetList = await modSetLoader();

  //listsReloading = true;

  Future.delayed(const Duration(milliseconds: 100), () {
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
  });

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

Future<void> jsonModManPathsRename(String oldModManDirPath) async {
  // Rename paths in jsons
  if (oldModManDirPath.isNotEmpty) {
    if (moddedItemsList.isEmpty) {
      File modManModListFile = File(modManModsListJsonPath);
      if (modManModListFile.existsSync()) {
        String data = modManModListFile.readAsStringSync();
        if (data.isNotEmpty) {
          var jsonData = jsonDecode(data);
          for (var type in jsonData) {
            moddedItemsList.add(CategoryType.fromJson(type));
          }
        }
      }
    }

    for (var type in moddedItemsList) {
      for (var cate in type.categories) {
        cate.location = cate.location.replaceFirst(oldModManDirPath, modManDirPath);
        for (var item in cate.items) {
          item.location = item.location.replaceFirst(oldModManDirPath, modManDirPath);
          item.backupIconPath = item.backupIconPath!.replaceFirst(oldModManDirPath, modManDirPath);
          item.overlayedIconPath = item.overlayedIconPath!.replaceFirst(oldModManDirPath, modManDirPath);
          for (var mod in item.mods) {
            mod.location = mod.location.replaceFirst(oldModManDirPath, modManDirPath);
            for (var sub in mod.submods) {
              sub.location = sub.location.replaceFirst(oldModManDirPath, modManDirPath);
              for (var modFile in sub.modFiles) {
                modFile.location = modFile.location.replaceFirst(oldModManDirPath, modManDirPath);
                for (int i = 0; i < modFile.bkLocations.length; i++) {
                  modFile.bkLocations[i] = modFile.bkLocations[i].replaceFirst(oldModManDirPath, modManDirPath);
                }
              }
            }
          }
        }
      }
    }

    saveModdedItemListToJson();

    List<File> setListJsonFiles = [
      File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()),
      File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()),
    ];

    for (var file in setListJsonFiles) {
      if (file.existsSync() && file.readAsStringSync().isNotEmpty) {
        List<ModSet> tempList = [];
        var jsonData = jsonDecode(file.readAsStringSync());
        for (var type in jsonData) {
          tempList.add(ModSet.fromJson(type));
        }

        for (var set in tempList) {
          for (var item in set.setItems) {
            item.location = item.location.replaceAll(oldModManDirPath, modManDirPath);
            for (var mod in item.mods) {
              mod.location = mod.location.replaceAll(oldModManDirPath, modManDirPath);
              for (var sub in mod.submods) {
                sub.location = sub.location.replaceAll(oldModManDirPath, modManDirPath);
                for (var modFile in sub.modFiles) {
                  modFile.location = modFile.location.replaceAll(oldModManDirPath, modManDirPath);
                  for (int i = 0; i < modFile.bkLocations.length; i++) {
                    modFile.bkLocations[i] = modFile.bkLocations[i].replaceFirst(oldModManDirPath, modManDirPath);
                  }
                }
              }
            }
          }
        }

        tempList.map((set) => set.toJson()).toList();
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        file.writeAsStringSync(encoder.convert(tempList));
      }
    }

    List<File> vgJsonFiles = [
      File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath()),
      File(Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath()),
    ];

    for (var file in vgJsonFiles) {
      if (file.existsSync() && file.readAsStringSync().isNotEmpty) {
        List<VitalGaugeBackground> tempList = [];
        var jsonData = jsonDecode(file.readAsStringSync());
        for (var type in jsonData) {
          tempList.add(VitalGaugeBackground.fromJson(type));
        }

        for (var vg in tempList) {
          vg.pngPath = vg.pngPath.replaceAll(oldModManDirPath, modManDirPath);
          vg.replacedImagePath = vg.replacedImagePath.replaceAll(oldModManDirPath, modManDirPath);
        }

        tempList.map((vg) => vg.toJson()).toList();
        const JsonEncoder encoder = JsonEncoder.withIndent('  ');
        file.writeAsStringSync(encoder.convert(tempList));
      }
    }
  }
}

Future<void> jsonPso2binPathsRename(context, String oldPso2binDirPath) async {
  // Rename paths in jsons
  if (oldPso2binDirPath.isNotEmpty) {
    //modlist
    if (moddedItemsList.isEmpty) {
      File modManModListFile = File(modManModsListJsonPath);
      if (modManModListFile.existsSync()) {
        String data = modManModListFile.readAsStringSync();
        if (data.isNotEmpty) {
          var jsonData = jsonDecode(data);
          for (var type in jsonData) {
            moddedItemsList.add(CategoryType.fromJson(type));
          }
        }
      }
    }
    for (var type in moddedItemsList) {
      for (var cate in type.categories) {
        for (var item in cate.items) {
          item.iconPath = item.iconPath!.replaceFirst(oldPso2binDirPath, modManPso2binPath);
          for (var mod in item.mods) {
            for (var sub in mod.submods) {
              for (var i = 0; i < sub.applyLocations!.length; i++) {
                sub.applyLocations![i] = sub.applyLocations![i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
              }
              for (var modFile in sub.modFiles) {
                for (var i = 0; i < modFile.ogLocations.length; i++) {
                  modFile.ogLocations[i] = modFile.ogLocations[i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
                  // debugPrint(modFile.ogLocations[i]);
                }
                for (var i = 0; i < modFile.applyLocations!.length; i++) {
                  modFile.applyLocations![i] = modFile.applyLocations![i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
                }
              }
            }
          }
        }
      }
    }
    //reload ogpaths
    ogModFilesReset();
    ogModFilesLoader();
    //appliedlist
    if (appliedItemList.isNotEmpty) {
      appliedItemList = await appliedListBuilder(moddedItemsList);
      //Apply mods to new data folder
      for (var type in appliedItemList) {
        for (var cate in type.categories) {
          for (var item in cate.items) {
            if (item.applyStatus) {
              for (var mod in item.mods) {
                if (mod.applyStatus) {
                  for (var submod in mod.submods) {
                    if (submod.applyStatus) {
                      for (var modFile in submod.modFiles) {
                        if (modFile.applyStatus) {
                          modFile.ogLocations = fetchOriginalIcePaths(modFile.modFileName);
                          modFileApply(context, modFile);
                        }
                      }
                      //apply cmx
                      if (submod.hasCmx! && submod.cmxApplied!) {
                        int startIndex = -1, endIndex = -1;
                        (startIndex, endIndex) = await cmxModPatch(submod.cmxFile!);
                        if (startIndex != -1 && endIndex != -1) {
                          submod.cmxStartPos = startIndex;
                          submod.cmxEndPos = endIndex;
                        }
                      }
                    }
                  }
                }
              }
              if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                await applyOverlayedIcon(context, item);
              }
            }
          }
        }
      }
    }
    saveModdedItemListToJson();

    //Modsets
    if (modSetList.isEmpty) {
      File modManModSetListFile = File(modManModSetsJsonPath);
      if (modManModSetListFile.existsSync()) {
        String data = modManModSetListFile.readAsStringSync();
        if (data.isNotEmpty) {
          var jsonData = jsonDecode(data);
          for (var type in jsonData) {
            modSetList.add(ModSet.fromJson(type));
          }
        }
      }
    }

    for (var set in modSetList) {
      for (var item in set.setItems) {
        item.iconPath = item.iconPath!.replaceFirst(oldPso2binDirPath, modManPso2binPath);
        for (var mod in item.mods) {
          for (var sub in mod.submods) {
            if (sub.applyLocations != null && sub.applyLocations!.isNotEmpty) {
              for (var i = 0; i < sub.applyLocations!.length; i++) {
                sub.applyLocations![i] = sub.applyLocations![i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
              }
            }
            for (var modFile in sub.modFiles) {
              for (int i = 0; i < modFile.ogLocations.length; i++) {
                modFile.ogLocations[i] = modFile.ogLocations[i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
              }
              for (var i = 0; i < modFile.applyLocations!.length; i++) {
                modFile.applyLocations![i] = modFile.applyLocations![i].replaceFirst(oldPso2binDirPath, modManPso2binPath);
              }
            }
          }
        }
      }
    }

    saveSetListToJson();

    List<VitalGaugeBackground> vgList = [];
    File modManVGListFile = File(modManVitalGaugeJsonPath);
    if (modManVGListFile.existsSync()) {
      String data = modManVGListFile.readAsStringSync();
      if (data.isNotEmpty) {
        var jsonData = jsonDecode(data);
        for (var type in jsonData) {
          vgList.add(VitalGaugeBackground.fromJson(type));
        }
      }
    }

    for (int i = 0; i < vgList.length; i++) {
      vgList[i].icePath = vgList[i].icePath.replaceFirst(oldPso2binDirPath, modManPso2binPath);
    }

    saveVitalGaugesInfoToJson(vgList);
    await appliedVitalGaugesCheck(context);
  }
}

Future<void> createSubDirs(context) async {
  await clearAllTempDirsBeforeGettingPath();
  //Create Mods folder and default categories
  modManModsDirPath = Uri.file('$modManDirPath/Mods').toFilePath();
  Directory(modManModsDirPath).createSync(recursive: true);
  for (var name in defaultCategoryDirs) {
    Directory(Uri.file('$modManModsDirPath/$name').toFilePath()).createSync(recursive: true);
  }
  //Create Backups folder
  modManBackupsDirPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Backups').toFilePath() : Uri.file('$modManDirPath/Backups_profile2').toFilePath();
  Directory(modManBackupsDirPath).createSync(recursive: true);
  List<String> dataFolders = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  for (var name in dataFolders) {
    Directory(Uri.file('$modManBackupsDirPath/$name').toFilePath()).createSync(recursive: true);
  }
  //Create Vital gauge folder
  modManVitalGaugeDirPath = Uri.file('$modManDirPath/Vital Gauge').toFilePath();
  Directory(modManVitalGaugeDirPath).createSync(recursive: true);
  modManVitalGaugeOriginalsDirPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/Vital Gauge/Originals').toFilePath() : Uri.file('$modManDirPath/Vital Gauge/Originals_profile2').toFilePath();
  Directory(modManVitalGaugeOriginalsDirPath).createSync(recursive: true);
  //Create Checksum folder
  modManChecksumDirPath = Uri.file('$modManDirPath/Checksum').toFilePath();
  Directory(modManChecksumDirPath).createSync(recursive: true);
  //Create Deleted Items folder
  modManDeletedItemsDirPath = Uri.file('$modManDirPath/Deleted Items').toFilePath();
  Directory(modManDeletedItemsDirPath).createSync(recursive: true);
  //Create misc folders
  modManAddModsTempDirPath = Uri.file('$modManDirPath/temp').toFilePath();
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  modManAddModsUnpackDirPath = Uri.file('$modManDirPath/unpack').toFilePath();
  Directory(modManAddModsUnpackDirPath).createSync(recursive: true);
  modManModsAdderPath = Uri.file('$modManDirPath/modsAdder').toFilePath();
  Directory(modManModsAdderPath).createSync(recursive: true);
  modManTempCmxDirPath = Uri.file('$modManDirPath/tempCmx').toFilePath();
  Directory(modManTempCmxDirPath).createSync(recursive: true);
  //Create Json files
  modManModsListJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManModsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManModsList_profile2.json').toFilePath();
  File(modManModsListJsonPath).createSync(recursive: true);
  modManModSetsJsonPath = modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath();
  File(modManModSetsJsonPath).createSync(recursive: true);
  modManVitalGaugeJsonPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManVitalGaugeList.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManVitalGaugeList_profile2.json').toFilePath();
  File(modManVitalGaugeJsonPath).createSync(recursive: true);
  // modManModSettingsJsonPath = Uri.file('$modManDirPath/PSO2ModManSettings.json').toFilePath();
  // File(modManModSettingsJsonPath).createSync();
  modManAppliedModsJsonPath =
      modManCurActiveProfile == 1 ? Uri.file('$modManDirPath/PSO2ModManAppliedMods.json').toFilePath() : Uri.file('$modManDirPath/PSO2ModManAppliedMods_profile2.json').toFilePath();

  //Swapper paths
  modManSwapperDirPath = Uri.file('$modManDirPath/swapper').toFilePath();
  modManSwapperFromItemDirPath = Uri.file('$modManDirPath/swapper/fromitem').toFilePath();
  modManSwapperToItemDirPath = Uri.file('$modManDirPath/swapper/toitem').toFilePath();
  modManSwapperOutputDirPath = Uri.file('$modManDirPath/swapper/Swapped Items').toFilePath();
  //exporter path
  modManExportedDirPath = Uri.file('$modManDirPath/exported').toFilePath();
  Directory(modManExportedDirPath).createSync(recursive: true);
  //overlayed icon path
  modManOverlayedItemIconsDirPath = Uri.file('$modManDirPath/overlayed_item_icons').toFilePath();
  Directory(modManOverlayedItemIconsDirPath).createSync(recursive: true);
  //json saves
  modManJsonAutoSaveDir = Uri.file('$modManDirPath/jsonBackup/auto').toFilePath();
  Directory(modManJsonAutoSaveDir).createSync(recursive: true);
  modManJsonManualSaveDir = Uri.file('$modManDirPath/jsonBackup/manual').toFilePath();
  Directory(modManJsonManualSaveDir).createSync(recursive: true);
  //mods adder ignore list
  modManAddModsIgnoreListPath = Uri.file('$modManDirPath/modAdderIgnoreList.txt').toFilePath();
  File(modManAddModsIgnoreListPath).createSync(recursive: true);
  //custom aqm
  modManCustomAqmDir = Uri.file('$modManDirPath/customAqm').toFilePath();
  Directory(modManCustomAqmDir).createSync(recursive: true);
  if (Directory(modManCustomAqmDir).existsSync() && modManCustomAqmFileName.isNotEmpty) {
    modManCustomAqmFilePath = Uri.file('$modManCustomAqmDir/$modManCustomAqmFileName').toFilePath();
    if (!File(modManCustomAqmFilePath).existsSync() && Provider.of<StateProvider>(context, listen: false).autoAqmInject) {
      final prefs = await SharedPreferences.getInstance();
      autoAqmInject = false;
      prefs.setBool('autoAqmInject', false);
      Provider.of<StateProvider>(context, listen: false).autoAqmInjectSet(false);
    }
  }
}
