import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PopupListTile extends StatefulWidget {
  const PopupListTile({super.key, required this.item, required this.mod, required this.selectedMod, required this.onSelectedMod});

  final Item item;
  final Mod mod;
  final Mod? selectedMod;
  final VoidCallback onSelectedMod;

  @override
  State<PopupListTile> createState() => _PopupListTileState();
}

class _PopupListTileState extends State<PopupListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
        data: ListTileThemeData(selectedTileColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context))),
        child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            selected: widget.selectedMod == widget.mod ? true : false,
            title: Text(widget.mod.modName),
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
                PopupMenuButton(
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                  color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiBackgroundColorAlpha.watch(context) + 50),
                  padding: EdgeInsets.zero,
                  menuPadding: EdgeInsets.zero,
                  tooltip: '',
                  elevation: 5,
                  style: ButtonStyle(
                      visualDensity: VisualDensity.adaptivePlatformDensity,
                      shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(20))))),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(child: MenuIconItem(icon: Icons.import_export, text: appText.export)),
                      PopupMenuItem(onTap: () async => await modRename(context, widget.mod), child: MenuIconItem(icon: Icons.edit, text: appText.rename)),
                      PopupMenuItem(onTap: () => launchUrlString(widget.mod.location), child: MenuIconItem(icon: Icons.folder_open, text: appText.openInFileExplorer)),
                      const PopupMenuItem(
                          height: 0,
                          enabled: false,
                          child: PopupMenuDivider(
                            height: 5,
                          )),
                      PopupMenuItem(
                          enabled: !widget.mod.applyStatus,
                          onTap: () async {
                            await modDelete(context, widget.item, widget.mod);
                            modPopupStatus.value = '${widget.mod.modName} deleted';
                            if (widget.item.mods.isEmpty) {
                              mainGridStatus.value = '"${widget.mod.modName}" in "${widget.item.itemName}" is empty and removed';
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                          },
                          child: MenuIconItem(icon: Icons.delete_forever_outlined, text: appText.delete)),
                    ];
                  },
                )
              ],
            ),
            onTap: () => widget.onSelectedMod()));
  }
}
