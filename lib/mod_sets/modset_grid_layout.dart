import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/header_info_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/mod_sets/modset_mod_view_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/main_modset_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class ModSetGridLayout extends StatefulWidget {
  const ModSetGridLayout({super.key, required this.modSet});

  final ModSet modSet;

  @override
  State<ModSetGridLayout> createState() => _ModSetGridLayoutState();
}

class _ModSetGridLayoutState extends State<ModSetGridLayout> {
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
                        HeaderInfoBox(info: appText.dText(widget.modSet.setItems.length > 1 ? appText.numItems : appText.numItem, widget.modSet.setItems.length.toString()), borderHighlight: false),
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
                                shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(5))))),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                    onTap: () async {
                                      await modSetDelete(context, widget.modSet);
                                      setState(() {
                                        modSetRefreshSignal.value = 'deleted ${widget.modSet.setName}';
                                      });
                                    },
                                    child: MenuIconItem(icon: Icons.delete_forever_outlined, text: appText.delete)),
                              ];
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ))),
        sliver: ResponsiveSliverGridList(minItemWidth: 350, verticalGridMargin: 5, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: modCardFetch()));
  }

  List<ModSetCardLayout> modCardFetch() {
    List<ModSetCardLayout> modCardList = [];
    for (var item in widget.modSet.setItems) {
      var (mod, submod) = item.getActiveInSet(widget.modSet.setName);
      if (mod != null && submod != null) modCardList.add(ModSetCardLayout(item: item, activeMod: mod, activeSubmod: submod, setName: widget.modSet.setName));
    }

    return modCardList;
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
    return CardOverlay(
      paddingValue: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  spacing: 5,
                  children: [
                    ItemIconBox(item: widget.item),
                    Text(widget.item.itemName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: SubmodImageBox(filePaths: widget.activeSubmod.previewImages, isNew: widget.activeSubmod.isNew),
              )
            ],
          ),
          Visibility(
              visible: widget.activeMod.modName != widget.activeSubmod.submodName, child: Text(widget.activeMod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
          Text(widget.activeSubmod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
          Row(
            spacing: 5,
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
                  child: Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          modsetModViewPopup(context, widget.item, widget.setName);
                        },
                        child: Text(appText.viewVariants)),
                  )),
              Expanded(child: OutlinedButton(onPressed: () {}, child: Text(widget.activeSubmod.applyStatus ? appText.restore : appText.apply))),
              IconButton(
                  onPressed: () async {},
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  visualDensity: VisualDensity.adaptivePlatformDensity),
            ],
          )
        ],
      ),
    );
  }
}
