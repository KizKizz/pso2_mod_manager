import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class CmlItemListLayout extends StatefulWidget {
  const CmlItemListLayout({super.key, required this.cmlItemList, required this.scrollController, required this.selectedCmlFile});

  final List<Cml> cmlItemList;
  final ScrollController scrollController;
  final Signal<File?> selectedCmlFile;

  @override
  State<CmlItemListLayout> createState() => _CmlItemListLayoutState();
}

class _CmlItemListLayoutState extends State<CmlItemListLayout> {
  TextEditingController injectedItemSearchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modAqmInjectingRefresh.watch(context) != modAqmInjectingRefresh.peek()) setState(() {});

    List<Cml> displayingCml = [];
    if (injectedItemSearchTextController.value.text.isEmpty) {
      displayingCml = widget.cmlItemList;
    } else {
      displayingCml = widget.cmlItemList.where((e) => e.getName().toLowerCase().contains(injectedItemSearchTextController.value.text.toLowerCase())).toList();
    }

    return Column(
      spacing: 5,
      children: [
        SizedBox(
          height: 30,
          child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
            SearchField<Cml>(
              itemHeight: 90,
              searchInputDecoration: SearchInputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 15),
                  cursorHeight: 15,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                  cursorColor: Theme.of(context).colorScheme.primary),
              suggestions: displayingCml
                  .map(
                    (e) => SearchFieldListItem(
                      e.getName(),
                      item: e,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            spacing: 5,
                            children: [
                              GenericItemIconBox(iconImagePaths: [e.cloudItemIconPath], boxSize: const Size(70, 70), isNetwork: true),
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
                  itemCount: displayingCml.length,
                  itemBuilder: (context, index) {
                    return ListTileTheme(
                      data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                      child: ListTile(
                        minTileHeight: 90,
                        title: Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GenericItemIconBox(iconImagePaths: [displayingCml[index].cloudItemIconPath], boxSize: const Size(80, 80), isNetwork: true),
                            Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayingCml[index].getName(),
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Visibility(
                                    visible: displayingCml[index].isReplaced,
                                    child: Text(appText.dText(appText.injectedAQMFile, displayingCml[index].replacedCmlFileName), style: Theme.of(context).textTheme.labelMedium))
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              onPressed: widget.selectedCmlFile.watch(context) != null && widget.selectedCmlFile.watch(context)!.existsSync()
                                  ? () async {
                                      setState(() {});
                                    }
                                  : null,
                              child: Text(appText.replace),
                            ),
                            OutlinedButton(
                                onPressed: displayingCml[index].isReplaced
                                    ? () async {
                                        setState(() {});
                                      }
                                    : null,
                                child: Text(appText.restore)),
                          ],
                        ),
                      ),
                    );
                  },
                )))
      ],
    );
  }
}
