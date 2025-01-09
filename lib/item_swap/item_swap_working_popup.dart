import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

void itemSwapWorkingPopup(
  context,
  ItemData lItemData,
  ItemData rItemData,
) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: OverflowBar(
              spacing: 5,
              overflowSpacing: 5,
              overflowAlignment: OverflowBarAlignment.center,
              children: [
                CardOverlay(
                    paddingValue: 10,
                    child: Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenericItemIconBox(iconImagePaths: [lItemData.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                        Text(appText.categoryName(lItemData.category), style: Theme.of(context).textTheme.titleMedium),
                        Text(lItemData.getName(), style: Theme.of(context).textTheme.titleLarge),
                        SingleChildScrollView(
                          physics: const SuperRangeMaintainingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: lItemData.getDetails().map((e) => Text(e)).toList(),
                          ),
                        )
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: LoadingAnimationWidget.twoRotatingArc(
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
                CardOverlay(
                    paddingValue: 10,
                    child: Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenericItemIconBox(iconImagePaths: [rItemData.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                        Text(appText.categoryName(rItemData.category), style: Theme.of(context).textTheme.titleMedium),
                        Text(rItemData.getName(), style: Theme.of(context).textTheme.titleLarge),
                        SingleChildScrollView(
                          physics: const SuperRangeMaintainingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: rItemData.getDetails().map((e) => Text(e)).toList(),
                          ),
                        )
                      ],
                    ))
              ],
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(appText.swap)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
