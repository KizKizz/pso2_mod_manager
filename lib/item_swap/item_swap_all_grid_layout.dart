import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ItemSwapAllGridLayout extends StatefulWidget {
  const ItemSwapAllGridLayout({super.key, required this.itemDataList, required this.scrollController, required this.selectedItemData, required this.refresh});

  final List<ItemData> itemDataList;
  final ScrollController scrollController;
  final Signal<List<ItemData>> selectedItemData;
  final VoidCallback refresh;

  @override
  State<ItemSwapAllGridLayout> createState() => _ItemSwapAllGridLayoutState();
}

class _ItemSwapAllGridLayoutState extends State<ItemSwapAllGridLayout> {
  TextEditingController itemSwapAllSearchTextController = TextEditingController();
  ItemData? selectedItemData;

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
                                      widget.refresh();
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

class ItemSwapAllSelectedGridLayout extends StatefulWidget {
  const ItemSwapAllSelectedGridLayout({super.key, required this.itemDataList, required this.scrollController});

  final Signal<List<ItemData>> itemDataList;
  final ScrollController scrollController;

  @override
  State<ItemSwapAllSelectedGridLayout> createState() => _ItemSwapAllSelectedGridLayout();
}

class _ItemSwapAllSelectedGridLayout extends State<ItemSwapAllSelectedGridLayout> {
  TextEditingController itemSwapAllSearchTextController = TextEditingController();
  ItemData? selectedItemData;

  @override
  Widget build(BuildContext context) {
    List<ItemData> displayingItemData = [];
    if (itemSwapAllSearchTextController.value.text.isEmpty) {
      displayingItemData = widget.itemDataList.watch(context);
    } else {
      displayingItemData = widget.itemDataList.watch(context).where((e) => e.getName().toLowerCase().contains(itemSwapAllSearchTextController.value.text.toLowerCase())).toList();
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
                          selected: widget.itemDataList.watch(context).contains(displayingItemData[index]),
                          onTap: !widget.itemDataList.watch(context).contains(displayingItemData[index])
                              ? () {
                                  selectedItemData = displayingItemData[index];
                                  setState(() {});
                                }
                              : null,
                          trailing: OutlinedButton(
                              onPressed: widget.itemDataList.watch(context).contains(displayingItemData[index])
                                  ? () {
                                      selectedItemData = null;
                                      widget.itemDataList.watch(context).remove(displayingItemData[index]);
                                      setState(() {});
                                    }
                                  : null,
                              child: Text(appText.remove)),
                        ));
                  },
                )))
      ],
    );
  }
}

class ItemSwapAllSubmodGridLayout extends StatefulWidget {
  const ItemSwapAllSubmodGridLayout({super.key, required this.submodList, required this.scrollController, required this.selectedSubmods});

  final List<SubMod> submodList;
  final ScrollController scrollController;
  final Signal<List<SubMod>> selectedSubmods;

  @override
  State<ItemSwapAllSubmodGridLayout> createState() => _ItemSwapAllSubmodGridLayout();
}

class _ItemSwapAllSubmodGridLayout extends State<ItemSwapAllSubmodGridLayout> {
  TextEditingController itemSwapAllSubmodSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<SubMod> displayingSubmods = [];
    if (itemSwapAllSubmodSearchTextController.value.text.isEmpty) {
      displayingSubmods = widget.submodList;
    } else {
      displayingSubmods = widget.submodList.where((e) => e.submodName.toLowerCase().contains(itemSwapAllSubmodSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 30,
          child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
            SearchField<SubMod>(
              itemHeight: 90,
              searchInputDecoration: SearchInputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                  cursorHeight: 15,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                  cursorColor: Theme.of(context).colorScheme.primary),
              suggestions: displayingSubmods
                  .map(
                    (e) => SearchFieldListItem(
                      e.submodName,
                      item: e,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            spacing: 5,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: SubmodPreviewBox(imageFilePaths: e.previewImages, videoFilePaths: e.previewVideos, isNew: false),
                              ),
                              Text(e.submodName)
                            ],
                          )),
                    ),
                  )
                  .toList(),
              hint: appText.search,
              controller: itemSwapAllSubmodSearchTextController,
              onSuggestionTap: (p0) {
                itemSwapAllSubmodSearchTextController.text = p0.searchKey;
                // widget.selectedItemData.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return null;
              },
            ),
            Visibility(
              visible: itemSwapAllSubmodSearchTextController.value.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: IconButton(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onPressed: itemSwapAllSubmodSearchTextController.value.text.isNotEmpty
                        ? () {
                            itemSwapAllSubmodSearchTextController.clear();
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
                child: SuperListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 5,
                  ),
                  physics: const SuperRangeMaintainingScrollPhysics(),
                  controller: widget.scrollController,
                  itemCount: displayingSubmods.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      // height: 260,
                      child: Card(
                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(0))),
                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                        margin: EdgeInsets.zero,
                        elevation: 5,
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5,
                              children: [
                                // Stack(
                                //   alignment: AlignmentDirectional.bottomStart,
                                //   children: [
                                //     SubmodPreviewBox(
                                //         imageFilePaths: displayingSubmods[index].previewImages, videoFilePaths: displayingSubmods[index].previewVideos, isNew: displayingSubmods[index].isNew),
                                //     Visibility(
                                //         visible: displayingSubmods[index].hasCmx! ||
                                //             displayingSubmods[index].customAQMInjected! ||
                                //             displayingSubmods[index].boundingRemoved! ||
                                //             displayingSubmods[index].applyHQFilesOnly!,
                                //         child: Padding(
                                //           padding: const EdgeInsets.only(left: 5, bottom: 5),
                                //           child: Row(
                                //             spacing: 1,
                                //             mainAxisAlignment: MainAxisAlignment.start,
                                //             children: [
                                //               Visibility(
                                //                   visible: displayingSubmods[index].applyHQFilesOnly!,
                                //                   child: Icon(Icons.high_quality_outlined, color: selectedModsApplyHQFilesOnly ? Theme.of(context).colorScheme.primary : null)),
                                //               Visibility(visible: displayingSubmods[index].hasCmx!, child: InfoTag(info: appText.cmx, borderHighlight: displayingSubmods[index].cmxApplied!)),
                                //               Visibility(
                                //                   visible: displayingSubmods[index].customAQMInjected!,
                                //                   child: InfoTag(info: appText.aqm, borderHighlight: displayingSubmods[index].customAQMInjected!)),
                                //               Visibility(
                                //                   visible: displayingSubmods[index].boundingRemoved!,
                                //                   child: InfoTag(info: appText.bounding, borderHighlight: displayingSubmods[index].boundingRemoved!)),
                                //             ],
                                //           ),
                                //         )),
                                //   ],
                                // ),
                                Row(
                                  spacing: 2.5,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(displayingSubmods[index].modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                                    const Icon(Icons.arrow_right),
                                    Text(displayingSubmods[index].submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall),
                                  ],
                                ),
                                SizedBox(
                                    width: double.infinity,
                                    height: 30,
                                    child: OutlinedButton(
                                        onPressed: () {
                                          widget.selectedSubmods.value.contains(displayingSubmods[index])
                                              ? widget.selectedSubmods.value.remove(displayingSubmods[index])
                                              : widget.selectedSubmods.value.add(displayingSubmods[index]);
                                          setState(() {});
                                        },
                                        child: Text(widget.selectedSubmods.watch(context).contains(displayingSubmods[index]) ? appText.remove : appText.select))),
                              ],
                            )),
                      ),
                    );
                  },
                )))
      ],
    );
  }
}
