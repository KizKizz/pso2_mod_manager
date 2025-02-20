import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/v3_widgets/horizintal_divider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:path/path.dart' as p;

Future<String?> renamePopup(context, String parentDirPath, String currentName) async {
  var focusNode = FocusNode();
  TextEditingController newName = TextEditingController();
  newName.text = currentName;
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
                appText.rename,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              const HoriDivider()
            ]),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: Form(
              key: nameFormKey,
              child: TextFormField(
                controller: newName,
                focusNode: focusNode,
                maxLines: 1,
                maxLength: 256 - parentDirPath.length,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                textAlignVertical: TextAlignVertical.center,
                inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                validator: (value) {
                  if (Directory(parentDirPath).listSync().indexWhere((element) => p.basenameWithoutExtension(element.path).toLowerCase() == newName.text.toLowerCase()) != -1) {
                    return appText.nameAlreadyExists;
                  }
                  if (newName.value.text.isEmpty) return appText.nameCannotBeEmpty;
                  return null;
                },
                decoration: InputDecoration(
                    labelText: appText.dText(appText.changeTextTo, currentName),
                    hintText: currentName,
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
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              const HoriDivider(),
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: newName.value.text.isNotEmpty && newName.value.text != currentName
                          ? () {
                              Navigator.of(context).pop(newName.value.text);
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
