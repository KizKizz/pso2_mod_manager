import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/cml/cml_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';

class AppCmlItemLoadPage extends StatefulWidget {
  const AppCmlItemLoadPage({super.key});

  @override
  State<AppCmlItemLoadPage> createState() => _AppAqmItemLoadPageState();
}

class _AppAqmItemLoadPageState extends State<AppCmlItemLoadPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: cmlItemsLoad(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: CardOverlay(
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
                      appText.loadingAqmInjectedItems,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(
            loadingText: appText.loadingAqmInjectedItems,
            snapshotError: snapshot.error.toString(),
            isPopup: false,
          );
        } else {
          masterCMLItemList = snapshot.data;
          saveMasterCmlItemListToJson();
          pageIndex++;
          curPage.value = appPages[pageIndex];
          return const SizedBox();
        }
      },
    );
  }
}
