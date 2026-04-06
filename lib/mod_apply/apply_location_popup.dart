import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

enum ApplyLocation {
  win32('win32'),
  win32Reboot('win32reboot'),
  win32NA('win32_na'),
  win32reboootNA('win32reboot_na');

  final String value;
  const ApplyLocation(this.value);
}

Future<List<String>> modApplyLocationPopup(context, SubMod submod) async {
  List<String> selectedLocations = submod.applyLocations!;
  final locations = ['win32', 'win32reboot', 'win32_na', 'win32reboot_na'];
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
            insetPadding: const EdgeInsets.all(5),
            titlePadding: const EdgeInsets.only(top: 5),
            title: Column(children: [
              Text(
                appText.applyLocations,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: locations
                      .map((e) => CheckboxListTile(
                            title: Text(e),
                            value: selectedLocations.contains(e) ? true : false,
                            onChanged: (value) {
                              if (value!) {
                                selectedLocations.add(e);
                              } else {
                                selectedLocations.remove(e);
                              }
                              setState(
                                () {},
                              );
                            },
                          ))
                      .toList(),
                ),
                const Divider(height: 5, thickness: 1.5, endIndent: 5, indent: 5,),
                CheckboxListTile(
                  title: Text(appText.applyToAllLocations),
                  value: selectedLocations.isEmpty ? true : false,
                  onChanged: (value) {
                    if (value!) {
                      selectedLocations.clear();
                    }
                    setState(
                      () {},
                    );
                  },
                )
              ],
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
                        Navigator.of(context).pop(selectedLocations);
                      },
                      child: Text(appText.saveAndReturn)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(selectedLocations);
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
