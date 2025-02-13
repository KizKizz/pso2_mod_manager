
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> repathConfirmPopup(context, isPso2bin, String curPath) async {
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
              Text(appText.reselectPath, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isPso2bin ? appText.reselectpso2binPath : appText.reselectMainModManagerPath, style: Theme.of(context).textTheme.titleMedium),
                Text(appText.dText(appText.currentPathLocation, curPath))
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
                        
                      onPressed: () { Navigator.of(context).pop(true); },
                      child: Text(appText.continues)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
