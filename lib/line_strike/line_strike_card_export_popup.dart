import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<File?> lineStrikeCardExportPopup(context, LineStrikeCard card) async {
  final Future future = cardExport(card);
  File? exportedFile;
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
                                appText.dText(appText.exportingFile, card.cardZeroDdsName),
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
                              lineStrikeStatus.watch(context),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ))
                    ],
                  ));
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  return FutureBuilderError(
                    loadingText: appText.dText(appText.exportingFile, card.cardZeroDdsName),
                    snapshotError: snapshot.error.toString(),
                    isPopup: true,
                  );
                } else {
                  exportedFile = snapshot.data;
                  return ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 350),
                      child: CardOverlay(
                          paddingValue: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lineStrikeStatus.watch(context),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const HoriDivider(),
                              Row(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: exportedFile != null && exportedFile!.existsSync(),
                                    child: OutlinedButton(
                                        onPressed: () {
                                          launchUrlString(lineStrikeExportedCardsDirPath);
                                        },
                                        child: Text(appText.openInFileExplorer)),
                                  ),
                                  OutlinedButton(onPressed: () => Navigator.of(context).pop(exportedFile), child: Text(appText.returns))
                                ],
                              )
                            ],
                          )));
                }
              },
            ),
            actions: exportedFile == null
                ? null
                : lineStrikeStatus.value == appText.failed
                    ? [OutlinedButton(onPressed: () => Navigator.of(context).pop(exportedFile), child: Text(appText.returns))]
                    : [],
          );
        });
      });
}
