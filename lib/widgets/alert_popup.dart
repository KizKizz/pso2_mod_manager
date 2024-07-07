import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

Future<bool?> modManAlertOkPopup(context, AlertType? alertType, String tiltle, String desc) {
  return Alert(
    context: context,
    type: alertType,
    style: AlertStyle(
        backgroundColor: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        titleStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium!.color, fontSize: 20),
        descStyle: TextStyle(color: Theme.of(context).textTheme.titleMedium!.color, fontSize: 15),
        ),
    title: curLangText!.uiError,
    desc: desc,
    buttons: [
      DialogButton(
        width: 60,
        color: Theme.of(context).primaryColorLight,
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'OK',
        ),
      ),
    ],
  ).show();
}
