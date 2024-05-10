import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/classes/mods_adder_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

//Auto Files adder
Future<bool> modsImportFilesAdder(context, List<ModsAdderItem> itemsToAddList, String importedSetName, bool applyImported) async {
  //List<List<String>> addedItems = [];
  ModSet newSet = ModSet(importedSetName, 0, true, false, DateTime.now(), []);
  for (var item in itemsToAddList) {
    if (item.toBeAdded) {
      String category = item.category;
      String itemName = item.itemName;
      List<String> mainNames = [];
      String rootPath = Directory(item.itemDirPath).parent.parent.path;

      //copy files to Mods
      String newItemPath = item.itemDirPath.replaceFirst(rootPath, modManModsDirPath);
      //copy files in item dir
      for (var file in Directory(item.itemDirPath).listSync().whereType<File>()) {
        String newFileDirPath = file.path.replaceFirst(rootPath, modManModsDirPath);
        Directory(p.dirname(newFileDirPath)).createSync(recursive: true);
        file.copySync(newFileDirPath);
      }
      for (var mod in item.modList) {
        if (mod.toBeAdded) {
          mainNames.add(mod.modName);
          String newmodDirPath = mod.modDirPath.replaceFirst(rootPath, modManModsDirPath);
          Directory(newmodDirPath).createSync(recursive: true);
          for (var file in mod.filesInMod) {
            String newFilePath = file.path.replaceFirst(rootPath, modManModsDirPath);
            file.copySync(newFilePath);
          }
          for (var submod in mod.submodList) {
            if (submod.toBeAdded) {
              String newSubmodDirPath = submod.submodDirPath.replaceFirst(rootPath, modManModsDirPath);
              Directory(newSubmodDirPath).createSync(recursive: true);
              for (var file in submod.files) {
                String newFilePath = file.path.replaceFirst(rootPath, modManModsDirPath);
                Directory(p.dirname(newFilePath)).createSync(recursive: true);
                file.copySync(newFilePath);
              }
            }
          }
        }
      }

      if (mainNames.isNotEmpty) {
        List<Directory> foldersInNewItemPath = [];
        for (var mod in item.modList) {
          if (mod.toBeAdded) {
            String newmodDirPath = mod.modDirPath.replaceFirst(rootPath, modManModsDirPath);
            if (foldersInNewItemPath.indexWhere((element) => element.path == newmodDirPath) == -1) {
              foldersInNewItemPath.add(Directory(newmodDirPath));
            }
          }
        }

        //Add to current moddedItemList
        for (var cateType in moddedItemsList) {
          int cateIndex = cateType.categories.indexWhere((element) => element.categoryName == category);
          if (cateIndex != -1) {
            Category cateInList = cateType.categories[cateIndex];
            int itemInListIndex = cateInList.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              Item newItem = await newItemsFetcher(Uri.file('$modManModsDirPath/$category').toFilePath(), newItemPath, importedSetName);
              cateInList.items.add(newItem);
              newSet.setItems.add(newItem);
            } else {
              Item itemInList = cateInList.items[itemInListIndex];
              itemInList.isSet = true;
              if (!itemInList.setNames.contains(importedSetName)) {
                itemInList.setNames.add(importedSetName);
              }
              int modInListIndex = itemInList.mods.indexWhere((element) => mainNames.where((name) => name.toLowerCase() == element.modName.toLowerCase()).isNotEmpty);
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                modInList.isSet = true;
                if (!modInList.setNames.contains(importedSetName)) {
                  modInList.setNames.add(importedSetName);
                }
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, cateInList.categoryName, itemInList.itemName, importedSetName);
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, cateInList.categoryName, foldersInNewItemPath, importedSetName));
              }
              itemInList.isNew = true;
              //Sort alpha
              itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
              newSet.setItems.add(itemInList);
            }
            //Sort alpha
            cateInList.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            cateInList.visible = cateInList.items.isNotEmpty ? true : false;
            cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          } else if (cateType.groupName == defaultCategoryTypeNames[2]) {
            Category newCate = Category(category, cateType.groupName, Uri.file('$modManModsDirPath/$category').toFilePath(), cateType.categories.length, true, []);
            int itemInListIndex = newCate.items.indexWhere((element) => element.itemName.toLowerCase() == itemName.toLowerCase());
            if (itemInListIndex == -1) {
              Item newItem = await newItemsFetcher(Uri.file('$modManModsDirPath/$category').toFilePath(), newItemPath, importedSetName);
              newCate.items.add(newItem);
              newSet.setItems.add(newItem);
            } else {
              Item itemInList = newCate.items[itemInListIndex];
              itemInList.isSet = true;
              if (!itemInList.setNames.contains(importedSetName)) {
                itemInList.setNames.add(importedSetName);
              }
              int modInListIndex = itemInList.mods.indexWhere((element) => mainNames.where((name) => name.toLowerCase() == element.modName.toLowerCase()).isNotEmpty);
              if (modInListIndex != -1) {
                Mod modInList = itemInList.mods[modInListIndex];
                modInList.isSet = true;
                if (!modInList.setNames.contains(importedSetName)) {
                  modInList.setNames.add(importedSetName);
                }
                List<SubMod> extraSubmods = newSubModFetcher(modInList.location, newCate.categoryName, itemInList.itemName, importedSetName);
                for (var subModInCurMod in modInList.submods) {
                  extraSubmods.removeWhere((element) => element.submodName.toLowerCase() == subModInCurMod.submodName.toLowerCase());
                }
                modInList.submods.addAll(extraSubmods);
                modInList.isNew = true;
              } else {
                itemInList.mods.addAll(newModsFetcher(itemInList.location, newCate.categoryName, foldersInNewItemPath, importedSetName));
              }
              itemInList.isNew = true;
              //Sort alpha
              itemInList.mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
              newSet.setItems.add(itemInList);
            }
            //Sort alpha
            newCate.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
            newCate.visible = newCate.items.isNotEmpty ? true : false;
            cateType.categories.add(newCate);
            cateType.visible = cateType.categories.where((element) => element.items.isNotEmpty).isNotEmpty ? true : false;

            break;
          }
        }

        Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
      }
    }
  }

  //save to set
  modSetList.insert(0, newSet);
  for (var set in modSetList) {
    set.position = modSetList.indexOf(set);
  }
  saveSetListToJson();

  //apply
  if (applyImported) {
    await applyingImportedModLoader(context, newSet);
  }

  //Save to json
  saveModdedItemListToJson();

  //clear sheets
  if (csvInfosFromSheets.isNotEmpty) {
    csvInfosFromSheets.clear();
  }

  return true;
}

