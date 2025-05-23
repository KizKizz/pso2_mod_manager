import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_popup.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/mod_apply/item_icon_mark.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class AqmInjectGridLayout extends StatefulWidget {
  const AqmInjectGridLayout({super.key, required this.itemDataList, required this.scrollController, required this.selectedItemData});

  final List<ItemData> itemDataList;
  final ScrollController scrollController;
  final Signal<ItemData?> selectedItemData;

  @override
  State<AqmInjectGridLayout> createState() => _AqmInjectGridLayoutState();
}

class _AqmInjectGridLayoutState extends State<AqmInjectGridLayout> {
  TextEditingController itemSwapSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modAqmInjectingRefresh.watch(context) != modAqmInjectingRefresh.peek()) {
      setState(() {});
    }

    // Filtered data
    List<ItemData> displayingItemData = [];
    if (itemSwapSearchTextController.value.text.isEmpty) {
      displayingItemData = widget.itemDataList;
    } else {
      displayingItemData = widget.itemDataList.where((e) => e.getName().toLowerCase().contains(itemSwapSearchTextController.value.text.toLowerCase())).toList();
    }

    List<String> currentlyAppliedFiles = [];
    for (var type in masterModList) {
      for (var cate in type.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
        for (var item in cate.items.where((e) => e.applyStatus)) {
          for (var mod in item.mods.where((e) => e.applyStatus)) {
            for (var submod in mod.submods.where((e) => e.applyStatus)) {
              for (var modFile in submod.modFiles.where((e) => e.applyStatus)) {
                if (!currentlyAppliedFiles.contains(modFile.modFileName)) {
                  currentlyAppliedFiles.add(modFile.modFileName);
                }
              }
            }
          }
        }
      }
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
              controller: itemSwapSearchTextController,
              onSuggestionTap: (p0) {
                itemSwapSearchTextController.text = p0.searchKey;
                widget.selectedItemData.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return [];
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
                        enabled: !currentlyAppliedFiles.contains(p.basenameWithoutExtension(displayingItemData[index].getHQIceName())) &&
                            !currentlyAppliedFiles.contains(p.basenameWithoutExtension(displayingItemData[index].getLQIceName())) &&
                            masterAqmInjectedItemList.indexWhere((e) => e.getName() == displayingItemData[index].getName()) == -1,
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
                        subtitle: widget.selectedItemData.watch(context) == displayingItemData[index]
                            ? Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(spacing: 5, crossAxisAlignment: CrossAxisAlignment.start, children: displayingItemData[index].getDetailsForAqmInject().map((e) => Text(e)).toList()),
                                  const HoriDivider(),
                                  OverflowBar(
                                    spacing: 5,
                                    overflowSpacing: 5,
                                    alignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                          onPressed: masterAqmInjectedItemList.indexWhere((e) => e.getName() == displayingItemData[index].getName()) == -1 &&
                                                  selectedCustomAQMFilePath.watch(context).isNotEmpty &&
                                                  File(selectedCustomAQMFilePath.value).existsSync()
                                              ? () async {
                                                  AqmInjectedItem newItem = AqmInjectedItem(
                                                      displayingItemData[index].category,
                                                      displayingItemData[index].getItemIDs().first,
                                                      displayingItemData[index].getItemIDs().last,
                                                      displayingItemData[index].iconImagePath,
                                                      displayingItemData[index].getENNameOriginal(),
                                                      displayingItemData[index].getJPNameOriginal(),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getHQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getLQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getIconIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      selectedCustomAQMFilePath.value,
                                                      '',
                                                      '',
                                                      false,
                                                      false,
                                                      false,
                                                      false);

                                                  bool result = await aqmInjectPopup(context, newItem.injectedAQMFilePath!, newItem.hqIcePath, newItem.lqIcePath, displayingItemData[index].getName(),
                                                      false, false, false, false, false);
                                                  if (result) {
                                                    if (replaceItemIconOnApplied) {
                                                      newItem.isIconReplaced = await markedAqmItemIconApply(newItem.iconIcePath);
                                                    }
                                                    newItem.injectedHqIceMd5 = await File(pso2binDirPath + p.separator + newItem.hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.injectedLqIceMd5 = await File(pso2binDirPath + p.separator + newItem.lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.isAqmReplaced = true;
                                                    newItem.isApplied = true;
                                                    masterAqmInjectedItemList.add(newItem);
                                                    modAqmInjectingRefresh.value = 'Injected AQM into ${newItem.getName()}';
                                                    saveMasterAqmInjectListToJson();
                                                  }
                                                }
                                              : null,
                                          child: Text(appText.injectAQM)),
                                      OutlinedButton(
                                          onPressed: masterAqmInjectedItemList.indexWhere((e) => e.getName() == displayingItemData[index].getName()) == -1
                                              ? () async {
                                                  AqmInjectedItem newItem = AqmInjectedItem(
                                                      displayingItemData[index].category,
                                                      displayingItemData[index].getItemIDs().first,
                                                      displayingItemData[index].getItemIDs().last,
                                                      displayingItemData[index].iconImagePath,
                                                      displayingItemData[index].getENNameOriginal(),
                                                      displayingItemData[index].getJPNameOriginal(),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getHQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getLQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getIconIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      selectedCustomAQMFilePath.value,
                                                      '',
                                                      '',
                                                      false,
                                                      false,
                                                      false,
                                                      false);

                                                  bool result = await itemCustomAqmBounding(context, newItem.hqIcePath, newItem.lqIcePath, displayingItemData[index].getName());
                                                  if (result) {
                                                    newItem.injectedHqIceMd5 = await File(pso2binDirPath + p.separator + newItem.hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.injectedLqIceMd5 = await File(pso2binDirPath + p.separator + newItem.lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.isBoundingRemoved = true;
                                                    newItem.isApplied = true;
                                                    masterAqmInjectedItemList.add(newItem);
                                                    if (replaceItemIconOnApplied) {
                                                      newItem.isIconReplaced = await markedAqmItemIconApply(newItem.iconIcePath);
                                                    }
                                                    modAqmInjectingRefresh.value = 'Removed Bounding from ${newItem.getName()}';
                                                    saveMasterAqmInjectListToJson();
                                                  }
                                                }
                                              : null,
                                          child: Text(appText.removeBounding)),
                                      OutlinedButton(
                                          onPressed: masterAqmInjectedItemList.indexWhere((e) => e.getName() == displayingItemData[index].getName()) == -1 &&
                                                  selectedCustomAQMFilePath.watch(context).isNotEmpty &&
                                                  File(selectedCustomAQMFilePath.value).existsSync()
                                              ? () async {
                                                  AqmInjectedItem newItem = AqmInjectedItem(
                                                      displayingItemData[index].category,
                                                      displayingItemData[index].getItemIDs().first,
                                                      displayingItemData[index].getItemIDs().last,
                                                      displayingItemData[index].iconImagePath,
                                                      displayingItemData[index].getENNameOriginal(),
                                                      displayingItemData[index].getJPNameOriginal(),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getHQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getLQIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      p.withoutExtension(oItemData
                                                          .firstWhere(
                                                            (e) => e.path.contains(displayingItemData[index].getIconIceName()),
                                                            orElse: () => OfficialIceFile.empty(),
                                                          )
                                                          .path),
                                                      selectedCustomAQMFilePath.value,
                                                      '',
                                                      '',
                                                      false,
                                                      false,
                                                      false,
                                                      false);

                                                  bool aqmResult = await aqmInjectPopup(context, newItem.injectedAQMFilePath!, newItem.hqIcePath, newItem.lqIcePath,
                                                      displayingItemData[index].getName(), false, false, false, false, false);
                                                  // ignore: use_build_context_synchronously
                                                  bool boundingResult = await itemCustomAqmBounding(context, newItem.hqIcePath, newItem.lqIcePath, displayingItemData[index].getName());
                                                  if (aqmResult || boundingResult) {
                                                    newItem.injectedHqIceMd5 = await File(pso2binDirPath + p.separator + newItem.hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.injectedLqIceMd5 = await File(pso2binDirPath + p.separator + newItem.lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                    newItem.isAqmReplaced = aqmResult;
                                                    newItem.isBoundingRemoved = boundingResult;
                                                    newItem.isApplied = true;
                                                    masterAqmInjectedItemList.add(newItem);
                                                    if (replaceItemIconOnApplied) {
                                                      newItem.isIconReplaced = await markedAqmItemIconApply(newItem.iconIcePath);
                                                    }
                                                    modAqmInjectingRefresh.value = 'Injected AQM and removed Bounding from ${newItem.getName()}';
                                                    saveMasterAqmInjectListToJson();
                                                  }
                                                }
                                              : null,
                                          child: Text(appText.both))
                                    ],
                                  )
                                ],
                              )
                            : null,
                        selected: widget.selectedItemData.watch(context) == displayingItemData[index],
                        onTap: () {
                          widget.selectedItemData.value = displayingItemData[index];
                        },
                      ),
                    );
                  },
                )))
      ],
    );
  }
}
