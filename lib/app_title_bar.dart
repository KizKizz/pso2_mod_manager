import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/file_check/file_check_popup.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_apply/save_restore_function.dart';
import 'package:pso2_mod_manager/mod_apply/save_restore_popup.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_widgets/jp_game_start_btn.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_indicator.dart';
import 'package:pso2_mod_manager/v3_functions/pso2_version_check.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class AppTitleBar extends StatefulWidget {
  const AppTitleBar({super.key});

  @override
  State<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends State<AppTitleBar> {
  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }
    return AppBar(
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor, border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(5))),
            message: appText.dText(appText.madeBy, 'キス★ (KizKizz)'),
            textStyle: Theme.of(context).textTheme.titleSmall,
            child: Row(
              children: [
                Text(
                  appTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.headlineSmall!.color),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'v$curAppVersion',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.headlineSmall!.color),
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 2.5,
            mainAxisSize: MainAxisSize.min,
            children: [
              Visibility(
                  visible: appLoadingFinished.watch(context) && pso2RegionVersion.watch(context) == PSO2RegionVersion.jp,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 2.5),
                    child: JpGameStartBtn(),
                  )),
              // Visibility(
              //     // visible: appLoadingFinished.watch(context),
              //     visible: false,
              //     child: SizedBox(
              //       height: 20,
              //       child: OutlinedButton.icon(
              //           style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
              //           onPressed: () async {
              //             final prefs = await SharedPreferences.getInstance();
              //             showPreviewBox.value ? showPreviewBox.value = false : showPreviewBox.value = true;
              //             prefs.setBool('showPreviewBox', showPreviewBox.value);
              //           },
              //           icon: const Icon(
              //             Icons.preview,
              //             size: 18,
              //           ),
              //           label: Text(showPreviewBox.watch(context) ? appText.hidePreview : appText.showPreview)),
              //     )),

              Visibility(
                  visible: appLoadingFinished.watch(context),
                  child: SizedBox(
                    height: 20,
                    child: ModManTooltip(
                      message: appText.refresh,
                      child: OutlinedButton(
                        style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                        onPressed: () async {
                          selectedItemV2.value = null;
                          pageIndex = 6;
                          curPage.value = appPages[pageIndex];
                        },
                        child: const Icon(
                          Icons.refresh,
                          size: 18,
                        ),
                      ),
                    ),
                  )),

              Visibility(
                visible: appLoadingFinished.watch(context),
                child: SizedBox(
                  height: 20,
                  child: ModManTooltip(
                    message: saveRestoreAppliedModsActive.watch(context) ? '${appText.reApplyAllSavedMods}\n${appText.quickSaveRestoreModsInfo}' : '${appText.saveAndRestoreAllAppliedMods}\n${appText.quickSaveRestoreModsInfo}',
                    child: OutlinedButton(
                      style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                      onPressed: () async {
                        await saveRestorePopup(context, saveRestoreAppliedModsActive.value ? false : true);
                        saveRestoreAppliedModsCheck();
                      },
                      child: Icon(
                        saveRestoreAppliedModsActive.watch(context) ? Icons.save_alt : Icons.save,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              Visibility(
                  visible: appLoadingFinished.watch(context),
                  child: SizedBox(
                    height: 20,
                    child: ModManTooltip(
                      message: appText.gameDataIntegrityCheck,
                      child: OutlinedButton(
                        style: ButtonStyle(shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)))),
                        onPressed: () async {
                          await checkGameFilesPopup(context, false);
                        },
                        child: const Icon(
                          Icons.checklist_rounded,
                          size: 18,
                        ),
                      ),
                    ),
                  )),

              Visibility(visible: appLoadingFinished.watch(context), child: const ChecksumIndicator())
            ],
          )
        ],
      )),
      titleSpacing: 5,
      actions: [
        WindowCaptionButton.minimize(
          brightness: appThemeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
          onPressed: () => windowManager.minimize(),
        ),
        if (!windowMaximizedState.watch(context))
          WindowCaptionButton.maximize(
            brightness: appThemeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              windowManager.maximize();
              windowMaximizedState.value = true;
              prefs.setBool('windowMaximizedState', windowMaximizedState.value);
              setState(() {});
            },
          ),
        if (windowMaximizedState.watch(context))
          WindowCaptionButton.unmaximize(
            brightness: appThemeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              windowManager.unmaximize();
              windowMaximizedState.value = false;
              prefs.setBool('windowMaximizedState', windowMaximizedState.value);
              setState(() {});
            },
          ),
        WindowCaptionButton.close(
          brightness: appThemeMode == AppThemeMode.dark ? Brightness.dark : Brightness.light,
          onPressed: () => windowManager.close(),
        ),
      ],
    );
  }
}
