import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/sega_file_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

Future<void> checkGameFilesPopup(context) async {
  bool progStarted = false;
  bool progPaused = false;
  List<OfficialIceFile> checkedFiles = [];
  List<OfficialIceFile> missingFiles = [];
  ScrollController leftScrollController = ScrollController();
  ScrollController rightScrollController = ScrollController();
  int curDownloadingIndex = -1;
  int totalChecked = 0;

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
            title: Text(appText.checkGameFileIntegrity),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
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
                              Text(appText.passedFiles, style: Theme.of(context).textTheme.headlineSmall),
                              Expanded(
                                  child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), controller: leftScrollController, slivers: [
                                SuperSliverList.separated(
                                  itemCount: checkedFiles.length,
                                  itemBuilder: (context, index) {
                                    return CardOverlay(
                                        paddingValue: 0,
                                        child: CheckboxListTile(
                                          title: Text(
                                            p.withoutExtension(checkedFiles[index].path),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            checkedFiles[index].md5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          secondary: curDownloadingIndex == index
                                              ? SizedBox(
                                                  width: 200,
                                                  height: 25,
                                                  child: LinearProgressIndicator(),
                                                )
                                              : null,
                                          controlAffinity: ListTileControlAffinity.leading,
                                          value: checkedFiles.contains(oItemData[index]),
                                          onChanged: (bool? value) {},
                                        ));
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return SizedBox(height: 2.5);
                                  },
                                )
                              ])),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded),
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
                                          secondary: curDownloadingIndex == index
                                              ? SizedBox(
                                                  width: 200,
                                                  height: 25,
                                                  child: LinearProgressIndicator(),
                                                )
                                              : null,
                                          controlAffinity: ListTileControlAffinity.leading,
                                          value: false,
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
                                minHeight: 40,
                                value: totalChecked / oItemData.length,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            Text('$totalChecked / ${appText.dText(appText.numFiles, oItemData.length.toString())}')
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
                    if (!progStarted && !progPaused || progStarted && !progPaused) {
                      progStarted = true;
                      for (var data in oItemData.getRange(totalChecked, oItemData.length)) {
                        totalChecked++;
                        final gameFilePath = File(pso2binDirPath + p.separator + p.withoutExtension(data.path));
                        if (gameFilePath.existsSync()) {
                          final fileHash = await gameFilePath.getMd5Hash();
                          if (fileHash == data.md5.toLowerCase()) {
                            checkedFiles.insert(0, data);
                          } else {
                            missingFiles.insert(0, data);
                          }
                        } else {
                          missingFiles.insert(0, data);
                        }
                        if (!progStarted || progPaused) {
                          break;
                        }
                        setState(
                          () {},
                        );
                      }
                      if (totalChecked == oItemData.length) {
                        progStarted = false;
                        setState(
                          () {},
                        );
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
