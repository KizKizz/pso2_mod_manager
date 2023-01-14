import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';

List<String> _pathsToRemove = ['win32', 'win32reboot', 'win32_na', 'win32reboot_na'];
bool _newModDragging = false;
final List<XFile> _newModDragDropList = [];
List<XFile> modsToAddList = [];
Future? sortedModsListLoad;
List<List<String>> sortedModsList = [];
String tempDirPath = '${Directory.current.path}${s}temp';

//Csv lists
List<String> _accessoriesCsv = ['Accessories.csv'];
List<String> _emoteCsv = ['LobbyActionsNGS_HandPoses.csv', 'LobbyActions.csv'];
List<String> _basewearCsv = ['GenderlessNGSBasewear.csv', 'FemaleNGSBasewear.csv', 'MaleNGSBasewear.csv', 'FemaleBasewear.csv', 'MaleBasewear.csv'];

void modAddHandler(context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
              title: const Text('Adding mods'),
              titlePadding: const EdgeInsets.all(5),
              contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return FutureBuilder(
                      future: popSheetsList(refSheetsDirPath),
                      builder: ((
                        BuildContext context,
                        AsyncSnapshot snapshot,
                      ) {
                        if (snapshot.connectionState == ConnectionState.waiting && ngsRefSheetsList.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Text(
                                'Preparing',
                                style: TextStyle(fontSize: 20),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              CircularProgressIndicator(),
                            ],
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          ngsRefSheetsList = snapshot.data;
                        }
                        return Row(
                          children: [
                            Column(
                              children: [
                                DropTarget(
                                  //enable: true,
                                  onDragDone: (detail) async {
                                    for (var element in detail.files) {
                                      if (_newModDragDropList.indexWhere((file) => file.path == element.path) == -1) {
                                        _newModDragDropList.add(element);
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
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: Theme.of(context).hintColor),
                                        color: _newModDragging ? Colors.blue.withOpacity(0.4) : Colors.black26.withAlpha(20),
                                      ),
                                      height: constraints.maxHeight - 33,
                                      width: constraints.maxWidth * 0.3,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (_newModDragDropList.isEmpty) const Center(child: Text('Drag and drop files here')),
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
                                                                  message: 'Remove',
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
                                SizedBox(
                                  width: constraints.maxWidth * 0.3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
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
                                              child: const Text('Clear All')),
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
                                                          await unzipPack(file.path, file.name.split('.').first);
                                                          modsToAddList.addAll(await sortFile(file.name.split('.').first));
                                                          // } else if (Directory(file.path).existsSync()) {
                                                          //   List<XFile> filesInFolder = [];
                                                          //   for (var file in Directory(file.path).listSync(recursive: true)) {
                                                          //     if (File(file.path).existsSync()) {
                                                          //       filesInFolder.add(XFile(file.path));
                                                          //     }
                                                          //   }
                                                          //  modsToAddList.addAll(filesInFolder);
                                                        } else {
                                                          modsToAddList.add(XFile(file.path));
                                                        }
                                                      }

                                                      //Test
                                                      for (var element in modsToAddList) {
                                                        print(element.path);
                                                      }

                                                      //clear lists
                                                      _newModDragDropList.clear();
                                                      sortedModsListLoad = fetchItemName(modsToAddList);
                                                      setState(
                                                        () {},
                                                      );
                                                    })
                                                  : null,
                                              child: const Text('Process')),
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
                            Container(
                                width: constraints.maxWidth * 0.4,
                                height: constraints.maxHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Theme.of(context).hintColor),
                                  //color: _newModDragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                                ),
                                child: FutureBuilder(
                                    future: sortedModsListLoad,
                                    builder: (
                                      BuildContext context,
                                      AsyncSnapshot snapshot,
                                    ) {
                                      if (snapshot.connectionState == ConnectionState.none) {
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Waiting for data',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            CircularProgressIndicator(),
                                          ],
                                        );
                                      } else {
                                        if (snapshot.hasError) {
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Error when loading data. Restart the app.',
                                                style: TextStyle(color: Theme.of(context).textTheme.bodyText1?.color, fontSize: 20),
                                              ),
                                            ],
                                          );
                                        } else if (!snapshot.hasData) {
                                          return Column(
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
                                          );
                                        } else {
                                          sortedModsList = snapshot.data;
                                          //print(sortedModsList.length);
                                          return SingleChildScrollView(
                                              controller: AdjustableScrollController(80),
                                              child: ListView.builder(
                                                  //key: Key('builder ${modNameCatSelected.toString()}'),
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: sortedModsList.length,
                                                  itemBuilder: (context, index) {
                                                    return Card(
                                                      margin: const EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 2),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                          side: BorderSide(
                                                              width: 1, color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).primaryColorLight)),
                                                      child: ExpansionTile(
                                                        initiallyExpanded: true,
                                                        title: curActiveLang == 'JP'
                                                            ? Text('${sortedModsList[index].first} > ${sortedModsList[index][1]}',
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w500,
                                                                ))
                                                            : Text('${sortedModsList[index].first} > ${sortedModsList[index][2]}',
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w500,
                                                                )),
                                                        textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                        iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                        collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                        children: [
                                                          for (int ex = 0; ex < sortedModsList[index][3].split('|').length; ex++)
                                                            ExpansionTile(
                                                              initiallyExpanded: false,
                                                              textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                              iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                              collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                              title: Text(sortedModsList[index][3].split('|')[ex]),
                                                              children: [
                                                                for (int i = 0; i < modsToAddList.length; i++)
                                                                  if (sortedModsList[index].last.split('|').indexWhere((element) => element == modsToAddList[i].path) != -1 &&
                                                                      modsToAddList[i].path.contains(sortedModsList[index][3].split('|')[ex]))
                                                                    ListTile(
                                                                      title: Text(modsToAddList[i].name),
                                                                      //dense: true,
                                                                    )
                                                              ],
                                                            )
                                                        ],
                                                      ),
                                                    );
                                                  }));
                                        }
                                      }
                                    }))
                          ],
                        );
                      }),
                    );
                  })));
        });
      });
}

