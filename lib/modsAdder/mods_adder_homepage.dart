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
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/mods_adder.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:window_manager/window_manager.dart';
import 'package:io/io.dart' as io;

bool dropZoneMax = true;
bool _newModDragging = false;
List<XFile> modAdderDragDropFiles = [];
Future? processedFileListLoad;
List<ModsAdderItem> processedFileList = [];
List<String> _selectedCategories = [];
TextEditingController renameTextBoxController = TextEditingController();
List<bool> _itemNameRenameIndex = [];
//List<List<bool>> _mainFolderRenameIndex = [];
//List<List<bool>> _subFoldersRenameIndex = [];
bool _isNameEditing = false;
final _subItemFormValidate = GlobalKey<FormState>();

void modsAdderHomePage(context) {
  showDialog(
      barrierDismissible: true,
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
                        future: itemCsvFetcher(modManRefSheetsDirPath),
                        builder: ((
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
                          if (snapshot.connectionState == ConnectionState.waiting && csvInfosFromSheets.isEmpty) {
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
                              csvInfosFromSheets = snapshot.data;
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
                                                if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                                  modsAdderUnsupportedFileTypeDialog(context, p.basename(element.path));
                                                } else if (modAdderDragDropFiles.indexWhere((file) => file.path == element.path) == -1) {
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
                                                  height: constraints.maxHeight - 42,
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
                                                                  child: ListView.builder(
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
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: modAdderDragDropFiles.isNotEmpty
                                                            ? (() async {
                                                                processedFileListLoad = modsAdderFilesProcess(modAdderDragDropFiles.toList());
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
                                                if (snapshot.connectionState == ConnectionState.none) {
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
                                                    processedFileList = snapshot.data;
                                                    //rename trigger
                                                    if (_itemNameRenameIndex.isEmpty || _itemNameRenameIndex.length != processedFileList.length) {
                                                      _itemNameRenameIndex = List.generate(processedFileList.length, (index) => false);
                                                    }
                                                    // if (_mainFolderRenameIndex.isEmpty) {
                                                    //         _itemNameRenameIndex = List.generate(processedFileList.length, (index) => false);
                                                    //         _mainFolderRenameIndex = List.generate(processedFileList.length, (index) => []);
                                                    //         for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                    //           _mainFolderRenameIndex[i] = List.generate(processedFileList[i].modList.length, (index) => false);
                                                    //         }
                                                    //         _subFoldersRenameIndex = List.generate(processedFileList.length, (index) => []);
                                                    //         for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                    //           _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                    //         }
                                                    //       } else if (_mainFolderRenameIndex.isNotEmpty && _mainFolderRenameIndex.length < sortedModsList.length) {
                                                    //         _itemNameRenameIndex = List.generate(sortedModsList.length, (index) => false);
                                                    //         _mainFolderRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                    //         for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                    //           _mainFolderRenameIndex[i] = List.generate(sortedModsList[i][4].split('|').length, (index) => false);
                                                    //         }
                                                    //         _subFoldersRenameIndex = List.generate(sortedModsList.length, (index) => []);
                                                    //         for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                    //           _subFoldersRenameIndex[i] = List.generate(sortedModsList[i][5].split('|').length, (index) => false);
                                                    //         }
                                                    //       } else if (_mainFolderRenameIndex.isNotEmpty && _mainFolderRenameIndex.length == sortedModsList.length) {
                                                    //         for (int i = 0; i < _mainFolderRenameIndex.length; i++) {
                                                    //           if (_mainFolderRenameIndex[i].length < sortedModsList[i][4].split('|').length) {
                                                    //             for (int missingEle = sortedModsList[i][4].split('|').length - _mainFolderRenameIndex[i].length; missingEle > 0; missingEle--) {
                                                    //               _mainFolderRenameIndex[i].add(false);
                                                    //             }
                                                    //           }
                                                    //         }
                                                    //         for (int i = 0; i < _subFoldersRenameIndex.length; i++) {
                                                    //           if (_subFoldersRenameIndex[i].length < sortedModsList[i][5].split('|').length) {
                                                    //             for (int missingEle = sortedModsList[i][5].split('|').length - _subFoldersRenameIndex[i].length; missingEle > 0; missingEle--) {
                                                    //               _subFoldersRenameIndex[i].add(false);
                                                    //             }
                                                    //           }
                                                    //         }
                                                    //       }

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
                                                              itemCount: processedFileList.length,
                                                              itemBuilder: (context, index) {
                                                                return Card(
                                                                  margin: const EdgeInsets.only(top: 0, bottom: 2, left: 0, right: 0),
                                                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
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
                                                                                  items: defaultCateforyDirs
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
                                                                                      processedFileList[index].category = value.toString();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              if (!processedFileList[index].isUnknown)
                                                                                SizedBox(
                                                                                  width: 150,
                                                                                  height: 40,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                    child: Text(processedFileList[index].category,
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
                                                                                              height: 40,
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
                                                                                                onEditingComplete: () {
                                                                                                  // if (renameTextBoxController.text.isNotEmpty) {
                                                                                                  //   String newItemName = renameTextBoxController.text.trim();
                                                                                                  //   if (sortedModsList[index][0] == 'Basewears' && !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                  //     newItemName += ' [Ba]';
                                                                                                  //   } else if (sortedModsList[index][0] == 'Innerwears' &&
                                                                                                  //       !renameTextBoxController.text.contains('[In]')) {
                                                                                                  //     newItemName += ' [In]';
                                                                                                  //   } else if (sortedModsList[index][0] == 'Outerwears' &&
                                                                                                  //       !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                  //     newItemName += ' [Ou]';
                                                                                                  //   } else if (sortedModsList[index][0] == 'Setwears' &&
                                                                                                  //       !renameTextBoxController.text.contains('[Se]')) {
                                                                                                  //     newItemName += ' [Se]';
                                                                                                  //   } else {
                                                                                                  //     newItemName = renameTextBoxController.text;
                                                                                                  //   }
                                                                                                  //   if (curActiveLang == 'JP') {
                                                                                                  //     sortedModsList[index][1] = newItemName;
                                                                                                  //   } else {
                                                                                                  //     sortedModsList[index][2] = newItemName;
                                                                                                  //   }

                                                                                                  //   //print(sortedModsList);
                                                                                                  // }
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
                                                                                                // if (renameTextBoxController.text.isNotEmpty) {
                                                                                                //   String newItemName = renameTextBoxController.text.trim();
                                                                                                //   if (sortedModsList[index][0] == 'Basewears' && !renameTextBoxController.text.contains('[Ba]')) {
                                                                                                //     newItemName += ' [Ba]';
                                                                                                //   } else if (sortedModsList[index][0] == 'Innerwears' &&
                                                                                                //       !renameTextBoxController.text.contains('[In]')) {
                                                                                                //     newItemName += ' [In]';
                                                                                                //   } else if (sortedModsList[index][0] == 'Outerwears' &&
                                                                                                //       !renameTextBoxController.text.contains('[Ou]')) {
                                                                                                //     newItemName += ' [Ou]';
                                                                                                //   } else if (sortedModsList[index][0] == 'Setwears' && !renameTextBoxController.text.contains('[Se]')) {
                                                                                                //     newItemName += ' [Se]';
                                                                                                //   } else {
                                                                                                //     newItemName = renameTextBoxController.text;
                                                                                                //   }
                                                                                                //   if (curActiveLang == 'JP') {
                                                                                                //     sortedModsList[index][1] = newItemName;
                                                                                                //   } else {
                                                                                                //     sortedModsList[index][2] = newItemName;
                                                                                                //   }

                                                                                                //   //print(sortedModsList);
                                                                                                // }
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
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 3),
                                                                                              child: Text(processedFileList[index].itemName.replaceAll('_', '/'),
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
                                                                                          SizedBox(
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
                                                                      //mods list
                                                                      ListView.builder(
                                                                          shrinkWrap: true,
                                                                          physics: const NeverScrollableScrollPhysics(),
                                                                          itemCount: processedFileList[index].modList.length,
                                                                          itemBuilder: (context, mIndex) {
                                                                            var curMod = processedFileList[index].modList[mIndex];
                                                                            //rename trigger
                                                                            List<bool> mainFolderRenameIndex = [];
                                                                            if (mainFolderRenameIndex.isEmpty || mainFolderRenameIndex.length != processedFileList[index].modList.length) {
                                                                              mainFolderRenameIndex = List.generate(processedFileList[index].modList.length, (index) => false);
                                                                            }
                                                                            return ExpansionTile(
                                                                              initiallyExpanded: true,
                                                                              childrenPadding: const EdgeInsets.only(left: 15),
                                                                              textColor:
                                                                                  MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                              iconColor:
                                                                                  MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                              collapsedTextColor:
                                                                                  MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                              //Edit Name
                                                                              title: mainFolderRenameIndex[mIndex]
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
                                                                                                hintText: curMod.modName,
                                                                                                counterText: '',
                                                                                              ),
                                                                                              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                                                                                              onEditingComplete: () {
                                                                                                // if (renameTextBoxController.text.isNotEmpty) {
                                                                                                //   //print('OLD: $sortedModsList');
                                                                                                //   String oldMainDirName = sortedModsList[index][4].split('|')[ex];
                                                                                                //   // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                                //   //     .renameSync('$modManAddModsTempDirPath$s${renameTextBoxController.text}');
                                                                                                //   List<FileSystemEntity> curFilesInMainDir =
                                                                                                //       Directory(Uri.file('$modManAddModsTempDirPath/$oldMainDirName').toFilePath())
                                                                                                //           .listSync(recursive: true);
                                                                                                //   for (var element in curFilesInMainDir) {
                                                                                                //     //print(curFilesInMainDir);
                                                                                                //     String newMainPath = element.path.replaceFirst(
                                                                                                //         Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                //         Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                //     if (!File(element.path).existsSync()) {
                                                                                                //       Directory(newMainPath).createSync(recursive: true);
                                                                                                //     }
                                                                                                //     if (sortedModsList[index][5].isEmpty) {
                                                                                                //       Directory(Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}').toFilePath())
                                                                                                //           .createSync(recursive: true);
                                                                                                //     }
                                                                                                //   }
                                                                                                //   for (var element in curFilesInMainDir) {
                                                                                                //     String newMainPath = element.path.replaceFirst(
                                                                                                //         Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                                //         Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                                //     if (File(element.path).existsSync()) {
                                                                                                //       File(element.path).copySync(newMainPath);
                                                                                                //     }
                                                                                                //   }

                                                                                                //   //Itemlist
                                                                                                //   //Item name replace
                                                                                                //   List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                                //   mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                //   sortedModsList[index][4] = mainDirsString.join('|');

                                                                                                //   //Subitem Item name replace
                                                                                                //   List<String> mainDirsInSubItemString = sortedModsList[index][5].split('|');
                                                                                                //   for (var element in mainDirsInSubItemString) {
                                                                                                //     List<String> split = element.split((':'));
                                                                                                //     if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                //       split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                //       mainDirsInSubItemString[mainDirsInSubItemString.indexOf(element)] = split.join(':');
                                                                                                //     }
                                                                                                //   }
                                                                                                //   sortedModsList[index][5] = mainDirsInSubItemString.join('|');

                                                                                                //   //icefile Item name replace
                                                                                                //   List<String> mainDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                //   for (var element in mainDirsInItemString) {
                                                                                                //     List<String> split = element.split((':'));
                                                                                                //     if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                                //       split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                                //       mainDirsInItemString[mainDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                //     }
                                                                                                //   }
                                                                                                //   sortedModsList[index][6] = mainDirsInItemString.join('|');

                                                                                                //   //print(sortedModsList);
                                                                                                // }
                                                                                                mainFolderRenameIndex[mIndex] = false;
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
                                                                                              // if (renameTextBoxController.text.isNotEmpty) {
                                                                                              //   String oldMainDirName = sortedModsList[index][4].split('|')[ex];
                                                                                              //   // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}')
                                                                                              //   //     .renameSync('$modManAddModsTempDirPath$s${renameTextBoxController.text}');
                                                                                              //   List<FileSystemEntity> curFilesInMainDir =
                                                                                              //       Directory(Uri.file('$modManAddModsTempDirPath/$oldMainDirName').toFilePath()).listSync(recursive: true);
                                                                                              //   for (var element in curFilesInMainDir) {
                                                                                              //     //print(curFilesInMainDir);
                                                                                              //     String newMainPath = element.path.replaceFirst(
                                                                                              //         Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                              //         Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                              //     if (!File(element.path).existsSync()) {
                                                                                              //       Directory(newMainPath).createSync(recursive: true);
                                                                                              //     }
                                                                                              //     if (sortedModsList[index][5].isEmpty) {
                                                                                              //       Directory(Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}').toFilePath())
                                                                                              //           .createSync(recursive: true);
                                                                                              //     }
                                                                                              //   }
                                                                                              //   for (var element in curFilesInMainDir) {
                                                                                              //     String newMainPath = element.path.replaceFirst(
                                                                                              //         Uri.file('$modManAddModsTempDirPath/$oldMainDirName/').toFilePath(),
                                                                                              //         Uri.file('$modManAddModsTempDirPath/${renameTextBoxController.text}/').toFilePath());
                                                                                              //     if (File(element.path).existsSync()) {
                                                                                              //       File(element.path).copySync(newMainPath);
                                                                                              //     }
                                                                                              //   }

                                                                                              //   //Itemlist
                                                                                              //   List<String> mainDirsString = sortedModsList[index][4].split('|');
                                                                                              //   mainDirsString[mainDirsString.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                              //   sortedModsList[index][4] = mainDirsString.join('|');

                                                                                              //   //Subitem Item name replace
                                                                                              //   List<String> mainDirsInSubItemString = sortedModsList[index][5].split('|');
                                                                                              //   for (var element in mainDirsInSubItemString) {
                                                                                              //     List<String> split = element.split((':'));
                                                                                              //     if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                              //       split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                              //       mainDirsInSubItemString[mainDirsInSubItemString.indexOf(element)] = split.join(':');
                                                                                              //     }
                                                                                              //   }
                                                                                              //   sortedModsList[index][5] = mainDirsInSubItemString.join('|');

                                                                                              //   List<String> mainDirsInItemString = sortedModsList[index][6].split('|');
                                                                                              //   for (var element in mainDirsInItemString) {
                                                                                              //     List<String> split = element.split((':'));
                                                                                              //     if (split.indexWhere((element) => element == oldMainDirName) != -1) {
                                                                                              //       split[split.indexOf(oldMainDirName)] = renameTextBoxController.text;
                                                                                              //       mainDirsInItemString[mainDirsInItemString.indexOf(element)] = split.join(':');
                                                                                              //     }
                                                                                              //   }
                                                                                              //   sortedModsList[index][6] = mainDirsInItemString.join('|');

                                                                                              //   //print(sortedModsList);
                                                                                              // }
                                                                                              mainFolderRenameIndex[mIndex] = false;
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
                                                                                          child: Text(curMod.modName,
                                                                                              style: TextStyle(
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  color: !curMod.toBeAdded
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
                                                                                              onPressed: !_isNameEditing && curMod.toBeAdded
                                                                                                  ? () {
                                                                                                      renameTextBoxController.text = curMod.modName;
                                                                                                      renameTextBoxController.selection = TextSelection(
                                                                                                        baseOffset: 0,
                                                                                                        extentOffset: renameTextBoxController.text.length,
                                                                                                      );
                                                                                                      _isNameEditing = true;
                                                                                                      mainFolderRenameIndex[mIndex] = true;
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
                                                                                                  // //mainName
                                                                                                  // final mainNames = sortedModsList[index][4].split('|');
                                                                                                  // int curMainIndex = mainNames.indexOf(sortedModsList[index][4].split('|')[ex]);
                                                                                                  // if (!sortedModsList[index][4].split('|')[ex].contains(':[TOREMOVE]')) {
                                                                                                  //   mainNames[curMainIndex] = sortedModsList[index][4].split('|')[ex] += ':[TOREMOVE]';
                                                                                                  // }
                                                                                                  // sortedModsList[index][4] = mainNames.join('|');
                                                                                                  // //subName
                                                                                                  // final subNames = sortedModsList[index][5].split('|');
                                                                                                  // String subTemp = '';
                                                                                                  // for (int i = 0; i < subNames.length; i++) {
                                                                                                  //   if (subTemp.isEmpty) {
                                                                                                  //     if (subNames[i].split(':').first == sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                  //       subTemp = subNames[i] += ':[TOREMOVE]';
                                                                                                  //     } else {
                                                                                                  //       subTemp = subNames[i];
                                                                                                  //     }
                                                                                                  //   } else {
                                                                                                  //     if (subNames[i].split(':').first == sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                  //       subTemp += '|${subNames[i]}:[TOREMOVE]';
                                                                                                  //     } else {
                                                                                                  //       subTemp += '|${subNames[i]}';
                                                                                                  //     }
                                                                                                  //   }
                                                                                                  // }
                                                                                                  // sortedModsList[index][5] = subTemp;

                                                                                                  // //check mains to disable or able the whole item if all main disabled
                                                                                                  // bool allMainRemoving = true;
                                                                                                  // for (var element in sortedModsList[index][4].split('|')) {
                                                                                                  //   if (element.split(':').last != '[TOREMOVE]') {
                                                                                                  //     allMainRemoving = false;
                                                                                                  //     break;
                                                                                                  //   }
                                                                                                  // }
                                                                                                  // if (allMainRemoving) {
                                                                                                  //   sortedModsList[index][1] = sortedModsList[index][1] += ':[TOREMOVE]';
                                                                                                  //   sortedModsList[index][2] = sortedModsList[index][2] += ':[TOREMOVE]';
                                                                                                  //   //print(sortedModsList[index][4]);
                                                                                                  // }
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
                                                                                                  // sortedModsList[index][1] = sortedModsList[index][1].replaceAll(':[TOREMOVE]', '');
                                                                                                  // sortedModsList[index][2] = sortedModsList[index][2].replaceAll(':[TOREMOVE]', '');
                                                                                                  // //mainName
                                                                                                  // final mainNames = sortedModsList[index][4].split('|');
                                                                                                  // int curMainIndex = mainNames.indexOf(sortedModsList[index][4].split('|')[ex]);
                                                                                                  // if (sortedModsList[index][4].split('|')[ex].contains(':[TOREMOVE]')) {
                                                                                                  //   mainNames[curMainIndex] = sortedModsList[index][4].split('|')[ex].replaceAll(':[TOREMOVE]', '');
                                                                                                  // }
                                                                                                  // sortedModsList[index][4] = mainNames.join('|');
                                                                                                  // sortedModsList[index][5] = sortedModsList[index][5].replaceAll(':[TOREMOVE]', '');
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
                                                                                //if file in mod folder found
                                                                                if (curMod.filesInMod.isNotEmpty)
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: const NeverScrollableScrollPhysics(),
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
                                                                                  ListView.builder(
                                                                                      shrinkWrap: true,
                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                      itemCount: curMod.submodList.length,
                                                                                      itemBuilder: (context, sIndex) {
                                                                                        var curSubmod = curMod.submodList[sIndex];
                                                                                        //rename trigger
                                                                                        List<bool> subFoldersRenameIndex = [];
                                                                                        if (subFoldersRenameIndex.isEmpty || subFoldersRenameIndex.length != curMod.submodList.length) {
                                                                                          subFoldersRenameIndex = List.generate(curMod.submodList.length, (index) => false);
                                                                                        }
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
                                                                                          title: subFoldersRenameIndex[sIndex]
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
                                                                                                              hintText: curSubmod.submodName,
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
                                                                                                              // final List<String> subDirList = sortedModsList[index][5]
                                                                                                              //     .split('|')
                                                                                                              //     .where((element) =>
                                                                                                              //         element.split(':')[1] != sortedModsList[index][5].split('|')[sub].split(':')[1])
                                                                                                              //     .toList();
                                                                                                              // List<String> subDirNames = [];
                                                                                                              // for (var name in subDirList) {
                                                                                                              //   subDirNames.add(name.split(':')[1]);
                                                                                                              // }

                                                                                                              // for (var name in subDirNames) {
                                                                                                              //   if (name.toLowerCase() == value.toLowerCase()) {
                                                                                                              //     Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(65);
                                                                                                              //     return curLangText!.uiNameAlreadyExisted;
                                                                                                              //   }
                                                                                                              // }

                                                                                                              return null;
                                                                                                            },
                                                                                                            onEditingComplete: (() {
                                                                                                              if (_subItemFormValidate.currentState!.validate()) {
                                                                                                                //   if (renameTextBoxController.text.isNotEmpty) {
                                                                                                                //     String mainDirName = sortedModsList[index][5].split('|')[sub].split(':').first;
                                                                                                                //     String oldSubDirName = sortedModsList[index][5].split('|')[sub].split(':')[1];
                                                                                                                //     // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                                //     //     '$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                                //     List<FileSystemEntity> curFilesInSubDir = Directory(Uri.file(
                                                                                                                //                 '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName')
                                                                                                                //             .toFilePath())
                                                                                                                //         .listSync(recursive: true);
                                                                                                                //     for (var element in curFilesInSubDir) {
                                                                                                                //       //print(curFilesInMainDir);
                                                                                                                //       String newMainPath = element.path.replaceFirst(
                                                                                                                //           Uri.file(
                                                                                                                //                   '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                //               .toFilePath(),
                                                                                                                //           Uri.file(
                                                                                                                //                   '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                //               .toFilePath());
                                                                                                                //       if (!File(element.path).existsSync()) {
                                                                                                                //         Directory(newMainPath).createSync(recursive: true);
                                                                                                                //       } else {
                                                                                                                //         Directory(File(newMainPath).parent.path).createSync(recursive: true);
                                                                                                                //       }
                                                                                                                //     }
                                                                                                                //     for (var element in curFilesInSubDir) {
                                                                                                                //       String newMainPath = element.path.replaceFirst(
                                                                                                                //           Uri.file(
                                                                                                                //                   '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                                //               .toFilePath(),
                                                                                                                //           Uri.file(
                                                                                                                //                   '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                                //               .toFilePath());
                                                                                                                //       if (File(element.path).existsSync()) {
                                                                                                                //         File(element.path).copySync(newMainPath);
                                                                                                                //       }
                                                                                                                //     }

                                                                                                                //     //List
                                                                                                                //     List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                                //     subDirsString[subDirsString.indexOf('$mainDirName:$oldSubDirName')] =
                                                                                                                //         '$mainDirName:${renameTextBoxController.text}';
                                                                                                                //     sortedModsList[index][5] = subDirsString.join('|');

                                                                                                                //     List<String> subDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                                //     for (var element in subDirsInItemString) {
                                                                                                                //       List<String> split = element.split((':'));
                                                                                                                //       if (split.indexWhere((element) => element == oldSubDirName) != -1) {
                                                                                                                //         split[split.indexOf(oldSubDirName)] = renameTextBoxController.text;
                                                                                                                //         subDirsInItemString[subDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                                //       }
                                                                                                                //     }
                                                                                                                //     sortedModsList[index][6] = subDirsInItemString.join('|');
                                                                                                                //   }

                                                                                                                //Clear
                                                                                                                Provider.of<StateProvider>(context, listen: false).itemAdderSubItemETHeightSet(40);
                                                                                                                subFoldersRenameIndex[sIndex] = false;
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
                                                                                                            // if (renameTextBoxController.text.isNotEmpty) {
                                                                                                            //   String mainDirName = sortedModsList[index][5].split('|')[sub].split(':').first;
                                                                                                            //   String oldSubDirName = sortedModsList[index][5].split('|')[sub].split(':')[1];
                                                                                                            //   // Directory('$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s$oldSubDirName').renameSync(
                                                                                                            //   //     '$modManAddModsTempDirPath$s${sortedModsList[index][3].split('|')[ex]}$s${renameTextBoxController.text}');
                                                                                                            //   List<FileSystemEntity> curFilesInSubDir = Directory(Uri.file(
                                                                                                            //               '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName')
                                                                                                            //           .toFilePath())
                                                                                                            //       .listSync(recursive: true);
                                                                                                            //   for (var element in curFilesInSubDir) {
                                                                                                            //     //print(curFilesInMainDir);
                                                                                                            //     String newMainPath = element.path.replaceFirst(
                                                                                                            //         Uri.file(
                                                                                                            //                 '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                            //             .toFilePath(),
                                                                                                            //         Uri.file(
                                                                                                            //                 '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                            //             .toFilePath());
                                                                                                            //     if (!File(element.path).existsSync()) {
                                                                                                            //       Directory(newMainPath).createSync(recursive: true);
                                                                                                            //     } else {
                                                                                                            //       Directory(File(newMainPath).parent.path).createSync(recursive: true);
                                                                                                            //     }
                                                                                                            //   }
                                                                                                            //   for (var element in curFilesInSubDir) {
                                                                                                            //     String newMainPath = element.path.replaceFirst(
                                                                                                            //         Uri.file(
                                                                                                            //                 '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/$oldSubDirName/')
                                                                                                            //             .toFilePath(),
                                                                                                            //         Uri.file(
                                                                                                            //                 '$modManAddModsTempDirPath/${sortedModsList[index][4].split('|')[ex]}/${renameTextBoxController.text}/')
                                                                                                            //             .toFilePath());
                                                                                                            //     if (File(element.path).existsSync()) {
                                                                                                            //       File(element.path).copySync(newMainPath);
                                                                                                            //     }
                                                                                                            //   }

                                                                                                            //   //List
                                                                                                            //   List<String> subDirsString = sortedModsList[index][5].split('|');
                                                                                                            //   subDirsString[subDirsString.indexOf('$mainDirName:$oldSubDirName')] =
                                                                                                            //       '$mainDirName:${renameTextBoxController.text}';
                                                                                                            //   sortedModsList[index][5] = subDirsString.join('|');

                                                                                                            //   List<String> subDirsInItemString = sortedModsList[index][6].split('|');
                                                                                                            //   for (var element in subDirsInItemString) {
                                                                                                            //     List<String> split = element.split((':'));
                                                                                                            //     if (split.indexWhere((element) => element == oldSubDirName) != -1) {
                                                                                                            //       split[split.indexOf(oldSubDirName)] = renameTextBoxController.text;
                                                                                                            //       subDirsInItemString[subDirsInItemString.indexOf(element)] = split.join(':');
                                                                                                            //     }
                                                                                                            //   }
                                                                                                            //   sortedModsList[index][6] = subDirsInItemString.join('|');
                                                                                                            // }

                                                                                                            //Clear
                                                                                                            subFoldersRenameIndex[sIndex] = false;
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
                                                                                                                  renameTextBoxController.text = curSubmod.submodName;
                                                                                                                  renameTextBoxController.selection = TextSelection(
                                                                                                                    baseOffset: 0,
                                                                                                                    extentOffset: renameTextBoxController.text.length,
                                                                                                                  );
                                                                                                                  subFoldersRenameIndex[sIndex] = true;
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
                                                                                                              // final subNames = sortedModsList[index][5].split('|');
                                                                                                              // String subTemp = '';
                                                                                                              // for (int i = 0; i < subNames.length; i++) {
                                                                                                              //   if (subTemp.isEmpty) {
                                                                                                              //     if (subNames[i].split(':').first ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                              //         subNames[i].split(':')[1] ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                              //       subTemp = subNames[i] += ':[TOREMOVE]';
                                                                                                              //     } else {
                                                                                                              //       subTemp = subNames[i];
                                                                                                              //     }
                                                                                                              //   } else {
                                                                                                              //     if (subNames[i].split(':').first ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                              //         subNames[i].split(':')[1] ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                              //       subTemp += '|${subNames[i]}:[TOREMOVE]';
                                                                                                              //     } else {
                                                                                                              //       subTemp += '|${subNames[i]}';
                                                                                                              //     }
                                                                                                              //   }
                                                                                                              // }
                                                                                                              // sortedModsList[index][5] = subTemp;
                                                                                                              // //print(sortedModsList[index][5]);

                                                                                                              // //check sub to disable or able main if all or one disabled
                                                                                                              // bool allSubRemoving = true;
                                                                                                              // for (var element in sortedModsList[index][5].split('|')) {
                                                                                                              //   if (sortedModsList[index][5].split('|').length > 1 &&
                                                                                                              //       sub < sortedModsList[index][5].split('|').length) {
                                                                                                              //     if (element.split(':').first ==
                                                                                                              //                 sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                              //             element.split(':').last != '[TOREMOVE]' ||
                                                                                                              //         sortedModsList[index][6].contains('${sortedModsList[index][4]}::')) {
                                                                                                              //       allSubRemoving = false;
                                                                                                              //       break;
                                                                                                              //     }
                                                                                                              //   } else {
                                                                                                              //     if (element.split(':').first ==
                                                                                                              //                 sortedModsList[index][5].split('|')[0].split(':')[0] &&
                                                                                                              //             element.split(':').last != '[TOREMOVE]' ||
                                                                                                              //         sortedModsList[index][6].contains('${sortedModsList[index][4]}::')) {
                                                                                                              //       allSubRemoving = false;
                                                                                                              //       break;
                                                                                                              //     }
                                                                                                              //   }
                                                                                                              // }
                                                                                                              // if (allSubRemoving) {
                                                                                                              //   String mainTemp = '';
                                                                                                              //   for (var element in sortedModsList[index][4].split('|')) {
                                                                                                              //     if (element.split(':').first ==
                                                                                                              //         sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                              //       if (mainTemp.isEmpty) {
                                                                                                              //         mainTemp = '${element.split(':').first}:[TOREMOVE]';
                                                                                                              //       } else {
                                                                                                              //         mainTemp += '|${element.split(':').first}:[TOREMOVE]';
                                                                                                              //       }
                                                                                                              //     } else {
                                                                                                              //       if (mainTemp.isEmpty) {
                                                                                                              //         mainTemp = element;
                                                                                                              //       } else {
                                                                                                              //         mainTemp += '|$element';
                                                                                                              //       }
                                                                                                              //     }
                                                                                                              //   }
                                                                                                              //   sortedModsList[index][4] = mainTemp;
                                                                                                              //   //print(sortedModsList[index][4]);
                                                                                                              // }

                                                                                                              // //check mains to disable or able the whole item if all main disabled
                                                                                                              // bool allMainRemoving = true;
                                                                                                              // for (var element in sortedModsList[index][4].split('|')) {
                                                                                                              //   if (element.split(':').last != '[TOREMOVE]') {
                                                                                                              //     allMainRemoving = false;
                                                                                                              //     break;
                                                                                                              //   }
                                                                                                              // }
                                                                                                              // if (allMainRemoving) {
                                                                                                              //   sortedModsList[index][1] = sortedModsList[index][1] += ':[TOREMOVE]';
                                                                                                              //   sortedModsList[index][2] = sortedModsList[index][2] += ':[TOREMOVE]';
                                                                                                              //   //print(sortedModsList[index][4]);
                                                                                                              // }
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
                                                                                                              // sortedModsList[index][1] = sortedModsList[index][1].replaceAll(':[TOREMOVE]', '');
                                                                                                              // sortedModsList[index][2] = sortedModsList[index][2].replaceAll(':[TOREMOVE]', '');
                                                                                                              // String mainTemp = '';
                                                                                                              // for (var element in sortedModsList[index][4].split('|')) {
                                                                                                              //   if (element.split(':').first ==
                                                                                                              //       sortedModsList[index][4].split('|')[ex].split(':').first) {
                                                                                                              //     if (mainTemp.isEmpty) {
                                                                                                              //       mainTemp = element.split(':').first;
                                                                                                              //     } else {
                                                                                                              //       mainTemp += '|${element.split(':').first}';
                                                                                                              //     }
                                                                                                              //   } else {
                                                                                                              //     if (mainTemp.isEmpty) {
                                                                                                              //       mainTemp = element;
                                                                                                              //     } else {
                                                                                                              //       mainTemp += '|$element';
                                                                                                              //     }
                                                                                                              //   }
                                                                                                              // }
                                                                                                              // sortedModsList[index][4] = mainTemp;
                                                                                                              // //print(sortedModsList[index][4]);
                                                                                                              // final subNames = sortedModsList[index][5].split('|');
                                                                                                              // String subTemp = '';
                                                                                                              // for (int i = 0; i < subNames.length; i++) {
                                                                                                              //   if (subTemp.isEmpty) {
                                                                                                              //     if (subNames[i].split(':').first ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                              //         subNames[i].split(':')[1] ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                              //       subTemp = subNames[i].replaceAll(':[TOREMOVE]', '');
                                                                                                              //     } else {
                                                                                                              //       subTemp = subNames[i];
                                                                                                              //     }
                                                                                                              //   } else {
                                                                                                              //     if (subNames[i].split(':').first ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[0] &&
                                                                                                              //         subNames[i].split(':')[1] ==
                                                                                                              //             sortedModsList[index][5].split('|')[sub].split(':')[1]) {
                                                                                                              //       subTemp += '|${subNames[i].replaceAll(':[TOREMOVE]', '')}';
                                                                                                              //     } else {
                                                                                                              //       subTemp += '|${subNames[i]}';
                                                                                                              //     }
                                                                                                              //   }
                                                                                                              // }
                                                                                                              // sortedModsList[index][5] = subTemp;
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
                                                                                            ListView.builder(
                                                                                                shrinkWrap: true,
                                                                                                physics: const NeverScrollableScrollPhysics(),
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
                                                              })),
                                                    );
                                                  }
                                                }
                                              }),
                                        ),
                                      ),
                                    ],
                                  ))
                                ],
                              );
                            }
                          }
                        }));
                  }),
                ),
              ));
        });
      });
}

