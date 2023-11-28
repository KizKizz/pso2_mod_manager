import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
void setModSetNameToSingleItem(String modSetName, Item item, Mod mod, SubMod submod, List<ModFile> modFiles) {
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
    if (modFiles.where((element) => element.location == modFile.location).isNotEmpty && !modFile.setNames.contains(modSetName)) {
      modFile.isSet = true;
      modFile.setNames.add(modSetName);
    }
  }
}

void setModSetNameToSingleMod(String modSetName, Mod mod, SubMod submod, List<ModFile> modFiles) {
  if (!mod.setNames.contains(modSetName)) {
    mod.setNames.add(modSetName);
  }
  mod.isSet = true;

  if (!submod.setNames.contains(modSetName)) {
    submod.setNames.add(modSetName);
  }
  submod.isSet = true;
  for (var modFile in submod.modFiles) {
    if (modFiles.where((element) => element.location == modFile.location).isNotEmpty && !modFile.setNames.contains(modSetName)) {
      modFile.isSet = true;
      modFile.setNames.add(modSetName);
    }
  }
}

List<Widget> modSetsMenuButtons(context, Item item, Mod mod, SubMod submod) {
  List<Widget> menuButtonList = [];
  //create new set
  menuButtonList.add(
    MenuItemButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
        return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
      })),
      child: Text(curLangText!.uiAddNewSet),
      onPressed: () async {
        //create new set
        String newSetName = await newModSetDialog(context);
        if (newSetName.isNotEmpty) {
          ModSet newSet = ModSet(newSetName, 0, true, false, DateTime.now(), []);

          newSet.setItems.add(item);
          setModSetNameToSingleItem(newSet.setName, item, mod, submod, submod.modFiles);
          modSetList.add(newSet);
          modSetList.sort(
            (a, b) => b.addedDate.compareTo(a.addedDate),
          );
          saveSetListToJson();
          saveModdedItemListToJson();
        }
      },
    ),
  );

  //modSets
  for (var set in modSetList) {
    menuButtonList.add(
      MenuItemButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
          return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
        })),
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
              setModSetNameToSingleMod(set.setName, mod, submod, submod.modFiles);
              saveSetListToJson();
              saveModdedItemListToJson();
            }
          } else {
            readyToAdd = true;
          }

          //add to set
          if (readyToAdd) {
            set.setItems.add(item);
            setModSetNameToSingleItem(set.setName, item, mod, submod, submod.modFiles);
            saveSetListToJson();
            saveModdedItemListToJson();
          }
        },
      ),
    );
  }
  return menuButtonList;
}

List<Widget> modSetsMenuItemButtons(context, List<ModFile> selectedModFiles) {
  List<Widget> menuItemButtonList = [];

  //create new set
  menuItemButtonList.add(
    MenuItemButton(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
        return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
      })),
      child: Text(curLangText!.uiAddNewSet),
      onPressed: () async {
        //create new set
        String newSetName = await newModSetDialog(context);
        if (newSetName.isNotEmpty) {
          ModSet newSet = ModSet(newSetName, 0, true, false, DateTime.now(), []);

          List<Item> matchedItems = [];
          List<Mod> matchedMods = [];
          List<SubMod> matchedSubmods = [];
          for (var modFile in selectedModFiles) {
            var matchingTypes = appliedItemList.where((element) => element.categories.where((cate) => cate.categoryName == modFile.category).isNotEmpty);
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
                setModSetNameToSingleItem(newSet.setName, item, mod, submod, selectedModFiles);
                if (newSet.setItems.where((element) => element.location == item.location).isEmpty) {
                  newSet.setItems.add(item);
                }
              }
            }
          }

          modSetList.add(newSet);
          modSetList.sort(
            (a, b) => b.addedDate.compareTo(a.addedDate),
          );
          saveSetListToJson();
          saveModdedItemListToJson();
          isModViewListHidden = true;
          Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
        }
      },
    ),
  );

  //modSets
  for (var set in modSetList) {
    menuItemButtonList.add(
      MenuItemButton(
        style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
          return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
        })),
        child: Text(set.setName),
        onPressed: () async {
          List<Item> matchedItems = [];
          List<Mod> matchedMods = [];
          List<SubMod> matchedSubmods = [];
          for (var modFile in selectedModFiles) {
            var matchingTypes = appliedItemList.where((element) => element.categories.where((cate) => cate.categoryName == modFile.category).isNotEmpty);
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

                  if (duplicatedModInfos.isNotEmpty) {
                    int userInput = await duplicateItemInModSetDialog(context, duplicatedModInfos);
                    if (userInput == 1) {
                      removeModSetNameFromItems(set.setName, duplicateSetItems);
                      set.setItems.removeWhere((element) => duplicateSetItems.contains(element));
                      readyToAdd = true;
                    } else if (userInput == 2) {
                      removeModSetNameFromFiles(set.setName, duplicateSetItems, mod, submod);
                      setModSetNameToSingleMod(set.setName, mod, submod, selectedModFiles);
                      saveSetListToJson();
                      saveModdedItemListToJson();
                      isModViewListHidden = true;
                      Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
                    }
                  }
                } else {
                  readyToAdd = true;
                }

                //add to set
                if (readyToAdd) {
                  set.setItems.add(item);
                  setModSetNameToSingleItem(set.setName, item, mod, submod, selectedModFiles);
                  saveSetListToJson();
                  saveModdedItemListToJson();
                  isModViewListHidden = true;
                  Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
                }
              }
            }
          }
        },
      ),
    );
  }
  return menuItemButtonList;
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
                child: Text(curLangText!.uiDuplicatesFoundInTheCurrentSet, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                    child: Text(curLangText!.uiReplaceAll)),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, 2);
                    },
                    child: Text(curLangText!.uiReplaceDuplicateFilesOnly))
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

Future<String> newModSetDialog(context) async {
  TextEditingController newModSetName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiNewModSet, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newModSetName,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (modSetList.where((element) => element.setName == newModSetName.text).isNotEmpty) {
                        return curLangText!.uiNameAlreadyExisted;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: curLangText!.uiEnterNewModSetName,
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        //isCollapsed: true,
                        //isDense: true,
                        contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                        constraints: const BoxConstraints.tightForFinite(),
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(2),
                        )),
                    onChanged: (value) async {
                      setState(() {});
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: newModSetName.value.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newModSetName.text);
                              }
                            },
                      child: Text(curLangText!.uiCreateAndAddModsToThisSet))
                ]);
          }));
}
