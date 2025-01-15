import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> duplicatePopup(context, Item dupItem, Mod dupMod, SubMod dupSubmod, String newSubmodName) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            title: Center(child: Text(appText.dunplicateAppliedMods)),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appText.dText(appText.duplicateAppliedInfo, newSubmodName)),
                const HoriDivider(),
                SizedBox(
                  width: 400,
                  height: 250,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                                ItemIconBox(item: dupItem),
                                Text(dupItem.itemName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SubmodImageBox(filePaths: dupSubmod.previewImages, isNew: dupSubmod.isNew),
                          )
                        ],
                      ),
                      Text(dupSubmod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                      Visibility(visible: dupSubmod.submodName != dupSubmod.modName, child: Text(dupSubmod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                    ],
                  ),
                ),
                const HoriDivider(),
              ],
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(appText.replace)),
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
