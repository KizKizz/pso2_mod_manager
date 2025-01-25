import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
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
  bool reloadButtonVisible = false;

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
                        // Profile
                        SettingsHeader(icon: modManCurActiveProfile == 1 ? Icons.filter_1 : Icons.filter_2, text: appText.profiles),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.profile1, appText.profile2],
                          initialIndex: modManCurActiveProfile == 1 ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? modManCurActiveProfile = 1 : modManCurActiveProfile = 2;
                            prefs.setInt('modManCurActiveProfile', modManCurActiveProfile);
                            pso2binDirPath = modManCurActiveProfile == 1 ? prefs.getString('pso2binDirPath') ?? '' : prefs.getString('pso2binDirPath_profile2') ?? '';
                            reloadButtonVisible = true;
                            setState(() {});
                          },
                        ),
                        Visibility(
                            visible: reloadButtonVisible,
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                  onPressed: () {
                                    reloadButtonVisible = false;
                                    pageIndex = 6;
                                    curPage.value = appPages[pageIndex];
                                  },
                                  child: Text(appText.reload)),
                            )),
                        // Item icon slides
                        SettingsHeader(icon: Icons.slideshow, text: appText.itemIconSlides),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.on, appText.off],
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
