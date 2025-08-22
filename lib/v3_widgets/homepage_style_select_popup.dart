import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

void homepageStyleSelectPopup(context) {
  bool legacyStyleSelected = false;
  var focusNode = FocusNode();
  focusNode.requestFocus();
  showDialog(
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
                appText.homepageStyle,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 250,
                          child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: legacyStyleSelected ? Theme.of(context).primaryColorLight : Theme.of(context).colorScheme.outline, width: 1.5),
                                  borderRadius: const BorderRadius.all(Radius.circular(5))),
                              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  legacyStyleSelected = true;
                                  setState(
                                    () {},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Image.asset('assets/img/l_style.png'),
                                ),
                              )),
                        ),
                        Text(appText.legacy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: legacyStyleSelected ? Theme.of(context).primaryColorLight : null))
                      ],
                    ),
                  ],
                ),
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
                      child: Text(appText.save)),
                ],
              )
            ],
          );
        });
      });
}
