import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bounding_radius_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_popup.dart';
import 'package:pso2_mod_manager/main_widgets/info_tag.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';
import 'package:star_menu/star_menu.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SubmodGridLayout extends StatefulWidget {
  const SubmodGridLayout({super.key, required this.item, required this.mod, required this.submods, required this.searchString, required this.modSetName});

  final Item item;
  final Mod mod;
  final List<SubMod> submods;
  final String searchString;
  final String modSetName;

  @override
  State<SubmodGridLayout> createState() => _SubmodGridLayoutState();
}

class _SubmodGridLayoutState extends State<SubmodGridLayout> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveSliverGridList(
        minItemWidth: 260,
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
                    ))
                .toList());
  }
}

class SubmodCardLayout extends StatefulWidget {
  const SubmodCardLayout({super.key, required this.item, required this.mod, required this.submod, required this.modSetName});

  final Item item;
  final Mod mod;
  final SubMod submod;
  final String modSetName;

  @override
  State<SubmodCardLayout> createState() => _SubmodCardLayoutState();
}

class _SubmodCardLayoutState extends State<SubmodCardLayout> {
  StarMenuController starMenuController = StarMenuController();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
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
              Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  SubmodImageBox(filePaths: widget.submod.previewImages, isNew: widget.submod.isNew),
                  Visibility(
                      visible: widget.submod.hasCmx! || widget.submod.customAQMInjected! || widget.submod.boundingRemoved!,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, bottom: 4),
                        child: Row(
                          spacing: 5,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Visibility(visible: widget.submod.hasCmx!, child: InfoTag(info: appText.cmx, borderHighlight: widget.submod.cmxApplied!)),
                            Visibility(visible: widget.submod.customAQMInjected!, child: InfoTag(info: appText.aqm, borderHighlight: widget.submod.customAQMInjected!)),
                            Visibility(visible: widget.submod.boundingRemoved!, child: InfoTag(info: appText.bounding, borderHighlight: widget.submod.boundingRemoved!)),
                          ],
                        ),
                      )),
                ],
              ),
              Text(widget.submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
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
                                  modPopupStatus.value = '"${widget.modSetName}" active submod changed to "${widget.submod.submodName}" in "${widget.item.itemName}"';
                                  saveMasterModListToJson();
                                  saveMasterModSetListToJson();
                                }
                              : null,
                          icon: Icon(widget.submod.activeInSets!.contains(widget.modSetName) ? Icons.check_box_outlined : Icons.check_box_outline_blank_rounded,
                              color: widget.submod.activeInSets!.contains(widget.modSetName) ? Theme.of(context).colorScheme.primary : null)),
                    )),
                PopupMenuButton(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
                  padding: EdgeInsets.zero,
                  menuPadding: EdgeInsets.zero,
                  tooltip: '',
                  elevation: 5,
                  style: ButtonStyle(
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(20))))),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                          onTap: () async {
                            await submodAddToSet(context, widget.item, widget.mod, widget.submod);
                            setState(() {});
                          },
                          child: MenuIconItem(icon: Icons.list_alt_outlined, text: appText.modSets)),
                      PopupMenuItem(child: MenuIconItem(icon: Icons.add_location_alt_outlined, text: appText.setApplyLocations)),
                      const PopupMenuItem(
                          height: 0,
                          enabled: false,
                          child: PopupMenuDivider(
                            height: 5,
                          )),
                      PopupMenuItem(
                          onTap: () async => await modSwapPopup(context, widget.item, widget.mod, widget.submod),
                          child: MenuIconItem(icon: Icons.swap_horizontal_circle_outlined, text: appText.swapToAnotherItem)),
                      PopupMenuItem(child: MenuIconItem(icon: Icons.file_present, text: appText.cmx)),
                      PopupMenuItem(
                          enabled: boundingRadiusCategoryDirs.contains(widget.submod.category) && !widget.submod.applyStatus,
                          onTap: () async {
                            await boundingRadiusPopup(context, widget.submod);
                            widget.submod.boundingRemoved = true;
                            saveMasterModListToJson();
                            setState(() {});
                          },
                          child: MenuIconItem(icon: Icons.radio_button_on_sharp, text: appText.removeBoundingRadius)),
                      if (!widget.submod.customAQMInjected!)
                        PopupMenuItem(
                            enabled: aqmInjectCategoryDirs.contains(widget.submod.category) &&
                                !widget.submod.applyStatus &&
                                !widget.submod.customAQMInjected! &&
                                selectedCustomAQMFilePath.watch(context).isNotEmpty &&
                                File(selectedCustomAQMFilePath.value).existsSync(),
                            onTap: () async {
                              await submodAqmInject(context, widget.submod);
                              setState(() {});
                            },
                            child: MenuIconItem(icon: Icons.auto_fix_high, text: appText.injectCustomAQM)),
                      if (widget.submod.customAQMInjected!)
                        PopupMenuItem(
                            enabled: aqmInjectCategoryDirs.contains(widget.submod.category) && !widget.submod.applyStatus && widget.submod.customAQMInjected!,
                            onTap: () async {
                              await submodCustomAqmRemove(context, widget.submod);
                              setState(() {});
                            },
                            child: MenuIconItem(icon: Icons.auto_fix_off, text: appText.removeCustomAQMs)),
                      const PopupMenuItem(
                          height: 0,
                          enabled: false,
                          child: PopupMenuDivider(
                            height: 5,
                          )),
                      PopupMenuItem(
                          onTap: () async {
                            await addPreviews(widget.mod, widget.submod);
                            setState(() {});
                          },
                          child: MenuIconItem(icon: Icons.preview_outlined, text: appText.addPreviews)),
                      PopupMenuItem(child: MenuIconItem(icon: Icons.import_export, text: appText.export)),
                      PopupMenuItem(onTap: () async => await submodRename(context, widget.mod, widget.submod), child: MenuIconItem(icon: Icons.edit, text: appText.rename)),
                      PopupMenuItem(onTap: () => launchUrlString(widget.submod.location), child: MenuIconItem(icon: Icons.folder_open, text: appText.openInFileExplorer)),
                      const PopupMenuItem(
                          height: 0,
                          enabled: false,
                          child: PopupMenuDivider(
                            height: 5,
                          )),
                      PopupMenuItem(
                          onTap: () async {
                            await submodDelete(context, widget.item, widget.mod, widget.submod);
                            modPopupStatus.value = '${widget.submod.submodName} deleted';
                            if (widget.mod.submods.isEmpty) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                              mainGridStatus.value = '"${widget.mod.modName}" in "${widget.item.itemName}" is empty and removed';
                            }
                          },
                          child: MenuIconItem(icon: Icons.delete_forever_outlined, text: appText.delete)),
                    ];
                  },
                )
              ]),
            ],
          )),
    );
  }
}

class MenuIconItem extends StatelessWidget {
  const MenuIconItem({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon), Text(text)],
    );
  }
}
