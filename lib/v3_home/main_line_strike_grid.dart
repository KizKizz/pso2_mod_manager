import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_custom_image_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_original_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_image_crop_popup.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_functions.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MainLineStrikeGrid extends StatefulWidget {
  const MainLineStrikeGrid({super.key});

  @override
  State<MainLineStrikeGrid> createState() => _MainVitalGaugeGridState();
}

class _MainVitalGaugeGridState extends State<MainLineStrikeGrid> {
  double fadeInOpacity = 0;
  List<File> customBackgroundImages = [];
  bool lineStrikeShowAppliedOnly = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      customBackgroundImages = await customCardImagesFetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: fadeInOpacity,
      duration: const Duration(milliseconds: 500),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: SizedBox(
                height: 40,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      XTypeGroup typeGroup = XTypeGroup(
                        label: appText.images,
                        extensions: const <String>['jpg', 'png'],
                      );
                      final XFile? selectedImageFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                      if (selectedImageFile != null) {
                        // ignore: use_build_context_synchronously
                        File? croppedImage = await lineStrikeImageCropPopup(context, File(selectedImageFile.path), LineStrikeItemType.card);
                        if (croppedImage != null && croppedImage.existsSync()) customBackgroundImages.insert(0, croppedImage);
                        setState(() {});
                      }
                    },
                    child: Text(appText.createNewBackground)),
              )),
              Expanded(
                  child: SizedBox(
                height: 40,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      launchUrlString(lineStrikeCardsDirPath);
                    },
                    child: Text(appText.openInFileExplorer)),
              )),
              Expanded(
                  child: SizedBox(
                height: 40,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      customBackgroundImages = await customCardImagesFetch();
                      setState(() {});
                    },
                    child: Text(appText.refresh)),
              )),
              Expanded(
                  child: SizedBox(
                height: 40,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      lineStrikeShowAppliedOnly ? lineStrikeShowAppliedOnly = false : lineStrikeShowAppliedOnly = true;
                      setState(() {});
                    },
                    child: Text(lineStrikeShowAppliedOnly ? appText.showAll : appText.showAppliedOnly)),
              ))
            ],
          ),
          Expanded(
              child: Row(
            spacing: 5,
            children: [
              LineStrikeCardcustomImageGridLayout(customImageFiles: customBackgroundImages),
              LineStrikeCardOriginalGridLayout(cards: lineStrikeShowAppliedOnly ? masterLineStrikeCardList.where((e) => e.isReplaced).toList() : masterLineStrikeCardList)
            ],
          )),
        ],
      ),
    );
  }
}
