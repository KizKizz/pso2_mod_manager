import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

List<List<String>> csvData = [];

List<String> getCsvFilePath(String categoryName) {
  List<String> csvPaths = [];
  int categoryIndex = defaultCateforyDirs.indexOf(categoryName);
  for (var csvFileName in csvFileList[categoryIndex]) {
    csvPaths.add(Uri.file('$modManRefSheetsDirPath/Player/$csvFileName').toFilePath());
  }
  return csvPaths;
}

Future<List<List<String>>> sheetListFetchFromFiles(List<String> csvDirPaths) async {
  List<List<String>> csvList = [];
  for (var path in csvDirPaths) {
    File curCsvFile = File(path);
      csvList.add([]);
      csvList.last.add(p.basename(curCsvFile.path));
      await File(curCsvFile.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) => csvList.last.add(line));
  }

  return csvList;
}

void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            contentPadding: const EdgeInsets.all(5),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  return FutureBuilder(
                      future: sheetListFetchFromFiles(getCsvFilePath(fromItem.category)),
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
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiErrorWhenLoadingAppliedMods,
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
                            //Applied Item list
                            csvData = snapshot.data;
                            print(csvData);
                            return Row(
                              children: [
                                RotatedBox(
                                    quarterTurns: -1,
                                    child: Text(
                                      'MODS SWAP',
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 12),
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: constraints.maxHeight - 30,
                                              child: Card(
                                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                              child: Container(
                                                                  width: 80,
                                                                  height: 80,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(3),
                                                                    border: Border.all(
                                                                        color: fromItem.isNew
                                                                            ? Colors.amber
                                                                            : fromItem.applyStatus
                                                                                ? Theme.of(context).colorScheme.primary
                                                                                : Theme.of(context).hintColor,
                                                                        width: fromItem.isNew || fromItem.applyStatus ? 3 : 1),
                                                                  ),
                                                                  child: fromItem.icon.contains('assets/img/placeholdersquare.png')
                                                                      ? Image.asset(
                                                                          'assets/img/placeholdersquare.png',
                                                                          filterQuality: FilterQuality.none,
                                                                          fit: BoxFit.fitWidth,
                                                                        )
                                                                      : Image.file(
                                                                          File(fromItem.icon),
                                                                          filterQuality: FilterQuality.none,
                                                                          fit: BoxFit.fitWidth,
                                                                        )),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  fromItem.category,
                                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                                                ),
                                                                Text(fromItem.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                                                Text('${fromSubmod.modName} > ${fromSubmod.submodName}')
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const Divider(
                                                        height: 1,
                                                        thickness: 1,
                                                        indent: 5,
                                                        endIndent: 5,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 0),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 25,
                                            ),
                                          ),
                                          Expanded(
                                            child: Card(
                                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                child: Text('To')),
                                          ),
                                        ],
                                      ),
                                      Wrap(
                                        runAlignment: WrapAlignment.center,
                                        alignment: WrapAlignment.center,
                                        spacing: 5,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(curLangText!.uiClose),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            );
                          }
                        }
                      });
                }),
              ),
            ),
          );
        },
      );
    },
  );
}
