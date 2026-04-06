import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_functions.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> vitalGaugeApplyPopup(context, String customImagePath, VitalGaugeBackground vgDataFile) async {
  bool? taskFinished;
  final Future future = customVgBackgroundApply(context, customImagePath, vgDataFile);

  Future<void> popupDismiss(bool result) async {
    await Future.delayed(Duration.zero);
    if (taskFinished != null && taskFinished == true) {
      taskFinished = false;
      Navigator.of(context).pop(result);
    }
  }

  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(5),
              contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
              content: FutureBuilder(
                future: future,
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
                                  appText.dText(appText.editingMod, vgDataFile.iceName),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 350),
                            child: CardOverlay(
                              paddingValue: 15,
                              child: Text(
                                vitalGaugeStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    return FutureBuilderError(
                      loadingText: appText.dText(appText.editingMod, vgDataFile.iceName),
                      snapshotError: snapshot.error.toString(),
                      isPopup: true, showContButton: false,
                    );
                  } else {
                    bool result = snapshot.data;
                    taskFinished ??= true;
                    popupDismiss(result);
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}

Future<bool> vitalGaugeRestorePopup(context, VitalGaugeBackground vgDataFile) async {
  bool? taskFinished;
  final Future future = vitalGaugeOriginalFileDownload(vgDataFile.icePath);

  Future<void> popupDismiss(bool result) async {
    await Future.delayed(Duration.zero);
    if (taskFinished != null && taskFinished == true) {
      taskFinished = false;
      Navigator.of(context).pop(result);
    }
  }

  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(5),
              contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
              content: FutureBuilder(
                future: future,
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
                                  appText.dText(appText.editingMod, vgDataFile.iceName),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 350),
                            child: CardOverlay(
                              paddingValue: 15,
                              child: Text(
                                vitalGaugeStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    return FutureBuilderError(
                      loadingText: appText.dText(appText.editingMod, vgDataFile.iceName),
                      snapshotError: snapshot.error.toString(),
                      isPopup: true, showContButton: false,
                    );
                  } else {
                    File downloadedFile = snapshot.data.$1;
                    String downloadedFileMd5 = snapshot.data.$2;
                    taskFinished ??= true;
                    if (downloadedFile.existsSync() && downloadedFileMd5 != vgDataFile.replacedMd5) {
                      popupDismiss(true);
                    } else {
                      popupDismiss(false);
                    }
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
