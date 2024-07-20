// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_card_class.dart';
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

Future? cardDataLoader;
Future? customCardsLoader;
List<bool> _loading = [];

void lineDuelCardsHomePage(context) {
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
                                future: customCardsLoader = customCardsFetch(),
                                builder: ((
                                  BuildContext context,
                                  AsyncSnapshot snapshot,
                                ) {
                                  if (snapshot.connectionState == ConnectionState.waiting && customCardsLoader == null) {
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
                                          future: cardDataLoader = originalCardsFetch(context),
                                          builder: ((
                                            BuildContext context,
                                            AsyncSnapshot snapshot,
                                          ) {
                                            if (snapshot.connectionState == ConnectionState.waiting && cardDataLoader == null) {
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
                                                List<LineStrikeCard> cardData = snapshot.data;
                                                if (_loading.length != cardData.length) {
                                                  _loading = List.generate(cardData.length, (index) => false);
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
                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                          crossAxisCount: 3, childAspectRatio: 347 / 449, mainAxisSpacing: 5, crossAxisSpacing: 5),
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
                                                                                aspectRatio: 347 / 451,
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
                                                                                    onLongPress: cardData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                                        color: cardData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                    await customCardsFetch();
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
                                                                      await launchUrl(Uri.file(modManLineStrikeCardDirPath));
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
                                                                        customCardImageCropDialog(context, File(selectedImage.path)).then((value) {
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
                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 5),
                                                                      // itemBuilder: (BuildContext context, int index) {
                                                                      //   return const SizedBox(height: 4);
                                                                      // },
                                                                      shrinkWrap: true,
                                                                      itemCount: cardData.length,
                                                                      itemBuilder: (context, i) {
                                                                        return DragTarget(
                                                                          builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                                                            return Center(
                                                                              child: cardData[i].isReplaced
                                                                                  ? Stack(
                                                                                      alignment: AlignmentDirectional.bottomEnd,
                                                                                      children: [
                                                                                        Stack(
                                                                                          alignment: AlignmentDirectional.bottomEnd,
                                                                                          children: [
                                                                                            AspectRatio(
                                                                                              aspectRatio: 1,
                                                                                              child: Image.network(
                                                                                                cardData[i].iconWebPath,
                                                                                                fit: BoxFit.fill,
                                                                                                filterQuality: FilterQuality.high,
                                                                                              ),
                                                                                            ),
                                                                                            AspectRatio(
                                                                                              aspectRatio: 0.42,
                                                                                              child: Image.file(
                                                                                                File(cardData[i].replacedImagePath),
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
                                                                                                    cardData[i].icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    cardData[i].iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                try {
                                                                                                  File(downloadedIceFilePath).copySync(cardData[i].icePath);
                                                                                                  File(downloadedIconIceFilePath).copySync(cardData[i].iconIcePath);
                                                                                                  cardData[i].replacedIceMd5 = '';
                                                                                                  cardData[i].replacedIconIceMd5 = '';
                                                                                                  cardData[i].replacedImagePath = '';
                                                                                                  cardData[i].isReplaced = false;
                                                                                                  saveLineStrikeCardInfoToJson(cardData);
                                                                                                } catch (e) {
                                                                                                  // ignore: use_build_context_synchronously
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                      // ignore: use_build_context_synchronously
                                                                                                      context,
                                                                                                      '${curLangText!.uiFailed}!',
                                                                                                      '${p.basename(cardData[i].icePath)}\n${p.basename(cardData[i].iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
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
                                                                                            cardData[i].iconWebPath,
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
                                                                                  customCardApply(context, imgPath, cardData[i]).then((value) {
                                                                                    if (value) {
                                                                                      cardData[i].replacedImagePath = imgPath;
                                                                                      cardData[i].isReplaced = true;
                                                                                      saveLineStrikeCardInfoToJson(cardData);
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
                                                                    onLongPress: cardData.where((element) => element.isReplaced).isEmpty
                                                                        ? null
                                                                        : () async {
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                            for (var card in cardData) {
                                                                              if (card.isReplaced) {
                                                                                int index = cardData.indexOf(card);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      card.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      card.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  try {
                                                                                    File(downloadedIceFilePath).copySync(card.icePath);
                                                                                    File(downloadedIconIceFilePath).copySync(card.iconIcePath);
                                                                                    card.replacedIceMd5 = '';
                                                                                    card.replacedIconIceMd5 = '';
                                                                                    card.replacedImagePath = '';
                                                                                    card.isReplaced = false;
                                                                                    saveLineStrikeCardInfoToJson(cardData);
                                                                                  } catch (e) {
                                                                                    // ignore: use_build_context_synchronously
                                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                        // ignore: use_build_context_synchronously
                                                                                        context,
                                                                                        '${curLangText!.uiFailed}!',
                                                                                        '${p.basename(card.icePath)}\n${p.basename(card.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
                                                                                        5000));
                                                                                  }
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                int index = cardData.indexOf(card);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      card.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      card.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  File(downloadedIceFilePath).copySync(card.icePath);
                                                                                  File(downloadedIconIceFilePath).copySync(card.icePath);
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            }
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                          },
                                                                    onPressed: cardData.where((element) => element.isReplaced).isEmpty ? null : () {},
                                                                    child: Text(curLangText!.uiRestoreAll)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () {
                                                                      customCardsLoader = null;
                                                                      cardDataLoader = null;

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
Future<bool> customCardImageCropDialog(context, File newImageFile) async {
  final imageCropController = CropController(
    aspectRatio: 347 / 451,
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
                        if (Directory(modManLineStrikeCardDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
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
                                img.Image resized = img.copyResize(image!, width: 347, height: 451);

                                File croppedImage = File(Uri.file('$modManLineStrikeCardDirPath/${newImageName.text}.png').toFilePath());
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
                              img.Image resized = img.copyResize(image!, width: 347, height: 451);

                              File croppedImage = File(Uri.file('$modManLineStrikeCardDirPath/${newImageName.text}.png').toFilePath());
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

Future<List<LineStrikeCard>> originalCardsFetch(context) async {
  //Load vg from playerItemdata
  if (playerItemData.isEmpty) {
    await playerItemDataGet(context);
  }
  List<CsvItem> csvCardData = playerItemData.where((element) => element.csvFileName == 'Line Duel Cards.csv').toList();
  List<LineStrikeCard> newCardInfoList = [];
  for (var data in csvCardData) {
    String icePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last);
    String iconIcePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last);
    String iceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String iconIceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'ImagePath').value.split('/').last);
    String iconWebPath = '$modManMAIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
    newCardInfoList.add(LineStrikeCard(icePath, iconIcePath, iceDdsName, iconIceDdsName, iconWebPath, '', '', '', false));
    await Future.delayed(const Duration(milliseconds: 10));
  }

  //Load list from json
  List<LineStrikeCard> cardsData = [];
  if (File(modManLineStrikeCardJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeCardJsonPath).readAsStringSync());
    for (var type in jsonData) {
      cardsData.add(LineStrikeCard.fromJson(type));
    }
  }

  //replace settings
  for (var i = 0; i < newCardInfoList.length; i++) {
    for (var cardInJson in cardsData) {
      if (p.basename(newCardInfoList[i].icePath) == p.basename(cardInJson.icePath) && p.basename(newCardInfoList[i].iconIcePath) == p.basename(cardInJson.iconIcePath)) {
        newCardInfoList[i].replacedImagePath = cardInJson.replacedImagePath;
        newCardInfoList[i].replacedIceMd5 = cardInJson.replacedIceMd5;
        newCardInfoList[i].replacedIconIceMd5 = cardInJson.replacedIconIceMd5;
        newCardInfoList[i].isReplaced = cardInJson.isReplaced;
        break;
      }
    }
  }

  // newCardInfoList.sort(
  //   (a, b) => p.basename(b.icePath).compareTo(p.basename(a.icePath)),
  // );
  saveLineStrikeCardInfoToJson(newCardInfoList);

  return newCardInfoList;
}

Future<List<File>> customCardsFetch() async {
  List<File> returnList = [];
  //remove local originals
  // if (customCardsLoader == null) {
  //   await Future.delayed(const Duration(milliseconds: 250));
  // } else {
  //   await Future.delayed(const Duration(milliseconds: 150));
  // }
  returnList = Directory(modManLineStrikeCardDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
  return returnList;
}

Future<bool> customCardApply(context, String imgPath, LineStrikeCard cardDataFile) async {
  clearAllTempDirs();
  //prep image
  img.Image? iconTemplate;
  img.Image? cardTemplate;
  img.Image? fireFrame0Template;
  if (kDebugMode) {
    // iconTemplate = await img.decodePngFile('assets/img/line_strike_card_icon_template.png');
    cardTemplate = await img.decodePngFile('assets/img/line_strike_card_template.png');
    fireFrame0Template = await img.decodePngFile('assets/img/line_strike_card_fire_frame0_template.png');
  } else {
    // iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_icon_template.png').toFilePath());
    cardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_template.png').toFilePath());
    fireFrame0Template = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_fire_frame0_template.png').toFilePath());
  }
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  // img.Image resizedReplaceImage = img.copyResize(replaceImage!, width: 159, height: 224);

  //download and replace
  //icon
  // if (cardDataFile.iconIcePath.isNotEmpty) {
  //   String downloadedIconIceFilePath = await downloadIconIceFromOfficial(cardDataFile.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  //   await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIconIceFilePath]);
  //   String newTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.iconIcePath)}_ext/group2').toFilePath();

  //   if (Directory(newTempIconIcePath).existsSync()) {
  //     await Process.run(modManDdsPngToolExePath,
  //         [Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
  //     img.Image? iconImage = await img.decodePngFile(Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.png').toFilePath());
  //     for (var templatePixel in iconTemplate!.data!) {
  //       if (templatePixel.a > 0) {
  //         iconImage!.setPixel(templatePixel.x, templatePixel.y, resizedReplaceImage.getPixel(templatePixel.x - 49, templatePixel.y - 16));
  //       }
  //     }

  //     await File(Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(iconImage!));

  //     await Process.run(modManDdsPngToolExePath,
  //         [Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
  //     await File(Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.png').toFilePath()).delete();
  //   }

  //   if (File(Uri.file('$newTempIconIcePath/${cardDataFile.iconIceDdsName}.dds').toFilePath()).existsSync()) {
  //     await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.iconIcePath)}_ext').toFilePath()]);
  //     Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.iconIcePath)}').toFilePath()).deleteSync(recursive: true);

  //     File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.iconIcePath)}_ext.ice').toFilePath())
  //         .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.iconIcePath)}').toFilePath());
  //     if (renamedFile.path.isNotEmpty) {
  //       int i = 0;
  //       while (i < 10) {
  //         try {
  //           File copied = renamedFile.copySync(cardDataFile.iconIcePath);
  //           cardDataFile.replacedIconIceMd5 = await getFileHash(copied.path);
  //           i = 10;
  //         } catch (e) {
  //           i++;
  //         }
  //       }
  //       if (i > 10) {
  //         ScaffoldMessenger.of(context)
  //             .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
  //         return false;
  //       }
  //     }

  //     Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
  //       element.deleteSync(recursive: true);
  //     });
  //   }
  // }

  //card
  // String downloadedIceFilePath = await downloadIconIceFromOfficial(cardDataFile.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  // await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIceFilePath]);
  String newTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);

  if (Directory(newTempIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(cardDataFile.iconWebPath, Uri.file('$newTempIcePath/${p.basename(cardDataFile.iconWebPath)}').toFilePath());
    dio.close();
    // await Process.run(
    //     modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.dds').toFilePath(), Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.png').toFilePath(), '-ddstopng']);
    // img.Image? iceImage = await img.decodePngFile(Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.png').toFilePath());

    if (returnedResult.statusCode == 200) {
      //frame0 edit
      img.Image? ogCard = await img.decodePngFile(Uri.file('$newTempIcePath/${p.basename(cardDataFile.iconWebPath)}').toFilePath());
      // for (var pixel in fireFrame0Template!.data!) {
      //   if (pixel.y == 19 && pixel.x == 31) {
      //     debugPrint('x: ' +
      //         pixel.x.toString() +
      //         ' | y: ' +
      //         pixel.y.toString() +
      //         ' | r: ' +
      //         pixel.r.toString() +
      //         ' | g: ' +
      //         pixel.g.toString() +
      //         ' | b: ' +
      //         pixel.b.toString() +
      //         " | a: " +
      //         pixel.a.toString());
      //     break;
      //   }
      //   // if (pixel.a > 0) ogCard!.setPixel(pixel.x, pixel.y, pixel);
      // }

      img.Pixel ogCardCheckPixel = ogCard!.getPixel(31, 19);
      if (ogCardCheckPixel.r == 255 && ogCardCheckPixel.g == 99 && ogCardCheckPixel.b == 99 && ogCardCheckPixel.a == 255) {
        for (var pixel in fireFrame0Template!.data!) {
          if (pixel.a > 0) ogCard.setPixel(pixel.x, pixel.y, pixel);
        }
      }

      for (var templatePixel in cardTemplate!.data!) {
        if (templatePixel.a > 0) {
          try {
            ogCard.setPixel(templatePixel.x, templatePixel.y, replaceImage!.getPixel(templatePixel.x - 13, templatePixel.y - 16));
          } catch (e) {
            break;
          }
        }
      }

      await File(Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(ogCard));

      await Process.run(
          modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
      await File(Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.png').toFilePath()).delete();
    }
  }

  if (File(Uri.file('$newTempIcePath/${cardDataFile.iceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.icePath)}').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.icePath)}.ice').toFilePath())
        .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.icePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(cardDataFile.icePath);
          cardDataFile.replacedIceMd5 = await getFileHash(copied.path);
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.icePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
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
