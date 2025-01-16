import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
                    SettingsHeader(icon: Icons.backup_outlined, text: appText.originalFilesBackupPriority),
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
