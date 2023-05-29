import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pso2_mod_manager/global_variables.dart';

Future<String> categoryGroupAdder(context) async {
  TextEditingController newCateGroupName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: const Text('New Category Group', style: TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newCateGroupName,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (moddedItemsList.where((element) => element.groupName == value).isNotEmpty) {
                        return 'Name already existed!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'New Category Group name',
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
                          borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(2),
                        )),
                    onChanged: (value) async {
                      setState(() {
                        nameFormKey.currentState!.validate();
                      });
                    },
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text('Return'),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: newCateGroupName.value.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newCateGroupName.text);
                              }
                            },
                      child: const Text('Add'))
                ]);
          }));
}
