import 'dart:io';

import 'package:flutter/material.dart';

class LineStrikeBoardImageTile extends StatefulWidget {
  const LineStrikeBoardImageTile({super.key, required this.customImageFile, required this.onDeleteButtonPress});

  final File customImageFile;
  final VoidCallback onDeleteButtonPress;

  @override
  State<LineStrikeBoardImageTile> createState() => _LineStrikeBoardImageTileState();
}

class _LineStrikeBoardImageTileState extends State<LineStrikeBoardImageTile> {
  @override
  Widget build(BuildContext context) {
    return Draggable(
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Image.file(
        widget.customImageFile,
        scale: 1.4,
        filterQuality: FilterQuality.high,
        fit: BoxFit.fill,
      ),
      data: widget.customImageFile.path,
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          AspectRatio(
            aspectRatio: 867 / 488,
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
