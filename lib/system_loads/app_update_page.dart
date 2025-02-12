import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_version/app_version_check.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/system_loads/player_data_update_page.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import 'package:path/path.dart' as p;

class AppUpdatePage extends StatefulWidget {
  const AppUpdatePage({super.key});

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  Signal<String> downloadStatus = Signal('');
  Signal<double> downloadProgress = Signal(0);
  File? patchLauncher;

  @override
  Widget build(BuildContext context) {
    if (offlineMode) {
      pageIndex++;
      curPage.value = appPages[pageIndex];
      return const SizedBox();
    } else {
      return FutureBuilder(
        future: appLatestReleaseFetch(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return FutureBuilderLoading(loadingText: appText.checkingAppVersion);
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return FutureBuilderError(loadingText: appText.checkingAppVersion, snapshotError: snapshot.error.toString());
          } else {
            String remoteVersion = snapshot.data.$1;
            String remotePatchNotes = snapshot.data.$2;
            if (remoteVersion.isNotEmpty && remoteVersion != curAppVersion && newAppVersionCheck(remoteVersion)) {
              return Center(
                  child: CardOverlay(
                      paddingValue: 15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(appText.newAppVersionFound, style: Theme.of(context).textTheme.headlineSmall),
                          Padding(padding: const EdgeInsets.only(top: 5), child: Text('v$remoteVersion', style: Theme.of(context).textTheme.titleSmall)),
                          Padding(padding: const EdgeInsets.only(top: 20, bottom: 5), child: Text('${appText.patchNotes}:', style: Theme.of(context).textTheme.titleMedium)),
                          SingleChildScrollView(
                            child: Text(remotePatchNotes),
                          ),

                          Visibility(
                            visible: downloadStatus.watch(context).isEmpty,
                            child: Column(children: [
                              const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
                              Wrap(
                                spacing: 10,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        final task = DownloadTask(
                                          url: 'https://github.com/KizKizz/pso2_mod_manager/releases/download/v$remoteVersion/PSO2NGSModManager_v$remoteVersion.zip',
                                          filename: 'PSO2NGSModManager_v$remoteVersion.zip',
                                          directory: '${Directory.current.path}${p.separator}appUpdate',
                                          updates: Updates.statusAndProgress,
                                          retries: 2,
                                        );
                                        await FileDownloader().download(task, onProgress: (progress) => downloadProgress.value = progress, onStatus: (status) => downloadStatus.value = status.name);
                                        final updaterTask = DownloadTask(
                                          url: 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/updater/updater.exe',
                                          filename: 'updater.exe',
                                          directory: '${Directory.current.path}${p.separator}appUpdate',
                                          updates: Updates.statusAndProgress,
                                          retries: 2,
                                        );
                                        await FileDownloader().download(updaterTask, onProgress: (progress) => downloadProgress.value = progress, onStatus: (status) => downloadStatus.value = status.name);
                                        // Unpack and apply
                                        downloadStatus.value = appText.extractingDownloadedZipFile;
                                        await extractFileToDisk('${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion.zip',
                                            '${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion');
                                        // Create launcher
                                        patchLauncher = await patchFileLauncherGenerate(remoteVersion);
                                        patchLauncher != null && patchLauncher!.existsSync()
                                            ? downloadStatus.value = appText.extractCompletedReadyToPatch
                                            : downloadStatus.value = appText.cannotCreatePatchLauncherCheckPerm;
                                      },
                                      child: Text(appText.update)),
                                  ElevatedButton(
                                      onPressed: () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        appVersionUpdateSkip = remoteVersion;
                                        prefs.setString('appVersionUpdateSkip', appVersionUpdateSkip);
                                      },
                                      child: Text(appText.skip)),
                                  ElevatedButton(
                                      onPressed: () {
                                        pageIndex++;
                                        curPage.value = appPages[pageIndex];
                                      },
                                      child: Text(appText.later))
                                ],
                              ),
                            ]),
                          ),

                          // Downloading Panel
                          Visibility(
                              visible: downloadStatus.watch(context).isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        width: 250,
                                        child: LinearProgressIndicator(
                                          value: downloadProgress.watch(context),
                                        )),
                                    Text(downloadStatus.watch(context)),
                                    const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
                                    ElevatedButton(
                                        onPressed: patchLauncher != null && downloadStatus.watch(context) == appText.extractCompletedReadyToPatch
                                            ? () {
                                                if (patchLauncher != null && patchLauncher!.existsSync()) {
                                                  Process.run(patchLauncher!.path, []);
                                                } else {
                                                  curPage.value = const DataUpdatePage();
                                                }
                                              }
                                            : null,
                                        child: Text(patchLauncher != null && downloadStatus.watch(context) == appText.extractCompletedReadyToPatch ? appText.patch : appText.tryAgainLater)),
                                  ],
                                ),
                              ))
                        ],
                      )));
            } else {
              pageIndex++;
              curPage.value = appPages[pageIndex];
              return const SizedBox();
            }
          }
        },
      );
    }
  }
}
