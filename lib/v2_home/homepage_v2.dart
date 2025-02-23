import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/v2_home/item_list_v2.dart';

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
        initialAreas: [Area(flex: 1, builder: (context, area) => ItemListV2(refresh: () => setState(() {}))),
        Area(flex: 1, builder: (context, area) => ItemListV2(refresh: () => setState(() {}))),
        Area(flex: 1, builder: (context, area) => ItemListV2(refresh: () => setState(() {}))),]);
    return multiSplitView;
  }
}
