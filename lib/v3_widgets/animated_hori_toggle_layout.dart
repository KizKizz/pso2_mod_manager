import 'package:animated_toggle/animated_toggle.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class AnimatedHorizontalToggleLayout extends StatefulWidget {
  const AnimatedHorizontalToggleLayout({super.key, required this.taps, required this.initialIndex, required this.width, required this.onChange});

  final List<String> taps;
  final int initialIndex;
  final double width;
  final Function(int currentIndex, int targetIndex) onChange;

  @override
  State<AnimatedHorizontalToggleLayout> createState() => _AnimatedHorizontalToggleLayoutState();
}

class _AnimatedHorizontalToggleLayoutState extends State<AnimatedHorizontalToggleLayout> {
  @override
  Widget build(BuildContext context) {
    return AnimatedHorizontalToggle(
        taps: widget.taps,
        width: widget.width,
        height: 36,
        duration: const Duration(milliseconds: 100),
        initialIndex: widget.initialIndex,
        background: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context)),
        activeColor: Theme.of(context).colorScheme.primaryContainer,
        activeTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.labelLarge!.color),
        inActiveTextStyle: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.labelLarge!.color),
        horizontalPadding: 4,
        verticalPadding: 4,
        activeHorizontalPadding: 2,
        activeVerticalPadding: 4,
        radius: 20,
        activeButtonRadius: 20,
        onChange: widget.onChange,
        showActiveButtonColor: true);
  }
}
