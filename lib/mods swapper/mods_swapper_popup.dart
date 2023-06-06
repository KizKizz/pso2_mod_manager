import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/functions/csv_files_index.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';

List<String> getCsvFilePath(String categoryName) {
  List<String> csvPaths = [];
  if (categoryName == defaultCategoryTypes[0]) {
    for (var csvFileName in accessoriesCsv) {
      csvPaths.add(Uri.file('$modManRefSheetsDirPath/Player/$csvFileName').toFilePath());
    }
  }

  return csvPaths;
}

void modsSwapperDialog(context, Item fromItem, SubMod fromSubmod) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              actionsOverflowButtonSpacing: 5,
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: <Widget>[
                Wrap(
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(curLangText!.uiClose),
                    ),
                  ],
                )
              ]);
        },
      );
    },
  );
}
