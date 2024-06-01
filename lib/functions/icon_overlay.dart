import 'dart:io';
import 'package:flutter/material.dart' as m;
import 'package:image/image.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/player_item_data.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';

Future<File?> iconOverlay(String iconImagePath) async {
  if (!File(iconImagePath).existsSync()) return null;
  Image? icon = await decodePngFile(iconImagePath);
  Image? overlay;
  if (icon?.width == 128 && icon?.height == 128) {
    overlay = await decodePngFile('assets/img/icon_overlay.png');
  } else if (icon?.width == 64 && icon?.height == 64) {
    overlay = await decodePngFile('assets/img/icon_overlay_l.png');
  }
  if (overlay != null) {
    for (var oPixel in overlay.data!) {
      if (oPixel.a > 0) {
        icon!.setPixel(oPixel.x, oPixel.y, oPixel);
      }
    }
  }
  File overlayedIcon = File(Uri.file('${p.dirname(iconImagePath)}/${p.basename(iconImagePath)}').toFilePath());
  overlayedIcon.writeAsBytesSync(encodePng(icon!));
  return overlayedIcon.existsSync() ? overlayedIcon : null;
}

Future<File?> iconOverlayIceConvert(context, Item item) async {
  //get ori icon ice path
  if (item.iconPath == null || item.iconPath!.isEmpty) {
    if (playerItemData.isEmpty) {
      await playerItemDataGet();
    }
    int itemDataIndex = playerItemData.indexWhere((element) =>
        p.basenameWithoutExtension(element.iconImagePath) == p.basenameWithoutExtension(item.location) ||
        element.getENName() == p.basenameWithoutExtension(item.location).replaceAll('_', '/') ||
        element.getJPName() == p.basenameWithoutExtension(item.location).replaceAll('_', '/'));
    if (itemDataIndex != -1 && playerItemData[itemDataIndex].iconImagePath.isNotEmpty) {
      String iconIceName = playerItemData[itemDataIndex].getIconIceName();
      if (iconIceName.isNotEmpty) {
        final iconIcePaths = await originalFilePathGet(context, iconIceName);
        if (iconIcePaths.isNotEmpty) item.iconPath = iconIcePaths.first;
      }
    } else {
      for (var mod in item.mods) {
        for (var submod in mod.submods) {
          for (var modFile in submod.modFiles) {
            int index = playerItemData.indexWhere((element) =>
                element.infos.entries.where((e) => (e.key == 'Normal Quality' && e.value == modFile.modFileName) || (e.key == 'High Quality' && e.value == modFile.modFileName)).isNotEmpty);
            if (index != -1 && playerItemData[index].iconImagePath.isNotEmpty) {
              if (itemDataIndex != -1 && playerItemData[itemDataIndex].iconImagePath.isNotEmpty) {
                String iconIceName = playerItemData[index].getIconIceName();
                if (iconIceName.isNotEmpty) {
                  final iconIcePaths = await originalFilePathGet(context, iconIceName);
                  if (iconIcePaths.isNotEmpty) item.iconPath = iconIcePaths.first;
                }
              }
            }
          }
        }
      }
    }

    //download ori ice and apply overlay
    if (item.iconPath != null && item.iconPath!.isNotEmpty) {
      clearAllTempDirs();
      final dlIconIceFilePath = await downloadIconIceFromOfficial(item.iconPath!, modManAddModsTempDirPath);
      if (dlIconIceFilePath.isNotEmpty) {
        await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [dlIconIceFilePath]);
        Directory extractedIceDir = Directory(Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(item.iconPath!)}_ext').toFilePath());
        if (extractedIceDir.existsSync()) {
          File ddsFile = extractedIceDir.listSync(recursive: true).whereType<File>().firstWhere(
                (element) => p.extension(element.path) == '.dds',
                orElse: () => File(''),
              );
          if (ddsFile.existsSync()) {
            await Process.run(modManDdsPngToolExePath, [ddsFile.path, Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath(), '-ddstopng']);
            File convertedPng = File(Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath());
            if (convertedPng.existsSync()) {
              ddsFile.deleteSync();
              File? overlayedPng = await iconOverlay(convertedPng.path);
              if (overlayedPng != null) {
                await Process.run(
                    modManDdsPngToolExePath, [overlayedPng.path, Uri.file('${p.dirname(overlayedPng.path)}/${p.basenameWithoutExtension(overlayedPng.path)}.dds').toFilePath(), '-pngtodds']);
                overlayedPng.deleteSync();
                await Process.run(
                    '$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basenameWithoutExtension(item.iconPath!)}_ext').toFilePath()]);
                Directory(modManOverlayedItemIconsDirPath).createSync(recursive: true);
                File renamedIconFile = await File(Uri.file('${dlIconIceFilePath}_ext.ice').toFilePath())
                    .rename(Uri.file(dlIconIceFilePath.replaceFirst(modManAddModsTempDirPath, modManOverlayedItemIconsDirPath)).toFilePath());
                if (renamedIconFile.existsSync()) {
                  clearAllTempDirs();
                  return renamedIconFile;
                }
              }
            }
          }
        }
      }
    }
  }
  return null;
}

