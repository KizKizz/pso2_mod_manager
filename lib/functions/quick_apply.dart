// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:signals/signals_flutter.dart';

Future<void> quickModsRemoval(context) async {
  final isRunning = signal<bool>(false);
  final status = signal<String>('');
  File appliedModsFile = File(modManAppliedModsJsonPath);
  if (!appliedModsFile.existsSync()) {
    await appliedModsFile.create();
    if (appliedModsFile.existsSync()) {
      moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).map((cateType) => cateType.toJson()).toList();
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      appliedModsFile.writeAsStringSync(encoder.convert(moddedItemsList));
      List<ModFile> allModFilesInAppliedList = [];
      for (var type in moddedItemsList) {
        if (type.getNumOfAppliedCates() > 0) {
          for (var cate in type.categories) {
            if (cate.getNumOfAppliedItems() > 0) {
              for (var item in cate.items) {
                if (item.applyStatus) {
                  for (var mod in item.mods) {
                    if (mod.applyStatus) {
                      for (var submod in mod.submods) {
                        if (submod.applyStatus) {
                          allModFilesInAppliedList.addAll(submod.modFiles.where((e) => e.applyStatus));
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      saveApplyButtonState.value = SaveApplyButtonState.remove;
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (dialogContext, setState) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!isRunning.value && saveApplyButtonState.value == SaveApplyButtonState.remove) {
                  isRunning.value = true;
                  modViewModsApplyRemoving.value = true;
                  List<ModFile> reappliedModFiles = await restoreOriginalFilesToTheGame(context, allModFilesInAppliedList);
                  List<CategoryType> matchedTypes = [];
                  List<Item> matchedItems = [];
                  List<Mod> matchedMods = [];
                  List<SubMod> matchedSubmods = [];
                  for (var modFile in reappliedModFiles) {
                    var matchingTypes = moddedItemsList.where((element) => element.categories.where((cate) => cate.categoryName == modFile.category).isNotEmpty);
                    matchedTypes.addAll(matchingTypes);
                    for (var type in matchingTypes) {
                      var matchingCates = type.categories.where((element) => modFile.location.contains(element.location));
                      for (var cate in matchingCates) {
                        var matchingItems = cate.items.where((element) => modFile.location.contains(element.location));
                        for (var item in matchingItems) {
                          if (matchedItems.where((element) => element.location == item.location).isEmpty) {
                            matchedItems.add(item);
                          }
                          var matchingMods = item.mods.where((element) => modFile.location.contains(element.location));
                          for (var mod in matchingMods) {
                            if (matchedMods.where((element) => element.location == mod.location).isEmpty) {
                              matchedMods.add(mod);
                            }
                            var matchingSubmods = mod.submods.where((element) => modFile.location.contains(element.location));
                            for (var submod in matchingSubmods) {
                              if (matchedSubmods.where((element) => element.location == submod.location).isEmpty) {
                                matchedSubmods.add(submod);
                              }
                            }
                          }
                        }
                      }
                    }
                  }

                  for (var item in matchedItems) {
                    for (var mod in item.mods.where((element) => matchedMods.where((e) => e.location == element.location).isNotEmpty)) {
                      for (var submod in mod.submods.where((element) => matchedSubmods.where((e) => e.location == element.location).isNotEmpty)) {
                        if (submod.applyStatus) {
                          // unappliedFileNames += '${item.itemName} > ${mod.modName} > ${submod.submodName}\n';
                          submod.setApplyState(false);
                          submod.applyDate = DateTime(0);
                          previewImages.clear();
                          //videoPlayer.remove(0);
                          previewModName = '';
                          status.value += '${item.category} > ${item.itemName} > ${mod.modName} > ${submod.submodName}\n';
                        }

                        if (mod.submods.where((element) => element.applyStatus).isEmpty) {
                          mod.setApplyState(false);
                          mod.applyDate = DateTime(0);
                        }
                        if (item.mods.where((element) => element.applyStatus).isEmpty) {
                          item.applyDate = DateTime(0);
                          if (item.isOverlayedIconApplied!) {
                            await restoreOverlayedIcon(item);
                          }
                          item.setApplyState(false);
                        }
                      }
                    }
                  }

                  for (var type in matchedTypes) {
                    type.refresh();
                  }

                  saveModdedItemListToJson();
                  if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty && saveApplyButtonState.value != SaveApplyButtonState.none) {
                    // Navigator.pop(context);
                  }
                  isRunning.value = false;
                  modViewModsApplyRemoving.value = false;
                }
              });
              return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                title: Center(child: Text(!isRunning.watch(context) ? curLangText!.uiQuickRemoveAllMods : curLangText!.uiRemovingAllModsFromTheGame)),
                contentPadding: const EdgeInsets.all(20),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 150, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(visible: isRunning.watch(context), child: const CircularProgressIndicator()),
                      Visibility(visible: !isRunning.watch(context), child: Text(curLangText!.uiAllDone, style: const TextStyle(fontWeight: FontWeight.bold),)),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          status.watch(context),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        onPressed: !isRunning.watch(context)
                            ? () {
                                isRunning.value = false;
                                Navigator.pop(context, true);
                              }
                            : null,
                        child: Text(curLangText!.uiReturn)),
                  ),
                ],
              );
            });
          });
    }
  }
}

