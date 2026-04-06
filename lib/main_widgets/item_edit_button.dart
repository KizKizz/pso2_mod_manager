import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/main_widgets/mod_bulk_delete_button.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class ItemEditButton extends StatefulWidget {
  const ItemEditButton({super.key, required this.onPressed});

  final Function(bool isEditing) onPressed;

  @override
  State<ItemEditButton> createState() => _ItemEditButtonState();
}

class _ItemEditButtonState extends State<ItemEditButton> {
  bool isEditing = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: IconButton.outlined(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
              side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
          onPressed: () async {
            isEditing ? isEditing = false : isEditing = true;
            widget.onPressed(isEditing);
            bulkDeleteMods.clear();
            bulkDeleteSubmods.clear();
            setState(() {});
          },
          icon: Icon(
            isEditing == true ? Icons.close : Icons.edit_note,
          )),
    );
  }
}
