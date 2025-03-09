import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/popup_item_info.dart';
import 'package:pso2_mod_manager/main_widgets/popup_list_tile.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Future<void> submodViewPopup(context, Item item, Mod mod) async {
  Mod? selectedMod = mod;
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
         
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  mouseCursor: MouseCursor.defer,
                  onSecondaryTap: () => Navigator.of(context).pop(),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                spacing: 5,
                                children: [
                                  PopupItemInfo(item: item, showModInfo: false),
                                  const HoriDivider(),
                                  Expanded(
                                      child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), slivers: [
                                    SuperSliverList.builder(
                                        itemCount: 1,
                                        itemBuilder: (context, modIndex) {
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
                                            onDelete: () async {
                                              await modDelete(context, item, mod);
                                              modPopupStatus.value = '${mod.modName} deleted';
                                              selectedMod = null;
                                              item.isNew = item.getModsIsNewState();
                                              // if (item.mods.isEmpty) {
                                              mainGridStatus.value = '"${mod.modName}" in "${item.getDisplayName()}" is empty and removed';
                                              // ignore: use_build_context_synchronously
                                              Navigator.of(context).pop();
                                              // }
                                            },
                                          );
                                        })
                                  ]))
                                ],
                              ),
                            ),
                            const VerticalDivider(
                              width: 10,
                              thickness: 2,
                              endIndent: 5,
                              indent: 5,
                            ),
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
                                          submods: selectedMod!.submods,
                                          // searchString: searchTextController.value.text,
                                          searchString: '',
                                          item: item,
                                          mod: selectedMod!,
                                          modSetName: '', isPopup: true,
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const HoriDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(appText.returns))],
                      )
                    ],
                  )),
            ),
          );
        });
      });
}
