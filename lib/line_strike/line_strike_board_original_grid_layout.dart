import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_board_original_tile.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class LineStrikeBoardOriginalGridLayout extends StatefulWidget {
  const LineStrikeBoardOriginalGridLayout({super.key, required this.boards, required this.rScrollController});

  final List<LineStrikeBoard> boards;
  final ScrollController rScrollController;

  @override
  State<LineStrikeBoardOriginalGridLayout> createState() => _LineStrikeBoardOriginalGridLayoutState();
}

class _LineStrikeBoardOriginalGridLayoutState extends State<LineStrikeBoardOriginalGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ResponsiveGridList(
            minItemWidth: 190,
            verticalGridMargin: 5,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 5,
            children: [for (int i = 0; i < widget.boards.length; i++) LineStrikeBoardOriginalTile(board: widget.boards[i], lineStrikeBoardList: widget.boards)]));
  }
}
