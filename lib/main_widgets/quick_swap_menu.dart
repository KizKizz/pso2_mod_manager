import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/item_swap/mod_swap_popup.dart';
import 'package:pso2_mod_manager/main_widgets/submod_more_functions_menu.dart';
import 'package:pso2_mod_manager/mod_add/item_data_class.dart';
import 'package:pso2_mod_manager/mod_data/item_class.dart';
import 'package:pso2_mod_manager/mod_data/mod_class.dart';
import 'package:pso2_mod_manager/mod_data/sub_mod_class.dart';
import 'package:pso2_mod_manager/quick_swap/quick_swap_items_popup.dart';
import 'package:pso2_mod_manager/quick_swap/quick_swap_working_popup.dart';
import 'package:pso2_mod_manager/v3_widgets/generic_item_icon_box.dart';
import 'package:signals/signals_flutter.dart';

class QuickSwapMenu extends StatefulWidget {
  const QuickSwapMenu({super.key, required this.item, required this.mod, required this.submod});

  final Item item;
  final Mod mod;
  final SubMod submod;

  @override
  State<QuickSwapMenu> createState() => _QuickSwapMenuState();
}

class _QuickSwapMenuState extends State<QuickSwapMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(uiDialogBackgroundColorAlpha.watch(context)),
        padding: EdgeInsets.zero,
        menuPadding: EdgeInsets.zero,
        icon: const Icon(Icons.add),
        tooltip: '',
        elevation: 5,
        style: ButtonStyle(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1), borderRadius: const BorderRadius.all(Radius.circular(20))))),
        itemBuilder: (BuildContext context) {
          List<ItemData> selectedQuickSwapItems = masterQuickSwapItemList
              .where((e) =>
                  e.getName().isNotEmpty &&
                      (e.category == widget.submod.category ||
                          widget.submod.category == defaultCategoryDirs[16] && e.category == defaultCategoryDirs[1] ||
                          widget.submod.category == defaultCategoryDirs[2] && e.category == defaultCategoryDirs[11]) ||
                  widget.submod.category == defaultCategoryDirs[11] && e.category == defaultCategoryDirs[2])
              .toList();
          return [
            for (int i = 0; i < selectedQuickSwapItems.length; i++)
              PopupMenuItem(
                  enabled: selectedQuickSwapItems[i].getENName() != widget.item.itemName && selectedQuickSwapItems[i].getJPName() != widget.item.itemName,
                  onTap: () async {
                    List<ItemData> lItemData =
                        pItemData.where((e) => e.category == widget.submod.category && widget.submod.getModFileNames().indexWhere((f) => e.getIceDetailsWithoutKeys().contains(f)) != -1).toList();
                    quickSwapWorkingPopup(context, false, lItemData.first, selectedQuickSwapItems[i], widget.mod, widget.submod);
                    closeModSwapPopup.value = true;
                  },
                  child: Row(
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: GenericItemIconBox(iconImagePaths: [selectedQuickSwapItems[i].iconImagePath], boxSize: const Size(60, 60), isNetwork: true),
                      ),
                      Text(selectedQuickSwapItems[i].getName())
                    ],
                  )),
            PopupMenuItem(
                onTap: () async {
                  await quickSwapItemsPopup(context, widget.submod.category);
                  setState(() {});
                },
                child: MenuIconItem(
                  icon: Icons.add,
                  text: appText.selecteMoreItems,
                  enabled: true,
                )),
          ];
        });
  }
}
