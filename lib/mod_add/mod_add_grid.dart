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
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/rename_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
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
      for (var filterWord in modAddFilterList) {
        for (var mod in modAddingList) {
          if (p.basename(mod.modDir.path).split(' ').contains(filterWord)) {
            mod.modAddingState = false;
          }
          for (var submodName in mod.submodNames) {
            if (submodName.split(' ').contains(filterWord)) {
              int submodIndex = mod.submodNames.indexOf(submodName);
              mod.submodAddingStates[submodIndex] = false;
            }
          }
        }
      }
    } else {
      for (var mod in modAddingList) {
        mod.modAddingState = true;
      }
    }

    if (curModAddProcessedStatus.value == ModAddProcessedState.waiting) modAddDropBoxShow.value = true;
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Visibility(
            visible: curModAddProcessedStatus.watch(context) != ModAddProcessedState.waiting && curModAddProcessedStatus.watch(context) != ModAddProcessedState.addingToMasterList,
            child: ResponsiveGridList(minItemWidth: 375, verticalGridMargin: 0, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: [
              for (int i = 0; i < modAddingList.length; i++)
                CardOverlay(
                  paddingValue: 5,
                  child: Column(
                    spacing: 5,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 2.5,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GenericItemIconBox(iconImagePaths: [modAddingList[i].associatedItems[0].iconImagePath], boxSize: const Size(140, 140), isNetwork: true),
                                Text(modAddingList[i].associatedItems[0].getName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SubmodPreviewBox(
                                    imageFilePaths: modAddingList[i].previewImages.map((f) => f.path).toList(),
                                    videoFilePaths: modAddingList[i].previewVideos.map((f) => f.path).toList(),
                                    isNew: false),
                                Text(p.basename(modAddingList[i].modDir.path), textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          )
                        ],
                      ),
                      Row(
                        spacing: 2.5,
                        children: [
                          Expanded(
                              child: ModManTooltip(
                            message: modAddingList[i].submodNames.join('\n'),
                            child: InfoBox(
                              info:
                                  appText.dText(modAddingList[i].submods.length > 1 ? appText.numVariants : appText.numVariant, modAddingList[i].submods.length.toString()),
                              borderHighlight: false,
                            ),
                          )),
                          Expanded(
                              child: ModManTooltip(
                            message: modAddingList[i].submodNames.where((e) => modAddingList[i].submodAddingStates[modAddingList[i].submodNames.indexOf(e)] == true).join('\n'),
                            child: InfoBox(
                              info:
                                  appText.dText(appText.numItemSelected, modAddingList[i].submodAddingStates.where((e) => e == true).length.toString()),
                              borderHighlight: false,
                            ),
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
                                      modAddingList[i] = editedAddingItem;
                                    }
                                    setState(() {});
                                  },
                                  child: Text(
                                    appText.editVariants,
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
                              onPressed: () {
                                if (modAddingList[i].aItemAddingStates[0]) {
                                  modAddingList[i].aItemAddingStates[0] = false;
                                } else {
                                  modAddingList[i].aItemAddingStates[0] = true;
                                }
                                if (modAddingList.indexWhere((e) => e.modAddingState) == -1) {
                                  curModAddProcessedStatus.value = ModAddProcessedState.noSelectedData;
                                } else {
                                  curModAddProcessedStatus.value = ModAddProcessedState.dataInList;
                                }
                                setState(() {});
                              },
                              icon: Icon(modAddingList[i].aItemAddingStates[0] ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                                  color: modAddingList[i].aItemAddingStates[0] ? Colors.green : Colors.red),
                              visualDensity: VisualDensity.adaptivePlatformDensity),
                          IconButton(
                              onPressed: () async {
                                if (modAddingList[i].modDir.existsSync()) {
                                  await modAddingList[i].modDir.delete(recursive: true);
                                }
                                if (Directory(modAddingList[i].modDir.parent.path).existsSync() && Directory(modAddingList[i].modDir.parent.path).listSync().isEmpty) {
                                  Directory(modAddingList[i].modDir.parent.path).deleteSync();
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
            visible: curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting ||
                curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData ||
                curModAddProcessedStatus.watch(context) == ModAddProcessedState.addingToMasterList,
            child: Center(
                child: Column(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200, minHeight: 200),
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
                        if (curModAddProcessedStatus.watch(context) == ModAddProcessedState.addingToMasterList)
                          LoadingAnimationWidget.waveDots(
                            color: Theme.of(context).colorScheme.primary,
                            size: 100,
                          ),
                        Text(
                          curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting
                              ? appText.waitingForItems
                              : curModAddProcessedStatus.watch(context) == ModAddProcessedState.addingToMasterList
                                  ? appText.addingMods
                                  : appText.processingItems,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                    visible: modAddProcessingStatus.watch(context).isNotEmpty &&
                        (curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData || curModAddProcessedStatus.watch(context) == ModAddProcessedState.addingToMasterList),
                    child: CardOverlay(paddingValue: 15, child: Text(modAddProcessingStatus.watch(context))))
              ],
            )))
      ],
    );
  }
}
