import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class AppSettingsLayout extends StatefulWidget {
  const AppSettingsLayout({super.key});

  @override
  State<AppSettingsLayout> createState() => _AppSettingsLayoutState();
}

class _AppSettingsLayoutState extends State<AppSettingsLayout> {
  late List<AppLocale> appLocales;

  @override
  void initState() {
    // Load app locales
    appLocales = AppLocale().loadLocales();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        for (int i = 0; i < appLocales.length; i++)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                                onPressed: () {
                                  for (var e in appLocales) {
                                    e.isActive = false;
                                  }
                                  appLocales[i].isActive = true;
                                  setState(() {});
                                },
                                child: Text(appLocales[i].language,
                                    style: TextStyle(color: appLocales[i].isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color))),
                          )
                      ],
                    ),

                    // Item name language
                    SettingsHeader(icon: Icons.language, text: appText.itemNameLanguage),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () {
                                itemNameLanguage = ItemNameLanguage.en;
                                setState(() {});
                              },
                              child: Text(ItemNameLanguage.en.name.toUpperCase(),
                                  style: TextStyle(color: itemNameLanguage == ItemNameLanguage.en ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color))),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                              onPressed: () {
                                itemNameLanguage = ItemNameLanguage.jp;
                                setState(() {});
                              },
                              child: Text(ItemNameLanguage.jp.name.toUpperCase(),
                                  style: TextStyle(color: itemNameLanguage == ItemNameLanguage.jp ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color))),
                        )
                      ],
                    ),
                  ],
                )))
      ],
    );
  }
}
