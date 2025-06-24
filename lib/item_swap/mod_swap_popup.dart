import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/emote_queue_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_grid_layout.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_grid_layout.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_item_swap_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
  List<(ItemData, ItemData)> emoteSwapQueue = [];
  bool showEmoteQueue = false;

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
                          ? e.category == submod.category && (e.subCategory == selectedItemSwapMotionType.watch(context) || selectedItemSwapMotionType.watch(context) == appText.all)
                          : e.category == submod.category)
              .where((e) => selectedItemSwapTypeCategory.watch(context) == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
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
                                    : extraCategory == defaultCategoryDirs[14]
                                        ? e.category == defaultCategoryDirs[7]
                                        : true)
                .where((e) => selectedItemSwapTypeCategory.watch(context) == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
                .toList();
            rDisplayingItemsExtra.sort((a, b) => a.getName().compareTo(b.getName()));
          } else {
            extraCategory = '';
            rDisplayingItemsExtra = [];
          }

          // Data from mod
          lDisplayingItems = qualityFilterCategoryDirs.contains(submod.category)
              ? pItemData
                  .where((e) =>
                      (e.category == submod.category || submod.category.contains(e.subCategory)) &&
                      submod.getModFileNames().indexWhere((f) => e.getHQIceName().contains(f) || e.getLQIceName().contains(f)) != -1)
                  .toList()
              : pItemData
                  .where(
                      (e) => (e.category == submod.category || submod.category.contains(e.subCategory)) && submod.getModFileNames().indexWhere((f) => e.getIceDetailsWithoutKeys().contains(f)) != -1)
                  .toList();

          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: EdgeInsets.zero,
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
                      Visibility(
                          visible: submod.category == defaultCategoryDirs[14],
                          child: Expanded(
                              child: SingleChoiceSelectButton(
                                  width: double.infinity,
                                  height: 30,
                                  label: appText.motions,
                                  selectPopupLabel: appText.motions,
                                  availableItemList: defaultMotionTypes,
                                  availableItemLabels: defaultMotionTypes.map((e) => appText.motionTypeName(e)).toList(),
                                  selectedItemsLabel: defaultMotionTypes.map((e) => appText.motionTypeName(e)).toList(),
                                  selectedItem: selectedItemSwapMotionType,
                                  extraWidgets: [],
                                  savePref: () {
                                    lScrollController.jumpTo(0);
                                    rScrollController.jumpTo(0);
                                  }))),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: SingleChoiceSelectButton(
                            width: double.infinity,
                            height: 30,
                            label: appText.types,
                            selectPopupLabel: appText.types,
                            availableItemList: itemTypes,
                            availableItemLabels: itemTypes.map((e) => appText.itemTypeName(e)).toList(),
                            selectedItemsLabel: itemTypes.map((e) => appText.itemTypeName(e)).toList(),
                            selectedItem: selectedItemSwapTypeCategory,
                            extraWidgets: [],
                            savePref: () {
                              lScrollController.jumpTo(0);
                              rScrollController.jumpTo(0);
                            }),
                      )),
                    ],
                  ),
                  Expanded(
                      child: Row(
                    spacing: 5,
                    children: [
                      Expanded(
                          child: Column(
                        spacing: 5,
                        children: [
                          Expanded(
                              child: ModSwapGridLayout(
                            itemDataList: lDisplayingItems,
                            submod: submod,
                            scrollController: lScrollController,
                            selectedItemData: lSelectedItemData,
                            emoteSwapQueue: emoteSwapQueue,
                          )),
                          Row(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 300, height: 170, child: SubmodPreviewBox(imageFilePaths: submod.previewImages, videoFilePaths: submod.previewVideos, isNew: submod.isNew)),
                              Expanded(
                                child: Column(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(submod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
                                    Text(submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        spacing: 5,
                        children: [
                          Expanded(
                              flex: 2,
                              child: ItemSwapGridLayout(
                                itemDataList: extraCategory == defaultCategoryDirs[1] ||
                                        extraCategory == defaultCategoryDirs[2] ||
                                        extraCategory == defaultCategoryDirs[7] ||
                                        extraCategory == defaultCategoryDirs[11] ||
                                        extraCategory == defaultCategoryDirs[14] ||
                                        extraCategory == defaultCategoryDirs[16]
                                    ? rDisplayingItemsExtra
                                    : displayingItems,
                                scrollController: rScrollController,
                                selectedItemData: rSelectedItemData,
                                emoteSwapQueue: emoteSwapQueue,
                              )),

                          // emote queue
                          if (showEmoteQueue)
                            Expanded(
                                child: CardOverlay(
                                    paddingValue: 5,
                                    child: SuperListView.separated(
                                        itemBuilder: (context, index) {
                                          return ListTileTheme(
                                              data: ListTileThemeData(
                                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                  minVerticalPadding: 1,
                                                  selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                              child: ListTile(
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    // left data
                                                    ModManTooltip(
                                                      message: emoteSwapQueue[index].$1.getModSwapDetails(submod).map((e) => e).join('\n'),
                                                      child: Row(
                                                        spacing: 5,
                                                        children: [
                                                          GenericItemIconBox(iconImagePaths: [emoteSwapQueue[index].$1.iconImagePath], boxSize: const Size(35, 35), isNetwork: true),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                emoteSwapQueue[index].$1.getName(),
                                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                emoteSwapQueue[index].$1.getEmoteGender(),
                                                                style: const TextStyle(fontSize: 13),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    // right data
                                                    const Icon(Icons.arrow_forward_outlined),
                                                    ModManTooltip(
                                                      message: emoteSwapQueue[index].$2.getDetails().map((e) => e).join('\n'),
                                                      child: Row(
                                                        spacing: 5,
                                                        children: [
                                                          GenericItemIconBox(iconImagePaths: [emoteSwapQueue[index].$2.iconImagePath], boxSize: const Size(35, 35), isNetwork: true),
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                emoteSwapQueue[index].$2.getName(),
                                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                                              ),
                                                              Text(
                                                                emoteSwapQueue[index].$2.getEmoteGender(),
                                                                style: const TextStyle(fontSize: 13),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                leading: IconButton(
                                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                                    onPressed: () {
                                                      emoteSwapQueue.removeAt(index);
                                                      setState(
                                                        () {},
                                                      );
                                                    },
                                                    icon: const Icon(Icons.close)),
                                              ));
                                        },
                                        separatorBuilder: (context, index) => const SizedBox(height: 1),
                                        itemCount: emoteSwapQueue.length)))
                        ],
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
                              submod.category == defaultCategoryDirs[14] && item.subCategory! == 'Standby Motion' ||
                              submod.category == defaultCategoryDirs[16],
                          child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  extraCategory.isEmpty ? extraCategory = submod.category : extraCategory = '';
                                  extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                  extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
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
                                              : submod.category == defaultCategoryDirs[14]
                                                  ? Text(extraCategory == defaultCategoryDirs[14] ? appText.swapToMotions : appText.swapToEmotes)
                                                  : submod.category == defaultCategoryDirs[16]
                                                      ? Text(extraCategory == defaultCategoryDirs[16] ? appText.swapToSetwears : appText.swapToBasewears)
                                                      : null)),
                    ],
                  ),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      if (submod.category == defaultCategoryDirs[7] && lDisplayingItems.length > 1)
                        OutlinedButton(
                            onPressed: () {
                              showEmoteQueue ? showEmoteQueue = false : showEmoteQueue = true;
                              setState(
                                () {},
                              );
                            },
                            child: Text(showEmoteQueue ? appText.hideQueue : appText.viewQueue)),
                      if (submod.category == defaultCategoryDirs[7] && lDisplayingItems.length > 1)
                        OutlinedButton(
                            onPressed: emoteSwapQueue.isNotEmpty
                                ? () {
                                    emoteSwapQueue.clear();
                                    setState(
                                      () {},
                                    );
                                  }
                                : null,
                            child: Text(appText.clearAll)),
                      if (submod.category == defaultCategoryDirs[7] && lDisplayingItems.length > 1)
                        OutlinedButton(
                            onPressed: lSelectedItemData.watch(context) != null && rSelectedItemData.watch(context) != null
                                ? () async {
                                    if (emoteSwapQueue.indexWhere((e) => e.$1 == lSelectedItemData.value) == -1) {
                                      emoteSwapQueue.add((lSelectedItemData.value!, rSelectedItemData.value!));
                                      lSelectedItemData.value = null;
                                      rSelectedItemData.value = null;
                                      if (emoteSwapQueue.isNotEmpty) showEmoteQueue = true;
                                      setState(
                                        () {},
                                      );
                                    }
                                  }
                                : null,
                            child: Text(appText.addToQueue)),
                      if (submod.category == defaultCategoryDirs[7] && lDisplayingItems.length > 1)
                        OutlinedButton(
                            onPressed: emoteSwapQueue.isNotEmpty
                                ? () async {
                                    itemSwapWorkingStatus.value = '';
                                    extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                    extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
                                    await emoteQueueSwapWorkingPopup(context, false, emoteSwapQueue, mod, submod);
                                  }
                                : null,
                            child: Text(appText.next)),
                      if (submod.category != defaultCategoryDirs[7] || submod.category == defaultCategoryDirs[7] && lDisplayingItems.length == 1)
                        OutlinedButton(
                            onPressed: lSelectedItemData.watch(context) != null && rSelectedItemData.watch(context) != null
                                ? () async {
                                    itemSwapWorkingStatus.value = '';
                                    extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                    extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
                                    await itemSwapWorkingPopup(context, false, lSelectedItemData.value!, rSelectedItemData.value!, mod, submod);
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
