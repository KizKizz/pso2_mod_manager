import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/homepage.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

void homepageStyleSelectPopup(context) {
  bool legacyStyleSelected = v2Homepage.value;
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  side: BorderSide(color: legacyStyleSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1.5),
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
                        Text(appText.legacy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: legacyStyleSelected ? Theme.of(context).colorScheme.primary : null))
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 250,
                          child: Card(
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: !legacyStyleSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1.5),
                                  borderRadius: const BorderRadius.all(Radius.circular(5))),
                              color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                              margin: EdgeInsets.zero,
                              child: InkWell(
                                onTap: () {
                                  legacyStyleSelected = false;
                                  setState(
                                    () {},
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Image.asset('assets/img/n_style.png'),
                                ),
                              )),
                        ),
                        Text(appText.xnew, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: !legacyStyleSelected ? Theme.of(context).colorScheme.primary : null))
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(appText.firstTimeHomepageStyleSelectInfo),
                  OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        homepageStyleSelection = true;
                        prefs.setBool('homepageStyleSelection', homepageStyleSelection);
                        if (legacyStyleSelected) {
                          v2Homepage.value = true;
                          prefs.setBool('v2Homepage', v2Homepage.value);
                          if (mainSideMenuController.currentPage == 0) homepageCurrentWidget.value = homepageV2Widgets[0];
                        } else {
                          v2Homepage.value = false;
                          prefs.setBool('v2Homepage', v2Homepage.value);
                          if (mainSideMenuController.currentPage == 0) homepageCurrentWidget.value = homepageWidgets[0];
                        }
                        // ignore: use_build_context_synchronously
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
