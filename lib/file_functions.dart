import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mods_loader.dart';

import 'main.dart';

import 'package:path/path.dart' as p;

Directory dataDir = Directory('$binDirPath\\data');

void modsToDataAdder(List<ModFile> modList) async {
  final iceFiles = dataDir.listSync(recursive: true).whereType<File>();
  List<List<ModFile>> duplicateModsApplied = [];
  List<ModFile> actualAppliedMods = [];
  originalFilesMissingList.clear();
  //Checksum
  if (checkSumFilePath != null) {
    File(checkSumFilePath!).copySync('$binDirPath\\data\\win32\\${checkSumFilePath!.split('\\').last}');
  }

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

      final backupFiles = Directory(backupDirPath).listSync(recursive: true).whereType<File>();
      final matchedBackup = backupFiles.firstWhere(
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
        modFile.backupIcePath = '$backupDirPath\\${modFile.iceName}';
        for (var modList in modFilesList) {
          List<ModFile> tempList = [];
          for (var mod in modList) {
            if (mod.iceName == modFile.iceName && mod.isApplied == true) {
              tempList.add(mod);

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
                }
              }
            }
          }
          duplicateModsApplied.add(tempList);
        }

        for (var element in duplicateModsApplied) {
          for (var e in element) {
            print(e.iceName);
          }
        }

        for (var modList in duplicateModsApplied) {
          for (var element in modList) {
            modAppliedDup.add(element);
            File(element.backupIcePath).copySync(element.originalIcePath);
            element.isApplied = false;
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

    //Applied mods list add
    for (var mod in actualAppliedMods) {
      if (appliedModsList.isNotEmpty) {
        List<ModFile> tempList = [];
        ModFile? tempMod;
        for (var modList in appliedModsList) {
          tempList = modList;
          for (var appliedMod in modList) {
            if (appliedMod.iceParent == mod.iceParent) {
              tempMod = mod;
            }
          }
        }
        if (tempMod != null && tempList.isNotEmpty && tempMod.iceParent == mod.iceParent) {
          tempList.add(tempMod);
        } else {
          appliedModsList.add(actualAppliedMods);
        }
      } else {
        appliedModsList.add(actualAppliedMods);
      }
    }
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
void dragDropFilesAdd(List<XFile> newItemDragDropList, String? selectedCategoryName, String? newItemName) {
  final categoryName = selectedCategoryName;
  final catePath = cateList.firstWhere((element) => element.categoryName == categoryName).categoryPath;

  for (var xFile in newItemDragDropList) {
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
            if (categoryName == 'Basewears') {
              newPath += '\\${xFile.name} [Ba]\\$finalTailPath';
            } else if (categoryName == 'Innerwears') {
              newPath += '\\${xFile.name} [In]\\$finalTailPath';
            } else if (categoryName == 'Outerwears') {
              newPath += '\\${xFile.name} [Ou]\\$finalTailPath';
            } else if (categoryName == 'Setwears') {
              newPath += '\\${xFile.name} [Se]\\$finalTailPath';
            } else {
              newPath += '\\${xFile.name}\\$finalTailPath';
            }
          } else {
            if (categoryName == 'Basewears') {
              newPath += '\\$newItemName [Ba]\\$finalTailPath';
            } else if (categoryName == 'Innerwears') {
              newPath += '\\$newItemName [In]\\$finalTailPath';
            } else if (categoryName == 'Outerwears') {
              newPath += '\\$newItemName [Ou]\\$finalTailPath';
            } else if (categoryName == 'Setwears') {
              newPath += '\\$newItemName [Se]\\$finalTailPath';
            } else {
              newPath += '\\$newItemName\\$finalTailPath';
            }
          }
        } else {
          String finalTailPath = fileTailPath.join('\\');
          if (newItemName == null) {
            //Item suffix
            if (categoryName == 'Basewears') {
              newPath += '\\${xFile.name} [Ba]\\$finalTailPath';
            } else if (categoryName == 'Innerwears') {
              newPath += '\\${xFile.name} [In]\\$finalTailPath';
            } else if (categoryName == 'Outerwears') {
              newPath += '\\${xFile.name} [Ou]\\$finalTailPath';
            } else if (categoryName == 'Setwears') {
              newPath += '\\${xFile.name} [Se]\\$finalTailPath';
            } else {
              newPath += '\\${xFile.name}\\$finalTailPath';
            }
          } else {
            if (categoryName == 'Basewears') {
              newPath += '\\$newItemName [Ba]\\$finalTailPath';
            } else if (categoryName == 'Innerwears') {
              newPath += '\\$newItemName [In]\\$finalTailPath';
            } else if (categoryName == 'Outerwears') {
              newPath += '\\$newItemName [Ou]\\$finalTailPath';
            } else if (categoryName == 'Setwears') {
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
      if (categoryName == 'Basewears') {
        modName = '${xFile.name} [Ba]';
      } else if (categoryName == 'Innerwears') {
        modName = '${xFile.name} [In]';
      } else if (categoryName == 'Outerwears') {
        modName = '${xFile.name} [Ou]';
      } else if (categoryName == 'Setwears') {
        modName = '${xFile.name} [Se]';
      } else {
        modName = xFile.name;
      }
      if (categoryName == 'Basewears') {
        newItemPath = '$catePath\\${xFile.name} [Ba]';
      } else if (categoryName == 'Innerwears') {
        newItemPath = '$catePath\\${xFile.name} [In]';
      } else if (categoryName == 'Outerwears') {
        newItemPath = '$catePath\\${xFile.name} [Ou]';
      } else if (categoryName == 'Setwears') {
        newItemPath = '$catePath\\${xFile.name} [Se]';
      } else {
        newItemPath = '$catePath\\${xFile.name}';
      }
    } else {
      if (categoryName == 'Basewears') {
        modName = '$newItemName [Ba]';
      } else if (categoryName == 'Innerwears') {
        modName = '$newItemName [In]';
      } else if (categoryName == 'Outerwears') {
        modName = '$newItemName [Ou]';
      } else if (categoryName == 'Setwears') {
        modName = '$newItemName [Se]';
      } else {
        modName = xFile.name;
      }
      if (categoryName == 'Basewears') {
        newItemPath = '$catePath\\$newItemName [Ba]';
      } else if (categoryName == 'Innerwears') {
        newItemPath = '$catePath\\$newItemName [In]';
      } else if (categoryName == 'Outerwears') {
        newItemPath = '$catePath\\$newItemName [Ou]';
      } else if (categoryName == 'Setwears') {
        newItemPath = '$catePath\\$newItemName [Se]';
      } else {
        newItemPath = '$catePath\\$newItemName';
      }
    }

    //Add to list
    List<ModFile> newModList = [];
    final filesList = Directory(newItemPath).listSync(recursive: true).whereType<File>();
    for (var file in filesList) {
      if (p.extension(file.path) == '') {
        final iceName = file.path.split('\\').last;
        String iceParents = file.path.split(modName).last.split('\\$iceName').first.replaceAll('\\', ' > ');
        if (iceParents == '') {
          iceParents = '> $modName';
        }

        List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

        ModFile newModFile = ModFile(0, newItemPath, modName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true);
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
      thumbnails.add(File('assets/img/placeholdersquare.jpg'));
    }
    final selectedCategory = cateList.firstWhere((element) => element.categoryName == categoryName);
    if (selectedCategory.itemNames.indexWhere((element) => element == modName) == -1) {
      dubItemFound = false;
      selectedCategory.itemNames.add(modName);
    } else {
      dubItemFound = true;
    }

    if (!dubItemFound) {
      for (var cate in cateList) {
        if (cate.itemNames.indexWhere((e) => e == modName) != -1) {
          cate.allModFiles.addAll(newModList);
          //cate.allModFiles = [];
          cate.imageIcons.add(thumbnails);
          cate.numOfMods.add(newModList.length);
          cate.numOfItems++;
          cate.numOfApplied.add(0);
        }
      }
    }
  }
}

// New Mod Adders
void dragDropModsAdd(List<XFile> newModDragDropList, String curItemName, String itemPath, int index, String? newItemName) {
  for (var xFile in newModDragDropList) {
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
          } else {
            newPath += '\\$newItemName\\$finalTailPath';
          }
        } else {
          String finalTailPath = fileTailPath.join('\\');
          if (newItemName == null) {
            newPath += '\\${xFile.name}\\$finalTailPath';
          } else {
            newPath += '\\$newItemName\\$finalTailPath';
          }
        }

        File(newPath).createSync(recursive: true);
        File(file.path).copySync(newPath);
      }
    }

    String newModPath = '';
    if (newItemName == null) {
      newModPath = '$itemPath\\${xFile.name}';
    } else {
      newModPath = '$itemPath\\$newItemName';
    }

    //Add to list
    List<ModFile> newMods = [];
    final matchedCategory = cateList.firstWhere((element) => element.itemNames.indexWhere((e) => e == curItemName) != -1);
    final filesList = Directory(newModPath).listSync(recursive: true).whereType<File>();
    List<String> parentsList = [];
    for (var file in filesList) {
      if (p.extension(file.path) == '') {
        final iceName = file.path.split('\\').last;
        final iceParents = file.path.split(curItemName).last.split('\\$iceName').first.replaceAll('\\', ' > ');
        List<File> imgList = filesList.where((e) => (p.extension(e.path) == '.jpg' || p.extension(e.path) == '.png') && e.parent.path == file.parent.path).toList();

        ModFile newModFile = ModFile(0, newModPath, curItemName, file.path, iceName, iceParents, '', '', getImagesList(imgList), false, true, true);
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

    matchedCategory.allModFiles.addAll(newMods);
    matchedCategory.numOfMods.add(newMods.length);
  }
}
