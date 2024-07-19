// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/player_item_data.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

Future? sleeveDataLoader;
Future? customSleevesLoader;
List<bool> _loading = [];

void lineDuelSleevesHomePage(context) {
  showDialog(
      barrierDismissible: false,
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
                      return Row(children: [
                        RotatedBox(
                            quarterTurns: -1,
                            child: Text(
                              'LINE STRIKE',
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
                            child: FutureBuilder(
                                future: customSleevesLoader = customSleevesFetch(),
                                builder: ((
                                  BuildContext context,
                                  AsyncSnapshot snapshot,
                                ) {
                                  if (snapshot.connectionState == ConnectionState.waiting && customSleevesLoader == null) {
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
                                      List<File> allCustomBackgrounds = snapshot.data;
                                      return FutureBuilder(
                                          future: sleeveDataLoader = originalSleevesFetch(context),
                                          builder: ((
                                            BuildContext context,
                                            AsyncSnapshot snapshot,
                                          ) {
                                            if (snapshot.connectionState == ConnectionState.waiting && sleeveDataLoader == null) {
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
                                                        curLangText!.uiErrorWhenFetchingItemInfo,
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
                                                List<LineStrikeSleeve> sleeveData = snapshot.data;
                                                if (_loading.length != sleeveData.length) {
                                                  _loading = List.generate(sleeveData.length, (index) => false);
                                                }
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Text(curLangText!.uiCustomCardSleeves, style: Theme.of(context).textTheme.titleLarge),
                                                        Divider(
                                                          height: 10,
                                                          thickness: 1,
                                                          indent: 5,
                                                          endIndent: 5,
                                                          color: Theme.of(context).textTheme.bodySmall!.color,
                                                        ),
                                                        Expanded(
                                                            child: ScrollbarTheme(
                                                                data: ScrollbarThemeData(
                                                                  thumbColor: WidgetStateProperty.resolveWith((states) {
                                                                    if (states.contains(WidgetState.hovered)) {
                                                                      return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                                    }
                                                                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                                  }),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                  child: GridView.builder(
                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                                                      shrinkWrap: true,
                                                                      //physics: const PageScrollPhysics(),
                                                                      itemCount: allCustomBackgrounds.length,
                                                                      itemBuilder: (context, i) {
                                                                        Offset pointerDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset position) {
                                                                          return Offset.zero;
                                                                        }

                                                                        return Draggable(
                                                                          dragAnchorStrategy: pointerDragAnchorStrategy,
                                                                          // feedback: Container(
                                                                          //   width: 483,
                                                                          //   height: 100,
                                                                          //   decoration: ShapeDecoration(
                                                                          //       shape: RoundedRectangleBorder(
                                                                          //           side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                          //           borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                          feedback: Image.file(
                                                                            allCustomBackgrounds[i],
                                                                            filterQuality: FilterQuality.high,
                                                                            fit: BoxFit.fill,
                                                                          ),
                                                                          // ),
                                                                          data: allCustomBackgrounds[i].path,
                                                                          child: Stack(
                                                                            alignment: AlignmentDirectional.bottomStart,
                                                                            children: [
                                                                              AspectRatio(
                                                                                aspectRatio: 183 / 256,
                                                                                child: Container(
                                                                                  decoration: ShapeDecoration(
                                                                                      shape: RoundedRectangleBorder(
                                                                                          side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                                  child: Image.file(
                                                                                    allCustomBackgrounds[i],
                                                                                    fit: BoxFit.fill,
                                                                                    filterQuality: FilterQuality.high,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 2, bottom: 2),
                                                                                child: ModManTooltip(
                                                                                  message: curLangText!.uiHoldToDeleteThisBackground,
                                                                                  child: InkWell(
                                                                                    onLongPress: sleeveData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
                                                                                        ? null
                                                                                        : () async {
                                                                                            setState(() {
                                                                                              allCustomBackgrounds[i].deleteSync();
                                                                                              allCustomBackgrounds.removeAt(i);
                                                                                            });
                                                                                          },
                                                                                    child: Container(
                                                                                      decoration: ShapeDecoration(
                                                                                        color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.4),
                                                                                        shape: RoundedRectangleBorder(
                                                                                            side: BorderSide(color: Theme.of(context).hintColor),
                                                                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                                      ),
                                                                                      child: Icon(
                                                                                        Icons.delete,
                                                                                        color: sleeveData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
                                                                                            ? Theme.of(context).disabledColor
                                                                                            : Colors.red,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      }),
                                                                ))),
                                                        if (allCustomBackgrounds.isEmpty)
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 5),
                                                            child: Container(
                                                              decoration: ShapeDecoration(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                                                              ),
                                                              child: Text(
                                                                curLangText!.uiVitalGaugeBackGroundsInstruction,
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 5),
                                                          child: Row(
                                                            children: [
                                                              ElevatedButton(
                                                                  onPressed: () async {
                                                                    await customSleevesFetch();
                                                                    setState(
                                                                      () {},
                                                                    );
                                                                  },
                                                                  child: const Icon(Icons.refresh)),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await launchUrl(Uri.file(modManLineStrikeSleeveDirPath));
                                                                    },
                                                                    child: Text(curLangText!.uiOpenInFileExplorer)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      const XTypeGroup typeGroup = XTypeGroup(
                                                                        label: 'image',
                                                                        extensions: <String>['png'],
                                                                      );
                                                                      final selectedImage = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                      if (selectedImage != null && context.mounted) {
                                                                        customSleeveImageCropDialog(context, File(selectedImage.path)).then((value) {
                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Text(curLangText!.uiCreateNewCardSleeve)),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                                    VerticalDivider(
                                                      width: 10,
                                                      thickness: 2,
                                                      indent: 5,
                                                      endIndent: 5,
                                                      color: Theme.of(context).textTheme.bodySmall!.color,
                                                    ),
                                                    //available list
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Text(curLangText!.uiSwappedAvailableCardSleeves, style: Theme.of(context).textTheme.titleLarge),
                                                        Divider(
                                                          height: 10,
                                                          thickness: 1,
                                                          indent: 5,
                                                          endIndent: 5,
                                                          color: Theme.of(context).textTheme.bodySmall!.color,
                                                        ),
                                                        Expanded(
                                                            child: ScrollbarTheme(
                                                                data: ScrollbarThemeData(
                                                                  thumbColor: WidgetStateProperty.resolveWith((states) {
                                                                    // if (states.contains(WidgetStateered)) {
                                                                    //   return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                                                                    // }
                                                                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                                                                  }),
                                                                ),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                                  child: GridView.builder(
                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                                                      // itemBuilder: (BuildContext context, int index) {
                                                                      //   return const SizedBox(height: 4);
                                                                      // },
                                                                      shrinkWrap: true,
                                                                      itemCount: sleeveData.length,
                                                                      itemBuilder: (context, i) {
                                                                        return DragTarget(
                                                                          builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                                                            return Center(
                                                                              child: sleeveData[i].isReplaced
                                                                                  ? Stack(
                                                                                      alignment: AlignmentDirectional.bottomEnd,
                                                                                      children: [
                                                                                        Stack(
                                                                                          alignment: AlignmentDirectional.bottomEnd,
                                                                                          children: [
                                                                                            AspectRatio(
                                                                                              aspectRatio: 1,
                                                                                              child: Image.network(
                                                                                                sleeveData[i].iconWebPath,
                                                                                                fit: BoxFit.fill,
                                                                                                filterQuality: FilterQuality.high,
                                                                                              ),
                                                                                            ),
                                                                                            AspectRatio(
                                                                                              aspectRatio: 0.42,
                                                                                              child: Image.file(
                                                                                                File(sleeveData[i].replacedImagePath),
                                                                                                fit: BoxFit.scaleDown,
                                                                                                alignment: Alignment.bottomCenter,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(0),
                                                                                          child: ModManTooltip(
                                                                                            message: curLangText!.uiHoldToRestoreThisBackgroundToItsOriginal,
                                                                                            child: InkWell(
                                                                                              child: Container(
                                                                                                decoration: ShapeDecoration(
                                                                                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.4),
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                      side: BorderSide(color: Theme.of(context).hintColor),
                                                                                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                                                ),
                                                                                                child: const Icon(
                                                                                                  Icons.restore,
                                                                                                  color: Colors.red,
                                                                                                ),
                                                                                              ),
                                                                                              onLongPress: () async {
                                                                                                String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    sleeveData[i].icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    sleeveData[i].iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                try {
                                                                                                  File(downloadedIceFilePath).copySync(sleeveData[i].icePath);
                                                                                                  File(downloadedIconIceFilePath).copySync(sleeveData[i].iconIcePath);
                                                                                                  sleeveData[i].replacedIceMd5 = '';
                                                                                                  sleeveData[i].replacedIconIceMd5 = '';
                                                                                                  sleeveData[i].replacedImagePath = '';
                                                                                                  sleeveData[i].isReplaced = false;
                                                                                                  saveLineStrikeSleeveInfoToJson(sleeveData);
                                                                                                } catch (e) {
                                                                                                  // ignore: use_build_context_synchronously
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                      // ignore: use_build_context_synchronously
                                                                                                      context,
                                                                                                      '${curLangText!.uiFailed}!',
                                                                                                      '${p.basename(sleeveData[i].icePath)}\n${p.basename(sleeveData[i].iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
                                                                                                      5000));
                                                                                                }
                                                                                                setState(() {});
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  // ),

                                                                                  : Stack(
                                                                                      alignment: AlignmentDirectional.bottomCenter,
                                                                                      children: [
                                                                                        AspectRatio(
                                                                                          aspectRatio: 1,
                                                                                          // child: Container(
                                                                                          //   decoration: ShapeDecoration(
                                                                                          //       shape: RoundedRectangleBorder(
                                                                                          //           side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                          //           borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                                          child: Image.network(
                                                                                            sleeveData[i].iconWebPath,
                                                                                            filterQuality: FilterQuality.high,
                                                                                            fit: BoxFit.fill,
                                                                                          ),
                                                                                          // ),
                                                                                        ),
                                                                                        if (_loading[i])
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(left: 5, bottom: 5),
                                                                                            child: CircularProgressIndicator(
                                                                                              strokeWidth: 6,
                                                                                              backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                                            ),
                                                                                          ),
                                                                                      ],
                                                                                    ),
                                                                            );
                                                                          },
                                                                          onAcceptWithDetails: (data) {
                                                                            _loading[i] = true;
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                            Future.delayed(const Duration(milliseconds: 500), () {
                                                                              setState(
                                                                                () {
                                                                                  String imgPath = data.data.toString();
                                                                                  customSleeveApply(context, imgPath, sleeveData[i]).then((value) {
                                                                                    if (value) {
                                                                                      sleeveData[i].replacedImagePath = imgPath;
                                                                                      sleeveData[i].isReplaced = true;
                                                                                      saveLineStrikeSleeveInfoToJson(sleeveData);
                                                                                      // Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                      //   element.deleteSync(recursive: true);
                                                                                      // });
                                                                                      _loading[i] = false;
                                                                                      setState(
                                                                                        () {},
                                                                                      );
                                                                                    } else {
                                                                                      _loading[i] = false;
                                                                                      setState(
                                                                                        () {},
                                                                                      );
                                                                                    }
                                                                                  });
                                                                                },
                                                                              );
                                                                            });
                                                                          },
                                                                        );
                                                                      }),
                                                                ))),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 5),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onLongPress: sleeveData.where((element) => element.isReplaced).isEmpty
                                                                        ? null
                                                                        : () async {
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                            for (var sleeve in sleeveData) {
                                                                              if (sleeve.isReplaced) {
                                                                                int index = sleeveData.indexOf(sleeve);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      sleeve.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      sleeve.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  try {
                                                                                    File(downloadedIceFilePath).copySync(sleeve.icePath);
                                                                                    File(downloadedIconIceFilePath).copySync(sleeve.iconIcePath);
                                                                                    sleeve.replacedIceMd5 = '';
                                                                                    sleeve.replacedIconIceMd5 = '';
                                                                                    sleeve.replacedImagePath = '';
                                                                                    sleeve.isReplaced = false;
                                                                                    saveLineStrikeSleeveInfoToJson(sleeveData);
                                                                                  } catch (e) {
                                                                                    // ignore: use_build_context_synchronously
                                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                        // ignore: use_build_context_synchronously
                                                                                        context,
                                                                                        '${curLangText!.uiFailed}!',
                                                                                        '${p.basename(sleeve.icePath)}\n${p.basename(sleeve.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
                                                                                        5000));
                                                                                  }
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                int index = sleeveData.indexOf(sleeve);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      sleeve.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      sleeve.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  File(downloadedIceFilePath).copySync(sleeve.icePath);
                                                                                  File(downloadedIconIceFilePath).copySync(sleeve.icePath);
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            }
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                          },
                                                                    onPressed: sleeveData.where((element) => element.isReplaced).isEmpty ? null : () {},
                                                                    child: Text(curLangText!.uiRestoreAll)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () {
                                                                      customSleevesLoader = null;
                                                                      sleeveDataLoader = null;

                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(curLangText!.uiClose)),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ))
                                                  ],
                                                );
                                              }
                                            }
                                          }));
                                    }
                                  }
                                }))),
                      ]);
                    })),
              ));
        });
      });
}

