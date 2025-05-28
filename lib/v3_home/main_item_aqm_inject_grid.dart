import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_grid_layout.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_grid_layout.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

class MainItemAqmInjectGrid extends StatefulWidget {
  const MainItemAqmInjectGrid({super.key});

  @override
  State<MainItemAqmInjectGrid> createState() => _MainItemAqmInjectGridState();
}

class _MainItemAqmInjectGridState extends State<MainItemAqmInjectGrid> {
  double fadeInOpacity = 0;
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();
  Signal<ItemData?> lSelectedItemData = Signal<ItemData?>(null);
  Signal<AqmInjectedItem?> rSelectedItemData = Signal<AqmInjectedItem?>(null);
  Signal<bool> showNoNameItems = Signal(false);
  List<ItemData> displayingItems = [];

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
    // Fetch aqm files
    Directory(modCustomAqmsDirPath).createSync(recursive: true);

    // Sort item data
    displayingItems = pItemData
        .where((e) => showNoNameItems.watch(context) || (!showNoNameItems.watch(context) && e.getName().isNotEmpty))
        .where((e) => selectedAqmInjectCategory.watch(context) == defaultCategoryDirs[1]
            ? e.subCategory == 'Basewear'
            : selectedAqmInjectCategory.watch(context) == defaultCategoryDirs[16]
                ? e.subCategory == 'Setwear'
                : selectedAqmInjectCategory.watch(context) == defaultCategoryDirs[14]
                    ? e.category == selectedAqmInjectCategory.watch(context) && (e.subCategory == selectedItemSwapMotionType.watch(context) || selectedItemSwapMotionType.watch(context) == 'All')
                    : e.category == selectedAqmInjectCategory.watch(context))
        .where((e) => selectedItemSwapTypeCategory.watch(context) == 'Both' || e.itemType.toLowerCase().split(' | ').first == selectedItemSwapTypeCategory.watch(context).toLowerCase())
        .toList();
    displayingItems.sort((a, b) => a.getName().compareTo(b.getName()));

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
                  child: SizedBox(
                height: 30,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () {
                      showNoNameItems.watch(context) ? showNoNameItems.value = false : showNoNameItems.value = true;
                    },
                    child: Text(showNoNameItems.watch(context) ? appText.hideNoNameItems : appText.showNoNameItems)),
              )),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: SingleChoiceSelectButton(
                          width: double.infinity,
                          height: 30,
                          label: appText.types,
                          selectPopupLabel: appText.types,
                          availableItemList: itemTypes,
                          selectedItemsLabel: itemTypes.map((e) => appText.itemTypeName(e)).toList(),
                          selectedItem: selectedItemSwapTypeCategory,
                          extraWidgets: [],
                          savePref: () {
                            lScrollController.jumpTo(0);
                            rScrollController.jumpTo(0);
                          }))),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: SingleChoiceSelectButton(
                    width: double.infinity,
                    height: 30,
                    label: appText.view,
                    selectPopupLabel: appText.view,
                    availableItemList: aqmInjectCategoryDirs,
                    selectedItemsLabel: aqmInjectCategoryDirs.map((e) => appText.categoryName(e)).toList(),
                    selectedItem: selectedAqmInjectCategory,
                    extraWidgets: [],
                    savePref: () {
                      lSelectedItemData.value = null;
                      lScrollController.jumpTo(0);
                    }),
              )),
            ],
          ),
          Expanded(
              child: Row(
            spacing: 5,
            children: [
              Expanded(
                  child: AqmInjectGridLayout(
                itemDataList: displayingItems,
                scrollController: lScrollController,
                selectedItemData: lSelectedItemData,
              )),
              Expanded(
                  child: AqmInjectedGridLayout(
                injectedItemList: masterAqmInjectedItemList,
                scrollController: rScrollController,
                selectedAqmInjectedItem: rSelectedItemData,
              )),
            ],
          )),
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: () async {
                    const XTypeGroup aqmTypeGroup = XTypeGroup(
                      label: 'AQM',
                      extensions: <String>['aqm'],
                    );
                    final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
                      aqmTypeGroup,
                    ]);
                    for (var file in files) {
                      await File(file.path).copy(modCustomAqmsDirPath + p.separator + p.basename(file.path));
                      setState(() {});
                    }
                  },
                  child: Text(appText.addCustomAqmFiles)),
              Expanded(
                  child: SingleChoiceSelectButton(
                      width: double.infinity,
                      height: 30,
                      label: appText.currentAqmFile,
                      selectPopupLabel: appText.customAQMFiles,
                      availableItemList: Directory(modCustomAqmsDirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '.aqm').map((e) => e.path).toList(),
                      selectedItemsLabel: Directory(modCustomAqmsDirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '.aqm').map((e) => e.path).toList(),
                      selectedItem: selectedAqmInjectCategory,
                      extraWidgets: [],
                      savePref: () async {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('selectedCustomAQMFilePath', selectedCustomAQMFilePath.value);
                      }))
            ],
          )
        ],
      ),
    );
  }
}
