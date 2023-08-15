import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

void applyAllAvailableModsDialog(context) {
  int totalFiles = 0;
  showDialog(
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
                        return const SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Locating paths of original files',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                CircularProgressIndicator(),
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
                                  curLangText!.uiErrorWhenApplyingAllAvailableMods,
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
                                    curLangText!.uiErrorWhenApplyingAllAvailableMods,
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
                                if (context.watch<StateProvider>().applyAllProgressCounter < totalFiles)
                                const CircularProgressIndicator(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text('${context.watch<StateProvider>().applyAllProgressCounter} / $totalFiles ${curLangText!.uiMods}'),
                                ),
                                if (context.watch<StateProvider>().applyAllProgressCounter < totalFiles)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(context.watch<StateProvider>().applyAllStatus),
                                ),
                                if (context.watch<StateProvider>().applyAllProgressCounter >= totalFiles)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: Text(curLangText!.uiReturn)),
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
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            bool ogFileFound = false;
            for (var modFile in submod.modFiles) {
              if (!modFile.applyStatus) {
                modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
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
  }
  return totalFiles;
}

Future<String> applyAllAvailableMods(context, String categoryName, SubMod submod) async {
  //List<String> appliedList = [];
  String appliedPath = '$categoryName > ${submod.itemName} > ${submod.modName} > ${submod.submodName}';
  if (!submod.applyStatus) {
    bool allOGFilesFound = true;
    for (var modFile in submod.modFiles) {
      if (modFile.ogLocations.isEmpty) {
        allOGFilesFound = false;
        break;
      }
    }
    if (allOGFilesFound) {
      print(appliedPath);
      // modFilesApply(context, submod.modFiles).then((value) async {
      //   if (submod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
      //     submod.applyDate = DateTime.now();
      //     item.applyDate = DateTime.now();
      //     mod.applyDate = DateTime.now();
      //     submod.applyStatus = true;
      //     submod.isNew = false;
      //     mod.applyStatus = true;
      //     mod.isNew = false;
      //     item.applyStatus = true;
      //     item.isNew = false;
      //     appliedItemList = await appliedListBuilder(moddedItemsList);
      //   }
      //   saveModdedItemListToJson();
      // if (appliedPath.isNotEmpty && !appliedList.contains(appliedPath)) {
      //   appliedList.add(appliedPath);

      //}
      // });
      Provider.of<StateProvider>(context, listen: false).applyAllProgressCounterIncrease();
      Provider.of<StateProvider>(context, listen: false).setApplyAllStatus(appliedPath);
      return appliedPath;
    }
  }

  return '';
}