import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_cate_select_button.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_acc_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_emote_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_general_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';

Signal<String> itemSwapWorkingStatus = Signal('');

void itemSwapWorkingPopup(
  context,
  ItemData lItemData,
  ItemData rItemData,
) {
  Directory swapOutputDir = Directory('');

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
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(itemSwapWorkingStatus.watch(context)),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      Visibility(
                        visible: swapOutputDir.existsSync(),
                        child: OutlinedButton(
                            onPressed: () async {
                              launchUrl(Uri.directory(swapOutputDir.parent.path));
                            },
                            child: Text(appText.openInFileExplorer)),
                      ),
                      Visibility(
                        visible: !swapOutputDir.existsSync(),
                        child: OutlinedButton(
                            onPressed: () async {
                              swapOutputDir = Directory('');
                              if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[0]) {
                                swapOutputDir = await modSwapAccessories(
                                    context, true, lItemModGet(), lItemSubmodGet(lItemData), lItemData.getIceDetails(), rItemData.getIceDetails(), rItemData.getName(), rItemData.getItemID());
                              } else if (selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[14] || selectedDisplayItemSwapCategory.watch(context) == defaultCategoryDirs[7]) {
                                swapOutputDir =
                                    await modSwapEmotes(context, true, lItemModGet(), lItemSubmodGet(lItemData), rItemData.getName(), lItemData.getIceDetails(), rItemData.getIceDetails(), []);
                              } else {
                                swapOutputDir = await modSwapGeneral(context, true, lItemModGet(), lItemSubmodGet(lItemData), lItemData.getIceDetails(), rItemData.getIceDetails(), rItemData.getName(),
                                    lItemData.getItemID(), rItemData.getItemID());
                              }
                            },
                            child: Text(appText.swap)),
                      ),
                      OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(appText.returns))
                    ],
                  )
                ],
              )
            ],
          );
        });
      });
}
