import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:provider/provider.dart';

import 'main.dart';

import 'package:path/path.dart' as p;

Directory dataDir = Directory('$binDirPath\\data');
List<File> iceFiles = [];

Future<void> reapplyMods(List<ModFile> modList) async {
  //Checksum
  if (checkSumFilePath != null) {
    File(checkSumFilePath!).copySync('$binDirPath\\data\\win32\\${checkSumFilePath!.split('\\').last}');
  }

  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //Backup file check and apply
          final matchedFile = iceFiles.firstWhere(
            (e) => e.path.split('\\').last == modFile.iceName,
            orElse: () {
              return File('');
            },
          );

          if (matchedFile.path != '') {
            modFile.originalIcePath = matchedFile.path;
            final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
              (e) => p.extension(e.path) == '' && e.path.split('\\').last == modFile.iceName,
              orElse: () {
                return File('');
              },
            );

            if (matchedBackup.path == '') {
              modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
              //Backup file if not already
              File(modFile.originalIcePath).copySync(modFile.backupIcePath);
            }

            //File actions
            File(modFile.icePath).copySync(modFile.originalIcePath);
          } else {
            originalFilesMissingList.add(modFile);
          }
        },
      );
    }
  } else {
    for (var modFile in modList) {
      //Backup file check and apply
      final matchedFile = iceFiles.firstWhere(
        (e) => e.path.split('\\').last == modFile.iceName,
        orElse: () {
          return File('');
        },
      );

      if (matchedFile.path != '') {
        modFile.originalIcePath = matchedFile.path;
        final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
          (e) => p.extension(e.path) == '' && e.path.split('\\').last == modFile.iceName,
          orElse: () {
            return File('');
          },
        );

        if (matchedBackup.path == '') {
          modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
          //Backup file if not already
          File(modFile.originalIcePath).copySync(modFile.backupIcePath);
        }

        //File actions
        File(modFile.icePath).copySync(modFile.originalIcePath);
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
        modFile.appliedDate = formattedDate;
      } else {
        originalFilesMissingList.add(modFile);
      }
    }
  }

  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
}

