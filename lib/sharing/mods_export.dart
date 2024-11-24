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
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

Future<void> modExportHomePage(context, List<CategoryType> baseList, List<SubMod> exportSubmods, appliedModsExport) async {
  File exportedZip = File('');
  List<String> exportNames = exportSubmods.map((e) => '${e.itemName} > ${e.modName} > ${e.submodName}').toList();
  Provider.of<StateProvider>(context, listen: false).createModExportProgressStatus(List.generate(exportNames.length, (index) => false));
  bool exportStart = false;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            titlePadding: const EdgeInsets.symmetric(vertical: 5),
            title: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                curLangText!.uiModExport,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Visibility(
                visible: context.watch<StateProvider>().modExportProgessZipping && !exportedZip.existsSync(), 
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    curLangText!.uiPackingFiles,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                )),
              ),
            ]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 20, minWidth: 200, maxHeight: double.infinity, maxWidth: double.infinity),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: exportedZip.path.isEmpty,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int i = 0; i < exportNames.length; i++)
                                Text(
                                  exportNames[i],
                                  style: TextStyle(fontSize: 15, color: context.watch<StateProvider>().modExportProgressStatus[i] ? Colors.green : null),
                                ),
                            ],
                          )),
                    ),
                    Visibility(
                      visible: exportedZip.path.isNotEmpty,
                      child: Center(
                        child: Text(
                          exportedZip.existsSync() ? curLangText!.uiAllDone : curLangText!.uiFailed,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(5),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Provider.of<StateProvider>(context, listen: false).modExportProgessZippingStateSet(false);
                    exportStart = false;
                    Navigator.pop(context, true);
                  },
                  child: Text(curLangText!.uiClose)),
              Visibility(
                visible: exportedZip.path.isEmpty,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: ElevatedButton(
                      onPressed: !exportStart
                      ? () async {
                        exportStart = true;
                        setState(
                          () {},
                        );
                        String exportedZipPath = await modExport(context, baseList, exportSubmods, appliedModsExport);
                        exportedZip = File(exportedZipPath);
                        exportStart = false;
                        setState(
                          () {},
                        );
                      }
                      : null,
                      child: Text(curLangText!.uiExport)),
                ),
              ),
              Visibility(
                visible: exportedZip.existsSync(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: ElevatedButton(
                      onPressed: () async {
                        Provider.of<StateProvider>(context, listen: false).modExportProgessZippingStateSet(false);
                        exportStart = false;
                        await launchUrlString(exportedZip.parent.path);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, true);
                      },
                      child: Text(curLangText!.uiOpenInFileExplorer)),
                ),
              ),
            ],
          );
        });
      });
}

Future<String> modExport(context, List<CategoryType> baseList, List<SubMod> exportSubmods, bool appliedModsExport) async {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
  String rootExportDir = '$modManExportedDirPath/PSO2NGSMMExportedMods_$formattedDate';
  List<String> exportedLog = [];
  await Directory(rootExportDir).create(recursive: true);
  for (var type in baseList) {
    for (var exportSubmod in exportSubmods) {
      for (var cate in type.categories) {
        if (cate.categoryName == exportSubmod.category && exportSubmod.location.contains(cate.location)) {
          String log = exportSubmod.category;
          Directory expCateDir = Directory(cate.location.replaceFirst(modManModsDirPath, rootExportDir));
          expCateDir.createSync(recursive: true);
          for (var item in cate.items) {
            if (item.itemName == exportSubmod.itemName && exportSubmod.location.contains(item.location)) {
              log += ' > ${exportSubmod.itemName}';
              Directory expItemDir = Directory(item.location.replaceFirst(modManModsDirPath, rootExportDir));
              expItemDir.createSync(recursive: true);
              for (var iconPath in item.icons) {
                File icon = File(iconPath);
                if (icon.existsSync() && p.basename(icon.path) != 'placeholdersquare.png') await icon.copy(icon.path.replaceFirst(icon.parent.path, expItemDir.path));
              }
              for (var mod in item.mods) {
                if (mod.modName == exportSubmod.modName && exportSubmod.location.contains(mod.location)) {
                  log += ' > ${exportSubmod.modName} > ${exportSubmod.submodName}';
                  Directory expModDir = Directory(mod.location.replaceFirst(modManModsDirPath, rootExportDir));
                  expModDir.createSync(recursive: true);
                  Directory expSubmodDir = Directory(exportSubmod.location.replaceFirst(modManModsDirPath, rootExportDir));
                  expSubmodDir.createSync(recursive: true);
                  //previews file for mod
                  for (var filePath in mod.previewImages.where((element) => File(element).parent.path == mod.location)) {
                    await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                  }
                  for (var filePath in mod.previewVideos.where((element) => File(element).parent.path == mod.location)) {
                    await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                  }
                  //previews for submod
                  for (var filePath in exportSubmod.previewImages) {
                    await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                  }
                  for (var filePath in exportSubmod.previewVideos) {
                    await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                  }
                  for (var modFile in exportSubmod.modFiles) {
                    if (appliedModsExport) {
                      if (modFile.applyStatus) await File(modFile.location).copy(modFile.location.replaceFirst(modManModsDirPath, rootExportDir));
                    } else {
                      await File(modFile.location).copy(modFile.location.replaceFirst(modManModsDirPath, rootExportDir));
                    }
                    //previews file for modFile
                    for (var filePath in modFile.previewImages!) {
                      await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                    }
                    for (var filePath in modFile.previewVideos!) {
                      await File(filePath).copy(filePath.replaceFirst(modManModsDirPath, rootExportDir));
                    }
                    if (log.isNotEmpty && log.contains(exportSubmod.submodName)) {
                      exportedLog.add(log);
                      Provider.of<StateProvider>(context, listen: false).setModExportProgressStatus(exportSubmods.indexOf(exportSubmod), true);
                    }
                    log = '';
                    await Future.delayed(const Duration(milliseconds: 10));
                  }
                }
              }
            }
          }
        }
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
  Provider.of<StateProvider>(context, listen: false).modExportProgessZippingStateSet(true);
  await Future.delayed(const Duration(milliseconds: 50));
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
