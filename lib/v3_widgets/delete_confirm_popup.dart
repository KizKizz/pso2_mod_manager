
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> deleteConfirmPopup(context, String name) async {
  var focusNode = FocusNode();
  focusNode.requestFocus();
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
              Text(appText.delete, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appText.dText(appText.permanentlyDeleteItem, name), style: Theme.of(context).textTheme.bodyLarge,),
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
                      },
                      onLongPress: () {
                         Navigator.of(context).pop(true);
                      },
                      child: Text(appText.holdToDelete, style: const TextStyle(color: Colors.redAccent),)),
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