//suport functions
Future<List<ModsAdderItem>> modsAdderFilesProcess(List<XFile> xFilePaths) async {
  List<ModsAdderItem> modsAdderItemList = [];
  List<String> charsToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
  //copy files to temp
  for (var xFile in xFilePaths) {
    if (p.extension(xFile.path) == '.zip') {
      await extractFileToDisk(xFile.path, Uri.file('$modManAddModsTempDirPath/${xFile.name.replaceAll('.zip', '')}').toFilePath(), asyncWrite: true);
    } else if (File(xFile.path).statSync().type == FileSystemEntityType.directory) {
      await io.copyPath(xFile.path, Uri.file('$modManAddModsTempDirPath/${xFile.name}').toFilePath());
    } else {
      final tempPath = Uri.file('$modManAddModsTempDirPath/${p.basename(File(xFile.path).parent.path)}').toFilePath();
      Directory(tempPath).createSync(recursive: true);
      File(xFile.path).copySync(Uri.file('$tempPath/${xFile.name}').toFilePath());
    }
  }
  //listing ice files in temp
  List<File> iceFileList = [];
  for (var dir in Directory(modManAddModsTempDirPath).listSync(recursive: false).whereType<Directory>()) {
    iceFileList.addAll(dir.listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path).isEmpty));
  }
  //fetch csv
  if (csvInfosFromSheets.isEmpty) {
    csvInfosFromSheets = await itemCsvFetcher(modManRefSheetsDirPath);
  }
  List<String> csvFileInfos = [];
  for (var iceFile in iceFileList) {
    //look in csv infos
    for (var csvFile in csvInfosFromSheets) {
      csvFileInfos.addAll(csvFile.where((line) => line.contains(p.basenameWithoutExtension(iceFile.path)) && !csvFileInfos.contains(line) && line.split(',')[1].isNotEmpty));
    }
  }
  if (csvInfosFromSheets.isNotEmpty) {
    csvInfosFromSheets.clear();
  }
  //create new item structures
  List<File> csvMatchedIceFiles = [];
  for (var infoLine in csvFileInfos) {
    final infos = infoLine.split(',');
    String itemName = '';
    curActiveLang == 'JP' ? itemName = infos[1] : itemName = infos[2];
    for (var char in charsToReplace) {
      itemName = itemName.replaceAll(char, '_');
    }

    //move files from temp
    String newItemDirPath = '';
    for (var iceFile in iceFileList) {
      if (infoLine.contains(p.basenameWithoutExtension(iceFile.path))) {
        newItemDirPath = Uri.file('$modManModsAdderPath/${infos[0]}/$itemName').toFilePath();
        String newIceFilePath = Uri.file('$newItemDirPath${iceFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
        newIceFilePath = removeRebootPath(newIceFilePath);
        await Directory(p.dirname(newIceFilePath)).create(recursive: true);
        iceFile.copySync(newIceFilePath);
        csvMatchedIceFiles.add(iceFile);
        //fetch extra file in ice dir
        final extraFiles = Directory(iceFile.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty);
        for (var extraFile in extraFiles) {
          String newExtraFilePath = Uri.file('$newItemDirPath${extraFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
          if (!File(newExtraFilePath).existsSync()) {
            extraFile.copySync(newExtraFilePath);
          }
        }
      }
    }
    //get item icon
    File newItemIcon = File('');
    if (infos[0] != defaultCateforyDirs[7] && infos[0] != defaultCateforyDirs[14]) {
      String ogIconIcePath = findIcePathInGameData(infos[5]);
      if (ogIconIcePath.isNotEmpty) {
        String tempIconUnpackDirPath = Uri.file('$modManModsAdderPath/${infos[0]}/$itemName/tempItemIconUnpack').toFilePath();
        final downloadedconIcePath = await downloadIconIceFromOfficial(ogIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), tempIconUnpackDirPath);
        //unpack and convert dds to png
        if (downloadedconIcePath.isNotEmpty) {
          //debugPrint(downloadedconIcePath);
          await Process.run('$modManZamboniExePath -outdir "$tempIconUnpackDirPath"', [downloadedconIcePath]);
          File ddsItemIcon = Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
          if (ddsItemIcon.path.isNotEmpty) {
            await Process.run(Uri.file('${Directory.current.path}/ddstopngtool/DDStronk.exe').toFilePath(), [ddsItemIcon.path]);
            File pngItemIcon =
                Directory('${downloadedconIcePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.png', orElse: () => File(''));
            if (pngItemIcon.path.isNotEmpty) {
              newItemIcon = pngItemIcon.renameSync(Uri.file('$modManModsAdderPath/${infos[0]}/$itemName/$itemName.png').toFilePath());
            }
          }
          Directory(tempIconUnpackDirPath).deleteSync(recursive: true);
        }
      }
    }
    //create new item object
    modsAdderItemList.add(ModsAdderItem(infos[0], itemName, newItemDirPath, newItemIcon.path, false, true, []));
  }
  //move unmatched ice files to misc
  bool isUnknownItemAdded = false;
  for (var iceFile in iceFileList) {
    if (!csvMatchedIceFiles.contains(iceFile)) {
      String itemName = curActiveLang == 'JP' ? '不明な項目' : 'Unknown Item';
      String newItemDirPath = Uri.file('$modManModsAdderPath/Misc/$itemName').toFilePath();
      String newIceFilePath = Uri.file('$newItemDirPath${iceFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
      newIceFilePath = removeRebootPath(newIceFilePath);
      await Directory(p.dirname(newIceFilePath)).create(recursive: true);
      iceFile.copySync(newIceFilePath);
      //fetch extra file in ice dir
      final extraFiles = Directory(iceFile.parent.path).listSync().whereType<File>().where((element) => p.extension(element.path).isNotEmpty);
      for (var extraFile in extraFiles) {
        String newExtraFilePath = Uri.file('$newItemDirPath${extraFile.path.replaceFirst(modManAddModsTempDirPath, '')}').toFilePath();
        if (!File(newExtraFilePath).existsSync()) {
          extraFile.copySync(newExtraFilePath);
        }
      }
      if (!isUnknownItemAdded) {
        modsAdderItemList.add(ModsAdderItem('Misc', itemName, newItemDirPath, '', true, true, []));
        isUnknownItemAdded = true;
      }
    }
  }

  //Sort to list
  for (var item in modsAdderItemList) {
    List<ModsAdderMod> mods = [];
    for (var modDir in Directory(item.itemDirPath).listSync().whereType<Directory>()) {
      List<ModsAdderSubMod> submods = [];
      for (var submodDir in Directory(modDir.path).listSync(recursive: true).whereType<Directory>()) {
        submods.add(ModsAdderSubMod(p.basename(submodDir.path), submodDir.path, true, Directory(modDir.path).listSync(recursive: true).whereType<File>().toList()));
      }
      mods.add(ModsAdderMod(p.basename(modDir.path), modDir.path, true, submods, Directory(modDir.path).listSync().whereType<File>().toList()));
    }
    item.modList.addAll(mods);
  }

  return modsAdderItemList;
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
