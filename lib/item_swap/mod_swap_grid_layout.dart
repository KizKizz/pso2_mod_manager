import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ModSwapGridLayout extends StatefulWidget {
  const ModSwapGridLayout({super.key, required this.itemDataList, required this.submod, required this.scrollController, required this.selectedItemData, required this.emoteSwapQueue});

  final List<ItemData> itemDataList;
  final SubMod submod;
  final ScrollController scrollController;
  final Signal<ItemData?> selectedItemData;
  final List<(ItemData, ItemData)> emoteSwapQueue;

  @override
  State<ModSwapGridLayout> createState() => _ModSwapGridLayoutState();
}

class _ModSwapGridLayoutState extends State<ModSwapGridLayout> {
  TextEditingController itemSwapSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<ItemData> displayingItemData = [];
    if (itemSwapSearchTextController.value.text.isEmpty) {
      displayingItemData = widget.itemDataList;
    } else {
      displayingItemData = widget.itemDataList.where((e) => e.getName().toLowerCase().contains(itemSwapSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 30,
          child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
            SearchField<ItemData>(
              itemHeight: 90,
              searchInputDecoration: SearchInputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                  cursorHeight: 15,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                  cursorColor: Theme.of(context).colorScheme.primary,
                  hintText: appText.search),
              suggestions: displayingItemData
                  .map(
                    (e) => SearchFieldListItem(
                      e.getName(),
                      item: e,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            spacing: 5,
                            children: [
                              GenericItemIconBox(iconImagePaths: [e.iconImagePath], boxSize: const Size(70, 70), isNetwork: true),
                              Text(e.getName())
                            ],
                          )),
                    ),
                  )
                  .toList(),
              controller: itemSwapSearchTextController,
              onSuggestionTap: (p0) {
                itemSwapSearchTextController.text = p0.searchKey;
                widget.selectedItemData.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return displayingItemData
                    .map(
                      (e) => SearchFieldListItem(
                        e.getName(),
                        item: e,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              spacing: 5,
                              children: [
                                GenericItemIconBox(iconImagePaths: [e.iconImagePath], boxSize: const Size(70, 70), isNetwork: true),
                                Text(e.getName())
                              ],
                            )),
                      ),
                    )
                    .toList();
              },
            ),
            Visibility(
              visible: itemSwapSearchTextController.value.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: IconButton(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onPressed: itemSwapSearchTextController.value.text.isNotEmpty
                        ? () {
                            itemSwapSearchTextController.clear();
                            setState(() {});
                          }
                        : null,
                    icon: const Icon(Icons.close)),
              ),
            )
          ]),
        ),
        Expanded(
            child: CardOverlay(
                paddingValue: 5,
                child: SuperListView.builder(
                  physics: const SuperRangeMaintainingScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount: displayingItemData.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                        data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        child: ListTile(
                          minTileHeight: 90,
                          title: Row(
                            spacing: 5,
                            children: [
                              GenericItemIconBox(iconImagePaths: [displayingItemData[index].iconImagePath], boxSize: const Size(80, 80), isNetwork: true),
                              Column(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayingItemData[index].getName(),
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Visibility(
                                      visible: !aqmInjectCategoryDirs.contains(displayingItemData[index].category) && displayingItemData[index].subCategory.isNotEmpty,
                                      child: InfoBox(
                                          info: displayingItemData[index].category == defaultCategoryDirs[14]
                                              ? appText.motionTypeName(displayingItemData[index].subCategory)
                                              : displayingItemData[index].category == defaultCategoryDirs[17]
                                                  ? appText.weaponTypeName(displayingItemData[index].subCategory.split('* ').last)
                                                  : displayingItemData[index].subCategory,
                                          borderHighlight: false)),
                                ],
                              )
                            ],
                          ),
                          subtitle: widget.selectedItemData.watch(context) == displayingItemData[index]
                              ? Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: displayingItemData[index].getModSwapDetails(widget.submod).map((e) => Text(e)).toList(),
                                )
                              : null,
                          selected: widget.selectedItemData.watch(context) == displayingItemData[index],
                          enabled: widget.emoteSwapQueue.indexWhere((e) => e.$1 == displayingItemData[index]) == -1,
                          onTap: () {
                            widget.selectedItemData.value = displayingItemData[index];
                          },
                        ));
                  },
                )))
      ],
    );
  }
}
