import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/settings/color_picker.dart';
import 'package:pso2_mod_manager/settings/location_button.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/background_slideshow.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class OtherSettingsLayout extends StatefulWidget {
  const OtherSettingsLayout({super.key});

  @override
  State<OtherSettingsLayout> createState() => _OtherSettingsLayoutState();
}

class _OtherSettingsLayoutState extends State<OtherSettingsLayout> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appText.others,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const HoriDivider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const SuperRangeMaintainingScrollPhysics(),
                child: Column(
                  spacing: 5,
                  children: [
                    // Theme mode
                    SettingsHeader(icon: appThemeMode == AppThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, text: appText.themeMode),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.light, appText.dark],
                      initialIndex: appThemeMode == AppThemeMode.light ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) {
                        if (targetIndex == 0) {
                          setAppThemeMode(AppThemeMode.light);
                          MyApp.themeNotifier.value = ThemeMode.light;
                        } else {
                          setAppThemeMode(AppThemeMode.dark);
                          MyApp.themeNotifier.value = ThemeMode.dark;
                        }
                      },
                    ),

                    // Theme color schemes
                    SettingsHeader(icon: Icons.color_lens_outlined, text: appText.themeColorScheme),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (appThemeMode == AppThemeMode.light) {
                            Color? pickedColor = await colorPicker(context, lightModeSeedColor);
                            final prefs = await SharedPreferences.getInstance();
                            if (pickedColor != null) {
                              lightModeSeedColor = pickedColor;
                            }
                            prefs.setStringList(
                                'lightModeSeedColorValue', [lightModeSeedColor.r.toString(), lightModeSeedColor.g.toString(), lightModeSeedColor.b.toString(), lightModeSeedColor.a.toString()]);
                            setState(() {});
                            MyApp.themeNotifier.value = ThemeMode.dark;
                            MyApp.themeNotifier.value = ThemeMode.light;
                          } else {
                            Color? pickedColor = await colorPicker(context, darkModeSeedColor);
                            final prefs = await SharedPreferences.getInstance();
                            if (pickedColor != null) {
                              darkModeSeedColor = pickedColor;
                            }
                            prefs.setStringList(
                                'darkModeSeedColorValue', [darkModeSeedColor.r.toString(), darkModeSeedColor.g.toString(), darkModeSeedColor.b.toString(), darkModeSeedColor.a.toString()]);
                            setState(() {});
                            MyApp.themeNotifier.value = ThemeMode.light;
                            MyApp.themeNotifier.value = ThemeMode.dark;
                          }
                        },
                        style: ButtonStyle(backgroundColor: appThemeMode == AppThemeMode.light ? WidgetStatePropertyAll(lightModeSeedColor) : WidgetStatePropertyAll(darkModeSeedColor)),
                        child: const SizedBox(),
                      ),
                    ),

                    // UI Opacity
                    SettingsHeader(icon: Icons.opacity, text: appText.uiOpacity),
                    SizedBox(
                      width: double.infinity,
                      child: SliderTheme(
                          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.always),
                          child: Slider(
                            value: uiBackgroundColorAlpha.value.toDouble(),
                            min: 0,
                            max: 255,
                            label: uiBackgroundColorAlpha.toString(),
                            onChanged: (value) async {
                              final prefs = await SharedPreferences.getInstance();
                              uiBackgroundColorAlpha.value = value.round();
                              prefs.setInt('uiBackgroundColorAlpha', uiBackgroundColorAlpha.value);
                              setState(() {});
                            },
                          )),
                    ),

                    // Aux UI Opacity
                    SettingsHeader(icon: Icons.opacity_outlined, text: appText.auxiliaryUIOpacity),
                    SizedBox(
                      width: double.infinity,
                      child: SliderTheme(
                          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.always),
                          child: Slider(
                            value: uiDialogBackgroundColorAlpha.value.toDouble(),
                            min: 0,
                            max: 255,
                            label: uiDialogBackgroundColorAlpha.toString(),
                            onChanged: (value) async {
                              final prefs = await SharedPreferences.getInstance();
                              uiDialogBackgroundColorAlpha.value = value.round();
                              prefs.setInt('uiDialogBackgroundColorAlpha', uiDialogBackgroundColorAlpha.value);
                              setState(() {});
                            },
                          )),
                    ),

                    // Background slideshow
                    SettingsHeader(icon: Icons.slideshow, text: appText.backgroundSlideshow),
                    const SizedBox(
                      width: double.infinity,
                      child: BackgroundSlideshow(
                        isMini: true,
                      ),
                    ),
                    // Locations
                    SettingsHeader(icon: Icons.folder_open, text: appText.locations),
                    Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LocationButton(label: appText.pso2binFolder, folderPath: pso2binDirPath),
                        LocationButton(label: appText.modManagerMainFolder, folderPath: mainDataDirPath),
                        LocationButton(label: appText.checksumFolder, folderPath: p.dirname(modChecksumFilePath)),
                        LocationButton(label: appText.modDataFolder, folderPath: mainModDirPath),
                        LocationButton(label: appText.modBackupFolder, folderPath: backupDirPath),
                        LocationButton(label: appText.modConfigsBackupFolder, folderPath: jsonBackupDirPath),
                        LocationButton(label: appText.backgroundImageFolder, folderPath: backgroundDirPath),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
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
