import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_class.dart';
import 'package:pso2_mod_manager/line_strike/line_strike_card_original_tile.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:signals/signals_flutter.dart';

class LineStrikeCardOriginalGridLayout extends StatefulWidget {
  const LineStrikeCardOriginalGridLayout({super.key, required this.cards, required this.rScrollController});

  final List<LineStrikeCard> cards;
  final ScrollController rScrollController;

  @override
  State<LineStrikeCardOriginalGridLayout> createState() => _LineStrikeCardOriginalGridLayoutState();
}

class _LineStrikeCardOriginalGridLayoutState extends State<LineStrikeCardOriginalGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SignalBuilder(
        builder: (context) => CardOverlay(
          paddingValue: 5,
          rightPaddingValue: scrollbarsAlwaysVisible.value ? 0 : null,
          child: ScrollbarTheme(
            data: ScrollbarThemeData(trackVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value), thumbVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value)),
            child: ResponsiveGridList(
              listViewBuilderOptions: ListViewBuilderOptions(controller: widget.rScrollController),
              minItemWidth: 190,
              // verticalGridMargin: 5,
              horizontalGridSpacing: 5,
              verticalGridSpacing: 5,
              children: [for (int i = 0; i < widget.cards.length; i++) LineStrikeCardOriginalTile(card: widget.cards[i], lineStrikeCardList: widget.cards)],
            ),
          ),
        ),
      ),
    );
  }
}
