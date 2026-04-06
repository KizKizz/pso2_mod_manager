import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/v3_home/mod_add.dart';
import 'package:signals/signals_flutter.dart';

Future<void> modAddPopup(context, List<String> pathsToAdd) async {
  if (Directory(modAddTempDirPath).existsSync()) Directory(modAddTempDirPath).deleteSync(recursive: true);
  modAddingList.clear();
  modAddDragDropPaths = pathsToAdd;
  if (modAddDragDropPaths.isNotEmpty) curModAddDragDropStatus.value = ModAddDragDropState.fileInList;
  await showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(5),
            content: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: const ModAdd(isPopup: true)),
          );
        });
      });
}
