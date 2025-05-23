// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_inject_popup.dart';
import 'package:pso2_mod_manager/item_aqm_inject/aqm_injected_item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/mod_apply/item_icon_mark.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:path/path.dart' as p;

class AppAqmItemsCheckPage extends StatefulWidget {
  const AppAqmItemsCheckPage({super.key});

  @override
  State<AppAqmItemsCheckPage> createState() => _AppAqmItemsCheckPageState();
}

class _AppAqmItemsCheckPageState extends State<AppAqmItemsCheckPage> {
  @override
  Widget build(BuildContext context) {
    if (masterUnappliedAQMItemList.isEmpty) {
      saveMasterModListToJson();
      pageIndex++;
      curPage.value = appPages[pageIndex];
      return const SizedBox();
    } else {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: CardOverlay(
              paddingValue: 10,
              child: Column(
                spacing: 10,
                children: [
                  Center(
                    child: Text(
                      appText.restoredAQMInjectedItems,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    thickness: 1.5,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Text(appText.restoredAQMInjectedItemInfo),
                  Expanded(
                      child: ResponsiveGridList(
                    minItemWidth: 320,
                    children: unappliedItemsGet(masterUnappliedAQMItemList),
                  )),
                  const Divider(
                    height: 0,
                    thickness: 1.5,
                    indent: 10,
                    endIndent: 10,
                  ),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    alignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                          onPressed: () async {
                            for (var item in masterUnappliedAQMItemList) {
                              bool aqmResult = false;
                              bool boundingResult = false;
                              if (item.isApplied && item.isAqmReplaced!) {
                                aqmResult = await aqmInjectPopup(context, item.injectedAQMFilePath!, item.hqIcePath, item.lqIcePath, item.getName(), false, false, false, false, false);
                              }
                              if (item.isApplied && item.isBoundingRemoved!) {
                                boundingResult = await itemCustomAqmBounding(context, item.hqIcePath, item.lqIcePath, item.getName());
                              }
                              if (aqmResult || boundingResult) {
                                item.injectedHqIceMd5 = await File(pso2binDirPath + p.separator + item.hqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                item.injectedLqIceMd5 = await File(pso2binDirPath + p.separator + item.lqIcePath.replaceAll('/', p.separator)).getMd5Hash();
                                if (replaceItemIconOnApplied) {
                                  item.isIconReplaced = await markedAqmItemIconApply(item.iconIcePath);
                                }
                                item.isAqmReplaced = aqmResult;
                                item.isBoundingRemoved = boundingResult;
                                item.isApplied = true;
                              }
                            }
                            saveMasterAqmInjectListToJson();
                            masterUnappliedAQMItemList.clear();
                            pageIndex++;
                            curPage.value = appPages[pageIndex];
                          },
                          child: Text(appText.reApplyAll)),
                      OutlinedButton(
                          onPressed: () async {
                            for (var item in masterUnappliedAQMItemList) {
                              bool result = await aqmInjectPopup(context, item.injectedAQMFilePath!, item.hqIcePath, item.lqIcePath, item.getName(), false, false, true, item.isAqmReplaced!, false);
                              if (result) {
                                if (item.isIconReplaced) {
                                  await markedAqmItemIconRestore(pso2binDirPath + p.separator + item.iconIcePath);
                                }
                                masterAqmInjectedItemList.remove(item);
                              }
                            }
                            saveMasterAqmInjectListToJson();
                            masterUnappliedAQMItemList.clear();
                            pageIndex++;
                            curPage.value = appPages[pageIndex];
                          },
                          child: Text(appText.removeAll)),
                      OutlinedButton(
                          onPressed: () {
                            masterUnappliedAQMItemList.clear();
                            pageIndex++;
                            curPage.value = appPages[pageIndex];
                          },
                          child: Text(appText.skip)),
                    ],
                  )
                ],
              )),
        ),
      );
    }
  }

  List<Widget> unappliedItemsGet(List<AqmInjectedItem> items) {
    List<Widget> widgets = [];
    for (var item in items) {
      widgets.add(
        CardOverlay(
          paddingValue: 10,
          child: Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GenericItemIconBox(iconImagePaths: [item.iconImagePath], boxSize: const Size(80, 80), isNetwork: true),
              Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.getName(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Visibility(visible: item.isAqmReplaced!, child: InfoBox(info: appText.aqmInjected, borderHighlight: false)),
                      Visibility(visible: item.isBoundingRemoved!, child: InfoBox(info: appText.boundingRemoved, borderHighlight: false))
                    ],
                  ),
                  Visibility(visible: item.isAqmReplaced!, child: Text(appText.dText(appText.injectedAQMFile, p.basename(item.injectedAQMFilePath!)), style: Theme.of(context).textTheme.labelMedium))
                ],
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
