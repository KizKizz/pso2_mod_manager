import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_class.dart';
import 'package:pso2_mod_manager/mod_sets/mod_set_functions.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

Future<List<ModSet>> modsToSetPopup(context) async {
  List<ModSet> modsetsToAdd = [];

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
                appText.addToSets,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Column(
                  spacing: 10,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SuperListView.builder(
                        physics: const SuperRangeMaintainingScrollPhysics(),
                        itemCount: masterModSetList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return CheckboxListTile(
                            value: modsetsToAdd.contains(masterModSetList[index]),
                            title: Text(masterModSetList[index].setName),
                            subtitle: Row(
                              spacing: 5,
                              mainAxisSize: MainAxisSize.min,
                              children: [Text(appText.dText(masterModSetList[index].setItems.length > 1 ? appText.numItems : appText.numItem, masterModSetList[index].setItems.length.toString()))],
                            ),
                            onChanged: (value) {
                              if (modsetsToAdd.contains(masterModSetList[index])) {
                                modsetsToAdd.remove(masterModSetList[index]);
                              } else {
                                modsetsToAdd.add(masterModSetList[index]);
                              }
                              setState(
                                () {},
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                )),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OverflowBar(spacing: 5, overflowSpacing: 5, children: [
                    OutlinedButton(
                        onPressed: () {
                          modsetsToAdd.clear();
                          setState(
                            () {},
                          );
                        },
                        child: Text(appText.reset)),
                    OutlinedButton(
                        onPressed: () async {
                          await newModSetCreate(context);
                          setState(() {});
                        },
                        child: Text(appText.addNewSet)),
                  ]),
                  OverflowBar(
                    spacing: 5,
                    overflowSpacing: 5,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(modsetsToAdd);
                          },
                          child: Text(appText.apply)),
                      OutlinedButton(
                          onPressed: () {
                            modsetsToAdd.clear();
                            Navigator.of(context).pop(modsetsToAdd);
                          },
                          child: Text(appText.returns))
                    ],
                  )
                ],
              )
            ],
          );
        });
      });
}