//suport functions
Future<bool> customSleeveImageCropDialog(context, File newImageFile) async {
  final imageCropController = CropController(
    aspectRatio: 183 / 256,
    //minimumImageSize: 100,
    // defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );
  TextEditingController newImageName = TextEditingController(text: p.basenameWithoutExtension(newImageFile.path));
  final nameFormKey = GlobalKey<FormState>();
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
            //scrollable: true,
            contentPadding: const EdgeInsets.all(5),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height,
              child: CropImage(
                controller: imageCropController,
                image: Image.file(newImageFile, filterQuality: FilterQuality.high),
                paddingSize: 5,
                alwaysMove: true,
              ),
            ),
            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Form(
                    key: nameFormKey,
                    child: TextFormField(
                      controller: newImageName,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                      validator: (value) {
                        if (Directory(modManLineStrikeSleeveDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
                          return curLangText!.uiNameAlreadyExisted;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: curLangText!.uiCroppedImageName,
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.error),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          //isCollapsed: true,
                          //isDense: true,
                          contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                          constraints: const BoxConstraints.tightForFinite(),
                          // Set border for enabled state (default)
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          // Set border for focused state
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                            borderRadius: BorderRadius.circular(2),
                          )),
                      onChanged: (value) async {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    spacing: 5.0,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            imageCropController.dispose();
                            await Future.delayed(const Duration(milliseconds: 50));
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context, false);
                          },
                          child: Text(curLangText!.uiReturn)),
                      Visibility(
                        visible: (nameFormKey.currentState != null && nameFormKey.currentState!.validate()) || nameFormKey.currentState == null,
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(
                                () {},
                              );
                              if (nameFormKey.currentState!.validate()) {
                                final croppedImageBitmap = await imageCropController.croppedBitmap(quality: FilterQuality.high);
                                final data = await croppedImageBitmap.toByteData(format: ImageByteFormat.png);
                                final bytes = data!.buffer.asUint8List();
                                img.Image? image = img.decodePng(bytes);
                                img.Image resized = img.copyResize(image!, width: 183, height: 256);

                                File croppedImage = File(Uri.file('$modManLineStrikeSleeveDirPath/${newImageName.text}.png').toFilePath());
                                croppedImage.writeAsBytesSync(img.encodePng(resized));
                                //croppedImage.writeAsBytes(bytes, flush: true);
                                imageCropController.dispose();
                                //Future.delayed(const Duration(milliseconds: 100), () {
                                if (context.mounted) {
                                  Navigator.pop(context, true);
                                }
                                //});
                              }
                            },
                            child: Text(curLangText!.uiSaveCroppedArea)),
                      ),
                      Visibility(
                        visible: nameFormKey.currentState != null && !nameFormKey.currentState!.validate(),
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(
                                () {},
                              );
                              final croppedImageBitmap = await imageCropController.croppedBitmap(quality: FilterQuality.high);
                              final data = await croppedImageBitmap.toByteData(format: ImageByteFormat.png);
                              final bytes = data!.buffer.asUint8List();
                              img.Image? image = img.decodePng(bytes);
                              img.Image resized = img.copyResize(image!, width: 183, height: 256);

                              File croppedImage = File(Uri.file('$modManLineStrikeSleeveDirPath/${newImageName.text}.png').toFilePath());
                              croppedImage.writeAsBytesSync(img.encodePng(resized));
                              //croppedImage.writeAsBytes(bytes, flush: true);
                              imageCropController.dispose();
                              //Future.delayed(const Duration(milliseconds: 100), () {
                              if (context.mounted) {
                                Navigator.pop(context, true);
                              }
                              //});
                            },
                            child: Text(curLangText!.uiOverwriteImage)),
                      )
                    ],
                  )
                ],
              )
            ],
          );
        });
      });
}

