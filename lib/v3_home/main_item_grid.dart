import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/sorting_buttons.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/main_widgets/cate_item_grid_layout.dart';
import 'package:pso2_mod_manager/main_widgets/category_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';

class MainItemGrid extends StatefulWidget {
  const MainItemGrid({super.key});

  @override
  State<MainItemGrid> createState() => _MainItemGridState();
}

class _MainItemGridState extends State<MainItemGrid> {
  double fadeInOpacity = 0;
  ScrollController controller = ScrollController();

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
    // Refresh
    if (selectedDisplaySort.watch(context) != selectedDisplaySort.peek() || mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }

    // Suggestions
    List<Item> filteredItems = [];
    if (searchTextController.value.text.isEmpty) {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedDisplayCategory.value || selectedDisplayCategory.value == appText.all)) {
          filteredItems.addAll(cate.items);
        }
      }
    } else {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedDisplayCategory.value || selectedDisplayCategory.value == appText.all)) {
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

    return AnimatedOpacity(
      opacity: fadeInOpacity,
      duration: const Duration(milliseconds: 100),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 40,
                  child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
                    SearchField<Item>(
                      itemHeight: 90,
                      searchInputDecoration: SearchInputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
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
                        padding: const EdgeInsets.only(right: 4),
                        child: ElevatedButton(
                            onPressed: searchTextController.value.text.isNotEmpty
                                ? () {
                                    searchTextController.clear();
                                    setState(() {});
                                  }
                                : null,
                            child: const Icon(Icons.close)),
                      ),
                    )
                  ]),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                            side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                        onPressed: () async {
                          if (categories.indexWhere((e) => e.visible) != -1) {
                            for (var cate in categories) {
                              cate.visible = false;
                            }
                          } else {
                            for (var cate in categories) {
                              cate.visible = true;
                            }
                          }
                          setState(() {});
                          saveMasterModListToJson();
                        },
                        child: Text(
                          categories.indexWhere((e) => e.visible) != -1 ? appText.collapseAll : appText.expandAll,
                          textAlign: TextAlign.center,
                        )),
                  )),
              SizedBox(width: 250, child: SortingButtons(scrollController: controller)),
              SizedBox(
                width: 200,
                child: CategorySelectButtons(categories: categories, scrollController: controller),
              ),
            ],
          ),
          Expanded(
              child: CustomScrollView(
            controller: controller,
            slivers: displayingCategories
                .map((e) => CateItemGridLayout(
                      itemCate: e,
                      searchString: searchTextController.value.text, scrollController: controller,
                    ))
                .toList(),
          ))
        ],
      ),
    );
  }
}
