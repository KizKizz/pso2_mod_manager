import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_background_tile.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class VitalGaugeBackgroundGridLayout extends StatefulWidget {
  const VitalGaugeBackgroundGridLayout({super.key, required this.backgrounds});

  final List<VitalGaugeBackground> backgrounds;

  @override
  State<VitalGaugeBackgroundGridLayout> createState() => _VitalGaugeBackgroundGridLayoutState();
}

class _VitalGaugeBackgroundGridLayoutState extends State<VitalGaugeBackgroundGridLayout> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SuperListView.separated(
      physics: const SuperRangeMaintainingScrollPhysics(),
      itemCount: widget.backgrounds.length,
      itemBuilder: (context, index) {
        return VitalGaugeBackgroundTile(vitalGaugeBackgroundList: widget.backgrounds, background: widget.backgrounds[index]);
      },
      separatorBuilder: (BuildContext context, int index) => const SizedBox(
        height: 5,
      ),
    ));
  }
}