Future<void> unzipPack(String filePath, String fileName) async {
  // Use an InputFileStream to access the zip file without storing it in memory.
  final inputStream = InputFileStream(filePath);
  // Decode the zip from the InputFileStream. The archive will have the contents of the
  // zip, without having stored the data in memory.
  final archive = ZipDecoder().decodeBuffer(inputStream);
  // For all of the entries in the archive
  for (var file in archive.files) {
    // If it's a file and not a directory
    if (file.isFile) {
      // Write the file content to a directory called 'out'.
      // In practice, you should make sure file.name doesn't include '..' paths
      // that would put it outside of the extraction directory.
      // An OutputFileStream will write the data to disk.
      final outputStream = OutputFileStream('temp$s$fileName$s${file.name}');
      // The writeContent method will decompress the file content directly to disk without
      // storing the decompressed data in memory.
      file.writeContent(outputStream);
      // Make sure to close the output stream so the File is closed.
      outputStream.close();
    }
  }
}

Future<List<XFile>> sortFile(String fileName) async {
  List<XFile> filesList = [];
  for (var file in Directory('$tempDirPath$s$fileName$s').listSync(recursive: true)) {
    if (p.extension(file.path) == '' && !Directory(file.path).existsSync()) {
      XFile newFile = XFile(file.path);
      filesList.add(newFile);
    }
  }

  return filesList;
}

Future<List<List<String>>> fetchItemName(List<XFile> inputFiles) async {
  //getting main dirs
  List<String> mainDirPaths = [];
  for (var inputFile in inputFiles) {
    if (!File(inputFile.path).existsSync() && !inputFile.path.contains(tempDirPath)) {
      if (mainDirPaths.isEmpty) {
        mainDirPaths.add(inputFile.path);
      } else {
        if (mainDirPaths.indexWhere((element) => inputFile.path.contains(element)) != -1) {
          mainDirPaths.add(inputFile.path);
        }
      }
    }
  }

  //copy files to temp with new folder structures
  for (var inputFile in inputFiles) {
    if (File(inputFile.path).existsSync() && !inputFile.path.contains(tempDirPath)) {
      String subDirName = '';
      if (_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element)) != -1) {
        subDirName = inputFile.path.split(s)[inputFile.path.split(s).indexOf(_pathsToRemove[_pathsToRemove.indexWhere((element) => inputFile.path.split(s).contains(element))]) - 1];
      } else {
        subDirName = inputFile.path.split(s)[inputFile.path.split(s).indexOf(inputFile.name) - 1];
      }
      if (subDirName.isNotEmpty) {

      }
    }

  print(mainDirPaths);

  return [];
}

// Future<List<List<String>>> fetchItemName(List<XFile> inputFiles) async {
//   Function deepEq = const DeepCollectionEquality().equals;
//   List<List<String>> fileList = [];
//   List<XFile> extraFiles = [];

