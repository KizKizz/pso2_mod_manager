import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
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
    modAddDragDropPaths.isEmpty ? isModDragDropListEmpty.value = true : isModDragDropListEmpty.value = false;
    
    return DropTarget(
        onDragDone: (detail) {
          setState(() {
            for (var file in detail.files) {
              if (p.extension(file.path) == '' || widget.dragDropFileTypes.contains(p.extension(file.path))) {
                if (!modAddDragDropPaths.contains(file.path)) {
                  modAddDragDropPaths.add(file.path);
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
                  itemCount: modAddDragDropPaths.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                        data: const ListTileThemeData(minTileHeight: 45, minVerticalPadding: 0),
                        child: ListTile(
                          title: Text(
                            p.basename(modAddDragDropPaths[index]),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            FileSystemEntity.isFileSync(modAddDragDropPaths[index]) ? appText.file : appText.folder,
                            style: Theme.of(context).textTheme.bodyMedium,
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
                ),
                Visibility(
                    visible: modAddDragDropPaths.isEmpty,
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
                    visible: modAddDragDropPaths.isNotEmpty,
                    child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                            onPressed: modAddDragDropPaths.isNotEmpty
                                ? () => setState(() {
                                      modAddDragDropPaths.clear();
                                    })
                                : null,
                            child: Text(appText.clear))))
              ],
            )));
  }
}
