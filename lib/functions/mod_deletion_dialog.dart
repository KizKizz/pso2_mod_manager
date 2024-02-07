import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<bool> modDeletionDialog(context, String modName) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
              title: Center(
                child: Text(curLangText!.uiRemoveFromMM, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${curLangText!.uiRemove} "$modName" ${curLangText!.uiFromMM}?')
              ),
              actions: <Widget>[
                ElevatedButton(
                    child: Text(curLangText!.uiNo),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    }),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                    },
                    child: Text(curLangText!.uiYes))
              ]));
}