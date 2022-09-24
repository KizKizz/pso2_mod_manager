import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
        iconNormal: Theme.of(context).textTheme.button!.color,
        mouseOver: Theme.of(context).buttonTheme.colorScheme!.background,
        mouseDown: Theme.of(context).highlightColor,
        iconMouseOver: Theme.of(context).textTheme.button!.color,
        iconMouseDown: Theme.of(context).textTheme.button!.color);

    final closeButtonColors = WindowButtonColors(
        mouseOver: const Color(0xFFD32F2F),
        mouseDown: const Color(0xFFB71C1C),
        iconNormal: Theme.of(context).textTheme.button!.color,
        iconMouseOver: Colors.white);

    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
