import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sliver_sticky_collapsable_panel/utils/sliver_sticky_collapsable_panel_controller.dart';
import 'package:sliver_sticky_collapsable_panel/widgets/sliver_sticky_collapsable_panel.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class CategoryItemLayout extends StatefulWidget {
  const CategoryItemLayout({super.key, required this.category, required this.searchString, required this.scrollController, required this.refresh});

  final Category category;
  final String searchString;
  final ScrollController scrollController;
  final VoidCallback refresh;

  @override
  State<CategoryItemLayout> createState() => _CategoryItemLayoutState();
}

class _CategoryItemLayoutState extends State<CategoryItemLayout> {
  @override
  Widget build(BuildContext context) {
    // prep data
    List<ItemCardLayout> displayingItemCards = widget.searchString.isEmpty
        ? widget.category.items.map((e) => ItemCardLayout(item: e)).toList()
        : widget.category.items.where((e) => e.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty).map((e) => ItemCardLayout(item: e)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyCollapsablePanel(
          scrollController: widget.scrollController,
          controller: StickyCollapsablePanelController(),
          disableCollapsable: true,
          iOSStyleSticky: true,
          headerBuilder: (context, status) => InkWell(
                onTap: () {
                  widget.category.visible ? widget.category.visible = false : widget.category.visible = true;
                  saveMasterModListToJson();
                  setState(() {});
                },
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
                                Text('${appText.categoryTypeName(widget.category.group)} - ${appText.categoryName(widget.category.categoryName)}', style: Theme.of(context).textTheme.titleMedium),
                                Row(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    HeaderInfoBox(
                                        info: appText.dText(widget.category.items.length > 1 ? appText.numItems : appText.numItem, widget.category.items.length.toString()), borderHighlight: false),
                                    HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.category.items.where((e) => e.applyStatus).length.toString()), borderHighlight: false),
                                  ],
                                )
                              ],
                            ),
                            Icon(widget.category.visible ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                          ],
                        ))),
              ),
          sliverPanel: widget.category.visible
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  sliver: SuperSliverList.separated(
                    itemCount: displayingItemCards.length,
                    itemBuilder: (context, index) => displayingItemCards[index],
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(
                      height: 2.5,
                    ),
                  ))
              : null),
    );
  }
}

class ItemCardLayout extends StatefulWidget {
  const ItemCardLayout({super.key, required this.item});

  final Item item;

  @override
  State<ItemCardLayout> createState() => _ItemCardLayoutState();
}

class _ItemCardLayoutState extends State<ItemCardLayout> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 5,
              children: [
                AspectRatio(aspectRatio: 1, child: ItemIconBox(item: widget.item)),
                Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(child: Center(child: Text(widget.item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge))),
                    InfoBox(
                      info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                      borderHighlight: false,
                    ),
                    InfoBox(
                      info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                      borderHighlight: widget.item.applyStatus,
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
