import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/export_import/export_import_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_all_popup.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ModMoreFunctionsMenu extends StatefulWidget {
  const ModMoreFunctionsMenu({super.key, required this.item, required this.mod, required this.onDelete});

  final Item item;
  final Mod mod;
  final VoidCallback onDelete;

  @override
  State<ModMoreFunctionsMenu> createState() => _ModMoreFunctionsMenuState();
}

class _ModMoreFunctionsMenuState extends State<ModMoreFunctionsMenu> {
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
              onTap: () => modExportSequence(context, ExportType.mods, widget.item, widget.mod, null, null),
              child: MenuIconItem(
                icon: Icons.ios_share,
                text: appText.share,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () => modSwapAllPopup(context, widget.item, widget.mod),
              child: MenuIconItem(
                icon: Icons.swap_horizontal_circle_outlined,
                text: appText.swapAll,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () async {
                await modRename(context, widget.mod);
                mainGridStatus.value = '"${widget.mod.modName}" in "${widget.item.getDisplayName()}" is renamed';
              },
              child: MenuIconItem(icon: Icons.edit, text: appText.rename, enabled: true)),
          PopupMenuItem(onTap: () => launchUrlString(widget.mod.location), child: MenuIconItem(icon: Icons.folder_open, text: appText.openInFileExplorer, enabled: true)),
          const PopupMenuItem(
              height: 0,
              enabled: false,
              child: PopupMenuDivider(
                height: 5,
              )),
          PopupMenuItem(
              enabled: !widget.mod.applyStatus,
              onTap: widget.onDelete,
              child: MenuIconItem(
                icon: Icons.delete_forever_outlined,
                text: appText.delete,
                enabled: !widget.mod.applyStatus,
              )),
        ];
      },
    );
  }
}
