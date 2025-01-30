import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

Future<bool> lineStrikeBoardApplyPopup(context, String customImagePath, LineStrikeBoard board) async {
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
                future: customBoardImageApply(customImagePath, board),
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
                                  appText.dText(appText.editingMod, board.iceDdsName),
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
                    return FutureBuilderError(loadingText: appText.dText(appText.editingMod, board.iceDdsName), snapshotError: snapshot.error.toString());
                  } else {
                    bool result = snapshot.data;
                    Navigator.of(context).pop(result);
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
