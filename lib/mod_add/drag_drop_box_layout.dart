import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

Signal<bool> isModDragDropListEmpty = Signal(true);

class DragDropBoxLayout extends StatefulWidget {
  const DragDropBoxLayout({super.key, required this.dragDropFileTypes});

  final List<String> dragDropFileTypes;

  @override
  State<DragDropBoxLayout> createState() => _DragDropBoxLayoutState();
}

class _DragDropBoxLayoutState extends State<DragDropBoxLayout> {
  @override
  Widget build(BuildContext context) {
    modAddDragDropPaths.value.isEmpty ? isModDragDropListEmpty.value = true : isModDragDropListEmpty.value = false;
    
    return DropTarget(
        onDragDone: (detail) {
          setState(() {
            for (var file in detail.files) {
              if (p.extension(file.path) == '' || widget.dragDropFileTypes.contains(p.extension(file.path))) {
                if (!modAddDragDropPaths.value.contains(file.path)) {
                  modAddDragDropPaths.value.add(file.path);
                } else {
                  errorNotification(context, appText.dText(appText.fileAlreadyOnTheList, file.name));
                }
              } else {
                errorNotification(context, appText.dText(appText.fileIsNotSupported, file.name));
              }
            }
          });
        },
        child: CardOverlay(
            paddingValue: 5,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                SuperListView.builder(
                  physics: const SuperRangeMaintainingScrollPhysics(),
                  itemCount: modAddDragDropPaths.watch(context).length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                        data: const ListTileThemeData(minTileHeight: 45, minVerticalPadding: 0),
                        child: ListTile(
                          title: Text(
                            p.basename(modAddDragDropPaths.value[index]),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            FileSystemEntity.isFileSync(modAddDragDropPaths.value[index]) ? appText.file : appText.folder,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: IconButton(
                              onPressed: () => setState(() {
                                    modAddDragDropPaths.value.removeAt(index);
                                  }),
                              color: Colors.redAccent,
                              icon: const Icon(Icons.remove_circle_outline)),
                          contentPadding: const EdgeInsets.all(5),
                          dense: true,
                        ));
                  },
                ),
                Visibility(
                    visible: modAddDragDropPaths.value.isEmpty,
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
                    )),
                Visibility(
                    visible: modAddDragDropPaths.value.isNotEmpty,
                    child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: modAddDragDropPaths.watch(context).isNotEmpty
                                ? () => setState(() {
                                      modAddDragDropPaths.value.clear();
                                    })
                                : null,
                            child: Text(appText.clear))))
              ],
            )));
  }
}
