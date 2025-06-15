import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/category_item_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        for (var cate in cateType.categories.where((e) => selectedDisplayCategories.value.contains(e.categoryName) || selectedDisplayCategories.value.contains('All'))) {
          filteredItems.addAll(cate.items);
        }
      }
    } else {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => selectedDisplayCategories.value.contains(e.categoryName) || selectedDisplayCategories.value.contains('All'))) {
          filteredItems.addAll(cate.items.where((e) => itemListSearchIncludesMods
              ? e.getDistinctNames().indexWhere((n) => n.toLowerCase().contains(searchTextController.value.text.toLowerCase())) != -1
              : e.itemName.toLowerCase().contains(searchTextController.value.text.toLowerCase())));
        }
      }
    }
    filteredItems.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));

    // Filter
    List<Category> categories = [];
    if (searchTextController.value.text.isNotEmpty) {
      for (var type in masterModList) {
        for (var category in type.categories) {
          if (category.getDistinctNames().indexWhere((e) => e.toLowerCase().contains(searchTextController.text.toLowerCase())) != -1) {
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
    if (selectedDisplayCategories.watch(context).contains('All')) {
      displayingCategories = categories;
    } else {
      displayingCategories = categories.where((e) => selectedDisplayCategories.watch(context).contains(e.categoryName)).toList();
    }

    // Sort
    if (selectedDisplaySort.value == modSortingSelections[0]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => a.favoriteSort().compareTo(b.favoriteSort()));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[1]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => a.hasPreviewsSort().compareTo(b.hasPreviewsSort()));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[2]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[3]) {
      for (var category in displayingCategories) {
        category.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
      }
    } else if (selectedDisplaySort.value == modSortingSelections[4]) {
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
                      MultiChoiceSelectButton(
                          width: double.infinity,
                          height: 30,
                          label: appText.view,
                          selectPopupLabel: appText.view,
                          availableItemList: categories.map((e) => e.categoryName).toList(),
                          availableItemLabels: categories.map((e) => appText.categoryName(e.categoryName)).toList(),
                          selectedItemsLabel: selectedDisplayCategories.value.map((e) => appText.categoryName(e)).toList(),
                          selectedItems: selectedDisplayCategories,
                          extraWidgets: categories
                              .map((e) => Row(
                                    spacing: 5,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InfoBox(
                                          info: e.items.length > 1 ? appText.dText(appText.numItems, e.items.length.toString()) : appText.dText(appText.numItem, e.items.length.toString()),
                                          borderHighlight: false),
                                      InfoBox(info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedItems().toString()), borderHighlight: false)
                                    ],
                                  ))
                              .toList(),
                          savePref: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setStringList('selectedDisplayCategories', selectedDisplayCategories.value);
                          }),
                      Row(
                        spacing: 2.5,
                        children: [
                          Expanded(
                            child: SingleChoiceSelectButton(
                                width: double.infinity,
                                height: 30,
                                label: appText.sort,
                                selectPopupLabel: appText.sort,
                                availableItemList: modSortingSelections,
                                availableItemLabels: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                                selectedItemsLabel: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                                selectedItem: selectedDisplaySort,
                                extraWidgets: [],
                                savePref: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setString('selectedDisplaySort', selectedDisplaySort.value);
                                  scrollController.jumpTo(0);
                                }),
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
                          SearchField<String>(
                            itemHeight: 30,
                            searchInputDecoration: SearchInputDecoration(
                                filled: true,
                                fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                                isDense: true,
                                contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                                cursorHeight: 15,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                                cursorColor: Theme.of(context).colorScheme.inverseSurface,
                                hintText: appText.search),
                            suggestions: [],
                            // filteredItems
                            //     .map(
                            //       (e) => SearchFieldListItem<Item>(
                            //         e.itemName,
                            //         item: e,
                            //         child: Padding(
                            //           padding: const EdgeInsets.symmetric(horizontal: 5),
                            //           child: Row(
                            //             mainAxisAlignment: MainAxisAlignment.start,
                            //             mainAxisSize: MainAxisSize.min,
                            //             spacing: 5,
                            //             children: [
                            //               SizedBox(
                            //                   width: 75,
                            //                   height: 75,
                            //                   child: ItemIconBox(
                            //                     item: e,
                            //                     showSubCategory: true,
                            //                   )),
                            //               Column(
                            //                 spacing: 5,
                            //                 mainAxisAlignment: MainAxisAlignment.center,
                            //                 crossAxisAlignment: CrossAxisAlignment.start,
                            //                 children: [
                            //                   Text(e.itemName.replaceFirst('_', '/').trim(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                            //                   Row(
                            //                     spacing: 5,
                            //                     children: [
                            //                       InfoBox(
                            //                         info: appText.dText(e.mods.length > 1 ? appText.numMods : appText.numMod, e.mods.length.toString()),
                            //                         borderHighlight: false,
                            //                       ),
                            //                       InfoBox(
                            //                         info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedMods().toString()),
                            //                         borderHighlight: e.applyStatus,
                            //                       ),
                            //                     ],
                            //                   )
                            //                 ],
                            //               )
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //     )
                            //     .toList(),
                            controller: searchTextController,
                            onSuggestionTap: (p0) {
                              searchTextController.text = p0.searchKey;
                              setState(() {});
                            },
                            onSearchTextChanged: (p0) {
                              setState(() {});
                              if (itemListSearchIncludesMods) {
                                if (searchTextController.value.text.isEmpty) {
                                  modViewListV2SearchTextController.clear();
                                  mainGridStatus.value = '[${DateTime.now()}] searchTextController is empty';
                                } else {
                                  modViewListV2SearchTextController.text = searchTextController.value.text;
                                  mainGridStatus.value = '[${DateTime.now()}] searchTextController changed';
                                }

                                List<String> suggestionNames = [];
                                for (var item in filteredItems) {
                                  if (suggestionNames.indexWhere((e) => e.toLowerCase() == item.itemName.toLowerCase()) == -1 &&
                                      item.itemName.toLowerCase().contains(searchTextController.value.text)) {
                                    suggestionNames.add(item.itemName);
                                  }
                                  for (var name in item.getDistinctNames()) {
                                    if (suggestionNames.indexWhere((e) => e.toLowerCase() == name.toLowerCase()) == -1 && name.contains(searchTextController.value.text)) {
                                      suggestionNames.add(name);
                                    }
                                  }
                                }
                                if (suggestionNames.isEmpty) {
                                  return null;
                                } else {
                                  return suggestionNames.map((e) => SearchFieldListItem<String>(e)).toList();
                                }
                              } else {
                                return null;
                              }
                              // return filteredItems
                              //     .map(
                              //       (e) => SearchFieldListItem<Item>(
                              //         e.itemName,
                              //         item: e,
                              //         child: Padding(
                              //           padding: const EdgeInsets.symmetric(horizontal: 5),
                              //           child: Row(
                              //             mainAxisAlignment: MainAxisAlignment.start,
                              //             mainAxisSize: MainAxisSize.min,
                              //             spacing: 5,
                              //             children: [
                              //               SizedBox(
                              //                   width: 75,
                              //                   height: 75,
                              //                   child: ItemIconBox(
                              //                     item: e,
                              //                     showSubCategory: true,
                              //                   )),
                              //               Column(
                              //                 spacing: 5,
                              //                 mainAxisAlignment: MainAxisAlignment.center,
                              //                 crossAxisAlignment: CrossAxisAlignment.start,
                              //                 children: [
                              //                   Text(e.itemName.replaceFirst('_', '/').trim(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                              //                   Row(
                              //                     spacing: 5,
                              //                     children: [
                              //                       InfoBox(
                              //                         info: appText.dText(e.mods.length > 1 ? appText.numMods : appText.numMod, e.mods.length.toString()),
                              //                         borderHighlight: false,
                              //                       ),
                              //                       InfoBox(
                              //                         info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedMods().toString()),
                              //                         borderHighlight: e.applyStatus,
                              //                       ),
                              //                     ],
                              //                   )
                              //                 ],
                              //               )
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                              //     )
                              //     .toList();
                            },
                          ),
                          Padding(
                              padding: EdgeInsetsGeometry.only(right: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: 2,
                                children: [
                                  Visibility(
                                    visible: searchTextController.value.text.isNotEmpty,
                                    child: SizedBox(
                                      height: 30,
                                      child: IconButton(
                                          visualDensity: VisualDensity.adaptivePlatformDensity,
                                          padding: EdgeInsets.zero,
                                          onPressed: searchTextController.value.text.isNotEmpty
                                              ? () {
                                                  searchTextController.clear();
                                                  setState(() {});
                                                  if (itemListSearchIncludesMods) {
                                                    modViewListV2SearchTextController.clear();
                                                    mainGridStatus.value = '[${DateTime.now()}] searchTextController is cleared';
                                                  }
                                                }
                                              : null,
                                          icon: const Icon(Icons.close)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: ModManTooltip(
                                      message: appText.dText(itemListSearchIncludesMods ? appText.functionOn : appText.functionOff, appText.includeModsInItemSearch),
                                      child: IconButton(
                                          visualDensity: VisualDensity.adaptivePlatformDensity,
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            final prefs = await SharedPreferences.getInstance();
                                            itemListSearchIncludesMods ? itemListSearchIncludesMods = false : itemListSearchIncludesMods = true;
                                            prefs.setBool('itemListSearchIncludesMods', itemListSearchIncludesMods);
                                            itemListSearchIncludesMods && searchTextController.value.text.isNotEmpty
                                                ? modViewListV2SearchTextController.text = searchTextController.value.text
                                                : modViewListV2SearchTextController.clear();
                                            mainGridStatus.value = '[${DateTime.now()}] itemListSearchIncludesMods is set to ${itemListSearchIncludesMods.toString()}';
                                          },
                                          icon: Icon(Icons.saved_search, color: itemListSearchIncludesMods ? Theme.of(context).colorScheme.primary : null)),
                                    ),
                                  ),
                                ],
                              ))
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
