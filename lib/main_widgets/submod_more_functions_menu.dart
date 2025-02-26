import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/export_import/export_import_functions.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_bounding_radius/bounding_radius_popup.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_popup.dart';
import 'package:pso2_mod_manager/main_widgets/popup_menu_functions.dart';
import 'package:pso2_mod_manager/mod_apply/apply_location_popup.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/load_mods.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v2_home/homepage_v2.dart';
import 'package:pso2_mod_manager/v3_widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SubmodMoreFunctionsMenu extends StatefulWidget {
  const SubmodMoreFunctionsMenu({super.key, required this.item, required this.mod, required this.submod, required this.isInPopup, required this.refresh});

  final Item item;
  final Mod mod;
  final SubMod submod;
  final bool isInPopup;
  final VoidCallback refresh;

  @override
  State<SubmodMoreFunctionsMenu> createState() => _SubmodMoreFunctionsMenuState();
}

class _SubmodMoreFunctionsMenuState extends State<SubmodMoreFunctionsMenu> {
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
              onTap: () async {
                await submodAddToSet(context, widget.item, widget.mod, widget.submod);
                setState(() {});
                widget.refresh();
              },
              child: MenuIconItem(
                icon: Icons.list_alt_outlined,
                text: appText.modSets,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () async {
                widget.submod.applyLocations = await modApplyLocationPopup(context, widget.submod);
                setState(() {});
                widget.refresh();
              },
              child: ModManTooltip(
                  message: widget.submod.applyLocations!.isNotEmpty
                      ? appText.dText(appText.currentlyApplyingToLocations, widget.submod.applyLocations!.join(', '))
                      : appText.dText(appText.currentlyApplyingToLocations, appText.allLocations),
                  child: MenuIconItem(
                    icon: Icons.add_location_alt_outlined,
                    text: appText.setApplyLocations,
                    enabled: true,
                  ))),
          PopupMenuItem(
              onTap: () {
                widget.submod.applyHQFilesOnly! ? widget.submod.applyHQFilesOnly = false : widget.submod.applyHQFilesOnly = true;
                setState(() {});
                widget.refresh();
                saveMasterModListToJson();
              },
              enabled: applyHQFilesCategoryDirs.contains(widget.submod.category),
              child: Row(
                spacing: 5,
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Icons.high_quality), Text(appText.applyHQFilesOnly), Visibility(visible: widget.submod.applyHQFilesOnly!, child: const Icon(Icons.check))],
              )),
          const PopupMenuItem(
              height: 0,
              enabled: false,
              child: PopupMenuDivider(
                height: 5,
              )),
          PopupMenuItem(
              onTap: () async => await modSwapPopup(context, widget.item, widget.mod, widget.submod),
              child: MenuIconItem(
                icon: Icons.swap_horizontal_circle_outlined,
                text: appText.swapToAnotherItem,
                enabled: true,
              )),
          PopupMenuItem(
              enabled: false,
              child: MenuIconItem(
                icon: Icons.file_present,
                text: appText.cmx,
                enabled: true,
              )),
          PopupMenuItem(
              enabled: boundingRadiusCategoryDirs.contains(widget.submod.category) && !widget.submod.applyStatus,
              onTap: () async {
                await boundingRadiusPopup(context, widget.submod);
                // widget.submod.boundingRemoved = true;
                saveMasterModListToJson();
                setState(() {});
                widget.refresh();
              },
              child: MenuIconItem(
                icon: Icons.radio_button_on_sharp,
                text: appText.removeBoundingRadius,
                enabled: boundingRadiusCategoryDirs.contains(widget.submod.category) && !widget.submod.applyStatus,
              )),
          if (!widget.submod.customAQMInjected!)
            PopupMenuItem(
                enabled: aqmInjectCategoryDirs.contains(widget.submod.category) &&
                    !widget.submod.applyStatus &&
                    !widget.submod.customAQMInjected! &&
                    selectedCustomAQMFilePath.watch(context).isNotEmpty &&
                    File(selectedCustomAQMFilePath.value).existsSync(),
                onTap: () async {
                  await submodAqmInject(context, widget.submod);
                  setState(() {});
                  widget.refresh();
                },
                child: MenuIconItem(icon: Icons.auto_fix_high, text: appText.injectCustomAQM, enabled: true)),
          if (widget.submod.customAQMInjected!)
            PopupMenuItem(
                enabled: aqmInjectCategoryDirs.contains(widget.submod.category) && !widget.submod.applyStatus && widget.submod.customAQMInjected!,
                onTap: () async {
                  await submodCustomAqmRemove(context, widget.submod);
                  setState(() {});
                  widget.refresh();
                },
                child: MenuIconItem(
                  icon: Icons.auto_fix_off,
                  text: appText.removeCustomAQMs,
                  enabled: true,
                )),
          const PopupMenuItem(
              height: 0,
              enabled: false,
              child: PopupMenuDivider(
                height: 5,
              )),
          PopupMenuItem(
              onTap: () async {
                await addPreviews(widget.mod, widget.submod);
                setState(() {});
                widget.refresh();
              },
              child: MenuIconItem(
                icon: Icons.preview_outlined,
                text: appText.addPreviews,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () => modExportSequence(context, ExportType.submods, widget.item, widget.mod, widget.submod),
              child: MenuIconItem(
                icon: Icons.import_export,
                text: appText.export,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () async => await submodRename(context, widget.mod, widget.submod),
              child: MenuIconItem(
                icon: Icons.edit,
                text: appText.rename,
                enabled: true,
              )),
          PopupMenuItem(
              onTap: () => launchUrlString(widget.submod.location),
              child: MenuIconItem(
                icon: Icons.folder_open,
                text: appText.openInFileExplorer,
                enabled: true,
              )),
          const PopupMenuItem(
              height: 0,
              enabled: false,
              child: PopupMenuDivider(
                height: 5,
              )),
          PopupMenuItem(
              enabled: !widget.submod.applyStatus && widget.submod.location != widget.mod.location,
              onTap: () async {
                await submodDelete(context, widget.item, widget.mod, widget.submod);
                widget.mod.isNew = widget.mod.getSubmodsIsNewState();
                widget.item.isNew = widget.item.getModsIsNewState();
                modPopupStatus.value = '${widget.submod.submodName} deleted';
                if (widget.mod.submods.isEmpty) {
                  mainGridStatus.value = '"${widget.mod.modName}" in "${widget.item.getDisplayName()}" is empty and removed';
                }
                if (widget.item.mods.isEmpty) {
                  mainGridStatus.value = '"${widget.item.getDisplayName()}" is empty and removed';
                  if (selectedItemV2.value == widget.item) selectedItemV2.value = null;
                  // ignore: use_build_context_synchronously
                  if (widget.isInPopup) Navigator.of(context).pop;
                }
              },
              child: MenuIconItem(
                icon: Icons.delete_forever_outlined,
                text: appText.delete,
                enabled: !widget.submod.applyStatus && widget.submod.location != widget.mod.location,
              )),
        ];
      },
    );
  }
}

class MenuIconItem extends StatelessWidget {
  const MenuIconItem({super.key, required this.icon, required this.text, required this.enabled});

  final IconData icon;
  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            color: !enabled
                ? Theme.of(context).disabledColor
                : text == appText.delete
                    ? Colors.redAccent
                    : Theme.of(context).iconTheme.color),
        Text(
          text,
          style: TextStyle(
              color: !enabled
                  ? Theme.of(context).disabledColor
                  : text == appText.delete
                      ? Colors.redAccent
                      : null),
        )
      ],
    );
  }
}
