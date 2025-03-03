import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_image_tile.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:path/path.dart' as p;

class LineStrikeBoardCustomImageGridLayout extends StatefulWidget {
  const LineStrikeBoardCustomImageGridLayout({super.key, required this.customImageFiles, required this.lScrollController});

  final List<File> customImageFiles;
  final ScrollController lScrollController;

  @override
  State<LineStrikeBoardCustomImageGridLayout> createState() => _LineStrikeBoardCustomImageGridLayoutState();
}

class _LineStrikeBoardCustomImageGridLayoutState extends State<LineStrikeBoardCustomImageGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardOverlay(
          paddingValue: 5,
          child: ResponsiveGridList(
            listViewBuilderOptions: ListViewBuilderOptions(controller: widget.lScrollController),
            minItemWidth: 300,
            // verticalGridMargin: 5,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 5,
            children: [
              for (int i = 0; i < widget.customImageFiles.length; i++)
                LineStrikeBoardImageTile(
                    customImageFile: widget.customImageFiles[i],
                    onDeleteButtonPress: () async {
                      bool result = await deleteConfirmPopup(context, p.basename(widget.customImageFiles[i].path));
                      if (result) {
                        await widget.customImageFiles[i].delete();
                        widget.customImageFiles.remove(widget.customImageFiles[i]);
                        setState(() {});
                      }
                    })
            ],
          )),
    );
  }
}
