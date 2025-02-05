import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_view_popup.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class CateModGridLayout extends StatefulWidget {
  const CateModGridLayout({super.key, required this.itemCate, required this.searchString});

  final Category itemCate;
  final String searchString;

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

    List<ModCardLayout> modCardFetch() {
      List<ModCardLayout> modCardList = [];
      if (widget.searchString.isEmpty) {
        for (var item in widget.itemCate.items) {
          modCardList.addAll(item.mods.map((m) => ModCardLayout(item: item, mod: m)));
        }
      } else {
        for (var item in widget.itemCate.items) {
          for (var mod in item.mods) {
            if (mod.itemName.replaceFirst('_', '/').trim().toLowerCase().contains(widget.searchString.toLowerCase()) ||
                mod.modName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
                mod.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty) {
              modCardList.add(ModCardLayout(item: item, mod: mod));
            }
          }
        }
      }

      return modCardList;
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
                        HeaderInfoBox(info: appText.dText(modNum > 1 ? appText.numMods : appText.numMod, modNum.toString()), borderHighlight: false),
                        HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, modAppliedNum.toString()), borderHighlight: false)
                      ],
                    )
                  ],
                ))),
        sliver: ResponsiveSliverGridList(minItemWidth: 260, verticalGridMargin: 5, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: modCardFetch()));
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
              SubmodPreviewBox(imageFilePaths: widget.mod.previewImages, videoFilePaths: widget.mod.previewVideos, isNew: widget.mod.isNew),
              Text(widget.mod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
              Column(
                spacing: 5,
                children: [
                  InfoBox(
                    info: appText.dText(widget.mod.submods.length > 1 ? appText.numVariants : appText.numVariant, widget.mod.submods.length.toString()),
                    borderHighlight: false,
                  ),
                  InfoBox(
                    info: appText.dText(appText.numCurrentlyApplied, widget.mod.getNumOfAppliedSubmods().toString()),
                    borderHighlight: widget.mod.applyStatus,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () async {
                          await submodViewPopup(context, widget.item, widget.mod);
                          if (mounted) setState(() {});
                        },
                        child: Text(appText.viewVariants)),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