Future<void> modsToDataAdder(List<ModFile> modList) async {
  List<List<ModFile>> duplicateModsApplied = [];
  List<ModFile> actualAppliedMods = [];
  originalFilesMissingList.clear();
  //Checksum
  if (checkSumFilePath != null) {
    File(checkSumFilePath!).copySync('$binDirPath\\data\\win32\\${checkSumFilePath!.split('\\').last}');
  }

  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //Backup file check and apply
          final matchedFile = iceFiles.firstWhere(
            (e) => e.path.split('\\').last == modFile.iceName,
            orElse: () {
              return File('');
            },
          );

          if (matchedFile.path != '') {
            modFile.originalIcePath = matchedFile.path;
            final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
              (e) => p.extension(e.path) == '' && e.path.split('\\').last == modFile.iceName,
              orElse: () {
                return File('');
              },
            );

            if (matchedBackup.path == '') {
              modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
              //Backup file if not already
              File(modFile.originalIcePath).copySync(modFile.backupIcePath);
            } else {
              //check for dub applied mod
              //set backup path to file
              modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
              for (var lists in modFilesList) {
                List<ModFile> matchingList = lists.where((element) => element.iceName == modFile.iceName && element.isApplied == true).toList();
                if (matchingList.isNotEmpty) {
                  duplicateModsApplied.add(matchingList);

                  if (appliedModsList.isNotEmpty) {
                    for (var mod in matchingList) {
                      for (var appliedList in appliedModsList) {
                        appliedList.remove(mod);
                      }
                    }
                    appliedModsList.removeWhere((element) => element.isEmpty);
                  }
                }
              }
            }

            //File actions
            File(modFile.icePath).copySync(modFile.originalIcePath);
            modFile.isApplied = true;
            modFile.isNew = false;
            actualAppliedMods.add(modFile);
          } else {
            originalFilesMissingList.add(modFile);
          }
        },
      );
    }

    //Unapply, restore old dub
    for (var modList in duplicateModsApplied) {
      for (var element in modList) {
        modAppliedDup.add(element);
        File(element.backupIcePath).copySync(element.originalIcePath);
        element.isApplied = false;
      }
    }
  } else {
    for (var modFile in modList) {
      //Backup file check and apply
      final matchedFile = iceFiles.firstWhere(
        (e) => e.path.split('\\').last == modFile.iceName,
        orElse: () {
          return File('');
        },
      );

      if (matchedFile.path != '') {
        modFile.originalIcePath = matchedFile.path;
        final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
          (e) => p.extension(e.path) == '' && e.path.split('\\').last == modFile.iceName,
          orElse: () {
            return File('');
          },
        );

        if (matchedBackup.path == '') {
          modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
          //Backup file if not already
          File(modFile.originalIcePath).copySync(modFile.backupIcePath);
        } else {
          //check for dub applied mod
          //set backup path to file
          modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
          for (var lists in modFilesList) {
            List<ModFile> matchingList = lists.where((element) => element.iceName == modFile.iceName && element.isApplied == true).toList();
            if (matchingList.isNotEmpty) {
              duplicateModsApplied.add(matchingList);

              if (appliedModsList.isNotEmpty) {
                for (var mod in matchingList) {
                  for (var appliedList in appliedModsList) {
                    appliedList.remove(mod);
                  }
                }
                appliedModsList.removeWhere((element) => element.isEmpty);
              }
            }
          }
        }

        //File actions
        File(modFile.icePath).copySync(modFile.originalIcePath);
        modFile.isApplied = true;
        modFile.isNew = false;
        actualAppliedMods.add(modFile);
      } else {
        originalFilesMissingList.add(modFile);
      }
    }
    //Unapply, restore old dub
    for (var modList in duplicateModsApplied) {
      for (var element in modList) {
        modAppliedDup.add(element);
        File(element.backupIcePath).copySync(element.originalIcePath);
        element.isApplied = false;
      }
    }
  }

  //Applied mods to app list
  for (var mod in actualAppliedMods) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
    if (appliedModsList.isEmpty) {
      mod.appliedDate = formattedDate;
      appliedModsList.insert(0, [mod]);
    } else {
      final tempMods = appliedModsList.firstWhere(
        (modList) => modList.indexWhere((applied) => applied.iceParent == mod.iceParent && applied.modName == mod.modName) != -1,
        orElse: () {
          return [];
        },
      );
      if (tempMods.isNotEmpty) {
        tempMods.add(mod);
      } else {
        mod.appliedDate = formattedDate;
        appliedModsList.insert(0, [mod]);
      }
    }
    //appliedModsList.sort(((a, b) => a.first.appliedDate.compareTo(b.first.appliedDate)));
  }

  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
}

void modsRemover(List<ModFile> modsList) {
  final backupFiles = Directory(backupDirPath).listSync(recursive: true).whereType<File>();
  List<ModFile> actualRemovedMods = [];
  backupFilesMissingList.clear();

  for (var mod in modsList) {
    final matchedBackup = backupFiles.firstWhere(
      (e) => p.extension(e.path) == '' && e.path.split('\\').last == mod.iceName,
      orElse: () {
        return File('');
      },
    );

    if (matchedBackup.path != '') {
      File(mod.backupIcePath).copySync(mod.originalIcePath);
      mod.isApplied = false;
      actualRemovedMods.add(mod);
      File(mod.backupIcePath).deleteSync();

      //remove from applied list
      if (appliedModsList.isNotEmpty) {
        List<List<ModFile>> emptyList = [];
        for (var appliedList in appliedModsList) {
          List<ModFile> tempList = appliedList;
          ModFile? tempMod;
          for (var appliedMod in appliedList) {
            if (appliedMod.iceName == mod.iceName) {
              tempMod = appliedMod;
            }
          }
          if (tempList.isNotEmpty && tempMod != null) {
            tempList.remove(tempMod);
          }
          if (appliedList.isEmpty) {
            emptyList.add(appliedList);
          }
        }
        for (var element in emptyList) {
          appliedModsList.remove(element);
          totalAppliedFiles -= element.length;
          totalAppliedItems--;
        }
      }
    } else {
      backupFilesMissingList.add(mod);
    }
  }

  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
}

