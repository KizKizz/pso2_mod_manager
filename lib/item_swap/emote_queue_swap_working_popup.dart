import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_working_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_emote_functions.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_helper_functions.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_popup.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> emoteQueueSwapWorkingPopup(context, bool isVanillaSwap, List<(ItemData, ItemData)> emoteSwapQueue, Mod mod, SubMod submod) async {
  Directory swapOutputDir = Directory('');
  List<String> swapOutputDirPaths = [];
  int curPairIndex = 0;
  int swappedCount = 0;

  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                OverflowBar(
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
                            GenericItemIconBox(iconImagePaths: [emoteSwapQueue[curPairIndex].$1.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                            Text(appText.categoryName(emoteSwapQueue[curPairIndex].$1.category), style: Theme.of(context).textTheme.titleMedium),
                            Text(emoteSwapQueue[curPairIndex].$1.getName(), style: Theme.of(context).textTheme.titleLarge),
                            SingleChildScrollView(
                              physics: const SuperRangeMaintainingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: emoteSwapQueue[curPairIndex].$1.getDetails().map((e) => Text(e)).toList(),
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
                            GenericItemIconBox(iconImagePaths: [emoteSwapQueue[curPairIndex].$2.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                            Text(appText.categoryName(emoteSwapQueue[curPairIndex].$2.category), style: Theme.of(context).textTheme.titleMedium),
                            Text(emoteSwapQueue[curPairIndex].$2.getName(), style: Theme.of(context).textTheme.titleLarge),
                            SingleChildScrollView(
                              physics: const SuperRangeMaintainingScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: emoteSwapQueue[curPairIndex].$2.getDetails().map((e) => Text(e)).toList(),
                              ),
                            )
                          ],
                        ))
                  ],
                ),
                const Icon(Icons.arrow_downward_rounded, size: 30),
                CardOverlay(
                    paddingValue: 10,
                    child: Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GenericItemIconBox(iconImagePaths: [emoteSwapQueue[curPairIndex].$1.iconImagePath], boxSize: const Size(100, 100), isNetwork: true),
                        Text(appText.categoryName(emoteSwapQueue[curPairIndex].$2.category), style: Theme.of(context).textTheme.titleMedium),
                        Text(emoteSwapQueue[curPairIndex].$2.getName(), style: Theme.of(context).textTheme.titleLarge),
                        Visibility(
                          visible: !isVanillaSwap,
                          child: Text(lItemSubmodGet(emoteSwapQueue[curPairIndex].$1).submodName, style: Theme.of(context).textTheme.labelLarge),
                        )
                        // SingleChildScrollView(
                        //   physics: const SuperRangeMaintainingScrollPhysics(),
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: rItemData.getDetails().map((e) => Text(e)).toList(),
                        //   ),
                        // )
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
                        visible: swapOutputDir.existsSync() && swappedCount == emoteSwapQueue.length,
                        child: OutlinedButton(
                            onPressed: () async {
                              launchUrlString(swapOutputDir.parent.path);
                            },
                            child: Text(appText.openInFileExplorer)),
                      ),
                      Visibility(
                        visible: swapOutputDir.existsSync() && swappedCount == emoteSwapQueue.length,
                        child: OutlinedButton(
                            onPressed: () async {
                              await modAddPopup(context, swapOutputDirPaths);
                            },
                            child: Text(appText.addToModManager)),
                      ),
                      Visibility(
                        visible: !swapOutputDir.existsSync(),
                        child: OutlinedButton(
                            onPressed: itemSwapWorkingStatus.watch(context).isEmpty
                                ? () async {
                                    // Clean and create temp dirs
                                    await modSwapTempDirsRemove();
                                    await modSwapTempDirsCreate();
                                    swapOutputDir = Directory('');
                                    for (var pair in emoteSwapQueue) {
                                      swapOutputDir = await modSwapEmotes(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          isVanillaSwap,
                                          mod,
                                          isVanillaSwap ? lItemSubmodGet(pair.$1) : submod,
                                          pair.$2.getName(),
                                          pair.$1.getIceDetails(),
                                          pair.$2.getIceDetails());
                                      if (!swapOutputDirPaths.contains(swapOutputDir.path)) swapOutputDirPaths.add(swapOutputDir.path);
                                      if (curPairIndex < emoteSwapQueue.length - 1) curPairIndex++;
                                      swappedCount++;
                                      setState(
                                        () {},
                                      );
                                      await Future.delayed(Duration(milliseconds: 10));
                                    }
                                  }
                                : null,
                            child: Text(appText.swap)),
                      ),
                      OutlinedButton(
                          onPressed: () {
                            itemSwapWorkingStatus.value = '';
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
