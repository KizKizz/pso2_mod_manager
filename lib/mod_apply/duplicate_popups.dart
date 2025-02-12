import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:signals/signals_flutter.dart';

Future<(bool, List<ModFile>)> duplicateAppliedModPopup(context, Item dupItem, Mod dupMod, SubMod dupSubmod, SubMod applyingSubmod) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          List conflictingIceFileNames = applyingSubmod.getModFileNames();
          conflictingIceFileNames.retainWhere((e) => dupSubmod.getModFileNames().contains(e));

          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            title: Center(child: Text(appText.duplicatesInAppliedMods)),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: 400,
              height: 325,
              child: Column(
                spacing: 5,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(appText.dText(appText.duplicateAppliedInfo, applyingSubmod.submodName)),
                  const HoriDivider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Row(
                        spacing: 5,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              spacing: 5,
                              children: [
                                ItemIconBox(item: dupItem),
                                Text(dupItem.itemName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SubmodPreviewBox(imageFilePaths: dupSubmod.previewImages, videoFilePaths: dupSubmod.previewVideos, isNew: dupSubmod.isNew),
                          )
                        ],
                      ),
                      Text(dupSubmod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                      Visibility(visible: dupSubmod.submodName != dupSubmod.modName, child: Text(dupSubmod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                      // SingleChildScrollView(
                      //   physics: const SuperRangeMaintainingScrollPhysics(),
                      //   child: Column(
                      //     spacing: 5,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     mainAxisSize: MainAxisSize.max,
                      //     children: [Text(appText.conflictingFiles, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium), Text(conflictingIceFileNames.join('\n'))],
                      //   ),
                      // ),
                    ],
                  ),
                  const HoriDivider(),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: () {
                        List<ModFile> emptyList = [];
                        Navigator.of(context).pop((true, emptyList));
                      },
                      child: Text(appText.replaceTheEntireMod)),
                  OutlinedButton(
                      onPressed: () {
                        List<ModFile> conflictingFileList = dupSubmod.modFiles.where((e) => conflictingIceFileNames.contains(e.modFileName)).toList();
                        Navigator.of(context).pop((true, conflictingFileList));
                      },
                      child: Text(appText.replaceConflictingFilesOnly)),
                  OutlinedButton(
                      onPressed: () {
                        List<ModFile> emptyList = [];
                        Navigator.of(context).pop((false, emptyList));
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}

Future<bool> duplicateAqmInjectedFilesPopup(context, AqmInjectedItem aqmInjectedItem) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            title: Center(child: Text(appText.duplicateInAQMInjectedItems)),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(appText.dText(appText.duplicateAqmInjectInfo, aqmInjectedItem.getName())),
                const HoriDivider(),
                SizedBox(
                    width: 400,
                    child: ListTile(
                      minTileHeight: 90,
                      title: Row(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GenericItemIconBox(iconImagePaths: [aqmInjectedItem.iconImagePath], boxSize: const Size(140, 140), isNetwork: true),
                          Column(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                aqmInjectedItem.getName(),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Visibility(visible: aqmInjectedItem.isAqmReplaced!, child: InfoBox(info: appText.aqmInjected, borderHighlight: false)),
                                  Visibility(visible: aqmInjectedItem.isBoundingRemoved!, child: InfoBox(info: appText.boundingRemoved, borderHighlight: false))
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(spacing: 5, crossAxisAlignment: CrossAxisAlignment.start, children: aqmInjectedItem.getDetailsForAqmInject().map((e) => Text(e)).toList()),
                    )),
                const HoriDivider(),
              ],
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(appText.replace)),
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
