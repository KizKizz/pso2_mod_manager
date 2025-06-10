import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/fav_box.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_view_popup.dart';
import 'package:signals/signals_flutter.dart';

class CateModGridLayout extends StatefulWidget {
  const CateModGridLayout({super.key, required this.itemCate, required this.searchString, required this.scrollController});

  final Category itemCate;
  final String searchString;
  final ScrollController scrollController;

  @override
  State<CateModGridLayout> createState() => _CateModGridLayoutState();
}

class _CateModGridLayoutState extends State<CateModGridLayout> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (mainGridStatus.watch(context) != mainGridStatus.peek()) {
      setState(
        () {},
      );
    }
    // Get ext
    int modNum = 0;
    int modAppliedNum = 0;
    for (var item in widget.itemCate.items) {
      modNum += item.mods.length;
      modAppliedNum += item.mods.where((e) => e.applyStatus).length;
    }

    List<(Item, Mod)> allMods = [];
    List<ModCardLayout> modCardList = [];
    if (widget.searchString.isEmpty) {
      for (var item in widget.itemCate.items) {
        allMods.addAll(item.mods.map((e) => (item, e)));
      }
    } else {
      for (var item in widget.itemCate.items) {
        for (var mod in item.mods) {
          if (mod.itemName.replaceFirst('_', '/').trim().toLowerCase().contains(widget.searchString.toLowerCase()) ||
              mod.modName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
              mod.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty) {
            allMods.add((item, mod));
          }
        }
      }
    }

    // Sort
    if (selectedDisplaySort.value == modSortingSelections[0]) {
      allMods.sort((a, b) => a.$2.favoriteSort().compareTo(b.$2.favoriteSort()));
    } else if (selectedDisplaySort.value == modSortingSelections[1]) {
      allMods.sort((a, b) => a.$2.hasPreviewsSort().compareTo(b.$2.hasPreviewsSort()));
    } else if (selectedDisplaySort.value == modSortingSelections[2]) {
      allMods.sort((a, b) => a.$2.modName.toLowerCase().compareTo(b.$2.modName.toLowerCase()));
    } else if (selectedDisplaySort.value == modSortingSelections[3]) {
      allMods.sort((a, b) => b.$2.creationDate!.compareTo(a.$2.creationDate!));
    } else if (selectedDisplaySort.value == modSortingSelections[4]) {
      allMods.sort((a, b) => b.$2.applyDate.compareTo(a.$2.applyDate));
    }
    modCardList.addAll(allMods.map((e) => ModCardLayout(item: e.$1, mod: e.$2)));

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          sticky: widget.itemCate.visible ? true : false,
          builder: (context, status) => InkWell(
                onTap: () {
                  widget.itemCate.visible ? widget.itemCate.visible = false : widget.itemCate.visible = true;
                  widget.itemCate.visible
                      ? mainGridStatus.value = '[${DateTime.now()}] ${widget.itemCate.categoryName} is collapsed'
                      : mainGridStatus.value = '${widget.itemCate.categoryName} is expanded';
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
                                HeaderInfoBox(info: appText.dText(modNum > 1 ? appText.numMods : appText.numMod, modNum.toString()), borderHighlight: false),
                                HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, modAppliedNum.toString()), borderHighlight: false),
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
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(mainAxisExtent: 290.5, maxCrossAxisExtent: 450, mainAxisSpacing: 2.5, crossAxisSpacing: 2.5),
                      itemCount: modCardList.length,
                      itemBuilder: (context, index) => modCardList[index]),
                )
              : null),
    );
  }
}

class ModCardLayout extends StatefulWidget {
  const ModCardLayout({super.key, required this.item, required this.mod});

  final Item item;
  final Mod mod;

  @override
  State<ModCardLayout> createState() => _ModCardLayoutState();
}

class _ModCardLayoutState extends State<ModCardLayout> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await submodViewPopup(context, widget.item, widget.mod);
        if (mounted) setState(() {});
      },
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      hoverColor: Theme.of(context).colorScheme.onPrimary.withAlpha(uiBackgroundColorAlpha.watch(context)),
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 2.5,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Row(
                  spacing: 2.5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ItemIconBox(
                            item: widget.item,
                            showSubCategory: true,
                          ),
                          Flexible(child: Text(widget.item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: SubmodPreviewBox(imageFilePaths: widget.mod.previewImages, videoFilePaths: widget.mod.previewVideos, isNew: widget.mod.isNew),
                    )
                  ],
                ),
                Expanded(
                    child: Center(child: AutoSizeText(widget.mod.modName, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1, style: Theme.of(context).textTheme.labelLarge))),
                Column(
                  spacing: 2.5,
                  children: [
                    Row(
                      spacing: 2.5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: InfoBox(
                            info: appText.dText(widget.mod.submods.length > 1 ? appText.numVariants : appText.numVariant, widget.mod.submods.length.toString()),
                            borderHighlight: false,
                          ),
                        ),
                        if (widget.mod.isFavorite) FavoriteBox()
                      ],
                    ),
                    InfoBox(
                      info: appText.dText(appText.numCurrentlyApplied, widget.mod.getNumOfAppliedSubmods().toString()),
                      borderHighlight: widget.mod.applyStatus,
                    ),

                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton(
                    //       onPressed: () async {
                    //         await submodViewPopup(context, widget.item, widget.mod);
                    //         if (mounted) setState(() {});
                    //       },
                    //       child: Text(appText.viewVariants)),
                    // )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
