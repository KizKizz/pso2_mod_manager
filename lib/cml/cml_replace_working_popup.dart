import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/cml/cml_class.dart';
import 'package:pso2_mod_manager/cml/cml_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<void> cmlReplaceWorkingPopup(context, bool isRestoring, Cml cmlItem, File? cmlReplacementFile) async {
  Signal<bool> finished = Signal(false);
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (finished.watch(context)) {
            finished.value = false;
            Navigator.of(context).pop();
          }
        });
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(5),
              contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
              content: FutureBuilder(
                future: cmlFileReplacement(cmlItem, cmlReplacementFile!),
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
                                  appText.dText(appText.editingMod, cmlItem.getName()),
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
                                modApplyStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    return FutureBuilderError(
                      loadingText: appText.dText(appText.editingMod, cmlItem.getName()),
                      snapshotError: snapshot.error.toString(),
                      isPopup: true,
                    );
                  } else {
                    bool result = snapshot.data;
                    if (!isRestoring && result) {
                      cmlItem.isReplaced = true;
                      cmlItem.replacedCmlFileName = p.basename(cmlReplacementFile.path);
                    }
                    finished.value = true;
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
