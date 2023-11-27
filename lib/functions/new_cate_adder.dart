import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';

import '../state_provider.dart';

Future<String> categoryGroupAdder(context) async {
  TextEditingController newCateGroupName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiNewCateGroup, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: nameFormKey,
                      child: TextFormField(
                        controller: newCateGroupName,
                        maxLines: 1,
                        textAlignVertical: TextAlignVertical.center,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                        validator: (value) {
                          if (moddedItemsList.where((element) => element.groupName == value).isNotEmpty) {
                            return curLangText!.uiNameAlreadyExisted;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: curLangText!.uiNewCateGroupName,
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
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: newCateGroupName.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newCateGroupName.text);
                              }
                            },
                      child: Text(curLangText!.uiAdd))
                ]);
          }));
}

Future<String> categoryAdder(context) async {
  TextEditingController newCateName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiNewCate, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newCateName,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (moddedItemsList.where((group) => group.categories.where((element) => element.categoryName.contains(value!)).isNotEmpty).isNotEmpty) {
                        return curLangText!.uiNameAlreadyExisted;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: curLangText!.uiNewCateName,
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
                      child: Text(curLangText!.uiReturn),
                      onPressed: () async {
                        Navigator.pop(context, '');
                      }),
                  ElevatedButton(
                      onPressed: newCateName.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newCateName.text);
                              }
                            },
                      child: Text(curLangText!.uiAdd))
                ]);
          }));
}

void categoryGroupRemover(context, CategoryType cateTypeToDel) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiRemovingCateGroup, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Text(cateTypeToDel.categories.length < 2
                    ? curLangText!.uiCateFoundWhenDeletingGroup
                    : '${curLangText!.uiThereAre} ${cateTypeToDel.categories.length} ${curLangText!.uiCatesFoundWhenDeletingGroup}'),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      child: Text(curLangText!.uiMoveEverythingToOthers),
                      onPressed: () {
                        modViewItem = null;
                        //copy to Others
                        for (var cate in cateTypeToDel.categories) {
                          int othersTypeIndex = moddedItemsList.indexWhere((element) => element.groupName == 'Others');
                          if (moddedItemsList[othersTypeIndex].categories.where((element) => element.categoryName == cate.categoryName).isEmpty) {
                            moddedItemsList[othersTypeIndex].categories.add(cate);
                          }
                        }
                        //Delete group
                        moddedItemsList.remove(cateTypeToDel);
                        for (var cateType in moddedItemsList) {
                          cateType.position = moddedItemsList.indexOf(cateType);
                        }
                        saveModdedItemListToJson();
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: () {
                        modViewItem = null;
                        moddedItemsList.remove(cateTypeToDel);
                        for (var cateType in moddedItemsList) {
                          cateType.position = moddedItemsList.indexOf(cateType);
                        }
                        saveModdedItemListToJson();
                        Navigator.pop(context);
                      },
                      child: Text(curLangText!.uiNoDeleteAll))
                ]);
          }));
}

void categoryRemover(context, CategoryType cateTypeToDel, Category cateToDel) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiRemovingCate, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content:
                    Text(cateToDel.items.length < 2 ? curLangText!.uiItemFoundWhenDeletingCate : '${curLangText!.uiThereAre} ${cateToDel.items.length} ${curLangText!.uiItemsFoundWhenDeletingCate}'),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      onPressed: () {
                        modViewItem = null;
                        Directory(cateToDel.location).deleteSync(recursive: true);
                        cateTypeToDel.categories.remove(cateToDel);
                        for (var cate in cateTypeToDel.categories) {
                          cate.position = cateTypeToDel.categories.indexOf(cate);
                        }
                        saveModdedItemListToJson();
                        Navigator.pop(context);
                      },
                      child: Text(curLangText!.uiSure))
                ]);
          }));
}
