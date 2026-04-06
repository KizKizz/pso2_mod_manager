import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePage extends StatefulWidget {
  const LocalePage({super.key});

  @override
  State<LocalePage> createState() => _LocalePageState();
}

class _LocalePageState extends State<LocalePage> {
  @override
  Widget build(BuildContext context) {
    if (firstBootUp || !localeSettingsFile.existsSync()) {
      return const Center(child: CardOverlay(paddingValue: 15, child: LanguageSelector()));
    } else {
      return FutureBuilder(
        future: offlineMode ? AppLocale().offlineLocaleGet() : AppLocale().localeGet(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CardOverlay(
                paddingValue: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        appText.loadingUILanguage,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return FutureBuilderError(
              loadingText: appText.loadingUILanguage,
              snapshotError: snapshot.error.toString(),
              isPopup: false,
              showContButton: true,
            );
          } else {
            pageIndex++;
            curPage.value = appPages[pageIndex];
            return const SizedBox();
          }
        },
      );
    }
  }
}

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late List<AppLocale> locales;

  @override
  void initState() {
    locales = AppLocale().loadLocales();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            appText.selectUILanguage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        AnimatedHorizontalToggleLayout(
          taps: locales.map((e) => e.language).toList(),
          initialIndex: locales.indexWhere((e) => e.isActive),
          width: 300,
          onChange: (currentIndex, targetIndex) async {
            for (var e in locales) {
              e.isActive = false;
            }
            locales[targetIndex].isActive = true;
            locales[targetIndex].saveSettings(locales);
            appText = AppText.fromJson(jsonDecode(File(locales[targetIndex].translationFilePath).readAsStringSync()));
            final prefs = await SharedPreferences.getInstance();
            activeUILanguage = locales[targetIndex].language;
            prefs.setString('activeUILanguage', activeUILanguage);
            setState(() {});
          },
        ),

        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 5),
          child: Text(
            appText.selectItemNameLanguage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        AnimatedHorizontalToggleLayout(
          taps: const ['EN', 'JP'],
          initialIndex: itemNameLanguage == ItemNameLanguage.en ? 0 : 1,
          width: 300,
          onChange: (currentIndex, targetIndex) async {
            final prefs = await SharedPreferences.getInstance();
            targetIndex == 0 ? itemNameLanguage = ItemNameLanguage.en : itemNameLanguage = ItemNameLanguage.jp;
            prefs.setString('itemNameLanguage', itemNameLanguage.value);
          },
        ),

        const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
        ElevatedButton(
            onPressed: () async {
              // final prefs = await SharedPreferences.getInstance();
              // firstBootUp = false;
              // prefs.setBool('firstBootUp', firstBootUp);
              AppLocale().saveSettings(locales);
              pageIndex++;
              curPage.value = appPages[pageIndex];
            },
            child: Text(appText.cont)),
      ],
    );
  }
}
