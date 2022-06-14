import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';

Future binDirDialog(context, String popupTitle, String popupMessage, bool isReselect) async {
  await showDialog<String>(
      barrierDismissible: false,
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
                          deletedItemsPath = '$mainModDirPath\\Deleted Items';
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
                          if (!File(deletedItemsPath).existsSync()) {
                            await Directory(deletedItemsPath).create(recursive: true);
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
                          deletedItemsPath = '$mainModDirPath\\Deleted Items';
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
                          if (!File(deletedItemsPath).existsSync()) {
                            await Directory(deletedItemsPath).create(recursive: true);
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

//Remove Items Dialog
categoryDeleteDialog(context, double height, String popupTitle, String popupMessage, bool isYesOn, String curCatePath, List<ModFile> modsList) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy').format(now);
          return AlertDialog(
            titlePadding: const EdgeInsets.only(top: 10),
            title: Center(
              child: Text(popupTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            content: Container(
                constraints: BoxConstraints(minHeight: 40, maxHeight: height),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Text(popupMessage),
                    ],
                  ),
                )),
            actions: <Widget>[
              ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              if (isYesOn)
                ElevatedButton(
                    onPressed: (() async {
                      bool isRemovedFromList = false;
                      if (!isRemovedFromList) {
                        cateList.removeWhere((element) => element.categoryPath == curCatePath);
                        isRemovedFromList = true;
                        Navigator.of(context).pop();
                      }
                      if (modsList.isEmpty) {
                        String newPath = '';
                        var curPathSplit = curCatePath.split('\\');
                        for (var element in curPathSplit) {
                          if (element == 'Mods') {
                            element = 'Deleted Items\\$formattedDate';
                          }
                          if (element != curPathSplit.last) {
                            newPath += '$element\\';
                          } else {
                            newPath += element;
                          }
                        }
                        Directory(newPath).createSync(recursive: true);
                        Directory(curCatePath).deleteSync(recursive: true);
                      } else {
                        for (var mod in modsList) {
                          await Future(
                            () {
                              String newPath = '';
                              String newDirPath = '';
                              var curPathSplit = mod.icePath.split('\\');
                              for (var element in curPathSplit) {
                                if (element == 'Mods') {
                                  element = 'Deleted Items\\$formattedDate';
                                }
                                if (element != curPathSplit.last) {
                                  newPath += '$element\\';
                                } else {
                                  newDirPath = newPath;
                                  newPath += element;
                                }
                              }

                              if (!File(newPath).existsSync() && isRemovedFromList) {
                                Directory(newDirPath).createSync(recursive: true);
                                File(mod.icePath).copySync(newPath);
                              }
                            },
                          );
                        }
                        File(curCatePath).deleteSync(recursive: true);
                      }
                    }),
                    child: const Text('Sure')),
            ],
          );
        });
      });
}

