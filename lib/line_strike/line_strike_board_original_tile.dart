// ignore_for_file: duplicate_import, unused_import

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_apply_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_restore_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';

class LineStrikeBoardOriginalTile extends StatefulWidget {
  const LineStrikeBoardOriginalTile({super.key, required this.board, required this.lineStrikeBoardList});

  final List<LineStrikeBoard> lineStrikeBoardList;
  final LineStrikeBoard board;

  @override
  State<LineStrikeBoardOriginalTile> createState() => _LineStrikeBoardOriginalTileState();
}

class _LineStrikeBoardOriginalTileState extends State<LineStrikeBoardOriginalTile> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return Center(
          child: widget.board.isReplaced
              ? Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        AspectRatio(
                          aspectRatio: 867 / 488,
                          child: Image.network(
                            widget.board.iconWebPath,
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 0),
                          child: SizedBox(
                            width: 300,
                            child: AspectRatio(
                              aspectRatio: 867 / 488,
                              child: Image.file(
                                File(widget.board.replacedImagePath),
                                fit: BoxFit.fitWidth,
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
                              bool result = await lineStrikeBoardRestorePopup(context, widget.board, widget.lineStrikeBoardList);
                              // ignore: use_build_context_synchronously
                              result ? restoreSuccessNotification(widget.board.iceDdsName) : restoreFailedNotification(widget.board.iceDdsName);
                            },
                            child: Text(appText.restore)),
                        
                      ]),
                    ),
                  ],
                )
              : Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    AspectRatio(
                      aspectRatio: 867 / 488,
                      child: Image.network(
                        widget.board.iconWebPath,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
        );
      },
      onAcceptWithDetails: (data) async {
        String imgPath = data.data.toString();
        bool result = await lineStrikeBoardApplyPopup(context, imgPath, widget.board);
        if (result) {
          widget.board.replacedImagePath = imgPath;
          widget.board.isReplaced = true;
          saveMasterLineStrikeBoardListToJson(widget.lineStrikeBoardList);
          setState(
            () {},
          );
        }
      },
    );
  }
}
