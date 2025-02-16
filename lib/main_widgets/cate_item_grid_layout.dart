import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/mod_view_popup.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class CateItemGridLayout extends StatefulWidget {
  const CateItemGridLayout({super.key, required this.itemCate, required this.searchString});

  final Category itemCate;
  final String searchString;

  @override
  State<CateItemGridLayout> createState() => _CateItemGridLayoutState();
}

class _CateItemGridLayoutState extends State<CateItemGridLayout> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }
    return SliverStickyHeader.builder(
        builder: (context, state) => Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            color: state.isPinned
                ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context))
                : Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${appText.categoryTypeName(widget.itemCate.group)} - ${appText.categoryName(widget.itemCate.categoryName)}', style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HeaderInfoBox(info: appText.dText(widget.itemCate.items.length > 1 ? appText.numItems : appText.numItem, widget.itemCate.items.length.toString()), borderHighlight: false),
                        HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.itemCate.items.where((e) => e.applyStatus).length.toString()), borderHighlight: false),
                        IconButton(
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                            onPressed: () {
                              widget.itemCate.visible ? widget.itemCate.visible = false : widget.itemCate.visible = true;
                              widget.itemCate.visible ? mainGridStatus.value = '${widget.itemCate.categoryName} is collapsed' : mainGridStatus.value = '${widget.itemCate.categoryName} is expanded';
                              saveMasterModListToJson();
                              setState(() {});
                            },
                            icon: Icon(widget.itemCate.visible ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down))
                      ],
                    )
                  ],
                ))),
        sliver: ResponsiveSliverGridList(
            minItemWidth: 150,
            verticalGridMargin: 5,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 5,
            children: widget.itemCate.visible
                ? widget.searchString.isEmpty
                    ? widget.itemCate.items.map((e) => ItemCardLayout(item: e)).toList()
                    : widget.itemCate.items
                        .where((e) => e.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty)
                        .map((e) => ItemCardLayout(item: e))
                        .toList()
                : []));
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
    return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              ItemIconBox(item: widget.item),
              Text(widget.item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
              Column(
                spacing: 5,
                children: [
                  InfoBox(
                    info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                    borderHighlight: false,
                  ),
                  InfoBox(
                    info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                    borderHighlight: widget.item.applyStatus,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () async {
                          await modViewPopup(context, widget.item);
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: Text(appText.viewMods)),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
