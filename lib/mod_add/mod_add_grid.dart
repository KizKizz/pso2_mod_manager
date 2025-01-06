import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_function.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/mod_add_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class ModAddGrid extends StatefulWidget {
  const ModAddGrid({super.key});

  @override
  State<ModAddGrid> createState() => _ModAddGridState();
}

class _ModAddGridState extends State<ModAddGrid> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Visibility(
            visible: curModAddProcessedStatus.watch(context) != ModAddProcessedState.waiting,
            child: ResponsiveGridList(
                minItemWidth: 300,
                verticalGridMargin: 0,
                horizontalGridSpacing: 5,
                verticalGridSpacing: 5,
                children: modAddingList
                    .map((i) => CardOverlay(
                          paddingValue: 5,
                          child: Column(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SubmodImageBox(filePaths: i.previewImages.map((f) => f.path).toList(), isNew: false),
                              Text(p.basename(i.modDir.path), style: Theme.of(context).textTheme.titleMedium),
                              Row(spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () {}, icon: const Icon(Icons.edit), visualDensity: VisualDensity.adaptivePlatformDensity),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.check_box_outlined), visualDensity: VisualDensity.adaptivePlatformDensity),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.delete_forever_outlined), visualDensity: VisualDensity.adaptivePlatformDensity),
                              ],),
                              Row(
                                spacing: 5,
                                children: [
                                  Expanded(
                                    child: InfoBox(info: appText.dText(i.associatedItems.length > 1 ? appText.numMatchedItems : appText.numMatchedItem, i.associatedItems.length.toString())),
                                  ),
                                  Expanded(child: InfoBox(info: appText.dText(i.submods.length > 1 ? appText.numVariants : appText.numVariant, i.submods.length.toString())))
                                ],
                              ),
                              Row(
                                spacing: 5,
                                children: [
                                  Expanded(child: OutlinedButton(onPressed: () {}, child: Text(appText.editItems))),
                                  Expanded(child: OutlinedButton(onPressed: () {}, child: Text(appText.editVariants)))
                                ],
                              )
                            ],
                          ),
                        ))
                    .toList())),
        Visibility(
            visible: curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting || curModAddProcessedStatus.watch(context) == ModAddProcessedState.loadingData,
            child: FutureBuilderLoading(loadingText: curModAddProcessedStatus.watch(context) == ModAddProcessedState.waiting ? appText.waitingForItems : appText.processingItems))
      ],
    );
  }
}
