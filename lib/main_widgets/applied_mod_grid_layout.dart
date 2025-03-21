import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/main_widgets/quick_swap_menu.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/category_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:signals/signals_flutter.dart';

class AppliedModGridLayout extends StatefulWidget {
  const AppliedModGridLayout({super.key, required this.category, required this.searchString, required this.scrollController});

  final Category category;
  final String searchString;
  final ScrollController scrollController;

  @override
  State<AppliedModGridLayout> createState() => _AppliedModGridLayoutState();
}

class _AppliedModGridLayoutState extends State<AppliedModGridLayout> {
  @override
  Widget build(BuildContext context) {
    // Current applying submod count
    int applyingSubmodCount = 0;
    for (var item in widget.category.items.where((e) => e.applyStatus)) {
      for (var mod in item.mods.where((e) => e.applyStatus)) {
        applyingSubmodCount = mod.submods.where((e) => e.applyStatus).length;
      }
    }

    // prep data
    List<ModCardLayout> modCardList = [];
    if (widget.searchString.isEmpty) {
      for (var item in widget.category.items.where((e) => e.applyStatus)) {
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            modCardList.add(ModCardLayout(
              item: item,
              mod: mod,
              submod: submod,
            ));
          }
        }
      }
    } else {
      for (var item in widget.category.items.where((e) => e.applyStatus)) {
        for (var mod in item.mods.where((e) => e.applyStatus)) {
          for (var submod in mod.submods.where((e) => e.applyStatus)) {
            if (mod.itemName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
                mod.modName.toLowerCase().contains(widget.searchString.toLowerCase()) ||
                mod.getDistinctNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty) {
              modCardList.add(ModCardLayout(
                item: item,
                mod: mod,
                submod: submod,
              ));
            }
          }
        }
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          sticky: widget.category.visible ? true : false,
          builder: (context, status) => InkWell(
                onTap: () {
                  widget.category.visible ? widget.category.visible = false : widget.category.visible = true;
                  widget.category.visible ? mainGridStatus.value = '${widget.category.categoryName} is collapsed' : mainGridStatus.value = '${widget.category.categoryName} is expanded';
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
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 5,
                          children: [
                            Text(widget.category.categoryName, style: Theme.of(context).textTheme.titleMedium),
                            Row(
                              spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HeaderInfoBox(info: appText.dText(applyingSubmodCount > 1 ? appText.numMods : appText.numMod, applyingSubmodCount.toString()), borderHighlight: false),
                                Icon(widget.category.visible ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                              ],
                            )
                          ],
                        ))),
              ),
          sliver: widget.category.visible
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(mainAxisExtent: 295, maxCrossAxisExtent: 450, mainAxisSpacing: 2.5, crossAxisSpacing: 2.5),
                      itemCount: modCardList.length,
                      itemBuilder: (context, index) => modCardList[index]),
                )
              : null),
    );
  }
}

class ModCardLayout extends StatefulWidget {
  const ModCardLayout({super.key, required this.item, required this.mod, required this.submod});

  final Item item;
  final Mod mod;
  final SubMod submod;

  @override
  State<ModCardLayout> createState() => _ModCardLayoutState();
}

class _ModCardLayoutState extends State<ModCardLayout> {
  @override
  Widget build(BuildContext context) {
    return CardOverlay(
      paddingValue: 5,
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
                  children: [
                    ItemIconBox(
                      item: widget.item,
                      showSubCategory: true,
                    ),
                    Text(widget.item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: SubmodPreviewBox(imageFilePaths: widget.submod.previewImages, videoFilePaths: widget.submod.previewVideos, isNew: widget.mod.isNew),
              )
            ],
          ),
          Expanded(
            child: Row(
              spacing: 2.5,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(widget.mod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                const Icon(Icons.arrow_right),
                Flexible(child: Text(widget.submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
              ],
            ),
          ),
          Row(
            spacing: 5,
            children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: !saveRestoreAppliedModsActive.watch(context)
                          ? () async {
                              await modToGameData(context, false, widget.item, widget.mod, widget.submod);
                            }
                          : null,
                      child: Text(appText.restore))),
              // Quick swap Menu
              QuickSwapMenu(item: widget.item, mod: widget.mod, submod: widget.submod),

              // Function menu
              SubmodMoreFunctionsMenu(
                item: widget.item,
                mod: widget.mod,
                isInPopup: true,
                submod: widget.submod,
                refresh: () {
                  setState(() {});
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
