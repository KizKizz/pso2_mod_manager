import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:pso2_mod_manager/v3_widgets/delete_confirm_popup.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_custom_image_tile.dart';
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
      child: CardOverlay(
        paddingValue: 5,
          child: SuperListView.separated(
        physics: const SuperRangeMaintainingScrollPhysics(),
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
        separatorBuilder: (BuildContext context, int index) => const SizedBox(
          height: 5,
        ),
      )),
    );
  }
}
