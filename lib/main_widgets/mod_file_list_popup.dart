import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_apply/unapply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Future<void> modFileListPopup(context, Item item, Mod mod, SubMod submod) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5),
            title: Column(children: [
              Text(
                submod.modName,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: 450,
              // height: 350,
              child: Column(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(submod.submodName, style: Theme.of(context).textTheme.titleSmall),
                  Flexible(
                    child: CardOverlay(
                      paddingValue: 5,
                      child: SuperListView.builder(
                          shrinkWrap: true,
                          itemCount: submod.modFiles.length,
                          itemBuilder: (context, index) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(submod.modFiles[index].modFileName),
                                trailing: OutlinedButton(
                                    onPressed: () async {
                                      if (!submod.modFiles[index].applyStatus) {
                                        await modApplySequence(context, true, item, mod, submod, [submod.modFiles[index]]);
                                        submod.modFiles[index].applyStatus ? applySuccessNotification(submod.modFiles[index].modFileName) : applyFailedNotification(submod.modFiles[index].modFileName);
                                      } else {
                                        await modUnapplySequence(context, false, item, mod, submod, [submod.modFiles[index]]);
                                        !submod.modFiles[index].applyStatus
                                            ? restoreSuccessNotification(submod.modFiles[index].modFileName)
                                            : restoreFailedNotification(submod.modFiles[index].modFileName);
                                      }
                                      modPopupStatus.value = 'Done!';
                                      setState(
                                        () {},
                                      );
                                    },
                                    child: Text(submod.modFiles[index].applyStatus ? appText.restore : appText.apply)),
                              )),
                    ),
                  )
                ],
              ),
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
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
