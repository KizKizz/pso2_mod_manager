import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class ModCardOverlay extends StatefulWidget {
  const ModCardOverlay({super.key, required this.paddingValue, required this.child});

  final Widget child;
  final double paddingValue;

  @override
  State<ModCardOverlay> createState() => _ModCardOverlayState();
}

class _ModCardOverlayState extends State<ModCardOverlay> {
  double fadeInOpacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 50), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: fadeInOpacity,
        duration: const Duration(milliseconds: 100),
        child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(widget.paddingValue),
            child: widget.child,
          ),
        ));
  }
}
