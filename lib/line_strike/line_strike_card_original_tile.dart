import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_apply_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_functions.dart';

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
                  alignment: AlignmentDirectional.bottomEnd,
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
                          padding: const EdgeInsets.only(right: 15),
                          child: AspectRatio(
                            aspectRatio: 0.5,
                            child: Image.file(
                              File(widget.card.replacedImagePath),
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Padding(padding: const EdgeInsets.only(right: 5), child: OutlinedButton(onPressed: () {}, child: Text(appText.getImage))),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: OutlinedButton(onPressed: () {}, child: Text(appText.restore)),
                      ),
                    ]),
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
