import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
//import 'package:collection/collection.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/functions/mods_adder.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:window_manager/window_manager.dart';

List<String> _pathsToRemove = ['win32', 'win32reboot', 'win32_na', 'win32reboot_na'];
bool _newModDragging = false;
bool _exitConfirmDialog = false;
List<String> _duplicateModNames = [];
final List<XFile> _newModDragDropList = [];
List<XFile> _newModMainFolderList = [];
List<XFile> modsToAddList = [];
Future? sortedModsListLoad;
List<List<String>> sortedModsList = [];
TextEditingController renameTextBoxController = TextEditingController();
List<bool> _itemNameRenameIndex = [];
List<List<bool>> _mainFolderRenameIndex = [];
List<List<bool>> _subFoldersRenameIndex = [];
bool _isNameEditing = false;
bool _isAddedSuccess = false;
//bool processTrigger = false;
List<String> _nonSupportedFileNames = [];
//List<List<String>> _dropdownCategories = [];
List<String> _dropdownCategories = [];
List<String> _selectedCategories = [];
final _subItemFormValidate = GlobalKey<FormState>();
bool dropZoneMax = true;

void modAddHandler(context) {
  Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
    String ogIcePath = '';
    int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
    int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
    int win32RebootPathIndex = ogWin32RebootFilePaths.indexWhere((element) => p.basename(element) == iceName);
    int win32RebootNAPathIndex = ogWin32RebootNAFilePaths.indexWhere((element) => p.basename(element) == iceName);
    if (win32PathIndex != -1) {
      ogIcePath = ogWin32FilePaths[win32PathIndex];
    } else if (win32NAPathIndex != -1) {
      ogIcePath = ogWin32NAFilePaths[win32NAPathIndex];
    } else if (win32RebootPathIndex != -1) {
      ogIcePath = ogWin32RebootFilePaths[win32RebootPathIndex];
    } else if (win32RebootNAPathIndex != -1) {
      ogIcePath = ogWin32RebootNAFilePaths[win32RebootNAPathIndex];
    } else {
      ogIcePath = '';
    }

    if (ogIcePath.isNotEmpty) {
      XFile iconFile = XFile(ogIcePath);

      String itemName = '';
      if (curActiveLang == 'JP') {
        itemName = itemNameJP;
      } else {
        itemName = itemNameEN;
      }

      XFile ddsIcon = XFile('');
      await Process.run(modManZamboniExePath, [iconFile.path]).then((value) {
        if (Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).existsSync()) {
          final files = Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
          ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
          if (ddsIcon.path.isNotEmpty) {
            final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
            ddsIcon = XFile(iconNewName.path);
          }
        }
      });

      if (ddsIcon.path.isNotEmpty) {
        await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsIcon.path]).then((value) {
          //processTrigger = true;
        });
        final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
            .copySync(Uri.file('$modManAddModsTempDirPath/${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}').toFilePath());
        if (await newPath.exists()) {
          Directory(Uri.file('${Directory.current.path}/${iceName}_ext').toFilePath()).deleteSync(recursive: true);
        }
        //processTrigger = true;
        return newPath.path;
      }
    }

    //processTrigger = true;

    return '';
  }

  Future<List<String>> findItemInCsv(XFile inputFile) async {
    List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
    for (var file in itemRefSheetsList) {
      for (var line in file) {
        if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
          var lineSplit = line.split(',');
          String jpItemName = lineSplit[0];
          String enItemName = lineSplit[1];
          for (var char in charToReplace) {
            jpItemName = jpItemName.replaceAll(char, '_');
            enItemName = enItemName.replaceAll(char, '_');
          }
          //[0 Category, 1 JP name, 2 EN name, 3 icon]
          if (emoteCsv.indexWhere((element) => file.first == element) != -1) {
            String jpEmoteName = lineSplit[1];
            String enEmoteName = lineSplit[2];
            for (var char in charToReplace) {
              jpEmoteName = jpEmoteName.replaceAll(char, '_');
              enEmoteName = enEmoteName.replaceAll(char, '_');
            }
            return (['Emotes', jpEmoteName, enEmoteName, '']);
          } else if (basewearCsv.indexWhere((element) => element == file.first) != -1) {
            if (lineSplit[0].contains('[Ba]') || lineSplit[1].contains('[Ba]')) {
              return (['Basewears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
            } else if (lineSplit[0].contains('[Se]') || lineSplit[1].contains('[Se]')) {
              return (['Setwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
            } else {
              return (['Misc', jpItemName, enItemName, '']);
            }
          } else if (accessoriesCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Accessories', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
          } else if (innerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Innerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (outerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Outerwears', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (bodyPaintCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Body Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (magsCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Mags', jpItemName, enItemName, await getIconPath(lineSplit[3], jpItemName, enItemName)]);
          } else if (stickersCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Stickers', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (facePaintCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Face Paints', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (hairCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Hairs', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (castBodyCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Body Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (castArmCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Arm Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (castLegCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Cast Leg Parts', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (eyeCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Eyes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (costumeCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Costumes', jpItemName, enItemName, await getIconPath(lineSplit[4], jpItemName, enItemName)]);
          } else if (motionCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Motions', jpItemName, enItemName, '']);
          } else {
            return (['Misc', jpItemName, enItemName, '']);
          }
        }
      }
    }

    return [];
  }

  Future<List<List<String>>> fetchItemName(List<XFile> inputFiles) async {
    List<List<String>> filesList = [];
    //getting main dirs
    List<String> mainDirPaths = [];
    for (var file in _newModMainFolderList) {
      if (p.extension(file.path) == '.zip') {
        final ext = file.name.substring(file.name.lastIndexOf('.'));
        String nameAfterExtract = file.name.replaceAll(ext, '');
        mainDirPaths.add(Uri.file('$modManAddModsUnpackDirPath/$nameAfterExtract').toFilePath());
      } else if (_pathsToRemove.indexWhere((element) => element == file.name) != -1) {
        mainDirPaths.add(file.path.replaceFirst('${Uri.file('/').toFilePath()}${file.name}', ''));
      } else {
        if (!File(file.path).existsSync()) {
          mainDirPaths.add(file.path);
        } else {
          if (mainDirPaths.indexWhere((element) => element == File(file.path).parent.path) == -1) {
            mainDirPaths.add(File(file.path).parent.path);
          }
        }
      }
    }

    //copy files to temp with new folder structures
    List<List<String>> extraFiles = [];
    //int unknownModsCounter = 1;
    for (var inputFile in inputFiles) {
      if (File(inputFile.path).existsSync() && !inputFile.path.contains(modManAddModsTempDirPath)) {
        for (var mainPath in mainDirPaths) {
          //Paths have main path and continue with /
          if (inputFile.path.contains('$mainPath${Uri.file('/').toFilePath()}')) {
            String mainDirName = p.basename(mainPath);
            List<String> curPathSplit = inputFile.path.split(Uri.file('/').toFilePath());
            String subDirName = '';
            if (_pathsToRemove.indexWhere((element) => inputFile.path.split(Uri.file('/').toFilePath()).contains(element)) != -1) {
              curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
              curPathSplit.removeRange(
                  curPathSplit.indexWhere((element) => element == _pathsToRemove[_pathsToRemove.indexWhere((element) => inputFile.path.split(Uri.file('/').toFilePath()).contains(element))]),
                  curPathSplit.length);
              subDirName = curPathSplit.join(' - ');
            } else {
              curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
              curPathSplit.remove(inputFile.name);
              subDirName = curPathSplit.join(' - ');
            }

            //moving files to temp with sorted paths
            if (!Directory(Uri.file('$modManAddModsTempDirPath/$mainDirName/$subDirName').toFilePath()).existsSync()) {
              Directory(Uri.file('$modManAddModsTempDirPath/$mainDirName/$subDirName').toFilePath()).createSync(recursive: true);
            }
            File(inputFile.path).copySync(Uri.file('$modManAddModsTempDirPath/$mainDirName/$subDirName/${inputFile.name}').toFilePath());

            //get category and item name
            int indexInFilesList = -1;
            if (p.extension(inputFile.path) == '') {
              List<String> itemInfo = await findItemInCsv(inputFile);
              if (itemInfo.isNotEmpty) {
                if (filesList.indexWhere((element) => element[1].contains(itemInfo[1])) != -1 && filesList.indexWhere((element) => element[2].contains(itemInfo[2])) != -1) {
                  indexInFilesList = filesList.indexWhere((element) => element[1].contains(itemInfo[1]));
                  itemInfo = filesList[indexInFilesList];
                }
              } else {
                itemInfo = ['Misc', '不明な項目', 'Unknown Items', ''];
                // itemInfo = ['Misc', '不明な項目 $unknownModsCounter', 'Unknown Item $unknownModsCounter'];
                // unknownModsCounter++;
              }

              if (itemInfo.length < 5) {
                itemInfo.add(mainDirName);
              } else {
                if (!itemInfo[4].split('|').contains(mainDirName)) {
                  itemInfo[4] += '|$mainDirName';
                }
              }
              if (itemInfo.length < 6) {
                if (subDirName.isNotEmpty) {
                  itemInfo.add('$mainDirName:$subDirName');
                } else {
                  itemInfo.add('');
                }
              } else {
                if (!itemInfo[5].split('|').contains('$mainDirName:$subDirName')) {
                  if (subDirName.isNotEmpty) {
                    itemInfo[5] += '|$mainDirName:$subDirName';
                  } else {
                    itemInfo[5] += '';
                  }
                }
              }
              if (itemInfo.length < 7) {
                itemInfo.add('$mainDirName:$subDirName:${inputFile.name}');
              } else {
                if (!itemInfo[6].split('|').contains('$mainDirName:$subDirName:${inputFile.name}')) {
                  itemInfo[6] += '|$mainDirName:$subDirName:${inputFile.name}';
                }
              }

              //[0catname, 1jpname, 2enname, 3maindir, 4subdirs, 5files]
              if (indexInFilesList != -1) {
                filesList[indexInFilesList] = itemInfo;
              } else {
                filesList.add(itemInfo);
              }
            } else {
              if (subDirName.isNotEmpty) {
                extraFiles.add(['', '', '', '', mainDirName, '$mainDirName:$subDirName', '$mainDirName:$subDirName:${inputFile.name}']);
              } else {
                extraFiles.add(['', '', '', '', mainDirName, '', '$mainDirName:$subDirName:${inputFile.name}']);
              }
            }

            //print('Sub: $subDirName');
          }
        }
      }
    }
    for (var extraFile in extraFiles) {
      //print(extraFile);
      for (var file in filesList) {
        if (file[4].split('|').contains(extraFile[4]) && file[5].split('|').contains(extraFile[5])) {
          file[6] += '|${extraFile[6]}';
          //print(file);
        }
      }
    }

    Provider.of<StateProvider>(context, listen: false).modAdderReloadTrue();

    return filesList;
  }

  // Future<List<Item>> toAddItemsFetch(List<XFile> iceFiles) async {
  //   final itemCsvList = await itemCsvFetcher(modManRefSheetsDirPath);
  //   final modFileCsvList = modFileCsvFetcher(itemCsvList, iceFiles.map((e) => File(e.path)).toList());
  //   for (var element in modFileCsvList) {
  //   }

  //   return [];
  // }

  //Main popup
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height,
                  child: Scaffold(
                    backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                    body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      return FutureBuilder(
                        future: popSheetsList(modManRefSheetsDirPath),
                        builder: ((
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
                          if (snapshot.connectionState == ConnectionState.waiting && itemRefSheetsList.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiPreparing,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      curLangText!.uiErrorWhenLoadingAddModsData,
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          windowManager.destroy();
                                        },
                                        child: Text(curLangText!.uiExit))
                                  ],
                                ),
                              );
                            } else if (!snapshot.hasData) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      curLangText!.uiLoadingAppliedMods,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            } else {
                              itemRefSheetsList = snapshot.data;

                              return Row(
                                children: [
                                  RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        'ADD MODS',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 10),
                                      )),
                                  VerticalDivider(
                                    width: 10,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ),
                                  SizedBox(
                                    width: dropZoneMax
                                        ? constraints.maxWidth * 0.7
                                        : _newModDragDropList.isEmpty
                                            ? constraints.maxWidth * 0.3
                                            : constraints.maxWidth * 0.45,
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: AlignmentDirectional.bottomStart,
                                          children: [
                                            DropTarget(
                                              //enable: true,
                                              onDragDone: (detail) async {
                                                for (var element in detail.files) {
                                                  if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                                    if (_nonSupportedFileNames.indexWhere((e) => e == element.name) == -1) {
                                                      _nonSupportedFileNames.add(element.name);
                                                    }
                                                  } else if (_newModDragDropList.indexWhere((file) => file.path == element.path) == -1) {
                                                    _newModDragDropList.add(element);
                                                    _newModMainFolderList.add(element);
                                                  }
                                                }
                                                setState(
                                                  () {},
                                                );
                                              },
                                              onDragEntered: (detail) {
                                                setState(() {
                                                  _newModDragging = true;
                                                });
                                              },
                                              onDragExited: (detail) {
                                                setState(() {
                                                  _newModDragging = false;
                                                });
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 5),
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      border: Border.all(color: Theme.of(context).hintColor),
                                                      color: _newModDragging ? Colors.blue.withOpacity(0.4) : Colors.black26.withAlpha(20),
                                                    ),
                                                    height: constraints.maxHeight - 42,
                                                    //width: constraints.maxWidth * 0.45,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (_newModDragDropList.isEmpty)
                                                          Center(
                                                              child: Text(
                                                            curLangText!.uiDragDropFiles,
                                                            style: const TextStyle(fontSize: 20),
                                                            textAlign: TextAlign.center,
                                                          )),
                                                        if (_newModDragDropList.isNotEmpty)
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(right: 5),
                                                              child: SizedBox(
                                                                  width: constraints.maxWidth,
                                                                  height: constraints.maxHeight,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                    child: ListView.builder(
                                                                        itemCount: _newModDragDropList.length,
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          return ListTile(
                                                                            //dense: true,
                                                                            // leading: const Icon(
                                                                            //     Icons.list),
                                                                            trailing: SizedBox(
                                                                              width: 40,
                                                                              child: ModManTooltip(
                                                                                message: curLangText!.uiRemove,
                                                                                child: MaterialButton(
                                                                                  child: const Icon(Icons.remove_circle),
                                                                                  onPressed: () {
                                                                                    _newModDragDropList.removeAt(index);
                                                                                    setState(
                                                                                      () {},
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            title: Text(_newModDragDropList[index].name),
                                                                            subtitle: Text(
                                                                              _newModDragDropList[index].path,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              softWrap: false,
                                                                            ),
                                                                          );
                                                                        }),
                                                                  )),
                                                            ),
                                                          )
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            if (_nonSupportedFileNames.isNotEmpty)
                                              Container(
                                                //width: constraints.maxWidth * 0.45,
                                                //height: 60,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(3),
                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                    color: Theme.of(context).dialogBackgroundColor),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(5.0),
                                                      child: Center(
                                                          child: Text(
                                                        curLangText!.uiAchiveCurrentlyNotSupported,
                                                        textAlign: TextAlign.center,
                                                      )),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 5),
                                                      child: ElevatedButton(
                                                        child: Text(curLangText!.uiClose),
                                                        onPressed: () {
                                                          _nonSupportedFileNames.clear();
                                                          setState(
                                                            () {},
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(
                                          //width: constraints.maxWidth * 0.7,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 5, bottom: 4),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: _newModDragDropList.isNotEmpty
                                                          ? (() {
                                                              _newModDragDropList.clear();
                                                              _newModMainFolderList.clear();
                                                              setState(
                                                                () {},
                                                              );
                                                            })
                                                          : null,
                                                      child: Text(curLangText!.uiClearAll)),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: _newModDragDropList.isNotEmpty
                                                          ? (() async {
                                                              for (var file in _newModDragDropList) {
                                                                if (p.extension(file.path) == '.zip') {
                                                                  await extractFileToDisk(file.path, Uri.file('unpack/${file.name.replaceAll('.zip', '')}').toFilePath(), asyncWrite: true)
                                                                      .then((_) => setState(
                                                                            () {
                                                                              for (var file in Directory(modManAddModsUnpackDirPath).listSync(recursive: true)) {
                                                                                modsToAddList.add(XFile(file.path));
                                                                              }
                                                                            },
                                                                          ));
                                                                  //modsToAddList.addAll(await sortFile(file.name.split('.').first));
                                                                } else if (Directory(file.path).existsSync()) {
                                                                  List<XFile> filesInFolder = [XFile(file.path)];
                                                                  for (var file in Directory(file.path).listSync(recursive: true)) {
                                                                    //if (File(file.path).existsSync()) {
                                                                    filesInFolder.add(XFile(file.path));
                                                                    //}
                                                                  }
                                                                  modsToAddList.addAll(filesInFolder);
                                                                } else {
                                                                  modsToAddList.add(XFile(file.path));
                                                                }
                                                              }
                                                              // for (var element in modsToAddList) {
                                                              //   print(element.name);
                                                              // }

                                                              //clear lists
                                                              sortedModsListLoad = fetchItemName(modsToAddList);
                                                              _newModDragDropList.clear();
                                                              dropZoneMax = false;
                                                              setState(
                                                                () {},
                                                              );
                                                            })
                                                          : null,
                                                      child: Text(curLangText!.uiProcess)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    width: 10,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: AlignmentDirectional.bottomStart,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5, right: 5),
                                              child: SizedBox(
                                                height: constraints.maxHeight - 42,
                                                child: FutureBuilder(
                                                    future: sortedModsListLoad,
                                                    builder: (
                                                      BuildContext context,
                                                      AsyncSnapshot snapshot,
                                                    ) {
                                                      if (snapshot.connectionState == ConnectionState.none || modsToAddList.isEmpty) {
                                                        return Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                curLangText!.uiWaitingForData,
                                                                style: const TextStyle(fontSize: 20),
                                                              ),
                                                              const SizedBox(
                                                                height: 20,
                                                              ),
                                                              const CircularProgressIndicator(),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        if (snapshot.hasError) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  curLangText!.uiErrorWhenLoadingAddModsData,
                                                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        } else if (!snapshot.hasData) {
                                                          return Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  curLangText!.uiLoadingModsAdderData,
                                                                  style: const TextStyle(fontSize: 20),
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                const CircularProgressIndicator(),
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          sortedModsList = snapshot.data;

                                                          if (_mainFolderRenameIndex.isEmpty) {
                                                            _itemNameRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                            _mainFolderRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                            for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                              _mainFolderRenameIndex[i] = List.generate(sortedModsList[i][4].split('|').length, (index) => false);
                                                            }
                                                            _subFoldersRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                            for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                              _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                            }
                                                          } else if (_mainFolderRenameIndex.isNotEmpty && _mainFolderRenameIndex.length < sortedModsList.length) {
                                                            _itemNameRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                            _mainFolderRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                            for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                              _mainFolderRenameIndex[i] = List.generate(sortedModsList[i][4].split('|').length, (index) => false);
                                                            }
                                                            _subFoldersRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                            for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                              _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                            }
                                                          } else if (_mainFolderRenameIndex.isNotEmpty && _mainFolderRenameIndex.length == sortedModsList.length) {
                                                            for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                              if (_mainFolderRenameIndex[i].length < sortedModsList[i][4].split('|').length) {
                                                                for (int missingEle = sortedModsList[i][4].split('|').length - _mainFolderRenameIndex[i].length; missingEle > 0; missingEle--) {
                                                                  _mainFolderRenameIndex[i].add(false);
                                                                }
                                                              }
                                                            }
                                                            for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                              if (_subFoldersRenameIndex[i].length < sortedModsList[i][5].split('|').length) {
                                                                for (int missingEle = sortedModsList[i][5].split('|').length - _subFoldersRenameIndex[i].length; missingEle > 0; missingEle--) {
                                                                  _subFoldersRenameIndex[i].add(false);
                                                                }
                                                              }
                                                            }
                                                          }
                                                          //get catelist
                                                          // if (_dropdownCategories.isEmpty) {
                                                          //   for (var category in cateList) {
                                                          //     if (category.categoryName != 'Favorites') {
                                                          //       _dropdownCategories.add(category.categoryName);
                                                          //     }
                                                          //   }
                                                          // } else if (dropdownCategories.isNotEmpty && _dropdownCategories.length < cateList.length) {
                                                          //   _dropdownCategories.clear();
                                                          //   for (var category in cateList) {
                                                          //     if (category.categoryName != 'Favorites') {
                                                          //       _dropdownCategories.add(category.categoryName);
                                                          //     }
                                                          //   }
                                                          // }

                                                          if (_selectedCategories.isEmpty) {
                                                            for (var element in sortedModsList) {
                                                              _selectedCategories.add(element.first);
                                                            }
                                                          } else if (_selectedCategories.isNotEmpty && _selectedCategories.length < sortedModsList.length) {
                                                            _selectedCategories.clear();
                                                            for (var element in sortedModsList) {
                                                              _selectedCategories.add(element.first);
                                                            }
                                                          }

                                                          return ScrollbarTheme(
                                                            data: ScrollbarThemeData(
                                                              thumbColor: MaterialStateProperty.resolveWith((states) {
                                                                if (states.contains(MaterialState.hovered)) {
                                                                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                                }
                                                                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                              }),
                                                            ),
                                                            child: SingleChildScrollView(
                                                                child: ListView.builder(
                                                                    shrinkWrap: true,
                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                    itemCount: sortedModsList.length,
                                                                    itemBuilder: (context, index) {
                                                                      return Card(
                                                                        margin: const EdgeInsets.only(top: 0, bottom: 2, left: 0, right: 0),
                                                                        //color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                        child: ExpansionTile(
                                                                          initiallyExpanded: true,
                                                                          //Edit Item's name
                                                                          title: Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                                                child: Container(
                                                                                  width: 80,
                                                                                  height: 80,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                    border: Border.all(color: Theme.of(context).hintColor),
                                                                                  ),
                                                                                  child: sortedModsList[index][3].isEmpty
                                                                                      ? Image.asset(
                                                                                          'assets/img/placeholdersquare.png',
                                                                                          fit: BoxFit.fitWidth,
                                                                                        )
                                                                                      : Image.file(
                                                                                          File(sortedModsList[index][3]),
                                                                                          fit: BoxFit.fitWidth,
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                        height: 40,
                                                                                        child: sortedModsList[index][0] == 'Misc'
                                                                                            ? DropdownButton2(
                                                                                                hint: Text(curLangText!.uiSelectACategory),
                                                                                                buttonStyleData: ButtonStyleData(
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                                    border: Border.all(color: Theme.of(context).hintColor),
                                                                                                  ),
                                                                                                  width: 150,
                                                                                                  height: 35,
                                                                                                ),
                                                                                                dropdownStyleData: DropdownStyleData(
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius.circular(3),
                                                                                                    color: MyApp.themeNotifier.value == ThemeMode.light
                                                                                                        ? Theme.of(context).cardColor
                                                                                                        : Theme.of(context).primaryColor,
                                                                                                  ),
                                                                                                  elevation: 3,

                                                                                                  //dropdownWidth: 361,
                                                                                                  maxHeight: constraints.maxHeight * 0.5,
                                                                                                ),
                                                                                                iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 30),
                                                                                                menuItemStyleData: const MenuItemStyleData(
                                                                                                  height: 40,
                                                                                                ),
                                                                                                items: _dropdownCategories
                                                                                                    .map((item) => DropdownMenuItem<String>(
                                                                                                        value: item,
                                                                                                        child: Row(
                                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                                          children: [
                                                                                                            Container(
                                                                                                              padding: const EdgeInsets.only(bottom: 3),
                                                                                                              child: Text(
                                                                                                                item,
                                                                                                                style: const TextStyle(
                                                                                                                    //fontSize: 14,
                                                                                                                    //fontWeight: FontWeight.bold,
                                                                                                                    //color: Colors.white,
                                                                                                                    ),
                                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                              ),
                                                                                                            )
                                                                                                          ],
                                                                                                        )))
                                                                                                    .toList(),
                                                                                                value: _selectedCategories[index],
                                                                                                onChanged: (value) {
                                                                                                  setState(() {
                                                                                                    _selectedCategories[index] = value.toString();
                                                                                                    sortedModsList[index][0] = value.toString();
                                                                                                  });
                                                                                                },
                                                                                              )
                                                                                            : SizedBox(
                                                                                                width: 150,
                                                                                                height: 35,
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.only(top: 10),
                                                                                                  child: Text(sortedModsList[index].first,
                                                                                                      style: TextStyle(
                                                                                                          fontWeight: FontWeight.w600,
                                                                                                          color: sortedModsList[index][1].split(':').last.toString() == '[TOREMOVE]'
                                                                                                              ? Theme.of(context).disabledColor
                                                                                                              : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                                ),
                                                                                              )),
                                                                                    SizedBox(
                                                                                      height: 40,
                                                                                      child: _itemNameRenameIndex[index]
                                                                                          ? Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: SizedBox(
                                                                                                    //width: constraints.maxWidth * 0.4,
                                                                                                    height: 40,
                                                                                                    child: TextFormField(
                                                                                                      autofocus: true,
                                                                                                      controller: renameTextBoxController,
                                                                                                      maxLines: 1,
                                                                                                      maxLength: 50,
                                                                                                      decoration: InputDecoration(
                                                                                                        contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                                        border: const OutlineInputBorder(),
                                                                                                        hintText: curActiveLang == 'JP' ? sortedModsList[index][1] : sortedModsList[index][2],
                                                                                                        counterText: '',
                                                                                                      ),
                                                                                                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                                      onEditingComplete: () {
                                                                                                        if (renameTextBoxController.text.isNotEmpty) {
                                                                                                          String newItemName = renameTextBoxController.text.trim();
                                                                                                          if (sortedModsList[index][0] == 'Basewears' &&
                                                                                                              !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                            newItemName += ' [Ba]';
                                                                                                          } else if (sortedModsList[index][0] == 'Innerwears' &&
                                                                                                              !renameTextBoxController.text.contains('[In]')) {
                                                                                                            newItemName += ' [In]';
                                                                                                          } else if (sortedModsList[index][0] == 'Outerwears' &&
                                                                                                              !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                            newItemName += ' [Ou]';
                                                                                                          } else if (sortedModsList[index][0] == 'Setwears' &&
                                                                                                              !renameTextBoxController.text.contains('[Se]')) {
                                                                                                            newItemName += ' [Se]';
                                                                                                          } else {
                                                                                                            newItemName = renameTextBoxController.text;
                                                                                                          }
                                                                                                          if (curActiveLang == 'JP') {
                                                                                                            sortedModsList[index][1] = newItemName;
                                                                                                          } else {
                                                                                                            sortedModsList[index][2] = newItemName;
                                                                                                          }

                                                                                                          //print(sortedModsList);
                                                                                                        }
                                                                                                        _itemNameRenameIndex[index] = false;
                                                                                                        renameTextBoxController.clear();
                                                                                                        _isNameEditing = false;

                                                                                                        setState(
                                                                                                          () {},
                                                                                                        );
                                                                                                      },
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 5,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 40,
                                                                                                  child: MaterialButton(
                                                                                                    onPressed: () {
                                                                                                      if (renameTextBoxController.text.isNotEmpty) {
                                                                                                        String newItemName = renameTextBoxController.text.trim();
                                                                                                        if (sortedModsList[index][0] == 'Basewears' && !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                          newItemName += ' [Ba]';
                                                                                                        } else if (sortedModsList[index][0] == 'Innerwears' &&
                                                                                                            !renameTextBoxController.text.contains('[In]')) {
                                                                                                          newItemName += ' [In]';
                                                                                                        } else if (sortedModsList[index][0] == 'Outerwears' &&
                                                                                                            !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                          newItemName += ' [Ou]';
                                                                                                        } else if (sortedModsList[index][0] == 'Setwears' &&
                                                                                                            !renameTextBoxController.text.contains('[Se]')) {
                                                                                                          newItemName += ' [Se]';
                                                                                                        } else {
                                                                                                          newItemName = renameTextBoxController.text;
                                                                                                        }
                                                                                                        if (curActiveLang == 'JP') {
                                                                                                          sortedModsList[index][1] = newItemName;
                                                                                                        } else {
                                                                                                          sortedModsList[index][2] = newItemName;
                                                                                                        }

                                                                                                        //print(sortedModsList);
                                                                                                      }
                                                                                                      _itemNameRenameIndex[index] = false;
                                                                                                      renameTextBoxController.clear();
                                                                                                      _isNameEditing = false;

                                                                                                      setState(
                                                                                                        () {},
                                                                                                      );
                                                                                                    },
                                                                                                    child: const Icon(Icons.check),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: curActiveLang == 'JP'
                                                                                                      ? Padding(
                                                                                                          padding: const EdgeInsets.only(bottom: 3),
                                                                                                          child: Text(sortedModsList[index][1].split(':').first,
                                                                                                              style: TextStyle(
                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                  color: sortedModsList[index][1].split(':').last.toString() == '[TOREMOVE]'
                                                                                                                      ? Theme.of(context).disabledColor
                                                                                                                      : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                                        )
                                                                                                      : Padding(
                                                                                                          padding: const EdgeInsets.only(bottom: 3),
                                                                                                          child: Text(sortedModsList[index][2].split(':').first,
                                                                                                              style: TextStyle(
                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                  color: sortedModsList[index][1].split(':').last.toString() == '[TOREMOVE]'
                                                                                                                      ? Theme.of(context).disabledColor
                                                                                                                      : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                                        ),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 5,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 40,
                                                                                                  child: Tooltip(
                                                                                                    message: curLangText!.uiEditName,
                                                                                                    height: 25,
                                                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                    waitDuration: const Duration(seconds: 1),
                                                                                                    child: MaterialButton(
                                                                                                      onPressed: !_isNameEditing &&
                                                                                                              (sortedModsList[index][1].split(':').last != '[TOREMOVE]' ||
                                                                                                                  sortedModsList[index][2].split(':').last != '[TOREMOVE]')
                                                                                                          ? () {
                                                                                                              renameTextBoxController.text =
                                                                                                                  curActiveLang == 'JP' ? sortedModsList[index][1] : sortedModsList[index][2];
                                                                                                              renameTextBoxController.selection = TextSelection(
                                                                                                                baseOffset: 0,
                                                                                                                extentOffset: renameTextBoxController.text.length,
                                                                                                              );
                                                                                                              _isNameEditing = true;
                                                                                                              _itemNameRenameIndex[index] = true;
                                                                                                              setState(
                                                                                                                () {},
                                                                                                              );
                                                                                                            }
                                                                                                          : null,
                                                                                                      child: const Icon(Icons.edit),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 5,
                                                                                                ),
                                                                                                if (sortedModsList[index][1].split(':').last != '[TOREMOVE]' ||
                                                                                                    sortedModsList[index][2].split(':').last != '[TOREMOVE]')
                                                                                                  SizedBox(
                                                                                                    width: 40,
                                                                                                    child: ModManTooltip(
                                                                                                      message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                                      child: MaterialButton(
                                                                                                        onPressed: () {
                                                                                                          sortedModsList[index][1] += ':[TOREMOVE]';
                                                                                                          sortedModsList[index][2] += ':[TOREMOVE]';
                                                                                                          final mainNames = sortedModsList[index][4].split('|');
                                                                                                          String mainTemp = '';
                                                                                                          for (int i = 0; i < mainNames.length; i++) {
                                                                                                            if (mainTemp.isEmpty) {
                                                                                                              if (mainNames[i].split(':').last != '[TOREMOVE]') {
                                                                                                                mainTemp = mainNames[i] += ':[TOREMOVE]';
                                                                                                              } else {
                                                                                                                mainTemp = mainNames[i];
                                                                                                              }
                                                                                                            } else {
                                                                                                              if (mainNames[i].split(':').last != '[TOREMOVE]') {
                                                                                                                mainTemp += '|${mainNames[i]}:[TOREMOVE]';
                                                                                                              } else {
                                                                                                                mainTemp += '|${mainNames[i]}';
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                          sortedModsList[index][4] = mainTemp;
                                                                                                          final subNames = sortedModsList[index][5].split('|');
                                                                                                          String subTemp = '';
                                                                                                          for (int i = 0; i < subNames.length; i++) {
                                                                                                            if (subTemp.isEmpty) {
                                                                                                              if (subNames[i].split(':').last != '[TOREMOVE]') {
                                                                                                                subTemp = subNames[i] += ':[TOREMOVE]';
                                                                                                              } else {
                                                                                                                subTemp = subNames[i];
                                                                                                              }
                                                                                                            } else {
                                                                                                              if (subNames[i].split(':').last != '[TOREMOVE]') {
                                                                                                                subTemp += '|${subNames[i]}:[TOREMOVE]';
                                                                                                              } else {
                                                                                                                subTemp += '|${subNames[i]}';
                                                                                                              }
                                                                                                            }
                                                                                                          }
                                                                                                          sortedModsList[index][5] = subTemp;
                                                                                                          //print(sortedModsList[index]);
                                                                                                          setState(
                                                                                                            () {},
                                                                                                          );
                                                                                                        },
                                                                                                        child: const Icon(
                                                                                                          Icons.check_box_outlined,
                                                                                                          color: Colors.green,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                if (sortedModsList[index][1].split(':').last == '[TOREMOVE]' ||
                                                                                                    sortedModsList[index][2].split(':').last == '[TOREMOVE]')
                                                                                                  SizedBox(
                                                                                                    width: 40,
                                                                                                    child: ModManTooltip(
                                                                                                      message: curLangText!.uiMarkThisToBeAdded,
                                                                                                      child: MaterialButton(
                                                                                                        onPressed: () {
                                                                                                          sortedModsList[index][1] = sortedModsList[index][1].replaceAll(':[TOREMOVE]', '');
                                                                                                          sortedModsList[index][2] = sortedModsList[index][2].replaceAll(':[TOREMOVE]', '');
                                                                                                          sortedModsList[index][4] = sortedModsList[index][4].replaceAll(':[TOREMOVE]', '');
                                                                                                          sortedModsList[index][5] = sortedModsList[index][5].replaceAll(':[TOREMOVE]', '');
                                                                                                          //print(sortedModsList[index]);
                                                                                                          setState(
                                                                                                            () {},
                                                                                                          );
                                                                                                        },
                                                                                                        child: const Icon(
                                                                                                          Icons.check_box_outline_blank_outlined,
                                                                                                          color: Colors.red,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                              ],
                                                                                            ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                          textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          collapsedTextColor:
                                                                              MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          //childrenPadding: const EdgeInsets.only(left: 10),
                                                                          children: [
                                                                            for (int ex = 0; ex < sortedModsList[index][4].split('|').length; ex++)
                                                                              ExpansionTile(
                                                                                initiallyExpanded: true,
                                                                                childrenPadding: const EdgeInsets.only(left: 15),
                                                                                textColor:
                                                                                    MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                iconColor:
                                                                                    MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                collapsedTextColor:
                                                                                    MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                //Edit Name
                                                                                title: _mainFolderRenameIndex[index][ex]
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: SizedBox(
                                                                                              //width: constraints.maxWidth * 0.4,
                                                                                              height: 40,
                                                                                              child: TextFormField(
                                                                                                autofocus: true,
                                                                                                controller: renameTextBoxController,
                                                                                                maxLines: 1,
                                                                                                maxLength: 50,
                                                                                                decoration: InputDecoration(
                                                                                                  contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                                  border: const OutlineInputBorder(),
                                                                                                  hintText: sortedModsList[index][4].split('|')[ex],
                                                                                                  counterText: '',
                                                                                                ),
                                                                                                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                                onEditingComplete: () {
                                                                                                  if (renameTextBoxController.text.isNotEmpty) {
                                                                                                    //print('OLD: $sortedModsList');
                                                                                                    String oldMainDirName = sortedModsList[index][4].split('|')[ex];
                                                                                                    // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                                    //     .renameSync('$modManAddModsTempDirPath$s${renameTextBoxController.text}');
                                                                                                    List<FileSystemEntity> curFilesInMainDir =
                                                                                                        Directory(Uri.file('$modManAddModsTempDirPath/$oldMainDirName').toFilePath())
                                                                                                            .listSync(recursive: true);
                                                                                                    for (var element in curFilesInMainDir) {
                                                                                                      //print(curFilesInMainDir);
                                                                                                      String newMainPath = element.path.replaceFirst(
                                                                                                          Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                          Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                      if (!File(element.path).existsSync()) {
                                                                                                        Directory(newMainPath).createSync(recursive: true);
                                                                                                      }
                                                                                                      if (sortedModsList[index][5].isEmpty) {
                                                                                                        Directory(Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}').toFilePath())
                                                                                                            .createSync(recursive: true);
                                                                                                      }
                                                                                                    }
                                                                                                    for (var element in curFilesInMainDir) {
                                                                                                      String newMainPath = element.path.replaceFirst(
                                                                                                          Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                          Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                      if (File(element.path).existsSync()) {
                                                                                                        File(element.path).copySync(newMainPath);
                                                                                                      }
                                                                                                    }

                                                                                                    //Itemlist
                                                                                                    //Item name replace
                                                                                                    List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                                    mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                    sortedModsList[index][4] = mainDirsString.join('|');

                                                                                                    //Subitem Item name replace
                                                                                                    List<String> mainDirsInSubItemString = sortedModsList[index][5].split('|');
                                                                                                    for (var element in mainDirsInSubItemString) {
                                                                                                      List<String> split = element.split((':'));
                                                                                                      if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                        split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                        mainDirsInSubItemString[mainDirsInSubItemString.indexOf(element)] = split.join(':');
                                                                                                      }
                                                                                                    }
                                                                                                    sortedModsList[index][5] = mainDirsInSubItemString.join('|');

                                                                                                    //icefile Item name replace
                                                                                                    List<String> mainDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                    for (var element in mainDirsInItemString) {
                                                                                                      List<String> split = element.split((':'));
                                                                                                      if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                        split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                        mainDirsInItemString[mainDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                      }
                                                                                                    }
                                                                                                    sortedModsList[index][6] = mainDirsInItemString.join('|');

                                                                                                    //print(sortedModsList);
                                                                                                  }
                                                                                                  _mainFolderRenameIndex[index][ex] = false;
                                                                                                  renameTextBoxController.clear();
                                                                                                  _isNameEditing = false;

                                                                                                  setState(
                                                                                                    () {},
                                                                                                  );
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 40,
                                                                                            child: MaterialButton(
                                                                                              onPressed: () {
                                                                                                if (renameTextBoxController.text.isNotEmpty) {
                                                                                                  String oldMainDirName = sortedModsList[index][4].split('|')[ex];
                                                                                                  // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                                  //     .renameSync('$modManAddModsTempDirPath$s${renameTextBoxController.text}');
                                                                                                  List<FileSystemEntity> curFilesInMainDir =
                                                                                                      Directory(Uri.file('$modManAddModsTempDirPath/$oldMainDirName').toFilePath())
                                                                                                          .listSync(recursive: true);
                                                                                                  for (var element in curFilesInMainDir) {
                                                                                                    //print(curFilesInMainDir);
                                                                                                    String newMainPath = element.path.replaceFirst(
                                                                                                        Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                        Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                    if (!File(element.path).existsSync()) {
                                                                                                      Directory(newMainPath).createSync(recursive: true);
                                                                                                    }
                                                                                                    if (sortedModsList[index][5].isEmpty) {
                                                                                                      Directory(Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}').toFilePath())
                                                                                                          .createSync(recursive: true);
                                                                                                    }
                                                                                                  }
                                                                                                  for (var element in curFilesInMainDir) {
                                                                                                    String newMainPath = element.path.replaceFirst(
                                                                                                        Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                        Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                    if (File(element.path).existsSync()) {
                                                                                                      File(element.path).copySync(newMainPath);
                                                                                                    }
                                                                                                  }

                                                                                                  //Itemlist
                                                                                                  List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                                  mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                  sortedModsList[index][4] = mainDirsString.join('|');

                                                                                                  //Subitem Item name replace
                                                                                                  List<String> mainDirsInSubItemString = sortedModsList[index][5].split('|');
                                                                                                  for (var element in mainDirsInSubItemString) {
                                                                                                    List<String> split = element.split((':'));
                                                                                                    if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                      split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                      mainDirsInSubItemString[mainDirsInSubItemString.indexOf(element)] = split.join(':');
                                                                                                    }
                                                                                                  }
                                                                                                  sortedModsList[index][5] = mainDirsInSubItemString.join('|');

                                                                                                  List<String> mainDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                  for (var element in mainDirsInItemString) {
                                                                                                    List<String> split = element.split((':'));
                                                                                                    if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                      split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                      mainDirsInItemString[mainDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                    }
                                                                                                  }
                                                                                                  sortedModsList[index][6] = mainDirsInItemString.join('|');

                                                                                                  //print(sortedModsList);
                                                                                                }
                                                                                                _mainFolderRenameIndex[index][ex] = false;
                                                                                                renameTextBoxController.clear();
                                                                                                _isNameEditing = false;

                                                                                                setState(
                                                                                                  () {},
                                                                                                );
                                                                                              },
                                                                                              child: const Icon(Icons.check),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: Text(sortedModsList[index][4].split('|')[ex].split(':').first,
                                                                                                style: TextStyle(
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    color: sortedModsList[index][4].split('|')[ex].split(':').last == '[TOREMOVE]'
                                                                                                        ? Theme.of(context).disabledColor
                                                                                                        : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 40,
                                                                                            child: ModManTooltip(
                                                                                              message: curLangText!.uiEditName,
                                                                                              child: MaterialButton(
                                                                                                onPressed: !_isNameEditing && sortedModsList[index][4].split('|')[ex].split(':').last != '[TOREMOVE]'
                                                                                                    ? () {
                                                                                                        renameTextBoxController.text = sortedModsList[index][4].split('|')[ex];
                                                                                                        renameTextBoxController.selection = TextSelection(
                                                                                                          baseOffset: 0,
                                                                                                          extentOffset: renameTextBoxController.text.length,
                                                                                                        );
                                                                                                        _isNameEditing = true;
                                                                                                        _mainFolderRenameIndex[index][ex] = true;
                                                                                                        setState(
                                                                                                          () {},
                                                                                                        );
                                                                                                      }
                                                                                                    : null,
                                                                                                child: const Icon(Icons.edit),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(
                                                                                            width: 5,
                                                                                          ),
                                                                                          if (sortedModsList[index][4].split('|')[ex].split(':').last != '[TOREMOVE]')
                                                                                            SizedBox(
                                                                                              width: 40,
                                                                                              child: Tooltip(
                                                                                                message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                                height: 25,
                                                                                                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                waitDuration: const Duration(seconds: 1),
                                                                                                child: MaterialButton(
                                                                                                  onPressed: () {
                                                                                                    //mainName
                                                                                                    final mainNames = sortedModsList[index][4].split('|');
                                                                                                    int curMainIndex = mainNames.indexOf(sortedModsList[index][4].split('|')[ex]);
                                                                                                    if (!sortedModsList[index][4].split('|')[ex].contains(':[TOREMOVE]')) {
                                                                                                      mainNames[curMainIndex] = sortedModsList[index][4].split('|')[ex] += ':[TOREMOVE]';
                                                                                                    }
                                                                                                    sortedModsList[index][4] = mainNames.join('|');
                                                                                                    //subName
                                                                                                    final subNames = sortedModsList[index][5].split('|');
                                                                                                    String subTemp = '';
                                                                                                    for (int i = 0; i < subNames.length; i++) {
                                                                                                      if (subTemp.isEmpty) {
                                                                                                        if (subNames[i].split(':').first == sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                          subTemp = subNames[i] += ':[TOREMOVE]';
                                                                                                        } else {
                                                                                                          subTemp = subNames[i];
                                                                                                        }
                                                                                                      } else {
                                                                                                        if (subNames[i].split(':').first == sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                          subTemp += '|${subNames[i]}:[TOREMOVE]';
                                                                                                        } else {
                                                                                                          subTemp += '|${subNames[i]}';
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                    sortedModsList[index][5] = subTemp;

                                                                                                    //check mains to disable or able the whole item if all main disabled
                                                                                                    bool allMainRemoving = true;
                                                                                                    for (var element in sortedModsList[index][4].split('|')) {
                                                                                                      if (element.split(':').last != '[TOREMOVE]') {
                                                                                                        allMainRemoving = false;
                                                                                                        break;
                                                                                                      }
                                                                                                    }
                                                                                                    if (allMainRemoving) {
                                                                                                      sortedModsList[index][1] = sortedModsList[index][1] += ':[TOREMOVE]';
                                                                                                      sortedModsList[index][2] = sortedModsList[index][2] += ':[TOREMOVE]';
                                                                                                      //print(sortedModsList[index][4]);
                                                                                                    }
                                                                                                    //print(sortedModsList[index]);
                                                                                                    setState(
                                                                                                      () {},
                                                                                                    );
                                                                                                  },
                                                                                                  child: const Icon(
                                                                                                    Icons.check_box_outlined,
                                                                                                    color: Colors.green,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          if (sortedModsList[index][4].split('|')[ex].split(':').last == '[TOREMOVE]')
                                                                                            SizedBox(
                                                                                              width: 40,
                                                                                              child: Tooltip(
                                                                                                message: curLangText!.uiMarkThisToBeAdded,
                                                                                                height: 25,
                                                                                                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                waitDuration: const Duration(seconds: 1),
                                                                                                child: MaterialButton(
                                                                                                  onPressed: () {
                                                                                                    sortedModsList[index][1] = sortedModsList[index][1].replaceAll(':[TOREMOVE]', '');
                                                                                                    sortedModsList[index][2] = sortedModsList[index][2].replaceAll(':[TOREMOVE]', '');
                                                                                                    //mainName
                                                                                                    final mainNames = sortedModsList[index][4].split('|');
                                                                                                    int curMainIndex = mainNames.indexOf(sortedModsList[index][4].split('|')[ex]);
                                                                                                    if (sortedModsList[index][4].split('|')[ex].contains(':[TOREMOVE]')) {
                                                                                                      mainNames[curMainIndex] = sortedModsList[index][4].split('|')[ex].replaceAll(':[TOREMOVE]', '');
                                                                                                    }
                                                                                                    sortedModsList[index][4] = mainNames.join('|');
                                                                                                    sortedModsList[index][5] = sortedModsList[index][5].replaceAll(':[TOREMOVE]', '');
                                                                                                    //print(sortedModsList[index]);
                                                                                                    setState(
                                                                                                      () {},
                                                                                                    );
                                                                                                  },
                                                                                                  child: const Icon(
                                                                                                    Icons.check_box_outline_blank_outlined,
                                                                                                    color: Colors.red,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                        ],
                                                                                      ),
                                                                                children: [
                                                                                  //if has subfolders
                                                                                  for (int sub = 0; sub < sortedModsList[index][5].split('|').length; sub++)
                                                                                    if (sortedModsList[index][5].split('|')[sub] != '' &&
                                                                                        sortedModsList[index][5].split('|')[sub].split(':').first ==
                                                                                            sortedModsList[index][4].split('|')[ex].split(':').first)
                                                                                      ExpansionTile(
                                                                                        initiallyExpanded: false,
                                                                                        childrenPadding: const EdgeInsets.only(left: 20),
                                                                                        textColor: MyApp.themeNotifier.value == ThemeMode.light
                                                                                            ? Theme.of(context).primaryColor
                                                                                            : Theme.of(context).iconTheme.color,
                                                                                        iconColor: MyApp.themeNotifier.value == ThemeMode.light
                                                                                            ? Theme.of(context).primaryColor
                                                                                            : Theme.of(context).iconTheme.color,
                                                                                        collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light
                                                                                            ? Theme.of(context).primaryColor
                                                                                            : Theme.of(context).iconTheme.color,
                                                                                        //Edit Sub Name
                                                                                        title: _subFoldersRenameIndex[index][sub]
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    child: SizedBox(
                                                                                                      height: context.watch<StateProvider>().itemAdderSubItemETHeight,
                                                                                                      child: Form(
                                                                                                        key: _subItemFormValidate,
                                                                                                        child: TextFormField(
                                                                                                          autofocus: true,
                                                                                                          controller: renameTextBoxController,
                                                                                                          maxLines: 1,
                                                                                                          maxLength: 50,
                                                                                                          decoration: InputDecoration(
                                                                                                            contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                                            border: const OutlineInputBorder(),
                                                                                                            hintText: sortedModsList[index][5].split('|')[sub].split(':')[1],
                                                                                                            counterText: '',
                                                                                                          ),
                                                                                                          inputFormatters: <TextInputFormatter>[
                                                                                                            FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))
                                                                                                          ],
                                                                                                          validator: (value) {
                                                                                                            if (value == null || value.isEmpty) {
                                                                                                              Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                              return curLangText!.uiNameCannotBeEmpty;
                                                                                                            }
                                                                                                            final List<String> subDirList = sortedModsList[index][5]
                                                                                                                .split('|')
                                                                                                                .where((element) =>
                                                                                                                    element.split(':')[1] != sortedModsList[index][5].split('|')[sub].split(':')[1])
                                                                                                                .toList();
                                                                                                            List<String> subDirNames = [];
                                                                                                            for (var name in subDirList) {
                                                                                                              subDirNames.add(name.split(':')[1]);
                                                                                                            }

                                                                                                            for (var name in subDirNames) {
                                                                                                              if (name.toLowerCase() == value.toLowerCase()) {
                                                                                                                Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                                return curLangText!.uiNameAlreadyExisted;
                                                                                                              }
                                                                                                            }

                                                                                                            return null;
                                                                                                          },
                                                                                                          onEditingComplete: (() {
                                                                                                            if (_subItemFormValidate.currentState!.validate()) {
                                                                                                              if (renameTextBoxController.text.isNotEmpty) {
                                                                                                                String mainDirName = sortedModsList[index][5].split('|')[sub].split(':').first;
                                                                                                                String oldSubDirName = sortedModsList[index][5].split('|')[sub].split(':')[1];
                                                                                                                // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                                //     '$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                                List<FileSystemEntity> curFilesInSubDir = Directory(Uri.file(
                                                                                                                            '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName')
                                                                                                                        .toFilePath())
                                                                                                                    .listSync(recursive: true);
                                                                                                                for (var element in curFilesInSubDir) {
                                                                                                                  //print(curFilesInMainDir);
                                                                                                                  String newMainPath = element.path.replaceFirst(
                                                                                                                      Uri.file(
                                                                                                                              '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                          .toFilePath(),
                                                                                                                      Uri.file(
                                                                                                                              '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                          .toFilePath());
                                                                                                                  if (!File(element.path).existsSync()) {
                                                                                                                    Directory(newMainPath).createSync(recursive: true);
                                                                                                                  } else {
                                                                                                                    Directory(File(newMainPath).parent.path).createSync(recursive: true);
                                                                                                                  }
                                                                                                                }
                                                                                                                for (var element in curFilesInSubDir) {
                                                                                                                  String newMainPath = element.path.replaceFirst(
                                                                                                                      Uri.file(
                                                                                                                              '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                          .toFilePath(),
                                                                                                                      Uri.file(
                                                                                                                              '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                          .toFilePath());
                                                                                                                  if (File(element.path).existsSync()) {
                                                                                                                    File(element.path).copySync(newMainPath);
                                                                                                                  }
                                                                                                                }

                                                                                                                //List
                                                                                                                List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                                subDirsString[subDirsString.indexOf('$mainDirName:$oldSubDirName')] =
                                                                                                                    '$mainDirName:${renameTextBoxController.text}';
                                                                                                                sortedModsList[index][5] = subDirsString.join('|');

                                                                                                                List<String> subDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                                for (var element in subDirsInItemString) {
                                                                                                                  List<String> split = element.split((':'));
                                                                                                                  if (split.indexWhere((element) => element == oldSubDirName) != -1) {
                                                                                                                    split[split.indexOf(oldSubDirName)] = renameTextBoxController.text;
                                                                                                                    subDirsInItemString[subDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                                  }
                                                                                                                }
                                                                                                                sortedModsList[index][6] = subDirsInItemString.join('|');
                                                                                                              }

                                                                                                              //Clear
                                                                                                              Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                              _subFoldersRenameIndex[index][sub] = false;
                                                                                                              renameTextBoxController.clear();
                                                                                                              _isNameEditing = false;
                                                                                                              setState(
                                                                                                                () {},
                                                                                                              );
                                                                                                            }
                                                                                                          }),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 5,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 40,
                                                                                                    child: MaterialButton(
                                                                                                      onPressed: () {
                                                                                                        if (_subItemFormValidate.currentState!.validate()) {
                                                                                                          if (renameTextBoxController.text.isNotEmpty) {
                                                                                                            String mainDirName = sortedModsList[index][5].split('|')[sub].split(':').first;
                                                                                                            String oldSubDirName = sortedModsList[index][5].split('|')[sub].split(':')[1];
                                                                                                            // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                            //     '$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                            List<FileSystemEntity> curFilesInSubDir = Directory(Uri.file(
                                                                                                                        '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName')
                                                                                                                    .toFilePath())
                                                                                                                .listSync(recursive: true);
                                                                                                            for (var element in curFilesInSubDir) {
                                                                                                              //print(curFilesInMainDir);
                                                                                                              String newMainPath = element.path.replaceFirst(
                                                                                                                  Uri.file(
                                                                                                                          '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                      .toFilePath(),
                                                                                                                  Uri.file(
                                                                                                                          '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                      .toFilePath());
                                                                                                              if (!File(element.path).existsSync()) {
                                                                                                                Directory(newMainPath).createSync(recursive: true);
                                                                                                              } else {
                                                                                                                Directory(File(newMainPath).parent.path).createSync(recursive: true);
                                                                                                              }
                                                                                                            }
                                                                                                            for (var element in curFilesInSubDir) {
                                                                                                              String newMainPath = element.path.replaceFirst(
                                                                                                                  Uri.file(
                                                                                                                          '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                      .toFilePath(),
                                                                                                                  Uri.file(
                                                                                                                          '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                      .toFilePath());
                                                                                                              if (File(element.path).existsSync()) {
                                                                                                                File(element.path).copySync(newMainPath);
                                                                                                              }
                                                                                                            }

                                                                                                            //List
                                                                                                            List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                            subDirsString[subDirsString.indexOf('$mainDirName:$oldSubDirName')] =
                                                                                                                '$mainDirName:${renameTextBoxController.text}';
                                                                                                            sortedModsList[index][5] = subDirsString.join('|');

                                                                                                            List<String> subDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                            for (var element in subDirsInItemString) {
                                                                                                              List<String> split = element.split((':'));
                                                                                                              if (split.indexWhere((element) => element == oldSubDirName) != -1) {
                                                                                                                split[split.indexOf(oldSubDirName)] = renameTextBoxController.text;
                                                                                                                subDirsInItemString[subDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                              }
                                                                                                            }
                                                                                                            sortedModsList[index][6] = subDirsInItemString.join('|');
                                                                                                          }

                                                                                                          //Clear
                                                                                                          _subFoldersRenameIndex[index][sub] = false;
                                                                                                          renameTextBoxController.clear();
                                                                                                          _isNameEditing = false;
                                                                                                          Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                          setState(
                                                                                                            () {},
                                                                                                          );
                                                                                                        }
                                                                                                      },
                                                                                                      child: const Icon(Icons.check),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            : Row(
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    child: Text(sortedModsList[index][5].split('|')[sub].split(':')[1],
                                                                                                        style: TextStyle(
                                                                                                            fontWeight: FontWeight.w400,
                                                                                                            color: sortedModsList[index][5].split('|')[sub].split(':').last == '[TOREMOVE]'
                                                                                                                ? Theme.of(context).disabledColor
                                                                                                                : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 5,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 40,
                                                                                                    child: Tooltip(
                                                                                                      message: curLangText!.uiEditName,
                                                                                                      height: 25,
                                                                                                      textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                      waitDuration: const Duration(seconds: 1),
                                                                                                      child: MaterialButton(
                                                                                                        onPressed: !_isNameEditing &&
                                                                                                                sortedModsList[index][5].split('|')[sub].split(':').last != '[TOREMOVE]'
                                                                                                            ? () {
                                                                                                                renameTextBoxController.text = sortedModsList[index][5].split('|')[sub].split(':')[1];
                                                                                                                renameTextBoxController.selection = TextSelection(
                                                                                                                  baseOffset: 0,
                                                                                                                  extentOffset: renameTextBoxController.text.length,
                                                                                                                );
                                                                                                                _subFoldersRenameIndex[index][sub] = true;
                                                                                                                _isNameEditing = true;
                                                                                                                setState(
                                                                                                                  () {},
                                                                                                                );
                                                                                                              }
                                                                                                            : null,
                                                                                                        child: const Icon(Icons.edit),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 5,
                                                                                                  ),
                                                                                                  if (sortedModsList[index][5].split('|')[sub].split(':').last != '[TOREMOVE]')
                                                                                                    SizedBox(
                                                                                                      width: 40,
                                                                                                      child: Tooltip(
                                                                                                        message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                                        height: 25,
                                                                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                        waitDuration: const Duration(seconds: 1),
                                                                                                        child: MaterialButton(
                                                                                                          onPressed: () {
                                                                                                            final subNames = sortedModsList[index][5].split('|');
                                                                                                            String subTemp = '';
                                                                                                            for (int i = 0; i < subNames.length; i++) {
                                                                                                              if (subTemp.isEmpty) {
                                                                                                                if (subNames[i].split(':').first ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                                    subNames[i].split(':')[1] ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                                  subTemp = subNames[i] += ':[TOREMOVE]';
                                                                                                                } else {
                                                                                                                  subTemp = subNames[i];
                                                                                                                }
                                                                                                              } else {
                                                                                                                if (subNames[i].split(':').first ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                                    subNames[i].split(':')[1] ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                                  subTemp += '|${subNames[i]}:[TOREMOVE]';
                                                                                                                } else {
                                                                                                                  subTemp += '|${subNames[i]}';
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            sortedModsList[index][5] = subTemp;
                                                                                                            //print(sortedModsList[index][5]);

                                                                                                            //check sub to disable or able main if all or one disabled
                                                                                                            bool allSubRemoving = true;
                                                                                                            for (var element in sortedModsList[index][5].split('|')) {
                                                                                                              if (sortedModsList[index][5].split('|').length > 1) {
                                                                                                                if (element.split(':').first ==
                                                                                                                            sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                                        element.split(':').last != '[TOREMOVE]' ||
                                                                                                                    sortedModsList[index][6].contains('${sortedModsList[index][4]}::')) {
                                                                                                                  allSubRemoving = false;
                                                                                                                  break;
                                                                                                                }
                                                                                                              } else {
                                                                                                                if (element.split(':').first == sortedModsList[index][5].split('|')[0].split(':')[0] &&
                                                                                                                        element.split(':').last != '[TOREMOVE]' ||
                                                                                                                    sortedModsList[index][6].contains('${sortedModsList[index][4]}::')) {
                                                                                                                  allSubRemoving = false;
                                                                                                                  break;
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            if (allSubRemoving) {
                                                                                                              String mainTemp = '';
                                                                                                              for (var element in sortedModsList[index][4].split('|')) {
                                                                                                                if (element.split(':').first ==
                                                                                                                    sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                                  if (mainTemp.isEmpty) {
                                                                                                                    mainTemp = '${element.split(':').first}:[TOREMOVE]';
                                                                                                                  } else {
                                                                                                                    mainTemp += '|${element.split(':').first}:[TOREMOVE]';
                                                                                                                  }
                                                                                                                } else {
                                                                                                                  if (mainTemp.isEmpty) {
                                                                                                                    mainTemp = element;
                                                                                                                  } else {
                                                                                                                    mainTemp += '|$element';
                                                                                                                  }
                                                                                                                }
                                                                                                              }
                                                                                                              sortedModsList[index][4] = mainTemp;
                                                                                                              //print(sortedModsList[index][4]);
                                                                                                            }

                                                                                                            //check mains to disable or able the whole item if all main disabled
                                                                                                            bool allMainRemoving = true;
                                                                                                            for (var element in sortedModsList[index][4].split('|')) {
                                                                                                              if (element.split(':').last != '[TOREMOVE]') {
                                                                                                                allMainRemoving = false;
                                                                                                                break;
                                                                                                              }
                                                                                                            }
                                                                                                            if (allMainRemoving) {
                                                                                                              sortedModsList[index][1] = sortedModsList[index][1] += ':[TOREMOVE]';
                                                                                                              sortedModsList[index][2] = sortedModsList[index][2] += ':[TOREMOVE]';
                                                                                                              //print(sortedModsList[index][4]);
                                                                                                            }
                                                                                                            //print(sortedModsList[index]);
                                                                                                            setState(
                                                                                                              () {},
                                                                                                            );
                                                                                                          },
                                                                                                          child: const Icon(
                                                                                                            Icons.check_box_outlined,
                                                                                                            color: Colors.green,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  if (sortedModsList[index][5].split('|')[sub].split(':').last == '[TOREMOVE]')
                                                                                                    SizedBox(
                                                                                                      width: 40,
                                                                                                      child: Tooltip(
                                                                                                        message: curLangText!.uiMarkThisToBeAdded,
                                                                                                        height: 25,
                                                                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                        waitDuration: const Duration(seconds: 1),
                                                                                                        child: MaterialButton(
                                                                                                          onPressed: () {
                                                                                                            sortedModsList[index][1] = sortedModsList[index][1].replaceAll(':[TOREMOVE]', '');
                                                                                                            sortedModsList[index][2] = sortedModsList[index][2].replaceAll(':[TOREMOVE]', '');
                                                                                                            String mainTemp = '';
                                                                                                            for (var element in sortedModsList[index][4].split('|')) {
                                                                                                              if (element.split(':').first ==
                                                                                                                  sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                                if (mainTemp.isEmpty) {
                                                                                                                  mainTemp = element.split(':').first;
                                                                                                                } else {
                                                                                                                  mainTemp += '|${element.split(':').first}';
                                                                                                                }
                                                                                                              } else {
                                                                                                                if (mainTemp.isEmpty) {
                                                                                                                  mainTemp = element;
                                                                                                                } else {
                                                                                                                  mainTemp += '|$element';
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            sortedModsList[index][4] = mainTemp;
                                                                                                            //print(sortedModsList[index][4]);
                                                                                                            final subNames = sortedModsList[index][5].split('|');
                                                                                                            String subTemp = '';
                                                                                                            for (int i = 0; i < subNames.length; i++) {
                                                                                                              if (subTemp.isEmpty) {
                                                                                                                if (subNames[i].split(':').first ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                                    subNames[i].split(':')[1] ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                                  subTemp = subNames[i].replaceAll(':[TOREMOVE]', '');
                                                                                                                } else {
                                                                                                                  subTemp = subNames[i];
                                                                                                                }
                                                                                                              } else {
                                                                                                                if (subNames[i].split(':').first ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                                    subNames[i].split(':')[1] ==
                                                                                                                        sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                                  subTemp += '|${subNames[i].replaceAll(':[TOREMOVE]', '')}';
                                                                                                                } else {
                                                                                                                  subTemp += '|${subNames[i]}';
                                                                                                                }
                                                                                                              }
                                                                                                            }
                                                                                                            sortedModsList[index][5] = subTemp;
                                                                                                            //print(sortedModsList[index]);
                                                                                                            setState(
                                                                                                              () {},
                                                                                                            );
                                                                                                          },
                                                                                                          child: const Icon(
                                                                                                            Icons.check_box_outline_blank_outlined,
                                                                                                            color: Colors.red,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                ],
                                                                                              ),
                                                                                        children: [
                                                                                          for (int i = 0; i < sortedModsList[index][6].split('|').length; i++)
                                                                                            if (sortedModsList[index][6].split('|')[i].split(':')[0] ==
                                                                                                    sortedModsList[index][4].split('|')[ex].split(':').first &&
                                                                                                sortedModsList[index][6].split('|')[i].split(':')[1] ==
                                                                                                    sortedModsList[index][5].split('|')[sub].split(':')[1])
                                                                                              ListTile(
                                                                                                title: Text(
                                                                                                  sortedModsList[index][6].split('|')[i].split(':').last,
                                                                                                  style: TextStyle(
                                                                                                      color: sortedModsList[index][5].split('|')[sub].split(':').last == '[TOREMOVE]'
                                                                                                          ? Theme.of(context).disabledColor
                                                                                                          : null),
                                                                                                ),
                                                                                              )
                                                                                        ],
                                                                                      ),
                                                                                  //if has no subfolders
                                                                                  for (int i = 0; i < sortedModsList[index][6].split('|').length; i++)
                                                                                    if (sortedModsList[index][6].split('|')[i].split(':')[0] ==
                                                                                            sortedModsList[index][4].split('|')[ex].split(':').first &&
                                                                                        sortedModsList[index][6].split('|')[i].split(':')[1] == '')
                                                                                      ListTile(
                                                                                        title: Padding(
                                                                                          padding: const EdgeInsets.only(left: 0),
                                                                                          child: Text(sortedModsList[index][6].split('|')[i].split(':').last,
                                                                                              style: TextStyle(
                                                                                                  color: sortedModsList[index][4].split('|')[ex].split(':').last == '[TOREMOVE]'
                                                                                                      ? Theme.of(context).disabledColor
                                                                                                      : null)),
                                                                                        ),
                                                                                      )
                                                                                ],
                                                                              )
                                                                          ],
                                                                        ),
                                                                      );
                                                                    })),
                                                          );
                                                        }
                                                      }
                                                    }),
                                              ),
                                            ),
                                            if (_exitConfirmDialog)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 5),
                                                child: Container(
                                                  constraints: BoxConstraints(maxHeight: constraints.maxHeight - 200),
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                      color: Theme.of(context).dialogBackgroundColor),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(5.0),
                                                          child: Center(
                                                              child: _duplicateModNames.isNotEmpty
                                                                  ? Text(
                                                                      '${curLangText!.uiRename} $_duplicateModNames ${curLangText!.uiBeforeAdding}',
                                                                      textAlign: TextAlign.center,
                                                                    )
                                                                  : Text(
                                                                      curLangText!.uiThereAreStillModsThatWaitingToBeAdded,
                                                                      textAlign: TextAlign.center,
                                                                    )),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 5),
                                                          child: ElevatedButton(
                                                            child: Text(curLangText!.uiReturn),
                                                            onPressed: () {
                                                              _exitConfirmDialog = false;
                                                              _duplicateModNames.clear();
                                                              setState(
                                                                () {},
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (_isAddedSuccess)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 5),
                                                child: Container(
                                                    width: constraints.maxWidth,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Colors.green,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        curLangText!.uiModsAddedSuccessfully,
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    )),
                                              ),
                                          ],
                                        ),
                                        SizedBox(
                                          //width: constraints.maxWidth * 0.45,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 5, bottom: 4, right: 5),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Visibility(
                                                  visible: !dropZoneMax,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 5),
                                                    child: ElevatedButton(
                                                        onPressed: sortedModsList.isNotEmpty || context.watch<StateProvider>().modAdderReload
                                                            ? (() {
                                                                Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                  element.deleteSync(recursive: true);
                                                                });
                                                                Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
                                                                  element.deleteSync(recursive: true);
                                                                });
                                                                _mainFolderRenameIndex.clear();
                                                                _newModMainFolderList.clear();
                                                                _selectedCategories.clear();
                                                                _exitConfirmDialog = false;
                                                                Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                                _duplicateModNames.clear();
                                                                sortedModsList.clear();
                                                                _newModDragDropList.clear();
                                                                modsToAddList.clear();
                                                                _isNameEditing = false;
                                                                dropZoneMax = true;
                                                                setState(
                                                                  () {},
                                                                );
                                                              })
                                                            : null,
                                                        child: Text(curLangText!.uiClearAll)),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: (() async {
                                                        if (_exitConfirmDialog) {
                                                          Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                            element.deleteSync(recursive: true);
                                                          });
                                                          Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
                                                            element.deleteSync(recursive: true);
                                                          });

                                                          _mainFolderRenameIndex.clear();
                                                          _newModMainFolderList.clear();
                                                          _selectedCategories.clear();
                                                          Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                          _exitConfirmDialog = false;
                                                          _duplicateModNames.clear();
                                                          itemRefSheetsList.clear();
                                                          sortedModsList.clear();
                                                          _newModDragDropList.clear();
                                                          modsToAddList.clear();
                                                          setState(
                                                            () {},
                                                          );
                                                          dropZoneMax = true;
                                                          Navigator.of(context).pop();
                                                        } else if (sortedModsList.isNotEmpty || modsToAddList.isNotEmpty || _newModDragDropList.isNotEmpty) {
                                                          _exitConfirmDialog = true;
                                                          setState(
                                                            () {},
                                                          );
                                                        } else {
                                                          //clear lists
                                                          _mainFolderRenameIndex.clear();
                                                          _newModMainFolderList.clear();
                                                          Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                          _selectedCategories.clear();
                                                          itemRefSheetsList.clear();
                                                          sortedModsList.clear();
                                                          _newModDragDropList.clear();
                                                          modsToAddList.clear();
                                                          setState(
                                                            () {},
                                                          );
                                                          dropZoneMax = true;
                                                          Navigator.of(context).pop();
                                                        }
                                                      }),
                                                      child: Text(curLangText!.uiClose)),
                                                ),
                                                Visibility(
                                                  visible: !dropZoneMax,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary.withBlue(150)),
                                                        onPressed: sortedModsList.isNotEmpty && !_isNameEditing || context.watch<StateProvider>().modAdderReload && !_isNameEditing
                                                            ? (() async {
                                                                //Remove 'TOREMOVE' lines from list
                                                                List<List<String>> removingItems = [];
                                                                for (var line in sortedModsList) {
                                                                  if (line[1].split(':').last != '[TOREMOVE]' && line[2].split(':').last != '[TOREMOVE]') {
                                                                    List<String> mainLine = [];
                                                                    for (var main in line[4].split('|')) {
                                                                      if (main.split(':').last != '[TOREMOVE]') {
                                                                        mainLine.add(main);
                                                                      }
                                                                    }
                                                                    line[4] = mainLine.join('|');

                                                                    List<String> subLine = [];
                                                                    for (var sub in line[5].split('|')) {
                                                                      if (sub.split(':').last != '[TOREMOVE]') {
                                                                        subLine.add(sub);
                                                                      }
                                                                    }
                                                                    line[5] = subLine.join('|');
                                                                  } else {
                                                                    removingItems.add(line);
                                                                  }
                                                                }
                                                                for (var item in removingItems) {
                                                                  sortedModsList.remove(item);
                                                                }
                                                                //print(sortedModsList);

                                                                //Check for dub mods
                                                                _duplicateModNames.clear();
                                                                for (var sortedLine in sortedModsList) {
                                                                  String category = sortedLine[0];
                                                                  String itemName = '';
                                                                  if (curActiveLang == 'JP') {
                                                                    itemName = sortedLine[1];
                                                                  } else {
                                                                    itemName = sortedLine[2];
                                                                  }
                                                                  List<String> mainNames = sortedLine[4].split('|');

                                                                  if (Directory(Uri.file('$modManModsDirPath/$category/$itemName').toFilePath()).existsSync()) {
                                                                    if (Directory(Uri.file('$modManModsDirPath/$category/$itemName').toFilePath())
                                                                            .listSync(recursive: false)
                                                                            .indexWhere((element) => mainNames.contains(p.basename(element.path))) !=
                                                                        -1) {
                                                                      for (var mainName in mainNames) {
                                                                        if (Directory(Uri.file('$modManModsDirPath/$category/$itemName').toFilePath())
                                                                                .listSync(recursive: false)
                                                                                .indexWhere((element) => p.basename(element.path) == mainName) !=
                                                                            -1) {
                                                                          _duplicateModNames.add(' "$mainName" in $itemName ');
                                                                        }
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                                //Add mods
                                                                if (_duplicateModNames.isEmpty) {
                                                                  modFilesAdder(context, sortedModsList).then((_) {
                                                                    //clear lists and delete temp
                                                                    _isAddedSuccess = true;
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                    _mainFolderRenameIndex.clear();
                                                                    _newModMainFolderList.clear();
                                                                    _selectedCategories.clear();
                                                                    _exitConfirmDialog = false;
                                                                    Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                                    //Provider.of<StateProvider>(context, listen: false).singleItemDropAddClear();
                                                                    _duplicateModNames.clear();
                                                                    sortedModsList.clear();
                                                                    _newModDragDropList.clear();
                                                                    modsToAddList.clear();
                                                                    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                      element.deleteSync(recursive: true);
                                                                    });
                                                                    Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
                                                                      element.deleteSync(recursive: true);
                                                                    });
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                    Future.delayed(const Duration(seconds: 1)).then((value) {
                                                                      _isAddedSuccess = false;
                                                                      dropZoneMax = true;
                                                                      setState(
                                                                        () {},
                                                                      );
                                                                    });
                                                                  });
                                                                } else {
                                                                  _exitConfirmDialog = true;
                                                                }
                                                                setState(
                                                                  () {},
                                                                );
                                                              })
                                                            : null,
                                                        child: Text(curLangText!.uiAddAll)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }
                          }
                        }),
                      );
                    }),
                  )));
        });
      });
}
