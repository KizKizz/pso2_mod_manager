import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/popup_item_info.dart';
import 'package:pso2_mod_manager/main_widgets/popup_list_tile.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Future<void> submodViewPopup(context, Item item, Mod mod) async {
  Mod? selectedMod = item.mods.contains(mod) ? mod : null;
  bool isInEditingMode = false;
  bool showAppliedSubmods = false;
  List<SubMod> toShowSubmods = selectedMod!.submods;
  await showDialog(
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) => SignalBuilder(
          builder: (context) {
            // Refresh
            if (modPopupStatus.value != modPopupStatus.peek()) {
              setState(() {});
            }
            if (selectedMod != null && !item.mods.contains(selectedMod)) selectedMod = null;

            // Suggestions
            if (submodViewPopupSearchTextController.value.text.isNotEmpty) {
              toShowSubmods = selectedMod != null ? selectedMod!.submods.where((mod) => mod.submodName.toLowerCase().contains(submodViewPopupSearchTextController.text.toLowerCase())).toList() : [];
            } else {
              toShowSubmods = selectedMod != null ? selectedMod!.submods : [];
            }

            // Show applied only
            if (showAppliedSubmods) toShowSubmods = selectedMod!.submods.where((e) => e.applyStatus).toList();

            // Sort
            if (selectedDisplaySortModView.value == submodSortingSelections[0]) {
              toShowSubmods.sort(
                (a, b) => a.favoriteSort().compareTo(b.favoriteSort()) == 0
                    ? a.favoriteSort().compareTo(b.favoriteSort()) + a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase())
                    : a.favoriteSort().compareTo(b.favoriteSort()),
              );
            } else if (selectedDisplaySortModView.value == submodSortingSelections[1]) {
              toShowSubmods.sort(
                (a, b) => a.hasPreviewsSort().compareTo(b.hasPreviewsSort()) == 0
                    ? a.hasPreviewsSort().compareTo(b.hasPreviewsSort()) + a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase())
                    : a.hasPreviewsSort().compareTo(b.hasPreviewsSort()),
              );
            } else if (selectedDisplaySortModView.value == submodSortingSelections[2]) {
              toShowSubmods.sort((a, b) => a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase()));
            } else if (selectedDisplaySortModView.value == submodSortingSelections[3]) {
              toShowSubmods.sort(
                (a, b) => b.creationDate!.compareTo(a.creationDate!) == 0
                    ? b.creationDate!.compareTo(a.creationDate!) + a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase())
                    : b.creationDate!.compareTo(a.creationDate!),
              );
            } else if (selectedDisplaySortModView.value == submodSortingSelections[4]) {
              toShowSubmods.sort(
                (a, b) => b.applyDate.compareTo(a.applyDate) == 0
                    ? b.applyDate.compareTo(a.applyDate) + a.submodName.toLowerCase().compareTo(b.submodName.toLowerCase())
                    : b.applyDate.compareTo(a.applyDate),
              );
            }

            return AlertDialog(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.value),
              insetPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
              content: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  mouseCursor: MouseCursor.defer,
                  onSecondaryTap: () => Navigator.of(context).pop(),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                spacing: 5,
                                children: [
                                  PopupItemInfo(
                                    item: item,
                                    mod: mod,
                                    showModInfo: false,
                                    isSingleModView: true,
                                    onEditing: (bool editingState) {
                                      setState(() {
                                        isInEditingMode = editingState;
                                      });
                                    },
                                  ),
                                  const HoriDivider(),
                                  Expanded(
                                    child: CustomScrollView(
                                      physics: const SuperRangeMaintainingScrollPhysics(),
                                      slivers: [
                                        SuperSliverList.builder(
                                          itemCount: 1,
                                          itemBuilder: (context, modIndex) {
                                            return PopupListTile(
                                              item: item,
                                              mod: mod,
                                              selectedMod: selectedMod,
                                              onSelectedMod: () {
                                                selectedMod = mod;
                                                setState(() {});
                                              },
                                              onDelete: () async {
                                                await modDelete(context, item, mod, false);
                                                modPopupStatus.value = '[${DateTime.now()}] ${mod.modName} deleted';
                                                selectedMod = null;
                                                item.isNew = item.getModsIsNewState();
                                                // if (item.mods.isEmpty) {
                                                mainGridStatus.value = '[${DateTime.now()}] "${mod.modName}" in "${item.getDisplayName()}" is empty and removed';
                                                // ignore: use_build_context_synchronously
                                                Navigator.of(context).pop();
                                                // }
                                              },
                                              isInEditingMode: isInEditingMode,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 10, thickness: 2, endIndent: 5, indent: 5),
                            Expanded(
                              flex: 3,
                              child: selectedMod == null
                                  ? Center(child: Text(appText.selectAMod, style: Theme.of(context).textTheme.headlineSmall))
                                  : CustomScrollView(
                                      physics: const SuperRangeMaintainingScrollPhysics(),
                                      slivers: [
                                        SubmodGridLayout(
                                          submods: toShowSubmods,
                                          // searchString: searchTextController.value.text,
                                          searchString: '',
                                          item: item,
                                          mod: selectedMod!,
                                          modSetName: '',
                                          isPopup: true,
                                          isInEditingMode: isInEditingMode,
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const HoriDivider(),
                    ],
                  ),
                ),
              ),
              actionsPadding: EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
              actions: [
                Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: SizedBox(
                          height: 30,
                          child: Stack(
                            alignment: AlignmentDirectional.centerEnd,
                            children: [
                              SearchField<SubMod>(
                                enabled: searchTextController.value.text.isEmpty,
                                itemHeight: 90,
                                suggestionDirection: SuggestionDirection.up,
                                searchInputDecoration: SearchInputDecoration(
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.value),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(left: 20, right: 40, bottom: 15),
                                  cursorHeight: 15,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface),
                                  ),
                                  cursorColor: Theme.of(context).colorScheme.inverseSurface,
                                  hintText: appText.search,
                                ),
                                suggestions: toShowSubmods
                                    .map(
                                      (e) => SearchFieldListItem<SubMod>(
                                        e.submodName,
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
                                              Expanded(
                                                child: Text(e.submodName, textAlign: TextAlign.left, style: Theme.of(context).textTheme.labelLarge),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                controller: submodViewPopupSearchTextController,
                                onSuggestionTap: (p0) {
                                  submodViewPopupSearchTextController.text = p0.searchKey;
                                  setState(() {});
                                },
                                onSearchTextChanged: (p0) {
                                  setState(() {});
                                  return toShowSubmods
                                      .map(
                                        (e) => SearchFieldListItem<SubMod>(
                                          e.submodName,
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
                                                Expanded(
                                                  child: Text(e.submodName, textAlign: TextAlign.left, style: Theme.of(context).textTheme.labelLarge),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                              Visibility(
                                visible: submodViewPopupSearchTextController.value.text.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: IconButton(
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onPressed: submodViewPopupSearchTextController.value.text.isNotEmpty && (!itemListSearchIncludesMods || searchTextController.value.text.isEmpty)
                                        ? () {
                                            submodViewPopupSearchTextController.clear();
                                            setState(() {});
                                          }
                                        : null,
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: SingleChoiceSelectButton(
                        width: double.infinity,
                        height: 30,
                        label: appText.sort,
                        selectPopupLabel: appText.sort,
                        availableItemList: submodSortingSelections,
                        availableItemLabels: submodSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                        selectedItemsLabel: submodSortingSelections.map((e) => appText.sortingTypeName(e)).toList(),
                        selectedItem: selectedDisplaySortModView,
                        extraWidgets: [],
                        savePref: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('selectedDisplaySortModView', selectedDisplaySortModView.value);
                          setState(() {});
                        },
                      ),
                    ),
                    OutlinedButton(
                      onPressed: selectedMod != null && selectedMod!.getNumOfAppliedSubmods() > 0
                          ? () {
                              setState(() {
                                showAppliedSubmods ? showAppliedSubmods = false : showAppliedSubmods = true;
                              });
                            }
                          : null,
                      child: Text(!showAppliedSubmods ? appText.showAppliedOnly : appText.showAll),
                    ),
                    OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(appText.returns)),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
