import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:provider/provider.dart';

import 'main.dart';

import 'package:path/path.dart' as p;

Directory dataDir = Directory('$binDirPath${s}data');
List<File> iceFiles = [];

Future<void> reapplyMods(List<ModFile> modList) async {
  //Checksum
  if (checkSumFilePath != null) {
    File(checkSumFilePath!).copySync('$binDirPath${s}data${s}win32$s${checkSumFilePath!.split(s).last}');
  }

  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //Backup file check and apply
          final matchedFile = iceFiles.firstWhere(
            (e) => e.path.split(s).last == modFile.iceName,
            orElse: () {
              return File('');
            },
          );

          if (matchedFile.path != '') {
            modFile.originalIcePath = matchedFile.path;
            final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
              (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
              orElse: () {
                return File('');
              },
            );

            if (matchedBackup.path == '') {
              modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
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
        (e) => e.path.split(s).last == modFile.iceName,
        orElse: () {
          return File('');
        },
      );

      if (matchedFile.path != '') {
        modFile.originalIcePath = matchedFile.path;
        final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
          (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
          orElse: () {
            return File('');
          },
        );

        if (matchedBackup.path == '') {
          modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
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
    File(checkSumFilePath!).copySync('$binDirPath${s}data${s}win32$s${checkSumFilePath!.split(s).last}');
  }

  //Bulk apply
  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //Backup file check and apply
          final matchedFile = iceFiles.firstWhere(
            (e) => e.path.split(s).last == modFile.iceName,
            orElse: () {
              return File('');
            },
          );

          if (matchedFile.path != '') {
            modFile.originalIcePath = matchedFile.path;
            final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
              (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
              orElse: () {
                return File('');
              },
            );

            if (matchedBackup.path == '') {
              modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
              //Backup file if not already
              File(modFile.originalIcePath).copySync(modFile.backupIcePath);
            } else {
              //check for dub applied mod
              //set backup path to file
              modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';

              for (var file in allModFiles) {
                if (file.iceName == modFile.iceName && file.isApplied) {
                  duplicateModsApplied.add([file]);

                  // if (appliedModsList.isNotEmpty) {
                  //   // for (var appliedList in appliedModsList) {
                  //   //   //appliedList.remove(file);
                  //   // }

                  //   appliedModsList.removeWhere((element) => element.isEmpty);
                  //   appliedModsList.removeWhere((element) => element.every((file) => file.isApplied == false));
                  // }
                }
              }
            }

            //File actions
            File(modFile.icePath).copySync(modFile.originalIcePath);
            modFile.isApplied = true;
            modFile.isNew = false;
            actualAppliedMods.add(modFile);
            final curCate = cateList.firstWhere((element) => element.categoryName == modFile.categoryName && element.categoryPath == modFile.categoryPath);
            final curItemIndex = curCate.itemNames.indexOf(modFile.modName);
            curCate.numOfApplied[curItemIndex]++;
            if (modFile.isFav) {
              final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(modFile.modName);
              cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]++;
            }
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
        //File(element.backupIcePath).copySync(element.originalIcePath);
        element.isApplied = false;
      }
    }

    //Single apply
  } else {
    for (var modFile in modList) {
      //Backup file check and apply
      final matchedFile = iceFiles.firstWhere(
        (e) => e.path.split(s).last == modFile.iceName,
        orElse: () {
          return File('');
        },
      );

      if (matchedFile.path != '') {
        modFile.originalIcePath = matchedFile.path;
        final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
          (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
          orElse: () {
            return File('');
          },
        );

        if (matchedBackup.path == '') {
          modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
          //Backup file if not already
          File(modFile.originalIcePath).copySync(modFile.backupIcePath);
        } else {
          //check for dub applied mod
          //set backup path to file
          modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';

          for (var file in allModFiles) {
            if (file.iceName == modFile.iceName && file.isApplied) {
              duplicateModsApplied.add([file]);

              // if (appliedModsList.isNotEmpty) {
              //   for (var appliedList in appliedModsList) {
              //     //appliedList.remove(file);
              //     appliedList.firstWhere((element) => element.iceName == file.iceName).isApplied = false;
              //   }
              //   appliedModsList.removeWhere((element) => element.every((file) => file.isApplied == false));
              //   appliedModsList.removeWhere((element) => element.isEmpty);
              // }
            }
          }
        }

        //File actions
        File(modFile.icePath).copySync(modFile.originalIcePath);
        modFile.isApplied = true;
        modFile.isNew = false;
        actualAppliedMods.add(modFile);
        final curCate = cateList.firstWhere((element) => element.categoryName == modFile.categoryName && element.categoryPath == modFile.categoryPath);
        final curItemIndex = curCate.itemNames.indexOf(modFile.modName);
        curCate.numOfApplied[curItemIndex]++;
        if (modFile.isFav) {
          final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(modFile.modName);
          cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]++;
        }
      } else {
        originalFilesMissingList.add(modFile);
      }
    }
    //Unapply, restore old dub
    for (var modList in duplicateModsApplied) {
      for (var element in modList) {
        modAppliedDup.add(element);
        //File(element.backupIcePath).copySync(element.originalIcePath);
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
        if (tempMods.indexWhere((element) => element.iceName == mod.iceName) == -1) {
          tempMods.add(mod);
        }
      } else {
        mod.appliedDate = formattedDate;
        appliedModsList.insert(0, [mod]);
      }
    }
    appliedModsList.removeWhere((element) => element.every((file) => file.isApplied == false));
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
      (e) => p.extension(e.path) == '' && e.path.split(s).last == mod.iceName,
      orElse: () {
        return File('');
      },
    );

    if (matchedBackup.path != '') {
      File(mod.backupIcePath).copySync(mod.originalIcePath);
      mod.isApplied = false;
      actualRemovedMods.add(mod);
      final curCate = cateList.firstWhere((element) => element.categoryName == mod.categoryName && element.categoryPath == mod.categoryPath);
      final curItemIndex = curCate.itemNames.indexOf(mod.modName);
      curCate.numOfApplied[curItemIndex]--;
      if (mod.isFav) {
        final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(mod.modName);
        cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]--;
      }
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
          if (tempList.isNotEmpty && tempMod != null && tempMod.isApplied) {
            tempList.remove(tempMod);
          }
          if (appliedList.isEmpty || appliedList.indexWhere((element) => element.isApplied) == -1) {
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
Future<void> dragDropSingleFilesAdd(context, List<XFile> newItemDragDropList, XFile? itemIcon, String? selectedCategoryName, String? newItemName) async {
  final categoryName = selectedCategoryName;
  final catePath = cateList.firstWhere((element) => element.categoryName == categoryName).categoryPath;
  bool isFilesFound = false;
  for (var xFile in newItemDragDropList) {
    if (!Directory(xFile.path).existsSync()) {
      isFilesFound = true;
      break;
    }
  }

  if (!isFilesFound) {
    for (var xFile in newItemDragDropList) {
      await Future(
        () {
          final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
          if (files.isNotEmpty) {
            for (var file in files) {
              List<String> fileTailPath = file.path.split('${xFile.name}$s').last.split(s);
              if (xFile.name.contains('win32') || xFile.name.contains('win32_na') || xFile.name.contains('win32reboot') || xFile.name.contains('win32reboot_na')) {
                fileTailPath.insert(0, xFile.name);
              }
              String newPath = catePath;
              if (fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')) != -1) {
                fileTailPath.removeRange(fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')),
                    fileTailPath.indexOf(fileTailPath.last));

                String finalTailPath = fileTailPath.join(s);
                if (newItemName != null) {
                  //Item suffix
                  if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                    newPath += '$s$newItemName [Ba]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                    newPath += '$s$newItemName [In]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                    newPath += '$s$newItemName [Ou]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                    newPath += '$s$newItemName [Se]$s${xFile.name}$s$finalTailPath';
                  } else {
                    newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
                  }
                }
              } else {
                String finalTailPath = fileTailPath.join(s);
                if (newItemName != null) {
                  //Item suffix
                  if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                    newPath += '$s$newItemName [Ba]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                    newPath += '$s$newItemName [In]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                    newPath += '$s$newItemName [Ou]$s${xFile.name}$s$finalTailPath';
                  } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                    newPath += '$s$newItemName [Se]$s${xFile.name}$s$finalTailPath';
                  } else {
                    newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
                  }
                }
              }

              File(newPath).createSync(recursive: true);
              File(file.path).copySync(newPath);
            }
          }
        },
      );
      Provider.of<stateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
    }
  } else {
    for (var xFile in newItemDragDropList) {
      await Future(
        () {
          if (!Directory(xFile.path).existsSync()) {
            String newPath = catePath;
            if (newItemName != null) {
              //Item suffix
              if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                newPath += '$s$newItemName [Ba]${s}_$newItemName$s${xFile.name}';
              } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                newPath += '$s$newItemName [In]${s}_$newItemName$s${xFile.name}';
              } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                newPath += '$s$newItemName [Ou]${s}_$newItemName$s${xFile.name}';
              } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                newPath += '$s$newItemName [Se]${s}_$newItemName$s${xFile.name}';
              } else {
                newPath += '$s$newItemName${s}_$newItemName$s${xFile.name}';
              }
            }
            File(newPath).createSync(recursive: true);
            File(xFile.path).copySync(newPath);
          } else {
            final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
            if (files.isNotEmpty) {
              for (var file in files) {
                List<String> fileTailPath = file.path.split('${xFile.name}$s').last.split(s);
                if (xFile.name.contains('win32') || xFile.name.contains('win32_na') || xFile.name.contains('win32reboot') || xFile.name.contains('win32reboot_na')) {
                  fileTailPath.insert(0, xFile.name);
                }
                String newPath = catePath;
                if (fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')) != -1) {
                  fileTailPath.removeRange(fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')),
                      fileTailPath.indexOf(fileTailPath.last));
                  String finalTailPath = fileTailPath.join(s);
                  if (newItemName != null) {
                    //Item suffix
                    if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                      newPath += '$s$newItemName [Ba]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                      newPath += '$s$newItemName [In]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                      newPath += '$s$newItemName [Ou]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                      newPath += '$s$newItemName [Se]$s${xFile.name}$s$finalTailPath';
                    } else {
                      newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
                    }
                  }
                } else {
                  String finalTailPath = fileTailPath.join(s);
                  if (newItemName != null) {
                    //Item suffix
                    if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                      newPath += '$s$newItemName [Ba]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                      newPath += '$s$newItemName [In]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                      newPath += '$s$newItemName [Ou]$s${xFile.name}$s$finalTailPath';
                    } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                      newPath += '$s$newItemName [Se]$s${xFile.name}$s$finalTailPath';
                    } else {
                      newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
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
      newItemPath = '$catePath$s$newItemName [Ba]';
    } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
      newItemPath = '$catePath$s$newItemName [In]';
    } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
      newItemPath = '$catePath$s$newItemName [Ou]';
    } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
      newItemPath = '$catePath$s$newItemName [Se]';
    } else {
      newItemPath = '$catePath$s$newItemName';
    }
  }

  if (itemIcon != null) {
    File('$newItemPath$s${itemIcon.name}').createSync(recursive: true);
    File(itemIcon.path).copySync('$newItemPath$s${itemIcon.name}');
  }

  //Add to list
  List<ModFile> newModList = [];
  final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
  int numOfMods = 0;
  String tempParentTracker = '';
  for (var file in filesList) {
    if (p.extension(file.path) == '') {
      // final iceName = file.path.split(s).last;
      // String iceParents = file.path.split(modName).last.split('$s$iceName').first.replaceAll('$s', ' > ').trim();
      List<String> pathSplit = file.path.split(s);
      final iceName = pathSplit.removeLast();
      pathSplit.removeRange(0, pathSplit.indexWhere((element) => element == modName) + 1);
      String iceParents = pathSplit.join(' > ').trim();
      if (iceParents == '') {
        iceParents = modName;
      }
      if (tempParentTracker == '' || tempParentTracker != iceParents) {
        tempParentTracker = iceParents;
        numOfMods++;
      }

      List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
      List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

      if (imgList.isEmpty || vidList.isEmpty) {
        List<String> filePathSplit = file.path.split('$newItemPath$s').last.split(s);
        filePathSplit.insert(0, newItemName!);
        String fileName = filePathSplit.removeLast();
        String tempPath = file.path.split('$s$fileName').first;
        for (var folderPath in filePathSplit.reversed) {
          List<File> imgVidGet = Directory(tempPath)
              .listSync(recursive: false)
              .whereType<File>()
              .where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png' || p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm')
              .toList();
          if (imgVidGet.isNotEmpty) {
            for (var file in imgVidGet) {
              if ((p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') && imgList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                imgList.add(file);
              }
              if ((p.extension(file.path) == '.mp4' || p.extension(file.path) == '.webm') && vidList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                vidList.add(file);
              }
            }
          }
          tempPath = tempPath.split('$s$folderPath').first;
        }
      }

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
  Iterable<File> thumbnails = newModRoot.where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png');
  List<File> icons = [];
  if (thumbnails.isEmpty) {
    icons.add(File('assets/img/placeholdersquare.png'));
  } else {
    icons.addAll(thumbnails);
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
          index = cate.itemNames.indexOf(modName.toString());
        }
        cate.allModFiles.addAll(newModList);
        cate.imageIcons.insert(index, icons);
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
  final matchCate = cateList.firstWhere((element) => element.categoryName == categoryName);
  final catePath = matchCate.categoryPath;

  for (var xFile in newItemDragDropList) {
    await Future(
      () {
        final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
        String xFileName = xFile.name;
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MMddyyyy-HHmmss').format(now);
        if (selectedCategoryName == 'Basewears' || selectedCategoryName == 'Setwears' || selectedCategoryName == 'Outerwears' || selectedCategoryName == 'Innerwears') {
          if (matchCate.itemNames.indexWhere((element) => element.toLowerCase().substring(0, element.length - 4).trim() == xFile.name.toLowerCase()) != -1) {
            xFileName = '${xFileName}_$formattedDate';
          }
        } else {
          if (matchCate.itemNames.indexWhere((element) => element.toLowerCase() == xFile.name.toLowerCase()) != -1) {
            xFileName = '${xFileName}_$formattedDate';
          }
        }

        if (files.isNotEmpty) {
          for (var file in files) {
            List<String> fileTailPath = file.path.split('${xFile.name}$s').last.split(s);
            if (xFile.name.contains('win32') || xFile.name.contains('win32_na') || xFile.name.contains('win32reboot') || xFile.name.contains('win32reboot_na')) {
              fileTailPath.insert(0, xFile.name);
            }
            String newPath = catePath;
            if (fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')) != -1) {
              fileTailPath.removeRange(
                  fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')), fileTailPath.indexOf(fileTailPath.last));
              if (xFile.name == 'win32' || xFile.name == 'win32_na' || xFile.name == 'win32reboot' || xFile.name == 'win32reboot_na' || fileTailPath.length <= 1) {
                fileTailPath.insert(0, '_$xFileName');
              }

              String finalTailPath = fileTailPath.join(s);
              if (newItemName == null) {
                //Item suffix
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '$s$xFileName [Ba]$s$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '$s$xFileName [In]$s$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '$s$xFileName [Ou]$s$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '$s$xFileName [Se]$s$finalTailPath';
                } else {
                  newPath += '$s$xFileName$s$finalTailPath';
                }
              } else {
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '$s$newItemName [Ba]$s$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '$s$newItemName [In]$s$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '$s$newItemName [Ou]$s$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '$s$newItemName [Se]$s$finalTailPath';
                } else {
                  newPath += '$s$newItemName$s$finalTailPath';
                }
              }
            } else {
              if (fileTailPath.length < 2) {
                fileTailPath.insert(0, '_$xFileName');
              }
              String finalTailPath = fileTailPath.join(s);
              if (newItemName == null) {
                //Item suffix
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '$s$xFileName [Ba]$s$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '$s$xFileName [In]$s$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '$s$xFileName [Ou]$s$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '$s$xFileName [Se]$s$finalTailPath';
                } else {
                  newPath += '$s$xFileName$s$finalTailPath';
                }
              } else {
                if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
                  newPath += '$s$newItemName [Ba]$s$finalTailPath';
                } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
                  newPath += '$s$newItemName [In]$s$finalTailPath';
                } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
                  newPath += '$s$newItemName [Ou]$s$finalTailPath';
                } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
                  newPath += '$s$newItemName [Se]$s$finalTailPath';
                } else {
                  newPath += '$s$newItemName$s$finalTailPath';
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
            modName = '$xFileName [Ba]';
          } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
            modName = '$xFileName [In]';
          } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
            modName = '$xFileName [Ou]';
          } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
            modName = '$xFileName [Se]';
          } else {
            modName = xFileName;
          }
          if (categoryName == 'Basewears' && !xFile.name.contains('[Ba]')) {
            newItemPath = '$catePath$s$xFileName [Ba]';
          } else if (categoryName == 'Innerwears' && !xFile.name.contains('[In]')) {
            newItemPath = '$catePath$s$xFileName [In]';
          } else if (categoryName == 'Outerwears' && !xFile.name.contains('[Ou]')) {
            newItemPath = '$catePath$s$xFileName [Ou]';
          } else if (categoryName == 'Setwears' && !xFile.name.contains('[Se]')) {
            newItemPath = '$catePath$s$xFileName [Se]';
          } else {
            newItemPath = '$catePath$s$xFileName';
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
            newItemPath = '$catePath$s$newItemName [Ba]';
          } else if (categoryName == 'Innerwears' && !newItemName.contains('[In]')) {
            newItemPath = '$catePath$s$newItemName [In]';
          } else if (categoryName == 'Outerwears' && !newItemName.contains('[Ou]')) {
            newItemPath = '$catePath$s$newItemName [Ou]';
          } else if (categoryName == 'Setwears' && !newItemName.contains('[Se]')) {
            newItemPath = '$catePath$s$newItemName [Se]';
          } else {
            newItemPath = '$catePath$s$newItemName';
          }
        }

        //Add to list
        List<ModFile> newModList = [];
        int numOfMods = 0;
        String tempParentTracker = '';
        final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
        for (var file in filesList) {
          if (p.extension(file.path) == '') {
            List<String> pathSplit = file.path.split(s);
            final iceName = pathSplit.removeLast();
            pathSplit.removeRange(0, pathSplit.indexWhere((element) => element == modName) + 1);
            String iceParents = pathSplit.join(' > ').trim();
            if (iceParents == '') {
              iceParents = modName;
            }
            if (tempParentTracker == '' || tempParentTracker != iceParents) {
              tempParentTracker = iceParents;
              numOfMods++;
            }

            List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
            List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

            if (imgList.isEmpty || vidList.isEmpty) {
              List<String> filePathSplit = file.path.split('$newItemPath$s').last.split(s);
              if (filePathSplit.isNotEmpty) {
                filePathSplit.insert(0, xFileName);
                String fileName = filePathSplit.removeLast();
                String tempPath = file.path.split('$s$fileName').first;
                for (var folderPath in filePathSplit.reversed) {
                  List<File> imgVidGet = Directory(tempPath)
                      .listSync(recursive: false)
                      .whereType<File>()
                      .where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png' || p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm')
                      .toList();
                  if (imgVidGet.isNotEmpty) {
                    for (var file in imgVidGet) {
                      if ((p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') && imgList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                        imgList.add(file);
                      }
                      if ((p.extension(file.path) == '.mp4' || p.extension(file.path) == '.webm') && vidList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                        vidList.add(file);
                      }
                    }
                  }
                  tempPath = tempPath.split('$s$folderPath').first;
                }
              }
            }

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
              cate.imageIcons.insert(0, thumbnails);
              cate.numOfMods.insert(0, 0);
              cate.numOfMods[index] = numOfMods;
              cate.numOfItems++;
              cate.numOfApplied.add(0);
            }
          }
        }
        Provider.of<stateProvider>(context, listen: false).itemsDropAddRemoveFirst();
      },
    );
  }
}

