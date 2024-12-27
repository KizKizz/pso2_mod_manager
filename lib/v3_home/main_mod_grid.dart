import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_type_class.dart';
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
  List<String> allNames = [];

  @override
  Widget build(BuildContext context) {
    for (var type in masterModList) {
      allNames.addAll(type.getDistinctNames());
    }
    allNames = allNames.toSet().toList();
    allNames.sort((a, b) => a.compareTo(b));

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: SearchField<String>(
            suggestions: allNames
                .map(
                  (e) => SearchFieldListItem<String>(
                    e,
                    item: e,
                    child: Padding(padding: const EdgeInsets.all(8.0), child: Text(e)),
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
            },
          ),
        ),
        Expanded(
          child: CustomScrollView(
            primary: true,
            cacheExtent: 10000,
            physics: const SuperRangeMaintainingScrollPhysics(),
            slivers: [
              for (int i = 0; i < masterModList.length; i++)
                for (int j = 0; j < masterModList[i].categories.length; j++)
                  CateItemGridLayout(
                    itemCate: masterModList[i].categories[j],
                    searchString: searchTextController.value.text,
                  )
            ],
          ),
        )
      ],
    );
  }
}
