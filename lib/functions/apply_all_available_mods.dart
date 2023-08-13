import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/functions/apply_mods.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<void> applyAllAvailableModsDialog(context) async {
  List<String> appliedModsList = [];
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                contentPadding: const EdgeInsets.all(10),
                content: FutureBuilder(
                    future: applyAllAvailableMods(moddedItemsList),
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
                          appliedModsList = snapshot.data;
                          Navigator.pop(context, true);
                          return const SizedBox();
                          // return Column(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Text(curLangText!.uiSuccess, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 25)),
                          //     Expanded(
                          //       child: Padding(
                          //           padding: const EdgeInsets.symmetric(vertical: 15),
                          //           child: ScrollbarTheme(
                          //             data: ScrollbarThemeData(
                          //               thumbColor: MaterialStateProperty.resolveWith((states) {
                          //                 if (states.contains(MaterialState.hovered)) {
                          //                   return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                          //                 }
                          //                 return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                          //               }),
                          //             ),
                          //             child: SingleChildScrollView(
                          //                 child: ListView.builder(
                          //                     shrinkWrap: true,
                          //                     physics: const PageScrollPhysics(),
                          //                     itemCount: appliedModsList.length,
                          //                     itemBuilder: (context, index) {
                          //                       return Text(appliedModsList[index]);
                          //                     })),
                          //           )),
                          //     ),
                          //     Container(
                          //       constraints: const BoxConstraints(minWidth: 450),
                          //       child: ElevatedButton(
                          //           child: Text(curLangText!.uiReturn),
                          //           onPressed: () {
                          //             Navigator.pop(context, true);
                          //           }),
                          //     )
                          //   ],
                          // );
                        }
                      }
                    }));
          }));
}

Future<List<String>> applyAllAvailableMods(List<CategoryType> moddedList) async {
  List<String> appliedList = [];
  for (var cateType in moddedList) {
    for (var cate in cateType.categories) {
      String appliedPath = '${cate.categoryName} > ';
      for (var item in cate.items) {
        appliedPath += '${item.itemName} > ';
        for (var mod in item.mods) {
          appliedPath += '${mod.modName} > ';
          for (var submod in mod.submods) {
            appliedPath += submod.submodName;
            for (var modFile in submod.modFiles) {
              if (!modFile.applyStatus) {
                modFileApply(modFile).then((value) {
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
