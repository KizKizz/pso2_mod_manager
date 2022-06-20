import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
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
                            List<String> parentPaths = [];
                            for (var mod in modsInCurItem) {
                              parentPaths.add(File(mod.icePath).parent.path);
                              if (File(mod.icePath).existsSync()) {
                                String fileDeleteBackupPath = deleteBackupPath + mod.icePath.split(mod.modPath).last;
                                File(fileDeleteBackupPath).createSync(recursive: true);
                                File(mod.icePath).copySync(fileDeleteBackupPath);
                                File(mod.icePath).deleteSync(recursive: false);
                              }
                            }

                            //Remove leftover files
                            parentPaths.toSet();
                            for (var path in parentPaths) {
                              if (Directory(path).existsSync()) {
                                final leftOverFiles = Directory(path).listSync(recursive: false).whereType<File>();
                                if (leftOverFiles.isNotEmpty) {
                                  for (var file in leftOverFiles) {
                                    String leftOverFileDeleteBackupPath = '$deletedItemsPath\\$formattedDate\\${curCate.categoryName}\\$curItem${file.path.split(curItem).last}';
                                    //print(sourcePath);
                                    File(leftOverFileDeleteBackupPath).createSync(recursive: true);
                                    File(file.path).copySync(leftOverFileDeleteBackupPath);
                                    File(file.path).deleteSync(recursive: true);
                                  }
                                }
                              }
                            }
                            for (var path in parentPaths) {
                              if (Directory(path).existsSync() &&
                                  Directory(path).listSync(recursive: true).whereType<File>().isEmpty &&
                                  Directory(path).listSync(recursive: true).whereType<Directory>().isEmpty) {
                                Directory(path).deleteSync(recursive: true);
                              }
                            }

                            final subFolderList = Directory(curCate.categoryPath).listSync().whereType<Directory>();
                            for (var folder in subFolderList) {
                              if (Directory(folder.path).listSync(recursive: true).whereType<File>().isEmpty) {
                                Directory(folder.path).deleteSync(recursive: true);
                              }
                            }
                          }

                          curCate.imageIcons.removeAt(curCate.itemNames.indexOf(curItem));
                          curCate.numOfMods.removeAt(curCate.itemNames.indexWhere((element) => element == curItem));
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
                        List<String> parentPaths = [];
                        String curCateName = '';
                        //Remove ice files
                        for (var mod in modsList) {
                          if (curCateName == '') {
                            curCateName = mod.categoryName;
                          }
                          parentPaths.add(File(mod.icePath).parent.path);
                          String deleteBackupPath = '$deletedItemsPath\\$formattedDate\\${mod.categoryName}\\$curModName${mod.icePath.split(curModName).last}';
                          File(deleteBackupPath).createSync(recursive: true);
                          File(mod.icePath).copySync(deleteBackupPath);
                          File(mod.icePath).deleteSync(recursive: false);
                        }
                        //Remove leftover files
                        parentPaths.toSet();
                        for (var path in parentPaths) {
                          final leftOverFiles = Directory(path).listSync(recursive: false).whereType<File>();
                          if (leftOverFiles.isNotEmpty) {
                            for (var file in leftOverFiles) {
                              String leftOverFileDeleteBackupPath = '$deletedItemsPath\\$formattedDate\\$curCateName\\$curModName${file.path.split(curModName).last}';
                              //print(sourcePath);
                              File(leftOverFileDeleteBackupPath).createSync(recursive: true);
                              File(file.path).copySync(leftOverFileDeleteBackupPath);
                              File(file.path).deleteSync(recursive: true);
                            }
                          }
                        }
                        for (var path in parentPaths) {
                          if (Directory(path).existsSync() &&
                              Directory(path).listSync(recursive: true).whereType<File>().isEmpty &&
                              Directory(path).listSync(recursive: true).whereType<Directory>().isEmpty) {
                            Directory(path).deleteSync(recursive: true);
                          }
                        }

                        if (Directory(curModPath).existsSync()) {
                          final subFolderList = Directory(curModPath).listSync().whereType<Directory>();
                          for (var folder in subFolderList) {
                            if (Directory(folder.path).listSync(recursive: true).whereType<File>().isEmpty && Directory(folder.path).listSync(recursive: true).whereType<Directory>().isEmpty) {
                              Directory(folder.path).deleteSync(recursive: true);
                            }
                          }

                          if (Directory(curModPath).listSync(recursive: true).whereType<File>().isEmpty && Directory(curModPath).listSync(recursive: true).whereType<Directory>().isEmpty) {
                            Directory(curModPath).deleteSync(recursive: true);
                          }
                        }

                        ModCategory curCate = cateList.firstWhere((cate) => cate.allModFiles.indexWhere((file) => file.modPath == curModPath) != -1);
                        final curModIndex = curCate.itemNames.indexOf(curModName);
                        curCate.numOfMods[curModIndex]--;
                        modFilesList.removeAt(modFilesList.indexOf(modsList));
                        for (var element in modsList) {
                          curCate.allModFiles.remove(element);
                          allModFiles.remove(element);
                        }
                      }
                    }),
                    child: const Text('Sure'))
            ],
          );
        });
      });
}

//Remove Mod Dialog
Future pictureDialog(context, List<Widget> previewImageSliders) async {
  CarouselController imgSliderController = CarouselController();
  int currentImg = 0;
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(top: 5, left: 5, right: 5),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                InteractiveViewer(
                  scaleEnabled: true,
                  panEnabled: true,
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: CarouselSlider(
                      items: previewImageSliders,
                      carouselController: imgSliderController,
                      options: CarouselOptions(
                          //height: double.maxFinite,
                          autoPlay: false,
                          reverse: true,
                          viewportFraction: 1.0,
                          enlargeCenterPage: true,
                          aspectRatio: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentImg = index;
                            });
                          }),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 250, child: Text('Scroll wheel: Zoom | Right mouse: Pan',)),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (previewImageSliders.isNotEmpty)
                          SizedBox(
                            width: 40,
                            child: MaterialButton(
                              onPressed: (() => imgSliderController.previousPage()),
                              child: const Icon(Icons.arrow_left),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: modPreviewImgList.asMap().entries.map((entry) {
                            return GestureDetector(
                              onTap: () => imgSliderController.animateToPage(entry.key),
                              child: Container(
                                width: 10.0,
                                height: 10.0,
                                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentImg == entry.key ? 0.9 : 0.4)),
                              ),
                            );
                          }).toList(),
                        ),
                        if (previewImageSliders.isNotEmpty)
                          SizedBox(
                            width: 40,
                            child: MaterialButton(
                              onPressed: (() => imgSliderController.nextPage()),
                              child: const Icon(Icons.arrow_right),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      });
}
