import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class QuickSwapItemGridLayout extends StatefulWidget {
  const QuickSwapItemGridLayout({super.key, required this.itemDataList, required this.scrollController, required this.selectedList, required this.onButtonPress});

  final List<ItemData> itemDataList;
  final ScrollController scrollController;
  final bool selectedList;
  final Function(ItemData selectedItem) onButtonPress;

  @override
  State<QuickSwapItemGridLayout> createState() => _QuickSwapItemGridLayoutState();
}

class _QuickSwapItemGridLayoutState extends State<QuickSwapItemGridLayout> {
  TextEditingController quickSwapItemSearchTextController = TextEditingController();
  ItemData? selectedItemData;

  @override
  Widget build(BuildContext context) {
    // Refresh
    // if (quickSwapPopupStatus.watch(context) != quickSwapPopupStatus.peek()) setState(() {});

    // Filtered data
    List<ItemData> displayingItemData = [];
    if (quickSwapItemSearchTextController.value.text.isEmpty) {
      displayingItemData = widget.itemDataList;
    } else {
      displayingItemData = widget.itemDataList.where((e) => e.getName().toLowerCase().contains(quickSwapItemSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 40,
          child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
            SearchField<ItemData>(
              itemHeight: 90,
              searchInputDecoration: SearchInputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
                  cursorHeight: 15,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                  cursorColor: Theme.of(context).colorScheme.primary),
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
              hint: appText.search,
              controller: quickSwapItemSearchTextController,
              onSuggestionTap: (p0) {
                quickSwapItemSearchTextController.text = p0.searchKey;
                selectedItemData = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return null;
              },
            ),
            Visibility(
              visible: quickSwapItemSearchTextController.value.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ElevatedButton(
                    onPressed: quickSwapItemSearchTextController.value.text.isNotEmpty
                        ? () {
                            quickSwapItemSearchTextController.clear();
                            setState(() {});
                          }
                        : null,
                    child: const Icon(Icons.close)),
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
                        enabled: !widget.selectedList ? masterQuickSwapItemList.indexWhere((e) => e.getName() == displayingItemData[index].getName()) == -1 : true,
                        title: Row(
                          spacing: 5,
                          children: [
                            GenericItemIconBox(iconImagePaths: [displayingItemData[index].iconImagePath], boxSize: const Size(80, 80), isNetwork: true),
                            Text(
                              displayingItemData[index].getName(),
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        subtitle: selectedItemData == displayingItemData[index]
                            ? Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(spacing: 5, crossAxisAlignment: CrossAxisAlignment.start, children: displayingItemData[index].getDetailsForAqmInject().map((e) => Text(e)).toList()),
                                  const HoriDivider(),
                                  Row(
                                    spacing: 5,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(onPressed: () => widget.onButtonPress(displayingItemData[index]), child: Text(widget.selectedList ? appText.remove : appText.add)),
                                    ],
                                  )
                                ],
                              )
                            : null,
                        selected: selectedItemData == displayingItemData[index],
                        onTap: () {
                          selectedItemData = displayingItemData[index];
                          setState(() {});
                        },
                      ),
                    );
                  },
                )))
      ],
    );
  }
}
