import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_custom_image_tile.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:path/path.dart' as p;

class VitalGaugeCustomImageGridLayout extends StatefulWidget {
  const VitalGaugeCustomImageGridLayout({super.key, required this.customImageFiles});

  final List<File> customImageFiles;

  @override
  State<VitalGaugeCustomImageGridLayout> createState() => _VitalGaugeCustomImageGridLayoutState();
}

class _VitalGaugeCustomImageGridLayoutState extends State<VitalGaugeCustomImageGridLayout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SignalBuilder(
        builder: (context) => CardOverlay(
          paddingValue: 5,
          rightPaddingValue: scrollbarsAlwaysVisible.value ? 0 : null,
          child: ScrollbarTheme(
            data: ScrollbarThemeData(trackVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value), thumbVisibility: WidgetStatePropertyAll(scrollbarsAlwaysVisible.value)),
            child: SuperListView.separated(
              physics: const SuperRangeMaintainingScrollPhysics(),
              padding: EdgeInsets.only(right: scrollbarsAlwaysVisible.value ? 15 : 0),
              itemCount: widget.customImageFiles.length,
              itemBuilder: (context, index) {
                return VitalGaugeCustomImageTile(
                  customImageFile: widget.customImageFiles[index],
                  onDeleteButtonPress: () async {
                    final result = await deleteConfirmPopup(context, p.basename(widget.customImageFiles[index].path));
                    if (result) {
                      await File(widget.customImageFiles[index].path).delete();
                      widget.customImageFiles.remove(widget.customImageFiles[index]);
                      setState(() {});
                    }
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 5),
            ),
          ),
        ),
      ),
    );
  }
}
