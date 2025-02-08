import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/mod_add/variants_edit_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:io/io.dart' as io;

Signal<String> modAddProcessingStatus = Signal<String>('');

class ModAddGrid extends StatefulWidget {
  const ModAddGrid({super.key});

  @override
  State<ModAddGrid> createState() => _ModAddGridState();
}

class _ModAddGridState extends State<ModAddGrid> {
  @override
  Widget build(BuildContext context) {
    if (enableModAddFilters) {
      for (var mod in modAddingList) {
        if (modAddFilterList.contains(p.basenameWithoutExtension(mod.modDir.path))) mod.modAddingState = false;
      }
    } else {
      for (var mod in modAddingList) {
        mod.modAddingState = true;
      }
    }
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Visibility(
            visible: curModAddProcessedStatus.watch(context) != ModAddProcessedState.waiting,
            child: ResponsiveGridList(minItemWidth: 315, verticalGridMargin: 0, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: [
              for (int i = 0; i < modAddingList.length; i++)
                CardOverlay(
                  paddingValue: 10,
                  child: Column(
                    spacing: 5,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SubmodPreviewBox(
                          imageFilePaths: modAddingList[i].previewImages.map((f) => f.path).toList(), videoFilePaths: modAddingList[i].previewVideos.map((f) => f.path).toList(), isNew: false),
                      Text(p.basename(modAddingList[i].modDir.path), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        spacing: 5,
                        children: [
                          Expanded(
                            child: InfoBox(
                              info: appText.dText(modAddingList[i].associatedItems.length > 1 ? appText.numMatchedItems : appText.numMatchedItem, modAddingList[i].associatedItems.length.toString()),
                              borderHighlight: false,
                            ),
                          ),
                          Expanded(
                              child: InfoBox(
                            info: appText.dText(modAddingList[i].submods.length > 1 ? appText.numVariants : appText.numVariant, modAddingList[i].submods.length.toString()),
                            borderHighlight: false,
                          ))
                        ],
                      ),
                      Row(
                        spacing: 5,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () async {
                                    final editedAddingItem = await variantsEditPopup(context, modAddingList[i], i);
                                    if (editedAddingItem != null) {
                                      setState(() {
                                        modAddingList[i] = editedAddingItem;
                                      });
                                    }
                                  },
                                  child: Text(
                                    appText.editItemsAndVariants,
                                    textAlign: TextAlign.center,
                                  ))),
                          IconButton(
                              onPressed: () async {
                                final newName = await renamePopup(context, p.dirname(modAddingList[i].modDir.path), p.basename(modAddingList[i].modDir.path));
                                if (newName != null) {
                                  String newPath = p.dirname(modAddingList[i].modDir.path) + p.separator + newName;
                                  await io.copyPath(modAddingList[i].modDir.path, newPath);
                                  await modAddingList[i].modDir.delete(recursive: true);
                                  modAddingList[i] = await modAddRenameRefresh(Directory(newPath), modAddingList[i]);
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.edit),
                              visualDensity: VisualDensity.adaptivePlatformDensity),
                          IconButton(
                              onPressed: () => setState(() {
                                    modAddingList[i].modAddingState ? modAddingList[i].modAddingState = false : modAddingList[i].modAddingState = true;
                                    if (modAddingList.indexWhere((e) => e.modAddingState) == -1) {
                                      curModAddProcessedStatus.value = ModAddProcessedState.noSelectedData;
                                    } else {
                                      curModAddProcessedStatus.value = ModAddProcessedState.dataInList;
                                    }
                                  }),
                              icon:
                                  Icon(modAddingList[i].modAddingState ? Icons.check_box_outlined : Icons.check_box_outline_blank, color: modAddingList[i].modAddingState ? Colors.green : Colors.red),
                              visualDensity: VisualDensity.adaptivePlatformDensity),
                          IconButton(
                              onPressed: () async {
                                if (modAddingList[i].modDir.existsSync()) {
                                  await modAddingList[i].modDir.delete(recursive: true);
                                }
                                setState(() {
                                  modAddingList.removeAt(i);
                                });
                                if (modAddingList.isEmpty) {
                                  curModAddProcessedStatus.value = ModAddProcessedState.waiting;
                                }
                              },
                              icon: const Icon(
                                Icons.delete_forever_outlined,
                                color: Colors.red,
                              ),
                              visualDensity: VisualDensity.adaptivePlatformDensity),
                        ],
                      ),
                    ],
                  ),
                )
            ])),
        Visibility(
            visible: curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting || curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData,
            child: Center(
              child: CardOverlay(
                paddingValue: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    if (curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting)
                      LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).colorScheme.primary,
                        size: 100,
                      ),
                    if (curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData)
                      LoadingAnimationWidget.progressiveDots(
                        color: Theme.of(context).colorScheme.primary,
                        size: 100,
                      ),
                    Text(
                      curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting ? appText.waitingForItems : appText.processingItems,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Visibility(visible: curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData, child: Text(modAddProcessingStatus.watch(context)))
                  ],
                ),
              ),
            ))
      ],
    );
  }
}
