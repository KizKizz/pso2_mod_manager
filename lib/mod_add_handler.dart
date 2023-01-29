import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
// ignore: depend_on_referenced_packages
//import 'package:collection/collection.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';
import 'package:pso2_mod_manager/state_provider.dart';

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
List<bool> _mainFolderRenameIndex = [];
List<List<bool>> _subFoldersRenameIndex = [];
bool _isNameEditing = false;
bool _isAddedSuccess = false;
//bool processTrigger = false;
List<String> _nonSupportedFileNames = [];
//List<List<String>> _dropdownCategories = [];
List<String> _dropdownCategories = [];
List<String> _selectedCategories = [];

//Csv lists
List<String> _accessoriesCsv = ['Accessories.csv'];
List<String> _emoteCsv = ['LobbyActionsNGS_HandPoses.csv', 'LobbyActions.csv'];
List<String> _basewearCsv = ['GenderlessNGSBasewear.csv', 'FemaleNGSBasewear.csv', 'MaleNGSBasewear.csv', 'FemaleBasewear.csv', 'MaleBasewear.csv'];
List<String> _magsCsv = ['Mags.csv', 'MagsNGS.csv'];
List<String> _stickersCsv = ['Stickers.csv'];
List<String> _innerwearCsv = ['FemaleNGSInnerwear.csv', 'MaleNGSInnerwear.csv', 'MaleInnerwear.csv', 'FemaleInnerwear.csv'];
List<String> _outerwearCsv = ['FemaleNGSOuters.csv', 'MaleNGSOuters.csv', 'FemaleOuters.csv', 'MaleOuters.csv'];
List<String> _bodyPaintCsv = ['GenderlessNGSBodyPaint.csv', 'FemaleNGSBodyPaint.csv', 'MaleNGSBodyPaint.csv', 'FemaleBodyPaint.csv', 'MaleBodyPaint.csv'];
List<String> _facePaintCsv = ['FacePaintNGS.csv', 'FacePaint.csv'];
List<String> _hairCsv = ['CasealHair.csv', 'FemaleHair.csv', 'MaleHair.csv', 'AllHairNGS.csv'];
List<String> _castBodyCsv = ['CastBodies.csv', 'CasealBodies.csv', 'CastNGSBodies.csv', 'CasealNGSBodies.csv'];
List<String> _castArmCsv = ['CastArms.csv', 'CastArms.csv', 'CasealArmsNGS.csv', 'CastArmsNGS.csv'];
List<String> _castLegCsv = ['CasealLegs.csv', 'CastLegs.csv', 'CastLegsNGS.csv', 'CasealLegsNGS.csv'];
List<String> _eyeCsv = ['EyesNGS.csv', 'EyelashesNGS.csv', 'EyebrowsNGS.csv', 'Eyes.csv', 'Eyelashes.csv', 'Eyebrows.csv'];
List<String> _costumeCsv = ['FemaleCostumes.csv', 'MaleCostumes.csv'];
List<String> _motionCsv = [
  'SubstituteMotionGlide.csv',
  'SubstituteMotionJump.csv',
  'SubstituteMotionLanding.csv',
  'SubstituteMotionPhotonDash.csv',
  'SubstituteMotionRun.csv',
  'SubstituteMotionStandby.csv',
  'SubstituteMotionSwim.csv'
];

