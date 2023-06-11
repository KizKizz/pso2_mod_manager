import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/state_provider.dart';

SnackBar snackBarMessage(context, String title, String message, int durationMS) {
  return SnackBar(
      elevation: 0,
      width: windowsWidth * 0.5,
      padding: const EdgeInsets.all(10),
      duration: Duration(milliseconds: durationMS < 3000 ? durationMS : 3000),
      backgroundColor: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
      showCloseIcon: true,
      closeIconColor: Theme.of(context).textTheme.bodyMedium?.color,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ],
      ));
}
