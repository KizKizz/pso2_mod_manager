import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_popup.dart';
import 'package:pso2_mod_manager/main_widgets/popup_list_tile.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/vertical_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> modViewPopup(context, Item item) async {
  Mod? selectedMod = item.mods.first;
  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          // Refresh
          if (modPopupStatus.watch(context) != modPopupStatus.peek()) {
            setState(
              () {},
            );
          }
          if (closeModSwapPopup.watch(context) == true) {
            closeModSwapPopup.value = false;
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
            insetPadding: const EdgeInsets.only(top: 25),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      spacing: 5,
                      children: [
                        ItemIconBox(item: item),
                        Text(
                          appText.categoryName(item.category),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: InfoBox(
                                info: appText.dText(item.mods.length > 1 ? appText.numMods : appText.numMod, item.mods.length.toString()),
                                borderHighlight: false,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: InfoBox(
                                info: appText.dText(appText.numCurrentlyApplied, item.getNumOfAppliedMods().toString()),
                                borderHighlight: item.applyStatus,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 5,
                          children: [
                            Expanded(child: OutlinedButton(onPressed: () => launchUrlString(item.location), child: Text(appText.openInFileExplorer))),
                            IconButton.outlined(visualDensity: VisualDensity.adaptivePlatformDensity, onPressed: () {}, icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent))
                          ],
                        ),
                        const HoriDivider(),
                        Expanded(
                            child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), slivers: [
                          SuperSliverList.builder(
                              itemCount: item.mods.length,
                              itemBuilder: (context, modIndex) {
                                Mod mod = item.mods[modIndex];
                                return PopupListTile(
                                  item: item,
                                  mod: mod,
                                  selectedMod: selectedMod,
                                  onSelectedMod: () {
                                    selectedMod = mod;
                                    setState(
                                      () {},
                                    );
                                  },
                                );
                              })
                        ]))
                      ],
                    ),
                  ),
                  const VertDivider(),
                  Expanded(
                    flex: 3,
                    child: selectedMod == null
                        ? Center(
                            child: Text(
                              appText.selectAMod,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          )
                        : CustomScrollView(
                            physics: const SuperRangeMaintainingScrollPhysics(),
                            slivers: [
                              SubmodGridLayout(
                                item: item,
                                mod: selectedMod!,
                                submods: selectedMod!.submods,
                                searchString: searchTextController.value.text,
                                modSetName: '',
                              )
                            ],
                          ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(appText.returns))
            ],
          );
        });
      });
}