//Remove Items Dialog
Future itemDeleteDialog(context, double height, String popupTitle, String popupMessage, bool isYesOn, ModCategory curCate, String curItem, List<ModFile> modsList) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy').format(now);
          return AlertDialog(
            titlePadding: const EdgeInsets.only(top: 10),
            title: Center(
              child: Text(popupTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            content: Container(
                constraints: BoxConstraints(minHeight: 40, maxHeight: height),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Text(popupMessage),
                    ],
                  ),
                )),
            actions: <Widget>[
              ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              if (isYesOn)
                ElevatedButton(
                    onPressed: (() {
                      setState(
                        () {
                          Navigator.of(context).pop();

                          String deleteBackupPath = '$deletedItemsPath\\$formattedDate\\${curCate.categoryName}\\$curItem';
                          final modsInCurItem = modsList.where((element) => element.modName == curItem);
                          if (modsInCurItem.isEmpty) {
                            Directory(deleteBackupPath).createSync(recursive: true);
                            Directory('${curCate.categoryPath}\\$curItem').deleteSync(recursive: true);
                          } else {
                            for (var mod in modsInCurItem) {
                              String fileDeleteBackupPath = deleteBackupPath + mod.icePath.split(mod.modPath).last;
                              File(fileDeleteBackupPath).createSync(recursive: true);
                              File(mod.icePath).copySync(fileDeleteBackupPath);
                              File(mod.icePath).deleteSync(recursive: false);
                            }
                            final leftOverFiles = Directory('${curCate.categoryPath}\\$curItem').listSync(recursive: true).whereType<File>();
                            for (var file in leftOverFiles) {
                              String leftOverFileDeleteBackupPath = deleteBackupPath + file.path.split('${curCate.categoryPath}\\$curItem').last;
                              File(leftOverFileDeleteBackupPath).createSync(recursive: true);
                              File(file.path).copySync(leftOverFileDeleteBackupPath);
                              File(file.path).deleteSync(recursive: true);
                            }
                            Directory(('${curCate.categoryPath}\\$curItem')).deleteSync(recursive: true);
                          }

                          curCate.imageIcons.removeAt(curCate.itemNames.indexOf(curItem));
                          curCate.itemNames.removeWhere((element) => element == curItem);
                          curCate.allModFiles.removeWhere((element) => element.modName == curItem);
                          curCate.numOfItems--;
                          allModFiles.removeWhere((element) => element.categoryPath == curCate.categoryPath && element.modName == curItem);
                        },
                      );
                    }),
                    child: const Text('Sure'))
            ],
          );
        });
      });
}

//Remove Mod Dialog
Future modDeleteDialog(context, double height, String popupTitle, String popupMessage, bool isYesOn, String curModPath, String curModParent, String curModName, List<ModFile> modsList) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy').format(now);
          return AlertDialog(
            titlePadding: const EdgeInsets.only(top: 10),
            title: Center(
              child: Text(popupTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            content: Container(
                constraints: BoxConstraints(minHeight: 40, maxHeight: height),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      Text(popupMessage),
                    ],
                  ),
                )),
            actions: <Widget>[
              ElevatedButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              if (isYesOn)
                ElevatedButton(
                    onPressed: (() {
                      Navigator.of(context).pop();

                      if (modsList.isNotEmpty) {
                        String sourcePath = '';
                        String curCateName = '';
                        for (var mod in modsList) {
                          String fileDeleteBackupPath = '$deletedItemsPath\\$formattedDate\\${mod.categoryName}\\$curModName${mod.icePath.split(mod.modPath).last}';
                         // print(fileDeleteBackupPath);
                          sourcePath = '${mod.categoryPath}\\$curModName${mod.icePath.split(mod.modPath).last}'.split('\\${mod.iceName}').first;
                          curCateName = mod.categoryName;
                          File(fileDeleteBackupPath).createSync(recursive: true);
                          File(mod.icePath).copySync(fileDeleteBackupPath);
                          File(mod.icePath).deleteSync(recursive: false);
                        }
                        //Remove extras
                        final leftOverFiles = Directory(sourcePath).listSync(recursive: false).whereType<File>();
                        for (var file in leftOverFiles) {
                          String leftOverFileDeleteBackupPath = '$deletedItemsPath\\$formattedDate\\$curCateName\\$curModName${file.path.split(sourcePath).last}';
                          //print(sourcePath);
                          File(leftOverFileDeleteBackupPath).createSync(recursive: true);
                          File(file.path).copySync(leftOverFileDeleteBackupPath);
                          File(file.path).deleteSync(recursive: true);
                        }

                        if (Directory(sourcePath).listSync(recursive: true).whereType<File>().isEmpty) {
                          Directory(sourcePath).deleteSync(recursive: true);
                        }

                        ModCategory curCate = cateList.firstWhere((cate) => cate.allModFiles.indexWhere((file) => file.modPath == curModPath) != -1);
                        final curModIndex = curCate.itemNames.indexOf(curModName);
                        curCate.numOfMods[curModIndex]--;
                        modFilesList.removeWhere((element) => element == modsList);
                        allModFiles.removeWhere((element) => element.categoryPath == curCate.categoryPath && element.modName == curModName);
                      }
                    }),
                    child: const Text('Sure'))
            ],
          );
        });
      });
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
