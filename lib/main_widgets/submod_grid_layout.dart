import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class SubmodGridLayout extends StatefulWidget {
  const SubmodGridLayout({super.key, required this.item, required this.mod, required this.submods, required this.searchString});

  final Item item;
  final Mod mod;
  final List<SubMod> submods;
  final String searchString;

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
                    ))
                .toList()
            : widget.submods
                .where((e) =>
                    e.getModFileNames().where((e) => e.toLowerCase().contains(widget.searchString.toLowerCase())).isNotEmpty || e.submodName.toLowerCase().contains(widget.searchString.toLowerCase()))
                .map((e) => SubmodCardLayout(item: widget.item, mod: widget.mod, submod: e))
                .toList());
  }
}

class SubmodCardLayout extends StatefulWidget {
  const SubmodCardLayout({super.key, required this.item, required this.mod, required this.submod});

  final Item item;
  final Mod mod;
  final SubMod submod;

  @override
  State<SubmodCardLayout> createState() => _SubmodCardLayoutState();
}

class _SubmodCardLayoutState extends State<SubmodCardLayout> {
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
              SubmodImageBox(filePaths: widget.submod.previewImages, isNew: widget.submod.isNew),
              Text(widget.submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () async {
                            if (!widget.submod.applyStatus) {
                              await applyingPopup(context, true, widget.item, widget.mod, widget.submod);
                            } else {
                              await applyingPopup(context, false, widget.item, widget.mod, widget.submod);
                            }
                            setState(() {});
                          },
                          child: Text(widget.submod.applyStatus ? appText.restore : appText.apply))),
                  IconButton.outlined(visualDensity: VisualDensity.compact, onPressed: () {}, icon: const Center(child: Icon(Icons.more_horiz))),
                ],
              )
            ],
          ),
        ));
  }
}
