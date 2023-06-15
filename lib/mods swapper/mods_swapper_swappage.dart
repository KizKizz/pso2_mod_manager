import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/mods%20swapper/mods_swapper_popup.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';

class ModsSwapperSwapPage extends StatefulWidget {
  const ModsSwapperSwapPage({super.key, required this.fromSubmod});

  final SubMod fromSubmod;

  @override
  State<ModsSwapperSwapPage> createState() => _ModsSwapperSwapPageState();
}

Future<bool> modsSwapperIceFilesGet(SubMod fromSubmod) async {
  String tempSubmodPathF = Uri.file('$modManSwapperFromItemDirPath/${fromSubmod.submodName}').toFilePath();
  String tempSubmodPathT = Uri.file('$modManSwapperToItemDirPath/${fromSubmod.submodName}').toFilePath();

  toItemAvailableIces.removeWhere((element) => element.split(': ').last.isEmpty);
  if (toItemAvailableIces.isEmpty) {
    return false;
  }
  //get ice files
  for (var line in toItemAvailableIces) {
    //get from ice
    int fromLineIndex = fromItemAvailableIces.indexWhere((element) => element.split(': ').first == line.split(': ').first);
    if (fromLineIndex != -1) {
      final fromModFile = fromSubmod.modFiles.firstWhere((element) => element.modFileName == fromItemAvailableIces[fromLineIndex].split(': ').last);
      final copiedFIceFile = await File(fromModFile.location).copy(Uri.file('$modManSwapperFromItemDirPath/${p.basename(fromModFile.location)}').toFilePath());
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathF"', [copiedFIceFile.path]);

      //get to ices
      String toIcePathFromOgData = '';
      for (var loc in ogDataFilePaths) {
        toIcePathFromOgData = loc.firstWhere((element) => toItemAvailableIces.where((line) => line.split(': ').last == p.basename(element)).isNotEmpty);
        if (toIcePathFromOgData.isNotEmpty) {
          break;
        }
      }
      final copiedTIceFile = await File(toIcePathFromOgData).copy(Uri.file('$modManSwapperToItemDirPath/${p.basename(toIcePathFromOgData)}').toFilePath());
      await Process.run('$modManZamboniExePath -outdir "$tempSubmodPathT"', [copiedTIceFile.path]);

      //change from files ids -> to files ids
      for (var file in Directory(Uri.file('$tempSubmodPathF/${fromItemAvailableIces[fromLineIndex].split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>()) {
        String newFilePath = '';
        if (file.path.contains(fromItemIds[0])) {
          newFilePath = file.path.replaceFirst(fromItemIds[0], toItemIds[1]);
        } else if (file.path.contains(fromItemIds[1])) {
          newFilePath = file.path.replaceFirst(fromItemIds[1], toItemIds[1]);
        } else {
          newFilePath = file.path;
        }

        File renamedFile = await file.rename(Uri.file(newFilePath).toFilePath());
        final extractedFilesInTItem = Directory(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()).listSync(recursive: true).whereType<File>();
        File matchingTFile = extractedFilesInTItem
            .firstWhere((element) => p.basename(element.parent.path) == p.basename(renamedFile.parent.path) && p.basename(element.path) == p.basename(renamedFile.path), orElse: () {
          return File('');
        });
        if (matchingTFile.path.isNotEmpty) {
          renamedFile.copySync(matchingTFile.path);
        }
      }

      //pack
      List<String> charToReplace = ['\\', '/', ':', '*', '?', '"', '<', '>', '|'];
      for (var char in charToReplace) {
        toItemName = toItemName.replaceAll(char, '_');
      }
      String packDirPath = '';
      if (fromSubmod.modName == fromSubmod.submodName) {
        packDirPath = Uri.file('$modManSwapperDirPath/$toItemName/${fromSubmod.modName}').toFilePath();
      } else {
        packDirPath = Uri.file('$modManSwapperDirPath/$toItemName/${fromSubmod.modName}/${fromSubmod.submodName}').toFilePath();
      }
      Directory(packDirPath).createSync(recursive: true);
      await Process.run('$modManZamboniExePath -c -pack -outdir "$packDirPath"', [Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext').toFilePath()]);
      File(Uri.file('$tempSubmodPathT/${line.split(': ').last}_ext.ice').toFilePath()).renameSync(Uri.file('$packDirPath/${line.split(': ').last}').toFilePath());
    }
  }

  return true;
}

class _ModsSwapperSwapPageState extends State<ModsSwapperSwapPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: modsSwapperIceFilesGet(widget.fromSubmod),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Loading item sheets data',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'error when loading item sheets data',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading item sheets data',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              return Scaffold(
                body: ElevatedButton(
                    onPressed: () {
                      selectedFromCsvFile = null;
                      selectedToCsvFile = null;
                      availableItemsCsvData.clear();
                      fromItemIds.clear();
                      toItemIds.clear();
                      fromItemAvailableIces.clear();
                      toItemAvailableIces.clear();
                      Provider.of<StateProvider>(context, listen: false).modsSwapperSwitchToSwapPageFalse();
                      Navigator.pop(context);
                    },
                    child: Text(curLangText!.uiClose)),
              );
            }
          }
        });
  }
}
