import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

class ModAddButtons extends StatefulWidget {
  const ModAddButtons({super.key, required this.dragDropFileTypes});

  final List<String> dragDropFileTypes;

  @override
  State<ModAddButtons> createState() => _ModAddButtonsState();
}

class _ModAddButtonsState extends State<ModAddButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Browse files
        FloatingActionButton(
            elevation: 5,
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
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
                modAddDragDropPaths.addAll(selectedFiles.map((e) => e.path));
              }
            },
            child: Text(
              appText.addFiles,
              textAlign: TextAlign.center,
            )),

        // Browse Dir
        FloatingActionButton(
            elevation: 5,
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
            onPressed: () async {
              final List<String?> selectedDirPaths = await getDirectoryPaths();
              if (selectedDirPaths.isNotEmpty) {
                for (var path in selectedDirPaths) {
                  modAddDragDropPaths.add(path!);
                }
              }
            },
            child: Text(
              appText.addFolders,
              textAlign: TextAlign.center,
            )),

        // Ignore list
        FloatingActionButton(
            elevation: 5,
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
            onPressed: () {},
            child: Text(
              appText.ignoreList,
              textAlign: TextAlign.center,
            )),

        // Process files
        FloatingActionButton(
            elevation: 5,
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Colors.blueAccent.withAlpha(uiBackgroundColorAlpha.watch(context)),
            onPressed: !isModDragDropListEmpty.watch(context)
                ? () async {
                    await modAddUnpack(modAddDragDropPaths);
                    final test = modAddSort();
                  }
                : null,
            child: Text(
              appText.process,
              textAlign: TextAlign.center,
            )),
        const HoriDivider(),

        // Add
        FloatingActionButton(
            elevation: 5,
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Colors.green.withAlpha(uiBackgroundColorAlpha.watch(context)),
            onPressed: () {},
            child: Text(
              appText.add,
              textAlign: TextAlign.center,
            ))
      ],
    );
  }
}
