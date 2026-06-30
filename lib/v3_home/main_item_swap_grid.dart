import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/emote_queue_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_grid_layout.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

bool replaceLQTexturesWithHQ = false;

// bool emoteToIdleMotion = false;
// bool idleMotionToEmote = false;

class MainItemSwapGrid extends SignalStatefulWidget {
  const MainItemSwapGrid({super.key});

  @override
  State<MainItemSwapGrid> createState() => _MainItemSwapGridState();
}

class _MainItemSwapGridState extends State<MainItemSwapGrid> {
  double fadeInOpacity = 0;
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();
  Signal<ItemData?> lSelectedItemData = Signal<ItemData?>(null);
  Signal<ItemData?> rSelectedItemData = Signal<ItemData?>(null);
  Signal<bool> showNoNameItems = Signal(false);
  List<ItemData> rDisplayingItemsExtra = [];
  String extraCategory = '';
  List<ItemData> displayingItems = [];
  List<(ItemData, ItemData)> emoteSwapQueue = [];
  bool showEmoteQueue = false;
  ItemData? lastQueuedEmoteItemData;
  ItemCrossSwap itemCrossSwap = ItemCrossSwap.none;
  bool showEffectOnlyAccs = false;
  bool showEffectOnlyAccsSignal = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    displayingItems = pItemData
        .where((e) => showNoNameItems.value || (!showNoNameItems.value && e.getName().isNotEmpty))
        .where(
          (e) => selectedDisplayItemSwapCategory.value == defaultCategoryDirs[1]
              ? e.subCategory == 'Basewear'
              : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[16]
              ? e.subCategory == 'Setwear'
              : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[14]
              ? e.category == selectedDisplayItemSwapCategory.value && (e.subCategory == selectedItemSwapMotionType.value || selectedItemSwapMotionType.value == 'All')
              : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[17]
              ? e.category == defaultCategoryDirs[17] && (e.subCategory.contains(selectedWeaponType.value) || selectedWeaponType.value == 'All')
              : e.category == selectedDisplayItemSwapCategory.value,
        )
        .where((e) => selectedItemSwapTypeCategory.value == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.value.toLowerCase())
        .toList();
    displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));

    // Extra item data
    if (extraCategory.isNotEmpty && extraCategory == selectedDisplayItemSwapCategory.value) {
      rDisplayingItemsExtra = pItemData
          .where((e) => showNoNameItems.value || (!showNoNameItems.value && e.getName().isNotEmpty))
          .where(
            (e) => extraCategory == defaultCategoryDirs[7]
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
                : true,
          )
          .where((e) => selectedItemSwapTypeCategory.value == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.value.toLowerCase())
          .toList();
      rDisplayingItemsExtra.sort((a, b) => a.getName().compareTo(b.getName()));
    } else {
      extraCategory = '';
      rDisplayingItemsExtra = [];
    }

    if (lSelectedItemData.value != null && lSelectedItemData.value!.category == defaultCategoryDirs[0] && lSelectedItemData.value!.accessoryContainsEffects() && !showEffectOnlyAccsSignal) {
      showEffectOnlyAccs = true;
    } else if (lSelectedItemData.value != null && lSelectedItemData.value!.category == defaultCategoryDirs[0] && !lSelectedItemData.value!.accessoryContainsEffects() && !showEffectOnlyAccsSignal) {
      showEffectOnlyAccs = false;
    } else if (showEffectOnlyAccsSignal) {
      showEffectOnlyAccsSignal = false;
    }

    return AnimatedOpacity(
      opacity: fadeInOpacity,
      duration: const Duration(milliseconds: 100),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.value)),
                      side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5)),
                    ),
                    onPressed: () {
                      showNoNameItems.value ? showNoNameItems.value = false : showNoNameItems.value = true;
                    },
                    child: Text(showNoNameItems.value ? appText.hideNoNameItems : appText.showNoNameItems),
                  ),
                ),
              ),
              if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[14])
                Expanded(
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
                    },
                  ),
                ),
              if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[17])
                Expanded(
                  child: SingleChoiceSelectButton(
                    width: double.infinity,
                    height: 30,
                    label: appText.weaponTypes,
                    selectPopupLabel: appText.weaponTypes,
                    availableItemList: defaultWeaponTypes,
                    availableItemLabels: defaultWeaponTypes.map((e) => appText.weaponTypeName(e)).toList(),
                    selectedItemsLabel: defaultWeaponTypes.map((e) => appText.weaponTypeName(e)).toList(),
                    selectedItem: selectedWeaponType,
                    extraWidgets: [],
                    savePref: () {
                      lScrollController.jumpTo(0);
                      rScrollController.jumpTo(0);
                      lSelectedItemData.value = null;
                      rSelectedItemData.value = null;
                    },
                  ),
                ),
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
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: SingleChoiceSelectButton(
                    width: double.infinity,
                    height: 30,
                    label: appText.view,
                    selectPopupLabel: appText.view,
                    availableItemList: defaultCategoryDirs,
                    availableItemLabels: defaultCategoryDirs.map((e) => appText.categoryName(e)).toList(),
                    selectedItemsLabel: defaultCategoryDirs.map((e) => appText.categoryName(e)).toList(),
                    selectedItem: selectedDisplayItemSwapCategory,
                    extraWidgets: [],
                    savePref: () {
                      lScrollController.jumpTo(0);
                      rScrollController.jumpTo(0);
                      lSelectedItemData.value = null;
                      rSelectedItemData.value = null;
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              spacing: 5,
              children: [
                Expanded(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      ItemSwapGridLayout(
                        itemDataList: emoteSwapQueue.isEmpty
                            ? displayingItems
                            : displayingItems.where((e) => e.category == emoteSwapQueue.first.$1.category && e.getName() == emoteSwapQueue.first.$1.getName()).toList(),
                        scrollController: lScrollController,
                        selectedItemData: lSelectedItemData,
                        emoteSwapQueue: emoteSwapQueue,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35, right: 5),
                        child: Text(appText.mainItems, style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(170))),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Stack(
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            ItemSwapGridLayout(
                              itemDataList:
                                  extraCategory == defaultCategoryDirs[1] ||
                                      extraCategory == defaultCategoryDirs[2] ||
                                      extraCategory == defaultCategoryDirs[7] ||
                                      extraCategory == defaultCategoryDirs[11] ||
                                      extraCategory == defaultCategoryDirs[14] ||
                                      extraCategory == defaultCategoryDirs[16]
                                  ? rDisplayingItemsExtra
                                  : showEffectOnlyAccs
                                  ? displayingItems.where((e) => e.accessoryContainsEffects()).toList()
                                  : displayingItems,
                              scrollController: rScrollController,
                              selectedItemData: rSelectedItemData,
                              emoteSwapQueue: emoteSwapQueue,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 35, right: 5),
                              child: Text(appText.itemsToBeReplacedByMainItems, style: TextStyle(color: Theme.of(context).colorScheme.primary.withAlpha(170))),
                            ),
                          ],
                        ),
                      ),

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
                                    selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.value),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // left data
                                        ModManTooltip(
                                          message: emoteSwapQueue[index].$1.getDetails().map((e) => e).join('\n'),
                                          child: Row(
                                            spacing: 5,
                                            children: [
                                              GenericItemIconBox(iconImagePaths: [emoteSwapQueue[index].$1.iconImagePath], boxSize: const Size(35, 35), isNetwork: true),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(emoteSwapQueue[index].$1.getName(), style: const TextStyle(fontWeight: FontWeight.w500)),
                                                  Text(emoteSwapQueue[index].$1.getEmoteGender(), style: const TextStyle(fontSize: 13)),
                                                ],
                                              ),
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
                                                  Text(emoteSwapQueue[index].$2.getName(), style: const TextStyle(fontWeight: FontWeight.w500)),
                                                  Text(emoteSwapQueue[index].$2.getEmoteGender(), style: const TextStyle(fontSize: 13)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    leading: IconButton(
                                      onPressed: () {
                                        emoteSwapQueue.removeAt(index);
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(height: 5),
                              itemCount: emoteSwapQueue.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      side: WidgetStatePropertyAll(BorderSide(color: replaceLQTexturesWithHQ ? Theme.of(context).colorScheme.primary : Colors.transparent, width: replaceLQTexturesWithHQ ? 2 : 0)),
                    ),
                    onPressed: () {
                      setState(() {
                        replaceLQTexturesWithHQ ? replaceLQTexturesWithHQ = false : replaceLQTexturesWithHQ = true;
                      });
                    },
                    child: Text(appText.replaceLQTexturesWithHQ),
                  ),

                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[0])
                    ElevatedButton(
                      onPressed: () {
                        showEffectOnlyAccsSignal = true;
                        showEffectOnlyAccs ? showEffectOnlyAccs = false : showEffectOnlyAccs = true;
                        setState(() {});
                      },
                      child: Text(showEffectOnlyAccs ? appText.showAll : appText.showEffectAccessories),
                    ),

                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[1] ||
                      selectedDisplayItemSwapCategory.value == defaultCategoryDirs[2] ||
                      selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7] ||
                      selectedDisplayItemSwapCategory.value == defaultCategoryDirs[11] ||
                      selectedDisplayItemSwapCategory.value == defaultCategoryDirs[14] && lSelectedItemData.value != null && lSelectedItemData.value!.subCategory == 'Standby Motion' ||
                      selectedDisplayItemSwapCategory.value == defaultCategoryDirs[16])
                    ElevatedButton(
                      onPressed: selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7] && emoteSwapQueue.isNotEmpty
                          ? null
                          : () {
                              setState(() {
                                extraCategory.isEmpty ? extraCategory = selectedDisplayItemSwapCategory.value : extraCategory = '';
                                // extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                                // extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
                                extraCategory == defaultCategoryDirs[2]
                                    ? itemCrossSwap = ItemCrossSwap.bodyPaintToInnerwear
                                    : extraCategory == defaultCategoryDirs[11]
                                    ? itemCrossSwap = ItemCrossSwap.innerwearToBodyPaint
                                    : extraCategory == defaultCategoryDirs[7]
                                    ? itemCrossSwap = ItemCrossSwap.emoteToIdleMotion
                                    : extraCategory == defaultCategoryDirs[14]
                                    ? itemCrossSwap = ItemCrossSwap.idleMotionToEmote
                                    : itemCrossSwap = ItemCrossSwap.none;
                                rScrollController.jumpTo(0);
                              });
                            },
                      child: selectedDisplayItemSwapCategory.value == defaultCategoryDirs[1]
                          ? Text(extraCategory == defaultCategoryDirs[1] ? appText.swapToBasewears : appText.swapToSetwears)
                          : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[2]
                          ? Text(extraCategory == defaultCategoryDirs[2] ? appText.swapToBodyPaints : appText.swapToInnerwears)
                          : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7]
                          ? Text(extraCategory == defaultCategoryDirs[7] ? appText.swapToEmotes : appText.swapToIdleMotions)
                          : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[11]
                          ? Text(extraCategory == defaultCategoryDirs[11] ? appText.swapToInnerwears : appText.swapToBodyPaints)
                          : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[14]
                          ? Text(extraCategory == defaultCategoryDirs[14] ? appText.swapToMotions : appText.swapIdleMotionsToEmotes)
                          : selectedDisplayItemSwapCategory.value == defaultCategoryDirs[16]
                          ? Text(extraCategory == defaultCategoryDirs[16] ? appText.swapToSetwears : appText.swapToBasewears)
                          : null,
                    ),
                ],
              ),
              Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7])
                    ElevatedButton(
                      onPressed: () {
                        showEmoteQueue ? showEmoteQueue = false : showEmoteQueue = true;
                        setState(() {});
                      },
                      child: Text(showEmoteQueue ? appText.hideQueue : appText.viewQueue),
                    ),
                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7])
                    ElevatedButton(
                      onPressed: emoteSwapQueue.isNotEmpty
                          ? () {
                              emoteSwapQueue.clear();
                              setState(() {});
                            }
                          : null,
                      child: Text(appText.clearAll),
                    ),
                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7])
                    ElevatedButton(
                      onPressed: lSelectedItemData.value != null && rSelectedItemData.value != null
                          ? () async {
                              if (emoteSwapQueue.indexWhere((e) => e.$1 == lSelectedItemData.value) == -1) {
                                emoteSwapQueue.add((lSelectedItemData.value!, rSelectedItemData.value!));
                                lastQueuedEmoteItemData = lSelectedItemData.value!;
                                lSelectedItemData.value = null;
                                rSelectedItemData.value = null;
                                if (emoteSwapQueue.isNotEmpty) showEmoteQueue = true;
                                setState(() {});
                              }
                            }
                          : null,
                      child: Text(appText.addToQueue),
                    ),
                  if (selectedDisplayItemSwapCategory.value == defaultCategoryDirs[7])
                    ElevatedButton(
                      onPressed: emoteSwapQueue.isNotEmpty
                          ? () async {
                              itemSwapWorkingStatus.value = '';
                              // extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                              // extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
                              await emoteQueueSwapWorkingPopup(context, true, emoteSwapQueue, lItemModGet(), lItemSubmodGet(lastQueuedEmoteItemData!), itemCrossSwap);
                            }
                          : null,
                      child: Text(appText.next),
                    ),
                  if (selectedDisplayItemSwapCategory.value != defaultCategoryDirs[7])
                    ElevatedButton(
                      onPressed: lSelectedItemData.value != null && rSelectedItemData.value != null
                          ? () {
                              itemSwapWorkingStatus.value = '';
                              // extraCategory == defaultCategoryDirs[7] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                              // extraCategory == defaultCategoryDirs[14] ? idleMotionToEmote = true : idleMotionToEmote = false;
                              itemSwapWorkingPopup(context, true, lSelectedItemData.value!, rSelectedItemData.value!, lItemModGet(), lItemSubmodGet(lSelectedItemData.value!), itemCrossSwap);
                            }
                          : null,
                      child: Text(appText.next),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
