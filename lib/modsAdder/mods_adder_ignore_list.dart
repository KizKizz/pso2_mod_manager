import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> modAdderIgnoreListPopup(context) async {
  TextEditingController filterTextController = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  File ignoreList = File(modManAddModsIgnoreListPath);
  if (ignoreList.existsSync()) {
    filterTextController.text = ignoreList.readAsStringSync();
  }
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiIgnoreList, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.uiSeparateEachParamByAComma, style: const TextStyle(fontSize: 15))),
                    Form(
                      key: nameFormKey,
                      child: TextFormField(
                        controller: filterTextController,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                        // validator: (value) {
                        //   if (moddedItemsList.where((element) => element.groupName == value).isNotEmpty) {
                        //     return curLangText!.uiNameAlreadyExisted;
                        //   }
                        //   return null;
                        // },
                        decoration: InputDecoration(
                            labelText: curLangText!.uiIgnoreFoldersThatContain,
                            hintText: '${curLangText!.uiHint}: ori, _ori, backup',
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
                  ],
                ),
                actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(modAdderIgnoreListState ? '${curLangText!.uiCurrentState}: ${curLangText!.uiON}' : '${curLangText!.uiCurrentState}: ${curLangText!.uiOFF}'),
                      onPressed: () async {
                        if (modAdderIgnoreListState) {
                          modAdderIgnoreListState = false;
                        } else {
                          modAdderIgnoreListState = true;
                        }
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setBool('modAdderIgnoreList', modAdderIgnoreListState);
                        setState(
                          () {},
                        );
                      }),
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: filterTextController.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                ignoreList.writeAsStringSync(filterTextController.text);
                                Navigator.pop(context);
                              }
                            },
                      child: Text(curLangText!.uiSave))
                ]);
          }));
}

Future<List<String>> ignoreParamsGet() async {
  List<String> returnList = [];
  String ignoreWordList = await File(modManAddModsIgnoreListPath).readAsString();
  for (var word in ignoreWordList.split(',')) {
    returnList.add(word.trim());
  }
  return returnList;
}
