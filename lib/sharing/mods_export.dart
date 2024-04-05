import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> modExportHomePage(context, List<CategoryType> baseList, List<SubMod> exportSubmods) async {
  File exportedZip = File('');
  bool isWaiting = true;
  List<String> exportNames = exportSubmods.map((e) => '${e.itemName} > ${e.modName} > ${e.submodName}').toList();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200, minWidth: 200, maxHeight: double.infinity, maxWidth: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        curLangText!.uiModExport,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Visibility(
                      visible: exportedZip.path.isEmpty,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 5),
                              Text(
                                isWaiting ? exportNames.join('\n') : curLangText!.uiExportingMods,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          )),
                    ),
                    Visibility(
                      visible: exportedZip.path.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          exportedZip.existsSync() ? curLangText!.uiAllDone : curLangText!.uiFailed,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: Text(curLangText!.uiClose)),
                            Visibility(
                              visible: exportedZip.path.isEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      isWaiting = false;
                                      String exportedZipPath = await modExport(baseList, exportSubmods);
                                      exportedZip = File(exportedZipPath);
                                      setState(
                                        () {},
                                      );
                                    },
                                    child: Text(curLangText!.uiExport)),
                              ),
                            ),
                            Visibility(
                              visible: exportedZip.existsSync(),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      isWaiting = true;
                                      await launchUrl(Uri.file(exportedZip.parent.path));
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context, true);
                                    },
                                    child: Text(curLangText!.uiOpenInFileExplorer)),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ));
        });
      });
}

Future<String> modExport(List<CategoryType> baseList, List<SubMod> exportSubmods) async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
  String rootExportDir = '$modManExportedDirPath/PSO2NGSMMExportedMods_$formattedDate';
  List<String> exportedLog = [];
  await Directory(rootExportDir).create(recursive: true);
  for (var type in baseList) {
    for (var cate in type.categories) {
      for (var exportSubmod in exportSubmods) {
        if (cate.categoryName == exportSubmod.category && exportSubmod.location.contains(cate.location)) {
          String log = exportSubmod.category;
          for (var item in cate.items) {
            if (item.itemName == exportSubmod.itemName && exportSubmod.location.contains(item.location)) {
              log += ' > ${exportSubmod.itemName}';
              for (var mod in item.mods) {
                if (mod.modName == exportSubmod.modName && exportSubmod.location.contains(mod.location)) {
        //           log += ' > ${exportSubmod.modName} > ${exportSubmod.submodName}';
        //           Directory expCateDir = Directory(cate.location.replaceFirst(modManModsDirPath, rootExportDir));
        //           expCateDir.createSync(recursive: true);
        //           Directory expItemDir = Directory(item.location.replaceFirst(modManModsDirPath, rootExportDir));
        //           expItemDir.createSync(recursive: true);
        //           Directory expModDir = Directory(mod.location.replaceFirst(modManModsDirPath, rootExportDir));
        //           expModDir.createSync(recursive: true);
        //           Directory expSubmodDir = Directory(exportSubmod.location.replaceFirst(modManModsDirPath, rootExportDir));
        //           expSubmodDir.createSync(recursive: true);
                  for (var modFile in exportSubmod.modFiles) {
        //             await File(modFile.location).copy(modFile.location.replaceFirst(modManModsDirPath, rootExportDir));
        //           }
        //           //previews for submod
        //           for (var filePath in exportSubmod.previewImages) {
        //             await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
        //           }
        //           for (var filePath in exportSubmod.previewVideos) {
        //             await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
        //           }
        //           //previews file for mod
        //           for (var filePath in mod.previewImages.where((element) => File(element).parent.path == mod.location)) {
        //             await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
        //           }
        //           for (var filePath in mod.previewVideos.where((element) => File(element).parent.path == mod.location)) {
        //             await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
        //           }
        //           exportedLog.add(log);
        //           log = '';
                }
              }
        //       for (var iconPath in item.icons) {
        //         await File(iconPath).copy(iconPath.replaceFirst(modManModsDirPath, rootExportDir));
              }
            }
          }
        }
      }
    }
  }
  //Save logs
  File logFile = File(Uri.file('$rootExportDir/${curLangText!.uiExportedNote}.txt').toFilePath());
  await logFile.create(recursive: true);
  await logFile.writeAsString(exportedLog.join('\n'));
  //zip
  var encoder = ZipFileEncoder();
  await encoder.zipDirectoryAsync(Directory(rootExportDir));
  Directory(rootExportDir).deleteSync(recursive: true);

  if (File('$rootExportDir.zip').existsSync()) {
    return '$rootExportDir.zip';
  } else {
    return '';
  }
}
