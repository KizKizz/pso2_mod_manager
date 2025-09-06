// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_acc_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_emote_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_general_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

void quickSwapWorkingPopup(context, bool isVanillaSwap, ItemData lItemData, ItemData rItemData, Mod mod, SubMod submod) {
  Directory swapOutputDir = Directory('');
  bool taskWorking = false;

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          if (!taskWorking) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              taskWorking = true;
              swapOutputDir = Directory('');
              // Clean and create temp dirs
              await modSwapTempDirsRemove();
              await modSwapTempDirsCreate();
              if (submod.category == defaultCategoryDirs[0]) {
                swapOutputDir = await modSwapAccessories(context, isVanillaSwap, mod, submod, lItemData.getIceDetails(), rItemData.getIceDetails(), rItemData.getName(), rItemData.getItemID());
              } else if (submod.category == defaultCategoryDirs[14] || submod.category == defaultCategoryDirs[7]) {
                swapOutputDir = await modSwapEmotes(context, isVanillaSwap, mod, submod, rItemData.getName(), lItemData.getIceDetails(), rItemData.getIceDetails());
              } else {
                swapOutputDir =
                    await modSwapGeneral(context, isVanillaSwap, mod, submod, lItemData.getIceDetails(), rItemData.getIceDetails(), rItemData.getName(), lItemData.getItemID(), rItemData.getItemID());
              }
              if (swapOutputDir.existsSync()) {
                // Add to mod manager
                modAddDragDropPaths.add(swapOutputDir.path);
                await modAddUnpack(context, modAddDragDropPaths.toList());
                modAddDragDropPaths.clear();
                modAddingList = await modAddSort();
                List<Item> addedItems = await modAddToMasterList(false, []);
                // Apply
                Item applyItem = addedItems.firstWhere((e) => e.itemName == rItemData.getENName() || e.itemName == rItemData.getJPName());
                Mod applyMod = applyItem.mods.firstWhere((e) => e.modName == mod.modName);
                SubMod applySubmod = applyMod.submods.firstWhere((e) => e.submodName == submod.submodName);
                await modToGameData(context, true, applyItem, applyMod, applySubmod);
              }
              Navigator.of(context).pop();
              mainGridStatus.value = '"${submod.modName}" is swapped and applied';
              taskWorking = false;
            });
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                OverflowBar(
                  spacing: 5,
                  overflowSpacing: 5,
                  overflowAlignment: OverflowBarAlignment.center,
                  children: [
                    CardOverlay(
                        paddingValue: 10,
                        child: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GenericItemIconBox(iconImagePaths: [lItemData.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                            Text(appText.categoryName(lItemData.category), style: Theme.of(context).textTheme.titleMedium),
                            Text(lItemData.getName(), style: Theme.of(context).textTheme.titleLarge),
                            SingleChildScrollView(
                              physics: const SuperRangeMaintainingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: lItemData.getDetails().map((e) => Text(e)).toList(),
                              ),
                            )
                          ],
                        )),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: LoadingAnimationWidget.twoRotatingArc(
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    CardOverlay(
                        paddingValue: 10,
                        child: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GenericItemIconBox(iconImagePaths: [rItemData.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                            Text(appText.categoryName(rItemData.category), style: Theme.of(context).textTheme.titleMedium),
                            Text(rItemData.getName(), style: Theme.of(context).textTheme.titleLarge),
                            SingleChildScrollView(
                              physics: const SuperRangeMaintainingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: rItemData.getDetails().map((e) => Text(e)).toList(),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
                const Icon(Icons.arrow_downward_rounded, size: 30),
                CardOverlay(
                    paddingValue: 10,
                    child: Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenericItemIconBox(iconImagePaths: [lItemData.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                        Text(appText.categoryName(rItemData.category), style: Theme.of(context).textTheme.titleMedium),
                        Text(rItemData.getName(), style: Theme.of(context).textTheme.titleLarge),
                        Visibility(
                          visible: !isVanillaSwap,
                          child: Text(submod.submodName, style: Theme.of(context).textTheme.labelLarge),
                        )
                      ],
                    ))
              ],
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(itemSwapWorkingStatus.watch(context)),
                ],
              )
            ],
          );
        });
      });
}
