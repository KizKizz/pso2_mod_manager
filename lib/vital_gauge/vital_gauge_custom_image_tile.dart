import 'dart:io';

import 'package:flutter/material.dart';

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
          Padding(
            padding: const EdgeInsets.all(2.5),
            child: IconButton.filled(
                visualDensity: VisualDensity.adaptivePlatformDensity,
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(150))),
                onPressed: widget.onDeleteButtonPress,
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                )),
          )
        ],
      ),
    );
  }
}
