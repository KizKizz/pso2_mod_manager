import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ItemSwapAllGridLayout extends StatefulWidget {
  const ItemSwapAllGridLayout({super.key, required this.itemDataList, required this.scrollController, required this.selectedItemData});

  final List<ItemData> itemDataList;
  final ScrollController scrollController;
  final Signal<List<ItemData>> selectedItemData;

  @override
  State<ItemSwapAllGridLayout> createState() => _ItemSwapAllGridLayoutState();
}

class _ItemSwapAllGridLayoutState extends State<ItemSwapAllGridLayout> {
  TextEditingController itemSwapAllSearchTextController = TextEditingController();
  ItemData? selectedItemData = null;

  @override
  Widget build(BuildContext context) {
    List<ItemData> displayingItemData = [];
    if (itemSwapAllSearchTextController.value.text.isEmpty) {
      displayingItemData = widget.itemDataList;
    } else {
      displayingItemData = widget.itemDataList.where((e) => e.getName().toLowerCase().contains(itemSwapAllSearchTextController.value.text.toLowerCase())).toList();
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
              controller: itemSwapAllSearchTextController,
              onSuggestionTap: (p0) {
                itemSwapAllSearchTextController.text = p0.searchKey;
                // widget.selectedItemData.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return null;
              },
            ),
            Visibility(
              visible: itemSwapAllSearchTextController.value.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: IconButton(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onPressed: itemSwapAllSearchTextController.value.text.isNotEmpty
                        ? () {
                            itemSwapAllSearchTextController.clear();
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
                              Expanded(
                                child: Text(
                                  displayingItemData[index].getName(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          ),
                          subtitle: selectedItemData == displayingItemData[index]
                              ? Column(
                                  spacing: 5,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: displayingItemData[index].getDetails().map((e) => Text(e)).toList(),
                                )
                              : null,
                          selected: widget.selectedItemData.watch(context).contains(displayingItemData[index]),
                          onTap: !widget.selectedItemData.watch(context).contains(displayingItemData[index])
                              ? () {
                                  selectedItemData = displayingItemData[index];
                                  setState(() {});
                                }
                              : null,
                          trailing: OutlinedButton(
                              onPressed: !widget.selectedItemData.watch(context).contains(displayingItemData[index])
                                  ? () {
                                      selectedItemData = null;
                                      widget.selectedItemData.watch(context).add(displayingItemData[index]);
                                      setState(() {});
                                    }
                                  : null,
                              child: Text(appText.select)),
                        ));
                  },
                )))
      ],
    );
  }
}
