// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/app_version/data_version_check.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

class AppPathPage extends StatefulWidget {
  const AppPathPage({super.key});

  @override
  State<AppPathPage> createState() => _AppPathPageState();
}

class _AppPathPageState extends State<AppPathPage> {
  TextEditingController pso2binPathText = TextEditingController();
  TextEditingController mainDirPathText = TextEditingController();
  Signal<bool> pso2binPathSelected = Signal(false);
  Signal<bool> mainDirPathSelected = Signal(false);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: appMainPathsCheck(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return FutureBuilderLoading(loadingText: appText.fetchingNecessaryDirPaths);
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(loadingText: appText.fetchingNecessaryDirPaths, snapshotError: snapshot.error.toString());
        } else {
          bool pso2bin = snapshot.data.$1;
          bool mainDir = snapshot.data.$2;

          if (!pso2bin || !mainDir) {
            return Center(
                child: CardOverlay(
                    paddingValue: 15,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(appText.missingPathsFound, style: Theme.of(context).textTheme.headlineSmall),

                        // Pso2bin
                        Visibility(
                          visible: !pso2bin,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 10,
                              children: [
                                ModManTooltip(
                                  message: appText.pso2binDirPathInfo,
                                  child: const Icon(Icons.info_outline),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    controller: pso2binPathText,
                                    decoration: InputDecoration(labelText: appText.pso2binDirPath),
                                    maxLines: 1,
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      String? directoryPath = await getDirectoryPath();
                                      if (directoryPath != null && (p.basename(directoryPath) == 'pso2_bin' || p.basename(directoryPath) == 'Content')) {
                                        pso2binPathText.text = directoryPath;
                                        pso2binPathSelected.value = true;
                                      }
                                    },
                                    child: Text(appText.browse)),
                              ],
                            ),
                          ),
                        ),

                        // Main dir
                        Visibility(
                          visible: !mainDir,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 10,
                              children: [
                                ModManTooltip(
                                  message: appText.mainDirPathInfo,
                                  child: const Icon(Icons.info_outline),
                                ),
                                SizedBox(
                                  width: 250,
                                  child: TextField(
                                    controller: mainDirPathText,
                                    decoration: InputDecoration(labelText: appText.mainDirPath),
                                    maxLines: 1,
                                  ),
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      final String? directoryPath = await getDirectoryPath();
                                      if (directoryPath != null) {
                                        if (p.basename(directoryPath) == 'PSO2 Mod Manager') {
                                          mainDirPathText.text = directoryPath;
                                        } else {
                                          mainDirPathText.text = directoryPath.endsWith(p.separator) ? '${directoryPath}PSO2 Mod Manager' : '$directoryPath${p.separator}PSO2 Mod Manager';
                                        }
                                        mainDirPathSelected.value = true;
                                      }
                                    },
                                    child: Text(appText.browse))
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton(
                                onPressed: (pso2binPathSelected.watch(context) && mainDirPathSelected.watch(context)) ||
                                        (!pso2bin && mainDir && pso2binPathSelected.watch(context)) ||
                                        (pso2bin && !mainDir && mainDirPathSelected.watch(context))
                                    ? () async {
                                        final prefs = await SharedPreferences.getInstance();
                                        if (pso2binPathText.text.isNotEmpty) {
                                          pso2binDirPath = pso2binPathText.text;
                                          modManCurActiveProfile == 1 ? prefs.setString('pso2binDirPath', pso2binDirPath) : prefs.setString('pso2binDirPath_profile2', pso2binDirPath);
                                          pso2DataDirPath = '$pso2binDirPath${p.separator}data';
                                        }
                                        if (mainDirPathText.text.isNotEmpty) {
                                          mainDataDirPath = mainDirPathText.text;
                                          prefs.setString('mainDataDirPath', mainDataDirPath);
                                        }
                                        createMainDirs();
                                        pageIndex++;
                                        curPage.value = appPages[pageIndex];
                                      }
                                    : null,
                                child: Text(appText.save)),
                            ElevatedButton(
                                onPressed: () {
                                  windowManager.close();
                                },
                                child: Text(
                                  appText.exit,
                                  style: const TextStyle(color: Colors.red),
                                ))
                          ],
                        )
                      ],
                    )));
          } else {
            createMainDirs();
            pageIndex++;
            curPage.value = appPages[pageIndex];
            return const SizedBox();
          }
        }
      },
    );
  }
}