Future<void> quickModsReapply(context) async {
  final isRunning = signal<bool>(false);
  final status = signal<String>('');
  File appliedModsFile = File(modManAppliedModsJsonPath);
  if (appliedModsFile.existsSync()) {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (dialogContext, setState) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              //Load list from json
              if (!isRunning.value && File(modManAppliedModsJsonPath).existsSync()) {
                modViewModsApplyRemoving.value = true;
                isRunning.value = true;
                List<CategoryType> structureFromJson = [];
                String modSettingsFromJson = await File(modManAppliedModsJsonPath).readAsString();
                if (modSettingsFromJson.isNotEmpty) {
                  var jsonData = await jsonDecode(modSettingsFromJson);
                  for (var type in jsonData) {
                    structureFromJson.add(CategoryType.fromJson(type));
                  }
                }
                for (var type in structureFromJson) {
                  if (type.getNumOfAppliedCates() > 0) {
                    int matchingTypeIndex = moddedItemsList.indexWhere((e) => e.groupName == type.groupName);
                    CategoryType matchingType = moddedItemsList[matchingTypeIndex];
                    for (var cate in type.categories) {
                      if (cate.getNumOfAppliedItems() > 0) {
                        int matchingCateIndex = matchingType.categories.indexWhere((e) => e.location == cate.location);
                        Category matchingCate = matchingType.categories[matchingCateIndex];
                        for (var item in cate.items.where((e) => e.applyStatus)) {
                          int matchingItemIndex = matchingCate.items.indexWhere((e) => e.location == item.location);
                          Item matchingItem = matchingCate.items[matchingItemIndex];
                          for (var mod in item.mods.where((e) => e.applyStatus)) {
                            int matchingModIndex = matchingItem.mods.indexWhere((e) => e.location == mod.location);
                            Mod matchingMod = matchingItem.mods[matchingModIndex];
                            for (var submod in mod.submods.where((e) => e.applyStatus)) {
                              int matchingSubmodIndex = matchingMod.submods.indexWhere((e) => e.location == submod.location);
                              SubMod matchingSubmod = matchingMod.submods[matchingSubmodIndex];
                              List<ModFile> modFilesToReApply = [];
                              for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
                                int matchingModFileIndex = matchingSubmod.modFiles.indexWhere((e) => e.location == modFile.location);
                                ModFile matchingModFile = matchingSubmod.modFiles[matchingModFileIndex];
                                matchingModFile.ogLocations = modFile.ogLocations;
                                modFilesToReApply.add(matchingModFile);
                              }
                              await modFilesApply(context, modFilesToReApply);
                              matchingSubmod.setApplyState(true);
                              matchingSubmod.applyDate = DateTime.now();
                              status.value += '${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName}\n';
                            }
                            matchingMod.setApplyState(true);
                            matchingMod.applyDate = DateTime.now();
                          }
                          matchingItem.applyDate = DateTime.now();
                          if (markModdedItem && matchingItem.applyStatus && matchingItem.icons.isNotEmpty && !matchingItem.icons.contains('assets/img/placeholdersquare.png')) {
                            await applyOverlayedIcon(context, matchingItem);
                          }
                          matchingItem.setApplyState(true);
                        }
                      }
                    }
                  }
                }

                saveModdedItemListToJson();
                saveApplyButtonState.value = SaveApplyButtonState.none;
                if (File(modManAppliedModsJsonPath).existsSync()) File(modManAppliedModsJsonPath).deleteSync();
                isRunning.value = false;
                modViewModsApplyRemoving.value = false;
              }
              // Navigator.pop(context);
            });
            return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              title: Center(child: Text(!isRunning.watch(context) ? curLangText!.uiQuickReapplyAllModsToTheGame : curLangText!.uiReApplyingAllModsBackToTheGame)),
              contentPadding: const EdgeInsets.all(20),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 150, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(visible: isRunning.watch(context), child: const CircularProgressIndicator()),
                    Visibility(visible: !isRunning.watch(context), child: Text(curLangText!.uiAllDone, style: const TextStyle(fontWeight: FontWeight.bold),)),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        status.watch(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: ElevatedButton(
                      onPressed: !isRunning.watch(context)
                          ? () {
                              isRunning.value = false;
                              Navigator.pop(context, true);
                            }
                          : null,
                      child: Text(curLangText!.uiReturn)),
                ),
              ],
            );
          });
        });
  }
}
