import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/modset_grid_layout.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

Signal<List<String>> selectedDisplayModSets = Signal(['All']);
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
    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (selectedDisplaySortModSet.watch(context) != selectedDisplaySortModSet.peek() ||
        modSetRefreshSignal.watch(context) != modSetRefreshSignal.peek() ||
        mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }

    List<ModSet> displayingModSets = [];
    if (selectedDisplayModSets.watch(context).contains('All')) {
      displayingModSets = masterModSetList;
    } else {
      displayingModSets = masterModSetList.where((e) => selectedDisplayModSets.watch(context).contains(e.setName)).toList();
    }

    // Sort
    if (selectedDisplaySortModSet.value == modSortingSelections[0]) {
      displayingModSets.sort((a, b) => a.favoriteSort().compareTo(b.favoriteSort()));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[1]) {
      displayingModSets.sort((a, b) => a.hasPreviewsSort().compareTo(b.hasPreviewsSort()));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[2]) {
      displayingModSets.sort((a, b) => a.setName.toLowerCase().compareTo(b.setName.toLowerCase()));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[3]) {
      displayingModSets.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    } else if (selectedDisplaySortModSet.value == modSortingSelections[4]) {
      displayingModSets.sort((a, b) => b.appliedDate!.compareTo(a.appliedDate!));
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
                  flex: 1,
                  child: SizedBox(
                    height: 30,
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
              SingleChoiceSelectButton(
                  width: 250,
                  height: 30,
                  label: appText.types,
                  selectPopupLabel: appText.types,
                  availableItemList: modSortingSelections,
                  availableItemLabels: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                  selectedItemsLabel: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                  selectedItem: selectedDisplaySortModSet,
                  extraWidgets: [],
                  savePref: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setString('selectedDisplaySortModSet', selectedDisplaySortModSet.value);
                    controller.jumpTo(0);
                  }),
              MultiChoiceSelectButton(
                  width: 250,
                  height: 30,
                  label: appText.view,
                  selectPopupLabel: appText.view,
                  availableItemList: masterModSetList.map((e) => e.setName).toList(),
                  availableItemLabels: [],
                  selectedItemsLabel: masterModSetList.where((e) => selectedDisplayModSets.value.contains(e.setName)).map((e) => e.setName).toList(),
                  selectedItems: selectedDisplayModSets,
                  extraWidgets: masterModSetList
                      .map((e) => Row(
                            spacing: 5,
                            children: [
                              InfoBox(info: appText.dText(e.setItems.length > 1 ? appText.numItems : appText.numItem, e.setItems.length.toString()), borderHighlight: false),
                              InfoBox(info: appText.dText(appText.numCurrentlyApplied, e.setItems.where((e) => e.applyStatus).length.toString()), borderHighlight: false)
                            ],
                          ))
                      .toList(),
                  savePref: () async {
                    controller.jumpTo(0);
                  }),
              SizedBox(
                height: 30,
                child: IconButton.outlined(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
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
                    icon: Icon(
                      displayingModSets.indexWhere((e) => e.expanded) != -1 ? Icons.drag_handle_sharp : Icons.expand_outlined,
                    )),
              ),
            ],
          ),
          Expanded(
              child: CustomScrollView(
            controller: controller,
            slivers: displayingModSets
                .map((e) => ModSetGridLayout(
                      modSet: e,
                      scrollController: controller,
                    ))
                .toList(),
          ))
        ],
      ),
    );
  }
}
