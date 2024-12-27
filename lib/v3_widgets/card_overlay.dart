import 'package:flutter/material.dart';

class CardOverlay extends StatefulWidget {
  const CardOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<CardOverlay> createState() => _CardOverlayState();
}

class _CardOverlayState extends State<CardOverlay> {
  double fadeInOpacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      fadeInOpacity = 1;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: fadeInOpacity,
        duration: const Duration(milliseconds: 500),
        child: Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
          margin: EdgeInsets.zero,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: widget.child,
          ),
        ));
  }
}
