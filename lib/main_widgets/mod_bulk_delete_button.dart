import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:signals/signals_flutter.dart';

List<(Item, Mod)> bulkDeleteMods = [];
List<(Item, Mod, SubMod)> bulkDeleteSubmods = [];

class ModBulkDeleteButton extends StatefulWidget {
  const ModBulkDeleteButton({super.key, required this.enabled, required this.isPopup});

  final bool enabled;
  final bool isPopup;

  @override
  State<ModBulkDeleteButton> createState() => _ModBulkDeleteButtonState();
}

class _ModBulkDeleteButtonState extends State<ModBulkDeleteButton> {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
          side: WidgetStatePropertyAll(BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5))),
      onPressed: widget.enabled ? () async {} : null,
      onLongPress: () async {
        for (var element in bulkDeleteSubmods) {
          await submodDelete(context, element.$1, element.$2, element.$3, true);
          element.$2.isNew = element.$2.getSubmodsIsNewState();
          element.$1.isNew = element.$1.getModsIsNewState();
          modPopupStatus.value = '${element.$3.submodName} deleted';
          if (element.$2.submods.isEmpty) {
            mainGridStatus.value = '"${element.$2.modName}" in "${element.$1.getDisplayName()}" is empty and removed';
          }
          if (element.$1.mods.isEmpty) {
            mainGridStatus.value = '"${element.$1.getDisplayName()}" is empty and removed';
            if (selectedItemV2.value == element.$1) selectedItemV2.value = null;
            // ignore: use_build_context_synchronously
            if (widget.isPopup) Navigator.of(context).pop;
          }
        }

        for (var element in bulkDeleteMods) {
          // ignore: use_build_context_synchronously
          await modDelete(context, element.$1, element.$2, true);
          modPopupStatus.value = '${element.$2.modName} deleted';
          element.$1.isNew = element.$1.getModsIsNewState();
          if (element.$1.mods.isEmpty) {
            mainGridStatus.value = '"${element.$2.modName}" in "${element.$1.getDisplayName()}" is empty and removed';
            if (selectedItemV2.value == element.$1) selectedItemV2.value = null;
            // ignore: use_build_context_synchronously
            if (widget.isPopup) Navigator.of(context).pop;
          }
        }
      },
      child: Text(
        appText.holdToDeleteSelected,
        style: TextStyle(color: widget.enabled ? Colors.redAccent : Theme.of(context).disabledColor),
      ),
    );
  }
}
