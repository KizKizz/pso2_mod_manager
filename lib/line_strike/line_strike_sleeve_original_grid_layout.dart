import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_sleeve_original_tile.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class LineStrikeSleeveOriginalGridLayout extends StatefulWidget {
  const LineStrikeSleeveOriginalGridLayout({super.key, required this.sleeves, required this.rScrollController});

  final List<LineStrikeSleeve> sleeves;
  final ScrollController rScrollController;

  @override
  State<LineStrikeSleeveOriginalGridLayout> createState() => _LineStrikeSleeveOriginalGridLayoutState();
}

class _LineStrikeSleeveOriginalGridLayoutState extends State<LineStrikeSleeveOriginalGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ResponsiveGridList(
            listViewBuilderOptions: ListViewBuilderOptions(controller: widget.rScrollController),
            minItemWidth: 250,
            verticalGridMargin: 5,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 5,
            children: [for (int i = 0; i < widget.sleeves.length; i++) LineStrikeSleeveOriginalTile(sleeve: widget.sleeves[i], lineStrikeSleeveList: widget.sleeves)]));
  }
}
