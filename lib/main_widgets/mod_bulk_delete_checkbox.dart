import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/mod_bulk_delete_button.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';

class ModBulkDeleteCheckbox extends StatefulWidget {
  const ModBulkDeleteCheckbox({super.key, required this.item, required this.mod, required this.enabled});

  final Item item;
  final Mod mod;
  final bool enabled;

  @override
  State<ModBulkDeleteCheckbox> createState() => _ModBulkDeleteCheckboxState();
}

class _ModBulkDeleteCheckboxState extends State<ModBulkDeleteCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tristate: true,
      value: bulkDeleteMods.indexWhere((e) => e.$2 == widget.mod) == -1 && bulkDeleteSubmods.indexWhere((e) => widget.mod.submods.contains(e.$3)) != -1
          ? null
          : bulkDeleteMods.indexWhere((e) => e.$2 == widget.mod) != -1
              ? true
              : false,
      onChanged: widget.enabled
          ? (value) {
              if (value == null || !value) {
                bulkDeleteMods.remove((widget.item, widget.mod));
                bulkDeleteSubmods.removeWhere((e) => widget.mod.submods.contains(e.$3));
                modPopupStatus.value = 'Removed ${widget.mod.modName} from removal list';
              } else {
                bulkDeleteMods.add((widget.item, widget.mod));
                bulkDeleteSubmods.removeWhere((e) => widget.mod.submods.contains(e.$3));
                modPopupStatus.value = 'Added ${widget.mod.modName} to removal list';
              }
            }
          : null,
    );
  }
}
