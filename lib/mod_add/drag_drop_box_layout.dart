import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class DragDropBoxLayout extends StatefulWidget {
  const DragDropBoxLayout({super.key, required this.dragDropFileTypes});

  final List<String> dragDropFileTypes;

  @override
  State<DragDropBoxLayout> createState() => _DragDropBoxLayoutState();
}

class _DragDropBoxLayoutState extends State<DragDropBoxLayout> {
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      enable: curModAddDragDropStatus.watch(context) != ModAddDragDropState.unpackingFiles,
      onDragDone: (detail) async {
        for (var file in detail.files) {
          if (p.extension(file.path) == '' || widget.dragDropFileTypes.contains(p.extension(file.path)) || await FileSystemEntity.isDirectory(file.path)) {
            if (!modAddDragDropPaths.contains(file.path)) {
              modAddDragDropPaths.add(file.path);
              if (curModAddDragDropStatus.value != ModAddDragDropState.unpackingFiles) curModAddDragDropStatus.value = ModAddDragDropState.fileInList;
            } else {
              errorNotification(appText.dText(appText.fileAlreadyOnTheList, file.name));
            }
          } else {
            errorNotification(appText.dText(appText.fileIsNotSupported, file.name));
          }
        }
        setState(() {});
      },
      child: CardOverlay(
          paddingValue: 5,
          child: Column(children: [
            Visibility(
                visible: modAddDragDropPaths.isNotEmpty,
                child: Expanded(
                    child: SuperListView.separated(
                  physics: const SuperRangeMaintainingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: modAddDragDropPaths.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                        data: const ListTileThemeData(minTileHeight: 40, minVerticalPadding: 0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                          tileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                          title: Text(
                            p.basename(modAddDragDropPaths[index]),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            p.dirname(modAddDragDropPaths[index]),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                              onPressed: () => setState(() {
                                    modAddDragDropPaths.removeAt(index);
                                  }),
                              color: Colors.redAccent,
                              icon: const Icon(Icons.remove_circle_outline)),
                          contentPadding: const EdgeInsets.all(5),
                          dense: true,
                        ));
                  },
                  separatorBuilder: (BuildContext context, int index) => SizedBox(height: 2),
                ))),
            Visibility(
                visible: modAddDragDropPaths.isEmpty,
                child: Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      appText.dragdropBoxMessage,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      appText.dragdropBoxMessage2,
                      textAlign: TextAlign.center,
                    )
                  ],
                ))),
            Visibility(visible: modAddDragDropPaths.isNotEmpty, child: Divider(height: 10, indent: 15, endIndent: 15)),
            Visibility(
                visible: modAddDragDropPaths.isNotEmpty,
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary)))),
                        onPressed: modAddDragDropPaths.isNotEmpty
                            ? () {
                                modAddDragDropPaths.clear();
                                setState(() {});
                                if (curModAddDragDropStatus.value != ModAddDragDropState.unpackingFiles) curModAddDragDropStatus.value = ModAddDragDropState.waitingForFiles;
                              }
                            : null,
                        child: Stack(
                          alignment: AlignmentGeometry.center,
                          children: [
                            Text(appText.clear),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Text(modAddDragDropPaths.length.toString(), style: Theme.of(context).textTheme.bodySmall)],
                            )
                          ],
                        ))))
          ])),
    );
  }
}
