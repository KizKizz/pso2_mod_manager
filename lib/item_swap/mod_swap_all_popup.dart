import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_grid_layout.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_all_motions_select_button.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_all_type_select_button.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_all_working_popup.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modSwapAllPopup(context, Item item, Mod mod) async {
  ScrollController rScrollController = ScrollController();
  Signal<ItemData?> lSelectedItemData = Signal<ItemData?>(null);
  Signal<ItemData?> rSelectedItemData = Signal<ItemData?>(null);
  Signal<bool> showNoNameItems = Signal(false);
  List<ItemData> rDisplayingItemsExtra = [];
  String extraCategory = '';
  List<ItemData> displayingItems = [];
  // List<ItemData> lDisplayingItems = [];

  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          displayingItems = pItemData
              .where((e) => showNoNameItems.watch(context) || (!showNoNameItems.watch(context) && e.getName().isNotEmpty))
              .where((e) => mod.category == defaultCategoryDirs[1]
                  ? e.subCategory == 'Basewear'
                  : mod.category == defaultCategoryDirs[16]
                      ? e.subCategory == 'Setwear'
                      : mod.category == defaultCategoryDirs[14]
                          ? e.category == mod.category && (e.subCategory == selectedModSwapAllMotionType.watch(context) || selectedModSwapAllMotionType.watch(context) == appText.all)
                          : e.category == mod.category)
              .where((e) => selectedModSwapAllTypeCategory.watch(context) == appText.both || e.itemType.toLowerCase().split(' | ').first == selectedModSwapAllTypeCategory.watch(context).toLowerCase())
              .toList();
          displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));

          // Extra item data
          if (extraCategory.isNotEmpty && extraCategory == mod.category) {
            rDisplayingItemsExtra = pItemData
                .where((e) => showNoNameItems.watch(context) || (!showNoNameItems.watch(context) && e.getName().isNotEmpty))
                .where((e) => extraCategory == defaultCategoryDirs[7]
                    ? (e.category == defaultCategoryDirs[14] && e.subCategory == 'Standby Motion')
                    : extraCategory == defaultCategoryDirs[1]
                        ? e.subCategory == 'Setwear'
                        : extraCategory == defaultCategoryDirs[16]
                            ? e.subCategory == 'Basewear'
                            : extraCategory == defaultCategoryDirs[2]
                                ? e.category == defaultCategoryDirs[11]
                                : extraCategory == defaultCategoryDirs[11]
                                    ? e.category == defaultCategoryDirs[2]
                                    : true)
                .where(
                    (e) => selectedModSwapAllTypeCategory.watch(context) == appText.both || e.itemType.toLowerCase().split(' | ').first == selectedModSwapAllTypeCategory.watch(context).toLowerCase())
                .toList();
            rDisplayingItemsExtra.sort((a, b) => a.getName().compareTo(b.getName()));
          } else {
            extraCategory = '';
            rDisplayingItemsExtra = [];
          }

          // Data from mod
          // lDisplayingItems = pItemData.where((e) => e.category == mod.category && submod.getModFileNames().indexWhere((f) => e.getIceDetailsWithoutKeys().contains(f)) != -1).toList();

          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.only(top: 25),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                spacing: 5,
                children: [
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: SizedBox(
                        height: 30,
                        child: OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context))),
                                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                            onPressed: () {
                              showNoNameItems.watch(context) ? showNoNameItems.value = false : showNoNameItems.value = true;
                            },
                            child: Text(showNoNameItems.watch(context) ? appText.hideNoNameItems : appText.showNoNameItems)),
                      )),
                      Visibility(visible: mod.category == defaultCategoryDirs[14], child: Expanded(child: ModSwapAllMotionsSelectButton(rScrollController: rScrollController))),
                      Expanded(child: Padding(padding: const EdgeInsets.only(top: 1), child: ModSwapAllTypeSelectButton(rScrollController: rScrollController))),
                    ],
                  ),
                  Expanded(
                      child: ItemSwapGridLayout(
                    itemDataList: extraCategory == defaultCategoryDirs[1] ||
                            extraCategory == defaultCategoryDirs[2] ||
                            extraCategory == defaultCategoryDirs[7] ||
                            extraCategory == defaultCategoryDirs[11] ||
                            extraCategory == defaultCategoryDirs[16]
                        ? rDisplayingItemsExtra
                        : displayingItems,
                    scrollController: rScrollController,
                    selectedItemData: rSelectedItemData,
                  )),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              side: WidgetStatePropertyAll(
                                  BorderSide(color: replaceLQTexturesWithHQ ? Theme.of(context).colorScheme.primary : Colors.transparent, width: replaceLQTexturesWithHQ ? 2 : 0))),
                          onPressed: () {
                            setState(() {
                              replaceLQTexturesWithHQ ? replaceLQTexturesWithHQ = false : replaceLQTexturesWithHQ = true;
                            });
                          },
                          child: Text(appText.replaceLQTexturesWithHQ)),
                      Visibility(
                          visible: mod.category == defaultCategoryDirs[1] ||
                              mod.category == defaultCategoryDirs[2] ||
                              mod.category == defaultCategoryDirs[7] ||
                              mod.category == defaultCategoryDirs[11] ||
                              mod.category == defaultCategoryDirs[16],
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  extraCategory.isEmpty ? extraCategory = mod.category : extraCategory = '';
                                  mod.category == defaultCategoryDirs[11] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                  rScrollController.jumpTo(0);
                                });
                              },
                              child: mod.category == defaultCategoryDirs[1]
                                  ? Text(extraCategory == defaultCategoryDirs[1] ? appText.swapToBasewears : appText.swapToSetwears)
                                  : mod.category == defaultCategoryDirs[2]
                                      ? Text(extraCategory == defaultCategoryDirs[2] ? appText.swapToBodyPaints : appText.swapToInnerwears)
                                      : mod.category == defaultCategoryDirs[7]
                                          ? Text(extraCategory == defaultCategoryDirs[7] ? appText.swapToEmotes : appText.swapToIdleMotions)
                                          : mod.category == defaultCategoryDirs[11]
                                              ? Text(extraCategory == defaultCategoryDirs[11] ? appText.swapToInnerwears : appText.swapToBodyPaints)
                                              : mod.category == defaultCategoryDirs[16]
                                                  ? Text(extraCategory == defaultCategoryDirs[16] ? appText.swapToSetwears : appText.swapToBasewears)
                                                  : null)),
                    ],
                  ),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      OutlinedButton(
                          onPressed: rSelectedItemData.watch(context) != null
                              ? () async {
                                  itemSwapWorkingStatus.value = '';
                                  for (var submod in mod.submods) {
                                    final matchingItemData =
                                        pItemData.where((e) => submod.getModFileNames().indexWhere((f) => e.getIceDetailsWithoutKeys().contains(f)) != -1).toList();
                                    if (matchingItemData.length == 1) {
                                      lSelectedItemData.value = matchingItemData.first;
                                    } else if (matchingItemData.length > 1) {
                                      int matchingIndex = matchingItemData.indexWhere((e) => e.getENName() == item.itemName || e.getJPName() == item.itemName);
                                      matchingIndex != -1 ? lSelectedItemData.value = matchingItemData[matchingIndex] : lSelectedItemData.value = matchingItemData.first;
                                    } else {
                                      lSelectedItemData.value = null;
                                    }

                                    if (lSelectedItemData.value != null) {
                                      await modSwapAllWorkingPopup(context, false, lSelectedItemData.value!, rSelectedItemData.value!, mod, submod);
                                    } else {
                                      errorNotification(appText.noMatchingFilesBetweenItemsToSwap);
                                    }
                                  }
                                }
                              : null,
                          child: Text(appText.swapAll)),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(appText.returns))
                    ],
                  )
                ],
              )
            ],
          );
        });
      });
}
