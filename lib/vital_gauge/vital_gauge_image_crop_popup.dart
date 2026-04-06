import 'dart:io';
import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:signals/signals_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

Future<File?> vitalGaugeImageCropPopup(context, File newImageFile) async {
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
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
            insetPadding: const EdgeInsets.only(top: 25),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: CropImage(
                controller: imageCropController,
                image: Image.file(newImageFile, filterQuality: FilterQuality.high),
                paddingSize: 5,
                alwaysMove: true,
              ),
            ),
            actionsPadding: const EdgeInsets.only(top: 0, bottom: 10, left: 10, right: 10),
            actions: [
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: Form(
                        key: nameFormKey,
                        child: TextFormField(
                          controller: newImageName,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.deny(RegExp('[\\/:*?"<>|]'))],
                          validator: (value) {
                            if (Directory(vitalGaugeDirPath).listSync().whereType<File>().where((element) => p.basenameWithoutExtension(element.path) == newImageName.text).isNotEmpty) {
                              return appText.nameAlreadyExists;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              labelText: appText.imageName,
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
                    ),
                  ),
                  Visibility(
                    visible: (nameFormKey.currentState != null && nameFormKey.currentState!.validate()) || nameFormKey.currentState == null,
                    child: OutlinedButton(
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

                            File croppedImage = File(Uri.file('$vitalGaugeDirPath/${newImageName.text}.png').toFilePath());
                            croppedImage.writeAsBytesSync(img.encodePng(resized));
                            //croppedImage.writeAsBytes(bytes, flush: true);
                            imageCropController.dispose();
                            //Future.delayed(const Duration(milliseconds: 100), () {
                            if (context.mounted) {
                              Navigator.pop(context, croppedImage);
                            }
                            //});
                          }
                        },
                        child: Text(appText.save)),
                  ),
                  Visibility(
                    visible: nameFormKey.currentState != null && !nameFormKey.currentState!.validate(),
                    child: OutlinedButton(
                        onPressed: () async {
                          setState(
                            () {},
                          );
                          final croppedImageBitmap = await imageCropController.croppedBitmap(quality: FilterQuality.high);
                          final data = await croppedImageBitmap.toByteData(format: ImageByteFormat.png);
                          final bytes = data!.buffer.asUint8List();
                          img.Image? image = img.decodePng(bytes);
                          img.Image resized = img.copyResize(image!, width: 512, height: 128);

                          File croppedImage = File(Uri.file('$vitalGaugeDirPath/${newImageName.text}.png').toFilePath());
                          croppedImage.writeAsBytesSync(img.encodePng(resized));
                          //croppedImage.writeAsBytes(bytes, flush: true);
                          imageCropController.dispose();
                          //Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            Navigator.pop(context, croppedImage);
                          }
                          //});
                        },
                        child: Text(appText.overwrite)),
                  ),
                  OutlinedButton(
                      onPressed: () async {
                        imageCropController.dispose();
                        await Future.delayed(const Duration(milliseconds: 50));
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, null);
                      },
                      child: Text(appText.returns)),
                ],
              )
            ],
          );
        });
      });
}
