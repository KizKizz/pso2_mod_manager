import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/file_check/file_check_popup.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/material_app_service.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

Future<void> firstTimePopup(context) async {
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.all(5),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            content: Text(appText.firstTimeInfo, style: Theme.of(context).textTheme.titleSmall),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              OverflowBar(
                spacing: 5,
                overflowSpacing: 5,
                children: [
                  OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        firstBootUp = false;
                        prefs.setBool('firstBootUp', firstBootUp);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        await Future.delayed(Duration(milliseconds: 10));
                        await checkGameFilesPopup(MaterialAppService.navigatorKey.currentContext, true);
                      },
                      child: Text(appText.gameDataIntegrityCheck)),
                  OutlinedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        firstBootUp = false;
                        prefs.setBool('firstBootUp', firstBootUp);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      child: Text(appText.ok))
                ],
              )
            ],
          );
        });
      });
}
