import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/main_widgets/cate_mod_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class MainModGrid extends StatefulWidget {
  const MainModGrid({super.key});

  @override
  State<MainModGrid> createState() => _MainModGridState();
}

class _MainModGridState extends State<MainModGrid> {
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
    List<Mod> filteredMods = [];
    if (searchTextController.value.text.isEmpty) {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => selectedModDisplayCategories.watch(context).contains(e.categoryName) || selectedModDisplayCategories.watch(context).contains('All'))) {
          for (var item in cate.items) {
            filteredMods.addAll(item.mods);
          }
        }
      }
    } else {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => selectedModDisplayCategories.watch(context).contains(e.categoryName) || selectedModDisplayCategories.watch(context).contains('All'))) {
          for (var item in cate.items) {
            filteredMods.addAll(item.mods.where((e) => e.modName.toLowerCase().contains(searchTextController.value.text.toLowerCase())));
          }
        }
      }
    }
    filteredMods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));

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
    if (selectedModDisplayCategories.value.contains('All')) {
      displayingCategories = categories;
    } else {
      displayingCategories = categories.where((e) => selectedModDisplayCategories.watch(context).contains(e.categoryName)).toList();
    }

    // Sort
    // if (selectedDisplaySort.value == modSortingSelections[0]) {
    //   for (var category in displayingCategories) {
    //     category.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    //   }
    // } else if (selectedDisplaySort.value == modSortingSelections[1]) {
    //   for (var category in displayingCategories) {
    //     category.items.sort((a, b) => a.hasPreviewsSort().compareTo(b.hasPreviewsSort()));
    //   }
    // } else if (selectedDisplaySort.value == modSortingSelections[2]) {
    //   for (var category in displayingCategories) {
    //     category.items.sort((a, b) => a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
    //   }
    // } else if (selectedDisplaySort.value == modSortingSelections[3]) {
    //   for (var category in displayingCategories) {
    //     category.items.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
    //   }
    // } else if (selectedDisplaySort.value == modSortingSelections[4]) {
    //   for (var category in displayingCategories) {
    //     category.items.sort((a, b) => b.applyDate.compareTo(a.applyDate));
    //   }
    // }

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
                  height: 30,
                  child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
                    SearchField<Mod>(
                      itemHeight: 90,
                      searchInputDecoration: SearchInputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                          cursorHeight: 15,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                          cursorColor: Theme.of(context).colorScheme.inverseSurface,
                          hintText: appText.search),
                      suggestions: filteredMods
                          .map(
                            (e) => SearchFieldListItem<Mod>(
                              e.modName,
                              item: e,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 5,
                                  children: [
                                    SizedBox(
                                      width: 75,
                                      height: 75,
                                      child: SubmodPreviewBox(imageFilePaths: e.previewImages, videoFilePaths: e.previewVideos, isNew: false),
                                    ),
                                    Column(
                                      spacing: 5,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(e.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            InfoBox(
                                              info: appText.dText(e.submods.length > 1 ? appText.numVariants : appText.numVariant, e.submods.length.toString()),
                                              borderHighlight: false,
                                            ),
                                            InfoBox(
                                              info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedSubmods().toString()),
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
                      controller: searchTextController,
                      onSuggestionTap: (p0) {
                        searchTextController.text = p0.searchKey;
                        setState(() {});
                      },
                      onSearchTextChanged: (p0) {
                        setState(() {});
                        return filteredMods
                            .map(
                              (e) => SearchFieldListItem<Mod>(
                                e.modName,
                                item: e,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 5,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        height: 75,
                                        child: SubmodPreviewBox(imageFilePaths: e.previewImages, videoFilePaths: e.previewVideos, isNew: false),
                                      ),
                                      Column(
                                        spacing: 5,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(e.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                                          Row(
                                            spacing: 5,
                                            children: [
                                              InfoBox(
                                                info: appText.dText(e.submods.length > 1 ? appText.numVariants : appText.numVariant, e.submods.length.toString()),
                                                borderHighlight: false,
                                              ),
                                              InfoBox(
                                                info: appText.dText(appText.numCurrentlyApplied, e.getNumOfAppliedSubmods().toString()),
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
                            .toList();
                      },
                    ),
                    Visibility(
                      visible: searchTextController.value.text.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
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
                    )
                  ]),
                ),
              ),
              SingleChoiceSelectButton(
                  width: 250,
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
                    controller.jumpTo(0);
                  }),
              MultiChoiceSelectButton(
                width: 200,
                height: 30,
                label: appText.view,
                selectPopupLabel: appText.view,
                availableItemList: categories.map((e) => e.categoryName).toList(),
                availableItemLabels: categories.map((e) => appText.categoryName(e.categoryName)).toList(),
                selectedItemsLabel: selectedModDisplayCategories.value.map((e) => appText.categoryName(e)).toList(),
                selectedItems: selectedModDisplayCategories,
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
                  prefs.setStringList('selectedModDisplayCategories', selectedModDisplayCategories.value);
                },
              ),
              SizedBox(
                height: 30,
                child: IconButton.outlined(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
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
                    icon: Icon(
                      categories.indexWhere((e) => e.visible) != -1 ? Icons.drag_handle_sharp : Icons.expand_outlined,
                    )),
              ),
            ],
          ),
          Expanded(
              child: CustomScrollView(
                  controller: controller,
                  slivers: displayingCategories
                      .map((e) => CateModGridLayout(
                            itemCate: e,
                            searchString: searchTextController.value.text,
                            scrollController: controller,
                          ))
                      .toList()))
        ],
      ),
    );
  }
}
