// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

List<bool> _loading = [];
bool _isShowAll = true;
bool _dataLoaded = false;
int _curCardElement = -1;

void lineDuelCardsHomePage(context) {
  Future customCardsLoader = customCardsFetch();
  Future cardDataLoader = originalCardsFetch(context);
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
                                future: customCardsLoader,
                                builder: ((
                                  BuildContext context,
                                  AsyncSnapshot snapshot,
                                ) {
                                  if (snapshot.connectionState == ConnectionState.waiting && !_dataLoaded) {
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
                                          future: cardDataLoader,
                                          builder: ((
                                            BuildContext context,
                                            AsyncSnapshot snapshot,
                                          ) {
                                            if (snapshot.connectionState == ConnectionState.waiting && !_dataLoaded) {
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
                                                List<LineStrikeCard> allCardData = snapshot.data;
                                                List<LineStrikeCard> cardData = [];
                                                if (_isShowAll) {
                                                  cardData = allCardData;
                                                } else {
                                                  cardData = allCardData.where((e) => e.isReplaced).toList();
                                                }
                                                _dataLoaded = true;
                                                if (_loading.length != cardData.length) {
                                                  _loading = List.generate(cardData.length, (index) => false);
                                                }
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Text(curLangText!.uiCustomCardImages, style: Theme.of(context).textTheme.titleLarge),
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
                                                                            scale: 1.4,
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
                                                                                            allCustomBackgrounds[i].deleteSync();
                                                                                            allCustomBackgrounds.removeAt(i);
                                                                                            setState(() {});
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
                                                                curLangText!.uiLineStrikeCardImageInstruction,
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
                                                              ModManTooltip(
                                                                message: curLangText!.uiOpenExportedCardFolder,
                                                                child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await launchUrlString(modManLineStrikeExportedCardDirPath);
                                                                    },
                                                                    child: const Icon(Icons.folder_open)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () async {
                                                                      await launchUrlString(modManLineStrikeCardDirPath);
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
                                                                          customCardsLoader = customCardsFetch();
                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Text(curLangText!.uiCreateNewCard)),
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
                                                        Text(curLangText!.uiSwappedAvailableCards, style: Theme.of(context).textTheme.titleLarge),
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
                                                                                                cardData[i].cardZeroIconWebPath,
                                                                                                fit: BoxFit.fill,
                                                                                                filterQuality: FilterQuality.high,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(right: 15),
                                                                                              child: AspectRatio(
                                                                                                aspectRatio: 0.5,
                                                                                                child: Image.file(
                                                                                                  File(cardData[i].replacedImagePath),
                                                                                                  fit: BoxFit.fitWidth,
                                                                                                  alignment: Alignment.bottomCenter,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(right: 5),
                                                                                              child: ModManTooltip(
                                                                                                message: curLangText!.uiExportCustomizedCardToPng,
                                                                                                child: InkWell(
                                                                                                  child: Container(
                                                                                                    decoration: ShapeDecoration(
                                                                                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.4),
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                          side: BorderSide(color: Theme.of(context).hintColor),
                                                                                                          borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                                                    ),
                                                                                                    child: const Icon(
                                                                                                      Icons.image,
                                                                                                    ),
                                                                                                  ),
                                                                                                  onTap: () {
                                                                                                    lineDuelCardExportPopup(context, cardData[i]);
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(right: 15),
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
                                                                                                      saveLineStrikeCardInfoToJson(allCardData);
                                                                                                      if (File(cardData[i].cardZeroIcePath.replaceFirst(
                                                                                                              Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                          .existsSync()) {
                                                                                                        File(cardData[i].cardZeroIcePath.replaceFirst(
                                                                                                                Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                            .deleteSync(recursive: true);
                                                                                                      }
                                                                                                      if (File(cardData[i].cardZeroIconIcePath.replaceFirst(
                                                                                                              Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                          .existsSync()) {
                                                                                                        File(cardData[i].cardZeroIconIcePath.replaceFirst(
                                                                                                                Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                            .deleteSync(recursive: true);
                                                                                                      }
                                                                                                      if (File(cardData[i].cardOneIcePath.replaceFirst(
                                                                                                              Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                          .existsSync()) {
                                                                                                        File(cardData[i].cardOneIcePath.replaceFirst(
                                                                                                                Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                            .deleteSync(recursive: true);
                                                                                                      }
                                                                                                      if (File(cardData[i].cardOneIconIcePath.replaceFirst(
                                                                                                              Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                          .existsSync()) {
                                                                                                        File(cardData[i].cardOneIconIcePath.replaceFirst(
                                                                                                                Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                            .deleteSync(recursive: true);
                                                                                                      }
                                                                                                      for (var dir in Directory(modManLineStrikeCacheDirPath).listSync().whereType<Directory>()) {
                                                                                                        for (var subDir in dir.listSync().whereType<Directory>()) {
                                                                                                          if (subDir.listSync(recursive: true).whereType<File>().isEmpty) {
                                                                                                            subDir.deleteSync(recursive: true);
                                                                                                          }
                                                                                                        }
                                                                                                        if (dir.listSync(recursive: true).whereType<File>().isEmpty) dir.deleteSync(recursive: true);
                                                                                                      }
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
                                                                                      saveLineStrikeCardInfoToJson(allCardData);
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
                                                                                    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                      element.deleteSync(recursive: true);
                                                                                    });
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
                                                                    onPressed: cardData.where((e) => e.isReplaced).isNotEmpty || !_isShowAll
                                                                        ? () {
                                                                            if (!_isShowAll) {
                                                                              _isShowAll = true;
                                                                            } else {
                                                                              _isShowAll = false;
                                                                            }
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                          }
                                                                        : null,
                                                                    child: Text(_isShowAll ? curLangText!.uiShowSwapped : curLangText!.uiShowAll)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
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
                                                                                  saveLineStrikeCardInfoToJson(allCardData);
                                                                                  if (File(cardData[i]
                                                                                          .cardZeroIcePath
                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(cardData[i]
                                                                                            .cardZeroIcePath
                                                                                            .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  if (File(cardData[i]
                                                                                          .cardZeroIconIcePath
                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(cardData[i]
                                                                                            .cardZeroIconIcePath
                                                                                            .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  if (File(cardData[i]
                                                                                          .cardOneIcePath
                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(cardData[i]
                                                                                            .cardOneIcePath
                                                                                            .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  if (File(cardData[i]
                                                                                          .cardOneIconIcePath
                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(cardData[i]
                                                                                            .cardOneIconIcePath
                                                                                            .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  for (var dir in Directory(modManLineStrikeCacheDirPath).listSync().whereType<Directory>()) {
                                                                                    for (var subDir in dir.listSync().whereType<Directory>()) {
                                                                                      if (subDir.listSync(recursive: true).whereType<File>().isEmpty) subDir.deleteSync(recursive: true);
                                                                                    }
                                                                                    if (dir.listSync(recursive: true).whereType<File>().isEmpty) dir.deleteSync(recursive: true);
                                                                                  }
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
                                                                      // customCardsLoader = null;
                                                                      // cardDataLoader = null;

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
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
  TextEditingController newImageName = TextEditingController(text: '${p.basenameWithoutExtension(newImageFile.path)}_$formattedDate');
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
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value) .characters.last == '0')
      .toList();
  List<CsvItem> csvCardOneIconData = playerItemData
      .where((element) => element.csvFileName == 'Line Duel Icons.csv' && p.basenameWithoutExtension(element.infos.entries.firstWhere((element) => element.key == 'Path').value).characters.last == '1')
      .toList();

  //Load list from json
  List<LineStrikeCard> cardDataFromJson = [];
  bool refetchData = false;
  if (File(modManLineStrikeCardJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeCardJsonPath).readAsStringSync());
    for (var type in jsonData) {
      cardDataFromJson.add(LineStrikeCard.fromJson(type));
      if (!refetchData &&
          (!File(cardDataFromJson.last.cardZeroIcePath).existsSync() ||
              !File(cardDataFromJson.last.cardZeroIconIcePath).existsSync() ||
              !File(cardDataFromJson.last.cardOneIcePath).existsSync() ||
              !File(cardDataFromJson.last.cardOneIconIcePath).existsSync())) {
        refetchData = true;
      }
    }
  }

  List<LineStrikeCard> newCardInfoList = [];
  if (refetchData || csvCardZeroData.length > cardDataFromJson.length) {
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

    // //replace settings
    for (var cardInJson in cardDataFromJson.where((e) => e.isReplaced)) {
      int index = newCardInfoList.indexWhere((e) => p.basename(e.cardZeroIcePath) == p.basename(cardInJson.cardZeroIcePath) && p.basename(e.cardOneIcePath) == p.basename(cardInJson.cardOneIcePath));
      if (index != -1) {
        newCardInfoList[index].replacedImagePath = cardInJson.replacedImagePath;
        newCardInfoList[index].cardZeroReplacedIceMd5 = cardInJson.cardZeroReplacedIceMd5;
        newCardInfoList[index].cardZeroReplacedIconIceMd5 = cardInJson.cardZeroReplacedIconIceMd5;
        newCardInfoList[index].cardOneReplacedIceMd5 = cardInJson.cardOneReplacedIceMd5;
        newCardInfoList[index].cardOneReplacedIconIceMd5 = cardInJson.cardOneReplacedIconIceMd5;
        newCardInfoList[index].isReplaced = cardInJson.isReplaced;
      }
    }
  } else {
    newCardInfoList = cardDataFromJson;
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
  _curCardElement = -1;
  clearAllTempDirs();
  //prep image
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedIconImage = img.copyResize(replaceImage!, width: 104, height: 104);

  //download and replace
  //card zero replacement
  String cardZeroImageHash = '';
  File? replacedCardZeroIce;
  String newCardZeroTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardZeroIcePath)}/group2').toFilePath();
  Directory(newCardZeroTempIcePath).createSync(recursive: true);
  if (Directory(newCardZeroTempIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(cardDataFile.cardZeroIconWebPath, Uri.file('$newCardZeroTempIcePath/${p.basename(cardDataFile.cardZeroIconWebPath)}').toFilePath());
    dio.close();

    if (returnedResult.statusCode == 200) {
      cardZeroImageHash = await getFileHash(Uri.file('$newCardZeroTempIcePath/${p.basename(cardDataFile.cardZeroIconWebPath)}').toFilePath());
      replacedCardZeroIce = await cardArtReplace(
          context, replaceImage, cardDataFile.cardZeroIcePath, cardDataFile.cardZeroDdsName, Uri.file('$newCardZeroTempIcePath/${p.basename(cardDataFile.cardZeroIconWebPath)}').toFilePath());

      if (replacedCardZeroIce != null && replacedCardZeroIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copied = replacedCardZeroIce.copySync(cardDataFile.cardZeroIcePath);
            //cache
            String cachePath = cardDataFile.cardZeroIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardZeroIce.copySync(cachePath);
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

      if (replacedCardZeroIce == null) return false;
    }
  }

  //card one replacement
  String newCardOneTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardOneIcePath)}/group2').toFilePath();
  Directory(newCardOneTempIcePath).createSync(recursive: true);
  if (Directory(newCardOneTempIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(cardDataFile.cardOneIconWebPath, Uri.file('$newCardOneTempIcePath/${p.basename(cardDataFile.cardOneIconWebPath)}').toFilePath());
    dio.close();

    if (returnedResult.statusCode == 200) {
      File? replacedCardOneIce;
      if (cardZeroImageHash != await getFileHash(Uri.file('$newCardOneTempIcePath/${p.basename(cardDataFile.cardOneIconWebPath)}').toFilePath())) {
        replacedCardOneIce = await cardArtReplace(
            context, replaceImage, cardDataFile.cardOneIcePath, cardDataFile.cardOneDdsName, Uri.file('$newCardOneTempIcePath/${p.basename(cardDataFile.cardOneIconWebPath)}').toFilePath());
      } else {
        await Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardOneIcePath)}').toFilePath()).delete(recursive: true);
        replacedCardOneIce = await replacedCardZeroIce!.copy(replacedCardZeroIce.path.replaceFirst(p.basename(cardDataFile.cardOneIcePath), cardDataFile.cardOneIcePath));
      }
      _curCardElement = -1;
      if (replacedCardOneIce != null && replacedCardOneIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copied = replacedCardOneIce.copySync(cardDataFile.cardOneIcePath);
            //cache
            String cachePath = cardDataFile.cardOneIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardOneIce.copySync(cachePath);
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

      if (replacedCardOneIce == null) return false;
    }
  }

  //icon zero replacement
  String cardZeroIconImageHash = '';
  File? replacedCardZeroIconIce;
  String newCardZeroTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardZeroIconIcePath)}/group2').toFilePath();
  Directory(newCardZeroTempIconIcePath).createSync(recursive: true);

  if (Directory(newCardZeroTempIconIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(cardDataFile.cardZeroSquareIconWebPath, Uri.file('$newCardZeroTempIconIcePath/${p.basename(cardDataFile.cardZeroSquareIconWebPath)}').toFilePath());
    dio.close();
    if (returnedResult.statusCode == 200) {
      cardZeroIconImageHash = await getFileHash(Uri.file('$newCardZeroTempIconIcePath/${p.basename(cardDataFile.cardZeroSquareIconWebPath)}').toFilePath());
      replacedCardZeroIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardZeroIconIcePath, cardDataFile.cardZeroIconDdsName,
          Uri.file('$newCardZeroTempIconIcePath/${p.basename(cardDataFile.cardZeroSquareIconWebPath)}').toFilePath());
      if (replacedCardZeroIconIce != null && replacedCardZeroIconIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copied = replacedCardZeroIconIce.copySync(cardDataFile.cardZeroIconIcePath);
            //cache
            String cachePath = cardDataFile.cardZeroIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardZeroIconIce.copySync(cachePath);
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
    }
  }

  //icon one replacement
  String newCardOneTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardOneIconIcePath)}/group2').toFilePath();
  Directory(newCardOneTempIconIcePath).createSync(recursive: true);

  if (Directory(newCardOneTempIconIcePath).existsSync()) {
    Dio dio = Dio();
    final returnedResult = await dio.download(cardDataFile.cardOneSquareIconWebPath, Uri.file('$newCardOneTempIconIcePath/${p.basename(cardDataFile.cardOneSquareIconWebPath)}').toFilePath());
    dio.close();
    if (returnedResult.statusCode == 200) {
      File? replacedCardOneIconIce;
      if (cardZeroIconImageHash != await getFileHash(Uri.file('$newCardOneTempIconIcePath/${p.basename(cardDataFile.cardOneSquareIconWebPath)}').toFilePath())) {
        replacedCardOneIconIce = await cardIconArtReplace(resizedIconImage, cardDataFile.cardOneIconIcePath, cardDataFile.cardOneIconDdsName, cardDataFile.cardOneSquareIconWebPath);
      } else {
        await Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(cardDataFile.cardOneIconIcePath)}').toFilePath()).delete(recursive: true);
        replacedCardOneIconIce = await replacedCardZeroIconIce!.copy(replacedCardZeroIconIce.path.replaceFirst(p.basename(cardDataFile.cardOneIconIcePath), cardDataFile.cardOneIconIcePath));
      }
      if (replacedCardOneIconIce != null && replacedCardOneIconIce.existsSync()) {
        int i = 0;
        while (i < 10) {
          try {
            File copied = replacedCardOneIconIce.copySync(cardDataFile.cardOneIconIcePath);
            //cache
            String cachePath = cardDataFile.cardOneIconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
            File(cachePath).parent.createSync(recursive: true);
            replacedCardOneIconIce.copySync(cachePath);
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
    }
  }

  return true;
}

Future<File?> cardArtReplace(context, img.Image? replaceImage, String icePath, String ddsName, String downloadedIconWebPath) async {
  if (File(downloadedIconWebPath).existsSync()) {
    //edit
    img.Image? ogCard = await img.decodePngFile(downloadedIconWebPath);
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
    } else {
      if (_curCardElement == -1) {
        _curCardElement = await lineDuelCardElementSelection(context);
      }
      if (_curCardElement == 0) {
        //dark
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_dark_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_dark_frame0_template.png').toFilePath());
        }
      } else if (_curCardElement == 1) {
        //fire
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_fire_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_fire_frame0_template.png').toFilePath());
        }
      } else if (_curCardElement == 2) {
        //ice
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_ice_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_ice_frame0_template.png').toFilePath());
        }
      } else if (_curCardElement == 3) {
        //light
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_light_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_light_frame0_template.png').toFilePath());
        }
      } else if (_curCardElement == 4) {
        //lightning
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_lightning_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_lightning_frame0_template.png').toFilePath());
        }
      } else if (_curCardElement == 5) {
        //wind
        if (kDebugMode) {
          frameTemplate = await img.decodePngFile('assets/img/line_strike_card_wind_frame0_template.png');
        } else {
          frameTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_card_wind_frame0_template.png').toFilePath());
        }
      } else {
        _curCardElement = -1;
        return null;
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

    await File(Uri.file(downloadedIconWebPath).toFilePath()).writeAsBytes(img.encodePng(ogCard));

    await Process.run(modManDdsPngToolExePath, [Uri.file(downloadedIconWebPath).toFilePath(), Uri.file('${File(downloadedIconWebPath).parent.path}/$ddsName.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file(downloadedIconWebPath).toFilePath()).delete();

    if (File(Uri.file('${File(downloadedIconWebPath).parent.path}/$ddsName.dds').toFilePath()).existsSync()) {
      await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath()]);
      Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath()).deleteSync(recursive: true);

      File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}.ice').toFilePath()).rename(Uri.file('$modManAddModsTempDirPath/${p.basename(icePath)}').toFilePath());
      return renamedFile;
    }
  }

  _curCardElement = -1;
  return null;
}

Future<File?> cardIconArtReplace(img.Image? resizedIconImage, String iconIcePath, String iconDdsName, String downloadedSquareIconWebPath) async {
  if (iconIcePath.isNotEmpty) {
    if (File(downloadedSquareIconWebPath).existsSync()) {
      img.Image? ogCardIcon = await img.decodePngFile(Uri.file(downloadedSquareIconWebPath).toFilePath());
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

      await File(Uri.file(downloadedSquareIconWebPath).toFilePath()).writeAsBytes(img.encodePng(ogCardIcon!));

      await Process.run(modManDdsPngToolExePath,
          [Uri.file(downloadedSquareIconWebPath).toFilePath(), Uri.file(downloadedSquareIconWebPath.replaceFirst(p.extension(downloadedSquareIconWebPath), '.dds')).toFilePath(), '-pngtodds']);
      await File(Uri.file(downloadedSquareIconWebPath).toFilePath()).delete();
    }

    if (File(Uri.file(downloadedSquareIconWebPath.replaceFirst(p.extension(downloadedSquareIconWebPath), '.dds')).toFilePath()).existsSync()) {
      await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath()]);
      Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath()).deleteSync(recursive: true);

      File renamedFile =
          await File(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}.ice').toFilePath()).rename(Uri.file('$modManAddModsTempDirPath/${p.basename(iconIcePath)}').toFilePath());
      return renamedFile;
    }
  }
  return null;
}

Future<File?> cardExport(LineStrikeCard card) async {
  Directory(modManAddModsTempDirPath).createSync(recursive: true);
  File cachedIce = File(card.cardZeroIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath));
  if (cachedIce.existsSync()) {
    final copiedIce = await cachedIce.copy(cachedIce.path.replaceFirst(cachedIce.parent.path, modManAddModsTempDirPath));
    await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [copiedIce.path]);
    File ddsFile = File(Uri.file('$modManAddModsTempDirPath/${p.basename(copiedIce.path)}_ext/group2/${card.cardZeroDdsName}.dds').toFilePath());
    if (ddsFile.existsSync()) {
      await Process.run(modManDdsPngToolExePath, [ddsFile.path, ddsFile.path.replaceFirst(p.extension(ddsFile.path), '.png'), '-ddstopng']);
      img.Image? pngFile = await img.decodePngFile(ddsFile.path.replaceFirst(p.extension(ddsFile.path), '.png'));

      img.Image croppedImage = img.copyCrop(
        pngFile!,
        x: 1,
        y: 0,
        width: 367,
        height: 512,
      );
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('MM-dd-yyyy-kk-mm-ss').format(now);
      File exportedFile = await File(Uri.file('$modManLineStrikeExportedCardDirPath/${card.cardZeroDdsName}_$formattedDate.png').toFilePath()).writeAsBytes(img.encodePng(croppedImage));
      if (exportedFile.existsSync()) return exportedFile;
    }
  }
  return null;
}

Future<void> lineDuelCardExportPopup(context, LineStrikeCard card) async {
  File? exportedImage;
  bool exported = false;
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                title: Text(curLangText!.uiCardExport, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 10, right: 10),
                content: SizedBox(
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (exported && exportedImage == null) const CircularProgressIndicator(),
                        if (exported)
                          Text(
                            exported && exportedImage == null
                                ? curLangText!.uiFailed
                                : exported && exportedImage != null && exportedImage!.existsSync()
                                    ? curLangText!.uiSuccess
                                    : '',
                            style: const TextStyle(fontSize: 18),
                          ),
                        if (exported) const SizedBox(height: 10),
                        if (!exported && exportedImage == null) Text(card.cardZeroDdsName),
                        if (exported && exportedImage != null && exportedImage!.existsSync()) Text(p.basename(exportedImage!.path)),
                      ],
                    )),
                actionsPadding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        exported = false;
                        Navigator.pop(context);
                      }),
                  if (exported && exportedImage!.existsSync())
                    ElevatedButton(
                        onPressed: () async {
                          await launchUrlString(modManLineStrikeExportedCardDirPath);
                        },
                        child: Text(curLangText!.uiOpenInFileExplorer)),
                  if (!exported || exportedImage == null)
                    ElevatedButton(
                        onPressed: () async {
                          exported = true;
                          exportedImage = await cardExport(card);
                          Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                            element.deleteSync(recursive: true);
                          });
                          setState(
                            () {},
                          );
                        },
                        child: Text(curLangText!.uiExport)),
                ]);
          }));
}

Future<int> lineDuelCardElementSelection(context) async {
  String? selectedType;
  int selectedIndex = -1;
  List<String> cardElements = [curLangText!.uiCardDark, curLangText!.uiCardFire, curLangText!.uiCardIce, curLangText!.uiCardLight, curLangText!.uiCardLightning, curLangText!.uiCardWind];
  return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
                backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                titlePadding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                title: Text(curLangText!.uiCardElementSelect, style: const TextStyle(fontWeight: FontWeight.w700)),
                contentPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                content: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(curLangText!.uiUnableToDetectTheElementOfThisCard),
                        ),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2(
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(curLangText!.uiCardElement),
                          ),
                          buttonStyleData: ButtonStyleData(
                            width: 200,
                            height: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Theme.of(context).hintColor,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: windowsHeight * 0.5,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                          iconStyleData: const IconStyleData(iconSize: 15),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 25,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          isDense: true,
                          items: cardElements
                              .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // if (curActiveLang != 'JP')
                                      Container(
                                        padding: const EdgeInsets.only(bottom: 3),
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                              //fontSize: 14,
                                              //fontWeight: FontWeight.bold,
                                              //color: Colors.white,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )))
                              .toList(),
                          value: selectedType,
                          onChanged: (value) async {
                            selectedType = value.toString();
                            if (selectedType != null) {
                              selectedIndex = cardElements.indexOf(selectedType!);
                            }
                            setState(() {});
                          },
                        )),
                      ],
                    )),
                actionsPadding: const EdgeInsets.all(10),
                actions: <Widget>[
                  ElevatedButton(
                      child: Text(curLangText!.uiReturn),
                      onPressed: () {
                        Navigator.pop(context, -1);
                      }),
                  ElevatedButton(
                      onPressed: selectedType == null
                          ? null
                          : () {
                              Navigator.pop(context, selectedIndex);
                            },
                      child: Text(curLangText!.uiNext))
                ]);
          }));
}
