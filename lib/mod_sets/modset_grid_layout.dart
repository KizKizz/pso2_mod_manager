import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/main_widgets/quick_swap_menu.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/modset_mod_view_popup.dart';
import 'package:pso2_mod_manager/mod_sets/modset_rename_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:signals/signals_flutter.dart';

class ModSetGridLayout extends StatefulWidget {
  const ModSetGridLayout({super.key, required this.modSet, required this.scrollController});

  final ModSet modSet;
  final ScrollController scrollController;

  @override
  State<ModSetGridLayout> createState() => _ModSetGridLayoutState();
}

class _ModSetGridLayoutState extends State<ModSetGridLayout> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (modSetRefreshSignal.watch(context) != modSetRefreshSignal.peek()) {
      setState(
        () {},
      );
    }
    // get data
    List<ModSetCardLayout> modCardList = [];
    for (var item in widget.modSet.setItems) {
      var (mod, submod) = item.getActiveInSet(widget.modSet.setName);
      if (mod != null && submod != null) modCardList.add(ModSetCardLayout(item: item, activeMod: mod, activeSubmod: submod, setName: widget.modSet.setName));
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 2.5),
      sliver: SliverStickyHeader.builder(
          sticky: widget.modSet.expanded ? true : false,
          builder: (context, status) => InkWell(
                onTap: () {
                  widget.modSet.expanded ? widget.modSet.expanded = false : widget.modSet.expanded = true;
                  widget.modSet.expanded ? modSetRefreshSignal.value = '${widget.modSet.setName} is collapsed' : modSetRefreshSignal.value = '${widget.modSet.setName} is expanded';
                  saveMasterModSetListToJson();
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
                            Text(widget.modSet.setName, style: Theme.of(context).textTheme.titleMedium),
                            Row(
                              spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Visibility(
                                  visible: widget.modSet.setItems.indexWhere((e) => !e.applyStatus) != -1,
                                  child: SizedBox(
                                      height: 25,
                                      child: OutlinedButton(
                                          onPressed: !saveRestoreAppliedModsActive.watch(context)
                                              ? () async {
                                                  for (var item in widget.modSet.setItems) {
                                                    int modIndex = item.mods.indexWhere((e) =>
                                                        e.isSet &&
                                                        e.setNames.contains(widget.modSet.setName) &&
                                                        e.submods.indexWhere((s) => s.activeInSets!.contains(widget.modSet.setName)) != -1 &&
                                                        !e.applyStatus);
                                                    if (modIndex != -1) {
                                                      Mod mod = item.mods[modIndex];
                                                      int submodIndex = mod.submods.indexWhere(
                                                          (e) => e.isSet && e.setNames.contains(widget.modSet.setName) && e.activeInSets!.contains(widget.modSet.setName) && !e.applyStatus);
                                                      if (submodIndex != -1) {
                                                        await modToGameData(context, true, item, mod, mod.submods[submodIndex]);
                                                        setState(() {
                                                          modSetRefreshSignal.value = 'Applied ${mod.submods[submodIndex].submodName} in ${item.getDisplayName()} in ${widget.modSet.setName} Set';
                                                        });
                                                      }
                                                    }
                                                  }
                                                }
                                              : null,
                                          child: Text(appText.applyThisSet))),
                                ),
                                Visibility(
                                  visible: widget.modSet.setItems.indexWhere((e) => e.applyStatus) != -1,
                                  child: SizedBox(
                                      height: 25,
                                      child: OutlinedButton(
                                          onPressed: !saveRestoreAppliedModsActive.watch(context)
                                              ? () async {
                                                  for (var item in widget.modSet.setItems.where((e) => e.applyStatus)) {
                                                    int modIndex = item.mods.indexWhere((e) =>
                                                        e.isSet &&
                                                        e.setNames.contains(widget.modSet.setName) &&
                                                        e.submods.indexWhere((s) => s.activeInSets!.contains(widget.modSet.setName)) != -1 &&
                                                        e.applyStatus);
                                                    if (modIndex != -1) {
                                                      Mod mod = item.mods[modIndex];
                                                      int submodIndex = mod.submods
                                                          .indexWhere((e) => e.isSet && e.setNames.contains(widget.modSet.setName) && e.activeInSets!.contains(widget.modSet.setName) && e.applyStatus);
                                                      if (submodIndex != -1) {
                                                        await modToGameData(context, false, item, mod, mod.submods[submodIndex]);
                                                        setState(() {
                                                          modSetRefreshSignal.value = 'Restored ${mod.submods[submodIndex].submodName} in ${item.getDisplayName()} in ${widget.modSet.setName} Set';
                                                        });
                                                      }
                                                    }
                                                  }
                                                }
                                              : null,
                                          child: Text(appText.restoreThisSet))),
                                ),
                                // Favorite button
                                IconButton.outlined(
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.adaptivePlatformDensity,
                                    onPressed: () {
                                      widget.modSet.setFavorite(widget.modSet.isFavorite! ? false : true);
                                      saveMasterModSetListToJson();
                                      mainGridStatus.value = '[${DateTime.now()}] ${widget.modSet.setName} - favorite has been set to ${widget.modSet.isFavorite.toString()}';
                                    },
                                    icon: Icon(widget.modSet.isFavorite! ? Icons.favorite : Icons.favorite_border)),
                                HeaderInfoBox(
                                    info: appText.dText(widget.modSet.setItems.length > 1 ? appText.numItems : appText.numItem, widget.modSet.setItems.length.toString()), borderHighlight: false),
                                HeaderInfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.modSet.setItems.where((e) => e.applyStatus).length.toString()), borderHighlight: false),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: PopupMenuButton(
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                                    color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
                                    padding: EdgeInsets.zero,
                                    menuPadding: EdgeInsets.zero,
                                    tooltip: '',
                                    elevation: 5,
                                    style: ButtonStyle(
                                        visualDensity: VisualDensity.adaptivePlatformDensity,
                                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(5))))),
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem(
                                            enabled: widget.modSet.setItems.indexWhere((e) => e.applyStatus) == -1,
                                            onTap: () async {
                                              final newName = await modSetRenamePopup(context, widget.modSet.setName);
                                              if (newName != null) {
                                                for (var item in widget.modSet.setItems) {
                                                  for (var mod in item.mods.where((e) => e.setNames.contains(widget.modSet.setName))) {
                                                    for (var submod in mod.submods.where((e) => e.setNames.contains(widget.modSet.setName))) {
                                                      submod.setNames.add(newName);
                                                      submod.setNames.removeWhere((e) => e == widget.modSet.setName);
                                                      if (submod.activeInSets!.contains(widget.modSet.setName)) {
                                                        submod.activeInSets!.add(newName);
                                                        submod.activeInSets!.removeWhere((e) => e == widget.modSet.setName);
                                                      }
                                                    }
                                                    mod.setNames.add(newName);
                                                    mod.setNames.removeWhere((e) => e == widget.modSet.setName);
                                                  }
                                                  item.setNames.add(newName);
                                                  item.setNames.removeWhere((e) => e == widget.modSet.setName);
                                                }
                                                widget.modSet.setName = newName;
                                                saveMasterModSetListToJson();
                                                saveMasterModListToJson();
                                                setState(() {});
                                              }
                                            },
                                            child: MenuIconItem(
                                              icon: Icons.edit,
                                              text: appText.rename,
                                              enabled: widget.modSet.setItems.indexWhere((e) => e.applyStatus) == -1,
                                            )),
                                        PopupMenuItem(
                                            enabled: widget.modSet.setItems.isNotEmpty,
                                            onTap: () async {
                                              await modSetDuplicate(widget.modSet);
                                              modSetRefreshSignal.value = '[${DateTime.now()}] duplicated ${widget.modSet.setName}';
                                              setState(() {});
                                            },
                                            child: MenuIconItem(
                                              icon: Icons.control_point_duplicate,
                                              text: appText.duplicate,
                                              enabled: widget.modSet.setItems.indexWhere((e) => e.applyStatus) == -1,
                                            )),
                                        PopupMenuItem(
                                            enabled: widget.modSet.setItems.indexWhere((e) => e.applyStatus) == -1,
                                            onTap: () async {
                                              await modSetDelete(context, widget.modSet);
                                              setState(() {
                                                modSetRefreshSignal.value = '[${DateTime.now()}] deleted ${widget.modSet.setName}';
                                              });
                                            },
                                            child: MenuIconItem(
                                              icon: Icons.delete_forever_outlined,
                                              text: appText.delete,
                                              enabled: widget.modSet.setItems.indexWhere((e) => e.applyStatus) == -1,
                                            )),
                                      ];
                                    },
                                  ),
                                ),
                                Icon(widget.modSet.expanded ? Icons.keyboard_double_arrow_up : Icons.keyboard_double_arrow_down)
                              ],
                            )
                          ],
                        ))),
              ),
          sliver: widget.modSet.expanded
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(mainAxisExtent: 305, maxCrossAxisExtent: 450, mainAxisSpacing: 2.5, crossAxisSpacing: 2.5),
                      itemCount: modCardList.length,
                      itemBuilder: (context, index) => modCardList[index]),
                )
              : null),
    );
  }
}

