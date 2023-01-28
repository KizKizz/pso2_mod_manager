// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class PathsLoadingPage extends StatefulWidget {
  const PathsLoadingPage({Key? key}) : super(key: key);

  @override
  State<PathsLoadingPage> createState() => _PathsLoadingPageState();
}

class _PathsLoadingPageState extends State<PathsLoadingPage> {
  @override
  void initState() {
    mainPathsCheck();

    super.initState();
  }

  void mainPathsCheck() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';
    mainModManDirPath = prefs.getString('mainModManDirPath') ?? '';

    if (mainModManDirPath.isEmpty) {
      await getMainModManDirPath();
    } else {
      if (!Directory('$mainModManDirPath${s}PSO2 Mod Manager').existsSync()) {
        await getMainModManDirPath();
      } else {
        context.read<StateProvider>().mainModManPathFoundTrue();
      }
    }

    if (binDirPath.isEmpty) {
      await getDirPath();
    } else {
      if (!Directory(binDirPath).existsSync()) {
        await getDirPath();
        dirPathCheck();
      } else {
        context.read<StateProvider>().mainBinFoundTrue();
      }
    }

    if (binDirPath.isNotEmpty && mainModManDirPath.isNotEmpty && Directory(binDirPath).existsSync() && Directory('$mainModManDirPath${s}PSO2 Mod Manager').existsSync()) {
      dirPathCheck();
    }
  }

  Future<void> getDirPath() async {
    binDirDialog(context, 'Error', curLangText!.pso2binNotFoundPopupText, false);
  }

  Future<void> getMainModManDirPath() async {
    mainModManDirDialog(context, curLangText!.modmanFolderNotFoundLabelText, curLangText!.modmanFolderNotFoundText, false);
  }

  Future<void> dirPathCheck() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';
    mainModManDirPath = prefs.getString('mainModManDirPath') ?? '';

    if (mainModManDirPath.isNotEmpty) {
      //Fill in paths
      mainModDirPath = '$mainModManDirPath${s}PSO2 Mod Manager';
      modsDirPath = '$mainModDirPath${s}Mods';
      backupDirPath = '$mainModDirPath${s}Backups';
      checksumDirPath = '$mainModDirPath${s}Checksum';
      modSettingsPath = '$mainModDirPath${s}PSO2ModManSettings.json';
      modSetsSettingsPath = '$mainModDirPath${s}PSO2ModManModSets.json';
      deletedItemsPath = '$mainModDirPath${s}Deleted Items';
      //Check if exist, create dirs
      if (!Directory(mainModDirPath).existsSync()) {
        await Directory(mainModDirPath).create(recursive: true);
      }
      if (!Directory(modsDirPath).existsSync()) {
        await Directory(modsDirPath).create(recursive: true);
        await Directory('$modsDirPath${s}Accessories').create(recursive: true);
        await Directory('$modsDirPath${s}Basewears').create(recursive: true);
        await Directory('$modsDirPath${s}Body Paints').create(recursive: true);
        await Directory('$modsDirPath${s}Emotes').create(recursive: true);
        await Directory('$modsDirPath${s}Face Paints').create(recursive: true);
        await Directory('$modsDirPath${s}Innerwears').create(recursive: true);
        await Directory('$modsDirPath${s}Misc').create(recursive: true);
        await Directory('$modsDirPath${s}Motions').create(recursive: true);
        await Directory('$modsDirPath${s}Outerwears').create(recursive: true);
        await Directory('$modsDirPath${s}Setwears').create(recursive: true);
        await Directory('$modsDirPath${s}Mags').create(recursive: true);
        await Directory('$modsDirPath${s}Stickers').create(recursive: true);
        await Directory('$modsDirPath${s}Hairs').create(recursive: true);
        await Directory('$modsDirPath${s}Cast Body Parts').create(recursive: true);
        await Directory('$modsDirPath${s}Cast Arm Parts').create(recursive: true);
        await Directory('$modsDirPath${s}Cast Leg Parts').create(recursive: true);
        await Directory('$modsDirPath${s}Eyes').create(recursive: true);
        await Directory('$modsDirPath${s}Costumes').create(recursive: true);
      } else {
        for (var cateName in defaultCatesList) {
          Directory('$modsDirPath$s$cateName').createSync(recursive: true);
        }
      }
      if (!Directory(backupDirPath).existsSync()) {
        await Directory(backupDirPath).create(recursive: true);
      }
      if (!Directory('$backupDirPath${s}win32_na').existsSync()) {
        await Directory('$backupDirPath${s}win32_na').create(recursive: true);
      }
      if (!Directory('$backupDirPath${s}win32reboot_na').existsSync()) {
        await Directory('$backupDirPath${s}win32reboot_na').create(recursive: true);
      }
      if (!Directory(checksumDirPath).existsSync()) {
        await Directory(checksumDirPath).create(recursive: true);
      }
      if (!File(deletedItemsPath).existsSync()) {
        await Directory(deletedItemsPath).create(recursive: true);
      }
      if (!File(modSettingsPath).existsSync()) {
        await File(modSettingsPath).create(recursive: true);
      }
      if (!File(modSetsSettingsPath).existsSync()) {
        await File(modSetsSettingsPath).create(recursive: true);
      }

      setState(() {
        context.read<StateProvider>().mainModManPathFoundTrue();
      });

      //Checksum check
      if (checkSumFilePath == null) {
        final filesInCSFolder = Directory(checksumDirPath).listSync().whereType<File>();
        for (var file in filesInCSFolder) {
          if (p.extension(file.path) == '') {
            checkSumFilePath = file.path;
          }
        }
      }
    }
    if (binDirPath.isNotEmpty) {
      setState(() {
        context.read<StateProvider>().mainBinFoundTrue();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return context.watch<StateProvider>().isMainBinFound && context.watch<StateProvider>().isMainModManPathFound
        ? const DataLoadingPage()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                curLangText!.waitingUserActionText,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              const CircularProgressIndicator(),
            ],
          );
  }
}
