import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_version/app_version_check.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class AppUpdatePage extends SignalStatefulWidget {
  const AppUpdatePage({super.key});

  @override
  State<AppUpdatePage> createState() => _AppUpdatePageState();
}

class _AppUpdatePageState extends State<AppUpdatePage> {
  Signal<String> downloadStatus = Signal('');
  Signal<double> downloadProgress = Signal(0);
  // File? patchLauncher;
  File? updater;

  @override
  Widget build(BuildContext context) {
    if (offlineMode) {
      pageIndex++;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        curPage.value = appPages[pageIndex];
      });
      return const SizedBox();
    } else {
      return FutureBuilder(
        future: appLatestReleaseFetch(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return FutureBuilderLoading(loadingText: appText.checkingAppVersion);
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return FutureBuilderError(loadingText: appText.checkingAppVersion, snapshotError: snapshot.error.toString(), isPopup: false, showContButton: true);
          } else {
            String remoteVersion = snapshot.data.$1;
            String remotePatchNotes = snapshot.data.$2;
            if (remoteVersion.isNotEmpty && remoteVersion != curAppVersion && newAppVersionCheck(remoteVersion)) {
              Future<void> appUpdateDownload() async {
                await Directory('${Directory.current.path}${p.separator}appUpdate').create(recursive: true);
                final task = DownloadTask(
                  url: 'https://github.com/KizKizz/pso2_mod_manager/releases/download/v$remoteVersion/PSO2NGSModManager_v$remoteVersion.zip',
                  filename: 'PSO2NGSModManager_v$remoteVersion.zip',
                  baseDirectory: BaseDirectory.root,
                  directory: '${Directory.current.path}${p.separator}appUpdate',
                  updates: Updates.statusAndProgress,
                  retries: 2,
                );
                await FileDownloader().download(task, onProgress: (progress) => downloadProgress.value = progress, onStatus: (status) => downloadStatus.value = status.name);
                final updaterTask = DownloadTask(
                  url: 'https://raw.githubusercontent.com/KizKizz/pso2_mod_manager/refs/heads/main/updater/updater.exe',
                  filename: 'updater.exe',
                  baseDirectory: BaseDirectory.root,
                  directory: '${Directory.current.path}${p.separator}appUpdate',
                  updates: Updates.statusAndProgress,
                  retries: 2,
                );
                await FileDownloader().download(updaterTask, onProgress: (progress) => downloadProgress.value = progress, onStatus: (status) => downloadStatus.value = status.name);
                // Unpack and apply
                downloadStatus.value = appText.extractingDownloadedZipFile;
                await extractFileToDisk(
                  '${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion.zip',
                  '${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion',
                );
                // Create launcher
                // patchLauncher = await patchFileLauncherGenerate(remoteVersion);
                // patchLauncher != null && patchLauncher!.existsSync()
                //     ? downloadStatus.value = appText.extractCompletedReadyToPatch
                //     : downloadStatus.value = appText.cannotCreatePatchLauncherCheckPerm;

                updater = File('${Directory.current.path}${p.separator}appUpdate${p.separator}updater.exe');
                updater != null && updater!.existsSync() && Directory('${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion').existsSync()
                    ? downloadStatus.value = appText.extractCompletedReadyToPatch
                    : updater == null || !updater!.existsSync()
                    ? downloadStatus.value = appText.updaterNotFound
                    : !Directory('${Directory.current.path}${p.separator}appUpdate${p.separator}PSO2NGSModManager_v$remoteVersion').existsSync()
                    ? downloadStatus.value = appText.unableToExtractUpdateData
                    : downloadStatus.value = appText.unableToUpdate;
              }

              return Center(
                child: CardOverlay(
                  paddingValue: 15,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appText.newAppVersionFound, style: Theme.of(context).textTheme.headlineSmall),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text('v$remoteVersion', style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5),
                        child: Text('${appText.patchNotes}:', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      SingleChildScrollView(child: Text(remotePatchNotes)),

                      Visibility(
                        visible: downloadStatus.value.isEmpty,
                        child: Column(
                          children: [
                            const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
                            Wrap(
                              spacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await appUpdateDownload();
                                  },
                                  child: Text(appText.update),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    appVersionUpdateSkip = remoteVersion;
                                    prefs.setString('appVersionUpdateSkip', appVersionUpdateSkip);
                                  },
                                  child: Text(appText.skip),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    pageIndex++;
                                    curPage.value = appPages[pageIndex];
                                  },
                                  child: Text(appText.later),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Downloading Panel
                      Visibility(
                        visible: downloadStatus.value.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            children: [
                              SizedBox(width: 250, child: LinearProgressIndicator(value: downloadProgress.value)),
                              Text(downloadStatus.value),
                              const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
                              Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible:
                                        downloadStatus.value != appText.updaterNotFound &&
                                        downloadStatus.value != appText.unableToExtractUpdateData &&
                                        downloadStatus.value != appText.unableToUpdate,
                                    child: ElevatedButton(
                                      onPressed: downloadStatus.value == appText.extractCompletedReadyToPatch
                                          ? () {
                                              if (downloadStatus.value == appText.extractCompletedReadyToPatch) {
                                                Process.run(updater!.path, ['PSO2NGSModManager', remoteVersion, Directory.current.path]);
                                              }
                                            }
                                          : null,
                                      child: Text(appText.patch),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        downloadStatus.value == appText.updaterNotFound ||
                                        downloadStatus.value == appText.unableToExtractUpdateData ||
                                        downloadStatus.value == appText.unableToUpdate,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await appUpdateDownload();
                                      },
                                      child: Text(appText.tryAgain),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        downloadStatus.value == appText.updaterNotFound ||
                                        downloadStatus.value == appText.unableToExtractUpdateData ||
                                        downloadStatus.value == appText.unableToUpdate,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        pageIndex++;
                                        curPage.value = appPages[pageIndex];
                                      },
                                      child: Text(appText.tryAgainLater),
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        downloadStatus.value == appText.updaterNotFound ||
                                        downloadStatus.value == appText.unableToExtractUpdateData ||
                                        downloadStatus.value == appText.unableToUpdate,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await launchUrlString('https://github.com/KizKizz/pso2_mod_manager/releases');
                                      },
                                      child: Text(appText.manualDownload),
                                    ),
                                  ),
                                ],
                              ),
                              // ElevatedButton(
                              //     onPressed: patchLauncher != null && downloadStatus.value == appText.extractCompletedReadyToPatch
                              //         ? () {
                              //             // if (patchLauncher != null && patchLauncher!.existsSync()) {
                              //             //   Process.run('"${patchLauncher!.path}"', []);
                              //             // } else {
                              //             //   curPage.value = const DataUpdatePage();
                              //             // }
                              //           }
                              //         : null,
                              //     child: Text(patchLauncher != null && downloadStatus.value == appText.extractCompletedReadyToPatch ? appText.patch : appText.tryAgainLater)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              pageIndex++;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                curPage.value = appPages[pageIndex];
              });
              return const SizedBox();
            }
          }
        },
      );
    }
  }
}