// New File Adders
Future<void> dragDropSingleFilesAdd(context, List<XFile> newItemDragDropList, String? selectedCategoryName, String? newItemName) async {
  final categoryName = selectedCategoryName;
  final catePath = cateList.firstWhere((element) => element.categoryName == categoryName).categoryPath;

  for (var xFile in newItemDragDropList) {
    await Future(
      () {
        if (!Directory(xFile.path).existsSync()) {
          String newPath = catePath;
          final fileParent = File(xFile.path).parent.path.split('\\').last;
          if (newItemName != null) {
            //Item suffix
            if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
              newPath += '\\$newItemName [Ba]\\$fileParent\\${xFile.name}';
            } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
              newPath += '\\$newItemName [In]\\$fileParent\\${xFile.name}';
            } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
              newPath += '\\$newItemName [Ou]\\$fileParent\\${xFile.name}';
            } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
              newPath += '\\$newItemName [Se]\\$fileParent\\${xFile.name}';
            } else {
              newPath += '\\$newItemName\\$fileParent\\${xFile.name}';
            }
          }
          File(newPath).createSync(recursive: true);
          File(xFile.path).copySync(newPath);
        } else {
          final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
          if (files.isNotEmpty) {
            for (var file in files) {
              final fileTailPath = file.path.split('${xFile.name}\\').last.split('\\');
              String newPath = catePath;
              final fileParent = File(xFile.path).parent.path.split('\\').last;
              if (fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na') != -1) {
                fileTailPath.removeRange(fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na'), fileTailPath.indexOf(fileTailPath.last));
                String finalTailPath = fileTailPath.join('\\');
                if (newItemName != null) {
                  //Item suffix
                  if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                    newPath += '\\$newItemName [Ba]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                    newPath += '\\$newItemName [In]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                    newPath += '\\$newItemName [Ou]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                    newPath += '\\$newItemName [Se]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else {
                    newPath += '\\$newItemName\\$fileParent\\${xFile.name}\\$finalTailPath';
                  }
                }
              } else {
                String finalTailPath = fileTailPath.join('\\');
                if (newItemName != null) {
                  //Item suffix
                  if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                    newPath += '\\$newItemName [Ba]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                    newPath += '\\$newItemName [In]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                    newPath += '\\$newItemName [Ou]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                    newPath += '\\$newItemName [Se]\\$fileParent\\${xFile.name}\\$finalTailPath';
                  } else {
                    newPath += '\\$newItemName\\$fileParent\\${xFile.name}\\$finalTailPath';
                  }
                }
              }

              File(newPath).createSync(recursive: true);
              File(file.path).copySync(newPath);
            }
          }
        }
      },
    );
    Provider.of<stateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
  }

  String modName = '';
  String newItemPath = '';
  bool dubItemFound = false;
  if (newItemName != null) {
    if (categoryName == 'Basewears' && !newItemName.contains('[Ba]')) {
      modName = '$newItemName [Ba]';
    } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
      modName = '$newItemName [In]';
    } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
      modName = '$newItemName [Ou]';
    } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
      modName = '$newItemName [Se]';
    } else {
      modName = newItemName;
    }
    if (categoryName == 'Basewears' && !newItemName.contains('[Ba]')) {
      newItemPath = '$catePath\\$newItemName [Ba]';
    } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
      newItemPath = '$catePath\\$newItemName [In]';
    } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
      newItemPath = '$catePath\\$newItemName [Ou]';
    } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
      newItemPath = '$catePath\\$newItemName [Se]';
    } else {
      newItemPath = '$catePath\\$newItemName';
    }
  }

  //Add to list
  List<ModFile> newModList = [];
  final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
  int numOfMods = 0;
  String tempParentTracker = '';
  for (var file in filesList) {
    if (p.extension(file.path) == '') {
      final iceName = file.path.split('\\').last;
      String iceParents = file.path.split(modName).last.split('\\$iceName').first.replaceAll('\\', ' > ').trim();
      if (iceParents == '') {
        iceParents = '> $modName';
      }
      if (tempParentTracker == '' || tempParentTracker != iceParents) {
        tempParentTracker = iceParents;
        numOfMods++;
      }

      List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

      ModFile newModFile = ModFile('', newItemPath, modName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true, false, []);
      newModFile.categoryName = selectedCategoryName.toString();
      newModFile.categoryPath = catePath;
      newModList.add(newModFile);

      //Json Write
      allModFiles.add(newModFile);
      allModFiles.map((mod) => mod.toJson()).toList();
      File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
    }
  }

  //Update Cate list
  final newModRoot = Directory(newItemPath).listSync(recursive: false).whereType<File>();
  final thumbnails = newModRoot.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png').toList();
  if (thumbnails.isEmpty) {
    thumbnails.add(File('assets/img/placeholdersquare.png'));
  }
  final selectedCategory = cateList.firstWhere((element) => element.categoryName == categoryName);
  if (selectedCategory.itemNames.indexWhere((element) => element == modName) == -1) {
    dubItemFound = false;
    selectedCategory.itemNames.insert(0, modName);
  } else {
    dubItemFound = true;
  }

  if (!dubItemFound) {
    for (var cate in cateList) {
      if (cate.itemNames.indexWhere((e) => e == modName) != -1) {
        int index = 0;
        if (cate.itemNames.length > 1) {
          index = cate.itemNames.indexOf(newItemName.toString());
        }
        cate.allModFiles.addAll(newModList);
        cate.imageIcons.add(thumbnails);
        cate.numOfMods.add(0);
        cate.numOfMods[index] = numOfMods;
        cate.numOfItems++;
        cate.numOfApplied.add(0);
      }
    }
  }
}

