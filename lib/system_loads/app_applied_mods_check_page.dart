import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/material_app_service.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_file_class.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_preview_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class AppAppliedModsLoadPage extends StatefulWidget {
  const AppAppliedModsLoadPage({super.key});

  @override
  State<AppAppliedModsLoadPage> createState() => _AppAppliedModsLoadPageState();
}

class _AppAppliedModsLoadPageState extends State<AppAppliedModsLoadPage> {
  @override
  Widget build(BuildContext context) {
    if (masterUnappliedItemList.isEmpty) {
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
                      appText.restoredMods,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const Divider(
                    height: 0,
                    thickness: 1.5,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Text(appText.restoredModInfo),
                  Expanded(
                      child: ResponsiveGridList(
                    minItemWidth: 320,
                    children: unappliedItemsGet(masterUnappliedItemList),
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
                            for (var item in masterUnappliedItemList) {
                              for (var mod in item.mods.where((e) => e.getSubmodsAppliedState())) {
                                for (var submod in mod.submods.where((e) => e.getModFilesAppliedState())) {
                                  List<ModFile> unappliedModFiles = submod.modFiles.where((e) => e.applyStatus && e.ogMd5s.isNotEmpty && e.ogMd5s.first != e.md5).toList();
                                  if (unappliedModFiles.isNotEmpty) {
                                    await applyingPopup(MaterialAppService.navigatorKey.currentContext, true, item, mod, submod, unappliedModFiles);
                                  }
                                }
                              }
                            }
                            masterAppliedModList.clear();
                            saveMasterModListToJson();
                            pageIndex++;
                            curPage.value = appPages[pageIndex];
                          },
                          child: Text(appText.reApplyAll)),
                      OutlinedButton(
                          onPressed: () async {
                            for (var item in masterUnappliedItemList) {
                              for (var mod in item.mods.where((e) => e.getSubmodsAppliedState())) {
                                for (var submod in mod.submods.where((e) => e.getModFilesAppliedState())) {
                                  if (submod.modFiles.indexWhere((e) => e.applyStatus && e.ogMd5s.isNotEmpty && e.ogMd5s.first != e.md5) != -1) {
                                    await applyingPopup(MaterialAppService.navigatorKey.currentContext, false, item, mod, submod, []);
                                  }
                                }
                              }
                            }
                            masterUnappliedItemList.clear();
                            pageIndex++;
                            curPage.value = appPages[pageIndex];
                          },
                          child: Text(appText.removeAll)),
                      OutlinedButton(
                          onPressed: () {
                            masterUnappliedItemList.clear();
                            saveMasterModListToJson();
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

  List<Widget> unappliedItemsGet(List<Item> items) {
    List<Widget> widgets = [];
    for (var item in items) {
      for (var mod in item.mods.where((e) => e.applyStatus)) {
        for (var submod in mod.submods.where((e) => e.applyStatus)) {
          if (submod.modFiles.indexWhere((e) => e.applyStatus && e.ogMd5s.isNotEmpty && e.ogMd5s.first != e.md5) != -1) {
            widgets.add(
              CardOverlay(
                paddingValue: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                              ItemIconBox(item: item, showSubCategory: true,),
                              Text(item.getDisplayName(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: SubmodPreviewBox(imageFilePaths: submod.previewImages, videoFilePaths: submod.previewVideos, isNew: submod.isNew),
                        )
                      ],
                    ),
                    Text(mod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                    Visibility(visible: mod.modName != submod.submodName, child: Text(submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                  ],
                ),
              ),
            );
          }
        }
      }
    }

    return widgets;
  }
}
