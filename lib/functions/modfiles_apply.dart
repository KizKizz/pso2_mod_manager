import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/apply_mod_file.dart';
import 'package:pso2_mod_manager/functions/checksum_check.dart';
import 'package:pso2_mod_manager/functions/modfile_applied_dup.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<List<ModFile>> modFilesApply(context, List<ModFile> modFiles) async {
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
    }
  }

  if (alreadyAppliedModFiles.isNotEmpty) {
    List<ModFile> modFilesToReplace = await duplicateAppliedDialog(context, alreadyAppliedModFiles);
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
            appliedModFiles.add(modFiles[modFileToApplyIndex]);
          }
        }
      }
    }

    // String dupAppliedFiles = '';
    // for (var modFile in alreadyAppliedModFiles) {
    //   dupAppliedFiles += '${modFile.itemName} > ${modFile.modName} > ${modFile.submodName} > ${modFile.modFileName}\n';
    // }
    // applyMods = await duplicateAppliedDialog(context, dupAppliedFiles.trim());
    // if (applyMods) {
    //   for (var modFile in alreadyAppliedModFiles) {
    //     await modFileAppliedDupRestore(context, appliedItemList, modFile);
    //   }
    // }
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

  //apply mods

  // if (applyMods) {
  //   for (var modFile in modFiles) {
  //     bool replacedStatus = await modFileApply(context, modFile);
  //     if (replacedStatus) {
  //       // if (alreadyAppliedModFiles.where((element) => element.location == modFile.location).isNotEmpty) {
  //       //   await modFileAppliedDupRestore(moddedItemsList, modFile);
  //       // }
  //       modFile.applyStatus = true;
  //       modFile.applyDate = DateTime.now();
  //       if (modFile.isNew) {
  //         modFile.isNew = false;
  //       }
  //       appliedModFiles.add(modFile);
  //     }
  //   }
  // }

  return appliedModFiles;
}

Future<List<ModFile>> duplicateAppliedDialog(context, List<ModFile> dupModFiles) async {
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
                                  title: Text('${dupModFiles[i].itemName} > ${dupModFiles[i].modName} > ${dupModFiles[i].submodName} > ${dupModFiles[i].modFileName}'),
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

// Future<bool> duplicateAppliedDialog(context, String fileList) async {
//   return await showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => AlertDialog(
//               shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
//               backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
//               titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
//               title: Center(
//                 child: Text(curLangText!.uiDuplicatesInAppliedModsFound, style: const TextStyle(fontWeight: FontWeight.w700)),
//               ),
//               contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
//               content: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${curLangText!.uiApplyingWouldReplaceModFiles}:',
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: Text(fileList),
//                     ),
//                   ],
//                 ),
//               ),
//               actions: <Widget>[
//                 ElevatedButton(
//                     child: Text(curLangText!.uiReturn),
//                     onPressed: () async {
//                       Navigator.pop(context, false);
//                     }),
//                 ElevatedButton(
//                     onPressed: () async {
//                       Navigator.pop(context, true);
//                     },
//                     child: Text(curLangText!.uiSure))
//               ]));
// }
