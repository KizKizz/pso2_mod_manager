import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pso2_mod_manager/state_provider.dart';

Future<String> modsRenameDialog(context, String parentLocationPath, String curLocationPath) async {
  var focusNode = FocusNode();
  String curName = curLocationPath.replaceFirst(Uri.file('$parentLocationPath/').toFilePath(), '').replaceAll('/', ' > ').replaceAll('\\', ' > ');
  if (parentLocationPath == curLocationPath) {
    curName = p.basename(curLocationPath);
  }
  TextEditingController newName = TextEditingController();
  newName.text = curName;
  final nameFormKey = GlobalKey<FormState>();
  focusNode.requestFocus();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiRename, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: Form(
                  key: nameFormKey,
                  child: TextFormField(
                    controller: newName,
                    focusNode: focusNode,
                    maxLines: 1,
                    maxLength: 256 - parentLocationPath.length,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlignVertical: TextAlignVertical.center,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                    validator: (value) {
                      if (Directory(parentLocationPath).listSync().where((element) => p.basename(element.path) == newName.text).isNotEmpty) {
                        return curLangText!.uiNameAlreadyExisted;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: curLangText!.enterNewName,
                        hintText: curName,
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
                      onPressed: newName.text.isEmpty
                          ? null
                          : () async {
                              if (nameFormKey.currentState!.validate()) {
                                Navigator.pop(context, newName.text);
                              }
                            },
                      child: const Text('OK'))
                ]);
          }));
}

void renamedPreviewPathsGet(String parentDirPath, List<String> previewImagePaths, List<String> previewVideoPaths) {
  //Get preview images;
    final imagesInModDir = Directory(parentDirPath).listSync(recursive: false).whereType<File>().where(((element) => p.extension(element.path) == '.jpg' || p.extension(element.path) == '.png'));
    for (var element in imagesInModDir) {
      bool isIconImage = false;
      for (var part in p.basenameWithoutExtension(parentDirPath).split(' ')) {
        if (p.basenameWithoutExtension(element.path).contains(part)) {
          isIconImage = true;
          break;
        }
      }
      if (!isIconImage) {
        previewImagePaths.add(Uri.file(element.path).toFilePath());
      }
    }
    //Get preview videos;
    final videosInModDir = Directory(parentDirPath).listSync(recursive: false).whereType<File>().where((element) => p.extension(element.path) == '.webm' || p.extension(element.path) == '.mp4');
    for (var element in videosInModDir) {
      previewVideoPaths.add(Uri.file(element.path).toFilePath());
    }
}