import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/mod_apply/applying_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_apply/load_applied_mods.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/future_builder_states.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_image_box.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

Signal<String> modsetLoadingStatus = Signal('');

class AppAppliedModsLoadPage extends StatefulWidget {
  const AppAppliedModsLoadPage({super.key});

  @override
  State<AppAppliedModsLoadPage> createState() => _AppAppliedModsLoadPageState();
}

class _AppAppliedModsLoadPageState extends State<AppAppliedModsLoadPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: appliedModsCheck(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
              child: Column(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardOverlay(
                paddingValue: 15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.primary,
                      size: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        appText.checkingAppliedMods,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ));
        } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
          return FutureBuilderError(loadingText: appText.checkingAppliedMods, snapshotError: snapshot.error.toString());
        } else {
          List<Item> unappliedItemList = snapshot.data;
          if (unappliedItemList.isEmpty) {
            pageIndex++;
            curPage.value = appPages[pageIndex];
            return const SizedBox();
          } else {
            return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
              insetPadding: const EdgeInsets.all(5),
              titlePadding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              title: Center(
                child: Text(
                  appText.restoredMods,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              contentPadding: const EdgeInsets.only(top: 00, bottom: 0, left: 10, right: 10),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Text(appText.restoredModInfo),
                  const HoriDivider(),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height - 183,
                      child: ResponsiveGridList(
                        minItemWidth: 320,
                        children: unappliedItemsGet(unappliedItemList),
                      )),
                ],
              ),
              actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
              actions: [
                OverflowBar(
                  spacing: 5,
                  overflowSpacing: 5,
                  children: [
                    OutlinedButton(
                        onPressed: () async {
                          for (var item in unappliedItemList) {
                            for (var mod in item.mods.where((e) => e.applyStatus)) {
                              for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                if (submod.modFiles.indexWhere((e) => e.ogMd5s.first.isNotEmpty && e.ogMd5s.first != e.md5) != -1) {
                                  await applyingPopup(context, true, item, mod, submod);
                                }
                              }
                            }
                          }
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.reApplyAll)),
                    OutlinedButton(
                        onPressed: () async {
                          for (var item in unappliedItemList) {
                            for (var mod in item.mods.where((e) => e.applyStatus)) {
                              for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                if (submod.modFiles.indexWhere((e) => e.ogMd5s.first.isNotEmpty && e.ogMd5s.first != e.md5) != -1) {
                                  await applyingPopup(context, false, item, mod, submod);
                                }
                              }
                            }
                          }
                          pageIndex++;
                          curPage.value = appPages[pageIndex];
                        },
                        child: Text(appText.removeAll))
                  ],
                )
              ],
            );
          }
        }
      },
    );
  }

  List<Widget> unappliedItemsGet(List<Item> items) {
    List<Widget> widgets = [];
    for (var item in items) {
      for (var mod in item.mods.where((e) => e.applyStatus)) {
        for (var submod in mod.submods.where((e) => e.applyStatus)) {
          if (submod.modFiles.indexWhere((e) => e.ogMd5s.first.isNotEmpty && e.ogMd5s.first != e.md5) != -1) {
            widgets.add(
              Column(
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
                            ItemIconBox(item: item),
                            Text(item.itemName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SubmodImageBox(filePaths: submod.previewImages, isNew: submod.isNew),
                      )
                    ],
                  ),
                  Text(mod.modName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge),
                  Visibility(visible: mod.modName != submod.submodName, child: Text(submod.submodName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelLarge)),
                ],
              ),
            );
          }
        }
      }
    }

    return widgets;
  }
}
