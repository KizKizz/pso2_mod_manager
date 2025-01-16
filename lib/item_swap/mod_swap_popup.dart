import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_grid_layout.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_motions_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_type_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modSwapPopup(context, Item item, Mod mod, SubMod submod) async {
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();
  Signal<ItemData?> lSelectedItemData = Signal<ItemData?>(null);
  Signal<ItemData?> rSelectedItemData = Signal<ItemData?>(null);
  Signal<bool> showNoNameItems = Signal(false);
  List<ItemData> rDisplayingItemsExtra = [];
  String extraCategory = '';
  List<ItemData> displayingItems = [];
  List<ItemData> lDisplayingItems = [];

  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          displayingItems = pItemData
              .where((e) => showNoNameItems.watch(context) || (!showNoNameItems.watch(context) && e.getName().isNotEmpty))
              .where((e) => submod.category == defaultCategoryDirs[1]
                  ? e.subCategory == 'Basewear'
                  : submod.category == defaultCategoryDirs[16]
                      ? e.subCategory == 'Setwear'
                      : submod.category == defaultCategoryDirs[14]
                          ? e.category == submod.category &&
                              (e.subCategory == selectedItemSwapMotionType.watch(context) || selectedItemSwapMotionType.watch(context) == appText.all)
                          : e.category == submod.category)
              .where((e) => selectedItemSwapTypeCategory.watch(context) == appText.both || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
              .toList();
          displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));

          // Extra item data
          if (extraCategory.isNotEmpty && extraCategory == submod.category) {
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
                .where((e) => selectedItemSwapTypeCategory.watch(context) == appText.both || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
                .toList();
            rDisplayingItemsExtra.sort((a, b) => a.getName().compareTo(b.getName()));
          } else {
            extraCategory = '';
            rDisplayingItemsExtra = [];
          }

          // Data from mod
          lDisplayingItems = pItemData.where((e) => e.category == submod.category && submod.getModFileNames().indexWhere((f) => e.getIceDetailsWithoutKeys().contains(f)) != -1).toList();

          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
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
                        height: 40,
                        child: OutlinedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                            onPressed: () {
                              showNoNameItems.watch(context) ? showNoNameItems.value = false : showNoNameItems.value = true;
                            },
                            child: Text(showNoNameItems.watch(context) ? appText.hideNoNameItems : appText.showNoNameItems)),
                      )),
                      Visibility(
                          visible: submod.category == defaultCategoryDirs[14],
                          child: Expanded(child: ItemSwapMotionTypeSelectButtons(lScrollController: lScrollController, rScrollController: rScrollController))),
                      Expanded(child: Padding(padding: const EdgeInsets.only(top: 1), child: ItemSwapTypeSelectButtons(lScrollController: lScrollController, rScrollController: rScrollController))),
                    ],
                  ),
                  Expanded(
                      child: Row(
                    spacing: 5,
                    children: [
                      Expanded(
                          child: ItemSwapGridLayout(
                        itemDataList: lDisplayingItems,
                        scrollController: lScrollController,
                        selectedItemData: lSelectedItemData,
                      )),
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
                          visible: submod.category == defaultCategoryDirs[1] ||
                              submod.category == defaultCategoryDirs[2] ||
                              submod.category == defaultCategoryDirs[7] ||
                              submod.category == defaultCategoryDirs[11] ||
                              submod.category == defaultCategoryDirs[16],
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  extraCategory.isEmpty ? extraCategory = submod.category : extraCategory = '';
                                  submod.category == defaultCategoryDirs[11] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                  rScrollController.jumpTo(0);
                                });
                              },
                              child: submod.category == defaultCategoryDirs[1]
                                  ? Text(extraCategory == defaultCategoryDirs[1] ? appText.swapToBasewears : appText.swapToSetwears)
                                  : submod.category == defaultCategoryDirs[2]
                                      ? Text(extraCategory == defaultCategoryDirs[2] ? appText.swapToBodyPaints : appText.swapToInnerwears)
                                      : submod.category == defaultCategoryDirs[7]
                                          ? Text(extraCategory == defaultCategoryDirs[7] ? appText.swapToEmotes : appText.swapToIdleMotions)
                                          : submod.category == defaultCategoryDirs[11]
                                              ? Text(extraCategory == defaultCategoryDirs[11] ? appText.swapToInnerwears : appText.swapToBodyPaints)
                                              : submod.category == defaultCategoryDirs[16]
                                                  ? Text(extraCategory == defaultCategoryDirs[16] ? appText.swapToSetwears : appText.swapToBasewears)
                                                  : null)),
                    ],
                  ),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      OutlinedButton(
                          onPressed: lSelectedItemData.watch(context) != null && rSelectedItemData.watch(context) != null
                              ? () {
                                  itemSwapWorkingStatus.value = '';
                                  itemSwapWorkingPopup(context, false, lSelectedItemData.value!, rSelectedItemData.value!, mod, submod);
                                }
                              : null,
                          child: Text(appText.next)),
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
