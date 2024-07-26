import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
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

void vitalGaugeHomePage(context) {
  Future? vitalgaugeDataLoader = originalVitalBackgroundsFetching(context);
  Future? allCustomBackgroundsLoader = customVitalBackgroundsFetching();
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
                            child: FutureBuilder(
                                future: allCustomBackgroundsLoader,
                                builder: ((
                                  BuildContext context,
                                  AsyncSnapshot snapshot,
                                ) {
                                  if (snapshot.connectionState == ConnectionState.waiting && allCustomBackgroundsLoader == null) {
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
                                          future: vitalgaugeDataLoader,
                                          builder: ((
                                            BuildContext context,
                                            AsyncSnapshot snapshot,
                                          ) {
                                            if (snapshot.connectionState == ConnectionState.waiting && vitalgaugeDataLoader == null) {
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
                                                List<VitalGaugeBackground> allVgData = snapshot.data;
                                                List<VitalGaugeBackground> vgData = [];
                                                if (_isShowAll) {
                                                  vgData = allVgData;
                                                } else {
                                                  vgData = allVgData.where((e) => e.isReplaced).toList();
                                                }
                                                if (_loading.length != vgData.length) {
                                                  _loading = List.generate(vgData.length, (index) => false);
                                                }
                                                return Row(
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      children: [
                                                        Text(curLangText!.uiCustomBackgrounds, style: Theme.of(context).textTheme.titleLarge),
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
                                                                  child: ListView.separated(
                                                                      separatorBuilder: (BuildContext context, int index) {
                                                                        return const SizedBox(height: 4);
                                                                      },
                                                                      shrinkWrap: true,
                                                                      //physics: const PageScrollPhysics(),
                                                                      itemCount: allCustomBackgrounds.length,
                                                                      itemBuilder: (context, i) {
                                                                        Offset pointerDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset position) {
                                                                          return Offset.zero;
                                                                        }

                                                                        return Draggable(
                                                                          dragAnchorStrategy: pointerDragAnchorStrategy,
                                                                          feedback: Container(
                                                                            width: 483,
                                                                            height: 100,
                                                                            decoration: ShapeDecoration(
                                                                                shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                            child: Image.file(
                                                                              allCustomBackgrounds[i],
                                                                              filterQuality: FilterQuality.high,
                                                                              fit: BoxFit.fill,
                                                                            ),
                                                                          ),
                                                                          data: allCustomBackgrounds[i].path,
                                                                          child: Stack(
                                                                            alignment: AlignmentDirectional.bottomStart,
                                                                            children: [
                                                                              AspectRatio(
                                                                                aspectRatio: 29 / 6,
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
                                                                                    onLongPress: vgData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                                        color: vgData.indexWhere((element) => element.replacedImagePath == allCustomBackgrounds[i].path) != -1
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
                                                                    await customVitalBackgroundsFetching();
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
                                                                      await launchUrl(Uri.file(modManVitalGaugeDirPath));
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
                                                                        vitalGaugeImageCropDialog(context, File(selectedImage.path)).then((value) {
                                                                          allCustomBackgroundsLoader = customVitalBackgroundsFetching();
                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Text(curLangText!.uiCreateBackground)),
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
                                                        Text(curLangText!.uiSwappedAvailableBackgrounds, style: Theme.of(context).textTheme.titleLarge),
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
                                                                  child: ListView.separated(
                                                                      separatorBuilder: (BuildContext context, int index) {
                                                                        return const SizedBox(height: 4);
                                                                      },
                                                                      shrinkWrap: true,
                                                                      itemCount: vgData.length,
                                                                      itemBuilder: (context, i) {
                                                                        return DragTarget(
                                                                          builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                                                            return Center(
                                                                              child: vgData[i].isReplaced
                                                                                  ? AspectRatio(
                                                                                      aspectRatio: 29 / 6,
                                                                                      child: Container(
                                                                                        decoration: ShapeDecoration(
                                                                                            shape: RoundedRectangleBorder(
                                                                                                side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                                borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                                        child: Stack(
                                                                                          alignment: AlignmentDirectional.bottomStart,
                                                                                          children: [
                                                                                            Stack(
                                                                                              fit: StackFit.expand,
                                                                                              children: [
                                                                                                Image.network(
                                                                                                  vgData[i].pngPath,
                                                                                                  fit: BoxFit.fill,
                                                                                                  filterQuality: FilterQuality.high,
                                                                                                ),
                                                                                                ClipPath(
                                                                                                  clipper: CustomClipLayerPath(),
                                                                                                  child: Container(
                                                                                                    color: Theme.of(context).primaryColorLight,
                                                                                                  ),
                                                                                                ),
                                                                                                ClipPath(
                                                                                                  clipper: CustomClipPath(),
                                                                                                  child: Image.file(
                                                                                                    File(vgData[i].replacedImagePath),
                                                                                                    fit: BoxFit.fill,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 1, bottom: 1),
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
                                                                                                    String downloadedFilePath = await downloadIconIceFromOfficial(
                                                                                                        vgData[i].icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''),
                                                                                                        modManAddModsTempDirPath);
                                                                                                    try {
                                                                                                      File(downloadedFilePath).copySync(vgData[i].icePath);
                                                                                                      vgData[i].replacedMd5 = '';
                                                                                                      vgData[i].replacedImagePath = '';
                                                                                                      vgData[i].replacedImageName = '';
                                                                                                      vgData[i].isReplaced = false;
                                                                                                      saveVitalGaugesInfoToJson(vgData);
                                                                                                    } catch (e) {
                                                                                                      // ignore: use_build_context_synchronously
                                                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!',
                                                                                                          '${vgData[i].iceName}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
                                                                                                    }
                                                                                                    setState(() {});
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  : Stack(
                                                                                      alignment: AlignmentDirectional.bottomStart,
                                                                                      children: [
                                                                                        AspectRatio(
                                                                                          aspectRatio: 29 / 6,
                                                                                          child: Container(
                                                                                            decoration: ShapeDecoration(
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                                    borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                                            child: Image.network(
                                                                                              vgData[i].pngPath,
                                                                                              filterQuality: FilterQuality.high,
                                                                                              fit: BoxFit.fill,
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
                                                                                  customVgBackgroundApply(context, imgPath, vgData[i]).then((value) {
                                                                                    if (value) {
                                                                                      vgData[i].replacedImagePath = imgPath;
                                                                                      vgData[i].replacedImageName = p.basename(imgPath);
                                                                                      vgData[i].isReplaced = true;
                                                                                      saveVitalGaugesInfoToJson(vgData);
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
                                                                    onPressed: vgData.where((e) => e.isReplaced).isNotEmpty || !_isShowAll
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
                                                                    onLongPress: vgData.where((element) => element.isReplaced).isEmpty
                                                                        ? null
                                                                        : () async {
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                            for (var vg in vgData) {
                                                                              if (vg.isReplaced) {
                                                                                int index = vgData.indexOf(vg);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedFilePath = await downloadIconIceFromOfficial(
                                                                                      vg.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  try {
                                                                                    File(downloadedFilePath).copySync(vg.icePath);
                                                                                    vg.replacedMd5 = '';
                                                                                    vg.replacedImagePath = '';
                                                                                    vg.replacedImageName = '';
                                                                                    vg.isReplaced = false;
                                                                                    saveVitalGaugesInfoToJson(vgData);
                                                                                  } catch (e) {
                                                                                    // ignore: use_build_context_synchronously
                                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                        // ignore: use_build_context_synchronously
                                                                                        context,
                                                                                        '${curLangText!.uiFailed}!',
                                                                                        '${vg.iceName}\n${curLangText!.uiNoFilesInGameDataToReplace}',
                                                                                        5000));
                                                                                  }
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                int index = vgData.indexOf(vg);
                                                                                _loading[index] = true;
                                                                                Future.delayed(const Duration(milliseconds: 500), () async {
                                                                                  String downloadedFilePath = await downloadIconIceFromOfficial(
                                                                                      vg.icePath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
                                                                                  File(downloadedFilePath).copySync(vg.icePath);
                                                                                  _loading[index] = false;
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            }
                                                                            Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                              element.deleteSync(recursive: true);
                                                                            });
                                                                          },
                                                                    onPressed: vgData.where((element) => element.isReplaced).isEmpty ? null : () {},
                                                                    child: Text(curLangText!.uiRestoreAll)),
                                                              ),
                                                              const SizedBox(
                                                                width: 5,
                                                              ),
                                                              Expanded(
                                                                child: ElevatedButton(
                                                                    onPressed: () {
                                                                      allCustomBackgroundsLoader = null;
                                                                      vitalgaugeDataLoader = null;

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

class WidgetStateered {}

//suport functions
Future<bool> vitalGaugeImageCropDialog(context, File newImageFile) async {
  final imageCropController = CropController(
    aspectRatio: 29 / 6,
    //minimumImageSize: 100,
    //defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
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
                        if (Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
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
                                img.Image resized = img.copyResize(image!, width: 512, height: 128);

                                File croppedImage = File(Uri.file('$modManVitalGaugeDirPath/${newImageName.text}.png').toFilePath());
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
                              img.Image resized = img.copyResize(image!, width: 512, height: 128);

                              File croppedImage = File(Uri.file('$modManVitalGaugeDirPath/${newImageName.text}.png').toFilePath());
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

Future<List<VitalGaugeBackground>> originalVitalBackgroundsFetching(context) async {
  //Load vg from playerItemdata
  if (playerItemData.isEmpty) {
    await playerItemDataGet(context);
  }
  List<CsvItem> vgData = playerItemData.where((element) => element.csvFileName == 'Vital Gauge.csv').toList();
  //Load list from json
  List<VitalGaugeBackground> vitalGaugesData = [];
  bool refetchData = false;
  if (File(modManVitalGaugeJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManVitalGaugeJsonPath).readAsStringSync());
    for (var type in jsonData) {
      vitalGaugesData.add(VitalGaugeBackground.fromJson(type));
      if (!refetchData && (!File(vitalGaugesData.last.icePath).existsSync())) {
        refetchData = true;
      }
    }
  }
  List<VitalGaugeBackground> newVGInfoList = [];
  if (refetchData || vgData.length > vitalGaugesData.length) {
    for (var data in vgData) {
      String ddsName = p.basenameWithoutExtension(data.infos.entries.firstWhere((element) => element.key == 'Path').value.split('/').last);
      String iceName = data.infos.entries.firstWhere((element) => element.key == 'Ice Hash - Image').value.split('\\').last;
      String icePath = ogVitalGaugeIcePathsFetcher(iceName);
      String pngPath = '$modManMAIconDatabaseLink${data.iconImagePath.replaceAll('\\', '/')}';
      newVGInfoList.add(VitalGaugeBackground(icePath, iceName, ddsName, pngPath, '', '', '', '', false));
      await Future.delayed(const Duration(milliseconds: 10));
    }

    //replace vg settings
    for (var i = 0; i < newVGInfoList.length; i++) {
      for (var vgInJson in vitalGaugesData) {
        if (newVGInfoList[i].ddsName == vgInJson.ddsName && newVGInfoList[i].iceName == vgInJson.iceName) {
          newVGInfoList[i].ogMd5 = vgInJson.ogMd5;
          newVGInfoList[i].replacedImagePath = vgInJson.replacedImagePath;
          newVGInfoList[i].replacedImageName = vgInJson.replacedImageName;
          newVGInfoList[i].replacedMd5 = vgInJson.replacedMd5;
          newVGInfoList[i].isReplaced = vgInJson.isReplaced;
          break;
        }
      }
    }
  } else {
    newVGInfoList = vitalGaugesData;
  }

  newVGInfoList.sort(
    (a, b) => a.ddsName.compareTo(b.ddsName),
  );
  saveVitalGaugesInfoToJson(newVGInfoList);

  return newVGInfoList;
}

Future<List<File>> customVitalBackgroundsFetching() async {
  List<File> returnList = [];
  //remove local originals
  if (Directory(modManVitalGaugeOriginalsDirPath).existsSync()) {
    Directory(modManVitalGaugeOriginalsDirPath).deleteSync(recursive: true);
  }

  returnList = Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
  return returnList;
}

Future<bool> customVgBackgroundApply(context, String imgPath, VitalGaugeBackground vgDataFile) async {
  clearAllTempDirs();

  // String logs = 'Custom Path: $imgPath\n';

  String newTempIcePath = Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}/group2').toFilePath();
  Directory(newTempIcePath).createSync(recursive: true);
  if (Directory(newTempIcePath).existsSync()) {
    await Process.run(modManDdsPngToolExePath, [imgPath, Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath(), '-pngtodds']);
    // logs += 'Create: $newTempIcePath\n';
  }
  if (File(Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath()).existsSync()) {
    // logs += 'Convert: ${Uri.file('$newTempIcePath/${vgDataFile.ddsName}.dds').toFilePath().toString()}\n';
    await Process.run('$modManZamboniExePath -c -pack -outdir "$modManAddModsTempDirPath"', [Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}').toFilePath()]);
    Directory(Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}').toFilePath()).deleteSync(recursive: true);

    File renamedFile = await File(Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}.ice').toFilePath()).rename(Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}').toFilePath());
    if (renamedFile.path.isNotEmpty) {
      // logs += 'Pack: ${renamedFile.path.toString()}\n';
      int i = 0;
      while (i < 10) {
        try {
          File copied = renamedFile.copySync(vgDataFile.icePath);
          vgDataFile.replacedMd5 = await getFileHash(copied.path);
          i = 10;
          // logs += 'Copy: ${copied.path.toString()}\n';
        } catch (e) {
          i++;
        }
      }
      if (i > 10) {
        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiFailed}!', '${vgDataFile.iceName}\n${curLangText!.uiNoFilesInGameDataToReplace}', 5000));
        return false;
      }
    }

    // File(Uri.file('$modManAddModsTempDirPath/${vgDataFile.iceName}.ice').toFilePath()).rename(vgDataFile.icePath).then((value) async {
    //   if (value.path.isNotEmpty) {
    //     vgDataFile.replacedMd5 = await getFileHash(value.path);
    //   }
    // });

    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
      element.deleteSync(recursive: true);
    });
  }

  // File vgLog = File(Uri.file('$modManDirPath/vgApplyLog.txt').toFilePath());
  // vgLog.createSync();
  // vgLog.writeAsStringSync(logs);

  return true;
}

class CustomClipPath extends CustomClipper<Path> {
  //var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 200);
    path.lineTo(200, 200);
    path.lineTo(460, 0);
    path.lineTo(230, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomClipLayerPath extends CustomClipper<Path> {
  //var radius=10.0;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 200);
    path.lineTo(200, 200);
    path.lineTo(463, 0);
    path.lineTo(235, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
