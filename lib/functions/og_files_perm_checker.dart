import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

void ogFilesPermChecker(context) {
  if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync() && Directory(Uri.file('$modManPso2binPath/data/win32reboot_na').toFilePath()).existsSync()) {
    if (ogWin32FilePaths.isEmpty || ogWin32NAFilePaths.isEmpty || ogWin32RebootFilePaths.isEmpty || ogWin32RebootNAFilePaths.isEmpty) {
      noOGFIlesFoundDialog(context);
    }
  } else {
    if (ogWin32FilePaths.isEmpty || ogWin32RebootFilePaths.isEmpty) {
      noOGFIlesFoundDialog(context);
    }
  }
}

Future<bool> noOGFIlesFoundDialog(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiNoGamedataFound, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      curLangText!.uiNoGameDataFoundMessage,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                    },
                    child: const Text('OK'))
              ]));
}
