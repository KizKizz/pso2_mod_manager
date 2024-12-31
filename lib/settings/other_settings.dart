import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/settings/color_picker.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/background_slideshow_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class OtherSettingsLayout extends StatefulWidget {
  const OtherSettingsLayout({super.key});

  @override
  State<OtherSettingsLayout> createState() => _OtherSettingsLayoutState();
}

class _OtherSettingsLayoutState extends State<OtherSettingsLayout> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appText.others,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const HoriDivider(),
        SingleChildScrollView(
          physics: const SuperRangeMaintainingScrollPhysics(),
          child: Column(
            spacing: 5,
            children: [
              // Theme mode
              SettingsHeader(icon: appThemeMode == AppThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, text: appText.themeMode),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () {
                      if (appThemeMode == AppThemeMode.dark) {
                        setAppThemeMode(AppThemeMode.light);
                        MyApp.themeNotifier.value = ThemeMode.light;
                      } else {
                        setAppThemeMode(AppThemeMode.dark);
                        MyApp.themeNotifier.value = ThemeMode.dark;
                      }
                      setState(() {});
                    },
                    child: Text(appThemeMode == AppThemeMode.dark ? appText.light : appText.dark)),
              ),

              // Theme color schemes
              SettingsHeader(icon: Icons.color_lens_outlined, text: appText.themeColorSchemes),

              Text(appText.light),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    Color? pickedColor = await colorPicker(context, lightModeSeedColor);
                    final prefs = await SharedPreferences.getInstance();
                    if (pickedColor != null) {
                      lightModeSeedColor = pickedColor;
                    }
                    prefs
                        .setStringList('lightModeSeedColorValue', [lightModeSeedColor.r.toString(), lightModeSeedColor.g.toString(), lightModeSeedColor.b.toString(), lightModeSeedColor.a.toString()]);
                    setState(() {});
                    MyApp.themeNotifier.value = ThemeMode.dark;
                    MyApp.themeNotifier.value = ThemeMode.light;
                  },
                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(lightModeSeedColor)),
                  child: const SizedBox(),
                ),
              ),

              Text(appText.dark),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                    onPressed: () async {
                      Color? pickedColor = await colorPicker(context, darkModeSeedColor);
                      final prefs = await SharedPreferences.getInstance();
                      if (pickedColor != null) {
                        darkModeSeedColor = pickedColor;
                      }
                      prefs.setStringList('darkModeSeedColorValue', [darkModeSeedColor.r.toString(), darkModeSeedColor.g.toString(), darkModeSeedColor.b.toString(), darkModeSeedColor.a.toString()]);
                      setState(() {});
                      MyApp.themeNotifier.value = ThemeMode.light;
                      MyApp.themeNotifier.value = ThemeMode.dark;
                    },
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(darkModeSeedColor)),
                    child: const SizedBox()),
              ),

              // UI Opacity
              SettingsHeader(icon: Icons.opacity, text: appText.uiOpacity),
              SizedBox(
                width: double.infinity,
                child: SliderTheme(
                    data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
                    child: Slider(
                      value: uiBackgroundColorAlpha.value.toDouble(),
                      min: 0,
                      max: 250,
                      label: uiBackgroundColorAlpha.toString(),
                      onChanged: (value) {
                        uiBackgroundColorAlpha.value = value.round();
                        setState(() {});
                      },
                    )),
              ),

              // Background slideshow
              SettingsHeader(icon: Icons.slideshow, text: appText.backgroundSlideshow),
              const SizedBox(
                width: double.infinity,
                child: BackgroundSlideshowBox(),
              )
            ],
          ),
        )
      ],
    );
  }
}

enum AppThemeMode {
  dark('Dark'),
  light('Light');

  final String value;
  const AppThemeMode(this.value);
}

Future<void> setAppThemeMode(AppThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();

  appThemeMode = mode;
  prefs.setString('appThemeMode', appThemeMode.value);
}
