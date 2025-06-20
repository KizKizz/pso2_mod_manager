import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_version/data_version_check.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class DataUpdatePage extends StatefulWidget {
  const DataUpdatePage({super.key});

  @override
  State<DataUpdatePage> createState() => _DataUpdatePageState();
}

class _DataUpdatePageState extends State<DataUpdatePage> {
  Signal<String> downloadStatus = Signal('');
  Signal<double> downloadProgress = Signal(0);
  late DownloadTask task;

  @override
  Widget build(BuildContext context) {
    if (offlineMode) {
      return Center(
        child: CardOverlay(
            paddingValue: 15,
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: LoadingAnimationWidget.inkDrop(
                    color: Theme.of(context).colorScheme.primary,
                    size: 100,
                  ),
                ),
                Text(
                  appText.accessToGitHubIsLimited,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(appText.itemDataManualDownloadMessage, textAlign: TextAlign.center),
                Column(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(appText.step1),
                    OutlinedButton(
                        onPressed: () async {
                          await launchUrlString('https://github.com/KizKizz/pso2ngs_file_downloader/blob/main/json/playerItemData.json');
                        },
                        child: Text(appText.downloadItemData)),
                    Text(appText.step2),
                    OutlinedButton(
                        onPressed: () async {
                          await launchUrlString('${Directory.current.path}${p.separator}itemData');
                        },
                        child: Text(appText.browseDownloadedItemDataLocation))
                  ],
                ),
                const SizedBox(width: 350, child: HoriDivider()),
                Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                        onPressed: () {
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.save)),
                    OutlinedButton(
                        onPressed: () {
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.skip))
                  ],
                )
              ],
            )),
      );
    } else {
      return FutureBuilder(
        future: itemDataVersionFetch(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return FutureBuilderLoading(loadingText: appText.checkingItemDataVersion);
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return FutureBuilderError(
              loadingText: appText.checkingItemDataVersion,
              snapshotError: snapshot.error.toString(),
              isPopup: false, showContButton: true,
            );
          } else {
            String remoteVersion = snapshot.data.$1;
            String desc = snapshot.data.$2;
            File itemDataLocalVersionFile = File('${Directory.current.path}${p.separator}itemData${p.separator}itemDataLocalVersion.json');
            Map<String, dynamic> curItemDataVersion = jsonDecode(itemDataLocalVersionFile.readAsStringSync());
            if (!File('${Directory.current.path}${p.separator}itemData${p.separator}playerItemData.json').existsSync() ||
                (remoteVersion.isNotEmpty &&
                    int.parse(remoteVersion) > int.parse(curItemDataVersion.entries.firstWhere((e) => e.key == 'version', orElse: () => const MapEntry('version', '0')).value))) {
              return Center(
                  child: CardOverlay(
                      paddingValue: 15,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(appText.newItemDataVersionFound, style: Theme.of(context).textTheme.headlineSmall),
                          Padding(padding: const EdgeInsets.only(top: 5), child: Text('v$remoteVersion', style: Theme.of(context).textTheme.titleSmall)),
                          Text(desc),
                          Visibility(
                            visible: downloadStatus.watch(context).isEmpty || downloadStatus.watch(context) == TaskStatus.failed.name || downloadStatus.watch(context) == TaskStatus.canceled.name,
                            child: Column(children: [
                              const SizedBox(width: 150, child: Divider(height: 30, thickness: 2)),
                              Wrap(
                                spacing: 10,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        task = DownloadTask(
                                            url: 'https://raw.githubusercontent.com/KizKizz/pso2ngs_file_downloader/main/json/playerItemData.json',
                                            filename: 'playerItemData.json',
                                            baseDirectory: BaseDirectory.root,
                                            directory: '${Directory.current.path}${p.separator}itemData',
                                            updates: Updates.statusAndProgress,
                                            retries: 2,
                                            allowPause: true);
                                        final result = await FileDownloader()
                                            .download(task, onProgress: (progress) => downloadProgress.value = progress, onStatus: (status) => downloadStatus.value = status.name);

                                        if (result.status == TaskStatus.complete) {
                                          const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                          Map<String, dynamic> jsonData = {'version': remoteVersion};
                                          itemDataLocalVersionFile.writeAsStringSync(encoder.convert(jsonData));
                                        }
                                      },
                                      child: Text(downloadStatus.watch(context) == TaskStatus.failed.name ? appText.tryAgain : appText.update)),
                                  ElevatedButton(onPressed: () {}, child: Text(appText.later))
                                ],
                              ),
                            ]),
                          ),

                          // Downloading Panel
                          Visibility(
                              visible: downloadStatus.watch(context).isNotEmpty && downloadStatus.watch(context) != TaskStatus.failed.name && downloadStatus.watch(context) != TaskStatus.canceled.name,
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
                                    Visibility(visible: downloadStatus.watch(context) != TaskStatus.complete.name, child: const SizedBox(width: 150, child: Divider(height: 30, thickness: 2))),
                                    Visibility(
                                      visible: downloadStatus.watch(context) != TaskStatus.complete.name,
                                      child: Wrap(
                                        spacing: 10,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (downloadStatus.watch(context) == TaskStatus.paused.name) {
                                                  await FileDownloader().resume(task);
                                                } else {
                                                  await FileDownloader().pause(task);
                                                }
                                              },
                                              child: Text(downloadStatus.watch(context) == TaskStatus.paused.name ? appText.resume : appText.pause)),
                                          ElevatedButton(
                                              onPressed: () async {
                                                await FileDownloader().cancelTaskWithId(task.taskId);
                                              },
                                              child: Text(appText.cancel))
                                        ],
                                      ),
                                    )
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
