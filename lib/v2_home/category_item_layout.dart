import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CategoryItemLayout extends StatefulWidget {
  const CategoryItemLayout({super.key, required this.category, required this.searchString, required this.scrollController});

  final Category category;
  final String searchString;
  final ScrollController scrollController;

  @override
  State<CategoryItemLayout> createState() => _CategoryItemLayoutState();
}

class _CategoryItemLayoutState extends State<CategoryItemLayout> {
  @override
  Widget build(BuildContext context) {
    // prep data
    List<ItemCardLayout> displayingItemCards = widget.searchString.isEmpty
        ? widget.category.items
            .map((e) => ItemCardLayout(
                  item: e,
                  onSelected: () => setState(() {
                    modViewExpandState.value = false;
                    selectedItemV2.value = e;
                  }),
                ))
            .toList()
        : widget.category.items
            .where((e) => e.itemName.toLowerCase().contains(widget.searchString.toLowerCase()))
            .map((e) => ItemCardLayout(
                  item: e,
                  onSelected: () => setState(() {
                    modViewExpandState.value = false;
                    selectedItemV2.value = e;
                  }),
                ))
            .toList();

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          // sticky: widget.category.visible ? true : false,
          builder: (context, status) => InkWell(
                onTap: widget.category.items.isNotEmpty
                    ? () {
                        widget.category.visible ? widget.category.visible = false : widget.category.visible = true;
                        saveMasterModListToJson();
                        setState(() {});
                      }
                    : null,
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
                            Flexible(
                              child: Column(
                                spacing: 5,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${appText.categoryTypeName(widget.category.group)} - ${appText.categoryName(widget.category.categoryName)}',
                                      overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                                  Row(
                                    spacing: 5,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InfoBox(
                                          info: appText.dText(widget.category.items.length > 1 ? appText.numItems : appText.numItem, widget.category.items.length.toString()), borderHighlight: false),
                                      InfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.category.items.where((e) => e.applyStatus).length.toString()), borderHighlight: false),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Visibility(visible: widget.category.items.isNotEmpty, child: Icon(widget.category.visible ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down))
                          ],
                        ))),
              ),
          sliver: widget.category.visible && widget.category.items.isNotEmpty
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
  const ItemCardLayout({super.key, required this.item, required this.onSelected});

  final Item item;
  final VoidCallback onSelected;

  @override
  State<ItemCardLayout> createState() => _ItemCardLayoutState();
}

class _ItemCardLayoutState extends State<ItemCardLayout> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: InkWell(
        onTap: () => widget.onSelected(),
        child: Card(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
            color: selectedItemV2.watch(context) != null && selectedItemV2.watch(context) == widget.item
                ? Theme.of(context).listTileTheme.selectedColor
                : Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 5,
                children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: ItemIconBox(
                        item: widget.item,
                        showSubCategory: false,
                      )),
                  Expanded(
                    child: Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(widget.item.getDisplayName(), overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge)),
                        Row(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: !aqmInjectCategoryDirs.contains(widget.item.category) && widget.item.subCategory!.isNotEmpty ? 0 : 1,
                              child: InfoBox(
                                info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                                borderHighlight: false,
                              ),
                            ),
                            // Visibility(
                            // visible: !aqmInjectCategoryDirs.contains(widget.item.category) && widget.item.subCategory!.isNotEmpty,
                            if (!aqmInjectCategoryDirs.contains(widget.item.category) && widget.item.subCategory!.isNotEmpty)
                              Expanded(
                                child: InfoBox(
                                    info: widget.item.category == defaultCategoryDirs[14]
                                        ? appText.motionTypeName(widget.item.subCategory!)
                                        : widget.item.category == defaultCategoryDirs[17]
                                            ? appText.weaponTypeName(widget.item.subCategory!.split('* ').last)
                                            : widget.item.subCategory!,
                                    borderHighlight: false),
                              ),
                            // ),
                          ],
                        ),
                        InfoBox(
                          info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                          borderHighlight: widget.item.applyStatus,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    spacing: 2.5,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 30,
                        child: IconButton.outlined(
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            style: ButtonStyle(
                                // backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                                side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                            onPressed: () async {
                              launchUrlString(widget.item.location);
                            },
                            icon: const Icon(
                              Icons.folder_open,
                            )),
                      ),
                      ItemMoreFunctionsMenu(
                        item: widget.item,
                        mod: null,
                        isInsidePopup: false,
                        isSingleModView: false,
                      )
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
