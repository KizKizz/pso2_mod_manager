import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_apply_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_export_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_restore_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';

class LineStrikeCardOriginalTile extends StatefulWidget {
  const LineStrikeCardOriginalTile({super.key, required this.card, required this.lineStrikeCardList});

  final List<LineStrikeCard> lineStrikeCardList;
  final LineStrikeCard card;

  @override
  State<LineStrikeCardOriginalTile> createState() => _LineStrikeCardOriginalTileState();
}

class _LineStrikeCardOriginalTileState extends State<LineStrikeCardOriginalTile> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return Center(
          child: widget.card.isReplaced
              ? Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            widget.card.cardZeroIconWebPath,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: SizedBox(
                            width: 120,
                            height: 160,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(
                                File(widget.card.replacedImagePath),
                                fit: BoxFit.fill,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                      child: Row(spacing: 5, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ElevatedButton(
                            onPressed: () async {
                              bool result = await lineStrikeCardRestorePopup(context, widget.card, widget.lineStrikeCardList);
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                result ? restoreSuccessNotification(widget.card.cardZeroDdsName) : restoreFailedNotification(widget.card.cardZeroDdsName);
                              }
                            },
                            child: Text(appText.restore)),
                        ModManTooltip(
                            message: appText.exportToPngImage,
                            child: IconButton.filled(
                                visualDensity: VisualDensity.adaptivePlatformDensity,
                                onPressed: () async {
                                  await lineStrikeCardExportPopup(context, widget.card);
                                },
                                icon: const Icon(Icons.image_outlined))),
                      ]),
                    ),
                  ],
                )
              : Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        widget.card.cardZeroIconWebPath,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
        );
      },
      onAcceptWithDetails: (data) async {
        String imgPath = data.data.toString();
        bool result = await lineStrikeCardApplyPopup(context, imgPath, widget.card);
        if (result) {
          widget.card.replacedImagePath = imgPath;
          widget.card.isReplaced = true;
          saveMasterLineStrikeCardListToJson(widget.lineStrikeCardList);
          setState(
            () {},
          );
        }
      },
    );
  }
}
