import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> aqmInjectPopup(
    context, String customAQMFilePath, String hqIcePath, String lqIcePath, String itemName, bool restoreAqm, bool restoreBounding, bool restoreAll, bool aqmInjected, bool fromSubmod) async {
  // Signal<bool> finished = Signal(false);
  bool result = false;
  Future future = restoreAqm
      ? itemCustomAqmRestoreAqm(hqIcePath, lqIcePath, fromSubmod)
      : restoreBounding
          ? itemCustomAqmRestoreBounding(context, File(customAQMFilePath).existsSync() ? customAQMFilePath : selectedCustomAQMFilePath.value, hqIcePath, lqIcePath, aqmInjected)
          : restoreAll
              ? itemCustomAqmRestoreAll(hqIcePath, lqIcePath)
              : itemCustomAqmInject(context, File(customAQMFilePath).existsSync() ? customAQMFilePath : selectedCustomAQMFilePath.value, hqIcePath, lqIcePath, fromSubmod);
  if (Directory(modAqmInjectTempDirPath).existsSync()) Directory(modAqmInjectTempDirPath).deleteSync(recursive: true);
  await Directory(modAqmInjectTempDirPath).create(recursive: true);
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   if (finished.watch(context)) {
        //     finished.value = false;
        //     Navigator.of(context).pop(result);
        //   }
        // });
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
                                  appText.dText(appText.editingMod, itemName),
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
                                modAqmInjectingStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    return FutureBuilderError(
                      loadingText: appText.dText(appText.editingMod, itemName),
                      snapshotError: snapshot.error.toString(),
                      isPopup: true,
                    );
                  } else {
                    result = snapshot.data;
                    // finished.value = true;
                    Navigator.of(context).pop(result);
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
