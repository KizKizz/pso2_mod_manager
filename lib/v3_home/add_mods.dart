import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:path/path.dart' as p;
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class AddMods extends StatefulWidget {
  const AddMods({super.key});

  @override
  State<AddMods> createState() => _AddModsState();
}

class _AddModsState extends State<AddMods> {
  double fadeInOpacity = 0;
  List<String> dragDropSupportedExts = ['.7z', '.zip', '.rar'];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
            flex: 1,
            child: DropTarget(
              onDragDone: (detail) {
                            setState(() {
                              for (var file in detail.files) {
                                if (p.extension(file.path) == '' || dragDropSupportedExts.contains(p.extension(file.path))) {
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
                          child: Column(
                            spacing: 5,
                            children: [
                              modAddDragDropPaths.watch(context).isEmpty 
                              ? Column(
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
                                    )
                                    : SuperListView.builder(
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
                                )
                            ],
                          ))),
        Column(
          children: [],
        ),
        Expanded(
            flex: 2,
            child: Container(
            ))
      ],
    );
  }
}
