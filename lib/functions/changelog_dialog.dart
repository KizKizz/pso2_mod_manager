import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/application.dart';

Future<void> patchNotesDialog(context) async {
  return showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('Patch Notes')),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              for (int i = 0; i < patchNoteSplit.length; i++) Text('- ${patchNoteSplit[i]}'),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}