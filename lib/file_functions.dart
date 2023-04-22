import 'dart:convert';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:provider/provider.dart';

import 'main.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<void> reapplyMods(List<ModFile> modList) async {
  //Checksum
  if (checkSumFilePath != null && localChecksumMD5 != await getFileHash(win32CheckSumFilePath)) {
    File(checkSumFilePath!).copySync(win32CheckSumFilePath);
  }

  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //   //Backup file check and apply
          //   final matchedFile = iceFiles.firstWhere(
          //     (e) => e.path.split(s).last == modFile.iceName,
          //     orElse: () {
          //       return File('');
          //     },
          //   );

          //   if (matchedFile.path != '') {
          //     modFile.originalIcePath = matchedFile.path;
          //     final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
          //       (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
          //       orElse: () {
          //         return File('');
          //       },
          //     );

          //     if (matchedBackup.path == '') {
          //       modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
          //       //Backup file if not already
          //       File(modFile.originalIcePath).copySync(modFile.backupIcePath);
          //     }

          //     //File actions
          //     File(modFile.icePath).copySync(modFile.originalIcePath);
          //   } else {
          //     originalFilesMissingList.add(modFile);
          //   }
          // },

          //Backup file check and apply
          final matchedFiles = iceFiles.where((e) => e.path.split(s).last == modFile.iceName);

          if (matchedFiles.length == 1) {
            modFile.originalIcePath = matchedFiles.first.path;
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
            }

            //File actions
            File(modFile.icePath).copySync(modFile.originalIcePath);
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
            modFile.appliedDate = formattedDate;
            modFile.isApplied = true;
            modFile.isNew = false;
            final curCate = cateList.firstWhere((element) => element.categoryName == modFile.categoryName && element.categoryPath == modFile.categoryPath);
            final curItemIndex = curCate.itemNames.indexOf(modFile.modName);
            curCate.numOfApplied[curItemIndex]++;
            if (modFile.isFav) {
              final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(modFile.modName);
              cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]++;
            }
            //More than 1 og file
          } else if (matchedFiles.length > 1) {
            List<String> oriFilePaths = [];
            List<String> backupFilePaths = [];

            for (var file in matchedFiles) {
              oriFilePaths.add(file.path);
              if (file.path.split(s).indexWhere((element) => element == 'win32' || element == 'win32reboot') != -1) {
                backupFilePaths.add('$backupDirPath$s${modFile.iceName}');
              } else if (file.path.split(s).indexWhere((element) => element == 'win32_na') != -1) {
                backupFilePaths.add('$backupDirPath${s}win32_na$s${modFile.iceName}');
              } else if (file.path.split(s).indexWhere((element) => element == 'win32reboot_na') != -1) {
                backupFilePaths.add('$backupDirPath${s}win32reboot_na$s${modFile.iceName}');
              }
            }

            if (oriFilePaths.isNotEmpty) {
              modFile.originalIcePath = oriFilePaths.join(' | ');

              final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName);

              if (matchedBackup.isEmpty) {
                for (int i = 0; i < oriFilePaths.length; i++) {
                  File(oriFilePaths[i]).copySync(backupFilePaths[i]);
                }
                modFile.backupIcePath = backupFilePaths.join(' | ');
              }

              //File actions
              for (var oriPath in oriFilePaths) {
                File(modFile.icePath).copySync(oriPath);
              }
              DateTime now = DateTime.now();
              String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
              modFile.appliedDate = formattedDate;
              modFile.isApplied = true;
              modFile.isNew = false;
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
        },
      );
    }
  } else {
    for (var modFile in modList) {
      //Backup file check and apply
      final matchedFiles = iceFiles.where((e) => e.path.split(s).last == modFile.iceName);

      if (matchedFiles.length == 1) {
        modFile.originalIcePath = matchedFiles.first.path;
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
        }

        //File actions
        File(modFile.icePath).copySync(modFile.originalIcePath);
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
        modFile.appliedDate = formattedDate;
        modFile.isApplied = true;
        modFile.isNew = false;
        final curCate = cateList.firstWhere((element) => element.categoryName == modFile.categoryName && element.categoryPath == modFile.categoryPath);
        final curItemIndex = curCate.itemNames.indexOf(modFile.modName);
        curCate.numOfApplied[curItemIndex]++;
        if (modFile.isFav) {
          final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(modFile.modName);
          cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]++;
        }
        //More than 1 og file
      } else if (matchedFiles.length > 1) {
        List<String> oriFilePaths = [];
        List<String> backupFilePaths = [];

        for (var file in matchedFiles) {
          oriFilePaths.add(file.path);
          if (file.path.split(s).indexWhere((element) => element == 'win32' || element == 'win32reboot') != -1) {
            backupFilePaths.add('$backupDirPath$s${modFile.iceName}');
          } else if (file.path.split(s).indexWhere((element) => element == 'win32_na') != -1) {
            backupFilePaths.add('$backupDirPath${s}win32_na$s${modFile.iceName}');
          } else if (file.path.split(s).indexWhere((element) => element == 'win32reboot_na') != -1) {
            backupFilePaths.add('$backupDirPath${s}win32reboot_na$s${modFile.iceName}');
          }
        }

        if (oriFilePaths.isNotEmpty) {
          modFile.originalIcePath = oriFilePaths.join(' | ');

          final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName);

          if (matchedBackup.isEmpty) {
            for (int i = 0; i < oriFilePaths.length; i++) {
              File(oriFilePaths[i]).copySync(backupFilePaths[i]);
            }
            modFile.backupIcePath = backupFilePaths.join(' | ');
          }

          //File actions
          for (var oriPath in oriFilePaths) {
            File(modFile.icePath).copySync(oriPath);
          }
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
          modFile.appliedDate = formattedDate;
          modFile.isApplied = true;
          modFile.isNew = false;
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
  if (checkSumFilePath != null && localChecksumMD5 != await getFileHash(win32CheckSumFilePath)) {
    File(checkSumFilePath!).copySync(win32CheckSumFilePath);
  }

  //Bulk apply
  if (modList.length > 1) {
    for (var modFile in modList) {
      await Future(
        () {
          //Backup file check and apply
          final matchedFiles = iceFiles.where((e) => e.path.split(s).last == modFile.iceName);

          if (matchedFiles.length == 1) {
            modFile.originalIcePath = matchedFiles.first.path;
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
                }
              }
            }

            //File actions
            File(modFile.icePath).copySync(modFile.originalIcePath);
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
            modFile.appliedDate = formattedDate;
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
            //More than 1 og file
          } else if (matchedFiles.length > 1) {
            List<String> oriFilePaths = [];
            List<String> backupFilePaths = [];

            for (var file in matchedFiles) {
              oriFilePaths.add(file.path);
              if (file.path.split(s).indexWhere((element) => element == 'win32' || element == 'win32reboot') != -1) {
                backupFilePaths.add('$backupDirPath$s${modFile.iceName}');
              } else if (file.path.split(s).indexWhere((element) => element == 'win32_na') != -1) {
                backupFilePaths.add('$backupDirPath${s}win32_na$s${modFile.iceName}');
              } else if (file.path.split(s).indexWhere((element) => element == 'win32reboot_na') != -1) {
                backupFilePaths.add('$backupDirPath${s}win32reboot_na$s${modFile.iceName}');
              }
            }

            if (oriFilePaths.isNotEmpty) {
              modFile.originalIcePath = oriFilePaths.join(' | ');

              final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName);

              if (matchedBackup.isEmpty) {
                for (int i = 0; i < oriFilePaths.length; i++) {
                  File(oriFilePaths[i]).copySync(backupFilePaths[i]);
                }
                modFile.backupIcePath = backupFilePaths.join(' | ');
              } else {
                for (var file in allModFiles) {
                  if (file.iceName == modFile.iceName && file.isApplied) {
                    duplicateModsApplied.add([file]);
                  }
                }
              }

              //File actions
              for (var oriPath in oriFilePaths) {
                File(modFile.icePath).copySync(oriPath);
              }
              DateTime now = DateTime.now();
              String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
              modFile.appliedDate = formattedDate;
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
      final matchedFiles = iceFiles.where((e) => e.path.split(s).last == modFile.iceName);

      if (matchedFiles.length == 1) {
        modFile.originalIcePath = matchedFiles.first.path;
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
            }
          }
        }

        //File actions
        File(modFile.icePath).copySync(modFile.originalIcePath);
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
        modFile.appliedDate = formattedDate;
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
        //More than 1 og file
      } else if (matchedFiles.length > 1) {
        List<String> oriFilePaths = [];
        List<String> backupFilePaths = [];

        for (var file in matchedFiles) {
          oriFilePaths.add(file.path);
          if (file.path.split(s).indexWhere((element) => element == 'win32' || element == 'win32reboot') != -1) {
            backupFilePaths.add('$backupDirPath$s${modFile.iceName}');
          } else if (file.path.split(s).indexWhere((element) => element == 'win32_na') != -1) {
            backupFilePaths.add('$backupDirPath${s}win32_na$s${modFile.iceName}');
          } else if (file.path.split(s).indexWhere((element) => element == 'win32reboot_na') != -1) {
            backupFilePaths.add('$backupDirPath${s}win32reboot_na$s${modFile.iceName}');
          }
        }

        if (oriFilePaths.isNotEmpty) {
          modFile.originalIcePath = oriFilePaths.join(' | ');

          final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().where((e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName);

          if (matchedBackup.isEmpty) {
            for (int i = 0; i < oriFilePaths.length; i++) {
              File(oriFilePaths[i]).copySync(backupFilePaths[i]);
            }
            modFile.backupIcePath = backupFilePaths.join(' | ');
          } else {
            for (var file in allModFiles) {
              if (file.iceName == modFile.iceName && file.isApplied) {
                duplicateModsApplied.add([file]);
              }
            }
          }

          //File actions
          for (var oriPath in oriFilePaths) {
            File(modFile.icePath).copySync(oriPath);
          }
          DateTime now = DateTime.now();
          String formattedDate = DateFormat('MM-dd-yyyy HH:mm:ss').format(now);
          modFile.appliedDate = formattedDate;
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

      // final matchedFile = iceFiles.firstWhere(
      //   (e) => e.path.split(s).last == modFile.iceName,
      //   orElse: () {
      //     return File('');
      //   },
      // );

      // if (matchedFile.path != '') {
      //   modFile.originalIcePath = matchedFile.path;
      //   final matchedBackup = Directory(backupDirPath).listSync(recursive: true).whereType<File>().firstWhere(
      //     (e) => p.extension(e.path) == '' && e.path.split(s).last == modFile.iceName,
      //     orElse: () {
      //       return File('');
      //     },
      //   );

      //   if (matchedBackup.path == '') {
      //     modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';
      //     //Backup file if not already
      //     File(modFile.originalIcePath).copySync(modFile.backupIcePath);
      //   } else {
      //     //check for dub applied mod
      //     //set backup path to file
      //     modFile.backupIcePath = '$backupDirPath$s${modFile.iceName}';

      //     for (var file in allModFiles) {
      //       if (file.iceName == modFile.iceName && file.isApplied) {
      //         duplicateModsApplied.add([file]);

      //         // if (appliedModsList.isNotEmpty) {
      //         //   for (var appliedList in appliedModsList) {
      //         //     //appliedList.remove(file);
      //         //     appliedList.firstWhere((element) => element.iceName == file.iceName).isApplied = false;
      //         //   }
      //         //   appliedModsList.removeWhere((element) => element.every((file) => file.isApplied == false));
      //         //   appliedModsList.removeWhere((element) => element.isEmpty);
      //         // }
      //       }
      //     }
      //   }

      //   //File actions
      //   File(modFile.icePath).copySync(modFile.originalIcePath);
      //   modFile.isApplied = true;
      //   modFile.isNew = false;
      //   actualAppliedMods.add(modFile);
      //   final curCate = cateList.firstWhere((element) => element.categoryName == modFile.categoryName && element.categoryPath == modFile.categoryPath);
      //   final curItemIndex = curCate.itemNames.indexOf(modFile.modName);
      //   curCate.numOfApplied[curItemIndex]++;
      //   if (modFile.isFav) {
      //     final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(modFile.modName);
      //     cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]++;
      //   }
      // } else {
      //   originalFilesMissingList.add(modFile);
      // }
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
    final matchedBackup = backupFiles.where((e) => p.extension(e.path) == '' && e.path.split(s).last == mod.iceName);
    List<String> backupPaths = mod.backupIcePath.split(' | ');
    List<String> oriPaths = mod.originalIcePath.split(' | ');

    if (matchedBackup.isNotEmpty) {
      for (int i = 0; i < backupPaths.length; i++) {
        if (File(backupPaths[i]).existsSync()) {
          File(backupPaths[i]).copySync(oriPaths[i]);
          File(backupPaths[i]).deleteSync();
        } else {
          backupFilesMissingList.add(mod);
        }
      }

      mod.isApplied = false;
      actualRemovedMods.add(mod);
      final curCate = cateList.firstWhere((element) => element.categoryName == mod.categoryName && element.categoryPath == mod.categoryPath);
      final curItemIndex = curCate.itemNames.indexOf(mod.modName);
      curCate.numOfApplied[curItemIndex]--;
      if (mod.isFav) {
        final favIndex = cateList.firstWhere((element) => element.categoryName == 'Favorites').itemNames.indexOf(mod.modName);
        cateList.firstWhere((element) => element.categoryName == 'Favorites').numOfApplied[favIndex]--;
      }

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

//Auto Files adder
Future<void> modFilesAdder(context, List<List<String>> sortedList, XFile itemIcon) async {
  //List<List<String>> addedItems = [];
  for (var sortedLine in sortedList) {
    if (sortedLine[4].isNotEmpty) {
      List<String> addedIceFiles = [];
      List<String> addedImgs = [];
      List<String> addedVids = [];
      //Get mods info
      String category = sortedLine[0];
      String itemName = '';
      if (curActiveLang == 'JP') {
        itemName = sortedLine[1];
      } else {
        itemName = sortedLine[2];
      }

      List<String> subNames = [];
      if (sortedLine[5].isNotEmpty) {
        for (var name in sortedLine[5].split('|')) {
          if (name.isNotEmpty) {
            subNames.add(name.split(':')[1]);
          }
        }
      }

      //List<String> fileInfos = [];
      // if (sortedLine[5].isNotEmpty) {
      //   List<String> mainNames = sortedLine[4].split('|');
      //   List<String> mainSubNames = sortedLine[5].split('|');
      //   for (var name in sortedLine[6].split('|')) {
      //     if (mainSubNames.indexWhere((element) => element.split(':').first == name.split(':').first) != -1 &&
      //         mainSubNames.indexWhere((element) => element.split(':')[1] == name.split(':')[1]) != -1) {
      //       fileInfos.add(name);
      //     }
      //   }
      // } else {
      // for (var name in sortedLine[6].split('|')) {
      //   fileInfos.add(name);
      // }
      //}

      List<String> fileInfos = sortedLine[6].split('|');

      List<String> modFolders = [];
      for (var fileInfo in fileInfos) {
        List<String> temp = fileInfo.split(':');
        modFolders.add('${temp.first}:${temp[1]}');
      }
      final finalModFolders = modFolders.toSet();

      String newItemPath = '$modsDirPath$s$category$s$itemName';

      //Copy icon image to main item dir
      if (sortedLine[3].isNotEmpty && p.extension(sortedLine[3]) == '.png' && !File('$newItemPath$s$itemName.png').existsSync()) {
        Directory(newItemPath).createSync(recursive: true);
        File(sortedLine[3]).copySync('$newItemPath$s$itemName.png');
      }

      //Create folders inside Mods folder
      for (var field in fileInfos) {
        Uri newFilePath = Uri();
        String curMainName = field.split(':')[0];
        String curSubName = field.split(':')[1];
        String curFile = field.split(':')[2];
        if (subNames.isEmpty) {
          Directory(Uri.directory('$modManDirPath$category/$itemName/$curMainName').toFilePath()).createSync(recursive: true);
          File(Uri.file('$modManAddModsTempDirPath/$curMainName/$curFile').toFilePath()).copySync(Uri.file('$modsDirPath/$category/$itemName/$curMainName/$curFile').toFilePath());
          newFilePath = Uri.file('$modsDirPath/$category/$itemName/$curMainName/$curFile');
        } else {
          Directory(Uri.directory('$modsDirPath/$category/$itemName/$curMainName/$curSubName').toFilePath()).createSync(recursive: true);
          File(Uri.file('$modManAddModsTempDirPath/$curMainName/$curSubName/$curFile').toFilePath()).copySync(Uri.file('$modsDirPath/$category/$itemName/$curMainName/$curSubName/$curFile').toFilePath());
          newFilePath = Uri.file('$modsDirPath/$category/$itemName/$curMainName/$curSubName/$curFile');
        }

        //Add sorted files to lists
        if (p.extension(newFilePath.toFilePath()) == '') {
          addedIceFiles.add(field);
        } else if ((p.extension(newFilePath.toFilePath()) == '.jpg' || p.extension(newFilePath.toFilePath()) == '.png')) {
          addedImgs.add(field);
        } else if ((p.extension(newFilePath.toFilePath()) == '.mp4' || p.extension(newFilePath.toFilePath()) == '.webm')) {
          addedVids.add(field);
        }
      }

      //Create mod files
      List<ModFile> newModFiles = [];

      for (var ice in addedIceFiles) {
        String curIceMainName = ice.split(':')[0];
        String curIceSubName = ice.split(':')[1];
        String curFile = ice.split(':')[2];
        String newDirPath = '';
        if (subNames.isEmpty) {
          newDirPath = '$modsDirPath$s$category$s$itemName$s$curIceMainName';
        } else {
          newDirPath = '$modsDirPath$s$category$s$itemName$s$curIceMainName$s$curIceSubName';
        }
        List<String> curImgs = addedImgs.where((element) => element.split(':')[0] == curIceMainName && element.split(':')[1] == curIceSubName).toList();
        List<String> curVids = addedVids.where((element) => element.split(':')[0] == curIceMainName && element.split(':')[1] == curIceSubName).toList();
        List<File> imgFiles = [];
        for (var element in curImgs) {
          String imgName = element.split(':')[2];
          imgFiles.add(File('$newDirPath$s$imgName'));
        }
        List<File> vidFiles = [];
        for (var element in curVids) {
          String vidName = element.split(':')[2];
          vidFiles.add(File('$newDirPath$s$vidName'));
        }
        //Get parent for list and icepath
        String iceFileParents = '';
        String iceFileParentPath = newItemPath;
        if (curIceSubName.isEmpty) {
          iceFileParents = curIceMainName;
          iceFileParentPath += '$s$curIceMainName';
        } else {
          iceFileParents = '$curIceMainName > $curIceSubName';
          iceFileParentPath += '$s$curIceMainName$s$curIceSubName';
        }

        ModFile curModFile =
            ModFile('', '$modsDirPath$s$category$s$itemName', itemName, '$iceFileParentPath$s$curFile', curFile, iceFileParents, '', '', getImagesList(imgFiles), false, true, true, false, vidFiles);
        curModFile.categoryName = category;
        curModFile.categoryPath = '$modsDirPath$s$category';
        newModFiles.add(curModFile);

        //Json Write
        allModFiles.add(curModFile);
        allModFiles.map((mod) => mod.toJson()).toList();
        File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));
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
      final selectedCategory = cateList.firstWhere((element) => element.categoryName == category);
      if (selectedCategory.itemNames.indexWhere((element) => element == itemName) == -1) {
        selectedCategory.itemNames.insert(0, itemName);
        for (var cate in cateList) {
          if (cate.itemNames.indexWhere((e) => e == itemName) != -1) {
            int index = 0;
            if (cate.itemNames.length > 1) {
              index = cate.itemNames.indexOf(itemName.toString());
            }
            cate.allModFiles.addAll(newModFiles);
            cate.imageIcons.insert(index, icons);
            cate.numOfMods.insert(0, 0);
            cate.numOfMods[index] = finalModFolders.length;
            cate.numOfItems++;
            cate.numOfApplied.add(0);
          }
        }
      } else {
        for (var cate in cateList) {
          if (cate.itemNames.indexWhere((e) => e == itemName) != -1) {
            int index = 0;
            if (cate.itemNames.length > 1) {
              index = cate.itemNames.indexOf(itemName.toString());
            }
            cate.allModFiles.addAll(newModFiles);
            cate.numOfMods[index] += finalModFolders.length;
          }
        }
      }
      //addedItems.add(sortedLine);

      // Sort cate list
      if (selectedSortType == 1) {
        cateList.sort(((a, b) => b.numOfItems.compareTo(a.numOfItems)));
        ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
        cateList.insert(0, favCate);
        selectedSortTypeString = curLangText!.sortCateByNumItemsText;
      } else if (selectedSortType == 0) {
        cateList.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
        ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
        cateList.insert(0, favCate);
      }
      Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
    }
  }
// print(sortedModsList);
//   for (var item in addedItems) {
//     sortedModsList.remove(item);
//   }
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
      tempFavCate.itemNames.add(paramModFileList.first.modName);
      tempFavCate.itemNames.sort((a, b) => a.compareTo(b));
      tempFavCate.imageIcons.insert(tempFavCate.itemNames.indexOf(paramModFileList.first.modName), curCate.imageIcons[curCate.itemNames.indexOf(paramModFileList.first.modName)]);
      tempFavCate.numOfMods.add(1);
      tempFavCate.numOfApplied.insert(tempFavCate.itemNames.indexOf(paramModFileList.first.modName), curCate.numOfApplied[curCate.itemNames.indexOf(paramModFileList.first.modName)]);
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
    // if (isViewingFav) {
    //   modFilesList.remove(paramModFileList);
    // }
    if (tempFavCate.allModFiles.indexWhere((element) => element.modName == paramModFileList.first.modName) == -1) {
      tempFavCate.imageIcons.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.numOfMods.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.numOfApplied.removeAt(tempFavCate.itemNames.indexOf(paramModFileList.first.modName));
      tempFavCate.itemNames.remove(paramModFileList.first.modName);
      tempFavCate.numOfItems--;
    }
  }

  //tempFavCate.itemNames.sort();
  allModFiles.map((mod) => mod.toJson()).toList();
  File(modSettingsPath).writeAsStringSync(json.encode(allModFiles));

  return tempFavCate;
}

Future<String?> getFileHash(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) return null;
  try {
    final stream = file.openRead();
    final hash = await md5.bind(stream).first;

    return hash.toString();
  } catch (exception) {
    return null;
  }
}
