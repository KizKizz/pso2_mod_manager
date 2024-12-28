import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/v3_widgets/cate_item_grid_layout.dart';
import 'package:searchfield/searchfield.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class MainModGrid extends StatefulWidget {
  const MainModGrid({super.key});

  @override
  State<MainModGrid> createState() => _MainModGridState();
}

class _MainModGridState extends State<MainModGrid> {
  TextEditingController searchTextController = TextEditingController();

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

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 40,
          child: SearchField<String>(
            searchInputDecoration: SearchInputDecoration(
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(200),
              isDense: true,
              contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
              cursorHeight: 15,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                suffix: MaterialButton(
                      onPressed: searchTextController.value.text.isNotEmpty
                          ? () {
                              searchTextController.clear();
                              setState(() {});
                            }
                          : null,
                      child: const Icon(Icons.close)),
              
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
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(
            primary: true,
            cacheExtent: 10000,
            physics: const SuperRangeMaintainingScrollPhysics(),
            slivers: [
              for (int i = 0; i < categories.length; i++)
                CateItemGridLayout(
                  itemCate: categories[i],
                  searchString: searchTextController.value.text,
                )
            ],
          ),
        )
      ],
    );
  }
}
