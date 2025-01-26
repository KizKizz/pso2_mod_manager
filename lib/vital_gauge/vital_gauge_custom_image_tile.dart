import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';

class VitalGaugeCustomImageTile extends StatefulWidget {
  const VitalGaugeCustomImageTile({super.key, required this.customImageFile, required this.onDeleteButtonPress});

  final File customImageFile;
  final VoidCallback onDeleteButtonPress;

  @override
  State<VitalGaugeCustomImageTile> createState() => _VitalGaugeCustomImageTileState();
}

class _VitalGaugeCustomImageTileState extends State<VitalGaugeCustomImageTile> {
  @override
  Widget build(BuildContext context) {
    return Draggable(
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Container(
        width: 483,
        height: 100,
        decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
        child: Image.file(
          widget.customImageFile,
          filterQuality: FilterQuality.high,
          fit: BoxFit.fill,
        ),
      ),
      data: widget.customImageFile.path,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          AspectRatio(
            aspectRatio: 29 / 6,
            child: Container(
              decoration: ShapeDecoration(shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(0)))),
              child: Image.file(
                widget.customImageFile,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          OutlinedButton(onPressed: () => widget.onDeleteButtonPress, child: Text(appText.delete, style: const TextStyle(color: Colors.redAccent),))
        ],
      ),
    );
  }
}
