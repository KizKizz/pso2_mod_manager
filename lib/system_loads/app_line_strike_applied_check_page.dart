import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:signals/signals_flutter.dart';

class AppLineStrikeAppliedCheckPage extends StatefulWidget {
  const AppLineStrikeAppliedCheckPage({super.key});

  @override
  State<AppLineStrikeAppliedCheckPage> createState() => _AppLineStrikeAppliedCheckPage();
}

class _AppLineStrikeAppliedCheckPage extends State<AppLineStrikeAppliedCheckPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: unappliedLineStrikeCheck(),
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
                        appText.checkingAppliedLineStrikeItems,
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
          return FutureBuilderError(loadingText: appText.checkingAppliedLineStrikeItems, snapshotError: snapshot.error.toString(), isPopup: false,);
        } else {
          pageIndex++;
          curPage.value = appPages[pageIndex];
          return const SizedBox();
        }
      },
    );
  }
}
