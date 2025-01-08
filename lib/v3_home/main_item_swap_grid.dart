import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_cate_select_buttons.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/modset_grid_layout.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Signal<String> selectedDisplayItemSwapCategory = Signal('Accessories');

class MainItemSwapGrid extends StatefulWidget {
  const MainItemSwapGrid({super.key});

  @override
  State<MainItemSwapGrid> createState() => _MainItemSwapGridState();
}

class _MainItemSwapGridState extends State<MainItemSwapGrid> {
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
    List<ModSet> displayingModSets = [];
    if (selectedDisplayItemSwapCategory.watch(context) == 'Accessories') {
      displayingModSets = masterModSetList;
    } else {
      displayingModSets = masterModSetList.where((e) => e.setName == selectedDisplayItemSwapCategory.watch(context)).toList();
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
                flex: 3,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                        onPressed: () {},
                        child: Text(appText.addNewSet)),
                  )),
              Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: ItemSwapCateSelectButtons(categoryNames: defaultCategoryDirs, scrollController: controller),
                  )),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              controller: controller,
              cacheExtent: 10000,
              physics: const SuperRangeMaintainingScrollPhysics(),
              slivers: [for (int i = 0; i < displayingModSets.length; i++) ModSetGridLayout(modSet: displayingModSets[i])],
            ),
          )
        ],
      ),
    );
  }
}