// New Mod Adders
Future<void> dragDropModsAdd(context, List<XFile> newModDragDropList, String curCate, String curItemName, String itemPath, int index, String? newItemName) async {
  for (var xFile in newModDragDropList) {
    await Future(
      () {
        if (!Directory(xFile.path).existsSync()) {
          String newPath = itemPath;
          //final fileParent = File(xFile.path).parent.path.split(s).last;
          if (newItemName != null) {
            //Item suffix
            newPath += '$s$newItemName$s${xFile.name}';
          }
          File(newPath).createSync(recursive: true);
          File(xFile.path).copySync(newPath);
        } else {
          final files = Directory(xFile.path).listSync(recursive: true).whereType<File>();
          //final fileParent = File(xFile.path).parent.path.split(s).last;
          if (files.isNotEmpty) {
            for (var file in files) {
              List<String> fileTailPath = file.path.split('${xFile.name}$s').last.split(s);
              if (xFile.name.contains('win32') || xFile.name.contains('win32_na') || xFile.name.contains('win32reboot') || xFile.name.contains('win32reboot_na')) {
                fileTailPath.insert(0, xFile.name);
              }
              String newPath = itemPath;
              if (fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')) != -1) {
                fileTailPath.removeRange(fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')),
                    fileTailPath.indexOf(fileTailPath.last));
                String finalTailPath = fileTailPath.join(s);
                if (newItemName != null) {
                  newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
                }
              } else {
                String finalTailPath = fileTailPath.join(s);
                if (newItemName != null) {
                  newPath += '$s$newItemName$s${xFile.name}$s$finalTailPath';
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

  String newModPath = '$itemPath$s$newItemName';

  //Add to list
  List<ModFile> newMods = [];
  final matchedCategory = cateList.firstWhere((element) => element.categoryName == curCate);
  final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
  List<String> parentsList = [];
  for (var file in filesList) {
    if (p.extension(file.path) == '') {
      // final iceName = file.path.split(s).last;
      // final iceParents = file.path.split(curItemName).last.split('$s$iceName').first.replaceAll('$s', ' > ').trim();
      List<String> pathSplit = file.path.split(s);
      final iceName = pathSplit.removeLast();
      pathSplit.removeRange(0, pathSplit.indexWhere((element) => element == curItemName) + 1);
      String iceParents = pathSplit.join(' > ').trim();

      List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
      List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

      if (imgList.isEmpty || vidList.isEmpty) {
        List<String> filePathSplit = file.path.split('$newModPath$s').last.split(s);
        filePathSplit.insert(0, newItemName!);
        String fileName = filePathSplit.removeLast();
        String tempPath = file.path.split('$s$fileName').first;
        for (var folderPath in filePathSplit.reversed) {
          List<File> imgVidGet = Directory(tempPath)
              .listSync(recursive: false)
              .whereType<File>()
              .where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png' || p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm')
              .toList();
          if (imgVidGet.isNotEmpty) {
            for (var file in imgVidGet) {
              if ((p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') && imgList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                imgList.add(file);
              }
              if ((p.extension(file.path) == '.mp4' || p.extension(file.path) == '.webm') && vidList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                vidList.add(file);
              }
            }
          }
          tempPath = tempPath.split('$s$folderPath').first;
        }
      }

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
        final matchCate = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
        String xFileName = xFile.name;
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MMddyyyy-HHmmss').format(now);
        if (matchCate.itemNames.indexWhere((element) => element.toLowerCase() == curItemName.toLowerCase()) != -1 &&
            matchCate.allModFiles.indexWhere((element) => element.iceParent.toLowerCase().split(' > ').first == xFile.name.toLowerCase()) != -1) {
          xFileName = '${xFileName}_$formattedDate';
        }
        if (files.isNotEmpty) {
          for (var file in files) {
            List<String> fileTailPath = file.path.split('${xFile.name}$s').last.split(s);
            if (xFile.name.contains('win32') || xFile.name.contains('win32_na') || xFile.name.contains('win32reboot') || xFile.name.contains('win32reboot_na')) {
              fileTailPath.insert(0, xFile.name);
            }
            String newPath = itemPath;
            if (fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')) != -1) {
              fileTailPath.removeRange(
                  fileTailPath.indexWhere((e) => e.contains('win32') || e.contains('win32_na') || e.contains('win32reboot') || e.contains('win32reboot_na')), fileTailPath.indexOf(fileTailPath.last));
              String finalTailPath = fileTailPath.join(s);
              if (newItemName == null) {
                newPath += '$s$xFileName$s$finalTailPath';
              }
            } else {
              String finalTailPath = fileTailPath.join(s);
              if (newItemName == null) {
                newPath += '$s$xFileName$s$finalTailPath';
              }
            }

            File(newPath).createSync(recursive: true);
            File(file.path).copySync(newPath);
          }
        }

        String newModPath = '$itemPath$s$xFileName';

        //Add to list
        List<ModFile> newMods = [];
        final matchedCategory = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
        final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
        List<String> parentsList = [];
        for (var file in filesList) {
          if (p.extension(file.path) == '') {
            // final iceName = file.path.split(s).last;
            // final iceParents = file.path.split(curItemName).last.split('$s$iceName').first.replaceAll('$s', ' > ').trim();
            List<String> pathSplit = file.path.split(s);
            final iceName = pathSplit.removeLast();
            pathSplit.removeRange(0, pathSplit.indexWhere((element) => element == curItemName) + 1);
            String iceParents = pathSplit.join(' > ').trim();

            List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();
            List<File> vidList = filesList.where((e) => (p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm') && e.parent.path == file.parent.path).toList();

            if (imgList.isEmpty || vidList.isEmpty) {
              List<String> filePathSplit = file.path.split('$newModPath$s').last.split(s);
              if (newItemName != null) {
                filePathSplit.insert(0, newItemName);
              }
              String fileName = filePathSplit.removeLast();
              String tempPath = file.path.split('$s$fileName').first;
              for (var folderPath in filePathSplit.reversed) {
                List<File> imgVidGet = Directory(tempPath)
                    .listSync(recursive: false)
                    .whereType<File>()
                    .where((e) => p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png' || p.extension(e.path) == '.mp4' || p.extension(e.path) == '.webm')
                    .toList();
                if (imgVidGet.isNotEmpty) {
                  for (var file in imgVidGet) {
                    if ((p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') && imgList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                      imgList.add(file);
                    }
                    if ((p.extension(file.path) == '.mp4' || p.extension(file.path) == '.webm') && vidList.indexWhere((element) => element.path.split(s).last == file.path.split(s).last) == -1) {
                      vidList.add(file);
                    }
                  }
                }
                tempPath = tempPath.split('$s$folderPath').first;
              }
            }

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
