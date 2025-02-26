import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/main_widgets/mod_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:signals/signals_flutter.dart';

class PopupListTile extends StatefulWidget {
  const PopupListTile({super.key, required this.item, required this.mod, required this.selectedMod, required this.onSelectedMod, required this.onDelete});

  final Item item;
  final Mod mod;
  final Mod? selectedMod;
  final VoidCallback onSelectedMod;
  final VoidCallback onDelete;

  @override
  State<PopupListTile> createState() => _PopupListTileState();
}

class _PopupListTileState extends State<PopupListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: widget.mod.isNew
          ? RotatedCornerDecoration.withColor(
              color: Colors.redAccent.withAlpha(220),
              badgeSize: const Size(32, 32),
              textSpan: TextSpan(
                text: appText.xnew,
                style: Theme.of(context).textTheme.labelSmall,
              ))
          : null,
      child: ListTileTheme(
          data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
          child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              selected: widget.selectedMod == widget.mod ? true : false,
              title: Text(widget.mod.modName, style: const TextStyle(fontWeight: FontWeight.w500),),
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
                  ModMoreFunctionsMenu(item: widget.item, mod: widget.mod, onDelete: widget.onDelete)
                ],
              ),
              onTap: () => widget.onSelectedMod())),
    );
  }
}