void modAddHandler(context) {
  Future<String> getIconPath(String iceName, String itemNameJP, String itemNameEN) async {
    if (iceFiles.indexWhere((element) => element.path.split(s).last == iceName) != -1) {
      XFile iconFile = XFile(iceFiles.firstWhere((element) => element.path.split(s).last == iceName).path);

      String itemName = '';
      if (curActiveLang == 'JP') {
        itemName = itemNameJP.replaceAll('/', '_');
        itemName = itemName.replaceAll(':', '_');
      } else {
        itemName = itemNameEN.replaceAll('/', '_');
        itemName = itemName.replaceAll(':', '_');
      }

      XFile ddsIcon = XFile('');
      await Process.run(zamboniExePath, [iconFile.path]).then((value) {
        if (Directory('${Directory.current.path}$s${iceName}_ext').existsSync()) {
          final files = Directory('${Directory.current.path}$s${iceName}_ext').listSync(recursive: true).whereType<File>();
          ddsIcon = XFile(files.firstWhere((element) => p.extension(element.path) == '.dds').path);
          if (ddsIcon.path.isNotEmpty) {
            final iconNewName = File(ddsIcon.path).renameSync(ddsIcon.path.replaceFirst(ddsIcon.name, '$itemName.dds'));
            ddsIcon = XFile(iconNewName.path);
          }
        }
      });

      if (ddsIcon.path.isNotEmpty) {
        await Process.run('${Directory.current.path}${s}ddstopngtool${s}DDStronk.exe', [ddsIcon.path]).then((value) {
          //processTrigger = true;
        });
        final newPath = File(XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).path)
            .copySync('$tempDirPath$s${XFile(ddsIcon.path.replaceRange(ddsIcon.path.lastIndexOf('.'), null, '.png')).name}');
        if (await newPath.exists()) {
          Directory('${Directory.current.path}$s${iceName}_ext').deleteSync(recursive: true);
        }
        //processTrigger = true;
        return newPath.path;
      }
    }

    //processTrigger = true;

    return '';
  }

  Future<List<String>> findItemInCsv(XFile inputFile) async {
    for (var file in itemRefSheetsList) {
      for (var line in file) {
        if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
          var lineSplit = line.split(',');
          //[0 Category, 1 JP name, 2 EN name, 3 icon]
          if (_emoteCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Emotes', lineSplit[1].replaceAll('/', '_'), lineSplit[2].replaceAll('/', '_'), '']);
          } else if (_basewearCsv.indexWhere((element) => element == file.first) != -1) {
            if (lineSplit[0].contains('[Ba]') || lineSplit[1].contains('[Ba]')) {
              return ([
                'Basewears',
                lineSplit[0].replaceAll('/', '_'),
                lineSplit[1].replaceAll('/', '_'),
                await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
              ]);
            } else if (lineSplit[0].contains('[Se]') || lineSplit[1].contains('[Se]')) {
              return ([
                'Setwears',
                lineSplit[0].replaceAll('/', '_'),
                lineSplit[1].replaceAll('/', '_'),
                await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
              ]);
            } else {
              return (['Misc', lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
            }
          } else if (_accessoriesCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Accessories',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[3], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_innerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Innerwears',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_outerwearCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Outerwears',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_bodyPaintCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Body Paints',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_magsCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Mags',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[3], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_stickersCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Stickers',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_facePaintCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Face Paints',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_hairCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Hairs',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_castBodyCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Cast Body Parts',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_castArmCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Cast Arm Parts',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_castLegCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Cast Leg Parts',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_eyeCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Eyes',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_costumeCsv.indexWhere((element) => file.first == element) != -1) {
            return ([
              'Costumes',
              lineSplit[0].replaceAll('/', '_'),
              lineSplit[1].replaceAll('/', '_'),
              await getIconPath(lineSplit[4], lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'))
            ]);
          } else if (_motionCsv.indexWhere((element) => file.first == element) != -1) {
            return (['Motions', lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
          } else {
            return ([file.first, lineSplit[0].replaceAll('/', '_'), lineSplit[1].replaceAll('/', '_'), '']);
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
        mainDirPaths.add('${Directory.current.path}${s}unpack$s$nameAfterExtract');
      } else if (_pathsToRemove.indexWhere((element) => element == file.name) != -1) {
        mainDirPaths.add(file.path.replaceFirst('$s${file.name}', ''));
      } else {
        mainDirPaths.add(file.path);
      }
    }

    //copy files to temp with new folder structures
    List<List<String>> extraFiles = [];
    //int unknownModsCounter = 1;
    for (var inputFile in inputFiles) {
      if (File(inputFile.path).existsSync() && !inputFile.path.contains(tempDirPath)) {
        for (var mainPath in mainDirPaths) {
          //Paths have main path and continue with /
          if (inputFile.path.contains('$mainPath$s')) {
            String mainDirName = mainPath.split(s).last;
            List<String> curPathSplit = inputFile.path.split(s);
            String subDirName = '';
            if (_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element)) != -1) {
              curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
              curPathSplit.removeRange(
                  curPathSplit.indexWhere((element) => element == _pathsToRemove[_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element))]), curPathSplit.length);
              subDirName = curPathSplit.join(' - ');
            } else {
              curPathSplit.removeRange(0, curPathSplit.indexOf(mainDirName) + 1);
              curPathSplit.remove(inputFile.name);
              subDirName = curPathSplit.join(' - ');
            }

            //moving files to temp with sorted paths
            if (!Directory('$tempDirPath$s$mainDirName$s$subDirName').existsSync()) {
              Directory('$tempDirPath$s$mainDirName$s$subDirName').createSync(recursive: true);
            }
            File(inputFile.path).copySync('$tempDirPath$s$mainDirName$s$subDirName$s${inputFile.name}');

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
                itemInfo.add(subDirName);
              } else {
                if (!itemInfo[5].split('|').contains(subDirName)) {
                  itemInfo[5] += '|$subDirName';
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
              extraFiles.add(['', '', '', '', mainDirName, subDirName, '$mainDirName:$subDirName:${inputFile.name}']);
            }

            //print('Sub: $subDirName');
          }
        }
      }
    }
    for (var extraFile in extraFiles) {
      for (var file in filesList) {
        if (file[4].split('|').contains(extraFile[4]) && file[5].split('|').contains(extraFile[5])) {
          file[6] += '|${extraFile[6]}';
        }
      }
    }

    Provider.of<StateProvider>(context, listen: false).modAdderReloadTrue();

    return filesList;
  }

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              contentPadding: const EdgeInsets.all(5),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height,
                  child: Scaffold(
                    body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      return FutureBuilder(
                        future: popSheetsList(refSheetsDirPath),
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
                                    curLangText!.preparingLabelText,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            );
                          }
                          if (snapshot.connectionState == ConnectionState.done) {
                            itemRefSheetsList = snapshot.data;
                          }
                          return Row(
                            children: [
                              RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'ADD MODS',
                                    style: TextStyle(
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 20,
                                        letterSpacing: constraints.maxHeight / 10),
                                  )),
                              VerticalDivider(
                                width: 10,
                                thickness: 2,
                                indent: 5,
                                endIndent: 5,
                                color: Theme.of(context).textTheme.bodySmall!.color,
                              ),
                              Column(
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
                                              width: constraints.maxWidth * 0.45,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (_newModDragDropList.isEmpty)
                                                    Center(
                                                        child: Text(
                                                      curLangText!.dragNdropBoxLabelText,
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
                                                                        child: Tooltip(
                                                                          message: curLangText!.removeBtnLabel,
                                                                          waitDuration: const Duration(seconds: 2),
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
                                          width: constraints.maxWidth * 0.45,
                                          //height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Center(
                                                    child: Text(
                                                  '$_nonSupportedFileNames ${curLangText!.errorFilesNotSupportedText}',
                                                  textAlign: TextAlign.center,
                                                )),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 5),
                                                child: ElevatedButton(
                                                  child: Text(curLangText!.closeBtnText),
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
                                    width: constraints.maxWidth * 0.45,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                                onPressed: _newModDragDropList.isNotEmpty
                                                    ? (() {
                                                        _newModDragDropList.clear();
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.clearAllBtnLabel)),
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
                                                            await extractFileToDisk(file.path, 'unpack$s${file.name.replaceAll('.zip', '')}', asyncWrite: true).then((_) => setState(
                                                                  () {
                                                                    for (var file in Directory('${Directory.current.path}${s}unpack').listSync(recursive: true)) {
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

                                                        //clear lists
                                                        sortedModsListLoad = fetchItemName(modsToAddList);
                                                        _newModDragDropList.clear();
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.progressBtnLabel)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
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
                                                            curLangText!.waitingForDataLabelText,
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
                                                              curLangText!.errorLoadingRestartApp,
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
                                                          children: const [
                                                            Text(
                                                              'Loading Data',
                                                              style: TextStyle(fontSize: 20),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            CircularProgressIndicator(),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      sortedModsList = snapshot.data;

                                                      if (_mainFolderRenameIndex.isEmpty) {
                                                        _itemNameRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                        _mainFolderRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                        _subFoldersRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                        for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                          _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                        }
                                                      } else if (_mainFolderRenameIndex.isNotEmpty && _mainFolderRenameIndex.length < sortedModsList.length) {
                                                        _mainFolderRenameIndex.clear();
                                                        _itemNameRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                        _mainFolderRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                        _subFoldersRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                        for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                          _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                        }
                                                      }
                                                      //get catelist
                                                      if (_dropdownCategories.isEmpty) {
                                                        for (var category in cateList) {
                                                          if (category.categoryName != 'Favorites') {
                                                            _dropdownCategories.add(category.categoryName);
                                                          }
                                                        }
                                                      } else if (dropdownCategories.isNotEmpty && _dropdownCategories.length < cateList.length) {
                                                        _dropdownCategories.clear();
                                                        for (var category in cateList) {
                                                          if (category.categoryName != 'Favorites') {
                                                            _dropdownCategories.add(category.categoryName);
                                                          }
                                                        }
                                                      }

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

                                                      return SingleChildScrollView(
                                                          controller: AdjustableScrollController(80),
                                                          child: ListView.builder(
                                                              shrinkWrap: true,
                                                              physics: const NeverScrollableScrollPhysics(),
                                                              itemCount: sortedModsList.length,
                                                              itemBuilder: (context, index) {
                                                                return Card(
                                                                  margin: const EdgeInsets.only(top: 0, bottom: 2, left: 0, right: 0),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                      side: BorderSide(
                                                                          width: 1,
                                                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight)),
                                                                  child: ExpansionTile(
                                                                    initiallyExpanded: true,
                                                                    leading: Padding(
                                                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                                                      child: Container(
                                                                        width: 44,
                                                                        height: 50,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(3),
                                                                          border: Border.all(color: Theme.of(context).hintColor),
                                                                        ),
                                                                        child: sortedModsList[index][3].isEmpty
                                                                            ? Image.asset('assets/img/placeholdersquare.png')
                                                                            : Image.file(File(sortedModsList[index][3])),
                                                                      ),
                                                                    ),
                                                                    //Edit Item's name
                                                                    title: _itemNameRenameIndex[index]
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
                                                                                    decoration: InputDecoration(
                                                                                      contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                      border: const OutlineInputBorder(),
                                                                                      hintText: curActiveLang == 'JP' ? sortedModsList[index][1] : sortedModsList[index][2],
                                                                                    ),
                                                                                    onEditingComplete: () {
                                                                                      if (renameTextBoxController.text.isNotEmpty) {
                                                                                        String newItemName = renameTextBoxController.text.trim();
                                                                                        if (sortedModsList[index][0] == 'Basewears') {
                                                                                          newItemName += ' [Ba]';
                                                                                        } else if (sortedModsList[index][0] == 'Innerwears') {
                                                                                          newItemName += ' [In]';
                                                                                        } else if (sortedModsList[index][0] == 'Outerwears') {
                                                                                          newItemName += ' [Ou]';
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
                                                                                      if (sortedModsList[index][0] == 'Basewears') {
                                                                                        newItemName += ' [Ba]';
                                                                                      } else if (sortedModsList[index][0] == 'Innerwears') {
                                                                                        newItemName += ' [In]';
                                                                                      } else if (sortedModsList[index][0] == 'Outerwears') {
                                                                                        newItemName += ' [Ou]';
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
                                                                              if (sortedModsList[index][0] == 'Misc')
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 5),
                                                                                  child: CustomDropdownButton2(
                                                                                    hint: curLangText!.addSelectCatLabelText,
                                                                                    dropdownDecoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(3),
                                                                                      color:
                                                                                          MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                                                                    ),
                                                                                    buttonDecoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(3),
                                                                                      border: Border.all(color: Theme.of(context).hintColor),
                                                                                    ),
                                                                                    buttonWidth: 150,
                                                                                    buttonHeight: 43,
                                                                                    itemHeight: 40,
                                                                                    dropdownElevation: 3,
                                                                                    icon: const Icon(Icons.arrow_drop_down),
                                                                                    iconSize: 30,
                                                                                    //dropdownWidth: 361,
                                                                                    dropdownHeight: constraints.maxHeight * 0.5,
                                                                                    dropdownItems: _dropdownCategories,
                                                                                    value: _selectedCategories[index],
                                                                                    onChanged: (value) {
                                                                                      setState(() {
                                                                                        _selectedCategories[index] = value.toString();
                                                                                        sortedModsList[index][0] = value.toString();
                                                                                      });
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              Expanded(
                                                                                child: curActiveLang == 'JP'
                                                                                    ? sortedModsList[index][0] == 'Misc'
                                                                                        ? Text(' > ${sortedModsList[index][1]}',
                                                                                            style: const TextStyle(
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ))
                                                                                        : Text('${sortedModsList[index].first} > ${sortedModsList[index][1]}',
                                                                                            style: const TextStyle(
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ))
                                                                                    : sortedModsList[index][0] == 'Misc'
                                                                                        ? Text(' > ${sortedModsList[index][2]}',
                                                                                            style: const TextStyle(
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ))
                                                                                        : Text('${sortedModsList[index].first} > ${sortedModsList[index][2]}',
                                                                                            style: const TextStyle(
                                                                                              fontWeight: FontWeight.w600,
                                                                                            )),
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 40,
                                                                                child: Tooltip(
                                                                                  message: curLangText!.editTooltipText,
                                                                                  waitDuration: const Duration(seconds: 1),
                                                                                  child: MaterialButton(
                                                                                    onPressed: !_isNameEditing
                                                                                        ? () {
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
                                                                            ],
                                                                          ),

                                                                    textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                    iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                    collapsedTextColor:
                                                                        MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                    childrenPadding: const EdgeInsets.only(left: 10),
                                                                    children: [
                                                                      for (int ex = 0; ex < sortedModsList[index][4].split('|').length; ex++)
                                                                        ExpansionTile(
                                                                          initiallyExpanded: true,
                                                                          childrenPadding: const EdgeInsets.only(left: 5),
                                                                          textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          collapsedTextColor:
                                                                              MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          //Edit Name
                                                                          title: _mainFolderRenameIndex[index]
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
                                                                                          decoration: InputDecoration(
                                                                                            contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                            border: const OutlineInputBorder(),
                                                                                            hintText: sortedModsList[index][4].split('|')[ex],
                                                                                          ),
                                                                                          onEditingComplete: () {
                                                                                            if (renameTextBoxController.text.isNotEmpty) {
                                                                                              String oldMainDirName = sortedModsList[index][3].split('|')[ex];
                                                                                              // Directory('$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                              //     .renameSync('$tempDirPath$s${renameTextBoxController.text}');
                                                                                              List<FileSystemEntity> curFilesInMainDir =
                                                                                                  Directory('$tempDirPath$s$oldMainDirName').listSync(recursive: true);
                                                                                              for (var element in curFilesInMainDir) {
                                                                                                //print(curFilesInMainDir);
                                                                                                String newMainPath = element.path
                                                                                                    .replaceFirst('$tempDirPath$s$oldMainDirName$s', '$tempDirPath$s${renameTextBoxController.text}$s');
                                                                                                if (!File(element.path).existsSync()) {
                                                                                                  Directory(newMainPath).createSync(recursive: true);
                                                                                                }
                                                                                                if (sortedModsList[index][5].isEmpty) {
                                                                                                  Directory('$tempDirPath$s${renameTextBoxController.text}').createSync(recursive: true);
                                                                                                }
                                                                                              }
                                                                                              for (var element in curFilesInMainDir) {
                                                                                                String newMainPath = element.path
                                                                                                    .replaceFirst('$tempDirPath$s$oldMainDirName$s', '$tempDirPath$s${renameTextBoxController.text}$s');
                                                                                                if (File(element.path).existsSync()) {
                                                                                                  File(element.path).copySync(newMainPath);
                                                                                                }
                                                                                              }

                                                                                              //Itemlist
                                                                                              List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                              mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                              sortedModsList[index][4] = mainDirsString.join('|');

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
                                                                                            _mainFolderRenameIndex[index] = false;
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
                                                                                            // Directory('$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                            //     .renameSync('$tempDirPath$s${renameTextBoxController.text}');
                                                                                            List<FileSystemEntity> curFilesInMainDir =
                                                                                                Directory('$tempDirPath$s$oldMainDirName').listSync(recursive: true);
                                                                                            for (var element in curFilesInMainDir) {
                                                                                              //print(curFilesInMainDir);
                                                                                              String newMainPath = element.path
                                                                                                  .replaceFirst('$tempDirPath$s$oldMainDirName$s', '$tempDirPath$s${renameTextBoxController.text}$s');
                                                                                              if (!File(element.path).existsSync()) {
                                                                                                Directory(newMainPath).createSync(recursive: true);
                                                                                              }
                                                                                              if (sortedModsList[index][5].isEmpty) {
                                                                                                Directory('$tempDirPath$s${renameTextBoxController.text}').createSync(recursive: true);
                                                                                              }
                                                                                            }
                                                                                            for (var element in curFilesInMainDir) {
                                                                                              String newMainPath = element.path
                                                                                                  .replaceFirst('$tempDirPath$s$oldMainDirName$s', '$tempDirPath$s${renameTextBoxController.text}$s');
                                                                                              if (File(element.path).existsSync()) {
                                                                                                File(element.path).copySync(newMainPath);
                                                                                              }
                                                                                            }

                                                                                            //Itemlist
                                                                                            List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                            mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                            sortedModsList[index][4] = mainDirsString.join('|');

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
                                                                                          _mainFolderRenameIndex[index] = false;
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
                                                                                      child: Text(sortedModsList[index][4].split('|')[ex],
                                                                                          style: const TextStyle(
                                                                                            fontWeight: FontWeight.w500,
                                                                                          )),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 40,
                                                                                      child: Tooltip(
                                                                                        waitDuration: const Duration(seconds: 1),
                                                                                        message: curLangText!.editTooltipText,
                                                                                        child: MaterialButton(
                                                                                          onPressed: !_isNameEditing
                                                                                              ? () {
                                                                                                  _isNameEditing = true;
                                                                                                  _mainFolderRenameIndex[index] = true;
                                                                                                  setState(
                                                                                                    () {},
                                                                                                  );
                                                                                                }
                                                                                              : null,
                                                                                          child: const Icon(Icons.edit),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                          children: [
                                                                            //if has subfolders
                                                                            for (int sub = 0; sub < sortedModsList[index][5].split('|').length; sub++)
                                                                              if (sortedModsList[index][5].split('|')[sub] != '')
                                                                                ExpansionTile(
                                                                                  initiallyExpanded: false,
                                                                                  childrenPadding: const EdgeInsets.only(left: 10),
                                                                                  textColor:
                                                                                      MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                  iconColor:
                                                                                      MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                  collapsedTextColor:
                                                                                      MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                                  //Edit Sub Name
                                                                                  title: _subFoldersRenameIndex[index][sub]
                                                                                      ? Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: SizedBox(
                                                                                                height: 40,
                                                                                                child: TextFormField(
                                                                                                  autofocus: true,
                                                                                                  controller: renameTextBoxController,
                                                                                                  maxLines: 1,
                                                                                                  decoration: InputDecoration(
                                                                                                    contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                                    border: const OutlineInputBorder(),
                                                                                                    hintText: sortedModsList[index][5].split('|')[sub],
                                                                                                  ),
                                                                                                  onEditingComplete: (() {
                                                                                                    if (renameTextBoxController.text.isNotEmpty) {
                                                                                                      String oldSubDirName = sortedModsList[index][5].split('|')[sub];
                                                                                                      // Directory('$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                      //     '$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                      List<FileSystemEntity> curFilesInSubDir =
                                                                                                          Directory('$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName')
                                                                                                              .listSync(recursive: true);
                                                                                                      for (var element in curFilesInSubDir) {
                                                                                                        //print(curFilesInMainDir);
                                                                                                        String newMainPath = element.path.replaceFirst(
                                                                                                            '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName$s',
                                                                                                            '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s${renameTextBoxController.text}$s');
                                                                                                        if (!File(element.path).existsSync()) {
                                                                                                          Directory(newMainPath).createSync(recursive: true);
                                                                                                        } else {
                                                                                                          Directory(File(newMainPath).parent.path).createSync(recursive: true);
                                                                                                        }
                                                                                                      }
                                                                                                      for (var element in curFilesInSubDir) {
                                                                                                        String newMainPath = element.path.replaceFirst(
                                                                                                            '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName$s',
                                                                                                            '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s${renameTextBoxController.text}$s');
                                                                                                        if (File(element.path).existsSync()) {
                                                                                                          File(element.path).copySync(newMainPath);
                                                                                                        }
                                                                                                      }

                                                                                                      //List
                                                                                                      List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                      subDirsString[subDirsString.indexOf(oldSubDirName)] = renameTextBoxController.text;
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
                                                                                                    setState(
                                                                                                      () {},
                                                                                                    );
                                                                                                  }),
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
                                                                                                    String oldSubDirName = sortedModsList[index][5].split('|')[sub];
                                                                                                    // Directory('$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                    //     '$tempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                    List<FileSystemEntity> curFilesInSubDir =
                                                                                                        Directory('$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName')
                                                                                                            .listSync(recursive: true);
                                                                                                    for (var element in curFilesInSubDir) {
                                                                                                      //print(curFilesInMainDir);
                                                                                                      String newMainPath = element.path.replaceFirst(
                                                                                                          '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName$s',
                                                                                                          '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s${renameTextBoxController.text}$s');
                                                                                                      if (!File(element.path).existsSync()) {
                                                                                                        Directory(newMainPath).createSync(recursive: true);
                                                                                                      }
                                                                                                    }
                                                                                                    for (var element in curFilesInSubDir) {
                                                                                                      String newMainPath = element.path.replaceFirst(
                                                                                                          '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s$oldSubDirName$s',
                                                                                                          '$tempDirPath$s${sortedModsList[index][4].split('|')[ex]}$s${renameTextBoxController.text}$s');
                                                                                                      if (File(element.path).existsSync()) {
                                                                                                        File(element.path).copySync(newMainPath);
                                                                                                      }
                                                                                                    }

                                                                                                    //List
                                                                                                    List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                    subDirsString[subDirsString.indexOf(oldSubDirName)] = renameTextBoxController.text;
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
                                                                                              child: Text(
                                                                                                sortedModsList[index][5].split('|')[sub],
                                                                                                // style: const TextStyle(
                                                                                                //   fontWeight: FontWeight.w500,
                                                                                                // )
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              width: 5,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 40,
                                                                                              child: Tooltip(
                                                                                                message: curLangText!.editTooltipText,
                                                                                                waitDuration: const Duration(seconds: 1),
                                                                                                child: MaterialButton(
                                                                                                  onPressed: !_isNameEditing
                                                                                                      ? () {
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
                                                                                          ],
                                                                                        ),
                                                                                  children: [
                                                                                    for (int i = 0; i < sortedModsList[index][6].split('|').length; i++)
                                                                                      if (sortedModsList[index][6].split('|')[i].split(':')[0] == sortedModsList[index][4].split('|')[ex] &&
                                                                                          sortedModsList[index][6].split('|')[i].split(':')[1] == sortedModsList[index][5].split('|')[sub])
                                                                                        ListTile(
                                                                                          title: Text(sortedModsList[index][6].split('|')[i].split(':').last),
                                                                                        )
                                                                                  ],
                                                                                ),
                                                                            //if has no subfolders
                                                                            for (int u = 0; u < sortedModsList[index][5].split('|').length; u++)
                                                                              if (sortedModsList[index][5].split('|')[u] == '')
                                                                                for (int i = 0; i < sortedModsList[index][6].split('|').length; i++)
                                                                                  if (sortedModsList[index][6].split('|')[i].split(':')[0] == sortedModsList[index][4].split('|')[ex] &&
                                                                                      sortedModsList[index][6].split('|')[i].split(':')[1] == '')
                                                                                    ListTile(
                                                                                      title: Padding(
                                                                                        padding: const EdgeInsets.only(left: 10),
                                                                                        child: Text(sortedModsList[index][6].split('|')[i].split(':').last),
                                                                                      ),
                                                                                    )
                                                                          ],
                                                                        )
                                                                    ],
                                                                  ),
                                                                );
                                                              }));
                                                    }
                                                  }
                                                }),
                                          ),
                                        ),
                                        if (_exitConfirmDialog)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Container(
                                              //height: 60,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(3),
                                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(5.0),
                                                    child: Center(
                                                        child: _duplicateModNames.isNotEmpty
                                                            ? Text(
                                                                '${curLangText!.renameSpaceLabelText} $_duplicateModNames ${curLangText!.spaceBeforeAddingLabelText}',
                                                                textAlign: TextAlign.center,
                                                              )
                                                            : Text(
                                                                curLangText!.errorModsInToBeAddedListLabelText,
                                                                textAlign: TextAlign.center,
                                                              )),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 5),
                                                    child: ElevatedButton(
                                                      child: Text(curLangText!.returnBtnLabel),
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
                                                    curLangText!.modAddedSuccessfullyText,
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
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: sortedModsList.isNotEmpty || context.watch<StateProvider>().modAdderReload
                                                      ? (() {
                                                          Directory(tempDirPath).listSync(recursive: false).forEach((element) {
                                                            element.deleteSync(recursive: true);
                                                          });
                                                          Directory('${Directory.current.path}${s}unpack').listSync(recursive: false).forEach((element) {
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
                                                          setState(
                                                            () {},
                                                          );
                                                        })
                                                      : null,
                                                  child: Text(curLangText!.clearAllBtnLabel)),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: (() async {
                                                    if (_exitConfirmDialog) {
                                                      Directory(tempDirPath).listSync(recursive: false).forEach((element) {
                                                        element.deleteSync(recursive: true);
                                                      });
                                                      Directory('${Directory.current.path}${s}unpack').listSync(recursive: false).forEach((element) {
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
                                                      Navigator.of(context).pop();
                                                    }
                                                  }),
                                                  child: Text(curLangText!.closeBtnText)),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: sortedModsList.isNotEmpty && _mainFolderRenameIndex.indexWhere((element) => element == true) == -1 ||
                                                          context.watch<StateProvider>().modAdderReload && _mainFolderRenameIndex.indexWhere((element) => element == true) == -1
                                                      ? (() async {
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

                                                            if (Directory('$modsDirPath$s$category$s$itemName').existsSync()) {
                                                              if (Directory('$modsDirPath$s$category$s$itemName')
                                                                      .listSync(recursive: false)
                                                                      .indexWhere((element) => mainNames.contains(element.path.split(s).last)) !=
                                                                  -1) {
                                                                for (var mainName in mainNames) {
                                                                  if (Directory('$modsDirPath$s$category$s$itemName')
                                                                          .listSync(recursive: false)
                                                                          .indexWhere((element) => element.path.split(s).last == mainName) !=
                                                                      -1) {
                                                                    _duplicateModNames.add(' "$mainName" in $itemName ');
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                          //Add mods
                                                          if (_duplicateModNames.isEmpty) {
                                                            modFilesAdder(context, sortedModsList, XFile('')).then((_) {
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
                                                              _duplicateModNames.clear();
                                                              sortedModsList.clear();
                                                              _newModDragDropList.clear();
                                                              modsToAddList.clear();
                                                              Directory(tempDirPath).listSync(recursive: false).forEach((element) {
                                                                element.deleteSync(recursive: true);
                                                              });
                                                              Directory('${Directory.current.path}${s}unpack').listSync(recursive: false).forEach((element) {
                                                                element.deleteSync(recursive: true);
                                                              });
                                                              setState(
                                                                () {},
                                                              );
                                                              Future.delayed(const Duration(seconds: 3)).then((value) {
                                                                _isAddedSuccess = false;
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
                                                  child: Text(curLangText!.addAllBtnLabelText)),
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
                        }),
                      );
                    }),
                  )));
        });
      });
}
