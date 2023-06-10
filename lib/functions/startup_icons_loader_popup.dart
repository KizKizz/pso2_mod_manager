import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<String> startupItemIconDialog(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                title: Text(curLangText!.uiModsLoader, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                content: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(curLangText!.uiAutoFetchItemIcons),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiNo),
                      onPressed: () {
                        Navigator.pop(context, 'off');
                      }),
                  ElevatedButton(
                      child: Text(curLangText!.uiOneIconEachItem),
                      onPressed: () {
                        Navigator.pop(context, 'minimal');
                      }),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'all');
                      },
                      child: Text(curLangText!.uiFetchAll))
                ]);
          }));
}
