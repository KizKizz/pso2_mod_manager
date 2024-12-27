import 'package:flutter/material.dart';

class ModManTooltip extends StatelessWidget {
  const ModManTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: message,
        height: 25,
        textStyle: const TextStyle(fontSize: 14),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor.withAlpha(200),
            border: Border.all(color: Theme.of(context).primaryColorLight, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        waitDuration: const Duration(milliseconds: 500),
        child: child);
  }
}
