import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_original_tile.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class LineStrikeCardOriginalGridLayout extends StatefulWidget {
  const LineStrikeCardOriginalGridLayout({super.key, required this.cards});

  final List<LineStrikeCard> cards;

  @override
  State<LineStrikeCardOriginalGridLayout> createState() => _LineStrikeCardOriginalGridLayoutState();
}

class _LineStrikeCardOriginalGridLayoutState extends State<LineStrikeCardOriginalGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ResponsiveGridList(
            minItemWidth: 190,
            verticalGridMargin: 5,
            horizontalGridSpacing: 5,
            verticalGridSpacing: 5,
            children: [for (int i = 0; i < widget.cards.length; i++) LineStrikeCardOriginalTile(card: widget.cards[i], lineStrikeCardList: widget.cards)]));
  }
}
