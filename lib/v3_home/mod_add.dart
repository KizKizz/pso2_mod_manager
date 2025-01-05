
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/mod_add/drag_drop_box_layout.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_buttons.dart';
import 'package:signals/signals_flutter.dart';

Signal<bool> isModDragDropListEmpty = Signal(true);

class ModAdd extends StatefulWidget {
  const ModAdd({super.key});

  @override
  State<ModAdd> createState() => _ModAddState();
}

class _ModAddState extends State<ModAdd> {
  double fadeInOpacity = 0;
  List<String> dragDropSupportedExts = ['.7z', '.zip', '.rar'];

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
    return Row(
      spacing: 5,
      children: [
        Expanded(flex: 1, child: DragDropBoxLayout(dragDropFileTypes: dragDropSupportedExts)),
        ModAddButtons(dragDropFileTypes: dragDropSupportedExts),
        Expanded(flex: 2, child: Container())
      ],
    );
  }
}
