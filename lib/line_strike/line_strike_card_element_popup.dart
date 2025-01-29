import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<int> lineStrikeCardElementSelectPopup(context) async {
  int selectedIndex = -1;
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
                insetPadding: const EdgeInsets.all(5),
                titlePadding: const EdgeInsets.only(top: 5),
                title: Column(children: [
                  Text(
                    appText.selectCardElement,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  const HoriDivider()
                ]),
                contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                content: SizedBox(
                  width: 300,
                  child: AnimatedHorizontalToggleLayout(
                    taps: [appText.cardDarkElement, appText.cardFireElement, appText.cardIceElement, appText.cardLightElement, appText.cardLightningElement, appText.cardWindElement],
                    initialIndex: selectedIndex,
                    width: 300,
                    onChange: (currentIndex, targetIndex) async {
                      selectedIndex = targetIndex;
                      setState(() {});
                    },
                  ),
                ),
                actionsPadding: const EdgeInsets.all(10),
                actions: <Widget>[
                  OutlinedButton(
                      onPressed: selectedIndex == -1
                          ? null
                          : () {
                              Navigator.pop(context, selectedIndex);
                            },
                      child: Text(appText.select)),
                  OutlinedButton(
                      child: Text(appText.returns),
                      onPressed: () {
                        Navigator.pop(context, -1);
                      }),
                  
                ]);
          }));
}
