import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

List<CsvIceFile> csvData = [];
String modManSwapperDirPath = Uri.file('${Directory.current.path}/swapper').toFilePath();
String modManSwapperIconsDirPath = Uri.file('${Directory.current.path}/swapper/icons').toFilePath();
CsvIceFile? selectedCsvIceFile;

List<File> getCsvFiles(String categoryName) {
  List<File> csvFiles = [];
  int categoryIndex = defaultCateforyDirs.indexOf(categoryName);
  for (var csvFileName in csvFileList[categoryIndex]) {
    final csvFilesFromPath = Directory(modManRefSheetsDirPath).listSync(recursive: true).whereType<File>().where((element) => p.basename(element.path) == csvFileName);
    for (var file in csvFilesFromPath) {
      csvFiles.add(file);
    }
  }
  return csvFiles;
}

Future<List<CsvIceFile>> sheetListFetchFromFiles(List<File> csvFiles) async {
  List<List<String>> csvList = [];
  List<CsvIceFile> csvIceFileList = [];
  for (var file in csvFiles) {
    csvList.add([]);
    //csvList.last.add(p.basename(file.path));
    await file.openRead().transform(utf8.decoder).transform(const LineSplitter()).skip(1).forEach((line) {
      int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(file.path)).isNotEmpty);
      if (categoryIndex != -1) {
        line = '${defaultCateforyDirs[categoryIndex]},$line';
      }
      csvList.last.add(line);
    });
  }

  for (var line in csvList) {
    for (var item in line) {
      csvIceFileList.add(CsvIceFile.fromList(item.split(',')));
    }
  }
  return csvIceFileList;
}

void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) async {
  csvData = await sheetListFetchFromFiles(getCsvFiles(fromItem.category));
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
                      backgroundColor: Colors.transparent,
                      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                        //create temp dirs

                        Directory(modManSwapperDirPath).createSync(recursive: true);
                        Directory(modManSwapperIconsDirPath).createSync(recursive: true);

                        //fetch icons

                        final iceNamesFromSubmod = fromSubmod.getModFileNames();
                        final fromItemCsvData = csvData
                            .where((element) =>
                                iceNamesFromSubmod.contains(element.hqIceName) ||
                                iceNamesFromSubmod.contains(element.nqIceName) ||
                                iceNamesFromSubmod.contains(element.nqLiIceName) ||
                                iceNamesFromSubmod.contains(element.hqLiIceName))
                            .toList();
                        List<List<String>> csvInfos = [];
                        for (var csvItemData in fromItemCsvData) {
                          final data = csvItemData.getDetailedList().where((element) => element.split(': ').last.isNotEmpty).toList();
                          final availableModFileData = data.where((element) => iceNamesFromSubmod.contains(element.split(': ').last)).toList();
                          csvInfos.add(availableModFileData);
                        }

                        //selectedCsvIceFile = fromItemCsvData.first;

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
                            //from
                            Expanded(
                                child: Card(
                              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                              color: Colors.transparent,
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
                                                border: Border.all(color: Theme.of(context).hintColor, width: 1),
                                              ),
                                              child: fromItem.icons.first.contains('assets/img/placeholdersquare.png')
                                                  ? Image.asset(
                                                      'assets/img/placeholdersquare.png',
                                                      filterQuality: FilterQuality.none,
                                                      fit: BoxFit.fitWidth,
                                                    )
                                                  : Image.file(
                                                      File(fromItem.icons.first),
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
                                    height: 5,
                                    thickness: 1,
                                    indent: 5,
                                    endIndent: 5,
                                  ),
                                  Expanded(
                                    child: ScrollbarTheme(
                                        data: ScrollbarThemeData(
                                          thumbColor: MaterialStateProperty.resolveWith((states) {
                                            if (states.contains(MaterialState.hovered)) {
                                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                            }
                                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                          }),
                                        ),
                                        child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text('Item variant found in current mod files'),
                                                ),
                                          for (int i = 0; i < fromItemCsvData.length; i++)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
                                              child: RadioListTile(
                                                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                value: fromItemCsvData[i],
                                                groupValue: selectedCsvIceFile,
                                                title: Text(fromItemCsvData[i].enName),
                                                subtitle: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [for (int line = 0; line < csvInfos[i].length; line++) Text(csvInfos[i][line])],
                                                ),
                                                onChanged: (CsvIceFile? currentItem) {
                                                  //print("Current ${moddedItemsList[i].groupName}");
                                                  selectedCsvIceFile = currentItem!;
                                                  setState(
                                                    () {},
                                                  );
                                                },
                                              ),
                                            ),
                                        ]))),
                                  ),
                                ],
                              ),
                            )),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 25,
                              ),
                            ),
                            //to
                            const Expanded(child: Column())
                          ],
                        );
                      }))));
        });
      });
}