class ModSetCardLayout extends StatefulWidget {
  const ModSetCardLayout({super.key, required this.item, required this.activeMod, required this.activeSubmod, required this.setName});

  final Item item;
  final Mod activeMod;
  final SubMod activeSubmod;
  final String setName;

  @override
  State<ModSetCardLayout> createState() => _ModSetCardLayoutState();
}

class _ModSetCardLayoutState extends State<ModSetCardLayout> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
                  child: SubmodPreviewBox(imageFilePaths: widget.activeSubmod.previewImages, videoFilePaths: widget.activeSubmod.previewVideos, isNew: widget.activeSubmod.isNew),
                )
              ],
            ),
            Expanded(
              child: Row(
                spacing: 2,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: AutoSizeText(widget.activeMod.modName, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge)),
                  const Icon(Icons.arrow_right),
                  Flexible(
                      child: AutoSizeText(widget.activeSubmod.submodName, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelLarge)),
                ],
              ),
            ),
            Row(
              spacing: 2.5,
              children: [
                Expanded(
                    child: InfoBox(
                  info: appText.dText(widget.item.mods.where((e) => e.isSet && e.setNames.contains(widget.setName)).length > 1 ? appText.numMods : appText.numMod,
                      widget.item.mods.where((e) => e.isSet && e.setNames.contains(widget.setName)).length.toString()),
                  borderHighlight: false,
                )),
                Expanded(
                    child: InfoBox(
                  info: appText.dText(widget.item.getSubmods().where((e) => e.isSet && e.setNames.contains(widget.setName)).length > 1 ? appText.numVariants : appText.numVariant,
                      widget.item.getSubmods().where((e) => e.isSet && e.setNames.contains(widget.setName)).length.toString()),
                  borderHighlight: false,
                )),
                Expanded(
                    flex: 2,
                    child: InfoBox(
                      info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                      borderHighlight: false,
                    )),
              ],
            ),
            Row(
              spacing: 5,
              children: [
                Visibility(
                  visible:
                      widget.item.getSubmods().where((e) => e.isSet && e.setNames.contains(widget.setName)).length > 1 || widget.item.mods.where((e) => e.setNames.contains(widget.setName)).length > 1,
                  child: OutlinedButton(
                      onPressed: () {
                        modsetModViewPopup(context, widget.item, widget.setName);
                      },
                      child: Text(
                        appText.viewVariants,
                        textAlign: TextAlign.center,
                      )),
                ),
                Expanded(
                    child: OutlinedButton(
                        onPressed: !saveRestoreAppliedModsActive.watch(context)
                            ? () async {
                                if (!widget.activeSubmod.applyStatus) {
                                  await modToGameData(context, true, widget.item, widget.activeMod, widget.activeSubmod);
                                  modSetRefreshSignal.value = '[${DateTime.now()}] ${widget.activeSubmod.submodName} in ${widget.item.getDisplayName()} in ${widget.setName} Set was applied';
                                } else {
                                  await modToGameData(context, false, widget.item, widget.activeMod, widget.activeSubmod);
                                  modSetRefreshSignal.value = '[${DateTime.now()}] ${widget.activeSubmod.submodName} in ${widget.item.getDisplayName()} in ${widget.setName} Set was restored';
                                }
                                setState(() {});
                              }
                            : null,
                        child: Text(widget.activeSubmod.applyStatus ? appText.restore : appText.apply))),

                // Quick swap Menu
                QuickSwapMenu(item: widget.item, mod: widget.activeMod, submod: widget.activeSubmod),

                // Function menu
                SubmodMoreFunctionsMenu(
                  item: widget.item,
                  mod: widget.activeMod,
                  submod: widget.activeSubmod,
                  isInPopup: true,
                  refresh: () {
                    setState(() {});
                    modSetRefreshSignal.value = '[${DateTime.now()}] ${widget.item.itemName} > ${widget.activeMod.modName} > ${widget.activeSubmod.submodName} modified in set "${widget.setName}"';
                  },
                ),
                // IconButton.outlined(
                //     onPressed: () async {
                //       await submodAddToSet(context, widget.item, widget.activeMod, widget.activeSubmod);
                //       modSetRefreshSignal.value = '${widget.item.itemName} > ${widget.activeMod.modName} > ${widget.activeSubmod.submodName} modified in ${widget.setName}';
                //     },
                //     icon: const Icon(
                //       Icons.edit_attributes_outlined,
                //     ),
                //     visualDensity: VisualDensity.adaptivePlatformDensity),
              ],
            )
          ],
        ),
      ),
    );
  }
}
