import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<bool> applyAllAvailableModsDialog(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                contentPadding: const EdgeInsets.all(10),
                content: FutureBuilder(
                    future: //Future.delayed(const Duration(milliseconds: 500), () {
                        applyAllGetOgPaths(moddedItemsList)
                    //})
                    ,
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
                          return FutureBuilder(
                              future: applyAllAvailableMods(context, moddedItemsList),
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
                                            curLangText!.uiApplyingAllAvailableMods,
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
                                              curLangText!.uiSwappingItem,
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
                                    //appliedModsList = snapshot.data;
                                    //Navigator.pop(context, true);
                                    return SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Success',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          ElevatedButton(onPressed:() {
                                            Navigator.pop(context, true);
                                          }, child: Text(curLangText!.uiReturn))
                                        ],
                                      ),
                                    );
                                  }
                                }
                              });
                        }
                      }
                    }));
          }));
}

// Future<List<String>> applyAllAvailableMods(List<CategoryType> moddedList) async {
//   List<String> appliedList = [];
//   for (var cateType in moddedList) {
//     for (var cate in cateType.categories) {
//       String appliedPath = '${cate.categoryName} > ';
//       for (var item in cate.items) {
//         appliedPath += '${item.itemName} > ';
//         for (var mod in item.mods) {
//           appliedPath += '${mod.modName} > ';
//           for (var submod in mod.submods) {
//             appliedPath += submod.submodName;
//             for (var modFile in submod.modFiles) {
//               if (!modFile.applyStatus) {
//                 modFileApply(modFile).then((value) {
//                 if (appliedPath.isNotEmpty && !appliedList.contains(appliedPath)) {
//                   appliedList.add(appliedPath);
//                 }
//                 });
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   return appliedList;
// }

Future<bool> applyAllGetOgPaths(List<CategoryType> moddedList) async {
  //Future.delayed(const Duration(milliseconds: 3000), () {
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            for (var modFile in submod.modFiles) {
              if (!modFile.applyStatus && submod.submodName == 'Aelio Tribal D') {
                modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                print(modFile.ogLocations.length);
              }
            }
          }
        }
      }
    }
  }
  //});
  return true;
}

Future<List<String>> applyAllAvailableMods(context, List<CategoryType> moddedList) async {
  List<String> appliedList = [];
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      for (var item in cate.items) {
        for (var mod in item.mods) {
          for (var submod in mod.submods) {
            if (!submod.applyStatus) {
              String appliedPath = '${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName}';
              bool allOGFilesFound = true;
              for (var modFile in submod.modFiles) {
                if (modFile.ogLocations.isEmpty) {
                  allOGFilesFound = false;
                  break;
                }
              }
              if (allOGFilesFound && submod.submodName == 'Aelio Tribal D') {
                //print(appliedPath);
                modFilesApply(context, submod.modFiles).then((value) async {
                  if (submod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
                    submod.applyDate = DateTime.now();
                    item.applyDate = DateTime.now();
                    mod.applyDate = DateTime.now();
                    submod.applyStatus = true;
                    submod.isNew = false;
                    mod.applyStatus = true;
                    mod.isNew = false;
                    item.applyStatus = true;
                    item.isNew = false;
                    appliedItemList = await appliedListBuilder(moddedItemsList);
                  }
                  saveModdedItemListToJson();
                  if (appliedPath.isNotEmpty && !appliedList.contains(appliedPath)) {
                    appliedList.add(appliedPath);
                  }
                });
              }
            }
          }
        }
      }
    }
  }
  return appliedList;
}

// Future<List<String>> applyAllAvailableMods(List<CategoryType> moddedList) async {
//   List<String> appliedList = [];
//   for (var cateType in moddedList) {
//     for (var cate in cateType.categories) {
//       for (var item in cate.items) {
//         for (var mod in item.mods) {
//           for (var submod in mod.submods) {
//             for (var modFile in submod.modFiles) {
//               if (!modFile.applyStatus) {
//                 String appliedPath = '${cate.categoryName} > ${item.itemName} > ${mod.modName} > ${submod.submodName}';
//                 if (modFile.ogLocations.isNotEmpty && modFile.submodName == 'Aelio Tribal D') {
//                   //print(appliedPath);
//                   modFileApply(modFile).then((value) async {
//                     if (submod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
//                       submod.applyDate = DateTime.now();
//                       item.applyDate = DateTime.now();
//                       mod.applyDate = DateTime.now();
//                       submod.applyStatus = true;
//                       submod.isNew = false;
//                       mod.applyStatus = true;
//                       mod.isNew = false;
//                       item.applyStatus = true;
//                       item.isNew = false;
//                       modFile.applyStatus = true;
//                       modFile.applyDate = DateTime.now();
//                       if (modFile.isNew) {
//                         modFile.isNew = false;
//                       }
//                       print(appliedPath);
//                       // List<ModFile> appliedModFiles = value;
//                       // String fileAppliedText = '';
//                       // for (var element in appliedModFiles) {
//                       //   if (fileAppliedText.isEmpty) {
//                       //     fileAppliedText = '${curLangText!.uiSuccessfullyApplied} ${curMod.modName} > ${curSubmod.submodName}:\n';
//                       //   }
//                       //   fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
//                       // }
//                       // ScaffoldMessenger.of(context).showSnackBar(
//                       //     snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
//                       appliedItemList = await appliedListBuilder(moddedItemsList);
//                     }

//                     saveModdedItemListToJson();
//                     if (appliedPath.isNotEmpty && !appliedList.contains(appliedPath)) {
//                       appliedList.add(appliedPath);
//                     }
//                   });
//                 }
//               }
//             }
//           }
//         }
//       }
//     }
//   }

//   return appliedList;
// }
