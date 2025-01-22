import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_popup.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bounding_radius_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/mod_to_set_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Future<void> submodRename(context, Mod mod, SubMod submod) async {
  modPopupStatus.value = submod.submodName;
  String? newName = await renamePopup(context, p.dirname(submod.location), submod.submodName);
  if (newName != null) {
    if (p.isWithin(mod.location, submod.location)) {
      String newPath = p.dirname(submod.location) + p.separator + newName;
      await io.copyPath(submod.location, newPath);
      await Directory(submod.location).delete(recursive: true);
      submod.submodName = newName;
      submod.cmxFile = submod.cmxFile!.replaceFirst(submod.location, newPath);
      for (var modFile in submod.modFiles) {
        modFile.submodName = newName;
        modFile.location = modFile.location.replaceFirst(submod.location, newPath);
        for (int i = 0; i < modFile.previewImages!.length; i++) {
          modFile.previewImages![i] = modFile.previewImages![i].replaceFirst(submod.location, newPath);
        }
        for (int i = 0; i < modFile.previewVideos!.length; i++) {
          modFile.previewVideos![i] = modFile.previewVideos![i].replaceFirst(submod.location, newPath);
        }
      }
      for (var path in submod.previewImages) {
        path = path.replaceFirst(submod.location, newPath);
      }
      for (var path in submod.previewVideos) {
        path = path.replaceFirst(submod.location, newPath);
      }
      for (var path in mod.previewImages) {
        path = path.replaceFirst(submod.location, newPath);
      }
      for (var path in mod.previewVideos) {
        path = path.replaceFirst(submod.location, newPath);
      }
      submod.location = newPath;
    } else {
      String newPath = p.dirname(mod.location) + p.separator + newName;
      await io.copyPath(mod.location, newPath);
      await Directory(mod.location).delete(recursive: true);
      mod.modName = newName;
      submod.submodName = newName;
      submod.cmxFile = submod.cmxFile!.replaceFirst(submod.location, newPath);
      for (var modFile in submod.modFiles) {
        modFile.submodName = newName;
        modFile.location = modFile.location.replaceFirst(submod.location, newPath);
        for (int i = 0; i < modFile.previewImages!.length; i++) {
          modFile.previewImages![i] = modFile.previewImages![i].replaceFirst(submod.location, newPath);
        }
        for (int i = 0; i < modFile.previewVideos!.length; i++) {
          modFile.previewVideos![i] = modFile.previewVideos![i].replaceFirst(submod.location, newPath);
        }
      }
      for (int i = 0; i < submod.previewImages.length; i++) {
        submod.previewImages[i] = submod.previewImages[i].replaceFirst(submod.location, newPath);
      }
      for (int i = 0; i < submod.previewVideos.length; i++) {
        submod.previewVideos[i] = submod.previewVideos[i].replaceFirst(submod.location, newPath);
      }
      for (int i = 0; i < mod.previewImages.length; i++) {
        mod.previewImages[i] = mod.previewImages[i].replaceFirst(submod.location, newPath);
      }
      for (int i = 0; i < mod.previewVideos.length; i++) {
        mod.previewVideos[i] = mod.previewVideos[i].replaceFirst(submod.location, newPath);
      }

      // submods inside mod folder
      for (var smod in mod.submods.where((e) => p.isWithin(mod.location, e.location))) {
        for (var modFile in smod.modFiles) {
          modFile.location = modFile.location.replaceFirst(mod.location, newPath);
          for (int i = 0; i < modFile.previewImages!.length; i++) {
            modFile.previewImages![i] = modFile.previewImages![i].replaceFirst(mod.location, newPath);
          }
          for (int i = 0; i < modFile.previewVideos!.length; i++) {
            modFile.previewVideos![i] = modFile.previewVideos![i].replaceFirst(mod.location, newPath);
          }
        }
        smod.location = smod.location.replaceFirst(mod.location, newPath);
        smod.cmxFile = smod.cmxFile!.replaceFirst(mod.location, newPath);
        for (int i = 0; i < smod.previewImages.length; i++) {
          smod.previewImages[i] = smod.previewImages[i].replaceFirst(mod.location, newPath);
        }
        for (int i = 0; i < smod.previewVideos.length; i++) {
          smod.previewVideos[i] = smod.previewVideos[i].replaceFirst(mod.location, newPath);
        }
        for (int i = 0; i < mod.previewImages.length; i++) {
          mod.previewImages[i] = mod.previewImages[i].replaceFirst(mod.location, newPath);
        }
        for (int i = 0; i < mod.previewVideos.length; i++) {
          mod.previewVideos[i] = mod.previewVideos[i].replaceFirst(mod.location, newPath);
        }
      }

      mod.location = newPath;
      submod.location = newPath;
    }
    saveMasterModListToJson();
    modPopupStatus.value = newName;
  }
}

