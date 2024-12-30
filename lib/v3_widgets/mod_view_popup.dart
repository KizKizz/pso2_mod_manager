import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_grid_layout.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

void modViewPopup(context, Item item) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Mod? selectedMod = item.mods.first;
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha + 50),
            insetPadding: const EdgeInsets.all(5),
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
                          item.category,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        InfoBox(info: appText.dText(item.mods.length > 1 ? appText.numMods : appText.numMod, item.mods.length.toString())),
                        InfoBox(info: appText.dText(appText.numModsCurrentlyApplied, item.getNumOfAppliedMods().toString())),
                        const Divider(height: 15, thickness: 2),
                        Expanded(
                            child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), slivers: [
                          SuperSliverList.builder(
                              itemCount: item.mods.length,
                              itemBuilder: (context, modIndex) {
                                Mod mod = item.mods[modIndex];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  selected: selectedMod == mod ? true : false,
                                  title: Text(mod.modName),
                                  subtitle: Text(appText.dText(mod.submods.length > 1 ? appText.numVariants : appText.numVariant, mod.submods.length.toString())),
                                  onTap: () {
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
                  const VerticalDivider(width: 20, thickness: 2),
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
                            slivers: [SubmodGridLayout(submods: selectedMod!.submods, searchString: searchTextController.value.text)],
                          ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const Divider(height: 20, thickness: 2),
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
