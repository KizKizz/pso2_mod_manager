import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/modset_grid_layout.dart';
import 'package:pso2_mod_manager/mod_sets/modset_select_buttons.dart';
import 'package:pso2_mod_manager/mod_sets/modset_sorting_buttons.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Signal<String> selectedDisplayModSet = Signal('All');
Signal<String> modSetRefreshSignal = Signal('');

class MainModSetGrid extends StatefulWidget {
  const MainModSetGrid({super.key});

  @override
  State<MainModSetGrid> createState() => _MainModSetGridState();
}

class _MainModSetGridState extends State<MainModSetGrid> {
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
    if (selectedDisplaySortModSet.watch(context) != selectedDisplaySortModSet.peek() || modSetRefreshSignal.watch(context) != modSetRefreshSignal.peek()) {
      setState(
        () {},
      );
    }

    List<ModSet> displayingModSets = [];
    if (selectedDisplayModSet.watch(context) == 'All') {
      displayingModSets = masterModSetList;
    } else {
      displayingModSets = masterModSetList.where((e) => e.setName == selectedDisplayModSet.watch(context)).toList();
    }

    // Sort
    if (selectedDisplaySortModSet.value == modSortingSelections[0]) {
      displayingModSets.sort((a, b) => a.setName.toLowerCase().compareTo(b.setName.toLowerCase()));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[1]) {
      displayingModSets.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[2]) {
      displayingModSets.sort((a, b) => b.appliedDate!.compareTo(a.appliedDate!));
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
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                            side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                        onPressed: () async {
                          await newModSetCreate(context);
                          setState(() {});
                        },
                        child: Text(appText.addNewSet)),
                  )),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                            side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                        onPressed: () async {
                          if (displayingModSets.indexWhere((e) => e.expanded) != -1) {
                            for (var set in displayingModSets.where((e) => e.expanded)) {
                              set.expanded = false;
                            }
                          } else {
                            for (var set in displayingModSets.where((e) => !e.expanded)) {
                              set.expanded = true;
                            }
                          }
                          setState(() {});
                          saveMasterModSetListToJson();
                        },
                        child: Text(displayingModSets.indexWhere((e) => e.expanded) != -1 ? appText.collapseAll : appText.expandAll)),
                  )),
              Expanded(flex: 2, child: ModSetSortingButton(scrollController: controller)),
              Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: ModSetSelectButtons(setNames: masterModSetList.map((e) => e.setName).toList(), scrollController: controller),
                  )),
            ],
          ),
          Expanded(
              child: SuperListView.builder(
            controller: controller,
            itemCount: displayingModSets.length,
            itemBuilder: (context, i) => ModSetGridLayout(modSet: displayingModSets[i]),
          ))
        ],
      ),
    );
  }
}