Future<List<LineStrikeSleeve>> originalSleevesFetch(context) async {
  //Load vg from playerItemdata
  if (playerItemData.isEmpty) {
    await playerItemDataGet(context);
  }
  List<CsvItem> sleeveData = playerItemData.where((element) => element.csvFileName == 'Line Duel Sleeves.csv').toList();
  List<LineStrikeSleeve> newSleeveInfoList = [];
  for (var data in sleeveData) {
    String icePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last);
    String iconIcePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last);
    String iceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String iconIceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'ImagePath').value.split('/').last);
    String iconWebPath = '$modManMAIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
    newSleeveInfoList.add(LineStrikeSleeve(icePath, iconIcePath, iceDdsName, iconIceDdsName, iconWebPath, await getFileHash(icePath), await getFileHash(iconIcePath), '', false));
  }

  //Load list from json
  List<LineStrikeSleeve> sleevesData = [];
  if (File(modManLineStrikeSleeveJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeSleeveJsonPath).readAsStringSync());
    for (var type in jsonData) {
      sleevesData.add(LineStrikeSleeve.fromJson(type));
    }
  }

  //replace settings
  for (var i = 0; i < newSleeveInfoList.length; i++) {
    for (var sleeveInJson in sleevesData) {
      if (p.basename(newSleeveInfoList[i].icePath) == p.basename(sleeveInJson.icePath) && p.basename(newSleeveInfoList[i].iconIcePath) == p.basename(sleeveInJson.iconIcePath)) {
        newSleeveInfoList[i].replacedImagePath = sleeveInJson.replacedImagePath;
        newSleeveInfoList[i].replacedIceMd5 = sleeveInJson.replacedIceMd5;
        newSleeveInfoList[i].replacedIconIceMd5 = sleeveInJson.replacedIconIceMd5;
        newSleeveInfoList[i].isReplaced = sleeveInJson.isReplaced;
        break;
      }
    }
  }

  newSleeveInfoList.sort(
    (a, b) => p.basename(b.icePath).compareTo(p.basename(a.icePath)),
  );
  saveLineStrikeSleeveInfoToJson(newSleeveInfoList);

  return newSleeveInfoList;
}

