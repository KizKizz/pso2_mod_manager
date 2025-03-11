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
import 'package:signals/signals_flutter.dart';

class CateItemGridLayout extends StatefulWidget {
  const CateItemGridLayout({super.key, required this.itemCate, required this.searchString, required this.scrollController});

  final Category itemCate;
  final String searchString;
  final ScrollController scrollController;

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

    // prep data
    List<ItemCardLayout> displayingItemCards = widget.searchString.isEmpty
        ? widget.itemCate.items.map((e) => ItemCardLayout(item: e)).toList()
        : widget.itemCate.items.where((e) => e.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty).map((e) => ItemCardLayout(item: e)).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          sticky: widget.itemCate.visible ? true : false,
          builder: (context, status) => InkWell(
                onTap: () {
                  widget.itemCate.visible ? widget.itemCate.visible = false : widget.itemCate.visible = true;
                  widget.itemCate.visible ? mainGridStatus.value = '${widget.itemCate.categoryName} is collapsed' : mainGridStatus.value = '${widget.itemCate.categoryName} is expanded';
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
                                HeaderInfoBox(
                                    info: appText.dText(widget.itemCate.items.length > 1 ? appText.numItems : appText.numItem, widget.itemCate.items.length.toString()), borderHighlight: false),
                                HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.itemCate.items.where((e) => e.applyStatus).length.toString()), borderHighlight: false),
                                Icon(widget.itemCate.visible ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                              ],
                            )
                          ],
                        ))),
              ),
          sliver: widget.itemCate.visible
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(mainAxisExtent: 250, maxCrossAxisExtent: 160, mainAxisSpacing: 2.5, crossAxisSpacing: 2.5),
                      itemCount: displayingItemCards.length,
                      itemBuilder: (context, index) => displayingItemCards[index]),
                )
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
    return InkWell(
      onTap: () async {
        await modViewPopup(context, widget.item);
        if (mounted) {
          setState(() {});
        }
      },
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      hoverColor: Theme.of(context).colorScheme.onPrimary.withAlpha(uiBackgroundColorAlpha.watch(context)),
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
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
                AspectRatio(aspectRatio: 1, child: ItemIconBox(item: widget.item, showSubCategory: true,)),
                Expanded(child: Center(child: Text(widget.item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge))),
                Column(
                  spacing: 2.5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InfoBox(
                      info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                      borderHighlight: false,
                    ),
                    InfoBox(
                      info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                      borderHighlight: widget.item.applyStatus,
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton(
                    //       onPressed: () async {
                    //         await modViewPopup(context, widget.item);
                    //         if (mounted) {
                    //           setState(() {});
                    //         }
                    //       },
                    //       child: Text(appText.viewMods)),
                    // )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
