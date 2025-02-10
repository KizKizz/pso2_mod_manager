import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

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
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
            border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        waitDuration: const Duration(milliseconds: 0),
        child: child);
  }
}
