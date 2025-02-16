import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/cate_mod_category_select_buttons.dart';
import 'package:pso2_mod_manager/main_widgets/sorting_buttons.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/main_widgets/cate_mod_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
    Future.delayed(const Duration(milliseconds: 100), () {
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
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedModDisplayCategory.value || selectedModDisplayCategory.value == appText.all)) {
          for (var item in cate.items) {
            filteredMods.addAll(item.mods);
          }
        }
      }
    } else {
      for (var cateType in masterModList) {
        for (var cate in cateType.categories.where((e) => e.categoryName == selectedModDisplayCategory.value || selectedModDisplayCategory.value == appText.all)) {
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
    if (selectedModDisplayCategory.watch(context) == 'All') {
      displayingCategories = categories;
    } else {
      displayingCategories = categories.where((e) => e.categoryName == selectedModDisplayCategory.watch(context)).toList();
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
      duration: const Duration(milliseconds: 500),
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
                    SearchField<Mod>(
                      itemHeight: 90,
                      searchInputDecoration: SearchInputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
                          cursorHeight: 15,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                          cursorColor: Theme.of(context).colorScheme.inverseSurface),
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
                        child: Text(categories.indexWhere((e) => e.visible) != -1 ? appText.collapseAll : appText.expandAll)),
                  )),
              Expanded(flex: 2, child: SortingButtons(scrollController: controller)),
              Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: CateModCategorySelectButtons(categories: categories, scrollController: controller),
                  )),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              controller: controller,
              cacheExtent: 10000,
              physics: const SuperRangeMaintainingScrollPhysics(),
              slivers: [
                for (int i = 0; i < displayingCategories.length; i++)
                  CateModGridLayout(
                    itemCate: displayingCategories[i],
                    searchString: searchTextController.value.text,
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
