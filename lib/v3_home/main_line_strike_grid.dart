import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_custom_image_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_original_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_custom_image_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_original_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_image_crop_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_custom_image_grid_layout.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_original_grid_layout.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/choice_select_buttons.dart';
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
  ScrollController lScrollController = ScrollController();
  ScrollController rScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  Future<void> customImageFetch() async {
    if (selectedLineStrikeType.watch(context) == LineStrikeItemType.cards.value) {
      customBackgroundImages = await customCardImagesFetch();
    } else if (selectedLineStrikeType.watch(context) == LineStrikeItemType.boards.value) {
      customBackgroundImages = await customBoardImageFetch();
    } else if (selectedLineStrikeType.watch(context) == LineStrikeItemType.sleeves.value) {
      customBackgroundImages = await customSleeveImageFetch();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    customImageFetch();
    return AnimatedOpacity(
      opacity: fadeInOpacity,
      duration: const Duration(milliseconds: 100),
      child: Column(
        spacing: 5,
        children: [
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: SizedBox(
                height: 30,
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
                        File? croppedImage = await lineStrikeImageCropPopup(context, File(selectedImageFile.path), selectedLineStrikeType.value);
                        if (croppedImage != null && croppedImage.existsSync()) customBackgroundImages.insert(0, croppedImage);
                        setState(() {});
                      }
                    },
                    child: Text(appText.createNewBackground)),
              )),
              Expanded(
                  child: SizedBox(
                height: 30,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      launchUrlString(selectedLineStrikeType.value == LineStrikeItemType.cards.value
                          ? lineStrikeCardsDirPath
                          : selectedLineStrikeType.value == LineStrikeItemType.boards.value
                              ? lineStrikeBoardsDirPath
                              : lineStrikeSleevesDirPath);
                    },
                    child: Text(appText.openInFileExplorer)),
              )),
              Expanded(
                  child: SizedBox(
                height: 30,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      if (selectedLineStrikeType.value == LineStrikeItemType.cards.value) {
                        customBackgroundImages = await customCardImagesFetch();
                      } else if (selectedLineStrikeType.value == LineStrikeItemType.boards.value) {
                        customBackgroundImages = await customBoardImageFetch();
                      } else if (selectedLineStrikeType.value == LineStrikeItemType.sleeves.value) {
                        customBackgroundImages = await customSleeveImageFetch();
                      }
                      setState(() {});
                    },
                    child: Text(appText.refresh)),
              )),
              Expanded(
                  child: SizedBox(
                height: 30,
                child: OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
                        side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
                    onPressed: () async {
                      lineStrikeShowAppliedOnly ? lineStrikeShowAppliedOnly = false : lineStrikeShowAppliedOnly = true;
                      setState(() {});
                    },
                    child: Text(lineStrikeShowAppliedOnly ? appText.showAll : appText.showAppliedOnly)),
              )),
              Expanded(child: SingleChoiceSelectButton(
                        width: double.infinity,
                        height: 30,
                        label: appText.view,
                        selectPopupLabel: appText.view,
                        availableItemList: lineStrikeItemTypes,
                        selectedItemsLabel: lineStrikeItemTypes.map((e) => appText.lineStrikeItemTypeName(e)).toList(),
                        selectedItem: selectedLineStrikeType,
                        extraWidgets: [],
                        savePref: () {
                          lScrollController.jumpTo(0);
                          rScrollController.jumpTo(0);
                        }))
            ],
          ),
          Visibility(
            visible: selectedLineStrikeType.value == LineStrikeItemType.cards.value,
            child: Expanded(
                child: Row(
              spacing: 5,
              children: [
                LineStrikeCardcustomImageGridLayout(customImageFiles: customBackgroundImages, lScrollController: lScrollController),
                LineStrikeCardOriginalGridLayout(
                    cards: lineStrikeShowAppliedOnly ? masterLineStrikeCardList.where((e) => e.isReplaced).toList() : masterLineStrikeCardList, rScrollController: rScrollController)
              ],
            )),
          ),
          Visibility(
            visible: selectedLineStrikeType.value == LineStrikeItemType.boards.value,
            child: Expanded(
                child: Row(
              spacing: 5,
              children: [
                LineStrikeBoardCustomImageGridLayout(customImageFiles: customBackgroundImages, lScrollController: lScrollController),
                LineStrikeBoardOriginalGridLayout(
                    boards: lineStrikeShowAppliedOnly ? masterLineStrikeBoardList.where((e) => e.isReplaced).toList() : masterLineStrikeBoardList, rScrollController: rScrollController)
              ],
            )),
          ),
          Visibility(
            visible: selectedLineStrikeType.value == LineStrikeItemType.sleeves.value,
            child: Expanded(
                child: Row(
              spacing: 5,
              children: [
                LineStrikesSleeveCustomImageGridLayout(customImageFiles: customBackgroundImages, lScrollController: lScrollController),
                LineStrikeSleeveOriginalGridLayout(
                    sleeves: lineStrikeShowAppliedOnly ? masterLineStrikeSleeveList.where((e) => e.isReplaced).toList() : masterLineStrikeSleeveList, rScrollController: rScrollController)
              ],
            )),
          ),
        ],
      ),
    );
  }
}
