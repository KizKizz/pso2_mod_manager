import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class FavoriteBox extends StatelessWidget {
  const FavoriteBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          child: Center(child: Icon(Icons.favorite, size: 20, color: Theme.of(context).textTheme.labelLarge!.color)),
        ));
  }
}
