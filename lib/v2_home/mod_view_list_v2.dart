import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/mod_view_v2_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:searchfield/searchfield.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ModViewListV2 extends StatefulWidget {
  const ModViewListV2({super.key, required this.item});

  final Item? item;

  @override
  State<ModViewListV2> createState() => _ModViewListV2State();
}

class _ModViewListV2State extends State<ModViewListV2> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchTextController = TextEditingController();
  bool expandAll = false;

  @override
  Widget build(BuildContext context) {
    // data prep
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

    return Column(
      spacing: 5,
      children: [
        Row(
          spacing: 2.5,
          children: [
            // Search box
            Expanded(
              child: SizedBox(
                height: 40,
                child: Stack(alignment: AlignmentDirectional.centerEnd, children: [
                  SearchField<Mod>(
                    itemHeight: 90,
                    searchInputDecoration: SearchInputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                        isDense: true,
                        contentPadding: const EdgeInsets.only(left: 20, right: 5, bottom: 30),
                        cursorHeight: 15,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Theme.of(context).colorScheme.inverseSurface)),
                        cursorColor: Theme.of(context).colorScheme.inverseSurface),
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
                    hint: appText.search,
                    controller: searchTextController,
                    onSuggestionTap: (p0) {
                      searchTextController.text = p0.searchKey;
                      setState(() {});
                    },
                    onSearchTextChanged: (p0) {
                      setState(() {});
                      return null;
                    },
                  ),
                  Visibility(
                    visible: searchTextController.value.text.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ElevatedButton(
                          onPressed: searchTextController.value.text.isNotEmpty
                              ? () {
                                  searchTextController.clear();
                                  setState(() {});
                                }
                              : null,
                          child: const Icon(Icons.close)),
                    ),
                  )
                ]),
              ),
            ),

            // col-ex
            SizedBox(
              height: 40,
              child: IconButton.outlined(
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
        ),

        // Main list
        Expanded(
          child: CustomScrollView(
            physics: const SuperRangeMaintainingScrollPhysics(),
            slivers: filteredMods
                .map((e) => ModViewV2Layout(
                      item: widget.item!,
                      mod: e,
                      searchString: searchTextController.text,
                      scrollController: scrollController,        
                    ))
                .toList(),
          ),
        )
      ],
    );
  }
}
