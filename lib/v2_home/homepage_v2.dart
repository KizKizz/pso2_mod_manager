import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/applied_list_v2.dart';
import 'package:pso2_mod_manager/v2_home/item_list_v2.dart';
import 'package:pso2_mod_manager/v2_home/mod_view_list_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

Signal<Item?> selectedItemV2 = Signal(null);
Signal<bool> modViewExpandState = Signal(false);

class HomepageV2 extends StatefulWidget {
  const HomepageV2({super.key});

  @override
  State<HomepageV2> createState() => _HomepageV2State();
}

class _HomepageV2State extends State<HomepageV2> {
  final MultiSplitViewController multiSplitViewController = MultiSplitViewController(areas: [
    Area(flex: splitViewFlexValue0, builder: (context, area) => const ItemListV2()),
    Area(flex: splitViewFlexValue1, builder: (context, area) => ModViewListV2(item: selectedItemV2.watch(context))),
    Area(flex: splitViewFlexValue2, builder: (context, area) => const AppliedListV2()),
  ]);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitView multiSplitView = MultiSplitView(
      controller: multiSplitViewController,
      onDividerDragEnd: (_) async {
        final prefs = await SharedPreferences.getInstance();
        splitViewFlexValue0 = multiSplitViewController.getArea(0).flex!;
        prefs.setDouble('splitViewFlexValue0', splitViewFlexValue0);
        splitViewFlexValue1 = multiSplitViewController.getArea(1).flex!;
        prefs.setDouble('splitViewFlexValue1', splitViewFlexValue1);
        splitViewFlexValue2 = multiSplitViewController.getArea(2).flex!;
        prefs.setDouble('splitViewFlexValue2', splitViewFlexValue2);
        // debugPrint('Index: $index : ${multiSplitViewController.getArea(index).flex}');
      },
      onDividerDoubleTap: (_) async {
        final prefs = await SharedPreferences.getInstance();
        splitViewFlexValue0 = 1;
        splitViewFlexValue1 = 1;
        splitViewFlexValue2 = 1;
        prefs.setDouble('splitViewFlexValue0', splitViewFlexValue0);
        prefs.setDouble('splitViewFlexValue1', splitViewFlexValue1);
        prefs.setDouble('splitViewFlexValue2', splitViewFlexValue2);
        multiSplitViewController.getArea(0).flex = splitViewFlexValue0;
        multiSplitViewController.getArea(1).flex = splitViewFlexValue1;
        multiSplitViewController.getArea(2).flex = splitViewFlexValue2;

        setState(() {});
      },
    );
    return MultiSplitViewTheme(
        data: MultiSplitViewThemeData(dividerPainter: DividerPainters.grooved2(count: 49, highlightedCount: 99, highlightedColor: Theme.of(context).colorScheme.primary)), child: multiSplitView);
  }
}
