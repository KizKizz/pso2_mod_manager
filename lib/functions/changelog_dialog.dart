import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

Future<void> patchNotesDialog(context) async {
  return showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
        titlePadding: const EdgeInsets.only(top: 10),
        title: Center(child: Text(curLangText!.uiPatchNotes)),
        contentPadding: const EdgeInsets.all(10),
        content: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (int index = 0; index < patchNoteSplit.length; index++) Text('- ${patchNoteSplit[index]}')],
        )),
        actions: <Widget>[
          ElevatedButton(
            child: Text(curLangText!.uiClose),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
