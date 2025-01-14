import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_view_popup.dart';
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
    return SliverStickyHeader.builder(
        builder: (context, state) => Card(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            color: state.isPinned
                ? Theme.of(context).colorScheme.secondaryContainer.withAlpha(uiBackgroundColorAlpha.watch(context))
                : Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            margin: EdgeInsets.zero,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('${appText.categoryTypeName(widget.itemCate.group)} - ${appText.categoryName(widget.itemCate.categoryName)}', style: Theme.of(context).textTheme.titleMedium),
            )),
        sliver: ResponsiveSliverGridList(minItemWidth: 260, verticalGridMargin: 5, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: modCardFetch()));
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
          if (mod.itemName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
              mod.modName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
              mod.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty) {
            modCardList.add(ModCardLayout(item: item, mod: mod));
          }
        }
      }
    }

    return modCardList;
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
              SubmodImageBox(filePaths: widget.mod.previewImages, isNew: widget.mod.isNew),
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
                    borderHighlight: false,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () async {
                          await submodViewPopup(context, widget.item, widget.mod);
                          setState(() {});
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