Future<void> addPreviews(Mod mod, SubMod submod) async {
  const XTypeGroup imageTypeGroup = XTypeGroup(
    label: 'Images',
    extensions: <String>['jpg', 'png'],
  );
  const XTypeGroup videoTypeGroup = XTypeGroup(
    label: 'Videos',
    extensions: <String>['webm', 'mp4'],
  );
  final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
    imageTypeGroup,
    videoTypeGroup,
  ]);
  for (var file in files) {
    if (p.extension(file.path) == '.jpg' || p.extension(file.path) == '.png') {
      final copiedFile = await File(file.path).copy(submod.location + p.separator + p.basename(file.path));
      submod.previewImages.add(copiedFile.path);
      mod.previewImages.add(copiedFile.path);
    }
    if (p.extension(file.path) == '.webm' || p.extension(file.path) == '.mp4') {
      final copiedFile = await File(file.path).copy(submod.location + p.separator + p.basename(file.path));
      submod.previewVideos.add(copiedFile.path);
      mod.previewVideos.add(copiedFile.path);
    }
  }

  saveMasterModListToJson();
}

Future<bool> submodAqmInject(context, SubMod submod) async {
  String hqIcePath = '';
  String lqIcePath = '';
  for (var modFile in submod.modFiles) {
    if (hqIcePath.isEmpty) {
      int hqIndex = pItemData.indexWhere((e) => e.category == submod.category && e.getHQIceName().contains(modFile.modFileName));
      if (hqIndex != -1) {
        hqIcePath = modFile.location;
        if (lqIcePath.isNotEmpty) break;
      }
    }
    if (lqIcePath.isEmpty) {
      int lqIndex = pItemData.indexWhere((e) => e.category == submod.category && e.getLQIceName().contains(modFile.modFileName));
      if (lqIndex != -1) {
        lqIcePath = modFile.location;
        if (hqIcePath.isNotEmpty) break;
      }
    }
  }

  bool result = await aqmInjectPopup(context, hqIcePath, lqIcePath, submod.itemName, false, false, false, false, true);

  if (result) {
    submod.customAQMInjected = true;
    submod.customAQMFileName = p.basename(selectedCustomAQMFilePath.value);
    submod.hqIcePath = hqIcePath;
    submod.lqIcePath = lqIcePath;
    saveMasterModListToJson();
    return true;
  } else {
    return false;
  }
}

Future<bool> submodCustomAqmRemove(context, SubMod submod) async {
  String hqIcePath = submod.hqIcePath != null ? submod.hqIcePath! : '';
  String lqIcePath = submod.lqIcePath != null ? submod.lqIcePath! : '';

  bool aqmRemovalResult = await aqmInjectPopup(context, hqIcePath, lqIcePath, submod.itemName, true, false, false, false, true);
  if (aqmRemovalResult && submod.boundingRemoved!) {
    await boundingRadiusPopup(context, submod);
  }
  if (aqmRemovalResult) {
    submod.customAQMInjected = false;
    submod.customAQMFileName = '';
    saveMasterModListToJson();
    return true;
  } else {
    return false;
  }
}

Future<void> submodAddToSet(context, Item item, Mod mod, SubMod submod) async {
  final (toAddSets, toRemoveSets) = await modToSetPopup(context, submod);
  for (var modset in toRemoveSets) {
    int iIndex = modset.setItems.indexWhere((e) => e.location == item.location);
    if (submod.setNames.contains(modset.setName)) submod.setNames.remove(modset.setName);
    if (mod.submods.indexWhere((e) => e.setNames.contains(modset.setName)) == -1) mod.setNames.remove(modset.setName);
    if (item.mods.indexWhere((e) => e.setNames.contains(modset.setName)) == -1) item.setNames.remove(modset.setName);
    if (!item.setNames.contains(modset.setName) && iIndex != -1) modset.setItems.removeAt(iIndex);
  }
  for (var modset in toAddSets) {
    if (modset.setItems.indexWhere((e) => e.location == item.location) == -1) modset.setItems.add(item);
    if (!item.setNames.contains(modset.setName)) item.setNames.add(modset.setName);
    if (!mod.setNames.contains(modset.setName)) mod.setNames.add(modset.setName);
    if (!submod.setNames.contains(modset.setName)) submod.setNames.add(modset.setName);
  }

  submod.setNames.isNotEmpty ? submod.isSet = true : submod.isSet = false;
  mod.setNames.isNotEmpty ? mod.isSet = true : mod.isSet = false;
  item.setNames.isNotEmpty ? item.isSet = true : item.isSet = false;

  if (toAddSets.isNotEmpty || toRemoveSets.isNotEmpty) {
    saveMasterModSetListToJson();
    saveMasterModListToJson();
  }
}

Future<void> submodDelete(Item item, Mod mod, SubMod submod) async {
  if (Directory(submod.location).existsSync()) await Directory(submod.location).delete(recursive: true);
  if (!Directory(submod.location).existsSync()) {
    // Remove from sets
    for (var setName in submod.setNames) {
      mod.setNames.remove(setName);
    }
    item.setNames.removeWhere((e) => !mod.setNames.contains(e));
    if (item.setNames.isEmpty) {
      for (var modset in masterModSetList) {
        int iIndex = modset.setItems.indexWhere((e) => e.location == item.location);
        if (iIndex != -1) modset.setItems.removeAt(iIndex);
      }
    }
    // Remove from list
    mod.submods.remove(submod);
    if (mod.submods.isEmpty) item.removeMod(mod);
    if (item.mods.isEmpty) {
      int tIndex = masterModList.indexWhere((e) => e.containsCategory(item.category));
      masterModList[tIndex].categories.firstWhere((e) => e.categoryName == item.category).removeItem(item);
    }
    saveMasterModSetListToJson();
    saveMasterModListToJson();
  }
}
