import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/material_app_service.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/v3_functions/item_icons_refresh.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

Future<void> itemIconsRefreshPopup() async {
  dynamic context = MaterialAppService.navigatorKey.currentContext;
  Signal<String> status = Signal('');
  late final Future future = itemIconsRefresh(status);
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
                                  appText.refreshingItemIcons,
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
                                appText.dText(appText.fetchingIconsInItem, status.watch(context)),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ))
                      ],
                    ));
                  } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                    saveMasterModListToJson();
                    return FutureBuilderError(
                      loadingText: appText.refreshingItemIcons,
                      snapshotError: snapshot.error.toString(),
                      isPopup: true, showContButton: false,
                    );
                  } else {
                    saveMasterModListToJson();
                    mainGridStatus.value = 'All item icons refreshed and returning popup';
                    Navigator.of(context).pop();
                    return const SizedBox();
                  }
                },
              ));
        });
      });
}
