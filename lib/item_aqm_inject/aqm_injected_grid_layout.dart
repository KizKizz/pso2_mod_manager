import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_popup.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/mod_apply/item_icon_mark.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class AqmInjectedGridLayout extends StatefulWidget {
  const AqmInjectedGridLayout({super.key, required this.injectedItemList, required this.scrollController, required this.selectedAqmInjectedItem});

  final List<AqmInjectedItem> injectedItemList;
  final ScrollController scrollController;
  final Signal<AqmInjectedItem?> selectedAqmInjectedItem;

  @override
  State<AqmInjectedGridLayout> createState() => _AqmInjectedGridLayoutState();
}

class _AqmInjectedGridLayoutState extends State<AqmInjectedGridLayout> {
  TextEditingController injectedItemSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modAqmInjectingRefresh.watch(context) != modAqmInjectingRefresh.peek()) setState(() {});

    List<AqmInjectedItem> displayingAqmInjectedItem = [];
    if (injectedItemSearchTextController.value.text.isEmpty) {
      displayingAqmInjectedItem = widget.injectedItemList;
    } else {
      displayingAqmInjectedItem = widget.injectedItemList.where((e) => e.getName().toLowerCase().contains(injectedItemSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 30,
          child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
            SearchField<AqmInjectedItem>(
              itemHeight: 90,
              searchInputDecoration: SearchInputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                  cursorHeight: 15,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                  cursorColor: Theme.of(context).colorScheme.primary),
              suggestions: displayingAqmInjectedItem
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
              controller: injectedItemSearchTextController,
              onSuggestionTap: (p0) {
                injectedItemSearchTextController.text = p0.searchKey;
                widget.selectedAqmInjectedItem.value = p0.item;
                setState(() {});
              },
              onSearchTextChanged: (p0) {
                setState(() {});
                return null;
              },
            ),
            Visibility(
              visible: injectedItemSearchTextController.value.text.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: IconButton(
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onPressed: injectedItemSearchTextController.value.text.isNotEmpty
                        ? () {
                            injectedItemSearchTextController.clear();
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
                  itemCount: displayingAqmInjectedItem.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                      data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                      child: ListTile(
                        minTileHeight: 90,
                        title: Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GenericItemIconBox(iconImagePaths: [displayingAqmInjectedItem[index].iconImagePath], boxSize: const Size(80, 80), isNetwork: true),
                            Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayingAqmInjectedItem[index].getName(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  spacing: 5,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Visibility(visible: displayingAqmInjectedItem[index].isAqmReplaced!, child: InfoBox(info: appText.aqmInjected, borderHighlight: false)),
                                    Visibility(visible: displayingAqmInjectedItem[index].isBoundingRemoved!, child: InfoBox(info: appText.boundingRemoved, borderHighlight: false))
                                  ],
                                ),
                                Visibility(
                                    visible: displayingAqmInjectedItem[index].isAqmReplaced!,
                                    child:
                                        Text(appText.dText(appText.injectedAQMFile, p.basename(displayingAqmInjectedItem[index].injectedAQMFilePath!)), style: Theme.of(context).textTheme.labelMedium))
                              ],
                            ),
                          ],
                        ),
                        subtitle: widget.selectedAqmInjectedItem.watch(context) == displayingAqmInjectedItem[index]
                            ? Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(spacing: 5, crossAxisAlignment: CrossAxisAlignment.start, children: displayingAqmInjectedItem[index].getDetailsForAqmInject().map((e) => Text(e)).toList()),
                                  const HoriDivider(),
                                  OverflowBar(
                                    spacing: 5,
                                    overflowSpacing: 5,
                                    alignment: MainAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: displayingAqmInjectedItem[index].isAqmReplaced!,
                                        child: OutlinedButton(
                                            onPressed: () async {
                                              bool result = await aqmInjectPopup(
                                                  context,
                                                  displayingAqmInjectedItem[index].injectedAQMFilePath!,
                                                  displayingAqmInjectedItem[index].hqIcePath,
                                                  displayingAqmInjectedItem[index].lqIcePath,
                                                  displayingAqmInjectedItem[index].getName(),
                                                  true,
                                                  false,
                                                  false,
                                                  displayingAqmInjectedItem[index].isAqmReplaced!,
                                                  false);
                                              if (result && !displayingAqmInjectedItem[index].isBoundingRemoved!) {
                                                if (displayingAqmInjectedItem[index].isIconReplaced) {
                                                  await markedAqmItemIconRestore(displayingAqmInjectedItem[index].iconIcePath);
                                                }
                                                modAqmInjectingRefresh.value = 'Removed AQM and restored ${displayingAqmInjectedItem[index].getName()}';
                                                masterAqmInjectedItemList.removeAt(index);
                                              } else if (result && displayingAqmInjectedItem[index].isBoundingRemoved!) {
                                                displayingAqmInjectedItem[index].isAqmReplaced = false;
                                                displayingAqmInjectedItem[index].injectedHqIceMd5 =
                                                    await File(pso2binDirPath + p.separator + displayingAqmInjectedItem[index].hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                displayingAqmInjectedItem[index].injectedLqIceMd5 =
                                                    await File(pso2binDirPath + p.separator + displayingAqmInjectedItem[index].lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                modAqmInjectingRefresh.value = 'Removed AQM and restored ${displayingAqmInjectedItem[index].getName()}';
                                              }
                                              saveMasterAqmInjectListToJson();
                                            },
                                            child: Text(appText.removeCustomAQM)),
                                      ),
                                      Visibility(
                                        visible: displayingAqmInjectedItem[index].isBoundingRemoved!,
                                        child: OutlinedButton(
                                            onPressed: () async {
                                              bool result = await aqmInjectPopup(
                                                  context,
                                                  displayingAqmInjectedItem[index].injectedAQMFilePath!,
                                                  displayingAqmInjectedItem[index].hqIcePath,
                                                  displayingAqmInjectedItem[index].lqIcePath,
                                                  displayingAqmInjectedItem[index].getName(),
                                                  false,
                                                  true,
                                                  false,
                                                  displayingAqmInjectedItem[index].isAqmReplaced!,
                                                  false);
                                              if (result && !displayingAqmInjectedItem[index].isAqmReplaced!) {
                                                if (displayingAqmInjectedItem[index].isIconReplaced) {
                                                  await markedAqmItemIconRestore(displayingAqmInjectedItem[index].iconIcePath);
                                                }
                                                modAqmInjectingRefresh.value = 'Restored bounding ${displayingAqmInjectedItem[index].getName()}';
                                                masterAqmInjectedItemList.removeAt(index);
                                              } else if (result && displayingAqmInjectedItem[index].isAqmReplaced!) {
                                                displayingAqmInjectedItem[index].isBoundingRemoved = false;
                                                displayingAqmInjectedItem[index].injectedHqIceMd5 =
                                                    await File(pso2binDirPath + p.separator + displayingAqmInjectedItem[index].hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                displayingAqmInjectedItem[index].injectedLqIceMd5 =
                                                    await File(pso2binDirPath + p.separator + displayingAqmInjectedItem[index].lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                                modAqmInjectingRefresh.value = 'Restored bounding ${displayingAqmInjectedItem[index].getName()}';
                                              }
                                              saveMasterAqmInjectListToJson();
                                            },
                                            child: Text(appText.restoreBounding)),
                                      ),
                                      Visibility(
                                        visible: displayingAqmInjectedItem[index].isAqmReplaced! && displayingAqmInjectedItem[index].isBoundingRemoved!,
                                        child: OutlinedButton(
                                            onPressed: () async {
                                              bool result = await aqmInjectPopup(
                                                  context,
                                                  displayingAqmInjectedItem[index].injectedAQMFilePath!,
                                                  displayingAqmInjectedItem[index].hqIcePath,
                                                  displayingAqmInjectedItem[index].lqIcePath,
                                                  displayingAqmInjectedItem[index].getName(),
                                                  false,
                                                  false,
                                                  true,
                                                  displayingAqmInjectedItem[index].isAqmReplaced!,
                                                  false);
                                              if (result) {
                                                if (displayingAqmInjectedItem[index].isIconReplaced) {
                                                  await markedAqmItemIconRestore(displayingAqmInjectedItem[index].iconIcePath);
                                                }
                                                modAqmInjectingRefresh.value = 'Restored ${displayingAqmInjectedItem[index].getName()}';
                                                masterAqmInjectedItemList.removeAt(index);
                                              }
                                              saveMasterAqmInjectListToJson();
                                            },
                                            child: Text(appText.restoreAll)),
                                      )
                                    ],
                                  )
                                ],
                              )
                            : null,
                        selected: widget.selectedAqmInjectedItem.watch(context) == displayingAqmInjectedItem[index],
                        onTap: () {
                          widget.selectedAqmInjectedItem.value = displayingAqmInjectedItem[index];
                        },
                      ),
                    );
                  },
                )))
      ],
    );
  }
}
