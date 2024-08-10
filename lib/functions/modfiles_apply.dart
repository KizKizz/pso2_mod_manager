import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/classes/aqm_item_class.dart';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/apply_mod_file.dart';
import 'package:pso2_mod_manager/functions/checksum_check.dart';
import 'package:pso2_mod_manager/functions/modfile_applied_dup.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future<List<ModFile>> modFilesApply(context, SubMod? submod, List<ModFile> modFiles) async {
  List<ModFile> alreadyAppliedModFiles = [];
  List<ModFile> appliedModFiles = [];
  // bool applyMods = true;
//check for checksum
  await applyModsChecksumChecker(context);
  //check for applied file
  for (var modFile in modFiles) {
    if (!modFile.applyStatus) {
      ModFile? appliedFile = await modFileAppliedDupCheck(moddedItemsList, modFile);
      if (appliedFile != null) {
        alreadyAppliedModFiles.add(appliedFile);
      }
      //Load list from json
      List<AqmItem> structureFromJson = [];
      String dataFromJson = await File(modManAqmInjectedItemListJsonPath).readAsString();
      if (dataFromJson.isNotEmpty) {
        var jsonData = await jsonDecode(dataFromJson);
        for (var item in jsonData) {
          structureFromJson.add(AqmItem.fromJson(item));
        }
      }
      ModFile? aqmAppliedFile = await modFileAqmReplacementCheck(structureFromJson, modFile);
      if (aqmAppliedFile != null) {
        alreadyAppliedModFiles.add(aqmAppliedFile);
      }
    }
  }

  //load custom aqm items
  List<AqmItem> aqmItemsFromJson = [];
  String dataFromJson = await File(modManAqmInjectedItemListJsonPath).readAsString();
  if (dataFromJson.isNotEmpty) {
    var jsonData = await jsonDecode(dataFromJson);
    for (var item in jsonData) {
      aqmItemsFromJson.add(AqmItem.fromJson(item));
    }
  }

  if (alreadyAppliedModFiles.isNotEmpty) {
    List<ModFile> modFilesToReplace = await duplicateAppliedDialog(context, submod, alreadyAppliedModFiles);
    if (modFilesToReplace.isNotEmpty) {
      for (var modFile in modFilesToReplace) {
        await modFileAppliedDupRestore(context, moddedItemsList, modFile);
        int? modFileToApplyIndex = modFiles.indexWhere((e) => e.modFileName == modFile.modFileName);
        if (modFileToApplyIndex != -1) {
          bool replacedStatus = await modFileApply(context, modFiles[modFileToApplyIndex]);
          if (replacedStatus) {
            modFiles[modFileToApplyIndex].applyStatus = true;
            modFiles[modFileToApplyIndex].applyDate = DateTime.now();
            if (modFiles[modFileToApplyIndex].isNew) {
              modFiles[modFileToApplyIndex].isNew = false;
            }
            aqmItemsFromJson.removeWhere(
                (e) => p.basenameWithoutExtension(e.hqIcePath) == modFiles[modFileToApplyIndex].modFileName || p.basenameWithoutExtension(e.lqIcePath) == modFiles[modFileToApplyIndex].modFileName);
            appliedModFiles.add(modFiles[modFileToApplyIndex]);
          }
        }
      }
    }

    //Save to json
    aqmItemsFromJson.map((item) => item.toJson()).toList();
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    File(modManAqmInjectedItemListJsonPath).writeAsStringSync(encoder.convert(aqmItemsFromJson));

    if (autoAqmInject) {
      final modFilesToIgnore = modFiles.where((e) => modFilesToReplace.where((i) => i.location == e.location).isEmpty);
      for (var cateType in moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0)) {
        for (var cate in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
          for (var item in cate.items.where((e) => e.applyStatus)) {
            for (var mod in item.mods.where((e) => e.applyStatus)) {
              for (var submod in mod.submods.where((e) => e.applyStatus)) {
                for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
                  if (modFilesToIgnore.where((e) => e.location == modFile.location).isNotEmpty) {
                    await aqmInjectionRemovalSilent(context, submod);
                    break;
                  }
                }
              }
            }
          }
        }
      }
    }
  } else {
    for (var modFile in modFiles) {
      bool replacedStatus = await modFileApply(context, modFile);
      if (replacedStatus) {
        modFile.applyStatus = true;
        modFile.applyDate = DateTime.now();
        if (modFile.isNew) {
          modFile.isNew = false;
        }
        appliedModFiles.add(modFile);
      }
    }
  }

  return appliedModFiles;
}

Future<List<ModFile>> duplicateAppliedDialog(context, SubMod? applyingSubmod, List<ModFile> dupModFiles) async {
  var selectedList = List.generate(dupModFiles.length, (int index) => true);
  List<ModFile> modFilesToReplace = dupModFiles.toList();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                title: Text(curLangText!.uiDuplicatesInAppliedModsFound, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: applyingSubmod != null,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 10),
                          child: Text(
                            '${curLangText!.uiApplying}:',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          )),
                    ),
                    Visibility(
                      visible: applyingSubmod != null,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 10, left: 15),
                          child: Text(
                            '${applyingSubmod!.category} > ${applyingSubmod.itemName} > ${applyingSubmod.modName} > ${applyingSubmod.submodName}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                          )),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          curLangText!.uiSelectWhichFilesToBeReplacedWithThisMod,
                          style: const TextStyle(fontSize: 14),
                        )),
                    ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                            }
                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                          }),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              for (int i = 0; i < dupModFiles.length; i++)
                                ListTile(
                                  leading: Icon(selectedList[i] ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined),
                                  title: Text('${dupModFiles[i].category} > ${dupModFiles[i].itemName} > ${dupModFiles[i].modName} > ${dupModFiles[i].submodName} > ${dupModFiles[i].modFileName}'),
                                  onTap: () {
                                    if (selectedList[i]) {
                                      selectedList[i] = false;
                                      modFilesToReplace.remove(dupModFiles[i]);
                                    } else {
                                      selectedList[i] = true;
                                      modFilesToReplace.add(dupModFiles[i]);
                                    }
                                    setState(
                                      () {},
                                    );
                                  },
                                )
                            ],
                          ),
                        )),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiSelectAll),
                      onPressed: () async {
                        modFilesToReplace = dupModFiles.toList();
                        selectedList = List.generate(dupModFiles.length, (int index) => true);
                        setState(
                          () {},
                        );
                      }),
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () async {
                        List<ModFile> emptyList = [];
                        Navigator.pop(context, emptyList);
                      }),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context, modFilesToReplace);
                      },
                      child: const Text('OK'))
                ]);
          }));
}
