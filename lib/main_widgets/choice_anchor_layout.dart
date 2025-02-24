import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class ChoiceAnchorLayout extends StatelessWidget {
  const ChoiceAnchorLayout({super.key, required this.state, required this.openModal});

  final ChoiceController<String> state;
  final Function() openModal;

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(50))),
          tileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          contentPadding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 2),
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.labelLarge!.color),
          minTileHeight: 25,
          minVerticalPadding: 0,
          leadingAndTrailingTextStyle: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.labelLarge!.color)),
      child: ChoiceAnchor.create(
        valueTruncate: 2,
        inline: true,
      )(state, openModal),
    );
  }
}