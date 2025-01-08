import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/mod_add_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:pso2_mod_manager/v3_widgets/vertical_divider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Future<AddingMod?> variantsEditPopup(context, AddingMod addingMod, int curIndex) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5),
            title: Column(children: [
              Text(
                p.basename(addingMod.modDir.path),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      spacing: 15,
                      children: [
                        Text(appText.matchedItems, style: Theme.of(context).textTheme.titleMedium),
                        Expanded(
                            child: ResponsiveGridList(minItemWidth: 150, verticalGridMargin: 0, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: [
                          for (int i = 0; i < addingMod.associatedItems.length; i++)
                            CardOverlay(
                              paddingValue: 5,
                              child: Column(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ModAddItemIconBox(itemIcon: addingMod.associatedItems[i].iconImagePath),
                                  Text(p.basename(addingMod.associatedItems[i].getName()), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                                  IconButton(
                                      onPressed: addingMod.associatedItems.length > 1
                                          ? () => setState(() {
                                                addingMod.aItemAddingStates[i] ? addingMod.aItemAddingStates[i] = false : addingMod.aItemAddingStates[i] = true;
                                              })
                                          : null,
                                      icon: Icon(addingMod.aItemAddingStates[i] ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                          color: addingMod.aItemAddingStates[i] ? Colors.green : Colors.red),
                                      visualDensity: VisualDensity.adaptivePlatformDensity),
                                ],
                              ),
                            )
                        ])),
                      ],
                    ),
                  ),
                  const VertDivider(),
                  Expanded(
                      flex: 3,
                      child: ResponsiveGridList(minItemWidth: 300, verticalGridMargin: 0, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: [
                        for (int i = 0; i < addingMod.submods.length; i++)
                          CardOverlay(
                            paddingValue: 10,
                            child: Column(
                              spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubmodImageBox(
                                    filePaths: addingMod.submods[i]
                                        .listSync(recursive: addingMod.submods[i] != addingMod.modDir)
                                        .whereType<File>()
                                        .where((e) => p.extension(e.path) == '.png' || p.extension(e.path) == '.jpg')
                                        .map((e) => e.path)
                                        .toList(),
                                    isNew: false),
                                Text(addingMod.submodNames[i], textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                                Row(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: ModManTooltip(
                                        message: addingMod.submods[i].listSync().whereType<File>().where((e) => p.extension(e.path) == '').map((e) => p.basename(e.path)).join('\n'),
                                        child: InfoBox(
                                        info: appText.dText(
                                            addingMod.submods[i].listSync().whereType<File>().where((e) => p.extension(e.path) == '').length > 1 ? appText.numFiles : appText.numFile,
                                            addingMod.submods[i]
                                                .listSync(recursive: addingMod.submods.indexWhere((e) => e.parent == addingMod.submods[i]) != -1)
                                                .whereType<File>()
                                                .where((e) => p.extension(e.path) == '')
                                                .length
                                                .toString())),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: addingMod.submods[i] != addingMod.modDir ? () async {
                                          final newName = await renamePopup(context, p.dirname(addingMod.submods[i].path), p.basename(addingMod.submods[i].path));
                                          if (newName != null) {
                                            String newPath = p.dirname(addingMod.submods[i].path) + p.separator + newName;
                                            await io.copyPath(addingMod.submods[i].path, newPath);
                                            await addingMod.submods[i].delete(recursive: true);
                                            addingMod = await modAddRenameRefresh(addingMod.modDir, addingMod);
                                            modAddingList[curIndex] = addingMod;
                                            setState(() {});
                                          }
                                        } : null,
                                        icon: const Icon(Icons.edit),
                                        visualDensity: VisualDensity.adaptivePlatformDensity),
                                    IconButton(
                                        onPressed: () => setState(() {
                                              addingMod.submodAddingStates[i] ? addingMod.submodAddingStates[i] = false : addingMod.submodAddingStates[i] = true;
                                            }),
                                        icon: Icon(addingMod.submodAddingStates[i] ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                            color: addingMod.submodAddingStates[i] ? Colors.green : Colors.red),
                                        visualDensity: VisualDensity.adaptivePlatformDensity),
                                  ],
                                ),
                              ],
                            ),
                          )
                      ]))
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(addingMod);
                      },
                      child: Text(appText.saveAndReturn)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
