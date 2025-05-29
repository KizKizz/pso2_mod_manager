import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/item_edit_button.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/mod_bulk_delete_button.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/mod_view_v2_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

class ModViewListV2 extends StatefulWidget {
  const ModViewListV2({super.key, required this.item});

  final Item? item;

  @override
  State<ModViewListV2> createState() => _ModViewListV2State();
}

class _ModViewListV2State extends State<ModViewListV2> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchTextController = TextEditingController();
  bool expanded = false;
  bool expandAll = false;
  bool itemEditingMode = false;

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (selectedDisplaySortModView.watch(context) != selectedDisplaySortModView.peek() ||
        modApplyStatus.watch(context) != modApplyStatus.peek() ||
        modPopupStatus.watch(context) != modPopupStatus.peek() ||
        mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }

    // Suggestions
    List<Mod> filteredMods = [];
    if (widget.item != null) {
      if (searchTextController.value.text.isEmpty) {
        filteredMods = widget.item!.mods;
      } else {
        filteredMods = widget.item!.mods
            .where((mod) =>
                mod.itemName.replaceFirst('_', '/').trim().toLowerCase().contains(searchTextController.text.toLowerCase()) ||
                mod.modName.toLowerCase().contains(searchTextController.text.toLowerCase()) ||
                mod.getDistinctNames().where((e) => e.toLowerCase().contains(searchTextController.text.toLowerCase())).isNotEmpty)
            .toList();
      }
    }
    filteredMods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));

    // Sort
    if (selectedDisplaySortModView.value == modSortingSelections[0]) {
      filteredMods.sort((a, b) => a.modName.toLowerCase().compareTo(b.modName.toLowerCase()));
    } else if (selectedDisplaySortModView.value == modSortingSelections[1]) {
      filteredMods.sort((a, b) => b.creationDate!.compareTo(a.creationDate!));
    } else if (selectedDisplaySortModView.value == modSortingSelections[2]) {
      filteredMods.sort((a, b) => b.applyDate.compareTo(a.applyDate));
    }

    if (widget.item == null) {
      return SizedBox(
          height: 136,
          child: Card(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Center(
                      child: Text(
                    appText.emptyModViewInfo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  )))));
    } else {
      return Column(
        spacing: 5,
        children: [
          SizedBox(
            height: 136,
            child: Card(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                margin: EdgeInsets.zero,
                elevation: 5,
                child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                    child: Column(
                      spacing: 5,
                      children: [
                        SizedBox(
                          height: 90,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 5,
                            children: [
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: ItemIconBox(
                                    item: widget.item!,
                                    showSubCategory: false,
                                  )),
                              Expanded(
                                child: Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      spacing: 5,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: Text(widget.item!.getDisplayName(), style: Theme.of(context).textTheme.titleMedium)),
                                        Visibility(
                                          visible: !aqmInjectCategoryDirs.contains(widget.item!.category) && widget.item!.subCategory!.isNotEmpty,
                                          child: InfoBox(
                                              info: widget.item!.category == defaultCategoryDirs[14]
                                                  ? appText.motionTypeName(widget.item!.subCategory!)
                                                  : widget.item!.category == defaultCategoryDirs[17]
                                                      ? appText.weaponTypeName(widget.item!.subCategory!.split('* ').last)
                                                      : widget.item!.subCategory!,
                                              borderHighlight: false),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Row(
                                        spacing: 2.5,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: InfoBox(
                                              info: appText.dText(widget.item!.mods.length > 1 ? appText.numMods : appText.numMod, widget.item!.mods.length.toString()),
                                              borderHighlight: false,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InfoBox(
                                              info: appText.dText(appText.numCurrentlyApplied, widget.item!.getNumOfAppliedMods().toString()),
                                              borderHighlight: widget.item!.applyStatus,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      spacing: 2.5,
                                      children: [
                                        Expanded(
                                            child: SingleChoiceSelectButton(
                                                width: double.infinity,
                                                height: 30,
                                                label: appText.sort,
                                                selectPopupLabel: appText.sort,
                                                availableItemList: modSortingSelections,
                                                availableItemLabels: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                                                selectedItemsLabel: modSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                                                selectedItem: selectedDisplaySortModView,
                                                extraWidgets: [],
                                                savePref: () async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  prefs.setString('selectedDisplaySortModView', selectedDisplaySortModView.value);
                                                  scrollController.jumpTo(0);
                                                })),
                                        // edit
                                        ItemEditButton(
                                          onPressed: (isEditing) {
                                            itemEditingMode = isEditing;
                                            setState(() {});
                                          },
                                        ),
                                        // col-ex
                                        SizedBox(
                                          height: 30,
                                          child: IconButton.outlined(
                                              visualDensity: VisualDensity.adaptivePlatformDensity,
                                              style: ButtonStyle(
                                                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                                  side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                                              onPressed: () async {
                                                expandAll ? expandAll = false : expandAll = true;
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                expandAll == true ? Icons.drag_handle_sharp : Icons.expand_outlined,
                                              )),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // Search box
                        if (!itemEditingMode)
                          Expanded(
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
                        if (itemEditingMode)
                          SizedBox(
                              width: double.infinity,
                              height: 31,
                              child: ModBulkDeleteButton(
                                enabled: bulkDeleteMods.isNotEmpty || bulkDeleteSubmods.isNotEmpty,
                                isPopup: false,
                              ))
                      ],
                    ))),
          ),

          // Main list
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              // physics: const SuperRangeMaintainingScrollPhysics(),
              slivers: filteredMods
                  .map((e) => ModViewV2Layout(
                        item: widget.item!,
                        mod: e,
                        searchString: searchTextController.text,
                        expandAll: expandAll,
                        isInEditingMode: itemEditingMode,
                        scrollController: scrollController,
                      ))
                  .toList(),
            ),
          )
        ],
      );
    }
  }
}
