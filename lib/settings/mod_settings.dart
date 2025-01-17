import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/custom_aqm_file_select_button.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class ModSettingsLayout extends StatefulWidget {
  const ModSettingsLayout({super.key});

  @override
  State<ModSettingsLayout> createState() => _ModSettingsLayoutState();
}

class _ModSettingsLayoutState extends State<ModSettingsLayout> {
  @override
  Widget build(BuildContext context) {
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
                          data: const SliderThemeData(showValueIndicator: ShowValueIndicator.always),
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
                    SizedBox(width: double.infinity, child: CustomAqmSelectButtons(aqmFilePaths: modCustomAQMFiles.map((e) => e.path).toList())),
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