//Helpers
Future<Item> newItemsFetcher(String catePath, String itemPath, String importedSetName) async {
  //Get icons from dir
  List<String> itemIcons = [];
  final imagesFoundInItemDir = Directory(itemPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png').toList();
  if (imagesFoundInItemDir.isNotEmpty) {
    itemIcons = imagesFoundInItemDir.map((e) => e.path).toList();
  } else {
    itemIcons = ['assets/img/placeholdersquare.png'];
  }

  return Item(p.basename(itemPath), [], itemIcons, p.basename(catePath), Uri.file(itemPath).toFilePath(), false, DateTime(0), 0, false, true, true, [importedSetName],
      newModsFetcher(itemPath, p.basename(catePath), [], importedSetName));
}

List<Mod> newModsFetcher(String itemPath, String cateName, List<Directory> newModFolders, String importedSetName) {
  List<Directory> foldersInItemPath = [];
  if (newModFolders.isEmpty) {
    foldersInItemPath = Directory(itemPath).listSync(recursive: false).whereType<Directory>().toList();
  } else {
    foldersInItemPath = newModFolders;
  }
  List<Mod> mods = [];

  //Get modfiles in item folder
  List<ModFile> modFilesInItemDir = [];
  List<File> iceFilesInItemDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
  if (iceFilesInItemDir.isNotEmpty) {
    for (var iceFile in iceFilesInItemDir) {
      modFilesInItemDir.add(ModFile(p.basename(iceFile.path), p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, '', [], iceFile.path, false, DateTime(0), 0, false, true,
          true, [importedSetName], [], [], []));
    }
    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where(((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png'));
    for (var element in imagesInModDir) {
      bool isIconImage = false;
      for (var part in p.basenameWithoutExtension(itemPath).split(' ')) {
        if (p.basenameWithoutExtension(element.path).contains(part)) {
          isIconImage = true;
          break;
        }
      }
      if (!isIconImage) {
        modPreviewImages.add(Uri.file(element.path).toFilePath());
      }
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(itemPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    //add to submod
    SubMod subModInItemDir = SubMod(p.basename(itemPath), p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, true, false, false, -1, -1, '',
        [importedSetName], [], modPreviewImages, modPreviewVideos, [], modFilesInItemDir);

    //add to mod
    mods.add(
        Mod(p.basename(itemPath), p.basename(itemPath), cateName, itemPath, false, DateTime(0), 0, false, false, true, [importedSetName], modPreviewImages, modPreviewVideos, [], [subModInItemDir]));
  }

  // get submods in mod folders
  for (var dir in foldersInItemPath) {
    //Get preview images;
    List<String> modPreviewImages = [];
    List<String> modPreviewVideos = [];

    if (dir.existsSync()) {
      final imagesInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
      for (var element in imagesInModDir) {
        modPreviewImages.add(Uri.file(element.path).toFilePath());
      }
      //Get preview videos;

      final videosInModDir = Directory(dir.path).listSync(recursive: true).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
      for (var element in videosInModDir) {
        modPreviewVideos.add(Uri.file(element.path).toFilePath());
      }
    }

    mods.add(Mod(p.basename(dir.path), p.basename(itemPath), cateName, dir.path, false, DateTime(0), 0, true, false, true, [importedSetName], modPreviewImages, modPreviewVideos, [],
        newSubModFetcher(dir.path, cateName, p.basename(itemPath), importedSetName)));
  }

  //Sort alpha
  mods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));

  return mods;
}

List<SubMod> newSubModFetcher(String modPath, String cateName, String itemName, String importedSetName) {
  List<SubMod> submods = [];
  //ices in main mod dir
  final filesInMainModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
  if (filesInMainModDir.isNotEmpty) {
    List<ModFile> modFiles = [];
    for (var file in filesInMainModDir) {
      //final ogFiles = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }
      modFiles
          .add(ModFile(p.basename(file.path), p.basename(modPath), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, true, true, [importedSetName], [], [], []));
      //Sort alpha
      modFiles.sort((a, b) => a.modFileName.toLowerCase().compareTo(b.modFileName.toLowerCase()));
    }

    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
    for (var element in imagesInModDir) {
      modPreviewImages.add(Uri.file(element.path).toFilePath());
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(modPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    //get cmx file
    bool hasCmx = false;
    final cmxFile = Directory(modPath)
        .listSync(recursive: false)
        .whereType<File>()
        .firstWhere((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig'), orElse: () => File(''))
        .path;
    if (cmxFile.isNotEmpty) {
      hasCmx = true;
    }

    submods.add(SubMod(p.basename(modPath), p.basename(modPath), itemName, cateName, modPath, false, DateTime(0), 0, true, false, true, hasCmx, false, -1, -1, cmxFile, [importedSetName], [],
        modPreviewImages, modPreviewVideos, [], modFiles));
  }

  //ices in sub dirs
  final foldersInModDir = Directory(modPath).listSync(recursive: true).whereType<Directory>().toList();
  for (var dir in foldersInModDir) {
    //Get preview images;
    List<String> modPreviewImages = [];
    final imagesInModDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png');
    for (var element in imagesInModDir) {
      modPreviewImages.add(Uri.file(element.path).toFilePath());
    }
    //Get preview videos;
    List<String> modPreviewVideos = [];
    final videosInModDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      modPreviewVideos.add(Uri.file(element.path).toFilePath());
    }

    //get cmx file
    bool hasCmx = false;
    final cmxFile = Directory(modPath)
        .listSync(recursive: false)
        .whereType<File>()
        .firstWhere((element) => p.extension(element.path) == '.txt' && p.basename(element.path).contains('cmxConfig'), orElse: () => File(''))
        .path;
    if (cmxFile.isNotEmpty) {
      hasCmx = true;
    }

    final filesInDir = Directory(dir.path).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '').toList();
    List<ModFile> modFiles = [];
    for (var file in filesInDir) {
      //final ogFiles = ogDataFiles.where((element) => p.basename(element) == p.basename(file.path)).toList();
      //List<String> ogFilePaths = [];
      // for (var element in ogFiles) {
      //   ogFilePaths.add(element.path);
      // }

      List<String> parentPaths = file.parent.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
      parentPaths.removeWhere((element) => element.isEmpty);

      modFiles.add(
          ModFile(p.basename(file.path), parentPaths.join(' > '), p.basename(modPath), itemName, cateName, '', [], file.path, false, DateTime(0), 0, false, true, true, [importedSetName], [], [], []));
      //Sort alpha
      modFiles.sort((a, b) => a.modFileName.toLowerCase().compareTo(b.modFileName.toLowerCase()));
    }

    //Get submod name
    List<String> parentPaths = dir.path.split(modPath).last.trim().split(Uri.file('/').toFilePath());
    parentPaths.removeWhere((element) => element.isEmpty);
    submods.add(SubMod(parentPaths.join(' > '), p.basename(modPath), itemName, cateName, dir.path, false, DateTime(0), 0, true, false, true, hasCmx, false, -1, -1, cmxFile, [importedSetName], [],
        modPreviewImages, modPreviewVideos, [], modFiles));
  }

  //remove empty submods
  submods.removeWhere((element) => element.modFiles.isEmpty);

  //Sort alpha
  submods.sort((a, b) => a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase()));

  return submods;
}

Future<(String, bool)> newImportModSetDialog(context) async {
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
                title: Text(curLangText!.uiCreateASetForImportedMods, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                actionsPadding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
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
                        labelText: curLangText!.uiEnterImportedSetName,
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
                                Navigator.pop(context, (newModSetName.text, false));
                              }
                            },
                      child: Text(curLangText!.uiImport)),
                  ElevatedButton(
                      onPressed: newModSetName.value.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, (newModSetName.text, true));
                              }
                            },
                      child: Text(curLangText!.uiImportAndApply))
                ]);
          }));
}

