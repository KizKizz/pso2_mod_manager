import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_apply/apply_functions.dart';
import 'package:pso2_mod_manager/mod_apply/unapply_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

Future<void> applyingPopup(context, bool applying, Item item, Mod mod, SubMod submod, List<ModFile> extraModFiles) async {
  bool? taskFinished;
  final Future future = applying ? modBackupApply(item, mod, submod, extraModFiles) : modUnapplyRestore(item, mod, submod, extraModFiles);

  Future<void> popupDismiss() async {
    await Future.delayed(Duration.zero);
    if (taskFinished != null && taskFinished == true) {
      taskFinished = false;
      Navigator.of(context).pop();
    }
  }

  await showDialog(
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
                                  applying ? appText.dText(appText.applyingMod, submod.submodName) : appText.dText(appText.restoringModBackups, submod.submodName),
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
                      loadingText: applying ? appText.dText(appText.applyingMod, submod.submodName) : appText.dText(appText.restoringModBackups, submod.submodName),
                      snapshotError: snapshot.error.toString(),
                      isPopup: true, showContButton: false,
                    );
                  } else {
                    taskFinished ??= true;
                    popupDismiss();
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
