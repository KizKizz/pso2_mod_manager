import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

class PreviewImageStack extends StatelessWidget {
  const PreviewImageStack({super.key, required this.imagePath, required this.overlayText});

  final String imagePath;
  final String overlayText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.file(
          File(imagePath),
          width: double.infinity,
          height: double.infinity,
          //fit: BoxFit.cover,
        ),
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Theme.of(context).hintColor),
              ),
              height: 25,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Text(overlayText.replaceFirst(p.separator, '').replaceAll(p.separator, ' > '), style: const TextStyle(fontSize: 17)),
              ))),
        )
      ],
    );
  }
}
