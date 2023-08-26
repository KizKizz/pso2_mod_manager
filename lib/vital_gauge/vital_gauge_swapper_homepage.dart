import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/vital_gauge_class.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/csv_list_fetcher.dart';
import 'package:pso2_mod_manager/functions/hash_generator.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

Future vitalgaugeDataLoader = originalVitalBackgroundsFetching();
List<File> allAvailableImages = Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
List<File> allOriginalImages = Directory(modManVitalGaugeOriginalsDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
bool _isDropped = false;
Widget? _droppedImage;

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
                        future: vitalgaugeDataLoader,
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
                              List<VitalGaugeBackground> vgData = snapshot.data;
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
                                      Text('Available Backgrounds', style: Theme.of(context).textTheme.titleLarge),
                                      Expanded(
                                          child: ScrollbarTheme(
                                              data: ScrollbarThemeData(
                                                thumbColor: MaterialStateProperty.resolveWith((states) {
                                                  if (states.contains(MaterialState.hovered)) {
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
                                                    itemCount: allAvailableImages.length,
                                                    itemBuilder: (context, i) {
                                                      Offset pointerDragAnchorStrategy(Draggable<Object> draggable, BuildContext context, Offset position) {
                                                        return Offset.zero;
                                                      }

                                                      return Draggable(
                                                        dragAnchorStrategy: pointerDragAnchorStrategy,
                                                        feedback: Image.file(allAvailableImages[i]),
                                                        data: Image.file(allAvailableImages[i]),
                                                        child: Container(
                                                          decoration: ShapeDecoration(
                                                              shape: RoundedRectangleBorder(
                                                                  side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                          child: AspectRatio(
                                                              aspectRatio: 4 / 1,
                                                              child: Image.file(
                                                                allAvailableImages[i],
                                                                fit: BoxFit.fill,
                                                              )),
                                                        ),
                                                      );
                                                    }),
                                              ))),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    const XTypeGroup typeGroup = XTypeGroup(
                                                      label: 'image',
                                                      extensions: <String>['png'],
                                                    );
                                                    final selectedImage = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                    if (selectedImage != null) {
                                                      // ignore: use_build_context_synchronously
                                                      await vitalGaugeImageCropDialog(context, File(selectedImage.path)).then((value) => setState(() {}));
                                                    }
                                                  },
                                                  child: Text('Create')),
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
                                  Expanded(
                                      child: Column(
                                    children: [
                                      Text('Original Backgrounds', style: Theme.of(context).textTheme.titleLarge),
                                      Expanded(
                                          child: ScrollbarTheme(
                                              data: ScrollbarThemeData(
                                                thumbColor: MaterialStateProperty.resolveWith((states) {
                                                  if (states.contains(MaterialState.hovered)) {
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
                                                    itemCount: allOriginalImages.length,
                                                    itemBuilder: (context, i) {
                                                      return DragTarget(
                                                        builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                                          return Center(
                                                            child: _isDropped
                                                                ? AspectRatio(
                                                                  aspectRatio: 4 /1,
                                                                  child: Container(
                                                                      decoration: ShapeDecoration(
                                                                          shape: RoundedRectangleBorder(
                                                                              side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                      child: Stack(
                                                                        children: [
                                                                          Positioned(
                                                                            right: 0,
                                                                            top: 0,
                                                                            bottom: 0,
                                                                            left: 0,
                                                                            child: AspectRatio(
                                                                                aspectRatio: 4 / 1,
                                                                                child: Image.file(
                                                                                  allOriginalImages[i],
                                                                                  fit: BoxFit.fill,
                                                                                )),
                                                                          ),
                                                                          Positioned(
                                                                            left: 0,
                                                                            top: 0,
                                                                            bottom: 0,
                                                                            child: AspectRatio(
                                                                              aspectRatio: 4 / 1,
                                                                              child: ClipPath(
                                                                                clipper: CustomPath(),
                                                                                child: AspectRatio(aspectRatio: 4 / 1, child: _droppedImage),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                )
                                                                : Container(
                                                                    decoration: ShapeDecoration(
                                                                        shape: RoundedRectangleBorder(
                                                                            side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
                                                                    child: AspectRatio(
                                                                        aspectRatio: 4 / 1,
                                                                        child: Image.file(
                                                                          allOriginalImages[i],
                                                                          fit: BoxFit.fill,
                                                                        )),
                                                                  ),
                                                          );
                                                        },
                                                        onAccept: (data) {
                                                          setState(
                                                            () {
                                                              _droppedImage = data as Widget?;
                                                              _isDropped = true;
                                                            },
                                                          );
                                                        },
                                                        onLeave: (data) {
                                                          setState(
                                                            () {
                                                              _isDropped = false;
                                                            },
                                                          );
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
                                                  onPressed: () async {
                                                    setState(
                                                      () {},
                                                    );
                                                  },
                                                  child: Text('Restore All')),
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
                  }),
                ),
              ));
        });
      });
}

//suport functions
Future<bool> vitalGaugeImageCropDialog(context, File newImageFile) async {
  final imageCropController = CropController(
    aspectRatio: 4 / 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
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
                        if (Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
                          return curLangText!.uiNameAlreadyExisted;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: 'Cropped Image Name',
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
                          onPressed: () {
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
                                final croppedImageBitmap = await imageCropController.croppedBitmap(maxSize: 512, quality: FilterQuality.high);
                                final data = await croppedImageBitmap.toByteData(format: ImageByteFormat.png);
                                final bytes = data!.buffer.asUint8List();
                                File croppedImage = File(Uri.file('$modManVitalGaugeDirPath/${newImageName.text}.png').toFilePath());
                                croppedImage.writeAsBytes(bytes, flush: true);
                                allAvailableImages = Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
                                // ignore: use_build_context_synchronously
                              }
                              setState(
                                () {},
                              );
                            },
                            child: Text('Save Crop')),
                      ),
                      Visibility(
                        visible: nameFormKey.currentState != null && !nameFormKey.currentState!.validate(),
                        child: ElevatedButton(
                            onPressed: () async {
                              setState(
                                () {},
                              );
                              final croppedImageBitmap = await imageCropController.croppedBitmap(maxSize: 512, quality: FilterQuality.high);
                              final data = await croppedImageBitmap.toByteData(format: ImageByteFormat.png);
                              final bytes = data!.buffer.asUint8List();
                              File croppedImage = File(Uri.file('$modManVitalGaugeDirPath/${newImageName.text}.png').toFilePath());
                              croppedImage.writeAsBytes(bytes, flush: true);
                              allAvailableImages = Directory(modManVitalGaugeDirPath).listSync().whereType<File>().where((element) => p.extension(element.path) == '.png').toList();
                              setState(
                                () {},
                              );
                            },
                            child: Text('Overwrite')),
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

Future<List<VitalGaugeBackground>> originalVitalBackgroundsFetching() async {
  //get info from csv
  List<String> vgCsvInfoList = [];
  File vitalGaugeCsv = File(Uri.file('$modManRefSheetsDirPath/Player/Vital_Gauge.csv').toFilePath());
  await vitalGaugeCsv.openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
    vgCsvInfoList.add(line);
  });

  //Load list from json
  List<VitalGaugeBackground> vitalGaugesData = [];
  if (File(modManVitalGaugeJsonPath).readAsStringSync().toString().isNotEmpty) {
    var jsonData = jsonDecode(File(modManVitalGaugeJsonPath).readAsStringSync());
    for (var type in jsonData) {
      vitalGaugesData.add(VitalGaugeBackground.fromJson(type));
    }
  }

//create objects
  if (vitalGaugesData.isEmpty) {
    Directory(modManVitalGaugeOriginalsDirPath).listSync().forEach((element) {
      element.deleteSync();
    });
    for (var line in vgCsvInfoList) {
      String ddsName = p.basenameWithoutExtension(line.split(',').first.split('/').last);
      String iceName = line.split(',').last.split('\\').last;
      String ogPath = ogVitalGaugeIcePathsFetcher(iceName);
      if (ogPath.isNotEmpty) {
        String downloadedFilePath = await downloadIconIceFromOfficial(ogPath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
        await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedFilePath]);
        File ddsImage = Directory('${downloadedFilePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
        if (ddsImage.path.isNotEmpty) {
          await Process.run(Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath(),
              [ddsImage.path, '$modManVitalGaugeOriginalsDirPath/${p.basenameWithoutExtension(ddsImage.path)}.png', '-ddstopng']);
          File pngItemIcon = Directory('${downloadedFilePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.png', orElse: () => File(''));
          // if (pngItemIcon.path.isNotEmpty) {
          //   newItemIcon = pngItemIcon.renameSync(Uri.file('$modManModsAdderPath/$itemCategory/$itemName/$itemName.png').toFilePath());
        }

        vitalGaugesData.add(VitalGaugeBackground(ogPath, iceName, ddsName, await getFileHash(ogPath), '', '', '', false));
      }
    }
    saveVitalGaugesInfoToJson(vitalGaugesData);
  } else {
    for (var line in vgCsvInfoList) {
      String ddsName = p.basenameWithoutExtension(line.split(',').first.split('/').last);
      String iceName = line.split(',').last.split('\\').last;
      String ogPath = ogVitalGaugeIcePathsFetcher(iceName);
      if (vitalGaugesData.where((element) => element.iceName == iceName).isEmpty && ogPath.isNotEmpty) {
        String downloadedFilePath = await downloadIconIceFromOfficial(ogPath.replaceFirst(Uri.file('$modManPso2binPath/').toFilePath(), ''), modManAddModsTempDirPath);
        await Process.run('$modManZamboniExePath -outdir "$modManAddModsTempDirPath"', [downloadedFilePath]);
        File ddsImage = Directory('${downloadedFilePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.dds', orElse: () => File(''));
        if (ddsImage.path.isNotEmpty) {
          await Process.run(Uri.file('${Directory.current.path}/png_dds_converter/png_dds_converter.exe').toFilePath(),
              [ddsImage.path, '$modManVitalGaugeOriginalsDirPath/${p.basenameWithoutExtension(ddsImage.path)}.png', '-ddstopng']);
          File pngItemIcon = Directory('${downloadedFilePath}_ext').listSync(recursive: true).whereType<File>().firstWhere((element) => p.extension(element.path) == '.png', orElse: () => File(''));
          // if (pngItemIcon.path.isNotEmpty) {
          //   newItemIcon = pngItemIcon.renameSync(Uri.file('$modManModsAdderPath/$itemCategory/$itemName/$itemName.png').toFilePath());
        }
        vitalGaugesData.add(VitalGaugeBackground(ogPath, iceName, ddsName, await getFileHash(ogPath), '', '', '', false));
      }
    }
    vitalGaugesData.sort(
      (a, b) => a.ddsName.compareTo(b.ddsName),
    );
    saveVitalGaugesInfoToJson(vitalGaugesData);
  }

  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
    element.deleteSync(recursive: true);
  });

  return vitalGaugesData;
}

class CustomPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width - 50, 0);
    path.lineTo(size.width - 90, size.height / 2);
    path.lineTo(size.width - 50, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
