import 'dart:io';
import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/settings/mod_configs_restore_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/json_backup.dart';
import 'package:pso2_mod_manager/v3_functions/profanity_remove.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class ModSettingsLayout extends StatefulWidget {
  const ModSettingsLayout({super.key});

  @override
  State<ModSettingsLayout> createState() => _ModSettingsLayoutState();
}

class _ModSettingsLayoutState extends State<ModSettingsLayout> {
  String latestJsonBackupDate = '';

  @override
  void initState() {
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
              appText.modSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const HoriDivider(),
            Expanded(
              child: SingleChildScrollView(
                physics: const SuperRangeMaintainingScrollPhysics(),
                child: Column(
                  spacing: 5,
                  children: [
                    // Backup priority
                    SettingsHeader(icon: Icons.backup_outlined, text: appText.originalFilesRestorePriority),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.segaServers, appText.localBackups],
                      initialIndex: originalFilesBackupsFromSega ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) async {
                        final prefs = await SharedPreferences.getInstance();
                        targetIndex == 0 ? originalFilesBackupsFromSega = true : originalFilesBackupsFromSega = false;
                        prefs.setBool('originalFilesBackupsFromSega', originalFilesBackupsFromSega);
                      },
                    ),
                    // Auto bounding radius
                    SettingsHeader(icon: Icons.radio_button_checked_rounded, text: appText.autoRemoveBoundingRadius),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.on, appText.off],
                      initialIndex: autoBoundingRadiusRemoval ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) async {
                        final prefs = await SharedPreferences.getInstance();
                        targetIndex == 0 ? autoBoundingRadiusRemoval = true : autoBoundingRadiusRemoval = false;
                        prefs.setBool('autoBoundingRadiusRemoval', autoBoundingRadiusRemoval);
                      },
                    ),
                    // Bounding radius value
                    SettingsHeader(icon: Icons.radio_button_checked_rounded, text: appText.boundingRadiusRemovalValue),
                    SizedBox(
                      width: double.infinity,
                      child: SliderTheme(
                          data: SliderThemeData(overlayShape: SliderComponentShape.noOverlay, showValueIndicator: ShowValueIndicator.always),
                          child: Slider(
                            value: boundingRadiusRemovalValue,
                            min: -200,
                            max: 0,
                            label: boundingRadiusRemovalValue.toString(),
                            onChanged: (value) async {
                              final prefs = await SharedPreferences.getInstance();
                              boundingRadiusRemovalValue = value.ceilToDouble();
                              prefs.setDouble('boundingRadiusRemovalValue', boundingRadiusRemovalValue);
                              setState(() {});
                            },
                          )),
                    ),
                    // Auto remove custom aqm
                    SettingsHeader(icon: Icons.auto_fix_high, text: appText.autoInjectCustomAQM),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.on, appText.off],
                      initialIndex: autoInjectCustomAqm ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) async {
                        final prefs = await SharedPreferences.getInstance();
                        targetIndex == 0 ? autoInjectCustomAqm = true : autoInjectCustomAqm = false;
                        prefs.setBool('autoInjectCustomAqm', autoInjectCustomAqm);
                      },
                    ),
                    // Custom AQM settings
                    SettingsHeader(icon: Icons.auto_fix_high, text: appText.customAQMFiles),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          onPressed: () async {
                            const XTypeGroup aqmTypeGroup = XTypeGroup(
                              label: 'AQM',
                              extensions: <String>['aqm'],
                            );
                            final List<XFile> files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
                              aqmTypeGroup,
                            ]);
                            for (var file in files) {
                              await File(file.path).copy(modCustomAqmsDirPath + p.separator + p.basename(file.path));
                              setState(() {});
                            }
                          },
                          child: Text(appText.addCustomAqmFiles)),
                    ),
                    SingleChoiceSelectButton(
                        width: double.infinity,
                        height: 30,
                        label: appText.currentAqmFile,
                        selectPopupLabel: appText.customAQMFiles,
                        availableItemList: Directory(modCustomAqmsDirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '.aqm').map((e) => e.path).toList(),
                        availableItemLabels: [],
                        selectedItemsLabel: Directory(modCustomAqmsDirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '.aqm').map((e) => e.path).toList(),
                        selectedItem: selectedCustomAQMFilePath,
                        extraWidgets: [],
                        savePref: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('selectedCustomAQMFilePath', selectedCustomAQMFilePath.value);
                        }),
                    // Mark modded items
                    SettingsHeader(icon: Icons.image_search_rounded, text: appText.markModdedItemInGame),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.on, appText.off],
                      initialIndex: replaceItemIconOnApplied ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) async {
                        final prefs = await SharedPreferences.getInstance();
                        targetIndex == 0 ? replaceItemIconOnApplied = true : replaceItemIconOnApplied = false;
                        prefs.setBool('replaceItemIconOnApplied', replaceItemIconOnApplied);
                        // Isolate.run(() => profanityRemove);
                      },
                    ),
                    // Remove profanity filter
                    SettingsHeader(icon: Icons.abc, text: appText.removeProfanityFilter),
                    AnimatedHorizontalToggleLayout(
                      taps: [appText.on, appText.off],
                      initialIndex: removeProfanityFilter ? 0 : 1,
                      width: constraints.maxWidth,
                      onChange: (currentIndex, targetIndex) async {
                        final prefs = await SharedPreferences.getInstance();
                        targetIndex == 0 ? removeProfanityFilter = true : removeProfanityFilter = false;
                        prefs.setBool('removeProfanityFilter', removeProfanityFilter);
                        Isolate.run(() => profanityRemove);
                      },
                    ),
                    // Mod apply settings
                    SettingsHeader(icon: Icons.high_quality_outlined, text: appText.applyOnlyHQFilesFromMods),
                    ModManTooltip(
                      message: appText.applyHQOnlyInfo,
                      child: AnimatedHorizontalToggleLayout(
                        taps: [appText.allPossible, appText.selectedOnly, appText.off],
                        initialIndex: modAlwaysApplyHQFiles
                            ? 0
                            : selectedModsApplyHQFilesOnly
                                ? 1
                                : 2,
                        width: constraints.maxWidth,
                        onChange: (currentIndex, targetIndex) async {
                          final prefs = await SharedPreferences.getInstance();
                          targetIndex == 0 ? modAlwaysApplyHQFiles = true : modAlwaysApplyHQFiles = false;
                          prefs.setBool('modAlwaysApplyHQFiles', modAlwaysApplyHQFiles);
                          targetIndex == 1 ? selectedModsApplyHQFilesOnly = true : selectedModsApplyHQFilesOnly = false;
                          prefs.setBool('selectedModsApplyHQFilesOnly', selectedModsApplyHQFilesOnly);
                        },
                      ),
                    ),
                    // jsons backup
                    SettingsHeader(icon: Icons.backup_table_sharp, text: appText.dText(appText.modConfigsLastSaveDate, latestJsonBackupDate)),
                    Row(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () async {
                                await jsonManualBackup();
                                latestJsonBackupDate = getLatestBackupDate();
                                setState(() {});
                              },
                              child: Text(appText.backupNow)),
                        ),
                        Expanded(
                          child: OutlinedButton(
                              onPressed: () async {
                                List<File> configBackups = Directory(jsonBackupDirPath).listSync().whereType<File>().where((e) => p.extension(e.path) == '.zip').toList();
                                configBackups.sort(
                                  (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
                                );
                                if (configBackups.isNotEmpty) {
                                  await modConfigsRestorePopup(context, latestJsonBackupDate, configBackups);
                                }
                              },
                              child: Text(appText.restore)),
                        ),
                        ModManTooltip(
                          message: appText.openInFileExplorer,
                          child: OutlinedButton.icon(
                              onPressed: () async {
                                launchUrlString(jsonBackupDirPath);
                              },
                              label: const Icon(Icons.folder_open)),
                        ),
                      ],
                    ),
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
