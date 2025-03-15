import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/emote_queue_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_cate_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_grid_layout.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_motions_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_type_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_weapon_type_select_button.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

bool replaceLQTexturesWithHQ = false;
bool emoteToIdleMotion = false;

class MainItemSwapGrid extends StatefulWidget {
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
        .where((e) => showNoNameItems.watch(context) || (!showNoNameItems.watch(context) && e.getName().isNotEmpty))
        .where((e) => selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[1]
            ? e.subCategory == 'Basewear'
            : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[16]
                ? e.subCategory == 'Setwear'
                : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[14]
                    ? e.category == selectedDisplayItemSwapCategory.watch(context) && (e.subCategory == selectedItemSwapMotionType.watch(context) || selectedItemSwapMotionType.watch(context) == 'All')
                    : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[17]
                        ? e.category == defaultCategoryDirs[17] && (e.subCategory.contains(selectedWeaponType.watch(context)) || selectedWeaponType.watch(context) == 'All')
                        : e.category == selectedDisplayItemSwapCategory.watch(context))
        .where((e) => selectedItemSwapTypeCategory.watch(context) == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
        .toList();
    displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));

    // Extra item data
    if (extraCategory.isNotEmpty && extraCategory == selectedDisplayItemSwapCategory.watch(context)) {
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
          .where((e) => selectedItemSwapTypeCategory.watch(context) == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
          .toList();
      rDisplayingItemsExtra.sort((a, b) => a.getName().compareTo(b.getName()));
    } else {
      extraCategory = '';
      rDisplayingItemsExtra = [];
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
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () {
                      showNoNameItems.watch(context) ? showNoNameItems.value = false : showNoNameItems.value = true;
                    },
                    child: Text(showNoNameItems.watch(context) ? appText.hideNoNameItems : appText.showNoNameItems)),
              )),
              Visibility(
                  visible: selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[14],
                  child: Expanded(child: ItemSwapMotionTypeSelectButtons(lScrollController: lScrollController, rScrollController: rScrollController))),
              Visibility(
                  visible: selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[17],
                  child: Expanded(
                      child: ItemSwapWeaponTypeSelectButton(
                          weaponTypeName: defaultWeaponTypes,
                          lSelectedItemData: lSelectedItemData,
                          rSelectedItemData: rSelectedItemData,
                          lScrollController: lScrollController,
                          rScrollController: rScrollController))),
              Expanded(child: Padding(padding: const EdgeInsets.only(top: 1), child: ItemSwapTypeSelectButtons(lScrollController: lScrollController, rScrollController: rScrollController))),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: ItemSwapCateSelectButtons(
                    categoryNames: defaultCategoryDirs,
                    lSelectedItemData: lSelectedItemData,
                    rSelectedItemData: rSelectedItemData,
                    lScrollController: lScrollController,
                    rScrollController: rScrollController),
              )),
            ],
          ),
          Expanded(
              child: Row(
            spacing: 5,
            children: [
              Expanded(
                  child: ItemSwapGridLayout(
                itemDataList: emoteSwapQueue.isEmpty
                    ? displayingItems
                    : displayingItems.where((e) => e.category == emoteSwapQueue.first.$1.category && e.getName() == emoteSwapQueue.first.$1.getName()).toList(),
                scrollController: lScrollController,
                selectedItemData: lSelectedItemData,
                emoteSwapQueue: emoteSwapQueue,
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
                                              message: emoteSwapQueue[index].$1.getDetails().map((e) => e).join('\n'),
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
                                            onPressed: () {
                                              emoteSwapQueue.removeAt(index);
                                              setState(
                                                () {},
                                              );
                                            },
                                            icon: const Icon(Icons.close)),
                                      ));
                                },
                                separatorBuilder: (context, index) => const SizedBox(height: 5),
                                itemCount: emoteSwapQueue.length)))
                ],
              )),
            ],
          )),
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
                          side:
                              WidgetStatePropertyAll(BorderSide(color: replaceLQTexturesWithHQ ? Theme.of(context).colorScheme.primary : Colors.transparent, width: replaceLQTexturesWithHQ ? 2 : 0))),
                      onPressed: () {
                        setState(() {
                          replaceLQTexturesWithHQ ? replaceLQTexturesWithHQ = false : replaceLQTexturesWithHQ = true;
                        });
                      },
                      child: Text(appText.replaceLQTexturesWithHQ)),
                  Visibility(
                      visible: selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[1] ||
                          selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[2] ||
                          selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7] ||
                          selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[11] ||
                          selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[16],
                      child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              extraCategory.isEmpty ? extraCategory = selectedDisplayItemSwapCategory.watch(context) : extraCategory = '';
                              selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[11] ? emoteToIdleMotion = true : emoteToIdleMotion = false;
                              rScrollController.jumpTo(0);
                            });
                          },
                          child: selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[1]
                              ? Text(extraCategory == defaultCategoryDirs[1] ? appText.swapToBasewears : appText.swapToSetwears)
                              : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[2]
                                  ? Text(extraCategory == defaultCategoryDirs[2] ? appText.swapToBodyPaints : appText.swapToInnerwears)
                                  : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7]
                                      ? Text(extraCategory == defaultCategoryDirs[7] ? appText.swapToEmotes : appText.swapToIdleMotions)
                                      : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[11]
                                          ? Text(extraCategory == defaultCategoryDirs[11] ? appText.swapToInnerwears : appText.swapToBodyPaints)
                                          : selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[16]
                                              ? Text(extraCategory == defaultCategoryDirs[16] ? appText.swapToSetwears : appText.swapToBasewears)
                                              : null)),
                ],
              ),
              Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7])
                    ElevatedButton(
                        onPressed: () {
                          showEmoteQueue ? showEmoteQueue = false : showEmoteQueue = true;
                          setState(
                            () {},
                          );
                        },
                        child: Text(showEmoteQueue ? appText.hideQueue : appText.viewQueue)),
                  if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7])
                    ElevatedButton(
                        onPressed: emoteSwapQueue.isNotEmpty
                            ? () {
                                emoteSwapQueue.clear();
                                setState(() {});
                              }
                            : null,
                        child: Text(appText.clearAll)),
                  if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7])
                    ElevatedButton(
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
                  if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7])
                    ElevatedButton(
                        onPressed: emoteSwapQueue.isNotEmpty
                            ? () async {
                                itemSwapWorkingStatus.value = '';
                                await emoteQueueSwapWorkingPopup(context, true, emoteSwapQueue, lItemModGet(), lItemSubmodGet(emoteSwapQueue.first.$1));
                              }
                            : null,
                        child: Text(appText.next)),
                  if (selectedDisplayItemSwapCategory.watch(context) != defaultCategoryDirs[7])
                    ElevatedButton(
                        onPressed: lSelectedItemData.watch(context) != null && rSelectedItemData.watch(context) != null
                            ? () {
                                itemSwapWorkingStatus.value = '';
                                itemSwapWorkingPopup(context, true, lSelectedItemData.value!, rSelectedItemData.value!, lItemModGet(), lItemSubmodGet(lSelectedItemData.value!));
                              }
                            : null,
                        child: Text(appText.next))
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
