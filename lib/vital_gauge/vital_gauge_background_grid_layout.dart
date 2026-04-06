import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_background_tile.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class VitalGaugeBackgroundGridLayout extends StatefulWidget {
  const VitalGaugeBackgroundGridLayout({super.key, required this.backgrounds, required this.showButtons});

  final List<VitalGaugeBackground> backgrounds;
  final bool showButtons;

  @override
  State<VitalGaugeBackgroundGridLayout> createState() => _VitalGaugeBackgroundGridLayoutState();
}

class _VitalGaugeBackgroundGridLayoutState extends State<VitalGaugeBackgroundGridLayout> {
  @override
  Widget build(BuildContext context) {
    return CardOverlay(
      paddingValue: 5,
      child: SuperListView.separated(
        physics: const SuperRangeMaintainingScrollPhysics(),
        itemCount: widget.backgrounds.length,
        itemBuilder: (context, index) {
          return VitalGaugeBackgroundTile(vitalGaugeBackgroundList: widget.backgrounds, background: widget.backgrounds[index], showButtons: widget.showButtons,);
        },
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          height: 5,
        ),
      ),
    );
  }
}
