import 'dart:io';

import 'package:crop_image/crop_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:window_manager/window_manager.dart';

final imageCropController = CropController(
  aspectRatio: 1,
  defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
);

void vitalGaugeHomePage(context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
              contentPadding: const EdgeInsets.all(5),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height,
                child: Scaffold(
                  backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                  body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return FutureBuilder(
                        future: itemCsvFetcher(modManRefSheetsDirPath),
                        builder: ((
                          BuildContext context,
                          AsyncSnapshot snapshot,
                        ) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    curLangText!.uiPreparing,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      curLangText!.uiErrorWhenLoadingAddModsData,
                                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          windowManager.destroy();
                                        },
                                        child: Text(curLangText!.uiExit))
                                  ],
                                ),
                              );
                            } else if (!snapshot.hasData) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      curLangText!.uiPreparing,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const CircularProgressIndicator(),
                                  ],
                                ),
                              );
                            } else {
                              csvInfosFromSheets = snapshot.data;
                              return Row(
                                children: [
                                  RotatedBox(
                                      quarterTurns: -1,
                                      child: Text(
                                        'VITAL GAUGE',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: constraints.maxHeight / 14),
                                      )),
                                  VerticalDivider(
                                    width: 10,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ),
                                  Expanded(
                                      child: Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            const XTypeGroup typeGroup = XTypeGroup(
                                              label: 'image',
                                              extensions: <String>['png'],
                                            );
                                            await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
                                              if (value != null) {
                                                vitalGaugeImageCropDialog(context, File(value.path));
                                                setState(() {});
                                              }
                                            });
                                          },
                                          child: Text('Create'))
                                    ],
                                  )),
                                  VerticalDivider(
                                    width: 10,
                                    thickness: 2,
                                    indent: 5,
                                    endIndent: 5,
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ),
                                  Expanded(
                                      child: Column(
                                    children: [],
                                  ))
                                ],
                              );
                            }
                          }
                        }));
                  }),
                ),
              ));
        });
      });
}

//suport functions
void vitalGaugeImageCropDialog(context, File newImageFile) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            scrollable: true,
            contentPadding: const EdgeInsets.all(5),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              child: CropImage(
                controller: imageCropController,
                image: Image.file(newImageFile),
                paddingSize: 25.0,
                alwaysMove: true,
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(curLangText!.uiReturn))
            ],
          );
        });
      });
}
