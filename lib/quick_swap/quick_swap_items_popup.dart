import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/quick_swap/quick_swap_functions.dart';
import 'package:pso2_mod_manager/quick_swap/quick_swap_item_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<void> quickSwapItemsPopup(context, String category) async {
  List<ItemData> displayingItems = [];
  List<ItemData> selectedItems = [];
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();

  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          displayingItems = pItemData
              .where((e) =>
                  e.getName().isNotEmpty &&
                      (e.category == category ||
                          (category == defaultCategoryDirs[16] && e.category == defaultCategoryDirs[1]) ||
                          (category == defaultCategoryDirs[2] && e.category == defaultCategoryDirs[11])) ||
                  (category == defaultCategoryDirs[11] && e.category == defaultCategoryDirs[2]))
              .where((e) => selectedQuickSwapTypeCategory.watch(context) == appText.both || e.itemType.toLowerCase().split(' | ').first == selectedQuickSwapTypeCategory.watch(context).toLowerCase())
              .toList();

          selectedItems = masterQuickSwapItemList
              .where((e) =>
                  e.getName().isNotEmpty &&
                      (e.category == category ||
                          category == defaultCategoryDirs[16] && e.category == defaultCategoryDirs[1] ||
                          category == defaultCategoryDirs[2] && e.category == defaultCategoryDirs[11]) ||
                  category == defaultCategoryDirs[11] && e.category == defaultCategoryDirs[2])
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
                    SingleChoiceSelectButton(
                        width: double.infinity,
                        height: 30,
                        label: appText.types,
                        selectPopupLabel: appText.types,
                        availableItemList: itemTypes,
                        availableItemLabels: itemTypes.map((e) => appText.itemTypeName(e)).toList(),
                        selectedItemsLabel: itemTypes.map((e) => appText.itemTypeName(e)).toList(),
                        selectedItem: selectedQuickSwapTypeCategory,
                        extraWidgets: [],
                        savePref: () {
                          lScrollController.jumpTo(0);
                          rScrollController.jumpTo(0);
                        }),
                    Expanded(
                      child: Row(
                        spacing: 5,
                        children: [
                          Expanded(
                              child: QuickSwapItemGridLayout(
                            itemDataList: displayingItems,
                            scrollController: lScrollController,
                            selectedList: false,
                            onButtonPress: (selectedItem) {
                              masterQuickSwapItemList.add(selectedItem);
                              saveMasterQuickSwapItemListToJson(masterQuickSwapItemList);
                              setState(
                                () {},
                              );
                            },
                          )),
                          Expanded(
                              child: QuickSwapItemGridLayout(
                            itemDataList: selectedItems,
                            scrollController: rScrollController,
                            selectedList: true,
                            onButtonPress: (selectedItem) {
                              masterQuickSwapItemList.removeWhere((e) => e.compare(selectedItem));
                              saveMasterQuickSwapItemListToJson(masterQuickSwapItemList);
                              setState(
                                () {},
                              );
                            },
                          )),
                        ],
                      ),
                    ),
                  ],
                )),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(appText.returns))
            ],
          );
        });
      });
}
