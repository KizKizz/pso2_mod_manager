import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({super.key, required this.info});

  final String info;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha),
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Center(child: Text(info)),
        ));
  }
}
