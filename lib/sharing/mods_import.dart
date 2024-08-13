// ignore_for_file: unused_import

import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
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
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_add_function.dart';
import 'package:pso2_mod_manager/sharing/mod_import_add_function.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:io/io.dart' as io;
import 'package:super_sliver_list/super_sliver_list.dart';

bool importDropZoneMax = true;
bool _newModDragging = false;
List<XFile> importModDragDropFiles = [];
Future? processedImportedFileListLoad;
List<ModsAdderItem> processedImportFileList = [];
List<String> _selectedCategories = [];
TextEditingController renameImportTextBoxController = TextEditingController();
List<bool> _itemNameRenameIndex = [];
List<List<bool>> mainImportedFolderRenameIndex = [];
List<List<List<bool>>> subImportedFoldersRenameIndex = [];
bool _isNameEditing = false;
int _duplicateCounter = 0;
final _subItemFormValidate = GlobalKey<FormState>();
bool _isAddingMods = false;
bool _isProcessingMoreFiles = false;
int _pathLengthInNameEdit = 0;

void modsImportHomePage(context) {
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
                              'MOD IMPORT',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 15),
                            )),
                        VerticalDivider(
                          width: 10,
                          thickness: 2,
                          indent: 5,
                          endIndent: 5,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                        SizedBox(
                            width: importDropZoneMax
                                ? constraints.maxWidth * 0.7
                                : importModDragDropFiles.isEmpty
                                    ? constraints.maxWidth * 0.3
                                    : constraints.maxWidth * 0.45,
                            child: Column(
                              children: [
                                DropTarget(
                                  //enable: true,
                                  onDragDone: (detail) async {
                                    for (var element in detail.files) {
                                      if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                        modsAdderUnsupportedFileTypeDialog(context, p.basename(element.path));
                                      } else if (importModDragDropFiles.indexWhere((file) => file.path == element.path) == -1) {
                                        importModDragDropFiles.add(element);
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
                                        height: importDropZoneMax ? constraints.maxHeight - 42 : constraints.maxHeight - 75,
                                        //width: constraints.maxWidth * 0.45,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (importModDragDropFiles.isEmpty)
                                              Center(
                                                  child: Text(
                                                curLangText!.uiImportModDragDrop,
                                                style: const TextStyle(fontSize: 20),
                                                textAlign: TextAlign.center,
                                              )),
                                            if (importModDragDropFiles.isNotEmpty)
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
                                                            itemCount: importModDragDropFiles.length,
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
                                                                        importModDragDropFiles.removeAt(index);
                                                                        setState(
                                                                          () {},
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                                title: Text(importModDragDropFiles[index].name),
                                                                subtitle: Text(
                                                                  importModDragDropFiles[index].path,
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
                                  visible: !importDropZoneMax,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        // Expanded(
                                        //   child: SizedBox(
                                        //     width: double.infinity,
                                        //     child: ElevatedButton(
                                        //         onPressed: (() async {
                                        //           List<String?> selectedDirPaths = await getDirectoryPaths();
                                        //           if (selectedDirPaths.isNotEmpty) {
                                        //             importModDragDropFiles.addAll(selectedDirPaths.map((e) => XFile(e!)));
                                        //           }
                                        //           setState(
                                        //             () {},
                                        //           );
                                        //         }),
                                        //         child: Text(curLangText!.uiAddFolders)),
                                        //   ),
                                        // ),
                                        // const SizedBox(
                                        //   width: 5,
                                        // ),
                                        Expanded(
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                                onPressed: (() async {
                                                  XTypeGroup typeGroup = const XTypeGroup(
                                                    label: '.zip',
                                                    extensions: <String>['zip'],
                                                  );
                                                  List<XFile?> selectedDirPaths = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                  if (selectedDirPaths.isNotEmpty) {
                                                    importModDragDropFiles.addAll(selectedDirPaths.map((e) => e!));
                                                  }
                                                  setState(
                                                    () {},
                                                  );
                                                }),
                                                child: Text(curLangText!.uiAddFiles)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Visibility(
                                //   visible: !importDropZoneMax,
                                //   child: Padding(
                                //     padding: const EdgeInsets.only(top: 5),
                                //     child: SizedBox(
                                //       width: double.infinity,
                                //       child: ElevatedButton(
                                //           onPressed: importModDragDropFiles.isNotEmpty
                                //               ? (() async {
                                //                   final prefs = await SharedPreferences.getInstance();
                                //                   if (modsAdderGroupSameItemVariants) {
                                //                     modsAdderGroupSameItemVariants = false;
                                //                     prefs.setBool('modsAdderGroupSameItemVariants', false);
                                //                   } else {
                                //                     modsAdderGroupSameItemVariants = true;
                                //                     prefs.setBool('modsAdderGroupSameItemVariants', true);
                                //                   }
                                //                   setState(
                                //                     () {},
                                //                   );
                                //                 })
                                //               : null,
                                //           child: Text(modsAdderGroupSameItemVariants
                                //               ? '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiON}'
                                //               : '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiOFF}')),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  //width: constraints.maxWidth * 0.7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                            onPressed: importModDragDropFiles.isNotEmpty
                                                ? (() {
                                                    importModDragDropFiles.clear();
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
                                        // Visibility(
                                        //   visible: importDropZoneMax,
                                        //   child: Expanded(
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(right: 5),
                                        //       child: ElevatedButton(
                                        //           onPressed: importModDragDropFiles.isNotEmpty
                                        //               ? (() async {
                                        //                   final prefs = await SharedPreferences.getInstance();
                                        //                   if (modsAdderGroupSameItemVariants) {
                                        //                     modsAdderGroupSameItemVariants = false;
                                        //                     prefs.setBool('modsAdderGroupSameItemVariants', false);
                                        //                   } else {
                                        //                     modsAdderGroupSameItemVariants = true;
                                        //                     prefs.setBool('modsAdderGroupSameItemVariants', true);
                                        //                   }
                                        //                   setState(
                                        //                     () {},
                                        //                   );
                                        //                 })
                                        //               : null,
                                        //           child: Text(modsAdderGroupSameItemVariants
                                        //               ? '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiON}'
                                        //               : '${curLangText!.uiGroupSameItemVariants}: ${curLangText!.uiOFF}')),
                                        //     ),
                                        //   ),
                                        // ),
                                        // Visibility(
                                        //   visible: importDropZoneMax,
                                        //   child: Expanded(
                                        //     child: Padding(
                                        //       padding: const EdgeInsets.only(right: 5),
                                        //       child: ElevatedButton(
                                        //           onPressed: (() async {
                                        //             List<String?> selectedDirPaths = await getDirectoryPaths();
                                        //             if (selectedDirPaths.isNotEmpty) {
                                        //               importModDragDropFiles.addAll(selectedDirPaths.map((e) => XFile(e!)));
                                        //             }
                                        //             setState(
                                        //               () {},
                                        //             );
                                        //           }),
                                        //           child: Text(curLangText!.uiAddFolders)),
                                        //     ),
                                        //   ),
                                        // ),
                                        Visibility(
                                          visible: importDropZoneMax,
                                          child: Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: ElevatedButton(
                                                  onPressed: (() async {
                                                    XTypeGroup typeGroup = const XTypeGroup(
                                                      label: '.zip',
                                                      extensions: <String>['zip'],
                                                    );
                                                    List<XFile?> selectedDirPaths = await openFiles(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                    if (selectedDirPaths.isNotEmpty) {
                                                      importModDragDropFiles.addAll(selectedDirPaths.map((e) => e!));
                                                    }
                                                    setState(
                                                      () {},
                                                    );
                                                  }),
                                                  child: Text(curLangText!.uiAddFiles)),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary.withBlue(150)),
                                              onPressed: importModDragDropFiles.isNotEmpty
                                                  ? (() async {
                                                      if (processedImportFileList.isNotEmpty) {
                                                        _isProcessingMoreFiles = true;
                                                        setState(
                                                          () {},
                                                        );
                                                      }
                                                      processedImportedFileListLoad = modsImportFilesProcess(context, importModDragDropFiles.toList());
                                                      importModDragDropFiles.clear();
                                                      importDropZoneMax = false;
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
                                    future: processedImportedFileListLoad,
                                    builder: (
                                      BuildContext context,
                                      AsyncSnapshot snapshot,
                                    ) {
                                      if (snapshot.connectionState == ConnectionState.waiting && processedImportFileList.isEmpty) {
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
                                                  height: 5,
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      clearAllTempDirs();
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text(curLangText!.uiReturn))
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
                                                  curLangText!.uiProcessingFiles,
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
                                          if (Provider.of<StateProvider>(context, listen: false).modAdderReload) {
                                            bool renameModDifferencesFound = false;
                                            //sort item to add list
                                            for (ModsAdderItem element in snapshot.data) {
                                              int matchingItemIndex = processedImportFileList.indexWhere((item) => item.itemDirPath == element.itemDirPath);
                                              if (matchingItemIndex == -1 && Directory(element.itemDirPath).existsSync()) {
                                                processedImportFileList.add(element);
                                              } else if (matchingItemIndex != -1) {
                                                int ogModListLength = processedImportFileList[matchingItemIndex].modList.length;
                                                processedImportFileList[matchingItemIndex]
                                                    .modList
                                                    .addAll(element.modList.where((mod) => processedImportFileList[matchingItemIndex].modList.indexWhere((e) => e.modDirPath == mod.modDirPath) == -1));
                                                if (ogModListLength < processedImportFileList[matchingItemIndex].modList.length) {
                                                  renameModDifferencesFound = true;
                                                }
                                              }
                                            }

                                            //rename trigger
                                            if (_itemNameRenameIndex.isNotEmpty && _itemNameRenameIndex.length != processedImportFileList.length) {
                                              for (int i = 0; i < mainImportedFolderRenameIndex.length; i++) {
                                                if (processedImportFileList[i].modList.length != mainImportedFolderRenameIndex[i].length) {
                                                  renameModDifferencesFound = true;
                                                  break;
                                                }
                                              }
                                            }
                                            if (_itemNameRenameIndex.isEmpty || _itemNameRenameIndex.length != processedImportFileList.length || renameModDifferencesFound) {
                                              renameModDifferencesFound = false;
                                              _itemNameRenameIndex = List.generate(processedImportFileList.length, (index) => false);
                                              mainImportedFolderRenameIndex =
                                                  List.generate(processedImportFileList.length, (index) => List.generate(processedImportFileList[index].modList.length, (mIndex) => false));
                                              subImportedFoldersRenameIndex = List.generate(
                                                  processedImportFileList.length,
                                                  (index) => List.generate(processedImportFileList[index].modList.length,
                                                      (mIndex) => List.generate(processedImportFileList[index].modList[mIndex].submodList.length, (sIndex) => false)));
                                            }
                                            //misc dropdown
                                            if (_selectedCategories.isEmpty) {
                                              for (var element in processedImportFileList) {
                                                _selectedCategories.add(element.category);
                                              }
                                            } else if (_selectedCategories.isNotEmpty && _selectedCategories.length < processedImportFileList.length) {
                                              _selectedCategories.clear();
                                              for (var element in processedImportFileList) {
                                                _selectedCategories.add(element.category);
                                              }
                                            }
                                            //get duplicates
                                            processedImportFileList = getDuplicates(processedImportFileList);

                                            pathCharLengthList = List.generate(processedImportFileList.length, (index) => []);

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
                                                      itemCount: processedImportFileList.length,
                                                      itemBuilder: (context, index) {
                                                        if (processedImportFileList.isNotEmpty) {
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
                                                                      child: processedImportFileList[index].itemIconPath.isEmpty
                                                                          ? Image.asset(
                                                                              'assets/img/placeholdersquare.png',
                                                                              fit: BoxFit.fitWidth,
                                                                            )
                                                                          : Image.file(
                                                                              File(processedImportFileList[index].itemIconPath),
                                                                              fit: BoxFit.fitWidth,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        if (processedImportFileList[index].isUnknown)
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
                                                                              String newItemPath = processedImportFileList[index].itemDirPath.replaceFirst(
                                                                                  p.dirname(processedImportFileList[index].itemDirPath),
                                                                                  Uri.file('$modManImportedDirPath/${_selectedCategories[index]}').toFilePath());
                                                                              await io.copyPath(processedImportFileList[index].itemDirPath, newItemPath);
                                                                              //delete item dir
                                                                              Directory(processedImportFileList[index].itemDirPath).deleteSync(recursive: true);
                                                                              //delete parent dir if empty
                                                                              if (Directory(p.dirname(processedImportFileList[index].itemDirPath)).listSync().isEmpty) {
                                                                                Directory(p.dirname(processedImportFileList[index].itemDirPath)).deleteSync(recursive: true);
                                                                              }
                                                                              processedImportFileList[index].setNewParentPathToChildren(newItemPath.trim());
                                                                              processedImportFileList[index].itemDirPath = newItemPath;
                                                                              processedImportFileList[index].category = value.toString();
                                                                              debugPrint(processedImportFileList[index].itemDirPath);
                                                                              setState(
                                                                                () {},
                                                                              );
                                                                            },
                                                                          ),
                                                                        if (!processedImportFileList[index].isUnknown)
                                                                          SizedBox(
                                                                            width: 150,
                                                                            height: 40,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 10),
                                                                              child: Text(processedImportFileList[index].category,
                                                                                  style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: !processedImportFileList[index].toBeAdded
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
                                                                                        // height: 40,
                                                                                        child: Form(
                                                                                          key: _subItemFormValidate,
                                                                                          child: TextFormField(
                                                                                            autofocus: true,
                                                                                            controller: renameImportTextBoxController,
                                                                                            maxLines: 1,
                                                                                            maxLength: 50,
                                                                                            decoration: InputDecoration(
                                                                                              contentPadding: const EdgeInsets.only(left: 10, top: 10),
                                                                                              border: const OutlineInputBorder(),
                                                                                              hintText: processedImportFileList[index].itemName,
                                                                                              counterText: '',
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                            validator: (value) {
                                                                                              if (value == null || value.isEmpty) {
                                                                                                // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                return curLangText!.uiNameCannotBeEmpty;
                                                                                              }

                                                                                              if (Directory(p.dirname(processedImportFileList[index].itemDirPath.replaceFirst(modManModsAdderPath, modManModsDirPath)))
                                                                                                  .listSync()
                                                                                                  .whereType<Directory>()
                                                                                                  .where((element) => p.basename(element.path).toLowerCase() == value.toLowerCase())
                                                                                                  .isNotEmpty) {
                                                                                                // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                return curLangText!.uiNameAlreadyExisted;
                                                                                              }

                                                                                              if (renameImportTextBoxController.text.characters.last == ' ') {
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
                                                                                              if (renameImportTextBoxController.text != processedImportFileList[index].itemName &&
                                                                                                  _subItemFormValidate.currentState!.validate()) {
                                                                                                if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                  //rename text
                                                                                                  String newItemName = renameImportTextBoxController.text.trim();
                                                                                                  if (processedImportFileList[index].category == 'Basewears' &&
                                                                                                      !renameImportTextBoxController.text.contains('[Ba]')) {
                                                                                                    newItemName += ' [Ba]';
                                                                                                  } else if (processedImportFileList[index].category == 'Innerwears' &&
                                                                                                      !renameImportTextBoxController.text.contains('[In]')) {
                                                                                                    newItemName += ' [In]';
                                                                                                  } else if (processedImportFileList[index].category == 'Outerwears' &&
                                                                                                      !renameImportTextBoxController.text.contains('[Ou]')) {
                                                                                                    newItemName += ' [Ou]';
                                                                                                  } else if (processedImportFileList[index].category == 'Setwears' &&
                                                                                                      !renameImportTextBoxController.text.contains('[Se]')) {
                                                                                                    newItemName += ' [Se]';
                                                                                                  } else {
                                                                                                    newItemName = renameImportTextBoxController.text;
                                                                                                  }
                                                                                                  //change dir name
                                                                                                  processedImportFileList[index].itemName = newItemName;
                                                                                                  var newItemDir = await Directory(processedImportFileList[index].itemDirPath).rename(
                                                                                                      Uri.file('${p.dirname(processedImportFileList[index].itemDirPath)}/$newItemName').toFilePath());
                                                                                                  processedImportFileList[index].setNewParentPathToChildren(newItemDir.path.trim());
                                                                                                  processedImportFileList[index].itemIconPath = processedImportFileList[index]
                                                                                                      .itemIconPath
                                                                                                      .replaceFirst(processedImportFileList[index].itemDirPath, newItemDir.path);
                                                                                                  processedImportFileList[index].itemDirPath = newItemDir.path;
                                                                                                }

                                                                                                _itemNameRenameIndex[index] = false;
                                                                                                renameImportTextBoxController.clear();
                                                                                                _isNameEditing = false;
                                                                                                _duplicateCounter--;

                                                                                                setState(
                                                                                                  () {},
                                                                                                );
                                                                                              }
                                                                                              setState(
                                                                                                () {},
                                                                                              );
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
                                                                                        onPressed: renameImportTextBoxController.text == processedImportFileList[index].itemName
                                                                                            ? null
                                                                                            : () async {
                                                                                                if (_subItemFormValidate.currentState!.validate() &&
                                                                                                    renameImportTextBoxController.text != processedImportFileList[index].itemName) {
                                                                                                  if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                    //rename text
                                                                                                    String newItemName = renameImportTextBoxController.text.trim();
                                                                                                    if (processedImportFileList[index].category == 'Basewears' &&
                                                                                                        !renameImportTextBoxController.text.contains('[Ba]')) {
                                                                                                      newItemName += ' [Ba]';
                                                                                                    } else if (processedImportFileList[index].category == 'Innerwears' &&
                                                                                                        !renameImportTextBoxController.text.contains('[In]')) {
                                                                                                      newItemName += ' [In]';
                                                                                                    } else if (processedImportFileList[index].category == 'Outerwears' &&
                                                                                                        !renameImportTextBoxController.text.contains('[Ou]')) {
                                                                                                      newItemName += ' [Ou]';
                                                                                                    } else if (processedImportFileList[index].category == 'Setwears' &&
                                                                                                        !renameImportTextBoxController.text.contains('[Se]')) {
                                                                                                      newItemName += ' [Se]';
                                                                                                    } else {
                                                                                                      newItemName = renameImportTextBoxController.text;
                                                                                                    }
                                                                                                    //change dir name
                                                                                                    processedImportFileList[index].itemName = newItemName;
                                                                                                    var newItemDir = await Directory(processedImportFileList[index].itemDirPath).rename(
                                                                                                        Uri.file('${p.dirname(processedImportFileList[index].itemDirPath)}/$newItemName').toFilePath());
                                                                                                    processedImportFileList[index].setNewParentPathToChildren(newItemDir.path.trim());
                                                                                                    processedImportFileList[index].itemIconPath = processedImportFileList[index]
                                                                                                        .itemIconPath
                                                                                                        .replaceFirst(processedImportFileList[index].itemDirPath, newItemDir.path);
                                                                                                    processedImportFileList[index].itemDirPath = newItemDir.path;
                                                                                                  }

                                                                                                  _itemNameRenameIndex[index] = false;
                                                                                                  renameImportTextBoxController.clear();
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
                                                                                          renameImportTextBoxController.clear();
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
                                                                                        child: Text(processedImportFileList[index].itemName.replaceAll('_', '/'),
                                                                                            style: TextStyle(
                                                                                                fontWeight: FontWeight.w600,
                                                                                                color: !processedImportFileList[index].toBeAdded
                                                                                                    ? Theme.of(context).disabledColor
                                                                                                    : Theme.of(context).textTheme.bodyMedium!.color)),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    if (processedImportFileList[index].isChildrenDuplicated)
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
                                                                                      visible: !defaultCategoryNames.contains(processedImportFileList[index].category) ||
                                                                                          processedImportFileList[index].category == defaultCategoryNames[13],
                                                                                      child: SizedBox(
                                                                                        width: 40,
                                                                                        child: Tooltip(
                                                                                          message: curLangText!.uiEditName,
                                                                                          height: 25,
                                                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                                          waitDuration: const Duration(seconds: 1),
                                                                                          child: MaterialButton(
                                                                                            onPressed: !_isNameEditing && processedImportFileList[index].toBeAdded
                                                                                                ? () {
                                                                                                    renameImportTextBoxController.text = processedImportFileList[index].itemName;
                                                                                                    renameImportTextBoxController.selection = TextSelection(
                                                                                                      baseOffset: 0,
                                                                                                      extentOffset: renameImportTextBoxController.text.length,
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
                                                                                    if (processedImportFileList[index].toBeAdded)
                                                                                      SizedBox(
                                                                                        width: 40,
                                                                                        child: ModManTooltip(
                                                                                          message: curLangText!.uiMarkThisNotToBeAdded,
                                                                                          child: MaterialButton(
                                                                                            onPressed: () {
                                                                                              processedImportFileList[index].toBeAdded = false;
                                                                                              for (var mod in processedImportFileList[index].modList) {
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
                                                                                    if (!processedImportFileList[index].toBeAdded)
                                                                                      SizedBox(
                                                                                        width: 40,
                                                                                        child: ModManTooltip(
                                                                                          message: curLangText!.uiMarkThisToBeAdded,
                                                                                          child: MaterialButton(
                                                                                            onPressed: () {
                                                                                              processedImportFileList[index].toBeAdded = true;
                                                                                              for (var mod in processedImportFileList[index].modList) {
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
                                                                    itemCount: processedImportFileList[index].modList.length,
                                                                    itemBuilder: (context, mIndex) {
                                                                      var curMod = processedImportFileList[index].modList[mIndex];
                                                                      _isProcessingMoreFiles = false;
                                                                      //rename trigger
                                                                      // //List<bool> mainImportedFolderRenameIndex = [];
                                                                      // if (mainImportedFolderRenameIndex.isEmpty || mainImportedFolderRenameIndex.length != processedImportFileList[index].modList.length) {
                                                                      //   mainImportedFolderRenameIndex = List.generate(processedImportFileList[index].modList.length, (index) => false);
                                                                      // }
                                                                      // if (pathCharLengthList[index].isNotEmpty) {
                                                                      //   pathCharLengthList[index].clear();
                                                                      // }

                                                                      int pathLength = 0;
                                                                      for (var file in curMod.filesInMod) {
                                                                        String tempPath = file.path.replaceFirst(modManImportedDirPath, modManModsDirPath);
                                                                        if (tempPath.length > pathLength) {
                                                                          pathLength = tempPath.length;
                                                                        }
                                                                      }
                                                                      for (var sub in curMod.submodList) {
                                                                        for (var modFile in sub.files) {
                                                                          String tempPath = modFile.path.replaceFirst(modManImportedDirPath, modManModsDirPath);
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
                                                                        title: mainImportedFolderRenameIndex[index][mIndex]
                                                                            ? Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: SizedBox(
                                                                                      //width: constraints.maxWidth * 0.4,
                                                                                      // height: 40,
                                                                                      child: Form(
                                                                                        key: _subItemFormValidate,
                                                                                        child: TextFormField(
                                                                                          autofocus: true,
                                                                                          controller: renameImportTextBoxController,
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

                                                                                            if (Directory(processedImportFileList[index]
                                                                                                    .modList[mIndex]
                                                                                                    .modDirPath
                                                                                                    .replaceFirst(modManModsAdderPath, modManModsDirPath))
                                                                                                .parent
                                                                                                .listSync()
                                                                                                .whereType<Directory>()
                                                                                                .where((e) => p.basename(e.path) == renameImportTextBoxController.value.text)
                                                                                                .isNotEmpty) {
                                                                                              // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                              return curLangText!.uiNameAlreadyExisted;
                                                                                            }

                                                                                            if (renameImportTextBoxController.text.characters.last == ' ') {
                                                                                              return curLangText!.uiNameCannotHaveSpacesAtTheEnd;
                                                                                            }

                                                                                            return null;
                                                                                          },
                                                                                          onChanged: (value) {
                                                                                            int pathLength = 0;
                                                                                            for (var file in curMod.filesInMod) {
                                                                                              String tempPath = file.path.replaceFirst(modManImportedDirPath, modManModsDirPath);
                                                                                              if (tempPath.length > pathLength) {
                                                                                                pathLength = tempPath.length;
                                                                                              }
                                                                                            }
                                                                                            for (var sub in curMod.submodList) {
                                                                                              for (var modFile in sub.files) {
                                                                                                String tempPath = modFile.path
                                                                                                    .replaceFirst(modManImportedDirPath, modManModsDirPath)
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
                                                                                            if (renameImportTextBoxController.text != curMod.modName && _subItemFormValidate.currentState!.validate()) {
                                                                                              if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                curMod.modName = renameImportTextBoxController.text;
                                                                                                var newModDir = await Directory(curMod.modDirPath).rename(
                                                                                                    Uri.file('${p.dirname(curMod.modDirPath)}/${renameImportTextBoxController.text}').toFilePath());
                                                                                                curMod.setNewParentPathToChildren(newModDir.path.trim());
                                                                                                curMod.modDirPath = newModDir.path;
                                                                                              }

                                                                                              mainImportedFolderRenameIndex[index][mIndex] = false;
                                                                                              renameImportTextBoxController.clear();
                                                                                              _isNameEditing = false;
                                                                                              _duplicateCounter--;

                                                                                              setState(
                                                                                                () {},
                                                                                              );
                                                                                            }
                                                                                            setState(
                                                                                              () {},
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  Text('$_pathLengthInNameEdit/259 ${curLangText!.uiCharacters}',
                                                                                      style: TextStyle(color: pathCharLengthList[index][mIndex] > 259 ? Colors.red : null)),
                                                                                  const SizedBox(
                                                                                    width: 5,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 40,
                                                                                    child: MaterialButton(
                                                                                      onPressed: renameImportTextBoxController.text == curMod.modName
                                                                                          ? null
                                                                                          : () async {
                                                                                              if (_subItemFormValidate.currentState!.validate() &&
                                                                                                  renameImportTextBoxController.text != curMod.modName) {
                                                                                                if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                  curMod.modName = renameImportTextBoxController.text;
                                                                                                  var newModDir = await Directory(curMod.modDirPath).rename(
                                                                                                      Uri.file('${p.dirname(curMod.modDirPath)}/${renameImportTextBoxController.text}').toFilePath());
                                                                                                  curMod.setNewParentPathToChildren(newModDir.path.trim());
                                                                                                  curMod.modDirPath = newModDir.path;
                                                                                                }

                                                                                                mainImportedFolderRenameIndex[index][mIndex] = false;
                                                                                                renameImportTextBoxController.clear();
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
                                                                                        mainImportedFolderRenameIndex[index][mIndex] = false;
                                                                                        renameImportTextBoxController.clear();
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
                                                                                    style: TextStyle(color: pathCharLengthList[index][mIndex] > 259 ? Colors.red : null),
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
                                                                                                renameImportTextBoxController.text = curMod.modName;
                                                                                                renameImportTextBoxController.selection = TextSelection(
                                                                                                  baseOffset: 0,
                                                                                                  extentOffset: renameImportTextBoxController.text.length,
                                                                                                );
                                                                                                _isNameEditing = true;
                                                                                                mainImportedFolderRenameIndex[index][mIndex] = true;
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
                                                                                            if (processedImportFileList[index].modList.where((element) => element.toBeAdded).isEmpty) {
                                                                                              processedImportFileList[index].toBeAdded = false;
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
                                                                                            if (processedImportFileList[index].modList.where((element) => element.toBeAdded).isNotEmpty) {
                                                                                              processedImportFileList[index].toBeAdded = true;
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
                                                                                    title: subImportedFoldersRenameIndex[index][mIndex][sIndex]
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: SizedBox(
                                                                                                  // height: context.watch<StateProvider>().itemAdderSubItemETHeight,
                                                                                                  child: Form(
                                                                                                    key: _subItemFormValidate,
                                                                                                    child: TextFormField(
                                                                                                      autofocus: true,
                                                                                                      controller: renameImportTextBoxController,
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
                                                                                                            .parent
                                                                                                            .listSync()
                                                                                                            .whereType<Directory>()
                                                                                                            .where((e) => p.basename(e.path) == renameImportTextBoxController.value.text)
                                                                                                            .isNotEmpty) {
                                                                                                          // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                          return curLangText!.uiNameAlreadyExisted;
                                                                                                        }

                                                                                                        if (renameImportTextBoxController.text.characters.last == ' ') {
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
                                                                                                        if (renameImportTextBoxController.text != curSubmod.submodName.split(' > ').last &&
                                                                                                            _subItemFormValidate.currentState!.validate()) {
                                                                                                          if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                            List<String> submodNameParts = curSubmod.submodName.split(' > ');
                                                                                                            submodNameParts.removeLast();
                                                                                                            submodNameParts.add(renameImportTextBoxController.text);
                                                                                                            curSubmod.submodName = submodNameParts.join(' > ');
                                                                                                            var newSubmodDir = await Directory(curSubmod.submodDirPath).rename(
                                                                                                                Uri.file('${p.dirname(curSubmod.submodDirPath)}/${renameImportTextBoxController.text}')
                                                                                                                    .toFilePath());
                                                                                                            curSubmod.files = newSubmodDir.listSync(recursive: true).whereType<File>().toList();
                                                                                                            curSubmod.submodDirPath = newSubmodDir.path;
                                                                                                          }

                                                                                                          //Clear
                                                                                                          // ignore: use_build_context_synchronously
                                                                                                          // Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                          subImportedFoldersRenameIndex[index][mIndex][sIndex] = false;
                                                                                                          renameImportTextBoxController.clear();
                                                                                                          _isNameEditing = false;
                                                                                                          setState(
                                                                                                            () {},
                                                                                                          );
                                                                                                        }
                                                                                                        setState(
                                                                                                          () {},
                                                                                                        );
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
                                                                                                  onPressed: renameImportTextBoxController.text == curSubmod.submodName
                                                                                                      ? null
                                                                                                      : () async {
                                                                                                          if (_subItemFormValidate.currentState!.validate()) {
                                                                                                            if (renameImportTextBoxController.text.isNotEmpty) {
                                                                                                              List<String> submodNameParts = curSubmod.submodName.split(' > ');
                                                                                                              submodNameParts.removeLast();
                                                                                                              submodNameParts.add(renameImportTextBoxController.text);
                                                                                                              curSubmod.submodName = submodNameParts.join(' > ');
                                                                                                              var newSubmodDir = await Directory(curSubmod.submodDirPath).rename(Uri.file(
                                                                                                                      '${p.dirname(curSubmod.submodDirPath)}/${renameImportTextBoxController.text}')
                                                                                                                  .toFilePath());
                                                                                                              curSubmod.files = newSubmodDir.listSync(recursive: true).whereType<File>().toList();
                                                                                                              curSubmod.submodDirPath = newSubmodDir.path;
                                                                                                            }

                                                                                                            //Clear
                                                                                                            subImportedFoldersRenameIndex[index][mIndex][sIndex] = false;
                                                                                                            renameImportTextBoxController.clear();
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
                                                                                                    subImportedFoldersRenameIndex[index][mIndex][sIndex] = false;
                                                                                                    renameImportTextBoxController.clear();
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
                                                                                                            renameImportTextBoxController.text = curSubmod.submodName.split(' > ').last;
                                                                                                            renameImportTextBoxController.selection = TextSelection(
                                                                                                              baseOffset: 0,
                                                                                                              extentOffset: renameImportTextBoxController.text.length,
                                                                                                            );
                                                                                                            subImportedFoldersRenameIndex[index][mIndex][sIndex] = true;
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
                                                                                                        if (processedImportFileList[index].modList.where((element) => element.toBeAdded).isEmpty) {
                                                                                                          processedImportFileList[index].toBeAdded = false;
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
                                                                                                        if (processedImportFileList[index].modList.where((element) => element.toBeAdded).isNotEmpty) {
                                                                                                          processedImportFileList[index].toBeAdded = true;
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
                                                                  _isAddingMods ? curLangText!.uiAddingMods : curLangText!.uiWaitingForData,
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
                                                        return null;
                                                      }),
                                                ),
                                                if (_isProcessingMoreFiles)
                                                  Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          curLangText!.uiProcessingFiles,
                                                          style: const TextStyle(fontSize: 20),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        const CircularProgressIndicator(),
                                                      ],
                                                    ),
                                                  )
                                              ],
                                            );
                                          } else {
                                            return Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _isAddingMods ? curLangText!.uiAddingMods : curLangText!.uiWaitingForData,
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
                                      flex: importDropZoneMax ? 1 : 0,
                                      child: ElevatedButton(
                                          onPressed: _isAddingMods
                                              ? null
                                              : (() async {
                                                  clearAllTempDirs();
                                                  //clear lists
                                                  processedImportedFileListLoad = null;
                                                  processedImportFileList.clear();
                                                  _itemNameRenameIndex.clear();
                                                  subImportedFoldersRenameIndex.clear();
                                                  mainImportedFolderRenameIndex.clear();
                                                  renameImportTextBoxController.clear();
                                                  Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                  _selectedCategories.clear();
                                                  pathCharLengthList.clear();

                                                  setState(
                                                    () {},
                                                  );
                                                  importDropZoneMax = true;
                                                  Navigator.of(context).pop();
                                                  //}
                                                }),
                                          child: Text(curLangText!.uiClose)),
                                    ),
                                    Visibility(
                                      visible: !importDropZoneMax,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                            onPressed: processedImportFileList.isEmpty || !context.watch<StateProvider>().modAdderReload
                                                ? null
                                                : (() {
                                                    clearAllTempDirs();
                                                    _itemNameRenameIndex.clear();
                                                    renameImportTextBoxController.clear();
                                                    mainImportedFolderRenameIndex.clear();
                                                    subImportedFoldersRenameIndex.clear();
                                                    _selectedCategories.clear();
                                                    processedImportedFileListLoad = null;
                                                    processedImportFileList.clear();
                                                    pathCharLengthList.clear();
                                                    // if (csvInfosFromSheets.isNotEmpty) {
                                                    //   csvInfosFromSheets.clear();
                                                    // }
                                                    //_exitConfirmDialog = false;
                                                    Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                    _isNameEditing = false;
                                                    importDropZoneMax = true;
                                                    setState(
                                                      () {},
                                                    );
                                                  }),
                                            child: Text(curLangText!.uiClearAll)),
                                      ),
                                    ),
                                    Visibility(
                                      visible: !importDropZoneMax,
                                      child: Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary.withBlue(100)),
                                              onPressed: processedImportFileList.isEmpty ||
                                                      _isNameEditing ||
                                                      !context.watch<StateProvider>().modAdderReload ||
                                                      pathCharLengthList.where((mod) => mod.where((element) => element > 259).isNotEmpty).isNotEmpty
                                                  ? null
                                                  : (() async {
                                                      if (_duplicateCounter > 0) {
                                                        processedImportFileList = await replaceNamesOfDuplicates(processedImportFileList);
                                                        processedImportFileList = getDuplicates(processedImportFileList);
                                                      } else {
                                                        var (setName, applyImported) = await newImportModSetDialog(context);
                                                        if (setName.isNotEmpty) {
                                                          List<ModsAdderItem> toAddList = processedImportFileList.toList();
                                                          processedImportedFileListLoad = null;
                                                          processedImportFileList.clear();
                                                          _isAddingMods = true;
                                                          setState(
                                                            () {},
                                                          );
                                                          // ignore: use_build_context_synchronously
                                                          modsImportFilesAdder(context, toAddList, setName, applyImported).then(
                                                            (value) {
                                                              if (value) {
                                                                //clear values
                                                                clearAllTempDirs();
                                                                _itemNameRenameIndex.clear();
                                                                mainImportedFolderRenameIndex.clear();
                                                                renameImportTextBoxController.clear();
                                                                subImportedFoldersRenameIndex.clear();
                                                                _selectedCategories.clear();
                                                                processedImportedFileListLoad = null;
                                                                processedImportFileList.clear();
                                                                toAddList.clear();
                                                                pathCharLengthList.clear();
                                                                _isAddingMods = false;
                                                                //_exitConfirmDialog = false;
                                                                // ignore: use_build_context_synchronously
                                                                Provider.of<StateProvider>(context, listen: false).modAdderReloadFalse();
                                                                _isNameEditing = false;
                                                                importDropZoneMax = true;
                                                                // if (csvInfosFromSheets.isNotEmpty) {
                                                                //   csvInfosFromSheets.clear();
                                                                // }
                                                              } else {
                                                                processedImportFileList = toAddList.toList();
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
                                                          : Text(curLangText!.uiNext)),
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
Future<List<ModsAdderItem>> modsImportFilesProcess(context, List<XFile> xFilePaths) async {
  modManImportedDirPath = Uri.file('$modManDirPath/imported').toFilePath();
  Directory importedDir = Directory(modManImportedDirPath);
  importedDir.createSync(recursive: true);
  List<ModsAdderItem> modsImportItemList = [];
  // List<String> pathsWithNoIceInRoot = [];
  List<Directory> extractedImportDirs = [];
  //copy files to temp
  for (var xFile in xFilePaths) {
    if (p.extension(xFile.path) == '.zip') {
      String extractedPath = Uri.file('$modManImportedDirPath/${xFile.name.replaceAll('.zip', '')}').toFilePath();
      await extractFileToDisk(xFile.path, extractedPath, asyncWrite: false);
      if (Directory(extractedPath).existsSync()) {
        extractedImportDirs.add(Directory(extractedPath));
      }
    }
  }
  // //listing ice files in temp
  // List<File> iceFileList = [];
  // for (var dir in Directory(modManImportedDirPath).listSync(recursive: false).whereType<Directory>()) {
  //   iceFileList.addAll(dir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path).isEmpty && element.lengthSync() > 0));
  //   //listing mods with no ices in root
  //   if (dir.listSync().whereType<File>().where((element) => p.extension(element.path).isEmpty && element.lengthSync() > 0).isEmpty) {
  //     pathsWithNoIceInRoot.add(dir.path);
  //   }
  // }
  //fetch csv
  // if (csvInfosFromSheets.isEmpty) {
  //   csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  // }
  // List<String> csvFileInfos = [];
  // for (var iceFile in iceFileList) {
  //   //look in csv infos
  //   if (modsAdderGroupSameItemVariants && csvFileInfos.where((element) => element.contains(p.basename(iceFile.path))).isEmpty) {
  // for (var csvFile in csvInfosFromSheets) {
  //   final csv = csvFile.firstWhere(
  //     (line) => line.contains(p.basenameWithoutExtension(iceFile.path)) && !csvFileInfos.contains(line) && line.split(',')[1].isNotEmpty,
  //     orElse: () => '',
  //   );
  //   if (csv.isNotEmpty) {
  //     csvFileInfos.add(csv);
  //   }
  // }
  //   } else if (!modsAdderGroupSameItemVariants) {
  //     for (var csvFile in csvInfosFromSheets) {
  //       csvFileInfos.addAll(csvFile.where((line) => line.contains(p.basenameWithoutExtension(iceFile.path)) && !csvFileInfos.contains(line) && line.split(',')[1].isNotEmpty));
  //     }
  //   }
  // }

  //create new item structures
  // List<File> csvMatchedIceFiles = [];
  for (var rootDir in extractedImportDirs) {
    for (var cate in rootDir.listSync().whereType<Directory>()) {
      String itemCategory = p.basename(cate.path);
      if (defaultCategoryDirs.contains(p.basename(cate.path))) {
        itemCategory = defaultCategoryNames[defaultCategoryDirs.indexOf(p.basename(cate.path))];
      }
      for (var item in cate.listSync().whereType<Directory>()) {
        String itemName = p.basename(item.path);
        //look for item names
        // for (var csvFile in csvInfosFromSheets) {
        //   bool found = false;
        //   for (var line in csvFile) {
        //     if (line.split(',')[1].replaceAll(RegExp(charToReplace), '_').trim() == itemName || line.split(',')[2].replaceAll(RegExp(charToReplace), '_').trim() == itemName) {
        //       if (modManCurActiveItemNameLanguage == 'EN') {
        //         itemName = line.split(',')[2].replaceAll(RegExp(charToReplace), '_').trim();
        //         found = true;
        //       } else if (modManCurActiveItemNameLanguage == 'JP') {
        //         itemName = line.split(',')[1].replaceAll(RegExp(charToReplace), '_').trim();
        //         found = true;
        //       }
        //     }
        //     if (found) {
        //       break;
        //     }
        //   }
        //   if (found) {
        //     break;
        //   }
        // }

        String newItemDirPath = item.path;
        if (p.basename(item.path) != itemName) {
          String newPath = Uri.file('${cate.path}/$itemName').toFilePath();
          await io.copyPath(item.path, newPath);
          item.deleteSync(recursive: true);
          newItemDirPath = newPath;
        }

        // for (var iceFile in iceFileList) {
        //   if (infoLine.contains(p.basenameWithoutExtension(iceFile.path))) {
        //     newItemDirPath = Uri.file('$modManImportedDirPath/$itemCategory/$itemName').toFilePath().trimRight();
        //     String newIceFilePath = Uri.file('$newItemDirPath${iceFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
        //     newIceFilePath = removeRebootPath(newIceFilePath);
        //     if (p.dirname(newIceFilePath) == newItemDirPath) {
        //       await Directory('${p.dirname(newIceFilePath)}/$itemName').create(recursive: true);
        //       newIceFilePath = newIceFilePath.replaceFirst(p.dirname(newIceFilePath), '${p.dirname(newIceFilePath)}/$itemName');
        //     } else {
        //       await Directory(p.dirname(newIceFilePath)).create(recursive: true);
        //     }
        //     iceFile.copySync(newIceFilePath);
        //     csvMatchedIceFiles.add(iceFile);
        //     //fetch extra file in ice dir
        //     final specialParentDirNames = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
        //     List<File> extraFiles = Directory(iceFile.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty).toList();
        //     if (specialParentDirNames.contains(p.basename(iceFile.parent.path)) && p.basename(iceFile.parent.parent.path) != p.basename(modManAddModsTempDirPath)) {
        //       extraFiles.addAll(Directory(iceFile.parent.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty));
        //     }
        //     for (var extraFile in extraFiles) {
        //       String newExtraFilePath = Uri.file('${p.dirname(newIceFilePath)}/${p.basename(extraFile.path)}').toFilePath();
        //       if (!File(newExtraFilePath).existsSync()) {
        //         extraFile.copySync(newExtraFilePath);
        //       }
        //     }
        //   }
        // }
        //
        //get item icon
        File newItemIcon = File('');
        if (File(Uri.file('${item.path}/$itemName.png').toFilePath()).existsSync()) {
          newItemIcon = File(Uri.file('${item.path}/$itemName.png').toFilePath());
        }
        // if (itemCategory != defaultCategoryDirs[7] && itemCategory != defaultCategoryDirs[14]) {
        //   List<String> ogIconIcePaths = itemCategory == defaultCategoryDirs[0]
        //       ? await originalFilePathGet(context, infos[4])
        //       : itemCategory == defaultCategoryDirs[12]
        //           ? []
        //           : await originalFilePathGet(context, infos[5]);
        //   String ogIconIcePath = '';
        //   if (ogIconIcePaths.isNotEmpty) {
        //     ogIconIcePath = ogIconIcePaths.first;
        //   }
        //   if (ogIconIcePath.isNotEmpty) {
        //     String tempIconUnpackDirPath = Uri.file('$modManImportedDirPath/$itemCategory/$itemName/tempItemIconUnpack').toFilePath();
        //     final downloadedconIcePath = await downloadIconIceFromOfficial(ogIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), tempIconUnpackDirPath);
        //     //unpack and convert dds to png
        //     if (downloadedconIcePath.isNotEmpty && File(downloadedconIcePath).existsSync()) {
        //       //debugPrint(downloadedconIcePath);
        //       await Process.run('$modManZamboniExePath -outdir "$tempIconUnpackDirPath"', [downloadedconIcePath]);
        //       if (Directory('${downloadedconIcePath}_ext').existsSync()) {
        //         File ddsItemIcon =
        //             Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
        //         if (ddsItemIcon.path.isNotEmpty) {
        //           newItemIcon = File(Uri.file('$modManImportedDirPath/$itemCategory/$itemName/$itemName.png').toFilePath());
        //           await Process.run(modManDdsPngToolExePath, [ddsItemIcon.path, newItemIcon.path, '-ddstopng']);
        //           // File pngItemIcon =
        //           //     Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.png', orElse: () => File(''));
        //           // if (pngItemIcon.path.isNotEmpty) {
        //           //   newItemIcon = pngItemIcon.renameSync(Uri.file('$modManImportedDirPath/$itemCategory/$itemName/$itemName.png').toFilePath());
        //           // }
        //         }
        //       }
        //       if (Directory(tempIconUnpackDirPath).existsSync()) {
        //         Directory(tempIconUnpackDirPath).deleteSync(recursive: true);
        //       }
        //     }
        //   }
        // }
        //move more extra files
        // for (var modDir in Directory(newItemDirPath).listSync().whereType<Directory>()) {
        //   int index = pathsWithNoIceInRoot.indexWhere((element) => element.contains(p.basename(modDir.path)));
        //   if (index != -1) {
        //     for (var extraFile in Directory(pathsWithNoIceInRoot[index]).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty)) {
        //       extraFile.copySync(Uri.file('${modDir.path}/${p.basename(extraFile.path)}').toFilePath());
        //     }
        //   }
        // }
        //create new item object
        ModsAdderItem newItem = ModsAdderItem(itemCategory, itemName, newItemDirPath, newItemIcon.path, false, true, false, []);
        if (modsImportItemList.where((element) => element.category == newItem.category && element.itemName == newItem.itemName && element.itemDirPath == newItem.itemDirPath).isEmpty) {
          modsImportItemList.add(newItem);
        }
      }
    }
  }
  //move unmatched ice files to misc
  // bool isUnknownItemAdded = false;
  // for (var iceFile in iceFileList) {
  //   if (!csvMatchedIceFiles.contains(iceFile)) {
  //     String itemName = curLangText!.uiUnknownItem;
  //     String newItemDirPath = Uri.file('$modManImportedDirPath/Misc/$itemName').toFilePath();
  //     String newIceFilePath = Uri.file('$newItemDirPath${iceFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
  //     newIceFilePath = removeRebootPath(newIceFilePath);
  //     if (p.dirname(newIceFilePath) == newItemDirPath) {
  //       await Directory('${p.dirname(newIceFilePath)}/$itemName').create(recursive: true);
  //       newIceFilePath = newIceFilePath.replaceFirst(p.dirname(newIceFilePath), '${p.dirname(newIceFilePath)}/$itemName');
  //     } else {
  //       await Directory(p.dirname(newIceFilePath)).create(recursive: true);
  //     }
  //     iceFile.copySync(newIceFilePath);
  //     //fetch extra file in ice dir
  //     final specialParentDirNames = ['win32', 'win32_na', 'win32reboot', 'win32reboot_na'];
  //     List<File> extraFiles = Directory(iceFile.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty).toList();
  //     if (specialParentDirNames.contains(p.basename(iceFile.parent.path)) && p.basename(iceFile.parent.parent.path) != p.basename(modManAddModsTempDirPath)) {
  //       extraFiles.addAll(Directory(iceFile.parent.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty));
  //     }
  //     for (var extraFile in extraFiles) {
  //       String newExtraFilePath = Uri.file('${p.dirname(newIceFilePath)}/${p.basename(extraFile.path)}').toFilePath();
  //       if (!File(newExtraFilePath).existsSync()) {
  //         extraFile.copySync(newExtraFilePath);
  //       }
  //     }
  //     //move more extra files
  //     for (var modDir in Directory(newItemDirPath).listSync().whereType<Directory>()) {
  //       int index = pathsWithNoIceInRoot.indexWhere((element) => element.contains(p.basename(modDir.path)));
  //       if (index != -1) {
  //         for (var extraFile in Directory(pathsWithNoIceInRoot[index]).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty)) {
  //           extraFile.copySync(Uri.file('${modDir.path}/${p.basename(extraFile.path)}').toFilePath());
  //         }
  //       }
  //     }
  //     //add to list
  //     ModsAdderItem newItem = ModsAdderItem('Misc', itemName, newItemDirPath, '', true, true, false, []);
  //     if (!isUnknownItemAdded &&
  //         modsImportItemList.where((element) => element.category == newItem.category && element.itemName == newItem.itemName && element.itemDirPath == newItem.itemDirPath).isEmpty) {
  //       modsImportItemList.add(newItem);
  //       isUnknownItemAdded = true;
  //     }
  //   }
  // }

  //Sort to list
  for (var item in modsImportItemList) {
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

  // Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
  //   if (element.existsSync()) {
  //     element.deleteSync(recursive: true);
  //   }
  // });

  if (modsImportItemList.isNotEmpty) {
    Provider.of<StateProvider>(context, listen: false).modAdderReloadTrue();
  }

  return modsImportItemList;
}

String findIcePathInGameData(String iceName) {
  if (iceName.isEmpty) {
    return '';
  }
  int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
  if (win32PathIndex != -1) {
    return ogWin32FilePaths[win32PathIndex];
  }
  int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
  if (win32NAPathIndex != -1) {
    return ogWin32NAFilePaths[win32NAPathIndex];
  }
  int win32RebootPathIndex = ogWin32RebootFilePaths.indexWhere((element) => p.basename(element) == iceName);
  if (win32RebootPathIndex != -1) {
    return ogWin32RebootFilePaths[win32RebootPathIndex];
  }
  int win32RebootNAPathIndex = ogWin32RebootNAFilePaths.indexWhere((element) => p.basename(element) == iceName);
  if (win32RebootNAPathIndex != -1) {
    return ogWin32RebootNAFilePaths[win32RebootNAPathIndex];
  }
  return '';
}

String removeRebootPath(String filePath) {
  String newPath = filePath;
  String ogPath = findIcePathInGameData(p.basename(filePath));
  if (ogPath.isEmpty) {
    return filePath;
  } else {
    String trimmedPath = ogPath.replaceFirst(Uri.file('$modManPso2binPath/data/').toFilePath(), '');
    final toRemovePathNames = p.dirname(trimmedPath).split(Uri.file('/').toFilePath());
    List<String> newPathSplit = newPath.split(Uri.file('/').toFilePath());
    for (var name in toRemovePathNames) {
      newPathSplit.remove(name);
    }
    newPath = p.joinAll(newPathSplit);
  }

  return newPath;
}

List<ModsAdderItem> getDuplicates(List<ModsAdderItem> processedList) {
  List<ModsAdderItem> returnList = processedList;
  _duplicateCounter = 0;
  for (var item in returnList) {
    if (item.toBeAdded) {
      String parentPath = Directory(item.itemDirPath).parent.parent.path;
      for (var mod in item.modList) {
        if (mod.toBeAdded) {
          if (mod.filesInMod.isNotEmpty) {
            String modDirPathInMods = mod.modDirPath.replaceFirst(parentPath, modManModsDirPath);
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
                String submodDirinMods = submod.submodDirPath.replaceFirst(parentPath, modManModsDirPath);
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
            content: Text('"$fileName" ${curLangText!.uiFilesNotSupported}'),
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
