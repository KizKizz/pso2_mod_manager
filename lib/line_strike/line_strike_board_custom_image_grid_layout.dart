import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_image_tile.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class LineStrikeCardcustomImageGridLayout extends StatefulWidget {
  const LineStrikeCardcustomImageGridLayout({super.key, required this.customImageFiles, required this.lScrollController});

  final List<File> customImageFiles;
  final ScrollController lScrollController;

  @override
  State<LineStrikeCardcustomImageGridLayout> createState() => _LineStrikeCardcustomImageGridLayoutState();
}

class _LineStrikeCardcustomImageGridLayoutState extends State<LineStrikeCardcustomImageGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ResponsiveGridList(
        minItemWidth: 150,
        verticalGridMargin: 5,
        horizontalGridSpacing: 5,
        verticalGridSpacing: 5,
        children: [for (int i = 0; i < widget.customImageFiles.length; i++) LineStrikeBoardImageTile(customImageFile: widget.customImageFiles[i], onDeleteButtonPress: () {})],
      ),
    );
  }
}
