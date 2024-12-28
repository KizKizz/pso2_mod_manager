import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/loading_future_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePage extends StatefulWidget {
  const LocalePage({super.key});

  @override
  State<LocalePage> createState() => _LocalePageState();
}

class _LocalePageState extends State<LocalePage> {
  @override
  Widget build(BuildContext context) {
    AppLocale().localeInit();
    if (firstBootUp || !localeSettingsFile.existsSync()) {
      return const Center(child: CardOverlay(child: LanguageSelector()));
    } else {
      return LoadingFutureBuilder(loadingText: appText.loadingUILanguage, future: AppLocale().localeGet());
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
        Wrap(
          spacing: 10,
          children: [
            for (int i = 0; i < locales.length; i++)
              ElevatedButton(
                  onPressed: () {
                    for (var e in locales) {
                      e.isActive = false;
                    }
                    locales[i].isActive = true;
                  },
                  child: Text(
                    locales[i].language,
                    style: TextStyle(color: locales[i].isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color),
                  ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 5),
          child: Text(
            appText.selectItemNameLanguage,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Wrap(
          spacing: 10,
          children: [
            ElevatedButton(
                onPressed: () {
                  setItemNameLanguage(ItemNameLanguage.en);
                  setState(() {});
                },
                child: Text('EN', style: TextStyle(color: itemNameLanguage == ItemNameLanguage.en ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color))),
            ElevatedButton(
                onPressed: () {
                  setItemNameLanguage(ItemNameLanguage.jp);
                  setState(() {});
                },
                child: Text('JP', style: TextStyle(color: itemNameLanguage == ItemNameLanguage.jp ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelMedium!.color))),
          ],
        ),
        const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
        ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              firstBootUp = false;
              prefs.setBool('firstBootUp', firstBootUp);
              AppLocale().saveSettings(locales);
              pageIndex++;
              curPage.value = appPages[pageIndex];
            },
            child: Text(appText.cont)),
      ],
    );
  }
}
