import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/mod_bulk_delete_checkbox.dart';
import 'package:pso2_mod_manager/main_widgets/mod_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';

class PopupListTile extends StatefulWidget {
  const PopupListTile({super.key, required this.item, required this.mod, required this.selectedMod, required this.onSelectedMod, required this.onDelete, required this.isInEditingMode});

  final Item item;
  final Mod mod;
  final Mod? selectedMod;
  final VoidCallback onSelectedMod;
  final VoidCallback onDelete;
  final bool isInEditingMode;

  @override
  State<PopupListTile> createState() => _PopupListTileState();
}

class _PopupListTileState extends State<PopupListTile> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        ListTileTheme(
            data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                selected: widget.selectedMod == widget.mod ? true : false,
                title: Text(
                  widget.mod.modName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Row(
                  spacing: 5,
                  children: [
                    Text(appText.dText(widget.mod.submods.length > 1 ? appText.numVariants : appText.numVariant, widget.mod.submods.length.toString())),
                  ],
                ),
                trailing: Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(visible: widget.mod.applyStatus, child: Icon(Icons.turned_in, color: Theme.of(context).colorScheme.primary)),
                    if (!widget.isInEditingMode) ModMoreFunctionsMenu(item: widget.item, mod: widget.mod, onDelete: widget.onDelete),
                    if (widget.isInEditingMode) ModBulkDeleteCheckbox(item: widget.item, mod: widget.mod, enabled: !widget.mod.applyStatus),
                  ],
                ),
                onTap: () => widget.onSelectedMod())),
        if (widget.mod.isNew)
          Padding(
            padding: const EdgeInsets.only(top: 1.5, right: 2),
            child: Text(
              appText.xnew,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, backgroundColor: Colors.redAccent),
            ),
          ),
      ],
    );
  }
}
