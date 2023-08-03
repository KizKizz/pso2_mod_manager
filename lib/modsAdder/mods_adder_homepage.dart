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

bool dropZoneMax = true;
bool _newModDragging = false;

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
                                          : newModDragDropList.isEmpty
                                              ? constraints.maxWidth * 0.3
                                              : constraints.maxWidth * 0.45,
                                      child: Column(
                                        children: [
                                          DropTarget(
                                            //enable: true,
                                            onDragDone: (detail) async {
                                              for (var element in detail.files) {
                                                if (p.extension(element.path) == '.rar' || p.extension(element.path) == '.7z') {
                                                  modsAdderUnsupportedFileTypeDialog(context);
                                                } else if (newModDragDropList.indexWhere((file) => file.path == element.path) == -1) {
                                                  newModDragDropList.add(element);
                                                  newModMainFolderList.add(element);
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
                                                      if (newModDragDropList.isEmpty)
                                                        Center(
                                                            child: Text(
                                                          curLangText!.uiDragDropFiles,
                                                          style: const TextStyle(fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        )),
                                                      if (newModDragDropList.isNotEmpty)
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(right: 5),
                                                            child: SizedBox(
                                                                width: constraints.maxWidth,
                                                                height: constraints.maxHeight,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                                                  child: ListView.builder(
                                                                      itemCount: newModDragDropList.length,
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
                                                                                  newModDragDropList.removeAt(index);
                                                                                  setState(
                                                                                    () {},
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          title: Text(newModDragDropList[index].name),
                                                                          subtitle: Text(
                                                                            newModDragDropList[index].path,
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
                                        ],
                                      )),
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
void modsAdderUnsupportedFileTypeDialog(context) {
  showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            titlePadding: const EdgeInsets.all(5),
            title: Text(curLangText!.uiError),
            contentPadding: const EdgeInsets.symmetric(horizontal: 5),
            content: Text(curLangText!.uiAchiveCurrentlyNotSupported),
            actionsPadding: const EdgeInsets.all(5),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(curLangText!.uiReturn))
            ],
          ));
}
