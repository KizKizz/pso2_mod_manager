import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';

Future<int?> popupDismissedDelayPopup(context) async {
  var focusNode = FocusNode();
  TextEditingController newDelay = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  focusNode.requestFocus();
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
                'Mods Apply Delay',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: Column(
              spacing: 15,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current value: ${popupAfterDismissWaitDelayMilli.toString()} milliseconds',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newDelay,
                    focusNode: focusNode,
                    maxLines: 1,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (value!.isEmpty) return 'Cannot be empty';
                      if (int.tryParse(value) == null) return 'Numbers only';
                      if (int.parse(value) < 0) return 'Positive numbers only';

                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Enter new delay in milliseconds',
                        suffix: MaterialButton(
                          minWidth: 20,
                          onPressed: (() {
                            newDelay.clear();
                            setState(
                              () {},
                            );
                          }),
                          child: const Icon(
                            Icons.clear,
                            size: 18,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        //isCollapsed: true,
                        //isDense: true,
                        contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                        constraints: const BoxConstraints.tightForFinite(),
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(5),
                        )),
                    onChanged: (value) async {
                      nameFormKey.currentState!.validate();
                      setState(() {});
                    },
                  ),
                ),
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
                      onPressed: () {
                        Navigator.of(context).pop(50);
                      },
                      child: Text(appText.reset)),
                  OutlinedButton(
                      onPressed: newDelay.value.text.isNotEmpty
                          ? () {
                              Navigator.of(context).pop(int.parse(newDelay.value.text));
                            }
                          : null,
                      child: Text(appText.saveAndReturn)),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(null);
                      },
                      child: Text(appText.returns))
                ],
              )
            ],
          );
        });
      });
}
