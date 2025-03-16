import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

Future<void> modConfigsRestorePopup(context, String latestBackupDate, List<File> configBackups) async {
  File selectedFile = configBackups.first;

  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5),
            title: Column(children: [
              Text(
                appText.modConfigsRestore,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: 450,
              // height: 350,
              child: Column(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appText.dText(appText.latestBackup, latestBackupDate), style: Theme.of(context).textTheme.titleSmall),
                  Flexible(
                    child: CardOverlay(
                      paddingValue: 5,
                      child: SuperListView.builder(
                        shrinkWrap: true,
                        itemCount: configBackups.length,
                        itemBuilder: (context, index) => RadioListTile(
                          value: configBackups[index],
                          groupValue: selectedFile,
                          title: Text(p.basenameWithoutExtension(configBackups[index].path)),
                          onChanged: (value) {
                            selectedFile = configBackups[index];
                            setState(
                              () {},
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await extractFileToDisk(selectedFile.path, mainDataDirPath);
                        selectedItemV2.value = null;
                        pageIndex = 6;
                        curPage.value = appPages[pageIndex];
                      },
                      child: Text(appText.restore)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
