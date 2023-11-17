import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<List<ModSet>> modSetLoader() async {
  List<ModSet> newModSets = [];
  //Load list from json
  if (modManCurActiveProfile == 1) {
    if (File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).readAsStringSync().toString().isNotEmpty) {
      var jsonData = jsonDecode(File(Uri.file('$modManDirPath/PSO2ModManSetsList.json').toFilePath()).readAsStringSync());
      for (var set in jsonData) {
        newModSets.add(ModSet.fromJson(set));
      }
    }
  } else if (modManCurActiveProfile == 2) {
    if (File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).readAsStringSync().toString().isNotEmpty) {
      var jsonData = jsonDecode(File(Uri.file('$modManDirPath/PSO2ModManSetsList_profile2.json').toFilePath()).readAsStringSync());
      for (var set in jsonData) {
        newModSets.add(ModSet.fromJson(set));
      }
    }
  }

  //remove nonexistence set name
  List<String> setNames = newModSets.map((e) => e.setName).toList();
  for (var item in allSetItems) {
    item.setNames.removeWhere((element) => !setNames.contains(element));
  }

  for (var set in newModSets) {
    set.setItems = allSetItems.where((element) => element.setNames.contains(set.setName)).toList();
  }

  newModSets.sort(
    (a, b) => b.addedDate.compareTo(a.addedDate),
  );

  //saveSetListToJson();

  return newModSets;
}

List<Item> itemsFromAppliedListFetch(List<CategoryType> appliedList) {
  List<Item> newItemList = [];
  for (var type in appliedList) {
    for (var cate in type.categories) {
      for (var item in cate.items) {
        if (item.applyStatus == true) {
          item.isSet = true;
          newItemList.add(item);
        }
      }
    }
  }

  return newItemList;
}

void setModSetNameToItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.applyStatus) {
      item.isSet = true;
      if (!item.setNames.contains(modSetName)) {
        item.setNames.add(modSetName);
      }
      for (var mod in item.mods) {
        if (mod.applyStatus) {
          mod.isSet = true;
          if (!mod.setNames.contains(modSetName)) {
            mod.setNames.add(modSetName);
          }
          for (var submod in mod.submods) {
            if (submod.applyStatus) {
              submod.isSet = true;
              if (!submod.setNames.contains(modSetName)) {
                submod.setNames.add(modSetName);
              }
              for (var modFile in submod.modFiles) {
                if (modFile.applyStatus) {
                  modFile.isSet = true;
                  if (!modFile.setNames.contains(modSetName)) {
                    modFile.setNames.add(modSetName);
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

void removeModSetNameFromItems(String modSetName, List<Item> items) {
  for (var item in items) {
    if (item.isSet) {
      item.setNames.removeWhere(
        (element) => element == modSetName,
      );
      if (item.setNames.isEmpty) {
        item.isSet = false;
      }
      for (var mod in item.mods) {
        if (mod.isSet) {
          mod.setNames.removeWhere(
            (element) => element == modSetName,
          );
          if (mod.setNames.isEmpty) {
            mod.isSet = false;
          }
          for (var submod in mod.submods) {
            if (submod.isSet) {
              submod.setNames.removeWhere(
                (element) => element == modSetName,
              );
              if (submod.setNames.isEmpty) {
                submod.isSet = false;
              }
              for (var modFile in submod.modFiles) {
                if (modFile.isSet) {
                  modFile.setNames.removeWhere(
                    (element) => element == modSetName,
                  );
                  if (modFile.setNames.isEmpty) {
                    modFile.isSet = false;
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

void removeModSetNameFromFiles(String modSetName, List<Item> duplicateItems, Mod addingMod, SubMod addingSubmod) {
  for (var dupItem in duplicateItems) {
    if (dupItem.isSet && dupItem.setNames.contains(modSetName)) {
      for (var dupMod in dupItem.mods) {
        if (dupMod.isSet && dupMod.setNames.contains(modSetName)) {
          for (var dupSubmod in dupMod.submods) {
            if (dupSubmod.isSet && dupSubmod.setNames.contains(modSetName)) {
              for (var dupModFile in dupSubmod.modFiles) {
                if (dupModFile.isSet && dupModFile.setNames.contains(modSetName) && addingSubmod.modFiles.where((element) => element.modFileName == dupModFile.modFileName).isNotEmpty) {
                  dupModFile.setNames.remove(modSetName);
                  dupModFile.isSet = false;
                }
              }
              if (dupSubmod.modFiles.where((element) => element.isSet).isEmpty) {
                dupSubmod.setNames.remove(modSetName);
                dupSubmod.isSet = false;
              }
            }
          }
          if (dupMod.submods.where((element) => element.isSet).isEmpty) {
            dupMod.setNames.remove(modSetName);
            dupMod.isSet = false;
          }
        }
      }
    }
  }
}

// add to set menu
void setModSetNameToSingleItem(String modSetName, Item item, Mod mod, SubMod submod) {
  if (!item.setNames.contains(modSetName)) {
    item.setNames.add(modSetName);
  }
  item.isSet = true;

  if (!mod.setNames.contains(modSetName)) {
    mod.setNames.add(modSetName);
  }
  mod.isSet = true;

  if (!submod.setNames.contains(modSetName)) {
    submod.setNames.add(modSetName);
  }
  submod.isSet = true;
  for (var modFile in submod.modFiles) {
    if (!modFile.setNames.contains(modSetName)) {
      modFile.isSet = true;
      modFile.setNames.add(modSetName);
    }
  }
}

void setModSetNameToSingleMod(String modSetName, Mod mod, SubMod submod) {
  if (!mod.setNames.contains(modSetName)) {
    mod.setNames.add(modSetName);
  }
  mod.isSet = true;

  if (!submod.setNames.contains(modSetName)) {
    submod.setNames.add(modSetName);
  }
  submod.isSet = true;
  for (var modFile in submod.modFiles) {
    if (!modFile.setNames.contains(modSetName)) {
      modFile.isSet = true;
      modFile.setNames.add(modSetName);
    }
  }
}

List<Widget> modSetsMenuButtons(context, Item item, Mod mod, SubMod submod) {
  List<Widget> menuButtonList = [];
  for (var set in modSetList) {
    menuButtonList.add(
      MenuItemButton(
        child: Text(set.setName),
        onPressed: () async {
          bool readyToAdd = false;
          //check if existed in set
          if (set.setItems.where((element) => element.itemName == item.itemName).isNotEmpty) {
            final duplicateSetItems = set.setItems.where((element) => element.itemName == item.itemName).toList();
            List<String> duplicatedModInfos = [];

            for (var dupItem in duplicateSetItems) {
              final duplicateSetMods = dupItem.mods.where((element) => element.isSet);
              for (var dupMod in duplicateSetMods) {
                final duplicateSetSubmods = dupMod.submods.where((element) => element.isSet);
                for (var dupSubmod in duplicateSetSubmods) {
                  final duplicateSetModFiles = dupSubmod.modFiles.where((element) => element.isSet);
                  for (var dupModFile in duplicateSetModFiles) {
                    duplicatedModInfos.add('${dupItem.itemName} > ${dupMod.modName} > ${dupSubmod.submodName} > ${dupModFile.modFileName}');
                  }
                }
              }
            }

            int userInput = await duplicateItemInModSetDialog(context, duplicatedModInfos);
            if (userInput == 1) {
              removeModSetNameFromItems(set.setName, duplicateSetItems);
              set.setItems.removeWhere((element) => duplicateSetItems.contains(element));

              readyToAdd = true;
            } else if (userInput == 2) {
              removeModSetNameFromFiles(set.setName, duplicateSetItems, mod, submod);
              setModSetNameToSingleMod(set.setName, mod, submod);
              saveSetListToJson();
              saveModdedItemListToJson();
            }
          } else {
            readyToAdd = true;
          }

          //add to set
          if (readyToAdd) {
            set.setItems.add(item);
            setModSetNameToSingleItem(set.setName, item, mod, submod);
            saveSetListToJson();
            saveModdedItemListToJson();
          }
        },
      ),
    );
  }
  return menuButtonList;
}

Future<int> duplicateItemInModSetDialog(context, List<String> duplicatedModInfos) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text('Duplicates found in the current Mod Set', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(duplicatedModInfos.join('\n')),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiReturn),
                    onPressed: () async {
                      Navigator.pop(context, 0);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, 1);
                    },
                    child: Text('Replace the entire mod')),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, 2);
                    },
                    child: Text('Replace duplicate files only'))
              ]));
}

//remove modFile from set
void removeModFileFromThisSet(String selectedSetName, Item item, Mod mod, SubMod submod, ModFile modFile) {
  if (modFile.isSet && modFile.setNames.contains(selectedSetName)) {
    modFile.setNames.remove(selectedSetName);
    if (modFile.setNames.isEmpty) {
      modFile.isSet = false;
    }
    if (submod.modFiles.where((element) => element.setNames.contains(selectedSetName)).isEmpty) {
      removeSubmodFromThisSet(selectedSetName, item, mod, submod);
    }
  }
}

//remove modFile from set
void removeSubmodFromThisSet(String selectedSetName, Item item, Mod mod, SubMod submod) {
  if (submod.isSet && submod.setNames.contains(selectedSetName)) {
    submod.setNames.remove(selectedSetName);
    if (submod.setNames.isEmpty) {
      submod.isSet = false;
    }
    if (mod.submods.where((element) => element.setNames.contains(selectedSetName)).isEmpty) {
      removeModFromThisSet(selectedSetName, item, mod);
    }
  }
}

//remove modFile from set
void removeModFromThisSet(String selectedSetName, Item item, Mod mod) {
  if (mod.isSet && mod.setNames.contains(selectedSetName)) {
    mod.setNames.remove(selectedSetName);
    if (mod.setNames.isEmpty) {
      mod.isSet = false;
    }
    if (item.mods.where((element) => element.setNames.contains(selectedSetName)).isEmpty) {
      item.setNames.remove(selectedSetName);
      for (var set in modSetList) {
        if (set.setName == selectedSetName && set.setItems.contains(item)) {
          set.setItems.remove(item);
          break;
        }
      }
      if (item.setNames.isEmpty) {
        item.isSet = false;
      }
    }
  }
}
