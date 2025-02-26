import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/mod_add/adding_mod_class.dart';
import 'package:pso2_mod_manager/mod_add/drag_drop_box_layout.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_buttons.dart';
import 'package:pso2_mod_manager/mod_add/mod_add_grid.dart';
import 'package:pso2_mod_manager/v3_widgets/card_overlay.dart';
import 'package:signals/signals_flutter.dart';

Signal<ModAddDragDropState> curModAddDragDropStatus = Signal<ModAddDragDropState>(ModAddDragDropState.waitingForFiles);
Signal<ModAddProcessedState> curModAddProcessedStatus = Signal<ModAddProcessedState>(ModAddProcessedState.waiting);
Signal<bool> modAddDropBoxShow = Signal(true);
List<AddingMod> modAddingList = [];

class ModAdd extends StatefulWidget {
  const ModAdd({super.key});

  @override
  State<ModAdd> createState() => _ModAddState();
}

class _ModAddState extends State<ModAdd> {
  double fadeInOpacity = 0;
  List<String> dragDropSupportedExts = ['.7z', '.zip', '.rar', '.pmm'];

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
    return Row(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: modAddDropBoxShow.watch(context) ? 1 : 0,
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  spacing: modAddDropBoxShow.watch(context) ? 1 : 0, 
                  children: [
                  Visibility(
                    visible: modAddDropBoxShow.watch(context),
                    child: Expanded(child: DragDropBoxLayout(dragDropFileTypes: dragDropSupportedExts))),
                  SizedBox(
                      width: 15,
                      height: double.infinity,
                      child: CardOverlay(
                        paddingValue: 0,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              modAddDropBoxShow.value ? modAddDropBoxShow.value = false : modAddDropBoxShow.value = true;
                            },
                            icon: Icon(modAddDropBoxShow.watch(context) ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded, size: 16,)),
                      )),
                ]),
              ),
              Visibility(
                visible: modAddDropBoxShow.watch(context),
                child: ModAddDragDropButtons(dragDropFileTypes: dragDropSupportedExts)),
            ],
          ),
        ),
        const Expanded(
          flex: 2,
          child: Column(
            spacing: 5,
            children: [
              Expanded(child: ModAddGrid()),
              ModAddProcessedButtons(),
            ],
          ),
        )
      ],
    );
  }
}
