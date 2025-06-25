import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/export_import/export_import_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> modExportPopup(context, ExportType exportType, String exportFileName, Item item, Mod? mod, SubMod? submod) async {
  final Future future = exportType == ExportType.submods
      ? submodExportFunction(exportFileName, mod, submod)
      : exportType == ExportType.mods
          ? modExportFunction(exportFileName, mod)
          : itemExportFunction(exportFileName, item);
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
                                  appText.exportingMods,
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
                                exportStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    return FutureBuilderError(
                      loadingText: appText.exportingMods,
                      snapshotError: snapshot.error.toString(),
                      isPopup: true, showContButton: false,
                    );
                  } else {
                    File? exportedFile = snapshot.data;
                    return CardOverlay(
                        paddingValue: 10,
                        child: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(exportedFile!.existsSync() ? appText.successful : appText.failed, style: Theme.of(context).textTheme.labelLarge),
                            const SizedBox(
                              width: 250,
                              child: HoriDivider(),
                            ),
                            Row(
                              spacing: 5,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Visibility(
                                  visible: exportedFile.existsSync(),
                                  child: OutlinedButton(
                                      onPressed: () {
                                        launchUrlString(exportedFile.parent.path);
                                      },
                                      child: Text(appText.openInFileExplorer)),
                                ),
                                OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(appText.returns))
                              ],
                            )
                          ],
                        ));
                  }
                },
              ));
        });
      });
}
