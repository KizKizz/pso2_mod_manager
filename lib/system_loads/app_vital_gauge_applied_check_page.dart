import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_background_grid_layout.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_functions.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_popups.dart';
import 'package:signals/signals_flutter.dart';

class AppVitalGaugeAppliedCheckPage extends StatefulWidget {
  const AppVitalGaugeAppliedCheckPage({super.key});

  @override
  State<AppVitalGaugeAppliedCheckPage> createState() => _AppVitalGaugeAppliedCheckPageState();
}

class _AppVitalGaugeAppliedCheckPageState extends State<AppVitalGaugeAppliedCheckPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: unappliedVitalGaugeCheck(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
              child: Column(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardOverlay(
                paddingValue: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        appText.checkingAppliedVitalGauges,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(loadingText: appText.checkingAppliedVitalGauges, snapshotError: snapshot.error.toString());
        } else {
          List<VitalGaugeBackground> unappliedVitalGaugeList = snapshot.data;
          if (unappliedVitalGaugeList.isEmpty) {
            pageIndex++;
            curPage.value = appPages[pageIndex];
            return const SizedBox();
          } else {
            return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
              insetPadding: const EdgeInsets.all(5),
              titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              title: Center(
                child: Text(
                  appText.restoredMods,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 00, bottom: 0, left: 10, right: 10),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Text(appText.restoredModInfo),
                  const HoriDivider(),
                  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height - 183, child: VitalGaugeBackgroundGridLayout(backgrounds: unappliedVitalGaugeList)),
                ],
              ),
              actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
              actions: [
                OverflowBar(
                  spacing: 5,
                  overflowSpacing: 5,
                  children: [
                    OutlinedButton(
                        onPressed: () async {
                          for (var vitalGauge in unappliedVitalGaugeList) {
                            final result = await vitalGaugeApplyPopup(context, vitalGauge.replacedImagePath, vitalGauge);
                            if (result) {
                              vitalGauge.replacedImagePath = vitalGauge.replacedImagePath;
                              vitalGauge.replacedImageName = vitalGauge.replacedImageName;
                              vitalGauge.isReplaced = true;
                              saveMasterVitalGaugeToJson(masterVitalGaugeBackgroundList);
                              setState(() {});
                            }
                          }
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.reApplyAll)),
                    OutlinedButton(
                        onPressed: () async {
                          for (var vitalGauge in unappliedVitalGaugeList) {
                            bool result = await vitalGaugeRestorePopup(context, vitalGauge);
                            if (result) {
                              vitalGauge.replacedMd5 = '';
                              vitalGauge.replacedImagePath = '';
                              vitalGauge.replacedImageName = '';
                              vitalGauge.isReplaced = false;
                              saveMasterVitalGaugeToJson(masterVitalGaugeBackgroundList);
                              setState(() {});
                            }
                          }
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.removeAll))
                  ],
                )
              ],
            );
          }
        }
      },
    );
  }
}
