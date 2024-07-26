// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/line_strike_board_class.dart';
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

List<bool> _loading = [];
bool _isShowAll = true;

void lineDuelBoardsHomePage(context) {
  Future? boardDataLoader = originalBoardsFetch(context);
  Future? customBoardsLoader = customBoardsFetch();
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
                                future: customBoardsLoader,
                                builder: ((
                                  BuildContext context,
                                  AsyncSnapshot snapshot,
                                ) {
                                  if (snapshot.connectionState == ConnectionState.waiting && customBoardsLoader == null) {
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
                                          future: boardDataLoader,
                                          builder: ((
                                            BuildContext context,
                                            AsyncSnapshot snapshot,
                                          ) {
                                            if (snapshot.connectionState == ConnectionState.waiting && boardDataLoader == null) {
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
                                                List<LineStrikeBoard> allBoardData = snapshot.data;
                                                List<LineStrikeBoard> boardData = [];
                                                if (_isShowAll) {
                                                  boardData = allBoardData;
                                                } else {
                                                  boardData = allBoardData.where((e) => e.isReplaced).toList();
                                                }
                                                if (_loading.length != boardData.length) {
                                                  _loading = List.generate(boardData.length, (index) => false);
                                                }
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Text(curLangText!.uiCustomBoardImages, style: Theme.of(context).textTheme.titleLarge),
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
                                                                          crossAxisCount: 2, childAspectRatio: 867 / 488, mainAxisSpacing: 5, crossAxisSpacing: 5),
                                                                      shrinkWrap: true,
                                                                      //physics: const PageScrollPhysics(),
                                                                      itemCount: allCustomBackgrounds.length,
                                                                      itemBuilder: (context, i) {
                                                                        Offset pointerDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset position) {
                                                                          return Offset.zero;
                                                                        }

                                                                        return Draggable(
                                                                          dragAnchorStrategy: pointerDragAnchorStrategy,
                                                                          feedback: ConstrainedBox(
                                                                            constraints: const BoxConstraints(maxHeight: 512 / 2, maxWidth: 1024 / 2),
                                                                            child: Image.file(
                                                                              allCustomBackgrounds[i],
                                                                              filterQuality: FilterQuality.high,
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                          // ),
                                                                          data: allCustomBackgrounds[i].path,
                                                                          child: Stack(
                                                                            alignment: AlignmentDirectional.bottomStart,
                                                                            children: [
                                                                              AspectRatio(
                                                                                aspectRatio: 867 / 488,
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
                                                                                    onLongPress: boardData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                                        color: boardData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                curLangText!.uiLineStrikeBoardImageInstruction,
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
                                                                    await customBoardsFetch();
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
                                                                      await launchUrl(Uri.file(modManLineStrikeBoardDirPath));
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
                                                                        customBoardImageCropDialog(context, File(selectedImage.path)).then((value) {
                                                                          customBoardsLoader = customBoardsFetch();
                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Text(curLangText!.uiCreateNewBoard)),
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
                                                        Text(curLangText!.uiSwappedAvailableBoards, style: Theme.of(context).textTheme.titleLarge),
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
                                                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 256 / 137, mainAxisSpacing: 5),
                                                                      // itemBuilder: (BuildContext context, int index) {
                                                                      //   return const SizedBox(height: 4);
                                                                      // },
                                                                      shrinkWrap: true,
                                                                      itemCount: boardData.length,
                                                                      itemBuilder: (context, i) {
                                                                        return DragTarget(
                                                                          builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                                                            return Center(
                                                                              child: boardData[i].isReplaced
                                                                                  ? Stack(
                                                                                      alignment: AlignmentDirectional.bottomEnd,
                                                                                      children: [
                                                                                        Stack(
                                                                                          alignment: AlignmentDirectional.bottomEnd,
                                                                                          children: [
                                                                                            AspectRatio(
                                                                                              aspectRatio: 256 / 137,
                                                                                              child: Image.network(
                                                                                                boardData[i].iconWebPath,
                                                                                                fit: BoxFit.fitWidth,
                                                                                                filterQuality: FilterQuality.high,
                                                                                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                                                  'assets/img/placeholdersquare.png',
                                                                                                  filterQuality: FilterQuality.none,
                                                                                                  fit: BoxFit.fitWidth,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            AspectRatio(
                                                                                              aspectRatio: 1.2,
                                                                                              child: Image.file(
                                                                                                File(boardData[i].replacedImagePath),
                                                                                                fit: BoxFit.fitWidth,
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
                                                                                                    boardData[i].icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                                    boardData[i].iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                    modManAddModsTempDirPath);
                                                                                                try {
                                                                                                  File(downloadedIceFilePath).copySync(boardData[i].icePath);
                                                                                                  File(downloadedIconIceFilePath).copySync(boardData[i].iconIcePath);
                                                                                                  boardData[i].replacedIceMd5 = '';
                                                                                                  boardData[i].replacedIconIceMd5 = '';
                                                                                                  boardData[i].replacedImagePath = '';
                                                                                                  boardData[i].isReplaced = false;
                                                                                                  saveLineStrikeBoardInfoToJson(boardData);
                                                                                                  if (File(boardData[i]
                                                                                                          .icePath
                                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                      .existsSync()) {
                                                                                                    File(boardData[i].icePath.replaceFirst(
                                                                                                            Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                        .deleteSync(recursive: true);
                                                                                                  }
                                                                                                  if (File(boardData[i]
                                                                                                          .iconIcePath
                                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                                      .existsSync()) {
                                                                                                    File(boardData[i].iconIcePath.replaceFirst(
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
                                                                                                } catch (e) {
                                                                                                  // ignore: use_build_context_synchronously
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                      // ignore: use_build_context_synchronously
                                                                                                      context,
                                                                                                      '${curLangText!.uiFailed}!',
                                                                                                      '${p.basename(boardData[i].icePath)}\n${p.basename(boardData[i].iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
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
                                                                                          aspectRatio: 256 / 137,
                                                                                          child: Image.network(
                                                                                            boardData[i].iconWebPath,
                                                                                            filterQuality: FilterQuality.high,
                                                                                            fit: BoxFit.fitWidth,
                                                                                            errorBuilder: (context, error, stackTrace) => Image.asset(
                                                                                              'assets/img/placeholdersquare.png',
                                                                                              filterQuality: FilterQuality.none,
                                                                                              fit: BoxFit.fitWidth,
                                                                                            ),
                                                                                          ),
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
                                                                                  customBoardApply(context, imgPath, boardData[i]).then((value) {
                                                                                    if (value) {
                                                                                      boardData[i].replacedImagePath = imgPath;
                                                                                      boardData[i].isReplaced = true;
                                                                                      saveLineStrikeBoardInfoToJson(boardData);
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
                                                                    onPressed: boardData.where((e) => e.isReplaced).isNotEmpty || !_isShowAll
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
                                                                    onLongPress: boardData.where((element) => element.isReplaced).isEmpty
                                                                        ? null
                                                                        : () async {
                                                                            if (Directory(modManAddModsTempDirPath).existsSync()) {
                                                                              Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                element.deleteSync(recursive: true);
                                                                              });
                                                                            }
                                                                            for (var board in boardData) {
                                                                              if (board.isReplaced) {
                                                                                int index = boardData.indexOf(board);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      board.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      board.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  try {
                                                                                    File(downloadedIceFilePath).copySync(board.icePath);
                                                                                    File(downloadedIconIceFilePath).copySync(board.iconIcePath);
                                                                                    board.replacedIceMd5 = '';
                                                                                    board.replacedIconIceMd5 = '';
                                                                                    board.replacedImagePath = '';
                                                                                    board.isReplaced = false;
                                                                                    saveLineStrikeBoardInfoToJson(boardData);
                                                                                    if (File(board.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .existsSync()) {
                                                                                      File(board.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                          .deleteSync(recursive: true);
                                                                                    }
                                                                                    if (File(board.iconIcePath
                                                                                            .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .existsSync()) {
                                                                                      File(board.iconIcePath
                                                                                              .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                          .deleteSync(recursive: true);
                                                                                    }
                                                                                    for (var dir in Directory(modManLineStrikeCacheDirPath).listSync().whereType<Directory>()) {
                                                                                      for (var subDir in dir.listSync().whereType<Directory>()) {
                                                                                        if (subDir.listSync(recursive: true).whereType<File>().isEmpty) subDir.deleteSync(recursive: true);
                                                                                      }
                                                                                      if (dir.listSync(recursive: true).whereType<File>().isEmpty) dir.deleteSync(recursive: true);
                                                                                    }
                                                                                  } catch (e) {
                                                                                    // ignore: use_build_context_synchronously
                                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                        // ignore: use_build_context_synchronously
                                                                                        context,
                                                                                        '${curLangText!.uiFailed}!',
                                                                                        '${p.basename(board.icePath)}\n${p.basename(board.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}',
                                                                                        5000));
                                                                                  }
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                int index = boardData.indexOf(board);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedIceFilePath = await downloadIconIceFromOfficial(
                                                                                      board.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(
                                                                                      board.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  File(downloadedIceFilePath).copySync(board.icePath);
                                                                                  File(downloadedIconIceFilePath).copySync(board.icePath);
                                                                                  if (File(board.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(board.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  if (File(board.iconIcePath
                                                                                          .replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                      .existsSync()) {
                                                                                    File(board.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath))
                                                                                        .deleteSync(recursive: true);
                                                                                  }
                                                                                  for (var dir in Directory(modManLineStrikeCacheDirPath).listSync().whereType<Directory>()) {
                                                                                    for (var subDir in dir.listSync().whereType<Directory>()) {
                                                                                      if (subDir.listSync(recursive: true).whereType<File>().isEmpty) subDir.deleteSync(recursive: true);
                                                                                    }
                                                                                    if (dir.listSync(recursive: true).whereType<File>().isEmpty) dir.deleteSync(recursive: true);
                                                                                  }
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            }
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                          },
                                                                    onPressed: boardData.where((element) => element.isReplaced).isEmpty ? null : () {},
                                                                    child: Text(curLangText!.uiRestoreAll)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () {
                                                                      customBoardsLoader = null;
                                                                      boardDataLoader = null;

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
Future<bool> customBoardImageCropDialog(context, File newImageFile) async {
  final imageCropController = CropController(
    aspectRatio: 867 / 488,
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
                        if (Directory(modManLineStrikeBoardDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
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
                                img.Image resized = img.copyResize(image!, width: 867, height: 488);

                                File croppedImage = File(Uri.file('$modManLineStrikeBoardDirPath/${newImageName.text}.png').toFilePath());
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
                              img.Image resized = img.copyResize(image!, width: 867, height: 488);

                              File croppedImage = File(Uri.file('$modManLineStrikeBoardDirPath/${newImageName.text}.png').toFilePath());
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

Future<List<LineStrikeBoard>> originalBoardsFetch(context) async {
  //Load vg from playerItemdata
  if (playerItemData.isEmpty) {
    await playerItemDataGet(context);
  }
  List<CsvItem> boardData = playerItemData.where((element) => element.csvFileName == 'Line Duel Boards.csv').toList();

  //Load list from json
  List<LineStrikeBoard> boardDataFromJson = [];
  bool refetchData = false;
  if (File(modManLineStrikeBoardJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManLineStrikeBoardJsonPath).readAsStringSync());
    for (var type in jsonData) {
      boardDataFromJson.add(LineStrikeBoard.fromJson(type));
      if (!refetchData && (!File(boardDataFromJson.last.icePath).existsSync() || !File(boardDataFromJson.last.iconIcePath).existsSync())) {
        refetchData = true;
      }
    }
  }

  List<LineStrikeBoard> newBoardInfoList = [];
  if (refetchData || boardData.length > boardDataFromJson.length) {
    for (var data in boardData) {
      String icePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash').value.split('\\').last);
      String iconIcePath = ogVitalGaugeIcePathsFetcher(data.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last);
      String iceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'IcePath').value.split('/').last);
      String iconIceDdsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'ImagePath').value.split('/').last);
      String iconWebPath = '$modManMAIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
      newBoardInfoList.add(LineStrikeBoard(icePath, iconIcePath, iceDdsName, iconIceDdsName, iconWebPath, '', '', '', false));
      await Future.delayed(const Duration(milliseconds: 10));
    }

    //replace settings
    for (var sleeveInJson in boardDataFromJson.where((e) => e.isReplaced)) {
      int i = newBoardInfoList.indexWhere((e) => p.basename(e.icePath) == p.basename(sleeveInJson.icePath) && p.basename(e.iconIcePath) == p.basename(sleeveInJson.iconIcePath));
      if (i != -1) {
        newBoardInfoList[i].replacedImagePath = sleeveInJson.replacedImagePath;
        newBoardInfoList[i].replacedIceMd5 = sleeveInJson.replacedIceMd5;
        newBoardInfoList[i].replacedIconIceMd5 = sleeveInJson.replacedIconIceMd5;
        newBoardInfoList[i].isReplaced = sleeveInJson.isReplaced;
      }
    }
  } else {
    newBoardInfoList = boardDataFromJson;
  }

  saveLineStrikeBoardInfoToJson(newBoardInfoList);

  return newBoardInfoList;
}

Future<List<File>> customBoardsFetch() async {
  List<File> returnList = [];
  //remove local originals
  returnList = Directory(modManLineStrikeBoardDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
  return returnList;
}

Future<bool> customBoardApply(context, String imgPath, LineStrikeBoard boardDataFile) async {
  clearAllTempDirs();
  //prep image
  img.Image? iconTemplate;
  img.Image? boardTemplate;
  if (kDebugMode) {
    iconTemplate = await img.decodePngFile('assets/img/line_strike_board_icon_template.png');
    boardTemplate = await img.decodePngFile('assets/img/line_strike_board_template.png');
  } else {
    iconTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_board_icon_template.png').toFilePath());
    boardTemplate = await img.decodePngFile(Uri.file('${Directory.current.path}/data/flutter_assets/assets/img/line_strike_board_template.png').toFilePath());
  }
  img.Image? replaceImage = await img.decodePngFile(imgPath);
  img.Image resizedReplaceIconImage = img.copyResize(replaceImage!, width: 226, height: 128);

  //download and replace
  //icon
  String downloadedIconIceFilePath = await downloadIconIceFromOfficial(boardDataFile.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIconIceFilePath]);
  String newTempIconIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext/group2').toFilePath();

  if (Directory(newTempIconIcePath).existsSync()) {
    await Process.run(modManDdsPngToolExePath,
        [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), '-ddstopng']);
    img.Image? iconImage = await img.decodePngFile(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath());
    for (var templatePixel in iconTemplate!.data!) {
      if (templatePixel.a > 0) {
        try {
          iconImage!.setPixel(templatePixel.x, templatePixel.y, resizedReplaceIconImage.getPixel(templatePixel.x - 15, templatePixel.y - 64));
          // debugPrint(resizedReplaceIconImage.getPixel(templatePixel.x - 37, templatePixel.y - 64).toString());
        } catch (e) {
          break;
        }
      }
    }

    await File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(iconImage!));

    await Process.run(modManDdsPngToolExePath,
        [Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath(), Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIconIcePath/${boardDataFile.iconIceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.iconIcePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.iconIcePath)}_ext.ice').toFilePath())
        .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.iconIcePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(boardDataFile.iconIcePath);
          //cache
          String cachePath = boardDataFile.iconIcePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          boardDataFile.replacedIconIceMd5 = await getFileHash(copied.path);
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(boardDataFile.iconIcePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
        return false;
      }
    }

    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  //board
  // String downloadedIceFilePath = await downloadIconIceFromOfficial(boardDataFile.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
  // await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedIceFilePath]);
  String newTempIcePath = Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.icePath)}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);

  if (Directory(newTempIcePath).existsSync()) {
    // await Process.run(
    //     modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath(), Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath(), '-ddstopng']);
    // img.Image? iceImage = await img.decodePngFile(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath());
    for (var templatePixel in boardTemplate!.data!) {
      if (templatePixel.a > 0) {
        try {
          templatePixel.set(replaceImage.getPixel(templatePixel.x - 77, templatePixel.y - 12));
          // iceImage!.setPixel(templatePixel.x, templatePixel.y, replaceImage.getPixel(templatePixel.x, templatePixel.y));
        } catch (e) {
          break;
        }
      }
    }

    await File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath()).writeAsBytes(img.encodePng(boardTemplate));

    await Process.run(
        modManDdsPngToolExePath, [Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath(), Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath(), '-pngtodds']);
    await File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.png').toFilePath()).delete();
  }

  if (File(Uri.file('$newTempIcePath/${boardDataFile.iceDdsName}.dds').toFilePath()).existsSync()) {
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.icePath)}.ice').toFilePath())
        .rename(Uri.file('$modManAddModsTempDirPath/${p.basename(boardDataFile.icePath)}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(boardDataFile.icePath);
          //cache
          String cachePath = boardDataFile.icePath.replaceFirst(Uri.file('$modManPso2binPath/data').toFilePath(), modManLineStrikeCacheDirPath);
          File(cachePath).parent.createSync(recursive: true);
          renamedFile.copySync(cachePath);
          boardDataFile.replacedIceMd5 = await getFileHash(copied.path);
          i = 10;
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${p.basename(boardDataFile.icePath)}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
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
