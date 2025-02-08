import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/export_import/export_import_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/main_widgets/item_icon_box.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/main_widgets/submod_grid_layout.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PopupItemInfo extends StatefulWidget {
  const PopupItemInfo({super.key, required this.item, required this.showModInfo});

  final Item item;
  final bool showModInfo;

  @override
  State<PopupItemInfo> createState() => _PopupItemInfoState();
}

class _PopupItemInfoState extends State<PopupItemInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        ItemIconBox(item: widget.item),
        Text(
          appText.categoryName(widget.item.category),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          widget.item.itemName.replaceFirst('_', '/').trim(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          spacing: 5,
          children: [
            Visibility(
              visible: widget.showModInfo,
              child: Expanded(
                child: InfoBox(
                  info: appText.dText(widget.item.mods.length > 1 ? appText.numMods : appText.numMod, widget.item.mods.length.toString()),
                  borderHighlight: false,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: InfoBox(
                info: appText.dText(appText.numCurrentlyApplied, widget.item.getNumOfAppliedMods().toString()),
                borderHighlight: widget.item.applyStatus,
              ),
            ),
          ],
        ),
        Row(
          spacing: 5,
          children: [
            Expanded(child: OutlinedButton(onPressed: () => launchUrlString(widget.item.location), child: Text(appText.openInFileExplorer))),
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
                  PopupMenuItem(onTap: () => modExportSequence(context, ExportType.item, widget.item, null, null), child: MenuIconItem(icon: Icons.import_export, text: appText.export)),
                  PopupMenuItem(
                      enabled: !widget.item.applyStatus,
                      onTap: () async {
                        await itemDelete(context, widget.item);
                        mainGridStatus.value = '"${widget.item.itemName}" removed';
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      child: MenuIconItem(icon: Icons.delete_forever_outlined, text: appText.delete)),
                ];
              },
            )
          ],
        ),
      ],
    );
  }
}
