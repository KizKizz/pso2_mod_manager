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
                                                                            scale: 1.5,
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
                                                                                      alignment: AlignmentDirectional.bottomStart,
                                                                                      children: [
                                                                                        Stack(
                                                                                          alignment: AlignmentDirectional.bottomEnd,
                                                                                          children: [
                                                                                            AspectRatio(
                                                                                              aspectRatio: 1,
                                                                                              child: Image.network(
                                                                                                cardData[i].cardZeroIconWebPath,
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
                                                                                                String downloadedCardZeroIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    cardData[i].cardZeroIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedCardZeroIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    cardData[i].cardZeroIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedCardOneIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    cardData[i].cardOneIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedCardOneIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    cardData[i].cardOneIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                try {
                                                                                                  File(downloadedCardZeroIceFilePath).copySync(cardData[i].cardZeroIcePath);
                                                                                                  File(downloadedCardZeroIconIceFilePath).copySync(cardData[i].cardZeroIconIcePath);
                                                                                                  File(downloadedCardOneIceFilePath).copySync(cardData[i].cardOneIcePath);
                                                                                                  File(downloadedCardOneIconIceFilePath).copySync(cardData[i].cardOneIconIcePath);
                                                                                                  cardData[i].cardZeroReplacedIceMd5 = '';
                                                                                                  cardData[i].cardZeroReplacedIconIceMd5 = '';
                                                                                                  cardData[i].cardOneReplacedIceMd5 = '';
                                                                                                  cardData[i].cardOneReplacedIconIceMd5 = '';
                                                                                                  cardData[i].replacedImagePath = '';
                                                                                                  cardData[i].isReplaced = false;
                                                                                                  saveLineStrikeCardInfoToJson(cardData);
                                                                                                  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                                    element.deleteSync(recursive: true);
                                                                                                  });
                                                                                                } catch (e) {
                                                                                                  // ignore: use_build_context_synchronously
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                      // ignore: use_build_context_synchronously
                                                                                                      context,
                                                                                                      '${curLangText!.uiFailed}!',
                                                                                                      e.toString(),
                                                                                                      5000));
                                                                                                }
                                                                                                setState(() {});
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Stack(
                                                                                      alignment: AlignmentDirectional.bottomStart,
                                                                                      children: [
                                                                                        AspectRatio(
                                                                                          aspectRatio: 1,
                                                                                          // child: Container(
                                                                                          //   decoration: ShapeDecoration(
                                                                                          //       shape: RoundedRectangleBorder(
                                                                                          //           side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                          //           borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                                          child: Image.network(
                                                                                            cardData[i].cardZeroIconWebPath,
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
                                                                            for (int i = 0; i < cardData.length; i++) {
                                                                              if (cardData[i].isReplaced) {
                                                                                int index = cardData.indexOf(cardData[i]);
                                                                                _loading[index] = true;
                                                                                setState(
                                                                                  () {},
                                                                                );

                                                                                String downloadedCardZeroIceFilePath = await downloadIconIceFromOfficial(
                                                                                    cardData[i].cardZeroIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                    modManAddModsTempDirPath);
                                                                                String downloadedCardZeroIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                    cardData[i].cardZeroIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                    modManAddModsTempDirPath);
                                                                                String downloadedCardOneIceFilePath = await downloadIconIceFromOfficial(
                                                                                    cardData[i].cardOneIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                    modManAddModsTempDirPath);
                                                                                String downloadedCardOneIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                    cardData[i].cardOneIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                    modManAddModsTempDirPath);
                                                                                try {
                                                                                  File(downloadedCardZeroIceFilePath).copySync(cardData[i].cardZeroIcePath);
                                                                                  File(downloadedCardZeroIconIceFilePath).copySync(cardData[i].cardZeroIconIcePath);
                                                                                  File(downloadedCardOneIceFilePath).copySync(cardData[i].cardOneIcePath);
                                                                                  File(downloadedCardOneIconIceFilePath).copySync(cardData[i].cardOneIconIcePath);
                                                                                  cardData[i].cardZeroReplacedIceMd5 = '';
                                                                                  cardData[i].cardZeroReplacedIconIceMd5 = '';
                                                                                  cardData[i].cardOneReplacedIceMd5 = '';
                                                                                  cardData[i].cardOneReplacedIconIceMd5 = '';
                                                                                  cardData[i].replacedImagePath = '';
                                                                                  cardData[i].isReplaced = false;
                                                                                  saveLineStrikeCardInfoToJson(cardData);
                                                                                  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                    element.deleteSync(recursive: true);
                                                                                  });
                                                                                } catch (e) {
                                                                                  // ignore: use_build_context_synchronously
                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                      // ignore: use_build_context_synchronously
                                                                                      context,
                                                                                      '${curLangText!.uiFailed}!',
                                                                                      e.toString(),
                                                                                      5000));
                                                                                }
                                                                                _loading[index] = false;
                                                                                setState(() {});
                                                                              }
                                                                              await Future.delayed(const Duration(milliseconds: 10));
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
  List<CsvItem> csvCardZeroData = playerItemData
      .where(
          (element) => element.csvFileName == 'Line Duel Cards.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'IcePath').value).characters.last == '0')
      .toList();
  List<CsvItem> csvCardOneData = playerItemData
      .where(
          (element) => element.csvFileName == 'Line Duel Cards.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'IcePath').value).characters.last == '1')
      .toList();
  List<CsvItem> csvCardZeroIconData = playerItemData
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value).characters.last == '0')
      .toList();
  List<CsvItem> csvCardOneIconData = playerItemData
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value).characters.last == '1')
      .toList();

  List<LineStrikeCard> newCardInfoList = [];
  for (int i = 0; i < csvCardZeroData.length; i++) {
    //card0
    String cardZeroIcePath = ogVitalGaugeIcePathsFetcher(csvCardZeroData[i].infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last);
    String cardZeroIconIcePath = ogVitalGaugeIcePathsFetcher(csvCardZeroIconData[i].infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last);
    String cardZeroDdsName = p.basenameWithoutExtension(csvCardZeroData[i].infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String cardZeroIconDdsName = p.basenameWithoutExtension(csvCardZeroIconData[i].infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
    String cardZeroIconWebPath = '$modManMAIconDatabaseLink${csvCardZeroData[i].iconImagePath.replaceAll('\\', '/')}';
    String cardZeroSquareIconWebPath = '$modManMAIconDatabaseLink${csvCardZeroIconData[i].iconImagePath.replaceAll('\\', '/')}';
    //card1
    String cardOneIcePath = ogVitalGaugeIcePathsFetcher(csvCardOneData[i].infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last);
    String cardOneIconIcePath = ogVitalGaugeIcePathsFetcher(csvCardOneIconData[i].infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last);
    String cardOneDdsName = p.basenameWithoutExtension(csvCardOneData[i].infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
    String cardOneIconDdsName = p.basenameWithoutExtension(csvCardOneIconData[i].infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
    String cardOneIconWebPath = '$modManMAIconDatabaseLink${csvCardOneData[i].iconImagePath.replaceAll('\\', '/')}';
    String cardOneSquareIconWebPath = '$modManMAIconDatabaseLink${csvCardOneIconData[i].iconImagePath.replaceAll('\\', '/')}';

    newCardInfoList.add(LineStrikeCard(cardZeroIcePath, cardZeroIconIcePath, cardZeroDdsName, cardZeroIconDdsName, cardZeroIconWebPath, cardZeroSquareIconWebPath, '', '', cardOneIcePath,
        cardOneIconIcePath, cardOneDdsName, cardOneIconDdsName, cardOneIconWebPath, cardOneSquareIconWebPath, '', '', '', false));
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
      if (p.basename(newCardInfoList[i].cardZeroIcePath) == p.basename(cardInJson.cardZeroIcePath) && p.basename(newCardInfoList[i].cardOneIcePath) == p.basename(cardInJson.cardOneIcePath)) {
        newCardInfoList[i].replacedImagePath = cardInJson.replacedImagePath;
        newCardInfoList[i].cardZeroReplacedIceMd5 = cardInJson.cardZeroReplacedIceMd5;
        newCardInfoList[i].cardZeroReplacedIconIceMd5 = cardInJson.cardZeroReplacedIconIceMd5;
        newCardInfoList[i].cardOneReplacedIceMd5 = cardInJson.cardOneReplacedIceMd5;
        newCardInfoList[i].cardOneReplacedIconIceMd5 = cardInJson.cardOneReplacedIconIceMd5;
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
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedIconImage = img.copyResize(replaceImage!, width: 104, height: 104);

  //download and replace
  //card zero replacement
  File? replacedCardZeroIce = await cardArtReplace(replaceImage, cardDataFile.cardZeroIcePath, cardDataFile.cardZeroDdsName, cardDataFile.cardZeroIconWebPath);

  if (replacedCardZeroIce != null && replacedCardZeroIce.existsSync()) {
    int i = 0;
    while (i < 10) {
      try {
        File copied = replacedCardZeroIce.copySync(cardDataFile.cardZeroIcePath);
        cardDataFile.cardZeroReplacedIceMd5 = await getFileHash(copied.path);
        i = 10;
      } catch (e) {
        i++;
      }
    }
    if (i > 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.cardZeroIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
      return false;
    }
  }

  //card one replacement
  File? replacedCardOneIce = await cardArtReplace(replaceImage, cardDataFile.cardOneIcePath, cardDataFile.cardOneDdsName, cardDataFile.cardOneIconWebPath);

  if (replacedCardOneIce != null && replacedCardOneIce.existsSync()) {
    int i = 0;
    while (i < 10) {
      try {
        File copied = replacedCardOneIce.copySync(cardDataFile.cardOneIcePath);
        cardDataFile.cardOneReplacedIceMd5 = await getFileHash(copied.path);
        i = 10;
      } catch (e) {
        i++;
      }
    }
    if (i > 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.cardOneIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
      return false;
    }
  }

  //icon zero replacement
  File? replacedCardZeroIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardZeroIconIcePath, cardDataFile.cardZeroIconDdsName, cardDataFile.cardZeroSquareIconWebPath);
  if (replacedCardZeroIconIce != null && replacedCardZeroIconIce.existsSync()) {
    int i = 0;
    while (i < 10) {
      try {
        File copied = replacedCardZeroIconIce.copySync(cardDataFile.cardZeroIconIcePath);
        cardDataFile.cardZeroReplacedIconIceMd5 = await getFileHash(copied.path);
        i = 10;
      } catch (e) {
        i++;
      }
    }
    if (i > 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.cardZeroIconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
      return false;
    }
  }

  //icon one replacement
  File? replacedCardOneIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardOneIconIcePath, cardDataFile.cardOneIconDdsName, cardDataFile.cardOneSquareIconWebPath);
  if (replacedCardOneIconIce != null && replacedCardOneIconIce.existsSync()) {
    int i = 0;
    while (i < 10) {
      try {
        File copied = replacedCardOneIconIce.copySync(cardDataFile.cardOneIconIcePath);
        cardDataFile.cardOneReplacedIconIceMd5 = await getFileHash(copied.path);
        i = 10;
      } catch (e) {
        i++;
      }
    }
    if (i > 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(cardDataFile.cardOneIconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
      return false;
    }
  }

  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    element.deleteSync(recursive: true);
  });

  return true;
}

Future<File?> cardArtReplace(img.Image? replaceImage, String icePath, String ddsName, String iconWebPath) async {
  //card zero
  String newTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);
  if (Directory(newTempIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(iconWebPath, Uri.file('$newTempIcePath/${p.basename(iconWebPath)}').toFilePath());
    dio.close();

    if (returnedResult.statusCode == 200) {
      //edit
      img.Image? ogCard = await img.decodePngFile(Uri.file('$newTempIcePath/${p.basename(iconWebPath)}').toFilePath());
      img.Image? frameTemplate;
      img.Image? cardTemplate;

      // debugPrint('x: ' +
      //     ogCard!.getPixel(344, 380).x.toString() +
      //     ' | y: ' +
      //     ogCard.getPixel(344, 380).y.toString() +
      //     ' | r: ' +
      //     ogCard.getPixel(344, 380).r.toString() +
      //     ' | g: ' +
      //     ogCard.getPixel(344, 380).g.toString() +
      //     ' | b: ' +
      //     ogCard.getPixel(344, 380).b.toString() +
      //     " | a: " +
      //     ogCard.getPixel(344, 380).a.toString());

      if ((ogCard!.getPixel(344, 450).r == 92 && ogCard.getPixel(344, 450).g == 124 && ogCard.getPixel(344, 450).b == 204 && ogCard.getPixel(344, 450).a == 255) ||
          (ogCard.getPixel(344, 380).r == 184 && ogCard.getPixel(344, 380).g == 100 && ogCard.getPixel(344, 380).b == 100 && ogCard.getPixel(344, 380).a == 255)) {
        if (kDebugMode) {
          cardTemplate = await img.decodePngFile('assets/img/line_strike_card_template.png');
        } else {
          cardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_template.png').toFilePath());
        }
      } else {
        if (kDebugMode) {
          cardTemplate = await img.decodePngFile('assets/img/line_strike_card_template1.png');
        } else {
          cardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_template1.png').toFilePath());
        }
      }

      // img.Pixel ogCardCheckPixel = ogCard!.getPixel(31, 19);
      if (ogCard.getPixel(31, 19).r == 255 && ogCard.getPixel(31, 19).g == 99 && ogCard.getPixel(31, 19).b == 99 && ogCard.getPixel(31, 19).a == 255) {
        //fire
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_fire_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_fire_frame0_template.png').toFilePath());
        }
      } else if (ogCard.getPixel(31, 13).r == 120 && ogCard.getPixel(31, 13).g == 214 && ogCard.getPixel(31, 13).b == 253 && ogCard.getPixel(31, 13).a == 255) {
        //ice
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_ice_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_ice_frame0_template.png').toFilePath());
        }
      } else if (ogCard.getPixel(31, 13).r == 156 && ogCard.getPixel(31, 13).g == 255 && ogCard.getPixel(31, 13).b == 173 && ogCard.getPixel(31, 13).a == 255) {
        //wind
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_wind_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_wind_frame0_template.png').toFilePath());
        }
      } else if (ogCard.getPixel(35, 16).r == 255 && ogCard.getPixel(35, 16).g == 253 && ogCard.getPixel(35, 16).b == 97 && ogCard.getPixel(35, 16).a == 255) {
        //lightning
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_lightning_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_lightning_frame0_template.png').toFilePath());
        }
      } else if (ogCard.getPixel(26, 15).r == 255 && ogCard.getPixel(26, 15).g == 251 && ogCard.getPixel(26, 15).b == 239 && ogCard.getPixel(26, 15).a == 255) {
        //light
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_light_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_light_frame0_template.png').toFilePath());
        }
      } else if (ogCard.getPixel(24, 14).r == 255 && ogCard.getPixel(24, 14).g == 159 && ogCard.getPixel(24, 14).b == 255 && ogCard.getPixel(24, 14).a == 255) {
        //dark
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_dark_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_dark_frame0_template.png').toFilePath());
        }
      }
      // else {
      //   for (var pixel in ogCard.data!) {
      //     if (pixel.x == 24 && pixel.y == 14) {
      //       debugPrint('x: ' +
      //           pixel.x.toString() +
      //           ' | y: ' +
      //           pixel.y.toString() +
      //           ' | r: ' +
      //           pixel.r.toString() +
      //           ' | g: ' +
      //           pixel.g.toString() +
      //           ' | b: ' +
      //           pixel.b.toString() +
      //           " | a: " +
      //           pixel.a.toString());
      //       break;
      //     }
      //   }
      // }

      for (var pixel in frameTemplate!.data!) {
        if (pixel.a > 0) ogCard.setPixel(pixel.x, pixel.y, pixel);
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

      await File(Uri.file('$newTempIcePath/$ddsName.png').toFilePath()).writeAsBytes(img.encodePng(ogCard));

      await Process.run(modManDdsPngToolExePath, [Uri.file('$newTempIcePath/$ddsName.png').toFilePath(), Uri.file('$newTempIcePath/$ddsName.dds').toFilePath(), '-pngtodds']);
      await File(Uri.file('$newTempIcePath/$ddsName.png').toFilePath()).delete();
    }
  }

  if (File(Uri.file('$newTempIcePath/$ddsName.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}.ice').toFilePath()).rename(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath());
    return renamedFile;
  }
  return null;
}

