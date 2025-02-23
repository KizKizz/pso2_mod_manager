import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/v2_home/category_item_layout.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ItemListV2 extends StatefulWidget {
  const ItemListV2({super.key, required this.refresh});

  final VoidCallback refresh;

  @override
  State<ItemListV2> createState() => _ItemListV2State();
}

class _ItemListV2State extends State<ItemListV2> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // data prep
    List<Category> displayingCategories = [];
    for (var cateType in masterModList) {
      displayingCategories.addAll(cateType.categories);
    }
    return Column(
      spacing: 5,
      children: [
        Expanded(
          child: CustomScrollView(
            physics: const SuperRangeMaintainingScrollPhysics(),
            slivers: displayingCategories
                .map((e) => CategoryItemLayout(
                      category: e,
                      searchString: '',
                      scrollController: scrollController,
                      refresh: () => setState(() {}),
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
