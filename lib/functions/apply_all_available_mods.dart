import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

bool isApplyAllApplied = false;

Future<bool> applyAllAvailableModsDialog(context) async {
  Future<int> applyAllOgFileLocations = applyAllGetOgPaths(moddedItemsList);
  int totalFiles = 0;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                contentPadding: const EdgeInsets.all(10),
                content: FutureBuilder(
                    future: applyAllOgFileLocations,
                    builder: (
                      BuildContext context,
                      AsyncSnapshot snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiLocatingOriginalFiles,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                      } else {
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  curLangText!.uiErrorWhenLocatingOriginalFiles,
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
                                    child: Text(curLangText!.uiReturn),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return SizedBox(
                            width: 250,
                            height: 250,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiErrorWhenLocatingOriginalFiles,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        } else {
                          totalFiles = snapshot.data;
                          // WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!isApplyAllApplied) {
                            isApplyAllApplied = true;
                            applyAllCallBack(context);
                          }
                          //});
                          return ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 250, minWidth: 250, maxHeight: double.infinity, maxWidth: double.infinity),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                context.watch<StateProvider>().applyAllProgressCounter < totalFiles
                                    ? Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          curLangText!.uiApplyingAllAvailableMods,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          curLangText!.uiSuccessfullyApplied,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                if (context.watch<StateProvider>().applyAllProgressCounter < totalFiles) const CircularProgressIndicator(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text('${context.watch<StateProvider>().applyAllProgressCounter} / $totalFiles ${curLangText!.uiMods}'),
                                ),
                                Visibility(
                                  visible: context.watch<StateProvider>().applyAllProgressCounter < totalFiles,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(context.watch<StateProvider>().applyAllStatus),
                                  ),
                                ),
                                Visibility(
                                  visible: context.watch<StateProvider>().applyAllProgressCounter >= totalFiles,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          isApplyAllApplied = false;
                                          totalFiles = 0;
                                          Provider.of<StateProvider>(context, listen: false).applyAllProgressCounterReset();
                                          Provider.of<StateProvider>(context, listen: false).setApplyAllStatus('');
                                          Navigator.pop(context, true);
                                        },
                                        child: Text(curLangText!.uiReturn)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }));
          }));
}

Future<int> applyAllGetOgPaths(List<CategoryType> moddedList) async {
  int totalFiles = 0;
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      //if (cate.categoryName == 'Outerwears') {
      for (var item in cate.items) {
        if (!item.applyStatus) {
          if (item.mods.isNotEmpty && !item.mods.first.applyStatus) {
            if (item.mods.first.submods.isNotEmpty && !item.mods.first.submods.first.applyStatus) {
              bool ogFileFound = false;
              for (var modFile in item.mods.first.submods.first.modFiles) {
                if (!modFile.applyStatus) {
                  await Future.delayed(const Duration(milliseconds: 5));
                  modFile.ogLocations = applyModsOgIcePathsFetcher(item.mods.first.submods.first, modFile.modFileName);
                  if (modFile.ogLocations.isNotEmpty) {
                    ogFileFound = true;
                  }
                  //print(modFile.ogLocations.length);
                }
              }
              if (ogFileFound) {
                totalFiles++;
                ogFileFound = false;
              }
            }
          }
        }
      }
      //}
    }
  }
  return totalFiles;
}

Future<void> applyAllCallBack(context) async {
  //Provider.of<StateProvider>(context, listen: false).applyAllProgressCounterReset();
  for (var cateType in moddedItemsList) {
    for (var cate in cateType.categories) {
      //if (cate.categoryName == 'Outerwears') {
      for (var item in cate.items) {
        if (!item.applyStatus) {
          if (!item.mods.first.applyStatus) {
            if (!item.mods.first.submods.first.applyStatus) {
              applyAllAvailableMods(context, item, item.mods.first, item.mods.first.submods.first).then((value) async {
                appliedItemList = await appliedListBuilder(moddedItemsList);
              });
            }
          }
        }
      }
      //}
    }
  }
  isApplyAllApplied = true;
}

Future<String> applyAllAvailableMods(context, Item item, Mod mod, SubMod submod) async {
  if (await originalFilesCheck(context, submod.modFiles)) {
    if (removeBoundaryRadiusOnModsApply) {
      await removeBoundaryOnModsApply(context, submod);
    }
    String appliedPath = '${item.category} > ${submod.itemName} > ${submod.modName} > ${submod.submodName}';
    for (var modFile in submod.modFiles) {
      if (modFile.ogLocations.isNotEmpty) {
        final appliedFiles = await modFilesApply(context, [modFile]);
        if (appliedFiles.where((element) => element.modFileName == modFile.modFileName).isNotEmpty) {
          submod.applyDate = DateTime.now();
          item.applyDate = DateTime.now();
          mod.applyDate = DateTime.now();
          submod.applyStatus = true;
          submod.isNew = false;
          mod.applyStatus = true;
          mod.isNew = false;
          item.applyStatus = true;
          item.isNew = false;
          saveModdedItemListToJson();
        }
      }
    }

    if (submod.applyStatus) {
      //apply cmx
      if (submod.hasCmx!) {
        int startIndex = -1, endIndex = -1;
        (startIndex, endIndex) = await cmxModPatch(submod.cmxFile!);
        if (startIndex != -1 && endIndex != -1) {
          submod.cmxStartPos = startIndex;
          submod.cmxEndPos = endIndex;
          submod.cmxApplied = true;
          saveModdedItemListToJson();
        }
      }
      await applyOverlayedIcon(context, item);

      Provider.of<StateProvider>(context, listen: false).applyAllProgressCounterIncrease();
      Provider.of<StateProvider>(context, listen: false).setApplyAllStatus(appliedPath);
      await Future.delayed(const Duration(milliseconds: 100));
      return appliedPath;
    }
  }

  return '';
}
