import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:pso2_mod_manager/v3_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/v3_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/vertical_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

void submodViewPopup(context, Item item, Mod mod) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Mod? selectedMod = mod;
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
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
                          appText.categoryName(item.category),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          item.itemName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        InfoBox(info: appText.dText(item.mods.length > 1 ? appText.numMods : appText.numMod, item.mods.length.toString())),
                        InfoBox(info: appText.dText(appText.numCurrentlyApplied, mod.getNumOfAppliedSubmods().toString())),
                        const HoriDivider(),
                        Expanded(
                            child: CustomScrollView(physics: const SuperRangeMaintainingScrollPhysics(), slivers: [
                          SuperSliverList.builder(
                              itemCount: 1,
                              itemBuilder: (context, modIndex) {
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
                            slivers: [SubmodGridLayout(submods: selectedMod!.submods, searchString: searchTextController.value.text)],
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
