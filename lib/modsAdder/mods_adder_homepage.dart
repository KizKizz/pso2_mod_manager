import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';
// ignore: depend_on_referenced_packages
//import 'package:collection/collection.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_add_function.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_ignore_list.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:io/io.dart' as io;
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

bool dropZoneMax = true;
bool _newModDragging = false;
List<XFile> modAdderDragDropFiles = [];
Future? processedFileListLoad;
List<ModsAdderItem> processedFileList = [];
List<String> _selectedCategories = [];
TextEditingController renameTextBoxController = TextEditingController();
List<bool> _itemNameRenameIndex = [];
List<List<bool>> mainFolderRenameIndex = [];
List<List<List<bool>>> subFoldersRenameIndex = [];
bool _isNameEditing = false;
int _duplicateCounter = 0;
final _subItemFormValidate = GlobalKey<FormState>();
bool _isAddingMods = false;
// bool _isProcessingMoreFiles = false;
int _pathLengthInNameEdit = 0;
Signal _modAdderState = Signal<ModAdderProcessingState>(ModAdderProcessingState.idle);
String _errorMessage = '';

void modsAdderHomePage(context) {
  clearModAdderDirs();
  Directory(modManModsAdderPath).createSync(recursive: true);
  List<String> dropdownButtonCateList = [];
  for (var type in moddedItemsList) {
    dropdownButtonCateList.addAll(type.categories.map((e) => e.categoryName));
  }
  dropdownButtonCateList.sort();
  List<List<int>> pathCharLengthList = [];

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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Scaffold(
                  backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                  body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                                : modAdderDragDropFiles.isEmpty
                                    ? constraints.maxWidth * 0.3
                                    : constraints.maxWidth * 0.45,
                            child: Column(
                              children: [
                                DropTarget(
                                  //enable: true,
                                  onDragDone: (detail) async {
                                    for (var element in detail.files) {
                                      // if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                      //   modsAdderUnsupportedFileTypeDialog(context, p.basename(element.path));
                                      // } else
                                      if (modAdderDragDropFiles.indexWhere((file) => file.path == element.path) == -1) {
                                        modAdderDragDropFiles.add(element);
                                        //newModMainFolderList.add(element);
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
                                        height: dropZoneMax ? constraints.maxHeight - 75 : constraints.maxHeight - 108,
                                        //width: constraints.maxWidth * 0.45,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (modAdderDragDropFiles.isEmpty)
                                              Center(
                                                  child: Text(
                                                curLangText!.uiDragDropFiles,
                                                style: const TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center,
                                              )),
                                            if (modAdderDragDropFiles.isNotEmpty)
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 5),
                                                  child: SizedBox(
                                                      width: constraints.maxWidth,
                                                      height: constraints.maxHeight,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 0),
                                                        child: SuperListView.builder(
                                                            physics: const RangeMaintainingScrollPhysics(),
                                                            itemCount: modAdderDragDropFiles.length,
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
                                                                        modAdderDragDropFiles.removeAt(index);
                                                                        setState(
                                                                          () {},
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                title: Text(modAdderDragDropFiles[index].name),
                                                                subtitle: Text(
                                                                  modAdderDragDropFiles[index].path,
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
                                Visibility(
                                  visible: !dropZoneMax,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        List<String?> selectedDirPaths = await getDirectoryPaths();
                                                        if (selectedDirPaths.isNotEmpty) {
                                                          modAdderDragDropFiles.addAll(selectedDirPaths.map((e) => XFile(e!)));
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.uiAddFolders)),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        List<XFile?> selectedDirPaths = await openFiles();
                                                        if (selectedDirPaths.isNotEmpty) {
                                                          modAdderDragDropFiles.addAll(selectedDirPaths.map((e) => e!));
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.uiAddFiles)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: !dropZoneMax,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        final prefs = await SharedPreferences.getInstance();
                                                        if (modsAdderGroupSameItemVariants) {
                                                          modsAdderGroupSameItemVariants = false;
                                                          prefs.setBool('modsAdderGroupSameItemVariants', false);
                                                        } else {
                                                          modsAdderGroupSameItemVariants = true;
                                                          prefs.setBool('modsAdderGroupSameItemVariants', true);
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(modsAdderGroupSameItemVariants
                                                    ? '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiON}'
                                                    : '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiOFF}')),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        await modAdderIgnoreListPopup(context);
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(modAdderIgnoreListState ? '${curLangText!.uiIgnoreList}: ${curLangText!.uiON}' : '${curLangText!.uiIgnoreList}: ${curLangText!.uiOFF}')),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: dropZoneMax,
                                  //width: constraints.maxWidth * 0.7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        List<String?> selectedDirPaths = await getDirectoryPaths();
                                                        if (selectedDirPaths.isNotEmpty) {
                                                          modAdderDragDropFiles.addAll(selectedDirPaths.map((e) => XFile(e!)));
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.uiAddFolders)),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.zero,
                                            child: ElevatedButton(
                                                onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                    ? (() async {
                                                        List<XFile?> selectedDirPaths = await openFiles();
                                                        if (selectedDirPaths.isNotEmpty) {
                                                          modAdderDragDropFiles.addAll(selectedDirPaths.map((e) => e!));
                                                        }
                                                        setState(
                                                          () {},
                                                        );
                                                      })
                                                    : null,
                                                child: Text(curLangText!.uiAddFiles)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  //width: constraints.maxWidth * 0.7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: modAdderDragDropFiles.isNotEmpty
                                                ? (() {
                                                    modAdderDragDropFiles.clear();
                                                    //newModMainFolderList.clear();
                                                    setState(
                                                      () {},
                                                    );
                                                  })
                                                : null,
                                            child: Text(curLangText!.uiClearAll)),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Visibility(
                                          visible: dropZoneMax,
                                          child: Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: ElevatedButton(
                                                  onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                      ? (() async {
                                                          final prefs = await SharedPreferences.getInstance();
                                                          if (modsAdderGroupSameItemVariants) {
                                                            modsAdderGroupSameItemVariants = false;
                                                            prefs.setBool('modsAdderGroupSameItemVariants', false);
                                                          } else {
                                                            modsAdderGroupSameItemVariants = true;
                                                            prefs.setBool('modsAdderGroupSameItemVariants', true);
                                                          }
                                                          setState(
                                                            () {},
                                                          );
                                                        })
                                                      : null,
                                                  child: Text(modsAdderGroupSameItemVariants
                                                      ? '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiON}'
                                                      : '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiOFF}')),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: dropZoneMax,
                                          child: Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: ElevatedButton(
                                                  onPressed: Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                      ? (() async {
                                                          await modAdderIgnoreListPopup(context);
                                                          setState(
                                                            () {},
                                                          );
                                                        })
                                                      : null,
                                                  child: Text(modAdderIgnoreListState ? '${curLangText!.uiIgnoreList}: ${curLangText!.uiON}' : '${curLangText!.uiIgnoreList}: ${curLangText!.uiOFF}')),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary.withBlue(150)),
                                              onPressed: modAdderDragDropFiles.isNotEmpty
                                                  ? (() async {
                                                      // if (processedFileList.isNotEmpty) {
                                                      //   _isProcessingMoreFiles = true;
                                                      //   setState(
                                                      //     () {},
                                                      //   );
                                                      // }
                                                      processedFileListLoad = modsAdderFilesProcess(context, modAdderDragDropFiles.toList(), '');
                                                      modAdderDragDropFiles.clear();
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
                            )),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 5, right: 5),
                              child: SizedBox(
                                height: constraints.maxHeight - 42,
                                child: FutureBuilder(
                                    future: processedFileListLoad,
                                    builder: (
                                      BuildContext context,
                                      AsyncSnapshot snapshot,
                                    ) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                _isAddingMods ? curLangText!.uiAddingMods : curLangText!.uiWaitingForData,
                                                style: const TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const CircularProgressIndicator(),
                                              Padding(
                                                  padding: const EdgeInsets.only(top: 20),
                                                  child: Text(
                                                    context.watch<StateProvider>().modAdderProgressStatus,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(fontSize: 16),
                                                  ))
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
                                                  curLangText!.uiError,
                                                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                                ),
                                                if (_errorMessage.isNotEmpty)
                                                  Text(
                                                    _errorMessage,
                                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
                                                  ),
                                                if (snapshot.error != null)
                                                  Text(
                                                    snapshot.error.toString(),
                                                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 18),
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
                                                  Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                      ? curLangText!.uiWaitingForData
                                                      : Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus,
                                                  style: const TextStyle(fontSize: 20),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                const CircularProgressIndicator(),
                                              ],
                                            ),
                                          );
                                        } else {
                                          if (Provider.of<StateProvider>(context, listen: false).modAdderReload) {
                                            bool renameModDifferencesFound = false;
                                            //sort item to add list
                                            for (ModsAdderItem element in snapshot.data) {
                                              int matchingItemIndex = processedFileList.indexWhere((item) => item.itemDirPath == element.itemDirPath);
                                              if (matchingItemIndex == -1 && Directory(element.itemDirPath).existsSync()) {
                                                processedFileList.add(element);
                                              } else if (matchingItemIndex != -1) {
                                                int ogModListLength = processedFileList[matchingItemIndex].modList.length;
                                                processedFileList[matchingItemIndex]
                                                    .modList
                                                    .addAll(element.modList.where((mod) => processedFileList[matchingItemIndex].modList.indexWhere((e) => e.modDirPath == mod.modDirPath) == -1));
                                                if (ogModListLength < processedFileList[matchingItemIndex].modList.length) {
                                                  renameModDifferencesFound = true;
                                                }
                                              }
                                            }

                                            //rename trigger
                                            if (_itemNameRenameIndex.isNotEmpty && _itemNameRenameIndex.length != processedFileList.length) {
                                              for (int i = 0; i < mainFolderRenameIndex.length; i++) {
                                                if (processedFileList[i].modList.length != mainFolderRenameIndex[i].length) {
                                                  renameModDifferencesFound = true;
                                                  break;
                                                }
                                              }
                                            }
                                            if (_itemNameRenameIndex.isEmpty || _itemNameRenameIndex.length != processedFileList.length || renameModDifferencesFound) {
                                              renameModDifferencesFound = false;
                                              _itemNameRenameIndex = List.generate(processedFileList.length, (index) => false);
                                              mainFolderRenameIndex = List.generate(processedFileList.length, (index) => List.generate(processedFileList[index].modList.length, (mIndex) => false));
                                              subFoldersRenameIndex = List.generate(
                                                  processedFileList.length,
                                                  (index) => List.generate(processedFileList[index].modList.length,
                                                      (mIndex) => List.generate(processedFileList[index].modList[mIndex].submodList.length, (sIndex) => false)));
                                            }
                                            //misc dropdown
                                            if (_selectedCategories.isEmpty) {
                                              for (var element in processedFileList) {
                                                _selectedCategories.add(element.category);
                                              }
                                            } else if (_selectedCategories.isNotEmpty && _selectedCategories.length < processedFileList.length) {
                                              _selectedCategories.clear();
                                              for (var element in processedFileList) {
                                                _selectedCategories.add(element.category);
                                              }
                                            }
                                            //get duplicates
                                            if (!_isAddingMods) {
                                              processedFileList = getDuplicates(processedFileList);
                                            }

                                            pathCharLengthList = List.generate(processedFileList.length, (index) => []);
                                            processedFileList.isNotEmpty ? _modAdderState.value = ModAdderProcessingState.readyToAdd : _modAdderState.value = ModAdderProcessingState.idle;

                                            return Stack(
                                              children: [
                                                ScrollbarTheme(
                                                  data: ScrollbarThemeData(
                                                    thumbColor: WidgetStateProperty.resolveWith((states) {
                                                      if (states.contains(WidgetState.hovered)) {
                                                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                      }
                                                      return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                    }),
                                                  ),
                                                  child: SuperListView.builder(
                                                      // shrinkWrap: true,
                                                      physics: const RangeMaintainingScrollPhysics(),
                                                      itemCount: processedFileList.length,
                                                      itemBuilder: (context, index) {
                                                        if (processedFileList.isNotEmpty) {
                                                          return Card(
                                                            margin: const EdgeInsets.only(top: 0, bottom: 2, left: 0, right: 0),
                                                            color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                            child: ExpansionTile(
                                                              initiallyExpanded: true,
                                                              maintainState: true,
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
                                                                      child: processedFileList[index].itemIconPath.isEmpty
                                                                          ? Image.asset(
                                                                              'assets/img/placeholdersquare.png',
                                                                              fit: BoxFit.fitWidth,
                                                                            )
                                                                          : Image.file(
                                                                              File(processedFileList[index].itemIconPath),
                                                                              fit: BoxFit.fitWidth,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        if (processedFileList[index].isUnknown)
                                                                          DropdownButton2(
                                                                            hint: Text(curLangText!.uiSelectACategory),
                                                                            underline: const SizedBox(),
                                                                            buttonStyleData: ButtonStyleData(
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(3),
                                                                                border: Border.all(color: Theme.of(context).hintColor),
                                                                              ),
                                                                              width: 200,
                                                                              height: 35,
                                                                            ),
                                                                            dropdownStyleData: DropdownStyleData(
                                                                              decoration: BoxDecoration(
                                                                                color: Theme.of(context).primaryColorLight,
                                                                                borderRadius: BorderRadius.circular(2),
                                                                              ),
                                                                              padding: const EdgeInsets.symmetric(vertical: 5),
                                                                              elevation: 3,
                                                                              maxHeight: constraints.maxHeight * 0.5,
                                                                            ),
                                                                            iconStyleData: const IconStyleData(icon: Icon(Icons.arrow_drop_down), iconSize: 30),
                                                                            menuItemStyleData: const MenuItemStyleData(
                                                                              height: 30,
                                                                            ),
                                                                            items: dropdownButtonCateList
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
                                                                            onChanged: (value) async {
                                                                              _selectedCategories[index] = value.toString();
                                                                              String newItemPath = processedFileList[index].itemDirPath.replaceFirst(p.dirname(processedFileList[index].itemDirPath),
                                                                                  Uri.file('$modManModsAdderPath/${_selectedCategories[index]}').toFilePath());
                                                                              await io.copyPath(processedFileList[index].itemDirPath, newItemPath);
                                                                              //delete item dir
                                                                              Directory(processedFileList[index].itemDirPath).deleteSync(recursive: true);
                                                                              //delete parent dir if empty
                                                                              if (Directory(p.dirname(processedFileList[index].itemDirPath)).listSync().isEmpty) {
                                                                                Directory(p.dirname(processedFileList[index].itemDirPath)).deleteSync(recursive: true);
                                                                              }
                                                                              processedFileList[index].setNewParentPathToChildren(newItemPath.trim());
                                                                              processedFileList[index].itemDirPath = newItemPath;
                                                                              processedFileList[index].category = value.toString();
                                                                              debugPrint(processedFileList[index].itemDirPath);
                                                                              setState(
                                                                                () {},
                                                                              );
                                                                            },
                                                                          ),
                                                                        if (!processedFileList[index].isUnknown)
                                                                          SizedBox(
                                                                            width: 150,
                                                                            height: 40,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 10),
                                                                              child: Text(
                                                                                  defaultCategoryDirs.contains(processedFileList[index].category)
                                                                                      ? defaultCategoryNames[defaultCategoryDirs.indexOf(processedFileList[index].category)]
                                                                                      : processedFileList[index].category,
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: !processedFileList[index].toBeAdded
                                                                                          ? Theme.of(context).disabledColor
                                                                                          : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                            ),
                                                                          ),
                                                                        SizedBox(
                                                                          height: 40,
                                                                          child: _itemNameRenameIndex[index]
                                                                              ? Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: SizedBox(
                                                                                        //width: constraints.maxWidth * 0.4,
                                                                                        // height: context.watch<StateProvider>().itemAdderSubItemETHeight,
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
                                                                                              hintText: processedFileList[index].itemName,
                                                                                              counterText: '',
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                            validator: (value) {
                                                                                              if (value == null || value.isEmpty) {
                                                                                                // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                return curLangText!.uiNameCannotBeEmpty;
                                                                                              }

                                                                                              if (Directory(p.dirname(
                                                                                                      processedFileList[index].itemDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath)))
                                                                                                  .listSync()
                                                                                                  .whereType<Directory>()
                                                                                                  .where((element) => p.basename(element.path).toLowerCase() == value.toLowerCase())
                                                                                                  .isNotEmpty) {
                                                                                                // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                return curLangText!.uiNameAlreadyExisted;
                                                                                              }

                                                                                              if (renameTextBoxController.text.characters.last == ' ') {
                                                                                                return curLangText!.uiNameCannotHaveSpacesAtTheEnd;
                                                                                              }

                                                                                              return null;
                                                                                            },
                                                                                            onChanged: (value) {
                                                                                              setState(
                                                                                                () {},
                                                                                              );
                                                                                            },
                                                                                            onEditingComplete: () async {
                                                                                              if (renameTextBoxController.text != processedFileList[index].itemName &&
                                                                                                  _subItemFormValidate.currentState!.validate()) {
                                                                                                if (renameTextBoxController.text.isNotEmpty) {
                                                                                                  //rename text
                                                                                                  String newItemName = renameTextBoxController.text.trim();
                                                                                                  if (processedFileList[index].category == defaultCategoryDirs[1] &&
                                                                                                      !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                    newItemName += ' [Ba]';
                                                                                                  } else if (processedFileList[index].category == defaultCategoryDirs[11] &&
                                                                                                      !renameTextBoxController.text.contains('[In]')) {
                                                                                                    newItemName += ' [In]';
                                                                                                  } else if (processedFileList[index].category == defaultCategoryDirs[15] &&
                                                                                                      !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                    newItemName += ' [Ou]';
                                                                                                  } else if (processedFileList[index].category == defaultCategoryDirs[16] &&
                                                                                                      !renameTextBoxController.text.contains('[Se]')) {
                                                                                                    newItemName += ' [Se]';
                                                                                                  } else {
                                                                                                    newItemName = renameTextBoxController.text;
                                                                                                  }
                                                                                                  //change dir name
                                                                                                  processedFileList[index].itemName = newItemName;
                                                                                                  var newItemDir = await Directory(processedFileList[index].itemDirPath)
                                                                                                      .rename(Uri.file('${p.dirname(processedFileList[index].itemDirPath)}/$newItemName').toFilePath());
                                                                                                  processedFileList[index].setNewParentPathToChildren(newItemDir.path.trim());
                                                                                                  processedFileList[index].itemIconPath = processedFileList[index]
                                                                                                      .itemIconPath
                                                                                                      .replaceFirst(processedFileList[index].itemDirPath, newItemDir.path);
                                                                                                  processedFileList[index].itemDirPath = newItemDir.path;
                                                                                                }

                                                                                                _itemNameRenameIndex[index] = false;
                                                                                                renameTextBoxController.clear();
                                                                                                _isNameEditing = false;
                                                                                                _duplicateCounter--;

                                                                                                setState(
                                                                                                  () {},
                                                                                                );
                                                                                              }
                                                                                            },
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
                                                                                        onPressed: renameTextBoxController.text == processedFileList[index].itemName
                                                                                            ? null
                                                                                            : () async {
                                                                                                if (_subItemFormValidate.currentState!.validate() &&
                                                                                                    renameTextBoxController.text != processedFileList[index].itemName) {
                                                                                                  if (renameTextBoxController.text.isNotEmpty) {
                                                                                                    //rename text
                                                                                                    String newItemName = renameTextBoxController.text.trim();
                                                                                                    if (processedFileList[index].category == defaultCategoryDirs[1] &&
                                                                                                        !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                      newItemName += ' [Ba]';
                                                                                                    } else if (processedFileList[index].category == defaultCategoryDirs[11] &&
                                                                                                        !renameTextBoxController.text.contains('[In]')) {
                                                                                                      newItemName += ' [In]';
                                                                                                    } else if (processedFileList[index].category == defaultCategoryDirs[15] &&
                                                                                                        !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                      newItemName += ' [Ou]';
                                                                                                    } else if (processedFileList[index].category == defaultCategoryDirs[16] &&
                                                                                                        !renameTextBoxController.text.contains('[Se]')) {
                                                                                                      newItemName += ' [Se]';
                                                                                                    } else {
                                                                                                      newItemName = renameTextBoxController.text;
                                                                                                    }
                                                                                                    //change dir name
                                                                                                    processedFileList[index].itemName = newItemName;
                                                                                                    var newItemDir = await Directory(processedFileList[index].itemDirPath).rename(
                                                                                                        Uri.file('${p.dirname(processedFileList[index].itemDirPath)}/$newItemName').toFilePath());
                                                                                                    processedFileList[index].setNewParentPathToChildren(newItemDir.path.trim());
                                                                                                    processedFileList[index].itemIconPath = processedFileList[index]
                                                                                                        .itemIconPath
                                                                                                        .replaceFirst(processedFileList[index].itemDirPath, newItemDir.path);
                                                                                                    processedFileList[index].itemDirPath = newItemDir.path;
                                                                                                  }

                                                                                                  _itemNameRenameIndex[index] = false;
                                                                                                  renameTextBoxController.clear();
                                                                                                  _isNameEditing = false;
                                                                                                  _duplicateCounter--;

                                                                                                  setState(
                                                                                                    () {},
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                        child: const Icon(Icons.check),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 40,
                                                                                      child: MaterialButton(
                                                                                        onPressed: () {
                                                                                          _itemNameRenameIndex[index] = false;
                                                                                          renameTextBoxController.clear();
                                                                                          _isNameEditing = false;

                                                                                          setState(
                                                                                            () {},
                                                                                          );
                                                                                        },
                                                                                        child: const Icon(Icons.close),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              : Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.only(bottom: 3),
                                                                                        child: Text(
                                                                                            processedFileList[index].category == defaultCategoryDirs[17]
                                                                                                ? processedFileList[index].itemName.split('_').isNotEmpty &&
                                                                                                        processedFileList[index].itemName.split('_').first == 'it' &&
                                                                                                        processedFileList[index].itemName.split('_')[1] == 'wp'
                                                                                                    ? processedFileList[index].itemName
                                                                                                    : processedFileList[index].itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                                : processedFileList[index].itemName.replaceAll('_', '/'),
                                                                                            style: TextStyle(
                                                                                                fontWeight: FontWeight.w600,
                                                                                                color: !processedFileList[index].toBeAdded
                                                                                                    ? Theme.of(context).disabledColor
                                                                                                    : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    if (processedFileList[index].isChildrenDuplicated)
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(right: 5),
                                                                                        child: Container(
                                                                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                          ),
                                                                                          child: Text(
                                                                                            curLangText!.uiDuplicateModsInside,
                                                                                            style: TextStyle(
                                                                                                fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    Visibility(
                                                                                      visible: !defaultCategoryNames.contains(processedFileList[index].category) ||
                                                                                          processedFileList[index].category == defaultCategoryNames[13],
                                                                                      child: SizedBox(
                                                                                        width: 40,
                                                                                        child: Tooltip(
                                                                                          message: curLangText!.uiEditName,
                                                                                          height: 25,
                                                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                          waitDuration: const Duration(seconds: 1),
                                                                                          child: MaterialButton(
                                                                                            onPressed: !_isNameEditing && processedFileList[index].toBeAdded
                                                                                                ? () {
                                                                                                    renameTextBoxController.text = processedFileList[index].itemName;
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
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    if (processedFileList[index].toBeAdded)
                                                                                      SizedBox(
                                                                                        width: 40,
                                                                                        child: ModManTooltip(
                                                                                          message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                          child: MaterialButton(
                                                                                            onPressed: () {
                                                                                              processedFileList[index].toBeAdded = false;
                                                                                              for (var mod in processedFileList[index].modList) {
                                                                                                mod.toBeAdded = false;
                                                                                                for (var submod in mod.submodList) {
                                                                                                  submod.toBeAdded = false;
                                                                                                }
                                                                                              }
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
                                                                                    if (!processedFileList[index].toBeAdded)
                                                                                      SizedBox(
                                                                                        width: 40,
                                                                                        child: ModManTooltip(
                                                                                          message: curLangText!.uiMarkThisToBeAdded,
                                                                                          child: MaterialButton(
                                                                                            onPressed: () {
                                                                                              processedFileList[index].toBeAdded = true;
                                                                                              for (var mod in processedFileList[index].modList) {
                                                                                                mod.toBeAdded = true;
                                                                                                for (var submod in mod.submodList) {
                                                                                                  submod.toBeAdded = true;
                                                                                                }
                                                                                              }
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
                                                              collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                              //childrenPadding: const EdgeInsets.only(left: 10),
                                                              children: [
                                                                //mods list
                                                                SuperListView.builder(
                                                                    shrinkWrap: true,
                                                                    physics: const RangeMaintainingScrollPhysics(),
                                                                    itemCount: processedFileList[index].modList.length,
                                                                    itemBuilder: (context, mIndex) {
                                                                      var curMod = processedFileList[index].modList[mIndex];
                                                                      // _isProcessingMoreFiles = false;
                                                                      //rename trigger
                                                                      // //List<bool> mainFolderRenameIndex = [];
                                                                      // if (mainFolderRenameIndex.isEmpty || mainFolderRenameIndex.length != processedFileList[index].modList.length) {
                                                                      //   mainFolderRenameIndex = List.generate(processedFileList[index].modList.length, (index) => false);
                                                                      // }
                                                                      // if (pathCharLengthList[index].isNotEmpty) {
                                                                      //   pathCharLengthList[index].clear();
                                                                      // }

                                                                      int pathLength = 0;
                                                                      for (var file in curMod.filesInMod) {
                                                                        String tempPath = file.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
                                                                        if (tempPath.length > pathLength) {
                                                                          pathLength = tempPath.length;
                                                                        }
                                                                      }
                                                                      for (var sub in curMod.submodList) {
                                                                        for (var modFile in sub.files) {
                                                                          String tempPath = modFile.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
                                                                          if (tempPath.length > pathLength) {
                                                                            pathLength = tempPath.length;
                                                                          }
                                                                        }
                                                                      }

                                                                      pathCharLengthList[index].insert(mIndex, pathLength);

                                                                      return ExpansionTile(
                                                                        initiallyExpanded: false,
                                                                        childrenPadding: const EdgeInsets.only(left: 15),
                                                                        textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                        iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                        collapsedTextColor:
                                                                            MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                        //Edit Name
                                                                        title: mainFolderRenameIndex[index][mIndex]
                                                                            ? Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: SizedBox(
                                                                                      //width: constraints.maxWidth * 0.4,
                                                                                      // height: context.watch<StateProvider>().itemAdderSubItemETHeight,
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
                                                                                            hintText: curMod.modName,
                                                                                            counterText: '',
                                                                                          ),
                                                                                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                          validator: (value) {
                                                                                            if (value == null || value.isEmpty) {
                                                                                              // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                              return curLangText!.uiNameCannotBeEmpty;
                                                                                            }

                                                                                            if (Directory(processedFileList[index]
                                                                                                    .modList[mIndex]
                                                                                                    .modDirPath
                                                                                                    .replaceFirst(modManModsAdderPath, modManModsDirPath))
                                                                                                .parent
                                                                                                .listSync()
                                                                                                .whereType<Directory>()
                                                                                                .where((e) => p.basename(e.path) == renameTextBoxController.value.text)
                                                                                                .isNotEmpty) {
                                                                                              // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                              return curLangText!.uiNameAlreadyExisted;
                                                                                            }

                                                                                            if (renameTextBoxController.text.characters.last == ' ') {
                                                                                              return curLangText!.uiNameCannotHaveSpacesAtTheEnd;
                                                                                            }

                                                                                            return null;
                                                                                          },
                                                                                          onChanged: (value) {
                                                                                            int pathLength = 0;
                                                                                            for (var file in curMod.filesInMod) {
                                                                                              String tempPath = file.path.replaceFirst(modManModsAdderPath, modManModsDirPath);
                                                                                              if (tempPath.length > pathLength) {
                                                                                                pathLength = tempPath.length;
                                                                                              }
                                                                                            }
                                                                                            for (var sub in curMod.submodList) {
                                                                                              for (var modFile in sub.files) {
                                                                                                String tempPath = modFile.path
                                                                                                    .replaceFirst(modManModsAdderPath, modManModsDirPath)
                                                                                                    .replaceFirst(curMod.modName, value);
                                                                                                if (tempPath.length > pathLength) {
                                                                                                  pathLength = tempPath.length;
                                                                                                }
                                                                                              }
                                                                                            }

                                                                                            _pathLengthInNameEdit = pathLength;
                                                                                            setState(
                                                                                              () {},
                                                                                            );
                                                                                          },
                                                                                          onEditingComplete: () async {
                                                                                            if (renameTextBoxController.text != curMod.modName && _subItemFormValidate.currentState!.validate()) {
                                                                                              if (renameTextBoxController.text.isNotEmpty) {
                                                                                                curMod.modName = renameTextBoxController.text;
                                                                                                var newModDir = await Directory(curMod.modDirPath)
                                                                                                    .rename(Uri.file('${p.dirname(curMod.modDirPath)}/${renameTextBoxController.text}').toFilePath());
                                                                                                curMod.setNewParentPathToChildren(newModDir.path.trim());
                                                                                                curMod.modDirPath = newModDir.path;
                                                                                              }

                                                                                              mainFolderRenameIndex[index][mIndex] = false;
                                                                                              renameTextBoxController.clear();
                                                                                              _isNameEditing = false;
                                                                                              _duplicateCounter--;

                                                                                              setState(
                                                                                                () {},
                                                                                              );
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text('$_pathLengthInNameEdit/259 ${curLangText!.uiCharacters}',
                                                                                      style: TextStyle(
                                                                                          color: pathCharLengthList[index][mIndex] > 259 ? Colors.red : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 40,
                                                                                    child: MaterialButton(
                                                                                      onPressed: renameTextBoxController.text == curMod.modName
                                                                                          ? null
                                                                                          : () async {
                                                                                              if (_subItemFormValidate.currentState!.validate() && renameTextBoxController.text != curMod.modName) {
                                                                                                if (renameTextBoxController.text.isNotEmpty) {
                                                                                                  curMod.modName = renameTextBoxController.text;
                                                                                                  var newModDir = await Directory(curMod.modDirPath)
                                                                                                      .rename(Uri.file('${p.dirname(curMod.modDirPath)}/${renameTextBoxController.text}').toFilePath());
                                                                                                  curMod.setNewParentPathToChildren(newModDir.path.trim());
                                                                                                  curMod.modDirPath = newModDir.path;
                                                                                                }
                                                                                                pathCharLengthList[index][mIndex] = curMod.modDirPath.length;

                                                                                                mainFolderRenameIndex[index][mIndex] = false;
                                                                                                renameTextBoxController.clear();
                                                                                                _isNameEditing = false;
                                                                                                _pathLengthInNameEdit = 0;
                                                                                                _duplicateCounter--;
                                                                                                

                                                                                                setState(
                                                                                                  () {},
                                                                                                );
                                                                                              }
                                                                                            },
                                                                                      child: const Icon(Icons.check),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 40,
                                                                                    child: MaterialButton(
                                                                                      onPressed: () {
                                                                                        mainFolderRenameIndex[index][mIndex] = false;
                                                                                        renameTextBoxController.clear();
                                                                                        _isNameEditing = false;
                                                                                        _pathLengthInNameEdit = 0;

                                                                                        setState(
                                                                                          () {},
                                                                                        );
                                                                                      },
                                                                                      child: const Icon(Icons.close),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Text(curMod.modName,
                                                                                        style: TextStyle(
                                                                                            fontWeight: FontWeight.w500,
                                                                                            color:
                                                                                                !curMod.toBeAdded ? Theme.of(context).disabledColor : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text(
                                                                                    '${pathCharLengthList[index][mIndex]}/259 ${curLangText!.uiCharacters}',
                                                                                    style: TextStyle(
                                                                                        color: pathCharLengthList[index][mIndex] > 259 ? Colors.red : Theme.of(context).textTheme.bodyMedium!.color),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  if (curMod.isChildrenDuplicated)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 5),
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                        ),
                                                                                        child: Text(
                                                                                          curLangText!.uiDuplicateModsInside,
                                                                                          style: TextStyle(
                                                                                              fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  if (curMod.isDuplicated)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 5),
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                        ),
                                                                                        child: Text(
                                                                                          curLangText!.uiRenameThis,
                                                                                          style: TextStyle(
                                                                                              fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  SizedBox(
                                                                                    width: 40,
                                                                                    child: ModManTooltip(
                                                                                      message: curLangText!.uiEditName,
                                                                                      child: MaterialButton(
                                                                                        onPressed: !_isNameEditing && curMod.toBeAdded
                                                                                            ? () {
                                                                                                renameTextBoxController.text = curMod.modName;
                                                                                                renameTextBoxController.selection = TextSelection(
                                                                                                  baseOffset: 0,
                                                                                                  extentOffset: renameTextBoxController.text.length,
                                                                                                );
                                                                                                _isNameEditing = true;
                                                                                                mainFolderRenameIndex[index][mIndex] = true;
                                                                                                _pathLengthInNameEdit = pathCharLengthList[index][mIndex];
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
                                                                                  if (curMod.toBeAdded)
                                                                                    SizedBox(
                                                                                      width: 40,
                                                                                      child: Tooltip(
                                                                                        message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                        height: 25,
                                                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                        waitDuration: const Duration(seconds: 1),
                                                                                        child: MaterialButton(
                                                                                          onPressed: () {
                                                                                            curMod.toBeAdded = false;
                                                                                            for (var submod in curMod.submodList) {
                                                                                              submod.toBeAdded = false;
                                                                                            }
                                                                                            if (processedFileList[index].modList.where((element) => element.toBeAdded).isEmpty) {
                                                                                              processedFileList[index].toBeAdded = false;
                                                                                            }
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
                                                                                  if (!curMod.toBeAdded)
                                                                                    SizedBox(
                                                                                      width: 40,
                                                                                      child: Tooltip(
                                                                                        message: curLangText!.uiMarkThisToBeAdded,
                                                                                        height: 25,
                                                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                        waitDuration: const Duration(seconds: 1),
                                                                                        child: MaterialButton(
                                                                                          onPressed: () {
                                                                                            curMod.toBeAdded = true;
                                                                                            for (var submod in curMod.submodList) {
                                                                                              submod.toBeAdded = true;
                                                                                            }
                                                                                            if (processedFileList[index].modList.where((element) => element.toBeAdded).isNotEmpty) {
                                                                                              processedFileList[index].toBeAdded = true;
                                                                                            }
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
                                                                          //if file in mod folder found
                                                                          if (curMod.filesInMod.isNotEmpty)
                                                                            SuperListView.builder(
                                                                                shrinkWrap: true,
                                                                                physics: const RangeMaintainingScrollPhysics(),
                                                                                itemCount: curMod.filesInMod.length,
                                                                                itemBuilder: (context, fIndex) {
                                                                                  return ListTile(
                                                                                    title: Padding(
                                                                                      padding: const EdgeInsets.only(left: 0),
                                                                                      child: Text(p.basename(curMod.filesInMod[fIndex].path),
                                                                                          style: TextStyle(color: !curMod.toBeAdded ? Theme.of(context).disabledColor : null)),
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                          //if submmod list found
                                                                          if (curMod.submodList.isNotEmpty)
                                                                            SuperListView.builder(
                                                                                shrinkWrap: true,
                                                                                physics: const RangeMaintainingScrollPhysics(),
                                                                                itemCount: curMod.submodList.length,
                                                                                itemBuilder: (context, sIndex) {
                                                                                  var curSubmod = curMod.submodList[sIndex];
                                                                                  return ExpansionTile(
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
                                                                                    title: subFoldersRenameIndex[index][mIndex][sIndex]
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: SizedBox(
                                                                                                  // height: context.watch<StateProvider>().itemAdderSubItemETHeight,
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
                                                                                                        hintText: curSubmod.submodName.split(' > ').last,
                                                                                                        counterText: '',
                                                                                                      ),
                                                                                                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                                      validator: (value) {
                                                                                                        if (value == null || value.isEmpty) {
                                                                                                          // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                          return curLangText!.uiNameCannotBeEmpty;
                                                                                                        }

                                                                                                        if (Directory(curMod.submodList[sIndex].submodDirPath
                                                                                                                    .replaceFirst(modManModsAdderPath, modManModsDirPath))
                                                                                                                .existsSync() &&
                                                                                                            Directory(curMod.submodList[sIndex].submodDirPath
                                                                                                                    .replaceFirst(modManModsAdderPath, modManModsDirPath))
                                                                                                                .parent
                                                                                                                .listSync()
                                                                                                                .whereType<Directory>()
                                                                                                                .where((e) => p.basename(e.path) == renameTextBoxController.value.text)
                                                                                                                .isNotEmpty) {
                                                                                                          // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                          return curLangText!.uiNameAlreadyExisted;
                                                                                                        }

                                                                                                        if (renameTextBoxController.text.characters.last == ' ') {
                                                                                                          return curLangText!.uiNameCannotHaveSpacesAtTheEnd;
                                                                                                        }

                                                                                                        return null;
                                                                                                      },
                                                                                                      onChanged: (value) {
                                                                                                        setState(
                                                                                                          () {},
                                                                                                        );
                                                                                                      },
                                                                                                      onEditingComplete: (() async {
                                                                                                        if (renameTextBoxController.text != curSubmod.submodName.split(' > ').last &&
                                                                                                            _subItemFormValidate.currentState!.validate()) {
                                                                                                          if (renameTextBoxController.text.isNotEmpty) {
                                                                                                            List<String> submodNameParts = curSubmod.submodName.split(' > ');
                                                                                                            submodNameParts.removeLast();
                                                                                                            submodNameParts.add(renameTextBoxController.text);
                                                                                                            curSubmod.submodName = submodNameParts.join(' > ');
                                                                                                            var newSubmodDir = await Directory(curSubmod.submodDirPath).rename(
                                                                                                                Uri.file('${p.dirname(curSubmod.submodDirPath)}/${renameTextBoxController.text}')
                                                                                                                    .toFilePath());
                                                                                                            curSubmod.files = newSubmodDir.listSync(recursive: true).whereType<File>().toList();
                                                                                                            curSubmod.submodDirPath = newSubmodDir.path;
                                                                                                          }

                                                                                                          //Clear
                                                                                                          // ignore: use_build_context_synchronously
                                                                                                          // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                          subFoldersRenameIndex[index][mIndex][sIndex] = false;
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
                                                                                                  onPressed: renameTextBoxController.text == curSubmod.submodName
                                                                                                      ? null
                                                                                                      : () async {
                                                                                                          if (_subItemFormValidate.currentState!.validate()) {
                                                                                                            if (renameTextBoxController.text.isNotEmpty) {
                                                                                                              List<String> submodNameParts = curSubmod.submodName.split(' > ');
                                                                                                              submodNameParts.removeLast();
                                                                                                              submodNameParts.add(renameTextBoxController.text);
                                                                                                              curSubmod.submodName = submodNameParts.join(' > ');
                                                                                                              var newSubmodDir = await Directory(curSubmod.submodDirPath).rename(
                                                                                                                  Uri.file('${p.dirname(curSubmod.submodDirPath)}/${renameTextBoxController.text}')
                                                                                                                      .toFilePath());
                                                                                                              curSubmod.files = newSubmodDir.listSync(recursive: true).whereType<File>().toList();
                                                                                                              curSubmod.submodDirPath = newSubmodDir.path;
                                                                                                            }

                                                                                                            //Clear
                                                                                                            subFoldersRenameIndex[index][mIndex][sIndex] = false;
                                                                                                            renameTextBoxController.clear();
                                                                                                            _isNameEditing = false;
                                                                                                            // ignore: use_build_context_synchronously
                                                                                                            // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                            setState(
                                                                                                              () {},
                                                                                                            );
                                                                                                          }
                                                                                                        },
                                                                                                  child: const Icon(Icons.check),
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: 40,
                                                                                                child: MaterialButton(
                                                                                                  onPressed: () {
                                                                                                    subFoldersRenameIndex[index][mIndex][sIndex] = false;
                                                                                                    renameTextBoxController.clear();
                                                                                                    _isNameEditing = false;
                                                                                                    // ignore: use_build_context_synchronously
                                                                                                    // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);

                                                                                                    setState(
                                                                                                      () {},
                                                                                                    );
                                                                                                  },
                                                                                                  child: const Icon(Icons.close),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: Text(curSubmod.submodName,
                                                                                                    style: TextStyle(
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                        color: !curSubmod.toBeAdded
                                                                                                            ? Theme.of(context).disabledColor
                                                                                                            : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                              if (curSubmod.isDuplicated)
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(right: 5),
                                                                                                  child: Container(
                                                                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                                                    decoration: BoxDecoration(
                                                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      curLangText!.uiRenameThis,
                                                                                                      style: TextStyle(
                                                                                                          fontSize: 14,
                                                                                                          fontWeight: FontWeight.normal,
                                                                                                          color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              SizedBox(
                                                                                                width: 40,
                                                                                                child: Tooltip(
                                                                                                  message: curLangText!.uiEditName,
                                                                                                  height: 25,
                                                                                                  textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                  waitDuration: const Duration(seconds: 1),
                                                                                                  child: MaterialButton(
                                                                                                    onPressed: !_isNameEditing && curSubmod.toBeAdded
                                                                                                        ? () {
                                                                                                            renameTextBoxController.text = curSubmod.submodName.split(' > ').last;
                                                                                                            renameTextBoxController.selection = TextSelection(
                                                                                                              baseOffset: 0,
                                                                                                              extentOffset: renameTextBoxController.text.length,
                                                                                                            );
                                                                                                            subFoldersRenameIndex[index][mIndex][sIndex] = true;
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
                                                                                              if (curSubmod.toBeAdded)
                                                                                                SizedBox(
                                                                                                  width: 40,
                                                                                                  child: Tooltip(
                                                                                                    message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                                    height: 25,
                                                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                    waitDuration: const Duration(seconds: 1),
                                                                                                    child: MaterialButton(
                                                                                                      onPressed: () {
                                                                                                        curSubmod.toBeAdded = false;
                                                                                                        if (curMod.submodList.where((element) => element.toBeAdded).isEmpty) {
                                                                                                          curMod.toBeAdded = false;
                                                                                                        }
                                                                                                        if (processedFileList[index].modList.where((element) => element.toBeAdded).isEmpty) {
                                                                                                          processedFileList[index].toBeAdded = false;
                                                                                                        }
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
                                                                                              if (!curSubmod.toBeAdded)
                                                                                                SizedBox(
                                                                                                  width: 40,
                                                                                                  child: Tooltip(
                                                                                                    message: curLangText!.uiMarkThisToBeAdded,
                                                                                                    height: 25,
                                                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                                    waitDuration: const Duration(seconds: 1),
                                                                                                    child: MaterialButton(
                                                                                                      onPressed: () {
                                                                                                        curSubmod.toBeAdded = true;
                                                                                                        if (curMod.submodList.where((element) => element.toBeAdded).isNotEmpty) {
                                                                                                          curMod.toBeAdded = true;
                                                                                                        }
                                                                                                        if (processedFileList[index].modList.where((element) => element.toBeAdded).isNotEmpty) {
                                                                                                          processedFileList[index].toBeAdded = true;
                                                                                                        }
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
                                                                                      SuperListView.builder(
                                                                                          shrinkWrap: true,
                                                                                          physics: const RangeMaintainingScrollPhysics(),
                                                                                          itemCount: curSubmod.files.length,
                                                                                          itemBuilder: (context, fIndex) {
                                                                                            return ListTile(
                                                                                              title: Text(
                                                                                                p.basename(curSubmod.files[fIndex].path),
                                                                                                style: TextStyle(color: !curSubmod.toBeAdded ? Theme.of(context).disabledColor : null),
                                                                                              ),
                                                                                            );
                                                                                          })
                                                                                    ],
                                                                                  );
                                                                                })
                                                                        ],
                                                                      );
                                                                    }),
                                                              ],
                                                            ),
                                                          );
                                                        } else {
                                                          Center(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                                      ? curLangText!.uiProcessingFiles
                                                                      : Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus,
                                                                  style: const TextStyle(fontSize: 20),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                                const SizedBox(
                                                                  height: 20,
                                                                ),
                                                                const CircularProgressIndicator(),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                        return null;
                                                      }),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _isAddingMods
                                                        ? curLangText!.uiAddingMods
                                                        : Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus.isEmpty
                                                            ? curLangText!.uiWaitingForData
                                                            : Provider.of<StateProvider>(context, listen: false).modAdderProgressStatus,
                                                    style: const TextStyle(fontSize: 20),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  const CircularProgressIndicator(),
                                                ],
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }),
                              ),
                            ),
                            SizedBox(
                              //width: constraints.maxWidth * 0.45,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5, bottom: 4, right: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: dropZoneMax ? 1 : 0,
                                      child: ElevatedButton(
                                          onPressed: _isAddingMods
                                              ? null
                                              : (() async {
                                                  //clear lists
                                                  processedFileListLoad = null;
                                                  processedFileList.clear();
                                                  _itemNameRenameIndex.clear();
                                                  subFoldersRenameIndex.clear();
                                                  mainFolderRenameIndex.clear();
                                                  renameTextBoxController.clear();
                                                  _selectedCategories.clear();
                                                  pathCharLengthList.clear();
                                                  clearModAdderDirs();
                                                  dropZoneMax = true;
                                                  Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('');
                                                  _modAdderState.value = ModAdderProcessingState.idle;
                                                  Navigator.of(context).pop();
                                                  //}
                                                }),
                                          child: Text(curLangText!.uiClose)),
                                    ),
                                    Visibility(
                                      visible: !dropZoneMax,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                            onPressed: _modAdderState.watch(context) != ModAdderProcessingState.readyToAdd || !context.watch<StateProvider>().modAdderReload
                                                ? null
                                                : (() {
                                                    processedFileListLoad = null;
                                                    processedFileList.clear();
                                                    _itemNameRenameIndex.clear();
                                                    renameTextBoxController.clear();
                                                    mainFolderRenameIndex.clear();
                                                    subFoldersRenameIndex.clear();
                                                    _selectedCategories.clear();
                                                    pathCharLengthList.clear();
                                                    clearModAdderDirs();
                                                    Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                    _isNameEditing = false;
                                                    _modAdderState.value = ModAdderProcessingState.idle;
                                                    dropZoneMax = true;
                                                    setState(
                                                      () {},
                                                    );
                                                  }),
                                            child: Text(curLangText!.uiClearAll)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !dropZoneMax,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                            onPressed: _modAdderState.watch(context) != ModAdderProcessingState.readyToAdd || !context.watch<StateProvider>().modAdderReload
                                                ? null
                                                : (() async {
                                                    final prefs = await SharedPreferences.getInstance();
                                                    if (modAdderAddToModSets) {
                                                      modAdderAddToModSets = false;
                                                      prefs.setBool('modAdderAddToModSets', false);
                                                    } else {
                                                      modAdderAddToModSets = true;
                                                      prefs.setBool('modAdderAddToModSets', true);
                                                    }
                                                    setState(
                                                      () {},
                                                    );
                                                  }),
                                            child: Text(modAdderAddToModSets ? '${curLangText!.uiAddToModSets}: ON' : '${curLangText!.uiAddToModSets}: OFF')),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !dropZoneMax,
                                      child: Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary.withBlue(100)),
                                              onPressed: _isNameEditing ||
                                                      !context.watch<StateProvider>().modAdderReload ||
                                                      pathCharLengthList.where((mod) => mod.where((element) => element > 259).isNotEmpty).isNotEmpty ||
                                                      _modAdderState.watch(context) != ModAdderProcessingState.readyToAdd
                                                  ? null
                                                  : (() async {
                                                      if (_duplicateCounter > 0) {
                                                        processedFileList = await replaceNamesOfDuplicates(processedFileList);
                                                        processedFileList = getDuplicates(processedFileList);
                                                        setState(
                                                          () {},
                                                        );
                                                      } else {
                                                        List<ModsAdderItem> toAddList = processedFileList.toList();
                                                        processedFileListLoad = null;
                                                        processedFileList = [];
                                                        _isAddingMods = true;
                                                        setState(
                                                          () {},
                                                        );
                                                        modsAdderModFilesAdder(context, toAddList, modAdderAddToModSets).then(
                                                          (value) {
                                                            if (value.$1) {
                                                              clearModAdderDirs();
                                                              _itemNameRenameIndex.clear();
                                                              mainFolderRenameIndex.clear();
                                                              renameTextBoxController.clear();
                                                              subFoldersRenameIndex.clear();
                                                              _selectedCategories.clear();
                                                              processedFileListLoad = null;
                                                              processedFileList = [];
                                                              toAddList.clear();
                                                              pathCharLengthList.clear();
                                                              _isAddingMods = false;
                                                              _modAdderState.value = ModAdderProcessingState.idle;
                                                              //_exitConfirmDialog = false;
                                                              // ignore: use_build_context_synchronously
                                                              Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                              _isNameEditing = false;
                                                              dropZoneMax = true;
                                                              // if (csvInfosFromSheets.isNotEmpty) {
                                                              //   csvInfosFromSheets.clear();
                                                              // }
                                                            } else {
                                                              processedFileList = toAddList.toList();
                                                              toAddList.clear();
                                                              _isAddingMods = false;
                                                            }
                                                            setState(
                                                              () {},
                                                            );
                                                          },
                                                        );

                                                        // ignore: use_build_context_synchronously
                                                        //Navigator.of(context).pop();
                                                      }
                                                      setState(
                                                        () {},
                                                      );
                                                    }),
                                              child: _duplicateCounter > 0 && _duplicateCounter < 2
                                                  ? Text('${curLangText!.uiClickToRename}$_duplicateCounter${curLangText!.uiDuplicatedMod}')
                                                  : _duplicateCounter > 1
                                                      ? Text('${curLangText!.uiClickToRename}$_duplicateCounter${curLangText!.uiDuplicatedMods}')
                                                      : pathCharLengthList.where((mod) => mod.where((element) => element > 259).isNotEmpty).isNotEmpty
                                                          ? Text(curLangText!.uiPathTooLongError)
                                                          : Text(curLangText!.uiAddAll)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ))
                      ],
                    );
                  }),
                ),
              ));
        });
      });
}

//suport functions
Future<List<ModsAdderItem>> modsAdderFilesProcess(context, List<XFile> xFilePaths, String extraItemName) async {
  List<ModsAdderItem> modsAdderItemList = [];
  List<String> ignoredParams = await ignoreParamsGet();
  // List<String> pathsWithNoIceInRoot = [];
  //copy files to temp
  for (var xFile in xFilePaths) {
    String tempModDirName = '';
    if (p.extension(xFile.path) == '.zip' || p.extension(xFile.path) == '.rar' || p.extension(xFile.path) == '.7z') {
      tempModDirName = p.basenameWithoutExtension(xFile.path);
    } else {
      tempModDirName = p.basename(xFile.path);
    }
    if (Directory(modManAddModsTempDirPath).existsSync() && Directory(modManAddModsTempDirPath).listSync().where((element) => p.basename(element.path) == tempModDirName).isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
      tempModDirName += '_$formattedDate';
    }
    if (p.extension(xFile.path) == '.zip') {
      Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiExtracting}:\n${p.basename(xFile.path)}');
      await Future.delayed(const Duration(milliseconds: 5));
      await extractFileToDisk(xFile.path, Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath(), asyncWrite: false);
    } else if (p.extension(xFile.path) == '.rar') {
      Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiExtracting}:\n${p.basename(xFile.path)}');
      await Future.delayed(const Duration(milliseconds: 5));
      if (Platform.isLinux) {
        Directory(Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath()).createSync(recursive: true);
        await Process.run('unrar', ['e', xFile.path, (Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath())]);
      } else {
        await Process.run(modMan7zipExePath, ['x', xFile.path, '-o${Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath()}', '-r']);
      }
    } else if (p.extension(xFile.path) == '.7z') {
      Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiExtracting}:\n${p.basename(xFile.path)}');
      await Future.delayed(const Duration(milliseconds: 5));
      await Process.run(modMan7zipExePath, ['x', xFile.path, '-o${Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath()}', '-r']);
    } else if (File(xFile.path).statSync().type == FileSystemEntityType.directory) {
      Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiCopying}:\n${p.basename(xFile.path)}');
      await Future.delayed(const Duration(milliseconds: 5));
      await io.copyPath(xFile.path, Uri.file('$modManAddModsTempDirPath/$tempModDirName').toFilePath());
    } else {
      Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiCopying}:\n${p.basename(xFile.path)}');
      await Future.delayed(const Duration(milliseconds: 5));
      Directory(modManAddModsTempDirPath).createSync();
      String tempPath = Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(File(xFile.path).parent.path)}').toFilePath();
      if (Directory(modManAddModsTempDirPath).listSync().where((element) => p.basenameWithoutExtension(element.path) == tempPath).isNotEmpty) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
        tempPath += '_$formattedDate';
      }
      Directory(tempPath).createSync(recursive: true);
      if (File(xFile.path).existsSync()) File(xFile.path).copySync(Uri.file('$tempPath/${xFile.name}').toFilePath());
    }
  }

  //listing ice files in temp
  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus(curLangText!.uiSortingIceFiles);
  await Future.delayed(const Duration(milliseconds: 5));
  List<File> iceFileList = [];
  for (var dir in Directory(modManAddModsTempDirPath).listSync(recursive: false).whereType<Directory>()) {
    if (modAdderIgnoreListState && ignoredParams.isNotEmpty && dir.listSync().whereType<Directory>().isNotEmpty) {
      for (var subDir in dir.listSync(recursive: true).whereType<Directory>()) {
        bool ignore = false;
        for (var part in subDir.path.replaceFirst(dir.path + p.separator, '').split(p.separator)) {
          if (ignoredParams.contains(part)) {
            ignore = true;
            break;
          }
        }
        if (!ignore) iceFileList.addAll(subDir.listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path).isEmpty && element.lengthSync() > 0));
      }
    } else {
      iceFileList.addAll(dir.listSync(recursive: true).whereType<File>().where((element) =>
          p.extension(element.path).isEmpty &&
          RegExp(r'^[a-f0-9]').hasMatch(p.basename(element.path)) &&
          (p.basenameWithoutExtension(element.path).length == 30 || p.basenameWithoutExtension(element.path).length == 32)));
    }
    //listing mods with no ices in root
    // if (dir.listSync().whereType<File>().where((element) => p.extension(element.path).isEmpty && element.lengthSync() > 0).isEmpty) {
    //   pathsWithNoIceInRoot.add(dir.path);
    // }
  }

  //listing other files in temp
  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus(curLangText!.uiSortingOtherFiles);
  await Future.delayed(const Duration(milliseconds: 5));
  List<File> extraFileList = [];
  for (var dir in Directory(modManAddModsTempDirPath).listSync(recursive: false).whereType<Directory>()) {
    extraFileList.addAll(dir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path).isNotEmpty && element.lengthSync() > 0));
    //listing mods with no ices in root
    // if (dir.listSync().whereType<File>().where((element) => p.extension(element.path).isEmpty && element.lengthSync() > 0).isEmpty) {
    //   pathsWithNoIceInRoot.add(dir.path);
    // }
  }

  //get data for each ice
  List<CsvItem> foundItemData = [];
  List<File> iceFilesNotInItemData = [];
  for (var iceFile in iceFileList) {
    Provider.of<StateProvider>(context, listen: false)
        .setModAdderProgressStatus('${curLangText!.uiProcessing}:\n${iceFile.path.replaceFirst(modManAddModsTempDirPath + p.separator, '').replaceAll(p.separator, ' > ')}');
    await Future.delayed(const Duration(milliseconds: 5));
    final matchData = playerItemData
        .where((element) => element.containsIce(p.basenameWithoutExtension(iceFile.path)) && foundItemData.where((f) => f.containsIce(p.basenameWithoutExtension(iceFile.path))).isEmpty)
        .toList();
    if (extraItemName.isNotEmpty) {
      matchData.retainWhere((e) => e.getENName() == extraItemName || e.getJPName() == extraItemName);
    }
    // else {
    //   matchData.where((element) => (element.getENName().isNotEmpty || element.getJPName().isNotEmpty) || element.category == defaultCategoryDirs[17]);
    // }
    if (matchData.isNotEmpty) {
      if (modsAdderGroupSameItemVariants) {
        for (var data in matchData) {
          if (data.category != defaultCategoryDirs[7] && data.category != defaultCategoryDirs[14]) {
            int matchIndex = foundItemData.indexWhere((element) => element.getBaseItemENName().contains(data.getBaseItemENName()) || element.getBaseItemJPName().contains(data.getBaseItemJPName()));
            if (matchIndex != -1) foundItemData.removeAt(matchIndex);
          }
        }
      }
      foundItemData.addAll(matchData);
    } else if (foundItemData.where((f) => f.containsIce(p.basenameWithoutExtension(iceFile.path))).isEmpty) {
      iceFilesNotInItemData.add(iceFile);
    }
    // bool isFound = false;
    // for (var itemData in playerItemData) {
    //   if (itemData.containsIce(p.basenameWithoutExtension(iceFile.path)) && (itemData.getENName().isNotEmpty || itemData.getJPName().isNotEmpty)
    //     &&
    //     foundItemData.where((element) => element.getENName() == itemData.getENName() || element.getJPName() == itemData.getJPName()).isEmpty) {
    //     foundItemData.add(itemData);
    //     isFound = true;
    //     // } else if (itemData.containsIce(p.basenameWithoutExtension(iceFile.path)) && (itemData.getENName().isNotEmpty || itemData.getJPName().isNotEmpty)) {
    //     //   isFound = true;
    //   }
    // }
    // if (!isFound) iceFilesNotInItemData.add(iceFile);
  }

  //create file structures
  List<CsvItem> copiedCsvItems = [];
  DateTime nowData = DateTime.now();
  String formattedDateData = DateFormat('MM-dd-yyyy-kk-mm-ss').format(nowData);
  for (var data in foundItemData) {
    // Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus(
    //     'Sorting:\n${defaultCategoryNames[data.categoryIndex]} > ${modManCurActiveItemNameLanguage == 'JP' && data.getJPName().isNotEmpty ? data.getJPName() : data.getENName()}');
    await Future.delayed(const Duration(milliseconds: 5));
    String itemCategory = '';
    String itemName = '';

    int matchingIndex = copiedCsvItems.indexWhere((element) =>
        element.getENName().split('/').first.contains(data.getENName().split('/').first) ||
        element.getJPName().split('/').first.contains(data.getJPName().split('/').first) ||
        data.getENName().split('/').first.contains(element.getENName().split('/').first) ||
        data.getJPName().split('/').first.contains(element.getJPName().split('/').first));
    if (matchingIndex == -1) {
      //construct item name
      itemName = data.getENName();
      if ((modManCurActiveItemNameLanguage == 'JP' && data.getJPName().isNotEmpty) || itemName.isEmpty) {
        itemName = data.getJPName();
      }
      itemName = itemName.replaceAll(RegExp(charToReplace), '_').trim();

      //No name items
      if (itemName.isEmpty) {
        if (data.category == defaultCategoryDirs[17] && data.infos.entries.firstWhere((e) => e.key == 'Path').value.isNotEmpty) {
          itemName = p.basenameWithoutExtension(data.infos.entries.firstWhere((e) => e.key == 'Path').value);
        } else {
          itemName = '${curLangText!.uiUnknownItem}_$formattedDateData';
        }
      }

      //construct category
      itemCategory = data.category;
      if (itemName.contains('[Se]')) itemCategory = defaultCategoryDirs[16];
    } else {
      CsvItem matchingCsvItem = copiedCsvItems[matchingIndex];
      //construct item name
      itemName = matchingCsvItem.getENName();
      if ((modManCurActiveItemNameLanguage == 'JP' && matchingCsvItem.getJPName().isNotEmpty) || itemName.isEmpty) {
        itemName = matchingCsvItem.getJPName();
      }
      itemName = itemName.replaceAll(RegExp(charToReplace), '_').trim();
      //No name items
      if (itemName.isEmpty) {
        itemName = '${curLangText!.uiUnknownItem}_$formattedDateData';
      }

      //construct category
      itemCategory = matchingCsvItem.category;
      if (itemName.contains('[Se]')) itemCategory = defaultCategoryDirs[16];
    }

    //construct file structures
    String modAdderItemDirPath = Uri.file('$modManModsAdderPath/$itemCategory/$itemName').toFilePath().trim();
    for (var value in data.infos.values) {
      final matchingIceFiles = iceFileList.where((element) => value.contains(p.basenameWithoutExtension(element.path)));
      for (var iceFile in matchingIceFiles) {
        Provider.of<StateProvider>(context, listen: false)
            .setModAdderProgressStatus('${curLangText!.uiSorting}:\n${iceFile.path.replaceFirst(modManAddModsTempDirPath + p.separator, '').replaceAll(p.separator, ' > ')}');
        await Future.delayed(const Duration(milliseconds: 5));
        String newFilePath = iceFile.path.replaceFirst(modManAddModsTempDirPath, modAdderItemDirPath);
        newFilePath = await removeRebootPath(context, newFilePath);
        if (p.basenameWithoutExtension(File(newFilePath).parent.path) == itemName) {
          newFilePath = File(newFilePath).path.replaceFirst(File(newFilePath).parent.path, File(newFilePath).parent.path + p.separator + curLangText!.uiUnknown);
        }

        try {
          await File(newFilePath).parent.create(recursive: true);
          iceFile.copySync(newFilePath);
        } catch (e) {
          _errorMessage = e.toString();
        }
      }
    }

    //extra files copy
    for (var file in extraFileList) {
      String newFilePath = file.path.replaceFirst(modManAddModsTempDirPath, modAdderItemDirPath);
      newFilePath = await removeRebootPath(context, newFilePath);
      if (File(newFilePath).parent.existsSync()) {
        try {
          file.copySync(newFilePath);
        } catch (e) {
          _errorMessage = e.toString();
        }
      }
    }

    //download item icon from item database
    String itemIconPath = '';
    if (data.iconImagePath.isNotEmpty) {
      itemIconPath = '$modAdderItemDirPath/$itemName.png';
      final dio = Dio();
      String iconLink = modManMAIconDatabaseLink + data.iconImagePath.replaceAll('\\', '/');
      await dio.download(iconLink, itemIconPath);
    }

    if (modsAdderGroupSameItemVariants) copiedCsvItems.add(data);

    //create new item object
    ModsAdderItem newItem = ModsAdderItem(itemCategory, itemName, modAdderItemDirPath, itemIconPath, false, true, false, []);
    if (modsAdderItemList.where((element) => element.category == newItem.category && element.itemName == newItem.itemName && element.itemDirPath == newItem.itemDirPath).isEmpty) {
      modsAdderItemList.add(newItem);
    }
  }

  //ice files not in item data
  if (iceFilesNotInItemData.isNotEmpty) {
    List<String> miscFilePaths = [];
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
    String unknownItemName = '${curLangText!.uiUnknownItem}_$formattedDate';
    Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('${curLangText!.uiSorting}: ${defaultCategoryNames[13]} > $unknownItemName');
    await Future.delayed(const Duration(milliseconds: 5));
    String modAdderMiscItemDirPath = Uri.file('$modManModsAdderPath/${defaultCategoryDirs[13]}/$unknownItemName').toFilePath().trim();
    for (var file in iceFilesNotInItemData) {
      String newFilePath = file.path.replaceFirst(modManAddModsTempDirPath, modAdderMiscItemDirPath);
      newFilePath = await removeRebootPath(context, newFilePath);
      await File(newFilePath).parent.create(recursive: true);
      try {
        file.copySync(newFilePath);
        if (!miscFilePaths.contains(modAdderMiscItemDirPath)) miscFilePaths.add(modAdderMiscItemDirPath);
      } catch (e) {
        _errorMessage = e.toString();
      }
    }
    //extra files copy
    for (var file in extraFileList) {
      for (var path in miscFilePaths) {
        String newFilePath = file.path.replaceFirst(modManAddModsTempDirPath, path);
        newFilePath = await removeRebootPath(context, newFilePath);
        if (File(newFilePath).parent.existsSync()) {
          try {
            file.copySync(newFilePath);
          } catch (e) {
            _errorMessage = e.toString();
          }
        }
      }
    }
    //create new item object
    ModsAdderItem newItem = ModsAdderItem(defaultCategoryDirs[13], unknownItemName, modAdderMiscItemDirPath, '', false, true, false, []);
    if (modsAdderItemList.where((element) => element.category == newItem.category && element.itemName == newItem.itemName && element.itemDirPath == newItem.itemDirPath).isEmpty) {
      modsAdderItemList.add(newItem);
    }
  }

  //Sort to list
  for (var item in modsAdderItemList) {
    List<ModsAdderMod> mods = [];
    for (var modDir in Directory(item.itemDirPath).listSync().whereType<Directory>()) {
      List<ModsAdderSubMod> submods = [];
      for (var submodDir in Directory(modDir.path).listSync(recursive: true).whereType<Directory>()) {
        if (submodDir.listSync().whereType<File>().where((element) => p.extension(element.path) == '').isNotEmpty) {
          submods.add(ModsAdderSubMod(submodDir.path.replaceFirst(modDir.path + p.separator, '').replaceAll(p.separator, ' > '), submodDir.path, true, false,
              Directory(submodDir.path).listSync(recursive: false).whereType<File>().toList()));
        }
      }
      mods.add(ModsAdderMod(p.basename(modDir.path), modDir.path, true, false, false, submods, Directory(modDir.path).listSync().whereType<File>().toList()));
    }
    item.modList.addAll(mods);
  }

  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    if (element.existsSync()) {
      element.deleteSync(recursive: true);
    }
  });

  if (modsAdderItemList.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false).modAdderReloadTrue();
  }

  Provider.of<StateProvider>(context, listen: false).setModAdderProgressStatus('');

  return modsAdderItemList;
}

// String findIcePathInGameData(String iceName) {
//   if (iceName.isEmpty) {
//     return '';
//   }
//   int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
//   if (win32PathIndex != -1) {
//     return ogWin32FilePaths[win32PathIndex];
//   }
//   int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   if (win32NAPathIndex != -1) {
//     return ogWin32NAFilePaths[win32NAPathIndex];
//   }
//   int win32RebootPathIndex = ogWin32RebootFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   if (win32RebootPathIndex != -1) {
//     return ogWin32RebootFilePaths[win32RebootPathIndex];
//   }
//   int win32RebootNAPathIndex = ogWin32RebootNAFilePaths.indexWhere((element) => p.basename(element) == iceName);
//   if (win32RebootNAPathIndex != -1) {
//     return ogWin32RebootNAFilePaths[win32RebootNAPathIndex];
//   }
//   return '';
// }

Future<String> removeRebootPath(context, String filePath) async {
  if (filePath.isEmpty) return filePath;
  String newPath = filePath;
  final ogPaths = await originalFilePathGet(context, p.basenameWithoutExtension(filePath));
  String ogPath = '';
  if (ogPaths.isNotEmpty) ogPath = ogPaths.first;

  if (ogPath.isEmpty) {
    return filePath;
  } else {
    String trimmedPath = ogPath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), '');
    final toRemovePathNames = p.dirname(trimmedPath).split(p.separator);
    List<String> newPathSplit = newPath.split(p.separator);
    for (var name in toRemovePathNames) {
      newPathSplit.remove(name);
    }
    newPath = p.joinAll(newPathSplit);
    if (Platform.isLinux) newPath = p.separator + newPath;
  }

  return newPath;
}

List<ModsAdderItem> getDuplicates(List<ModsAdderItem> processedList) {
  List<ModsAdderItem> returnList = processedList;
  _duplicateCounter = 0;
  for (var item in returnList) {
    if (item.toBeAdded) {
      for (var mod in item.modList) {
        if (mod.toBeAdded) {
          if (mod.filesInMod.isNotEmpty) {
            String modDirPathInMods = mod.modDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
            if (Directory(modDirPathInMods).existsSync() && Directory(modDirPathInMods).listSync().isNotEmpty) {
              mod.isDuplicated = true;
              item.isChildrenDuplicated = true;
              _duplicateCounter++;
            } else {
              mod.isDuplicated = false;
              item.isChildrenDuplicated = false;
            }
          } else {
            for (var submod in mod.submodList) {
              if (submod.toBeAdded) {
                String submodDirinMods = submod.submodDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath);
                if (Directory(submodDirinMods).existsSync() && Directory(submodDirinMods).listSync().isNotEmpty) {
                  submod.isDuplicated = true;
                  mod.isChildrenDuplicated = true;
                  item.isChildrenDuplicated = true;
                  _duplicateCounter++;
                } else {
                  submod.isDuplicated = false;
                  mod.isChildrenDuplicated = false;
                  item.isChildrenDuplicated = false;
                }
              }
            }
          }
        }
      }
    }
  }

  return returnList;
}

Future<List<ModsAdderItem>> replaceNamesOfDuplicates(List<ModsAdderItem> processedList) async {
  List<ModsAdderItem> returnList = processedList;
  for (var item in returnList) {
    for (var mod in item.modList) {
      if (mod.isDuplicated) {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
        mod.modName = '${mod.modName}_$formattedDate';
        var newModDir = await Directory(mod.modDirPath).rename(Uri.file('${p.dirname(mod.modDirPath)}/${mod.modName}').toFilePath());
        mod.setNewParentPathToChildren(newModDir.path.trim());
        mod.modDirPath = newModDir.path;
        _duplicateCounter--;
      } else if (mod.isChildrenDuplicated) {
        for (var submod in mod.submodList) {
          if (submod.isDuplicated) {
            DateTime now = DateTime.now();
            String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
            List<String> submodNameParts = submod.submodName.split(' > ');
            String submodName = submodNameParts.removeLast();
            submodName = '${submodName}_$formattedDate';
            submodNameParts.add(submodName);
            submod.submodName = submodNameParts.join(' > ');
            //submod.submodName = '${submod.submodName}_$formattedDate';
            var newSubmodDir = await Directory(submod.submodDirPath).rename(Uri.file('${p.dirname(submod.submodDirPath)}/$submodName').toFilePath());
            submod.files = newSubmodDir.listSync(recursive: true).whereType<File>().toList();
            submod.submodDirPath = newSubmodDir.path;
            _duplicateCounter--;
          }
        }
      }
    }
  }

  return returnList;
}

void modsAdderUnsupportedFileTypeDialog(context, String fileName) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            titlePadding: const EdgeInsets.all(16),
            title: Text(curLangText!.uiError),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            content: Text('"$fileName" ${curLangText!.uiAchiveCurrentlyNotSupported}'),
            actionsPadding: const EdgeInsets.all(16),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(curLangText!.uiReturn))
            ],
          ));
}
