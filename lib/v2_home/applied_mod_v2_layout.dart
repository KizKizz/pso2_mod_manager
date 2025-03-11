import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_more_functions_menu.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppliedModV2Layout extends StatefulWidget {
  const AppliedModV2Layout({super.key, required this.item, required this.searchString, required this.expandAll, required this.scrollController});

  final Item item;
  final String searchString;
  final bool expandAll;
  final ScrollController scrollController;

  @override
  State<AppliedModV2Layout> createState() => _AppliedModV2LayoutState();
}

class _AppliedModV2LayoutState extends State<AppliedModV2Layout> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    // if (!modViewExpandState.watch(context)) {
    //   expanded = false;
    // }
    // prep data
    List<SubmodCardLayout> displayingSubmodCards = [];
    if (widget.searchString.isEmpty) {
      for (var mod in widget.item.mods.where((e) => e.applyStatus)) {
        for (var submod in mod.submods.where((e) => e.applyStatus)) {
          displayingSubmodCards.add(SubmodCardLayout(
            item: widget.item,
            mod: mod,
            submod: submod,
            modSetName: '',
            isInPopup: false,
          ));
        }
      }
    } else {
      for (var mod in widget.item.mods.where((e) => e.applyStatus)) {
        for (var submod in mod.submods.where((e) =>
            e.applyStatus &&
            (e.getModFileNames().where((i) => i.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty || e.submodName.toLowerCase().contains(widget.searchString.toLowerCase())))) {
          displayingSubmodCards.add(SubmodCardLayout(
            item: widget.item,
            mod: mod,
            submod: submod,
            modSetName: '',
            isInPopup: false,
          ));
        }
      }
    }

    String firstAppliedModName = '';
    int modIndex = widget.item.mods.indexWhere((e) => e.applyStatus);
    if (modIndex != -1) {
      Mod appliedMod = widget.item.mods[modIndex];
      int submodIndex = appliedMod.submods.indexWhere((e) => e.applyStatus);
      if (submodIndex != -1) {
        firstAppliedModName = '${appliedMod.modName} > ${appliedMod.submods[submodIndex].submodName}';
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          // sticky: widget.expanded ? true : false,
          builder: (context, status) => InkWell(
                onTap: () => setState(() {
                  modViewExpandState.value = true;
                  expanded ? expanded = false : expanded = true;
                }),
                child: SizedBox(
                  height: 93,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  AspectRatio(aspectRatio: 1, child: ItemIconBox(item: widget.item, showSubCategory: false,)),
                                  Column(
                                    spacing: 5,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        spacing: 5,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(widget.item.getDisplayName(), overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge),
                                          Visibility(
                                            visible: !aqmInjectCategoryDirs.contains(widget.item.category) && widget.item.subCategory!.isNotEmpty,
                                              child: InfoBox(
                                                    info: widget.item.category == defaultCategoryDirs[14]
                                                        ? appText.motionTypeName(widget.item.subCategory!)
                                                        : widget.item.category == defaultCategoryDirs[17]
                                                            ? appText.weaponTypeName(widget.item.subCategory!.split('* ').last)
                                                            : widget.item.subCategory!,
                                                    borderHighlight: false),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        spacing: 5,
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
                                        ],
                                      ),
                                      Row(
                                        spacing: 5,
                                        children: [
                                          SizedBox(
                                            height: 25,
                                            child: OutlinedButton(
                                                onPressed: () async {
                                                  selectedItemV2.value = widget.item;
                                                },
                                                child: Text(appText.details)),
                                          ),
                                          Visibility(
                                            visible: widget.item.getNumOfAppliedMods() == 1,
                                            child: ModManTooltip(
                                              message: firstAppliedModName,
                                              child: SizedBox(
                                                height: 25,
                                                child: OutlinedButton(
                                                    onPressed: () async {
                                                      int modIndex = widget.item.mods.indexWhere((e) => e.applyStatus);
                                                      if (modIndex != -1) {
                                                        Mod appliedMod = widget.item.mods[modIndex];
                                                        int submodIndex = appliedMod.submods.indexWhere((e) => e.applyStatus);
                                                        if (submodIndex != -1) {
                                                          await modToGameData(context, false, widget.item, appliedMod, appliedMod.submods[submodIndex]);
                                                        }
                                                      }
                                                    },
                                                    child: Text(appText.restore)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                spacing: 2.5,
                                children: [
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
                                        isInsidePopup: false,
                                      )
                                    ],
                                  ),
                                  Icon(expanded || widget.expandAll ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                                ],
                              )
                            ],
                          ))),
                ),
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
