import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';

class OfficialDataFetchPage extends StatefulWidget {
  const OfficialDataFetchPage({super.key});

  @override
  State<OfficialDataFetchPage> createState() => _OfficialDataFetchPageState();
}

class _OfficialDataFetchPageState extends State<OfficialDataFetchPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: officialFileDetailsFetch(),
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
                      appText.fetchingDataFromSegaServers,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(loadingText: appText.fetchingDataFromSegaServers, snapshotError: snapshot.error.toString());
        } else {
          oItemData = snapshot.data.$1;
          oItemDataNA = snapshot.data.$2;
          segaMasterServerURL = snapshot.data.$3;
          segaMasterServerBackupURL = snapshot.data.$4;
          segaPatchServerURL = snapshot.data.$5;
          segaPatchServerBackupURL = snapshot.data.$6;
          pageIndex++;
          curPage.value = appPages[pageIndex];
          return const SizedBox();
        }
      },
    );
  }
}