Future<File?> cardIconArtReplace(img.Image? resizedIconImage, String iconIcePath, String iconDdsName, String squareIconWebPath) async {
  if (iconIcePath.isNotEmpty) {
    String newTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}/group2').toFilePath();
    Directory(newTempIconIcePath).createSync(recursive: true);

    if (Directory(newTempIconIcePath).existsSync()) {
      Dio dio = Dio();
      final returnedResult = await dio.download(squareIconWebPath, Uri.file('$newTempIconIcePath/${p.basename(squareIconWebPath)}').toFilePath());
      dio.close();

      if (returnedResult.statusCode == 200) {
        img.Image? ogCardIcon = await img.decodePngFile(Uri.file('$newTempIconIcePath/${p.basename(squareIconWebPath)}').toFilePath());
        img.Image? iconTemplate;
        if (kDebugMode) {
          iconTemplate = await img.decodePngFile('assets/img/line_strike_card_icon_template.png');
        } else {
          iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_icon_template.png').toFilePath());
        }

        for (var templatePixel in iconTemplate!.data!) {
          if (templatePixel.a > 0) {
            try {
              ogCardIcon!.setPixel(templatePixel.x, templatePixel.y, resizedIconImage!.getPixel(templatePixel.x - 11, templatePixel.y - 11));
            } catch (e) {
              break;
            }
          }
        }

        await File(Uri.file('$newTempIconIcePath/$iconDdsName.png').toFilePath()).writeAsBytes(img.encodePng(ogCardIcon!));

        await Process.run(modManDdsPngToolExePath, [Uri.file('$newTempIconIcePath/$iconDdsName.png').toFilePath(), Uri.file('$newTempIconIcePath/$iconDdsName.dds').toFilePath(), '-pngtodds']);
        await File(Uri.file('$newTempIconIcePath/$iconDdsName.png').toFilePath()).delete();
      }
    }

    if (File(Uri.file('$newTempIconIcePath/$iconDdsName.dds').toFilePath()).existsSync()) {
      await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath()]);
      Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath()).deleteSync(recursive: true);

      File renamedFile =
          await File(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}.ice').toFilePath()).rename(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath());
      return renamedFile;
    }
  }
  return null;
}
