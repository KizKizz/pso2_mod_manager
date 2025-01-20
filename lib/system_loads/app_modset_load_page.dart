import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> modsetLoadingStatus = Signal('');

class AppModSetLoadPage extends StatefulWidget {
  const AppModSetLoadPage({super.key});

  @override
  State<AppModSetLoadPage> createState() => _AppModSetLoadPageState();
}

class _AppModSetLoadPageState extends State<AppModSetLoadPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: modSetLoader(),
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
                        appText.loadingModSets,
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
                      modsetLoadingStatus.watch(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ))
            ],
          ));
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(loadingText: appText.loadingModSets, snapshotError: snapshot.error.toString());
        } else {
          masterModSetList = snapshot.data;
          saveMasterModSetListToJson();
          pageIndex++;
          curPage.value = appPages[pageIndex];
          return const SizedBox();
        }
      },
    );
  }
}
