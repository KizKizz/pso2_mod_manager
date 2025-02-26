import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/mod_more_functions_menu.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ModViewV2Layout extends StatefulWidget {
  const ModViewV2Layout({super.key, required this.item, required this.mod, required this.searchString, required this.expandAll, required this.scrollController});

  final Item item;
  final Mod mod;
  final String searchString;
  final bool expandAll;
  final ScrollController scrollController;

  @override
  State<ModViewV2Layout> createState() => _ModViewV2LayoutState();
}

class _ModViewV2LayoutState extends State<ModViewV2Layout> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!modViewExpandState.watch(context)) {
      expanded = false;
    }
    // prep data
    List<SubmodCardLayout> displayingSubmodCards = widget.searchString.isEmpty
        ? widget.mod.submods
            .map((e) => SubmodCardLayout(
                  item: widget.item,
                  mod: widget.mod,
                  submod: e,
                  modSetName: '',
                  isInPopup: false,
                ))
            .toList()
        : widget.mod.submods
            .where((e) =>
                e.getModFileNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty ||
                e.submodName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
                e.modName.toLowerCase().contains(widget.searchString.toLowerCase()))
            .map((e) => SubmodCardLayout(
                  item: widget.item,
                  mod: widget.mod,
                  submod: e,
                  modSetName: '',
                  isInPopup: false,
                ))
            .toList();

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          // sticky: widget.expanded ? true : false,
          builder: (context, status) => InkWell(
                onTap: () => setState(() {
                  modViewExpandState.value = true;
                  expanded ? expanded = false : expanded = true;
                }),
                child: Card(
                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
                    color: !status.isPinned
                        ? Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))
                        : Theme.of(context).colorScheme.secondaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context)),
                    margin: EdgeInsets.zero,
                    elevation: 5,
                    child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.mod.modName, style: Theme.of(context).textTheme.titleMedium),
                                Row(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HeaderInfoBox(
                                        info: appText.dText(widget.mod.submods.length > 1 ? appText.numVariants : appText.numVariant, widget.mod.submods.length.toString()), borderHighlight: false),
                                    HeaderInfoBox(
                                      info: appText.dText(appText.numCurrentlyApplied, widget.mod.getNumOfAppliedSubmods().toString()),
                                      borderHighlight: widget.mod.applyStatus,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Row(
                              spacing: 2.5,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ModMoreFunctionsMenu(
                                  item: widget.item,
                                  mod: widget.mod,
                                  onDelete: () async {
                                    await modDelete(context, widget.item, widget.mod);
                                    modPopupStatus.value = '${widget.mod.modName} deleted';
                                    widget.item.isNew = widget.item.getModsIsNewState();
                                    if (widget.item.mods.isEmpty) {
                                      mainGridStatus.value = '"${widget.mod.modName}" in "${widget.item.getDisplayName()}" is empty and removed';
                                      if (selectedItemV2.value == widget.item) selectedItemV2.value = null;
                                    }
                                  },
                                ),
                                Icon(expanded || widget.expandAll ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                              ],
                            )
                          ],
                        ))),
              ),
          sliver: expanded || widget.expandAll
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  sliver: SuperSliverList.separated(
                    itemCount: displayingSubmodCards.length,
                    itemBuilder: (context, index) => SizedBox(height: 275, child: displayingSubmodCards[index]),
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(
                      height: 2.5,
                    ),
                  ))
              : null),
    );
  }
}