//   for (var inputFile in inputFiles) {
//     if (p.extension(inputFile.path) != '') {
//       extraFiles.add(inputFile);
//     } else {
//       if (fileList.isEmpty) {
//         fileList.add(await findItemInCsv(inputFile));
//       } else {
//         List<String> curFilePath = inputFile.path.split(s);
//         curFilePath.removeRange(inputFile.path.split(s).length - 1, inputFile.path.split(s).length);
//         String curSubFolder = curFilePath.removeLast();
//         for (var element in _pathsToRemove) {
//           int index = curFilePath.indexOf(element);
//           if (index != -1) {
//             curFilePath.removeRange(index, curFilePath.length);
//             //newFilePath = filePathSplit.join(s);
//             //print(newFilePath);
//             break;
//           }
//         }
//         String curDirPath = curFilePath.join(s);
//         bool foundInList = false;
//         for (var line in fileList) {
//           List<String> line4 = line[4].split(s);
//           for (var element in _pathsToRemove) {
//             int index = line4.indexOf(element);
//             if (index != -1) {
//               line4.removeRange(index, line4.length);
//               break;
//             }
//           }
//           if (line4.join(s) == curDirPath) {
//             foundInList = true;
//             if (line[3].split('|').indexWhere((element) => element == curSubFolder) == -1) {
//               line[3] += '|$curSubFolder';
//             }
//             if (line.last.split('|').indexWhere((element) => element == inputFile.path) == -1) {
//               line.last += '|${inputFile.path}';
//             }
//             break;
//           }
//           print(line);
//         }
//         if (!foundInList) {
//           var list = await findItemInCsv(inputFile);
//           if (fileList.indexWhere((element) => deepEq(element, list)) == -1) {
//             fileList.add(list);
//           }
//         }
//       }
//     }
//     if (extraFiles.isNotEmpty) {
//       for (var extraFile in extraFiles) {
//         List<String> curFilePath = extraFile.path.split(s);
//         curFilePath.removeRange(extraFile.path.split(s).length - 1, extraFile.path.split(s).length);
//         String curSubFolder = curFilePath.removeLast();
//         String curDirPath = curFilePath.join(s);
//         for (var line in fileList) {
//           if (line[4] == curDirPath) {
//             if (line[3].split('|').indexWhere((element) => element == curSubFolder) == -1) {
//               line[3] += '|$curSubFolder';
//             }
//             if (line.last.split('|').indexWhere((element) => element == inputFile.path) == -1) {
//               line.last += '|${extraFile.path}';
//             }
//             break;
//           }
//           //print(line);
//         }
//       }
//     }
//   }
//   return fileList;
// }

Future<List<String>> findItemInCsv(XFile inputFile) async {
  for (var file in ngsRefSheetsList) {
    for (var line in file) {
      if (p.extension(inputFile.path) == '' && line.contains(inputFile.name)) {
        var lineSplit = line.split(',');
        var filePathSplit = inputFile.path.split(s);
        var newFilePath = '';
        for (var element in _pathsToRemove) {
          int index = filePathSplit.indexOf(element);
          if (index != -1) {
            filePathSplit.removeRange(index, filePathSplit.length);
            newFilePath = filePathSplit.join(s);
            //print(newFilePath);
            break;
          }
        }
        if (newFilePath.isEmpty) {
          filePathSplit.removeAt(filePathSplit.length - 1);
          newFilePath = filePathSplit.join(s);
        }
        List<String> curFilePath = inputFile.path.split(s);
        curFilePath.removeRange(inputFile.path.split(s).length - 2, inputFile.path.split(s).length);
        String curDirPath = curFilePath.join(s);
        //[0 Category, 1 JP name, 2 EN name, 3 Parent Folder, 4 path, 5 new path, 6 sheets, 7 files]
        if (_emoteCsv.indexWhere((element) => file.first == element) != -1) {
          return (['Emotes', lineSplit[1], lineSplit[2], newFilePath.split(s).last, curDirPath, newFilePath, line, inputFile.path]);
        } else if (_basewearCsv.indexWhere((element) => element == file.first) != -1) {
          return (['Basewears', lineSplit[0], lineSplit[1], newFilePath.split(s).last, curDirPath, newFilePath, line, inputFile.path]);
        } else {
          return ([file.first, lineSplit[0], lineSplit[1], newFilePath.split(s).last, curDirPath, newFilePath, line, inputFile.path]);
        }
      }
    }
  }

  return [];
}
