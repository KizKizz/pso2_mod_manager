import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class CustomPopups {
  const CustomPopups();

  binDirDialog(context, String popupTitle, String popupMessage, bool isReselect) async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.only(top: 10),
              title: Center(
                child: Text(popupTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: SizedBox(
                  //width: 300,
                  height: 70,
                  child: Center(child: Text(popupMessage))),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Exit'),
                    onPressed: () async {
                      if (!isReselect) {
                        Navigator.of(context).pop();
                        await windowManager.destroy();
                      } else {
                        Navigator.of(context).pop();
                      }
                    }),
                ElevatedButton(
                    onPressed: (() async {
                      Navigator.of(context).pop();
                      String? binDirTempPath;

                      if (!isReselect) {
                        while (binDirTempPath == null) {
                          binDirTempPath = await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Select \'pso2_bin\' Directory Path',
                            lockParentWindow: true,
                          );
                          List<String> getCorrectPath = binDirTempPath.toString().split('\\');
                          if (getCorrectPath.last == 'pso2_bin') {
                            binDirPath = binDirTempPath.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('binDirPath', binDirPath);
                          }
                          if (binDirPath != '') {
                            //Fill in paths
                            mainModDirPath = '$binDirPath\\PSO2 Mod Manager';
                            modsDirPath = '$mainModDirPath\\Mods';
                            backupDirPath = '$mainModDirPath\\Backups';
                            checksumDirPath = '$mainModDirPath\\Checksum';
                            modSettingsPath = '$mainModDirPath\\PSO2ModManSettings.json';
                            //Check if exist, create dirs
                            if (!Directory(mainModDirPath).existsSync()) {
                              await Directory(mainModDirPath).create(recursive: true);
                            }
                            if (!Directory(modsDirPath).existsSync()) {
                              await Directory(modsDirPath).create(recursive: true);
                              await Directory('$modsDirPath\\Accessories').create(recursive: true);
                              await Directory('$modsDirPath\\Basewears').create(recursive: true);
                              await Directory('$modsDirPath\\Body Paints').create(recursive: true);
                              await Directory('$modsDirPath\\Emotes').create(recursive: true);
                              await Directory('$modsDirPath\\Face Paints').create(recursive: true);
                              await Directory('$modsDirPath\\Innerwears').create(recursive: true);
                              await Directory('$modsDirPath\\Misc').create(recursive: true);
                              await Directory('$modsDirPath\\Motions').create(recursive: true);
                              await Directory('$modsDirPath\\Outerwears').create(recursive: true);
                              await Directory('$modsDirPath\\Setwears').create(recursive: true);
                            }
                            if (!Directory(backupDirPath).existsSync()) {
                              await Directory(backupDirPath).create(recursive: true);
                            }
                            if (!Directory(checksumDirPath).existsSync()) {
                              await Directory(checksumDirPath).create(recursive: true);
                            }
                            if (!File(modSettingsPath).existsSync()) {
                              await File(modSettingsPath).create(recursive: true);
                            }
                            context.read<stateProvider>().mainBinFoundTrue();
                          } else {
                            binDirTempPath = await FilePicker.platform.getDirectoryPath(
                              dialogTitle: 'Select \'pso2_bin\' Directory Path',
                              lockParentWindow: true,
                            );
                          }
                        }
                      } else {
                        binDirTempPath = await FilePicker.platform.getDirectoryPath(
                          dialogTitle: 'Select \'pso2_bin\' Directory Path',
                          lockParentWindow: true,
                        );
                        if (binDirTempPath != null) {
                          List<String> getCorrectPath = binDirTempPath.toString().split('\\');
                          if (getCorrectPath.last == 'pso2_bin') {
                            binDirPath = binDirTempPath.toString();
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setString('binDirPath', binDirPath);
                          }
                          if (binDirPath != '') {
                            //Fill in paths
                            mainModDirPath = '$binDirPath\\PSO2 Mod Manager';
                            modsDirPath = '$mainModDirPath\\Mods';
                            backupDirPath = '$mainModDirPath\\Backups';
                            checksumDirPath = '$mainModDirPath\\Checksum';
                            modSettingsPath = '$mainModDirPath\\PSO2ModManSettings.json';
                            //Check if exist, create dirs
                            if (!Directory(mainModDirPath).existsSync()) {
                              await Directory(mainModDirPath).create(recursive: true);
                            }
                            if (!Directory(modsDirPath).existsSync()) {
                              await Directory(modsDirPath).create(recursive: true);
                              await Directory('$modsDirPath\\Accessories').create(recursive: true);
                              await Directory('$modsDirPath\\Basewears').create(recursive: true);
                              await Directory('$modsDirPath\\Body Paints').create(recursive: true);
                              await Directory('$modsDirPath\\Emotes').create(recursive: true);
                              await Directory('$modsDirPath\\Face Paints').create(recursive: true);
                              await Directory('$modsDirPath\\Innerwears').create(recursive: true);
                              await Directory('$modsDirPath\\Misc').create(recursive: true);
                              await Directory('$modsDirPath\\Motions').create(recursive: true);
                              await Directory('$modsDirPath\\Outerwears').create(recursive: true);
                              await Directory('$modsDirPath\\Setwears').create(recursive: true);
                            }
                            if (!Directory(backupDirPath).existsSync()) {
                              await Directory(backupDirPath).create(recursive: true);
                            }
                            if (!Directory(checksumDirPath).existsSync()) {
                              await Directory(checksumDirPath).create(recursive: true);
                            }
                            if (!File(modSettingsPath).existsSync()) {
                              await File(modSettingsPath).create(recursive: true);
                            }
                            context.read<stateProvider>().mainBinFoundTrue();
                          } else {
                            binDirTempPath = await FilePicker.platform.getDirectoryPath(
                              dialogTitle: 'Select \'pso2_bin\' Directory Path',
                              lockParentWindow: true,
                            );
                          }
                        }
                      }
                    }),
                    child: const Text('Yes'))
              ],
            );
          });
        });
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  const _SystemPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(padding: mediaQuery.viewInsets, duration: const Duration(milliseconds: 300), child: child);
  }
}
