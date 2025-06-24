import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

enum FileScanType { all, win32, win32reboot, modifiedOnly }

enum FileScanProgress { waiting, idle, started, paused }

Future<void> checkGameFilesPopup(context) async {
  FileScanType fileScanType = FileScanType.all;
  FileScanProgress fileScanProgress = FileScanProgress.waiting;
  bool progStarted = false;
  bool progPaused = false;
  List<OfficialIceFile> checkedFiles = [];
  List<OfficialIceFile> missingFiles = [];
  List<int> downloadedIndex = [];
  ScrollController leftScrollController = ScrollController();
  ScrollController rightScrollController = ScrollController();
  int totalChecked = 0;
  int totalFilesToCheck = 0;
  Signal<String> gameDataCheckStatus = Signal('');

  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            title: Text(appText.gameDataIntegrityCheck),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: fileScanProgress == FileScanProgress.waiting
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CardOverlay(
                        paddingValue: 5,
                        child: Column(
                          spacing: 10,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(appText.selectAScanType, style: Theme.of(context).textTheme.titleSmall),
                            AnimatedHorizontalToggleLayout(
                              taps: [appText.all, 'win32', 'win32reboot', appText.appliedFilesOnly],
                              initialIndex: fileScanType == FileScanType.all
                                  ? 0
                                  : fileScanType == FileScanType.win32
                                      ? 1
                                      : fileScanType == FileScanType.win32reboot
                                          ? 2
                                          : 3,
                              width: 600,
                              onChange: (currentIndex, targetIndex) async {
                                targetIndex == 0
                                    ? fileScanType = FileScanType.all
                                    : targetIndex == 1
                                        ? fileScanType = FileScanType.win32
                                        : targetIndex == 2
                                            ? fileScanType = FileScanType.win32reboot
                                            : fileScanType = FileScanType.modifiedOnly;
                              },
                            ),
                          ],
                        )))
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        HoriDivider(),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Text(appText.checkedFiles, style: Theme.of(context).textTheme.headlineSmall),
                                    Expanded(
                                        child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), controller: leftScrollController, slivers: [
                                      SuperSliverList.separated(
                                        itemCount: checkedFiles.length,
                                        itemBuilder: (context, index) {
                                          return CardOverlay(
                                              paddingValue: 0,
                                              child: ListTile(
                                                  title: Text(
                                                    p.withoutExtension(checkedFiles[index].path),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  subtitle: Text(
                                                    checkedFiles[index].md5,
                                                    overflow: TextOverflow.ellipsis,
                                                  )));
                                        },
                                        separatorBuilder: (BuildContext context, int index) {
                                          return SizedBox(height: 2.5);
                                        },
                                      )
                                    ])),
                                  ],
                                ),
                              ),
                              VerticalDivider(),
                              Expanded(
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Text(
                                      appText.unmatchedMissingFiles,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    Expanded(
                                        child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), controller: rightScrollController, slivers: [
                                      SuperSliverList.separated(
                                        itemCount: missingFiles.length,
                                        itemBuilder: (context, index) {
                                          return CardOverlay(
                                              paddingValue: 0,
                                              child: CheckboxListTile(
                                                title: Text(
                                                  p.withoutExtension(missingFiles[index].path),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                subtitle: Text(
                                                  missingFiles[index].md5,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                controlAffinity: ListTileControlAffinity.leading,
                                                value: downloadedIndex.contains(index),
                                                onChanged: (bool? value) {},
                                              ));
                                        },
                                        separatorBuilder: (BuildContext context, int index) {
                                          return SizedBox(height: 2.5);
                                        },
                                      )
                                    ]))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  CardOverlay(
                                    paddingValue: 0,
                                    child: LinearProgressIndicator(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      minHeight: 40,
                                      value: totalFilesToCheck > 0 ? totalChecked / totalFilesToCheck : 0.0,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Text('$totalChecked / ${appText.dText(appText.numFiles, totalFilesToCheck.toString())}')
                                ],
                              )),
                        ),
                        HoriDivider()
                      ],
                    ),
                  ),
            actionsPadding: EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              OutlinedButton(
                  onPressed: () async {
                    if (progStarted) {
                      !progPaused ? progPaused = true : progPaused = false;
                      setState(
                        () {},
                      );
                    }

                    final filesToScan = oItemData.where((e) => e.path.contains('data/')).toList();
                    totalFilesToCheck = filesToScan.length;
                    if (!progStarted && !progPaused || progStarted && !progPaused) {
                      progStarted = true;
                      for (var data in filesToScan.getRange(totalChecked, filesToScan.length)) {
                        totalChecked++;
                        final gameFilePath = File(pso2binDirPath + p.separator + p.withoutExtension(data.path));
                        if (gameFilePath.existsSync()) {
                          final fileHash = await gameFilePath.getMd5Hash();
                          checkedFiles.insert(0, data);
                          if (fileHash != data.md5.toLowerCase()) missingFiles.insert(0, data);
                        } else {
                          missingFiles.insert(0, data);
                        }
                        if (!progStarted || progPaused || totalChecked == 10000) {
                          break;
                        }
                        setState(
                          () {},
                        );
                      }
                      if (totalChecked == filesToScan.length) {
                        progStarted = false;
                        setState(
                          () {},
                        );
                      }
                      // Download
                      if (missingFiles.isNotEmpty) {
                        for (var data in missingFiles) {
                          int index = missingFiles.indexOf(data);
                          File? downloadedFile = await originalIceDownload(data.path, pso2binDirPath + p.separator + p.dirname(data.path), gameDataCheckStatus);
                          if (downloadedFile != null && !downloadedIndex.contains(index)) downloadedIndex.add(index);
                          setState(
                            () {},
                          );
                        }
                      }
                    }
                  },
                  child: Text(!progStarted || progPaused ? appText.start : appText.pause)),
              OutlinedButton(
                  onPressed: () {
                    if (progStarted) {
                      progStarted = false;
                      setState(
                        () {},
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(progStarted ? appText.cancel : appText.returns))
            ],
          );
        });
      });
}
