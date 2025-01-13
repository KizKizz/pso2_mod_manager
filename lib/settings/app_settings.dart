import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class AppSettingsLayout extends StatefulWidget {
  const AppSettingsLayout({super.key});

  @override
  State<AppSettingsLayout> createState() => _AppSettingsLayoutState();
}

class _AppSettingsLayoutState extends State<AppSettingsLayout> {
  late List<AppLocale> appLocales;
  final onOffLabels = [appText.on, appText.off];

  @override
  void initState() {
    // Load app locales
    appLocales = AppLocale().loadLocales();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appText.appSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const HoriDivider(),
            Expanded(
                child: SingleChildScrollView(
                    physics: const SuperRangeMaintainingScrollPhysics(),
                    child: Column(
                      spacing: 5,
                      children: [
                        // Language
                        SettingsHeader(icon: Icons.language, text: appText.uiLanguage),
                        AnimatedHorizontalToggleLayout(
                          taps: appLocales.map((e) => e.language).toList(),
                          initialIndex: appLocales.indexWhere((e) => e.isActive),
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) {
                            for (var e in appLocales) {
                              e.isActive = false;
                            }
                            appLocales[targetIndex].isActive = true;
                            appLocales[targetIndex].saveSettings(appLocales);
                          },
                        ),

                        // Item name language
                        SettingsHeader(icon: Icons.language, text: appText.itemNameLanguage),
                        AnimatedHorizontalToggleLayout(
                          taps: const ['EN', 'JP'],
                          initialIndex: itemNameLanguage == ItemNameLanguage.en ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? itemNameLanguage = ItemNameLanguage.en : itemNameLanguage = ItemNameLanguage.jp;
                            prefs.setString('itemNameLanguage', itemNameLanguage.value);
                          },
                        ),

                        // Item icon slides
                        SettingsHeader(icon: Icons.slideshow, text: appText.itemIconSlides),
                        AnimatedHorizontalToggleLayout(
                          taps: onOffLabels,
                          initialIndex: itemIconSlides.watch(context) ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? itemIconSlides.value = true : itemIconSlides.value = false;
                            prefs.setBool('itemIconSlides', itemIconSlides.value);
                          },
                        )
                      ],
                    )))
          ],
        );
      },
    );
  }
}
