import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/animated_hori_toggle_layout.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<void> modAddFilterPopup(context) async {
  var focusNode = FocusNode();
  TextEditingController newName = TextEditingController();
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
                appText.filters,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            content: SingleChildScrollView(
              child: Column(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appText.currentFilters,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: modAddFilterList
                        .map((e) => OutlinedButton(
                              onLongPress: () {
                                modAddFilterList.remove(e);
                                setState(
                                  () {},
                                );
                              },
                              child: Text(e),
                              onPressed: () {},
                            ))
                        .toList(),
                  ),
                  Visibility(visible: modAddFilterList.isNotEmpty, child: Text(appText.filterRemoveInfo)),
                  const HoriDivider(),
                  Form(
                    key: nameFormKey,
                    child: TextFormField(
                      controller: newName,
                      focusNode: focusNode,
                      maxLines: 1,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                      validator: (value) {
                        if (modAddFilterList.indexWhere((element) => p.basenameWithoutExtension(element) == newName.text) != -1) {
                          return appText.nameAlreadyExists;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: appText.enterFilterText,
                          suffix: MaterialButton(
                            minWidth: 20,
                            onPressed: (() {
                              newName.clear();
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
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  AnimatedHorizontalToggleLayout(
                    taps: [appText.on, appText.off],
                    initialIndex: enableModAddFilters ? 0 : 1,
                    width: 200,
                    onChange: (currentIndex, targetIndex) async {
                      final prefs = await SharedPreferences.getInstance();
                      targetIndex == 0 ? enableModAddFilters = true : enableModAddFilters = false;
                      prefs.setBool('enableModAddFilters', enableModAddFilters);
                    },
                  ),
                  OutlinedButton(
                      onPressed: newName.value.text.isNotEmpty
                          ? () async {
                              if (nameFormKey.currentState!.validate()) {
                                modAddFilterList.add(newName.text);
                                await File(modAddFilterListFilePath).writeAsString(modAddFilterList.join(', '));
                                setState(
                                  () {},
                                );
                              }
                            }
                          : null,
                      child: Text(appText.add)),
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
