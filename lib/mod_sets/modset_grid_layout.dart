import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_view_popup.dart';
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
              padding: const EdgeInsets.all(8),
              child: Text(widget.modSet.setName, style: Theme.of(context).textTheme.titleMedium),
            )),
        sliver: ResponsiveSliverGridList(minItemWidth: 350, verticalGridMargin: 5, horizontalGridSpacing: 5, verticalGridSpacing: 5, children: modCardFetch()));
  }

  List<ModCardLayout> modCardFetch() {
    List<ModCardLayout> modCardList = [];
    for (var item in widget.modSet.setItems) {
      for (var mod in item.mods.where((e) => e.isSet && e.setNames.contains(widget.modSet.setName))) {
        modCardList.add(ModCardLayout(item: item, mod: mod, setName: widget.modSet.setName));
      }
    }

    return modCardList;
  }
}

class ModCardLayout extends StatefulWidget {
  const ModCardLayout({super.key, required this.item, required this.mod, required this.setName});

  final Item item;
  final Mod mod;
  final String setName;

  @override
  State<ModCardLayout> createState() => _ModCardLayoutState();
}

class _ModCardLayoutState extends State<ModCardLayout> {
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
                child: SubmodImageBox(filePaths: widget.mod.submods.firstWhere((e) => e.setNames.contains(widget.setName)).previewImages, isNew: widget.mod.isNew),
              )
            ],
          ),
          Text(widget.mod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
          Visibility(
              visible: widget.mod.submods.firstWhere((e) => e.setNames.contains(widget.setName)).submodName != widget.mod.modName,
              child: Text(widget.mod.submods.firstWhere((e) => e.setNames.contains(widget.setName)).submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
          Row(
            spacing: 5,
            children: [
              Expanded(
                  child: InfoBox(
                      info: appText.dText(widget.mod.submods.where((e) => e.setNames.contains(widget.setName)).length > 1 ? appText.numVariants : appText.numVariant,
                          widget.mod.submods.where((e) => e.setNames.contains(widget.setName)).length.toString()), borderHighlight: false,)),
              Expanded(child: InfoBox(info: appText.dText(appText.numCurrentlyApplied, widget.mod.getNumOfAppliedSubmods().toString()), borderHighlight: false,)),
            ],
          ),
          Row(
            spacing: 5,
            children: [
              Visibility(
                  visible: widget.mod.submods.where((e) => e.setNames.contains(widget.setName)).length > 1,
                  child: Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          submodViewPopup(context, widget.item, widget.mod);
                        },
                        child: Text(appText.viewVariants)),
                  )),
              Expanded(child: OutlinedButton(onPressed: () {}, child: Text(appText.apply))),
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
