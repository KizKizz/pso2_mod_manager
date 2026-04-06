import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_apply_popup.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_functions.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_restore_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/notifications.dart';

class LineStrikeSleeveOriginalTile extends StatefulWidget {
  const LineStrikeSleeveOriginalTile({super.key, required this.sleeve, required this.lineStrikeSleeveList});

  final List<LineStrikeSleeve> lineStrikeSleeveList;
  final LineStrikeSleeve sleeve;

  @override
  State<LineStrikeSleeveOriginalTile> createState() => _LineStrikeSleeveOriginalTileState();
}

class _LineStrikeSleeveOriginalTileState extends State<LineStrikeSleeveOriginalTile> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
        return Center(
          child: widget.sleeve.isReplaced
              ? Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.bottomEnd,
                      children: [
                        AspectRatio(
                          aspectRatio: 170 / 235,
                          child: Image.network(
                            widget.sleeve.iconWebPath,
                            fit: BoxFit.fitHeight,
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
                                File(widget.sleeve.replacedImagePath),
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
                              bool result = await lineStrikeSleeveRestorePopup(context, widget.sleeve, widget.lineStrikeSleeveList);
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                result ? restoreSuccessNotification(widget.sleeve.iceDdsName) : restoreFailedNotification(widget.sleeve.iceDdsName);
                              }
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
                      aspectRatio: 170 / 235,
                      child: Image.network(
                        widget.sleeve.iconWebPath,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ],
                ),
        );
      },
      onAcceptWithDetails: (data) async {
        String imgPath = data.data.toString();
        bool result = await lineStrikeSleeveApplyPopup(context, imgPath, widget.sleeve);
        if (result) {
          widget.sleeve.replacedImagePath = imgPath;
          widget.sleeve.isReplaced = true;
          saveMasterLineStrikeSleeveListToJson(widget.lineStrikeSleeveList);
          setState(
            () {},
          );
        }
      },
    );
  }
}
