import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_localization/item_locale.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/settings/repath_confirm_popup.dart';
import 'package:pso2_mod_manager/v3_functions/json_backup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/homepage.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppSettingsLayout extends StatefulWidget {
  const AppSettingsLayout({super.key});

  @override
  State<AppSettingsLayout> createState() => _AppSettingsLayoutState();
}

class _AppSettingsLayoutState extends State<AppSettingsLayout> {
  late List<AppLocale> appLocales;
  bool reloadButtonVisible = false;
  String latestJsonBackupDate = '';

  @override
  void initState() {
    // Load app locales
    appLocales = AppLocale().loadLocales();
    latestJsonBackupDate = getLatestBackupDate();
    super.initState();
  }

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
                                  onPressed: () async {
                                    reloadButtonVisible = false;
                                    // pso2RegionVersion.value = await pso2RegionCheck();
                                    pageIndex = 6;
                                    curPage.value = appPages[pageIndex];
                                  },
                                  child: Text(appText.reload)),
                            )),
                        // Language
                        SettingsHeader(icon: Icons.language, text: appText.uiLanguage),
                        AnimatedHorizontalToggleLayout(
                          taps: appLocales.map((e) => e.language).toList(),
                          initialIndex: appLocales.indexWhere((e) => e.isActive),
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            for (var e in appLocales) {
                              e.isActive = false;
                            }
                            appLocales[targetIndex].isActive = true;
                            appLocales[targetIndex].saveSettings(appLocales);
                            appText = AppText.fromJson(jsonDecode(File(appLocales[targetIndex].translationFilePath).readAsStringSync()));
                            final prefs = await SharedPreferences.getInstance();
                            activeUILanguage = appLocales[targetIndex].language;
                            prefs.setString('activeUILanguage', activeUILanguage);
                            settingChangeStatus.value = 'Changed UI langage to ${appLocales[targetIndex].language}';
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
                        // v2 Homepage
                        SettingsHeader(icon: Icons.view_sidebar, text: appText.homepageStyle),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.legacy, appText.xnew],
                          initialIndex: v2Homepage.value ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? v2Homepage.value = true : v2Homepage.value = false;
                            prefs.setBool('v2Homepage', v2Homepage.value);
                          },
                        ),
                        // v2 Homepage Applied list hide
                        Visibility(visible: v2Homepage.watch(context), child: SettingsHeader(icon: Icons.highlight_alt_outlined, text: appText.hideAppliedList)),
                        Visibility(
                          visible: v2Homepage.watch(context),
                          child: AnimatedHorizontalToggleLayout(
                            taps: [appText.show, appText.hide],
                            initialIndex: showAppliedListV2.value ? 0 : 1,
                            width: constraints.maxWidth,
                            onChange: (currentIndex, targetIndex) async {
                              final prefs = await SharedPreferences.getInstance();
                              targetIndex == 0 ? showAppliedListV2.value = true : showAppliedListV2.value = false;
                              prefs.setBool('showAppliedListV2', showAppliedListV2.value);
                            },
                          ),
                        ),
                        // Default Homepage
                        SettingsHeader(icon: Icons.home, text: appText.defaultHomepage),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.itemList, appText.modList, appText.modSets],
                          initialIndex: defaultHomepageIndex,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            defaultHomepageIndex = targetIndex;
                            prefs.setInt('defaultHomepageIndex', defaultHomepageIndex);
                          },
                        ),
                        // Side menu
                        SettingsHeader(icon: Icons.view_sidebar, text: appText.sideBar),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.minimal, appText.alwaysExpanded],
                          initialIndex: sideMenuAlwaysExpanded ? 1 : 0,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 1 ? sideMenuAlwaysExpanded = true : sideMenuAlwaysExpanded = false;
                            sideMenuAlwaysExpanded ? sideBarCollapse.value = false : sideBarCollapse.value = true;
                            prefs.setBool('sideMenuAlwaysExpanded', sideMenuAlwaysExpanded);
                          },
                        ),
                        // Item icon slides
                        SettingsHeader(icon: Icons.slow_motion_video, text: appText.itemIconSlides),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.on, appText.off],
                          initialIndex: itemIconSlides.watch(context) ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? itemIconSlides.value = true : itemIconSlides.value = false;
                            prefs.setBool('itemIconSlides', itemIconSlides.value);
                          },
                        ),
                        // Hide empty cate
                        SettingsHeader(icon: Icons.hide_source, text: appText.hideEmptyCategories),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.on, appText.off],
                          initialIndex: hideEmptyCategories ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? hideEmptyCategories = true : hideEmptyCategories = false;
                            prefs.setBool('hideEmptyCategories', hideEmptyCategories);
                          },
                        ),
                        // Screensaver
                        SettingsHeader(icon: Icons.photo_size_select_large_rounded, text: appText.hideUIWhenAppUnfocused),
                        AnimatedHorizontalToggleLayout(
                          taps: [appText.on, appText.off],
                          initialIndex: hideUIWhenAppUnfocused ? 0 : 1,
                          width: constraints.maxWidth,
                          onChange: (currentIndex, targetIndex) async {
                            final prefs = await SharedPreferences.getInstance();
                            targetIndex == 0 ? hideUIWhenAppUnfocused = true : hideUIWhenAppUnfocused = false;
                            prefs.setBool('hideUIWhenAppUnfocused', hideUIWhenAppUnfocused);
                          },
                        ),
                        Row(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Text(appText.startAfter, style: Theme.of(context).textTheme.labelMedium),
                            Expanded(
                              child: SliderTheme(
                                  data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.always),
                                  child: Slider(
                                    value: hideUIInitDelaySeconds.toDouble(),
                                    min: 0,
                                    max: 250,
                                    label: appText.dText(appText.intervalNumSecond, hideUIInitDelaySeconds.toString()),
                                    onChanged: (value) async {
                                      final prefs = await SharedPreferences.getInstance();
                                      hideUIInitDelaySeconds = value.toInt();
                                      prefs.setInt('hideUIInitDelaySeconds', hideUIInitDelaySeconds);
                                      setState(() {});
                                    },
                                  )),
                            ),
                          ],
                        ),
                        // jsons backup
                        SettingsHeader(icon: Icons.backup_table_sharp, text: appText.dText(appText.modConfigsLastSaveDate, latestJsonBackupDate)),
                        Row(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                                onPressed: () async {
                                  await jsonManualBackup();
                                  latestJsonBackupDate = getLatestBackupDate();
                                  setState(() {});
                                },
                                child: Text(appText.backupNow)),
                            Expanded(
                              child: OutlinedButton(
                                  onPressed: () async {
                                    launchUrlString(jsonBackupDirPath);
                                  },
                                  child: Text(appText.openInFileExplorer)),
                            ),
                          ],
                        ),
                        // Main paths reselect
                        SettingsHeader(icon: Icons.folder, text: appText.mainPaths),
                        Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ModManTooltip(
                              message: appText.dText(appText.currentPathFolder, pso2binDirPath),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                    onPressed: () async {
                                      final result = await repathConfirmPopup(context, true, pso2binDirPath);
                                      if (result) {
                                        final prefs = await SharedPreferences.getInstance();
                                        pso2binDirPath = '';
                                        modManCurActiveProfile == 1 ? prefs.setString('pso2binDirPath', pso2binDirPath) : prefs.setString('pso2binDirPath_profile2', pso2binDirPath);
                                        pageIndex = 6;
                                        curPage.value = appPages[pageIndex];
                                      }
                                    },
                                    child: Text(appText.selectPso2BinFolder)),
                              ),
                            ),
                            ModManTooltip(
                              message: appText.dText(appText.currentPathFolder, mainDataDirPath),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                    onPressed: () async {
                                      final result = await repathConfirmPopup(context, false, mainDataDirPath);
                                      if (result) {
                                        final prefs = await SharedPreferences.getInstance();
                                        mainDataDirPath = '';
                                        prefs.setString('mainDataDirPath', mainDataDirPath);
                                        pageIndex = 6;
                                        curPage.value = appPages[pageIndex];
                                      }
                                    },
                                    child: Text(appText.selectModManagerDataFolder)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )))
          ],
        );
      },
    );
  }
}
