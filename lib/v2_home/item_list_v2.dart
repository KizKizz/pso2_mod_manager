import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/sorting_buttons.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/category_item_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';

class ItemListV2 extends StatefulWidget {
  const ItemListV2({super.key});

  @override
  State<ItemListV2> createState() => _ItemListV2State();
}

class _ItemListV2State extends State<ItemListV2> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (selectedDisplaySort.watch(context) != selectedDisplaySort.peek() ||
        modPopupStatus.watch(context) != modPopupStatus.peek() ||
        modApplyStatus.watch(context) != modApplyStatus.peek() ||
        mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }

    // Suggestions
    List<Item> filteredItems = [];
    if (searchTextController.value.text.isEmpty) {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedDisplayCategory.value || selectedDisplayCategory.value == 'All')) {
          filteredItems.addAll(cate.items);
        }
      }
    } else {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedDisplayCategory.value || selectedDisplayCategory.value == 'All')) {
          filteredItems.addAll(cate.items.where((e) => e.itemName.toLowerCase().contains(searchTextController.value.text.toLowerCase())));
        }
      }
    }
    filteredItems.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));

    // Filter
    List<Category> categories = [];
    if (searchTextController.value.text.isNotEmpty) {
      for (var type in masterModList) {
        for (var category in type.categories) {
          if (category.getDistinctNames().where((e) => e.toLowerCase().contains(searchTextController.text.toLowerCase())).isNotEmpty) {
            categories.add(category);
          }
        }
      }
    } else {
      for (var type in masterModList) {
        hideEmptyCategories ? categories.addAll(type.categories.where((e) => e.items.isNotEmpty)) : categories.addAll(type.categories);
      }
    }

    List<Category> displayingCategories = [];
    if (selectedDisplayCategory.watch(context) == 'All') {
      displayingCategories = categories;
    } else {
      displayingCategories = categories.where((e) => e.categoryName == selectedDisplayCategory.watch(context)).toList();
    }

    // Sort
    if (selectedDisplaySort.value == modSortingSelections[0]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[1]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[2]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => b.applyDate.compareTo(a.applyDate));
      }
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
                  padding: const EdgeInsets.only(top: 0, bottom: 5, left: 5, right: 5),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          appText.itemList,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),

                      CategorySelectButtons(categories: categories, scrollController: scrollController),
                      Row(
                        spacing: 2.5,
                        children: [
                          Expanded(child: SortingButtons(scrollController: scrollController)),
                          // col-ex
                          SizedBox(
                            height: 30,
                            child: IconButton.outlined(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                    side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                                onPressed: () async {
                                  if (displayingCategories.indexWhere((e) => e.visible) != -1) {
                                    for (var cate in displayingCategories) {
                                      cate.visible = false;
                                    }
                                  } else {
                                    for (var cate in displayingCategories) {
                                      cate.visible = true;
                                    }
                                  }
                                  setState(() {});
                                  saveMasterModListToJson();
                                },
                                icon: Icon(
                                  displayingCategories.indexWhere((e) => e.visible) != -1 ? Icons.drag_handle_sharp : Icons.expand_outlined,
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
                            controller: searchTextController,
                            onSuggestionTap: (p0) {
                              searchTextController.text = p0.searchKey;
                              setState(() {});
                            },
                            onSearchTextChanged: (p0) {
                              setState(() {});
                              return null;
                            },
                          ),
                          Visibility(
                            visible: searchTextController.value.text.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: SizedBox(
                                height: 30,
                                child: IconButton(
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onPressed: searchTextController.value.text.isNotEmpty
                                        ? () {
                                            searchTextController.clear();
                                            setState(() {});
                                          }
                                        : null,
                                    icon: const Icon(Icons.close)),
                              ),
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
            slivers: displayingCategories
                .map((e) => CategoryItemLayout(
                      category: e,
                      searchString: searchTextController.text,
                      scrollController: scrollController,
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
