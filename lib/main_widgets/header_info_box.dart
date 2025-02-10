import 'package:flutter/material.dart';

class HeaderInfoBox extends StatelessWidget {
  const HeaderInfoBox({super.key, required this.info, required this.borderHighlight});

  final String info;
  final bool borderHighlight;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(side: BorderSide(color: borderHighlight? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(5))),
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          child: Center(child: Text(info)),
        ));
  }
}
