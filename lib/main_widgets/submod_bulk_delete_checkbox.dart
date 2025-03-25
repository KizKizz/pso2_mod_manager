import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/mod_bulk_delete_button.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';

class SubmodBulkDeleteCheckbox extends StatefulWidget {
  const SubmodBulkDeleteCheckbox({super.key, required this.item, required this.mod, required this.submod, required this.enabled});

  final Item item;
  final Mod mod;
  final SubMod submod;
  final bool enabled;

  @override
  State<SubmodBulkDeleteCheckbox> createState() => _SubmodBulkDeleteCheckboxState();
}

class _SubmodBulkDeleteCheckboxState extends State<SubmodBulkDeleteCheckbox> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      visualDensity: VisualDensity.adaptivePlatformDensity,
      value: bulkDeleteMods.indexWhere((e) => e.$2 == widget.mod) != -1 || bulkDeleteSubmods.indexWhere((e) => e.$3 == widget.submod) != -1 ? true : false,
      onChanged: widget.enabled
          ? (value) {
              if (!value!) {
                bulkDeleteSubmods.removeWhere((e) => widget.submod == e.$3);
                modPopupStatus.value = 'Removed ${widget.submod.modName} > ${widget.submod.submodName} from removal list';
              } else {
                bulkDeleteMods.remove((widget.item, widget.mod));
                bulkDeleteSubmods.add((widget.item, widget.mod, widget.submod));
                modPopupStatus.value = 'Added ${widget.submod.modName} > ${widget.submod.submodName} to removal list';
              }
            }
          : null,
    );
  }
}