Future<List<File>> customSleevesFetch() async {
  List<File> returnList = [];
  //remove local originals
  if (customSleevesLoader == null) {
    await Future.delayed(const Duration(milliseconds: 250));
  } else {
    await Future.delayed(const Duration(milliseconds: 150));
  }
  returnList = Directory(modManLineStrikeSleeveDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
  return returnList;
}

Future<bool> customSleeveApply(context, String imgPath, LineStrikeSleeve sleeveDataFile) async {
  clearAllTempDirs();
  //prep image
  img.Image? iconTemplate;
  img.Image? sleeveTemplate;
  if (kDebugMode) {
    iconTemplate = await img.decodePngFile('assets/img/line_strike_sleeve_icon_template.png');
    sleeveTemplate = await img.decodePngFile('assets/img/line_strike_sleeve_template.png');
  } else {
    iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_sleeve_icon_template.png').toFilePath());
    sleeveTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_sleeve_template.png').toFilePath());
  }
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedReplaceImage = img.copyResize(replaceImage!, width: 159, height: 224);

  //download and replace
  //icon
  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(sleeveDataFile.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIconIceFilePath]);
  String newTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext/group2').toFilePath();

  if (Directory(newTempIconIcePath).existsSync()) {
    await Process.run(modManDdsPngToolExePath,
        [Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
    img.Image? iconImage = await img.decodePngFile(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath());
    for (var templatePixel in iconTemplate!.data!) {
      if (templatePixel.a > 0) {
        iconImage!.setPixel(templatePixel.x, templatePixel.y, resizedReplaceImage.getPixel(templatePixel.x - 49, templatePixel.y - 16));
      }
    }

    await File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(iconImage!));

    await Process.run(modManDdsPngToolExePath,
        [Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIconIcePath/${sleeveDataFile.iconIceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}_ext.ice').toFilePath())
        .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.iconIcePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(sleeveDataFile.iconIcePath);
          sleeveDataFile.replacedIconIceMd5 = await getFileHash(copied.path);
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(sleeveDataFile.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
        return false;
      }
    }

    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  //sleeve
  // String downloadedIceFilePath = await downloadIconIceFromOfficial(sleeveDataFile.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  // await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIceFilePath]);
  String newTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);

  if (Directory(newTempIcePath).existsSync()) {
    // await Process.run(
    //     modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath(), Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath(), '-ddstopng']);
    // img.Image? iceImage = await img.decodePngFile(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath());
    for (var templatePixel in sleeveTemplate!.data!) {
      if (templatePixel.a > 0) {
        templatePixel.set(replaceImage.getPixel(templatePixel.x, templatePixel.y));
        // iceImage!.setPixel(templatePixel.x, templatePixel.y, replaceImage.getPixel(templatePixel.x, templatePixel.y));
      }
    }

    await File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(sleeveTemplate));

    await Process.run(
        modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIcePath/${sleeveDataFile.iceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.icePath)}.ice').toFilePath())
        .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(sleeveDataFile.icePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(sleeveDataFile.icePath);
          sleeveDataFile.replacedIceMd5 = await getFileHash(copied.path);
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(sleeveDataFile.icePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
        return false;
      }
    }

    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  return true;
}

// class CustomClipPath extends CustomClipper<Path> {
//   //var radius=10.0;
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, 256);
//     path.lineTo(183, 0);
//     path.lineTo(256, 0);
//     path.lineTo(0, 0);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// class CustomClipLayerPath extends CustomClipper<Path> {
//   //var radius=10.0;
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, 50);
//     path.lineTo(50, 50);
//     path.lineTo(50, 0);
//     path.lineTo(50, 0);
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