//Add multiple
Future<void> dragDropFilesAdd(context, List<XFile> newItemDragDropList, String? selectedCategoryName, String? newItemName) async {
  final categoryName = selectedCategoryName;
  final catePath = cateList.firstWhere((element) => element.categoryName == categoryName).categoryPath;

  for (var xFile in newItemDragDropList) {
    await Future(
      () {
        final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
        if (files.isNotEmpty) {
          for (var file in files) {
            final fileTailPath = file.path.split('${xFile.name}\\').last.split('\\');
            String newPath = catePath;
            if (fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na') != -1) {
              fileTailPath.removeRange(fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na'), fileTailPath.indexOf(fileTailPath.last));
              String finalTailPath = fileTailPath.join('\\');
              if (newItemName == null) {
                //Item suffix
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '\\${xFile.name} [Ba]\\$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '\\${xFile.name} [In]\\$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '\\${xFile.name} [Ou]\\$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '\\${xFile.name} [Se]\\$finalTailPath';
                } else {
                  newPath += '\\${xFile.name}\\$finalTailPath';
                }
              } else {
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '\\$newItemName [Ba]\\$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '\\$newItemName [In]\\$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '\\$newItemName [Ou]\\$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '\\$newItemName [Se]\\$finalTailPath';
                } else {
                  newPath += '\\$newItemName\\$finalTailPath';
                }
              }
            } else {
              String finalTailPath = fileTailPath.join('\\');
              if (newItemName == null) {
                //Item suffix
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '\\${xFile.name} [Ba]\\$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '\\${xFile.name} [In]\\$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '\\${xFile.name} [Ou]\\$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '\\${xFile.name} [Se]\\$finalTailPath';
                } else {
                  newPath += '\\${xFile.name}\\$finalTailPath';
                }
              } else {
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '\\$newItemName [Ba]\\$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '\\$newItemName [In]\\$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '\\$newItemName [Ou]\\$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '\\$newItemName [Se]\\$finalTailPath';
                } else {
                  newPath += '\\$newItemName\\$finalTailPath';
                }
              }
            }

            File(newPath).createSync(recursive: true);
            File(file.path).copySync(newPath);
          }
        }

        String modName = '';
        String newItemPath = '';
        bool dubItemFound = false;
        if (newItemName == null) {
          if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
            modName = '${xFile.name} [Ba]';
          } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
            modName = '${xFile.name} [In]';
          } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
            modName = '${xFile.name} [Ou]';
          } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
            modName = '${xFile.name} [Se]';
          } else {
            modName = xFile.name;
          }
          if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
            newItemPath = '$catePath\\${xFile.name} [Ba]';
          } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
            newItemPath = '$catePath\\${xFile.name} [In]';
          } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
            newItemPath = '$catePath\\${xFile.name} [Ou]';
          } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
            newItemPath = '$catePath\\${xFile.name} [Se]';
          } else {
            newItemPath = '$catePath\\${xFile.name}';
          }
        } else {
          if (categoryName == 'Basewears' && !newItemName.contains('[Ba]')) {
            modName = '$newItemName [Ba]';
          } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
            modName = '$newItemName [In]';
          } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
            modName = '$newItemName [Ou]';
          } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
            modName = '$newItemName [Se]';
          } else {
            modName = newItemName;
          }
          if (categoryName == 'Basewears' && !newItemName.contains('[Ba]')) {
            newItemPath = '$catePath\\$newItemName [Ba]';
          } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
            newItemPath = '$catePath\\$newItemName [In]';
          } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
            newItemPath = '$catePath\\$newItemName [Ou]';
          } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
            newItemPath = '$catePath\\$newItemName [Se]';
          } else {
            newItemPath = '$catePath\\$newItemName';
          }
        }

        //Add to list
        List<ModFile> newModList = [];
        int numOfMods = 0;
        String tempParentTracker = '';
        final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
        for (var file in filesList) {
          if (p.extension(file.path) == '') {
            final iceName = file.path.split('\\').last;
            String iceParents = file.path.split(modName).last.split('\\$iceName').first.replaceAll('\\', ' > ').trim();
            if (iceParents == '') {
              iceParents = '> $modName';
            }
            if (tempParentTracker == '' || tempParentTracker != iceParents) {
              tempParentTracker = iceParents;
              numOfMods++;
            }

            List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

            List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

            ModFile newModFile = ModFile('', newItemPath, modName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true, false, vidList);
            newModFile.categoryName = selectedCategoryName.toString();
            newModFile.categoryPath = catePath;
            newModList.add(newModFile);

            //Json Write
            allModFiles.add(newModFile);
            allModFiles.map((mod) => mod.toJson()).toList();
            File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
          }
        }

        //Update Cate list
        final newModRoot = Directory(newItemPath).listSync(recursive: false).whereType<File>();
        final thumbnails = newModRoot.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png').toList();
        if (thumbnails.isEmpty) {
          thumbnails.add(File('assets/img/placeholdersquare.png'));
        }
        final selectedCategory = cateList.firstWhere((element) => element.categoryName == categoryName);
        if (selectedCategory.itemNames.indexWhere((element) => element == modName) == -1) {
          dubItemFound = false;
          selectedCategory.itemNames.insert(0, modName);
        } else {
          dubItemFound = true;
        }

        if (!dubItemFound) {
          for (var cate in cateList) {
            if (cate.itemNames.indexWhere((e) => e == modName) != -1) {
              int index = 0;
              if (cate.itemNames.length > 1) {
                index = cate.itemNames.indexOf(modName);
              }
              cate.allModFiles.addAll(newModList);
              //cate.allModFiles = [];
              cate.imageIcons.insert(0, thumbnails);
              cate.numOfMods.insert(0, 0);
              cate.numOfMods[index] = numOfMods;
              cate.numOfItems++;
              cate.numOfApplied.add(0);
            }
          }
        }
        Provider.of<stateProvider>(context, listen: false).itemsDropAddRemoveFirst();
        //print(xFile.name);
      },
    );
  }
}

