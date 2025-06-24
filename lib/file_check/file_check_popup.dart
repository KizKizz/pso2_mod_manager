import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_functions/original_ice_download.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

enum FileScanType { all, win32, win32reboot, modifiedOnly }

enum FileScanProgress { waiting, idle, started, paused }

Future<void> checkGameFilesPopup(context, bool checkAll) async {
  FileScanType fileScanType = checkAll ? FileScanType.all : FileScanType.modifiedOnly;
  FileScanProgress fileScanProgress = FileScanProgress.waiting;
  List<OfficialIceFile> checkedFiles = [];
  List<OfficialIceFile> missingFiles = [];
  List<int> downloadedIndex = [];
  ScrollController leftScrollController = ScrollController();
  ScrollController rightScrollController = ScrollController();
  int totalChecked = 0;
  int totalFilesToCheck = 0;
  bool refresh = false;
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
                              taps: [appText.all, appText.appliedFilesOnly, 'win32', 'win32reboot'],
                              initialIndex: checkAll ? 0 : 1,
                              width: 600,
                              onChange: (currentIndex, targetIndex) async {
                                targetIndex == 0
                                    ? fileScanType = FileScanType.all
                                    : targetIndex == 1
                                        ? fileScanType = FileScanType.modifiedOnly
                                        : targetIndex == 2
                                            ? fileScanType = FileScanType.win32
                                            : fileScanType = FileScanType.win32reboot;
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
                                    Row(
                                      spacing: 5,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Visibility(
                                            visible: missingFiles.isNotEmpty,
                                            child: Text(
                                              missingFiles.length.toString(),
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            )),
                                        Text(
                                          appText.unmatchedMissingFiles,
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                      ],
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
                                  Visibility(visible: gameDataCheckStatus.watch(context).isEmpty, child: Text('$totalChecked / ${appText.dText(appText.numFiles, totalFilesToCheck.toString())}')),
                                  Visibility(visible: gameDataCheckStatus.watch(context).isNotEmpty, child: Text(gameDataCheckStatus.watch(context)))
                                ],
                              )),
                        ),
                        HoriDivider()
                      ],
                    ),
                  ),
            actionsPadding: EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              Visibility(
                visible: !refresh && totalChecked < totalFilesToCheck || fileScanProgress == FileScanProgress.waiting,
                child: OutlinedButton(
                    onPressed: () async {
                      if (fileScanProgress == FileScanProgress.waiting || fileScanProgress == FileScanProgress.paused) {
                        fileScanProgress = FileScanProgress.idle;
                        setState(
                          () {},
                        );
                      }
                      if (fileScanProgress == FileScanProgress.started) {
                        fileScanProgress = FileScanProgress.paused;
                        setState(
                          () {},
                        );
                      }

                      final filesToScan = fileScanType == FileScanType.win32
                          ? oItemData.where((e) => e.path.contains('data/win32/')).toList()
                          : fileScanType == FileScanType.win32reboot
                              ? oItemData.where((e) => e.path.contains('data/win32reboot/')).toList()
                              : fileScanType == FileScanType.modifiedOnly
                                  ? oItemData.where((e) => modifiedIceList.contains(p.basenameWithoutExtension(e.path))).toList()
                                  : oItemData.where((e) => e.path.contains('data/')).toList();
                      totalFilesToCheck = filesToScan.length;
                      if (fileScanProgress == FileScanProgress.idle) {
                        fileScanProgress = FileScanProgress.started;
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
                          if (fileScanProgress == FileScanProgress.paused || fileScanProgress == FileScanProgress.idle || totalChecked == 10000) {
                            break;
                          }
                          if (context.mounted) setState(() {});
                        }
                        if (totalChecked == filesToScan.length) {
                          fileScanProgress = FileScanProgress.idle;
                          setState(
                            () {},
                          );
                        }
                        // Download Files
                        if (missingFiles.isNotEmpty) {
                          for (var data in missingFiles) {
                            if (context.mounted) {
                              int index = missingFiles.indexOf(data);
                              File? downloadedFile = await originalIceDownload(data.path, pso2binDirPath + p.separator + p.dirname(data.path), gameDataCheckStatus);
                              if (downloadedFile != null && !downloadedIndex.contains(index)) {
                                downloadedIndex.add(index);
                                setState(
                                  () {},
                                );
                              }
                            }
                          }
                          // Refresh Mod Manager
                          gameDataCheckStatus.value = '';
                          await checksumToGameData();
                          refresh = true;
                        }
                      }
                      if (context.mounted) setState(() {});
                    },
                    child: Text(fileScanProgress == FileScanProgress.started
                        ? appText.pause
                        : fileScanProgress == FileScanProgress.paused
                            ? appText.resume
                            : appText.start)),
              ),
              OutlinedButton(
                  onPressed: () async {
                    if (fileScanProgress == FileScanProgress.paused) {
                      fileScanProgress = FileScanProgress.idle;
                      setState(
                        () {},
                      );
                    } else if (refresh) {
                      Navigator.of(context).pop();
                      await Future.delayed(Duration(milliseconds: 50));
                      selectedItemV2.value = null;
                      pageIndex = 6;
                      curPage.value = appPages[pageIndex];
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(fileScanProgress == FileScanProgress.paused
                      ? appText.cancel
                      : refresh
                          ? appText.refreshModManager
                          : appText.returns))
            ],
          );
        });
      });
}
