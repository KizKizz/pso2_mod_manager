import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/global_vars.dart';

Future<void> profileReloadPopup(context) async {
  await showDialog(
    barrierDismissible: false,
    barrierColor: Colors.black.withAlpha(225),
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(0))),
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(0),
            content: Center(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Future.delayed(Duration(milliseconds: 500));
                  pageIndex = 6;
                  modListReload = true;
                  curPage.value = appPages[pageIndex];
                },
                child: Text(appText.reload, style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
          );
        },
      );
    },
  );
}
