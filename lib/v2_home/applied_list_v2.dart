import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/applied_mod_category_select_buttons.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_apply/load_applied_mods.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/mods_to_set_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/applied_list_sorting_button.dart';
import 'package:pso2_mod_manager/v2_home/applied_mod_v2_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';

class AppliedListV2 extends StatefulWidget {
  const AppliedListV2({super.key});

  @override
  State<AppliedListV2> createState() => _AppliedListV2State();
}

class _AppliedListV2State extends State<AppliedListV2> {
  TextEditingController appliedListSearchTextController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool expandAll = false;

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modApplyStatus.watch(context) != modApplyStatus.peek() ||
        mainGridStatus.watch(context) != mainGridStatus.peek() ||
        selectedDisplayCategoryAppliedList.watch(context) != selectedDisplayCategoryAppliedList.peek()) {
      setState(
        () {},
      );
    }

    int numOfAppliedMods = 0;
    // Suggestions
    List<Item> filteredItems = [];
    if (appliedListSearchTextController.text.isEmpty) {
      for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
        for (var cate
            in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0 && (e.categoryName == selectedDisplayCategoryAppliedList.value || selectedDisplayCategoryAppliedList.value == 'All'))) {
          for (var item in cate.items.where((e) => e.applyStatus)) {
            filteredItems.add(item);
            numOfAppliedMods += item.getNumOfAppliedMods();
          }
        }
      }
    } else {
      for (var cateType in masterModList.where((e) => e.getNumOfAppliedCates() > 0)) {
        for (var cate
            in cateType.categories.where((e) => e.getNumOfAppliedItems() > 0 && (e.categoryName == selectedDisplayCategoryAppliedList.value || selectedDisplayCategoryAppliedList.value == 'All'))) {
          for (var item in cate.items.where((e) => e.applyStatus)) {
            if (item.mods.indexWhere((e) => e.applyStatus && e.itemName.toLowerCase().contains(appliedListSearchTextController.text.toLowerCase())) != -1) filteredItems.add(item);
            numOfAppliedMods += item.getNumOfAppliedMods();
          }
        }
      }
    }
    filteredItems.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));

    // Filter
    List<Category> categories = [];
    if (appliedListSearchTextController.text.isNotEmpty) {
      for (var type in masterModList) {
        for (var category in type.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
          if (category.getDistinctNames().where((e) => e.toLowerCase().contains(appliedListSearchTextController.text.toLowerCase())).isNotEmpty) {
            categories.add(category);
          }
        }
      }
    } else {
      for (var type in masterModList) {
        categories.addAll(type.categories.where((e) => e.getNumOfAppliedItems() > 0));
      }
    }

    // Sort
    if (selectedDisplaySortAppliedList.value == modSortingSelections[0]) {
      filteredItems.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    } else if (selectedDisplaySortAppliedList.value == modSortingSelections[1]) {
      filteredItems.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
    } else if (selectedDisplaySortAppliedList.value == modSortingSelections[2]) {
      filteredItems.sort((a, b) => b.applyDate.compareTo(a.applyDate));
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 136,
          child: Card(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          appText.appliedList,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Row(
                        spacing: 2.5,
                        children: [
                          Flexible(flex: 4, child: AppliedModCategorySelectButtons(categories: categories, scrollController: scrollController)),
                          Flexible(flex: 5, child: AppliedListSortingButton(scrollController: scrollController)),
                        ],
                      ),
                      Row(
                        spacing: 2.5,
                        children: [
                          Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 30,
                                child: OutlinedButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                                    onPressed: numOfAppliedMods > 0 ? () {} : null,
                                    onLongPress: numOfAppliedMods > 0
                                        ? () async {
                                            List<Item> appliedItems = await appliedModsFetch();
                                            for (var item in appliedItems) {
                                              for (var mod in item.mods.where((e) => e.applyStatus)) {
                                                for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                                  // ignore: use_build_context_synchronously
                                                  await modToGameData(context, false, item, mod, submod);
                                                }
                                              }
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      appText.dText(numOfAppliedMods > 1 ? appText.holdToRestoreNumAppliedMods : appText.holdToRestoreNumAppliedMod, numOfAppliedMods.toString()),
                                      textAlign: TextAlign.center,
                                    )),
                              )),
                          SizedBox(
                            height: 30,
                            child: IconButton.outlined(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                    side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                                onPressed: () async {
                                  int addedCounter = 0;
                                  final toAddSets = await modsToSetPopup(context);
                                  List<Item> appliedItems = await appliedModsFetch();
                                  for (var item in appliedItems) {
                                    for (var mod in item.mods.where((e) => e.applyStatus)) {
                                      for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                        // ignore: use_build_context_synchronously
                                        final result = await submodsAddToSet(context, item, mod, submod, toAddSets);
                                        if (result) addedCounter++;
                                      }
                                    }
                                  }
                                  if (addedCounter > 0) {
                                    addToSetSuccessNotification(
                                        appText.dText(addedCounter > 1 ? appText.numMods : appText.numMod, addedCounter.toString()), toAddSets.map((e) => e.setName).toList().join(', '));
                                  }
                                },
                                icon: const Icon(
                                  Icons.my_library_books_outlined,
                                )),
                          ),
                          // col-ex
                          SizedBox(
                            height: 30,
                            child: IconButton.outlined(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                    side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                                onPressed: () async {
                                  expandAll ? expandAll = false : expandAll = true;
                                  setState(() {});
                                },
                                icon: Icon(
                                  expandAll == true ? Icons.drag_handle_sharp : Icons.expand_outlined,
                                )),
                          ),
                        ],
                      ),

                      // Search box
                      SizedBox(
                        height: 30,
                        child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
                          SearchField<Item>(
                            itemHeight: 90,
                            searchInputDecoration: SearchInputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                                isDense: true,
                                contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                                cursorHeight: 15,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                                cursorColor: Theme.of(context).colorScheme.inverseSurface),
                            suggestions: filteredItems
                                .map(
                                  (e) => SearchFieldListItem<Item>(
                                    e.itemName,
                                    item: e,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 5,
                                        children: [
                                          SizedBox(width: 75, height: 75, child: ItemIconBox(item: e)),
                                          Column(
                                            spacing: 5,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(e.itemName.replaceFirst('_', '/').trim(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                                              Row(
                                                spacing: 5,
                                                children: [
                                                  InfoBox(
                                                    info: appText.dText(e.mods.length > 1 ? appText.numMods : appText.numMod, e.mods.length.toString()),
                                                    borderHighlight: false,
                                                  ),
                                                  InfoBox(
                                                    info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedMods().toString()),
                                                    borderHighlight: e.applyStatus,
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            hint: appText.search,
                            controller: appliedListSearchTextController,
                            onSuggestionTap: (p0) {
                              appliedListSearchTextController.text = p0.searchKey;
                              setState(() {});
                            },
                            onSearchTextChanged: (p0) {
                              setState(() {});
                              return null;
                            },
                          ),
                          Visibility(
                            visible: appliedListSearchTextController.value.text.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: IconButton(
                                  visualDensity: VisualDensity.adaptivePlatformDensity,
                                  onPressed: appliedListSearchTextController.value.text.isNotEmpty
                                      ? () {
                                          appliedListSearchTextController.clear();
                                          setState(() {});
                                        }
                                      : null,
                                  icon: const Icon(Icons.close)),
                            ),
                          )
                        ]),
                      ),
                    ],
                  ))),
        ),
        // Main list
        Expanded(
          child: CustomScrollView(
            controller: scrollController,
            // physics: const RangeMaintainingScrollPhysics()  ,
            slivers: filteredItems.map((e) => AppliedModV2Layout(item: e, searchString: appliedListSearchTextController.text, expandAll: expandAll, scrollController: scrollController)).toList(),
          ),
        )
      ],
    );
  }
}
