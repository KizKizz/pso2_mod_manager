import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/state_provider.dart';

class ModManTooltip extends StatelessWidget {
  const ModManTooltip({Key? key, required this.message, required this.child}) : super(key: key);

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: message,
        height: 25,
        textStyle: const TextStyle(fontSize: 14),
        decoration: BoxDecoration(
            color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
            border: Border.all(color: Theme.of(context).primaryColorLight),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        waitDuration: const Duration(milliseconds: 500),
        child: child);
  }
}