Future<void> applyImportedMods(context, ModSet curSet) async {
  isModViewModsApplying = true;
  Future.delayed(const Duration(milliseconds: 200), () async {
    List<ModFile> allAppliedModFiles = [];
    for (var item in curSet.setItems.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
      for (var mod in item.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
        for (var submod in mod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
          allAppliedModFiles.addAll(submod.modFiles.where((element) => !element.applyStatus));
        }
      }
    }

    //apply mod files
    if (await originalFilesCheck(context, allAppliedModFiles)) {
      modFilesApply(context, allAppliedModFiles).then((value) async {
        if (value.indexWhere((element) => element.applyStatus) != -1) {
          for (var curItem in curSet.setItems) {
            for (var curMod in curItem.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
              for (var curSubmod in curMod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                curSubmod.applyStatus = true;
                curSubmod.isNew = false;
                curSubmod.applyDate = DateTime.now();
              }
              curMod.applyStatus = true;
              curMod.isNew = false;
              curMod.applyDate = DateTime.now();
            }
            curItem.applyDate = DateTime.now();
            curItem.applyStatus = true;
            if (curItem.mods.where((element) => element.isNew).isEmpty) {
              curItem.isNew = false;
            }
          }
          appliedItemList = await appliedListBuilder(moddedItemsList);
          List<ModFile> appliedModFiles = value;
          String fileAppliedText = '';

          for (var element in appliedModFiles.where((e) => e.applyStatus)) {
            if (fileAppliedText.isEmpty) {
              fileAppliedText = uiInTextArg(curLangText!.uiSuccessfullyAppliedX, curSet.setName);
            }
            if (!fileAppliedText.contains('${element.itemName} > ${element.modName} > ${element.submodName}\n')) {
              fileAppliedText += '${element.itemName} > ${element.modName} > ${element.submodName}\n';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
        }
        isModViewModsApplying = false;
        saveModdedItemListToJson();
        Navigator.pop(context);
      });
    }
  });
}

Future<void> applyingImportedModLoader(context, ModSet curSet) async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await applyImportedMods(context, curSet);
    // ignore: use_build_context_synchronously
  });
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              content: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 200, minWidth: 200, maxHeight: double.infinity, maxWidth: double.infinity),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 5),
                            Text(
                              curLangText!.uiApplyingImportedMods,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        )),
                  ],
                ),
              ));
        });
      });
}