// New Mod Adders
Future<void> dragDropModsAdd(context, List<XFile> newModDragDropList, String curItemName, String itemPath, int index, String? newItemName) async {
  for (var xFile in newModDragDropList) {
    await Future(
      () {
        if (!Directory(xFile.path).existsSync()) {
          String newPath = itemPath;
          final fileParent = File(xFile.path).parent.path.split('\\').last;
          if (newItemName != null) {
            //Item suffix
            newPath += '\\$newItemName\\${xFile.name}';
          }
          File(newPath).createSync(recursive: true);
          File(xFile.path).copySync(newPath);
        } else {
          final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
          final fileParent = File(xFile.path).parent.path.split('\\').last;
          if (files.isNotEmpty) {
            for (var file in files) {
              final fileTailPath = file.path.split('${xFile.name}\\').last.split('\\');
              String newPath = itemPath;
              if (fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na') != -1) {
                fileTailPath.removeRange(fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na'), fileTailPath.indexOf(fileTailPath.last));
                String finalTailPath = fileTailPath.join('\\');
                if (newItemName != null) {
                  newPath += '\\$newItemName\\${xFile.name}\\$finalTailPath';
                }
              } else {
                String finalTailPath = fileTailPath.join('\\');
                if (newItemName != null) {
                  newPath += '\\$newItemName\\${xFile.name}\\$finalTailPath';
                }
              }

              File(newPath).createSync(recursive: true);
              File(file.path).copySync(newPath);
            }
          }
        }
      },
    );
    Provider.of<stateProvider>(context, listen: false).modsDropAddRemoveFirst();
  }

  String newModPath = '$itemPath\\$newItemName';

  //Add to list
  List<ModFile> newMods = [];
  final matchedCategory = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
  final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
  List<String> parentsList = [];
  for (var file in filesList) {
    if (p.extension(file.path) == '') {
      final iceName = file.path.split('\\').last;
      final iceParents = file.path.split(curItemName).last.split('\\$iceName').first.replaceAll('\\', ' > ').trim();
      List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
      List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

      ModFile newModFile = ModFile('', newModPath, curItemName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true, false, vidList);
      newModFile.categoryName = matchedCategory.categoryName;
      newModFile.categoryPath = matchedCategory.categoryPath;
      newMods.add(newModFile);
      parentsList.add(newModFile.iceParent);

      //Json Write
      allModFiles.add(newModFile);
      allModFiles.map((mod) => mod.toJson()).toList();
      File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
    }
  }

  final parents = parentsList.toSet().toList();
  for (var parent in parents) {
    final sameParentMods = newMods.where((element) => element.iceParent == parent);
    modFilesList.add(sameParentMods.toList());
  }

  int index = 0;
  if (matchedCategory.itemNames.length > 1) {
    index = matchedCategory.itemNames.indexOf(curItemName);
  }

  isLoading.clear();
  matchedCategory.allModFiles.addAll(newMods);
  matchedCategory.numOfMods[index] += parents.length;
}

// New Mod Adders Folder Only
Future<void> dragDropModsAddFoldersOnly(context, List<XFile> newModDragDropList, String curItemName, String itemPath, int index, String? newItemName) async {
  for (var xFile in newModDragDropList) {
    await Future(
      () {
        final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
        if (files.isNotEmpty) {
          for (var file in files) {
            final fileTailPath = file.path.split('${xFile.name}\\').last.split('\\');
            String newPath = itemPath;
            if (fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na') != -1) {
              fileTailPath.removeRange(fileTailPath.indexWhere((e) => e == 'win32' || e == 'win32_na' || e == 'win32reboot' || e == 'win32reboot_na'), fileTailPath.indexOf(fileTailPath.last));
              String finalTailPath = fileTailPath.join('\\');
              if (newItemName == null) {
                newPath += '\\${xFile.name}\\$finalTailPath';
              }
            } else {
              String finalTailPath = fileTailPath.join('\\');
              if (newItemName == null) {
                newPath += '\\${xFile.name}\\$finalTailPath';
              }
            }

            File(newPath).createSync(recursive: true);
            File(file.path).copySync(newPath);
          }
        }

        String newModPath = '$itemPath\\${xFile.name}';

        //Add to list
        List<ModFile> newMods = [];
        final matchedCategory = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
        final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
        List<String> parentsList = [];
        for (var file in filesList) {
          if (p.extension(file.path) == '') {
            final iceName = file.path.split('\\').last;
            final iceParents = file.path.split(curItemName).last.split('\\$iceName').first.replaceAll('\\', ' > ').trim();
            List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
            List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

            ModFile newModFile = ModFile('', newModPath, curItemName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true, false, vidList);
            newModFile.categoryName = matchedCategory.categoryName;
            newModFile.categoryPath = matchedCategory.categoryPath;
            newMods.add(newModFile);
            parentsList.add(newModFile.iceParent);

            //Json Write
            allModFiles.add(newModFile);
            allModFiles.map((mod) => mod.toJson()).toList();
            File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
          }
        }

        final parents = parentsList.toSet().toList();
        for (var parent in parents) {
          final sameParentMods = newMods.where((element) => element.iceParent == parent);
          modFilesList.add(sameParentMods.toList());
        }

        int index = 0;
        if (matchedCategory.itemNames.length > 1) {
          index = matchedCategory.itemNames.indexOf(curItemName);
        }

        isLoading.clear();
        matchedCategory.allModFiles.addAll(newMods);
        matchedCategory.numOfMods[index] += parents.length;
      },
    );
    Provider.of<stateProvider>(context, listen: false).modsDropAddRemoveFirst();
  }
}

ModCategory addOrRemoveFav(List<ModCategory> categoryList, List<ModFile> paramModFileList, ModCategory paramFavCate, bool isAdding) {
  ModCategory tempFavCate = paramFavCate;
  var curCate = categoryList.singleWhere((element) => element.categoryName == paramModFileList.first.categoryName);
  if (isAdding) {
    for (var element in paramModFileList) {
      element.isFav = true;
      tempFavCate.allModFiles.add(element);
    }
    if (tempFavCate.itemNames.indexWhere((element) => element == paramModFileList.first.modName) == -1) {
      tempFavCate.itemNames.insert(0, paramModFileList.first.modName);
      tempFavCate.imageIcons.insert(0, curCate.imageIcons[curCate.itemNames.indexOf(paramModFileList.first.modName)]);
      tempFavCate.numOfMods.insert(0, 1);
      tempFavCate.numOfApplied.insert(0, curCate.numOfApplied[curCate.itemNames.indexOf(paramModFileList.first.modName)]);
      tempFavCate.numOfItems++;
    } else {
      tempFavCate.numOfMods[tempFavCate.itemNames.indexOf(paramModFileList.first.modName)] += 1;
      tempFavCate.numOfApplied[tempFavCate.itemNames.indexOf(paramModFileList.first.modName)] = curCate.numOfApplied[curCate.itemNames.indexOf(paramModFileList.first.modName)];
    }
  } else {
    for (var element in paramModFileList) {
      element.isFav = false;
      tempFavCate.allModFiles.remove(element);
    }
    if (isViewingFav) {
      modFilesList.remove(paramModFileList);
    }
    if (tempFavCate.allModFiles.indexWhere((element) => element.modName == paramModFileList.first.modName) == -1) {
      tempFavCate.imageIcons.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.numOfMods.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.numOfApplied.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.itemNames.remove(paramModFileList.first.modName);
      tempFavCate.numOfItems--;
    }
  }

  tempFavCate.itemNames.sort();
  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));

  return tempFavCate;
}
