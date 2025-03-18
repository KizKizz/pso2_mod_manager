import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/info_tag.dart';
import 'package:pso2_mod_manager/main_widgets/mod_file_list_popup.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/main_widgets/quick_swap_menu.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class SubmodGridLayout extends StatefulWidget {
  const SubmodGridLayout({super.key, required this.item, required this.mod, required this.submods, required this.searchString, required this.modSetName, required this.isPopup});

  final Item item;
  final Mod mod;
  final List<SubMod> submods;
  final String searchString;
  final String modSetName;
  final bool isPopup;

  @override
  State<SubmodGridLayout> createState() => _SubmodGridLayoutState();
}

class _SubmodGridLayoutState extends State<SubmodGridLayout> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveSliverGridList(
        minItemWidth: 300,
        verticalGridMargin: 0,
        horizontalGridSpacing: 5,
        verticalGridSpacing: 5,
        children: widget.searchString.isEmpty
            ? widget.submods
                .map((e) => SubmodCardLayout(
                      submod: e,
                      item: widget.item,
                      mod: widget.mod,
                      modSetName: widget.modSetName,
                      isInPopup: widget.isPopup,
                    ))
                .toList()
            : widget.submods
                .where((e) =>
                    e.getModFileNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty || e.submodName.toLowerCase().contains(widget.searchString.toLowerCase()))
                .map((e) => SubmodCardLayout(
                      item: widget.item,
                      mod: widget.mod,
                      submod: e,
                      modSetName: widget.modSetName,
                      isInPopup: widget.isPopup,
                    ))
                .toList());
  }
}

class SubmodCardLayout extends StatefulWidget {
  const SubmodCardLayout({super.key, required this.item, required this.mod, required this.submod, required this.modSetName, required this.isInPopup});

  final Item item;
  final Mod mod;
  final SubMod submod;
  final String modSetName;
  final bool isInPopup;

  @override
  State<SubmodCardLayout> createState() => _SubmodCardLayoutState();
}

class _SubmodCardLayoutState extends State<SubmodCardLayout> {
  @override
  Widget build(BuildContext context) {
    return Card(
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
              Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  SubmodPreviewBox(imageFilePaths: widget.submod.previewImages, videoFilePaths: widget.submod.previewVideos, isNew: widget.submod.isNew),
                  Visibility(
                      visible: widget.submod.hasCmx! || widget.submod.customAQMInjected! || widget.submod.boundingRemoved! || widget.submod.applyHQFilesOnly!,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 5),
                        child: Row(
                          spacing: 1,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(
                                visible: widget.submod.applyHQFilesOnly!, child: Icon(Icons.high_quality_outlined, color: selectedModsApplyHQFilesOnly ? Theme.of(context).colorScheme.primary : null)),
                            Visibility(visible: widget.submod.hasCmx!, child: InfoTag(info: appText.cmx, borderHighlight: widget.submod.cmxApplied!)),
                            Visibility(visible: widget.submod.customAQMInjected!, child: InfoTag(info: appText.aqm, borderHighlight: widget.submod.customAQMInjected!)),
                            Visibility(visible: widget.submod.boundingRemoved!, child: InfoTag(info: appText.bounding, borderHighlight: widget.submod.boundingRemoved!)),
                          ],
                        ),
                      )),
                ],
              ),
              Expanded(child: Text(widget.submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium)),
              Row(spacing: 5, children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () async {
                          if (!widget.submod.applyStatus) {
                            await modToGameData(context, true, widget.item, widget.mod, widget.submod);
                          } else {
                            await modToGameData(context, false, widget.item, widget.mod, widget.submod);
                          }
                        },
                        child: Text(widget.submod.applyStatus ? appText.restore : appText.apply))),
                Visibility(
                    visible: widget.modSetName.isNotEmpty,
                    child: ModManTooltip(
                      message: widget.submod.activeInSets!.contains(widget.modSetName)
                          ? appText.dTexts(appText.submodIsCurrentlyActiveInSet, [widget.submod.submodName, widget.modSetName])
                          : appText.dTexts(appText.setSubmodToBeActiveInSet, [widget.submod.submodName, widget.modSetName]),
                      child: IconButton.outlined(
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          onPressed: !widget.submod.activeInSets!.contains(widget.modSetName)
                              ? () {
                                  for (var mod in widget.item.mods) {
                                    for (var submod in mod.submods) {
                                      submod.activeInSets!.removeWhere((e) => e == widget.modSetName);
                                    }
                                  }
                                  if (!widget.submod.activeInSets!.contains(widget.modSetName)) widget.submod.activeInSets!.add(widget.modSetName);
                                  modPopupStatus.value = '"${widget.modSetName}" active submod changed to "${widget.submod.submodName}" in "${widget.item.getDisplayName()}"';
                                  saveMasterModListToJson();
                                  saveMasterModSetListToJson();
                                }
                              : null,
                          icon: Icon(widget.submod.activeInSets!.contains(widget.modSetName) ? Icons.check_box_outlined : Icons.check_box_outline_blank_rounded,
                              color: widget.submod.activeInSets!.contains(widget.modSetName) ? Theme.of(context).colorScheme.primary : null)),
                    )),
                // Ice file list button
                IconButton.outlined(
                    visualDensity: VisualDensity.adaptivePlatformDensity, onPressed: () => modFileListPopup(context, widget.item, widget.mod, widget.submod), icon: const Icon(Icons.list)),

                // Quick swap Menu
                QuickSwapMenu(item: widget.item, mod: widget.mod, submod: widget.submod),

                // Function menu
                SubmodMoreFunctionsMenu(
                  item: widget.item,
                  mod: widget.mod,
                  submod: widget.submod,
                  isInPopup: widget.isInPopup,
                  refresh: () {
                    setState(() {});
                  },
                )
              ]),
            ],
          )),
    );
  }
}
