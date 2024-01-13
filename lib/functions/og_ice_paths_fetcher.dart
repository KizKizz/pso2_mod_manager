import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';

List<String> fetchOriginalIcePaths(String iceName) {
  List<String> ogPaths = [];
  ogPaths.addAll(ogWin32FilePaths.where((element) => p.basename(element) == iceName));
  ogPaths.addAll(ogWin32NAFilePaths.where((element) => p.basename(element) == iceName));
  ogPaths.addAll(ogWin32RebootFilePaths.where((element) => p.basename(element) == iceName).toList());
  ogPaths.addAll(ogWin32RebootNAFilePaths.where((element) => p.basename(element) == iceName).toList());

  return ogPaths;
}

Future<bool> originalFilesCheck(context, List<ModFile> modFiles) async {
  for (var modFile in modFiles) {
    modFile.ogLocations = fetchOriginalIcePaths(modFile.modFileName);
    if (modFile.ogLocations.isEmpty) {
      List<String> ogFilesFromServers = officialPatchFiles.where((element) => element.contains(modFile.modFileName)).toList();
      ogFilesFromServers.addAll(officialMasterFiles.where((element) => element.contains(modFile.modFileName)));
      List<String> tempOgFiles = [];
      for (var line in ogFilesFromServers) {
        tempOgFiles.add(Uri.file('$modManPso2binPath/$line').toFilePath());
      }
      modFile.ogLocations = tempOgFiles;
      if (modFile.ogLocations.isEmpty) {
        isModViewModsApplying = false;
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', '${curLangText!.uiCouldntFindOGFileFor} ${modFile.modFileName}', 3000));
        return false;
      }
    }
  }

  return true;
}

Future<List<String>> originalFilePathGet(context, String iceName) async {
  List<String> filePaths = [];
  List<String> ogPaths = [];

  filePaths = fetchOriginalIcePaths(iceName);
  if (filePaths.isEmpty) {
    List<String> ogFilesFromServers = officialPatchFiles.where((element) => element.contains(iceName)).toList();
    ogFilesFromServers.addAll(officialMasterFiles.where((element) => element.contains(iceName)));
    for (var line in ogFilesFromServers) {
      ogPaths.add(Uri.file('$modManPso2binPath/$line').toFilePath());
    }
  }

  return ogPaths;
}

List<String> applyModsOgIcePathsFetcher(SubMod submod, String iceName) {
  List<String> ogPaths = [];
  if (submod.category == defaultCateforyDirs[7] && submod.category == defaultCateforyDirs[14]) {
    List<String> win32RebootPaths = ogWin32RebootFilePaths.where((element) => p.basename(element) == iceName).toList();
    List<String> win32RebootNAPaths = ogWin32RebootNAFilePaths.where((element) => p.basename(element) == iceName).toList();
    if (win32RebootPaths.isNotEmpty) {
      ogPaths.addAll(win32RebootPaths);
    }
    if (win32RebootNAPaths.isNotEmpty) {
      ogPaths.addAll(win32RebootNAPaths);
    }
    if (ogPaths.isNotEmpty) {
      return ogPaths;
    }
  } else if (submod.category != defaultCateforyDirs[13]) {
    int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
    int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
    if (win32PathIndex != -1) {
      ogPaths.add(ogWin32FilePaths[win32PathIndex]);
    }
    if (win32NAPathIndex != -1) {
      ogPaths.add(ogWin32NAFilePaths[win32NAPathIndex]);
    }
    if (ogPaths.isNotEmpty) {
      return ogPaths;
    }
  }

  int win32PathIndex = ogWin32FilePaths.indexWhere((element) => p.basename(element) == iceName);
  int win32NAPathIndex = ogWin32NAFilePaths.indexWhere((element) => p.basename(element) == iceName);
  List<String> win32RebootPaths = ogWin32RebootFilePaths.where((element) => p.basename(element) == iceName).toList();
  List<String> win32RebootNAPaths = ogWin32RebootNAFilePaths.where((element) => p.basename(element) == iceName).toList();
  if (win32PathIndex != -1) {
    ogPaths.add(ogWin32FilePaths[win32PathIndex]);
  }
  if (win32NAPathIndex != -1) {
    ogPaths.add(ogWin32NAFilePaths[win32NAPathIndex]);
  }
  if (win32RebootPaths.isNotEmpty) {
    ogPaths.addAll(win32RebootPaths);
  }
  if (win32RebootNAPaths.isNotEmpty) {
    ogPaths.addAll(win32RebootNAPaths);
  }
  return ogPaths;
}

String ogVitalGaugeIcePathsFetcher(String iceName) {
  String win32RebootPath = ogWin32RebootFilePaths.firstWhere(
    (element) => p.basename(element) == iceName,
    orElse: () => '',
  );
  if (win32RebootPath.isNotEmpty) {
    return win32RebootPath;
  }

  String win32RebootNAPath = ogWin32RebootNAFilePaths.firstWhere(
    (element) => p.basename(element) == iceName,
    orElse: () => '',
  );
  if (win32RebootNAPath.isNotEmpty) {
    return win32RebootNAPath;
  }

  return '';
}