Future<bool> backupOverlayIcon(Item item) async {
  String backupIconPath = item.iconPath!.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManBackupsDirPath);
  File copiedFile = await File(item.iconPath!).copy(backupIconPath);
  if (copiedFile.existsSync()) {
    item.backupIconPath = copiedFile.path;
    return true;
  }
  return false;
}

Future<bool> applyOverlayedIcon(context, Item item) async {
  if (!Provider.of<StateProvider>(context, listen: false).markModdedItem || item.icons.first.contains('assets/img/placeholdersquare.png') || item.icons.isEmpty) {
    return false;
  }
  if (item.overlayedIconPath!.isEmpty || !File(item.overlayedIconPath!).existsSync()) {
    File? overlayIcon = await iconOverlayIceConvert(context, item);
    if (overlayIcon != null) item.overlayedIconPath = overlayIcon.path;
  }
  if (!item.isOverlayedIconApplied! && File(item.overlayedIconPath!).existsSync()) {
    bool backupSuccess = await backupOverlayIcon(item);
    if (backupSuccess) {
      try {
        await File(item.overlayedIconPath!).copy(item.iconPath!);
      } catch (e) {
        m.debugPrint(e.toString());
        return false;
      }
    }
    item.isOverlayedIconApplied = true;
    saveModdedItemListToJson();
    return true;
  }
  return false;
}

Future<bool> restoreOverlayedIcon(Item item) async {
  // if (item.isOverlayedIconApplied! && item.iconPath!.isNotEmpty) {
  //   File backupFile = File(item.backupIconPath!);
  //   if (backupFile.existsSync()) {
  //     File restoredFile = await backupFile.copy(item.iconPath!);
  //     if (restoredFile.existsSync()) {
  // backupFile.deleteSync();
  //       item.backupIconPath = '';
  //       item.isOverlayedIconApplied = false;
  //       saveModdedItemListToJson();
  //       return true;
  //     } else {
  //       String downloadedFilePath = await downloadIconIceFromOfficial(item.iconPath!.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), p.dirname(item.iconPath!));
  //       if (File(downloadedFilePath).existsSync()) {
  //         File restoredFile = await File(downloadedFilePath).copy(item.iconPath!);
  //         if (restoredFile.existsSync()) {
  //           item.backupIconPath = '';
  //           item.isOverlayedIconApplied = false;
  //           saveModdedItemListToJson();
  //           return true;
  //         }
  //       }
  //     }
  //   }
  // }
  if (item.isOverlayedIconApplied! && item.iconPath!.isNotEmpty) {
    String downloadedFilePath = await downloadIconIceFromOfficial(item.iconPath!.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), p.dirname(item.iconPath!));
    if (File(downloadedFilePath).existsSync()) {
      File restoredFile = await File(downloadedFilePath).copy(item.iconPath!);
      if (restoredFile.existsSync()) {
        File backupFile = File(item.backupIconPath!);
        if (backupFile.existsSync()) backupFile.deleteSync();
        item.backupIconPath = '';
        item.isOverlayedIconApplied = false;
        saveModdedItemListToJson();
        return true;
      }
    }
  }
  return false;
}
