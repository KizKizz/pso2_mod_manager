import 'package:flutter/material.dart';

class SideBarButton extends StatefulWidget {
  const SideBarButton({super.key, required this.iconData, required this.label, required this.showLabel, required this.selected, required this.onPressed});

  final IconData iconData;
  final String label;
  final bool showLabel;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<SideBarButton> createState() => _SideBarButtonState();
}

class _SideBarButtonState extends State<SideBarButton> {
  @override
  Widget build(BuildContext context) {
    if (widget.showLabel) {
      return SizedBox(
        width: double.infinity,
        child: TextButton.icon(
            style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ))),
            onPressed: widget.onPressed,
            icon: Icon(widget.iconData, color: widget.selected ? Theme.of(context).colorScheme.primary : Theme.of(context).iconTheme.color),
            label: Text(widget.label, style: TextStyle(color: widget.selected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelLarge!.color),)),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: IconButton(
            style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ))),
            onPressed: widget.onPressed,
            icon: Icon(widget.iconData, color: widget.selected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.labelLarge!.color)),
      );
    }
  }
}
