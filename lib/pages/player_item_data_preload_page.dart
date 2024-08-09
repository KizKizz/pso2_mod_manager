// ignore_for_file: unused_import

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/functions/player_item_data.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/pages/applied_mods_checking_page.dart';
import 'package:pso2_mod_manager/pages/mod_set_loading_page.dart';
import 'package:pso2_mod_manager/pages/mods_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class PlayerItemDataPreloadingPage extends StatefulWidget {
  const PlayerItemDataPreloadingPage({super.key});

  @override
  State<PlayerItemDataPreloadingPage> createState() => _PlayerItemDataPreloadingPageState();
}

class _PlayerItemDataPreloadingPageState extends State<PlayerItemDataPreloadingPage> {
  @override
  Widget build(BuildContext context) {
    final playerItemDataPreload = playerItemDataGet(context);
    return FutureBuilder(
        future: playerItemDataPreload,
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    curLangText!.uiLoadingPlayerItemData,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              if (File(modManPlayerItemDataPath).existsSync()) {
                File(modManPlayerItemDataPath).deleteSync();
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiErrorWhenLoadingPlayerItemData,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(curLangText!.uiPlayerItemDataError, textAlign: TextAlign.center, softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 13)),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              windowManager.destroy();
                            },
                            child: Text(curLangText!.uiExit)),
                        const SizedBox(width: 5),
                        ElevatedButton(
                            onPressed: () async {
                              const XTypeGroup typeGroup = XTypeGroup(
                                label: '.json',
                                extensions: <String>['json'],
                              );
                              final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                              if (selectedFile != null && File(selectedFile.path).existsSync()) {
                                await File(selectedFile.path).copy(modManPlayerItemDataPath);
                                if (File(modManPlayerItemDataPath).existsSync() && refSheetsNewVersion > 0) {
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setInt('refSheetsVersion', refSheetsNewVersion);
                                  refSheetsVersion = refSheetsNewVersion;
                                  modManRefSheetsLocalVersion = refSheetsNewVersion;
                                  File(modManRefSheetsLocalVerFilePath).writeAsString(refSheetsNewVersion.toString());
                                  // ignore: use_build_context_synchronously
                                  Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableFalse();
                                  // ignore: use_build_context_synchronously
                                  Provider.of<StateProvider>(context, listen: false).playerItemDataDownloadPercentReset();
                                }
                                setState(() {});
                              }
                            },
                            child: Text(curLangText!.uiImportItemDataFile)),
                        const SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              await launchUrl(Uri.parse('https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/playerItemData.json'));
                            },
                            child: Text(curLangText!.uiManuallyDownload)),
                      ],
                    )
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      curLangText!.uiLoadingPlayerItemData,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              playerItemData = snapshot.data;

              return const ModsLoadingPage();
            }
          }
        });
  }
}
