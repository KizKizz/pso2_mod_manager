import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/item_swap_all_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_all_popup.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:signals/signals_flutter.dart';

import '../export_import/export_import_functions.dart';

class ItemMoreFunctionsMenu extends StatefulWidget {
  const ItemMoreFunctionsMenu({super.key, required this.item, required this.mod, required this.isInsidePopup, required this.isSingleModView});

  final Item item;
  final Mod? mod;
  final bool isInsidePopup;
  final bool isSingleModView;

  @override
  State<ItemMoreFunctionsMenu> createState() => _ItemMoreFunctionsMenuState();
}

class _ItemMoreFunctionsMenuState extends State<ItemMoreFunctionsMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
      color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      tooltip: '',
      elevation: 5,
      style: ButtonStyle(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(20))))),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
              onTap: () => widget.isSingleModView ? modExportSequence(context, ExportType.mods, widget.item, widget.mod, null) : modExportSequence(context, ExportType.item, widget.item, null, null),
              child: MenuIconItem(icon: Icons.import_export, text: appText.export, enabled: true)),
          PopupMenuItem(
              onTap: () => widget.isSingleModView ? modSwapAllPopup(context, widget.item, widget.mod!) : itemSwapAllPopup(context, widget.item),
              child: MenuIconItem(
                icon: Icons.swap_horizontal_circle_outlined,
                text: appText.swapAll,
                enabled: true,
              )),
          PopupMenuItem(
              enabled: !widget.item.applyStatus && widget.isSingleModView ? widget.item.mods.length == 1 : true,
              onTap: () async {
                await itemDelete(context, widget.item);
                mainGridStatus.value = '[${DateTime.now()}] "${widget.item.getDisplayName()}" removed';
                if (selectedItemV2.value == widget.item) selectedItemV2.value = null;
                // ignore: use_build_context_synchronously
                if (widget.isInsidePopup) Navigator.of(context).pop();
              },
              child: MenuIconItem(icon: Icons.delete_forever_outlined, text: appText.delete, enabled: !widget.item.applyStatus && widget.isSingleModView ? widget.item.mods.length == 1 : true)),
        ];
      },
    );
  }
}
