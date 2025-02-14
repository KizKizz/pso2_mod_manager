import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';

Future<File?> itemIconOverlay(String iconImagePath) async {
  if (!File(iconImagePath).existsSync()) return null;
  Image? icon = await decodePngFile(iconImagePath);
  Image? overlay;
  if (icon?.width == 128 && icon?.height == 128) {
    if (kDebugMode) {
      overlay = await decodePngFile('assets/img/icon_overlay.png');
    } else {
      overlay = await decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/icon_overlay.png').toFilePath());
    }
  } else if (icon?.width == 64 && icon?.height == 64) {
    if (kDebugMode) {
      overlay = await decodePngFile('assets/img/icon_overlay_l.png');
    } else {
      overlay = await decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/icon_overlay_l.png').toFilePath());
    }
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

Future<bool> markedItemIconApply(Item item) async {
  if (Directory(modItemIconTempDirPath).existsSync()) {
    Directory(modItemIconTempDirPath).deleteSync(recursive: true);
    Directory(modItemIconTempDirPath).createSync(recursive: true);
  } else {
    Directory(modItemIconTempDirPath).create(recursive: true);
  }

  if (item.overlayedIconPath!.isNotEmpty && File(item.overlayedIconPath!).existsSync()) {
    File cachedIconIceFile = File(item.overlayedIconPath!);
    String iconIceWebPath = oItemData.firstWhere((e) => e.path.contains(p.basenameWithoutExtension(cachedIconIceFile.path))).path;
    modApplyStatus.value = appText.dText(appText.copyingIconFileToGameData, p.basenameWithoutExtension(cachedIconIceFile.path));
    Future.delayed(const Duration(microseconds: 10));
    File copiedFile = await cachedIconIceFile.copy(pso2binDirPath + p.separator + p.withoutExtension(iconIceWebPath).replaceAll('/', p.separator));
    if (await copiedFile.getMd5Hash() == await File(item.overlayedIconPath!).getMd5Hash()) {
      item.iconPath = copiedFile.path;
      item.isOverlayedIconApplied = true;
      saveMasterModListToJson();
      return true;
    }
  } else {
    final itemData = pItemData.firstWhere((e) =>
        e.getENName() == item.itemName ||
        e.getJPName() == item.itemName ||
        item.getDistinctModFilePaths().map((path) => p.basenameWithoutExtension(path)).every((name) => e.getIceDetailsWithoutKeys().contains(name)));
    final itemIconIceName = itemData.getIconIceName();

    File cachedIconIceFile = File(markedItemIconsDirPath + p.separator + itemIconIceName);
    if (itemIconIceName.isNotEmpty && cachedIconIceFile.existsSync()) {
      String iconIceWebPath = oItemData.firstWhere((e) => e.path.contains(itemIconIceName)).path;
      modApplyStatus.value = appText.dText(appText.copyingIconFileToGameData, p.basenameWithoutExtension(cachedIconIceFile.path));
      Future.delayed(const Duration(microseconds: 10));
      File copiedFile = await cachedIconIceFile.copy(pso2binDirPath + p.separator + p.withoutExtension(pso2binDirPath + p.separator + iconIceWebPath).replaceAll('/', p.separator));
      if (await copiedFile.getMd5Hash() == await File(item.overlayedIconPath!).getMd5Hash()) {
        item.iconPath = copiedFile.path;
        item.isOverlayedIconApplied = true;
        item.overlayedIconPath = cachedIconIceFile.path;
        saveMasterModListToJson();
        return true;
      }
    } else if (itemIconIceName.isNotEmpty && !cachedIconIceFile.existsSync()) {
      String iconIceWebPath = oItemData.firstWhere((e) => e.path.contains(itemIconIceName)).path;
      File downloadedIconIce = await originalIceDownload(iconIceWebPath, modItemIconTempDirPath, modApplyStatus);
      modApplyStatus.value = appText.dText(appText.editingMod, itemIconIceName);
      Future.delayed(const Duration(microseconds: 10));
      if (downloadedIconIce.path.isNotEmpty && downloadedIconIce.existsSync()) {
        await Process.run('$zamboniExePath -outdir "$modItemIconTempDirPath"', [downloadedIconIce.path]);
        Directory extractedIceDir = Directory(Uri.file('$modItemIconTempDirPath/${p.basenameWithoutExtension(itemIconIceName)}_ext').toFilePath());
        if (extractedIceDir.existsSync()) {
          File ddsFile = extractedIceDir.listSync(recursive: true).whereType<File>().firstWhere(
                (element) => p.extension(element.path) == '.dds',
                orElse: () => File(''),
              );
          if (ddsFile.existsSync()) {
            await Process.run(pngDdsConvExePath, [ddsFile.path, Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath(), '-ddstopng']);
            File convertedPng = File(Uri.file('${p.dirname(ddsFile.path)}/${p.basenameWithoutExtension(ddsFile.path)}.png').toFilePath());
            if (convertedPng.existsSync()) {
              ddsFile.deleteSync();
              File? overlayedPng = await itemIconOverlay(convertedPng.path);
              if (overlayedPng != null) {
                await Process.run(pngDdsConvExePath, [overlayedPng.path, Uri.file('${p.dirname(overlayedPng.path)}/${p.basenameWithoutExtension(overlayedPng.path)}.dds').toFilePath(), '-pngtodds']);
                await overlayedPng.delete();
                modApplyStatus.value = appText.dText(appText.repackingFile, itemIconIceName);
                Future.delayed(const Duration(microseconds: 10));
                await Process.run('$zamboniExePath -c -pack -outdir "$modItemIconTempDirPath"', [Uri.file('$modItemIconTempDirPath/${p.basenameWithoutExtension(itemIconIceName)}_ext').toFilePath()]);
                Directory(markedItemIconsDirPath).createSync(recursive: true);
                File renamedIconFile = await File(Uri.file('${downloadedIconIce.path}_ext.ice').toFilePath())
                    .rename(Uri.file(downloadedIconIce.path.replaceFirst(modItemIconTempDirPath, markedItemIconsDirPath)).toFilePath());
                if (renamedIconFile.existsSync()) {
                  modApplyStatus.value = appText.dText(appText.copyingIconFileToGameData, itemIconIceName);
                  Future.delayed(const Duration(microseconds: 10));
                  String iconIceBinPath = p.withoutExtension(pso2binDirPath + p.separator + iconIceWebPath).replaceAll('/', p.separator);
                  File copiedFile = await renamedIconFile.copy(iconIceBinPath);
                  if (await copiedFile.getMd5Hash() == await renamedIconFile.getMd5Hash()) {
                    item.iconPath = copiedFile.path;
                    item.overlayedIconPath = renamedIconFile.path;
                    item.isOverlayedIconApplied = true;
                    saveMasterModListToJson();
                    return true;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return false;
}

Future<bool> markedItemIconRestore(Item item) async {
  String iconWebPath = ('${p.withoutExtension(item.iconPath!).replaceFirst(pso2binDirPath + p.separator, '')}.pat').replaceAll(p.separator, '/');
  File downloadedFile = await originalIceDownload(iconWebPath, p.dirname(item.iconPath!), modApplyStatus);
  modApplyStatus.value = appText.dText(appText.copyingIconFileToGameData, p.basenameWithoutExtension(downloadedFile.path));
  Future.delayed(const Duration(microseconds: 10));
  if (await downloadedFile.getMd5Hash() != await File(item.overlayedIconPath!).getMd5Hash()) {
    item.iconPath = '';
    item.backupIconPath = '';
    item.isOverlayedIconApplied = false;
    saveMasterModListToJson();
    return true;
  }
  return false;
}

Future<bool> markedAqmItemIconRestore(String gameDataIconIcePath) async {
  String iconWebPath = ('${p.withoutExtension(gameDataIconIcePath).replaceFirst(pso2binDirPath + p.separator, '')}.pat').replaceAll(p.separator, '/');
  File downloadedFile = await originalIceDownload(iconWebPath, p.dirname(gameDataIconIcePath), modApplyStatus);
  modAqmInjectingStatus.value = appText.dText(appText.copyingIconFileToGameData, p.basenameWithoutExtension(downloadedFile.path));
  Future.delayed(const Duration(microseconds: 10));
  return false;
}
