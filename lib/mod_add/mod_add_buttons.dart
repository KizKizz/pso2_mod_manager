import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_filter_popup.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_to_set_popup.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:signals/signals_flutter.dart';

class ModAddDragDropButtons extends StatefulWidget {
  const ModAddDragDropButtons({super.key, required this.dragDropFileTypes});

  final List<String> dragDropFileTypes;

  @override
  State<ModAddDragDropButtons> createState() => _ModAddDragDropButtonsState();
}

class _ModAddDragDropButtonsState extends State<ModAddDragDropButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(spacing: 5, children: [
      OverflowBar(
        spacing: 5,
        overflowSpacing: 5,
        alignment: MainAxisAlignment.spaceBetween,
        overflowAlignment: OverflowBarAlignment.center,
        children: [
          // Browse files
          ElevatedButton(
              onPressed: () async {
                XTypeGroup archiveTypeGroup = XTypeGroup(
                  label: appText.archives,
                  extensions: widget.dragDropFileTypes,
                );
                XTypeGroup iceTypeGroup = XTypeGroup(
                  label: appText.iceFiles,
                  extensions: const <String>['*'],
                );
                final List<XFile> selectedFiles = await openFiles(acceptedTypeGroups: <XTypeGroup>[archiveTypeGroup, iceTypeGroup]);
                if (selectedFiles.isNotEmpty) {
                  curModAddDragDropStatus.value = ModAddDragDropState.waitingForFiles;
                  modAddDragDropPaths.addAll(selectedFiles.map((e) => e.path));
                  curModAddDragDropStatus.value = ModAddDragDropState.fileInList;
                }
              },
              child: Text(
                appText.addFiles,
                textAlign: TextAlign.center,
              )),

          // Browse Dir
          ElevatedButton(
              onPressed: () async {
                final List<String?> selectedDirPaths = await getDirectoryPaths();
                if (selectedDirPaths.isNotEmpty) {
                  for (var path in selectedDirPaths) {
                    curModAddDragDropStatus.value = ModAddDragDropState.waitingForFiles;
                    modAddDragDropPaths.add(path!);
                    curModAddDragDropStatus.value = ModAddDragDropState.fileInList;
                  }
                }
              },
              child: Text(
                appText.addFolders,
                textAlign: TextAlign.center,
              )),

          // Ignore list
          ElevatedButton.icon(
              onPressed: () async {
                await modAddFilterPopup(context);
                setState(() {});
              },
              icon: enableModAddFilters ? const Icon(Icons.check) : null,
              iconAlignment: IconAlignment.end,
              label: Text(
                appText.filters,
                textAlign: TextAlign.center,
              )),
        ],
      ),
      // Process files
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            onPressed: curModAddDragDropStatus.watch(context) == ModAddDragDropState.fileInList
                ? () async {
                    curModAddDragDropStatus.value = ModAddDragDropState.unpackingFiles;
                    curModAddProcessedStatus.value = ModAddProcessedState.loadingData;
                    await modAddUnpack(context, modAddDragDropPaths.toList());
                    modAddDragDropPaths.clear();
                    modAddingList = await modAddSort();
                    curModAddDragDropStatus.value = ModAddDragDropState.waitingForFiles;
                    if (modAddingList.isNotEmpty) curModAddProcessedStatus.value = ModAddProcessedState.dataInList;
                  }
                : null,
            child: Text(
              appText.process,
              textAlign: TextAlign.center,
            )),
      ),
    ]);
  }
}

class ModAddProcessedButtons extends StatefulWidget {
  const ModAddProcessedButtons({super.key});

  @override
  State<ModAddProcessedButtons> createState() => _ModAddProcessedButtonsState();
}

class _ModAddProcessedButtonsState extends State<ModAddProcessedButtons> {
  List<ModSet> modSetsToAdd = [];
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
            child: ElevatedButton.icon(
                onPressed: curModAddProcessedStatus.watch(context) == ModAddProcessedState.dataInList
                    ? () async {
                        if (Directory(modAddTempDirPath).existsSync()) {
                          await Directory(modAddTempDirPath).delete(recursive: true);
                        }
                        modAddingList.clear();
                        modSetsToAdd.clear();
                        curModAddProcessedStatus.value = ModAddProcessedState.waiting;
                      }
                    : null,
                label: Text(appText.clearAll))),
        Expanded(
            child: ElevatedButton.icon(
                onPressed: curModAddProcessedStatus.watch(context) == ModAddProcessedState.dataInList
                    ? () async {
                        modSetsToAdd = await modAddToSetPopup(context, modSetsToAdd);
                        setState(() {});
                      }
                    : null,
                icon: modSetsToAdd.isNotEmpty ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                iconAlignment: IconAlignment.end,
                label: Text(appText.addToSet))),
        Expanded(
          flex: 2,
          child: ElevatedButton(
              onPressed: curModAddProcessedStatus.watch(context) == ModAddProcessedState.dataInList
                  ? () async {
                      curModAddProcessedStatus.value = ModAddProcessedState.addingToMasterList;
                      await modAddToMasterList(modSetsToAdd.isEmpty ? false : true, modSetsToAdd);
                      modAddingList.isNotEmpty ? curModAddProcessedStatus.value = ModAddProcessedState.dataInList : curModAddProcessedStatus.value = ModAddProcessedState.waiting;
                      modSetsToAdd.clear();
                    }
                  : null,
              child: Text(
                appText.add,
                textAlign: TextAlign.center,
              )),
        )
      ],
    );
  }
}
