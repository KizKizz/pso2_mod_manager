import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_background_tile.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_class.dart';
import 'package:signals/signals_flutter.dart';
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
    return SignalBuilder(
      builder: (context) => CardOverlay(
        paddingValue: 5,
        rightPaddingValue: scrollbarsAlwaysVisible.value ? 0 : null,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(trackVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value), thumbVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value)),
          child: SuperListView.separated(
            physics: const SuperRangeMaintainingScrollPhysics(),
            padding: EdgeInsets.only(right: scrollbarsAlwaysVisible.value ? 15 : 0),
            itemCount: widget.backgrounds.length,
            itemBuilder: (context, index) {
              return VitalGaugeBackgroundTile(vitalGaugeBackgroundList: widget.backgrounds, background: widget.backgrounds[index], showButtons: widget.showButtons);
            },
            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5),
          ),
        ),
      ),
    );
  }
}
