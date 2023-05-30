import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
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

Future<String> categoryAdder(context) async {
  TextEditingController newCateName = TextEditingController();
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: const Text('New Category', style: TextStyle(fontWeight: FontWeight.w700)),
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
                        return 'Name already existed!';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'New Category name',
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
                      onPressed: newCateName.value.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newCateName.text);
                              }
                            },
                      child: const Text('Add'))
                ]);
          }));
}

void categoryGroupRemover(context, CategoryType cateTypeToDel) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: const Text('Removing Category Group', style: TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Text(cateTypeToDel.categories.length < 2
                    ? 'There is a Category in this group. Would you like to move it to Others Group?'
                    : 'There are ${cateTypeToDel.categories.length} Categories in this group. Would you like to move them to Others Group?'),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text('Return'),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  ElevatedButton(
                      child: const Text('Move to Others'),
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
                      child: const Text('No, Delete All'))
                ]);
          }));
}

void categoryRemover(context, CategoryType cateTypeToDel, Category cateToDel) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: const Text('Removing Category', style: TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Text(cateToDel.items.length < 2
                    ? 'There is an Item in this Category. Remove this Category would delete all its Items.\nContinue?'
                    : 'There are ${cateToDel.items.length} Items in this Category. Remove this Category would delete all its Items.\nContinue?'),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text('Return'),
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
                      child: const Text('Sure'))
                ]);
          }));
}
