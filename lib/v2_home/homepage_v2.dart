import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/v2_home/applied_list_v2.dart';
import 'package:pso2_mod_manager/v2_home/item_list_v2.dart';
import 'package:pso2_mod_manager/v2_home/mod_view_list_v2.dart';
import 'package:signals/signals_flutter.dart';

Signal<Item?> selectedItemV2 = Signal(null);
Signal<bool> modViewExpandState = Signal(false);

class HomepageV2 extends StatefulWidget {
  const HomepageV2({super.key});

  @override
  State<HomepageV2> createState() => _HomepageV2State();
}

class _HomepageV2State extends State<HomepageV2> {
  final MultiSplitViewController multiSplitViewController = MultiSplitViewController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitView multiSplitView = MultiSplitView(
        // onDividerDragUpdate: _onDividerDragUpdate,
        // onDividerTap: _onDividerTap,
        // onDividerDoubleTap: _onDividerDoubleTap,
        // controller: _controller,
        // pushDividers: _pushDividers,
        initialAreas: [
          Area(flex: 2, builder: (context, area) => const ItemListV2()),
          Area(flex: 2, builder: (context, area) => ModViewListV2(item: selectedItemV2.watch(context))),
          Area(flex: 3, builder: (context, area) => const AppliedListV2()),
        ]);
    return MultiSplitViewTheme(
        data: MultiSplitViewThemeData(dividerPainter: DividerPainters.grooved2(count: 49, highlightedCount: 99, highlightedColor: Theme.of(context).colorScheme.primaryContainer)),
        child: multiSplitView);
  }
}
