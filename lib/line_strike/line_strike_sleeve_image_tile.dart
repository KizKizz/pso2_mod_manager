import 'dart:io';

import 'package:flutter/material.dart';

class LineStrikeSleeveCustomImageTile extends StatefulWidget {
  const LineStrikeSleeveCustomImageTile({super.key, required this.customImageFile, required this.onDeleteButtonPress});

  final File customImageFile;
  final VoidCallback onDeleteButtonPress;

  @override
  State<LineStrikeSleeveCustomImageTile> createState() => _LineStrikeSleeveCustomImageTileState();
}

class _LineStrikeSleeveCustomImageTileState extends State<LineStrikeSleeveCustomImageTile> {
  @override
  Widget build(BuildContext context) {
    return Draggable(
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Image.file(
        widget.customImageFile,
        scale: 1,
        filterQuality: FilterQuality.high,
        fit: BoxFit.fill,
      ),
      data: widget.customImageFile.path,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          AspectRatio(
            aspectRatio: 183 / 256,
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
