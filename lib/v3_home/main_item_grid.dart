import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/cate_item_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/category_select_buttons.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
    Future.delayed(const Duration(milliseconds: 100), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Suggestions
    List<String> filteredStrings = [];
    for (var type in masterModList) {
      if (searchTextController.value.text.isEmpty) {
        filteredStrings.addAll(type.getDistinctNames());
      } else {
        filteredStrings.addAll(type.getDistinctNames().where((e) => e.toLowerCase().contains(searchTextController.value.text.toLowerCase())));
      }
    }
    filteredStrings = filteredStrings.toSet().toList();
    filteredStrings.sort((a, b) => a.compareTo(b));

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
        categories.addAll(type.categories);
      }
    }

    List<Category> displayingCategories = [];
    if (selectedDisplayCategory.watch(context) == 'All') {
      displayingCategories = categories;
    } else {
      displayingCategories = categories.where((e) => e.categoryName == selectedDisplayCategory.watch(context)).toList();
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
                    SearchField<String>(
                      searchInputDecoration: SearchInputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                          isDense: true,
                          contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
                          cursorHeight: 15,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                          cursorColor: Theme.of(context).colorScheme.inverseSurface),
                      suggestions: filteredStrings
                          .map(
                            (e) => SearchFieldListItem<String>(
                              e,
                              item: e,
                              child: Padding(padding: const EdgeInsets.all(8.0), child: Text(e)),
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
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: CategorySelectButtons(categoryNames: categories.map((e) => e.categoryName).toList(), scrollController: controller),
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
                  CateItemGridLayout(
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
