// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_edit.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/apply_mods_functions.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/mod_deletion_dialog.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/mods_rename_functions.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/preview_dialog.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/functions/search_list_builder.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/home_page.dart';
import 'package:pso2_mod_manager/homepage/hp_widgets.dart';
import 'package:pso2_mod_manager/homepage/item_list.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_add_function.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_acc_swappage.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_data_loader.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_swappage.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';
import 'package:pso2_mod_manager/quickSwapApply/quick_swap_apply_popup.dart';
import 'package:pso2_mod_manager/sharing/mods_export.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/swapAll/swap_all_apply_popup.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/preview_hover_panel.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

bool hoveringOnSubmod = false;
bool hoveringOnModFile = false;
bool modViewListShowNew = false;
bool modViewListShowApplied = false;
// bool modViewListVisible != null;
final ValueNotifier<Item?> modViewItem = ValueNotifier<Item?>(null);

class ModView extends StatefulWidget {
  const ModView({super.key});

  @override
  State<ModView> createState() => _ModViewState();
}

class _ModViewState extends State<ModView> {
  List<bool> isModViewItemListExpanded = [];

  double modviewPanelWidth = 0;
  List<FocusNode> expansionListFNodes = [];

  ModViewListSort _modViewListSortState = ModViewListSort.none;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: modViewItem,
      builder: (BuildContext context, dynamic value, Widget? child) {
        modviewPanelWidth = appWindow.size.width * (viewsController.areas[1].weight! / 1);
        List<Mod> modViewMods = [];
        List<Mod> stateModFilters = [];

        //reset state
        if (modViewItem.value != null && modViewItem.value!.mods.indexWhere((e) => e.isNew) == -1) {
          modViewListShowNew = false;
        }
        if (modViewItem.value != null && modViewItem.value!.mods.indexWhere((e) => e.applyStatus) == -1) {
          modViewListShowApplied = false;
        }

        //Filters
        if (modViewItem.value != null) {
          if (modViewListShowNew && !modViewListShowApplied) {
            stateModFilters.addAll(modViewItem.value!.mods.where((e) => e.isNew).toList());
          } else if (modViewListShowApplied && !modViewListShowNew) {
            stateModFilters.addAll(modViewItem.value!.mods.where((e) => e.applyStatus).toList());
          } else if (modViewListShowNew && modViewListShowApplied) {
            stateModFilters = modViewItem.value!.mods.where((e) => e.isNew || e.applyStatus).toList();
          } else {
            stateModFilters = modViewItem.value!.mods.toList();
          }

          if (isFavListVisible && !isModViewFromApplied) {
            modViewMods = stateModFilters.where((e) => e.isFavorite).toList();
          } else if (searchTextController.value.text.toLowerCase().isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem.value!, searchTextController.value.text) > 0) {
            modViewMods = stateModFilters
                .where((e) =>
                    e.modName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) ||
                    e.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).isNotEmpty)
                .toList();
          } else if (context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied) {
            modViewMods = stateModFilters.where((e) => e.isSet && e.setNames.contains(selectedModSetName)).toList();
          } else {
            modViewMods = stateModFilters;
          }
        }

        //sort
        if (_modViewListSortState != context.watch<StateProvider>().modViewListSortState) {
          if (context.watch<StateProvider>().modViewListSortState == ModViewListSort.alphabeticalOrder) {
            _modViewListSortState = ModViewListSort.alphabeticalOrder;
          } else if (context.watch<StateProvider>().modViewListSortState == ModViewListSort.recentModsAdded) {
            _modViewListSortState = ModViewListSort.recentModsAdded;
          }
        }

        return Column(children: [
          AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            actions: <Widget>[
              Visibility(
                visible: modViewItem.value != null,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ModManTooltip(
                    message: curLangText!.uiClearAvailableModsView,
                    child: InkWell(
                        child: const Icon(
                          Icons.clear,
                        ),
                        onTap: () async {
                          modViewItem.value != null;
                          modViewItem.value = null;
                          setState(() {});
                        }),
                  ),
                ),
              ),
            ],
            title: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (modViewItem.value != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                      child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: modViewItem.value!.applyStatus
                                    ? Theme.of(context).colorScheme.primary
                                    : modViewItem.value!.isNew
                                        ? Colors.amber
                                        : Theme.of(context).hintColor,
                                width: modViewItem.value!.isNew || modViewItem.value!.applyStatus ? 3 : 1),
                          ),
                          child: modViewItem.value!.icons.first.contains('assets/img/placeholdersquare.png')
                              ? Image.asset(
                                  'assets/img/placeholdersquare.png',
                                  filterQuality: FilterQuality.none,
                                  fit: BoxFit.fitWidth,
                                )
                              : ItemIconsCarousel(iconPaths: modViewItem.value!.icons)),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: modViewItem.value != null ? 84 : 30,
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          // ignore: deprecated_member_use
                          thickness: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return modViewItem.value != null ? 5 : 0;
                            }
                            return modViewItem.value != null ? 3 : 0;
                          }),
                          thumbColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                            }
                            return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                          }),
                        ),
                        child: SingleChildScrollView(
                          physics: modViewItem.value == null ? const NeverScrollableScrollPhysics() : null,
                          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            modViewItem.value != null
                                ? Text(modViewItem.value!.category == defaultCategoryDirs[17]
                                    ? modViewItem.value!.itemName.split('_').isNotEmpty && modViewItem.value!.itemName.split('_').first == 'it' && modViewItem.value!.itemName.split('_')[1] == 'wp'
                                        ? modViewItem.value!.itemName
                                        : modViewItem.value!.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                    : modViewItem.value!.itemName.replaceAll('_', '/'))
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(curLangText!.uiAvailableMods),
                                  ),
                            if (modViewItem.value != null)
                              const Divider(
                                endIndent: 5,
                                height: 5,
                                thickness: 1,
                              ),

                            //status
                            if (modViewItem.value != null)
                              Wrap(spacing: 2.5, runSpacing: 2.5, children: [
                                // mod count
                                Container(
                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Text(
                                    modViewMods.length < 2 ? '${modViewMods.length} ${curLangText!.uiMod}' : '${modViewMods.length} ${curLangText!.uiMods}',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                                  ),
                                ),
                                //new count
                                Visibility(
                                  visible: modViewItem.value!.mods.indexWhere((element) => element.isNew) != -1,
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                    child: Text(
                                      '${modViewMods.where((element) => element.isNew == true).length} ${curLangText!.uiNew}',
                                      style: const TextStyle(fontSize: 14, color: Colors.amber),
                                    ),
                                  ),
                                ),
                                //show new
                                Visibility(
                                  visible: modViewItem.value!.mods.indexWhere((element) => element.isNew) != -1,
                                  child: InkWell(
                                    onTap: () async {
                                      if (modViewListShowNew) {
                                        modViewListShowNew = false;
                                      } else {
                                        modViewListShowNew = true;
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                        height: 22,
                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Text(
                                          modViewListShowNew ? curLangText!.uiUndo : curLangText!.uiShowNew,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).buttonTheme.colorScheme!.primary),
                                        )),
                                  ),
                                ),
                                Visibility(
                                  visible: modViewItem.value!.mods.indexWhere((element) => element.applyStatus) != -1,
                                  child: InkWell(
                                    onTap: () async {
                                      if (modViewListShowApplied) {
                                        modViewListShowApplied = false;
                                      } else {
                                        modViewListShowApplied = true;
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                        height: 22,
                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Text(
                                          modViewListShowApplied ? curLangText!.uiUndo : curLangText!.uiShowApplied,
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).buttonTheme.colorScheme!.primary),
                                        )),
                                  ),
                                )
                              ]),

                            //buttons
                            if (modViewItem.value != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.5),
                                child: Wrap(spacing: 2.5, runSpacing: 2.5, children: [
                                  // export
                                  InkWell(
                                    onTap: () async {
                                      List<SubMod> submodsToExport = [];
                                      for (var mod in modViewMods) {
                                        if (isFavListVisible) {
                                          submodsToExport.addAll(mod.submods.where((e) => e.isFavorite));
                                        } else if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) {
                                          submodsToExport.addAll(mod.submods.where((e) => e.isSet && e.setNames.contains(selectedModSetName)));
                                        } else {
                                          submodsToExport.addAll(mod.submods);
                                        }
                                      }
                                      await modExportHomePage(context, moddedItemsList, submodsToExport, false);
                                    },
                                    child: Container(
                                        height: 22,
                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        ),
                                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 5),
                                            child: Icon(
                                              Icons.import_export,
                                              color: Theme.of(context).buttonTheme.colorScheme!.primary,
                                              size: 18,
                                            ),
                                          ),
                                          Text(
                                            curLangText!.uiExportAllMods,
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).buttonTheme.colorScheme!.primary),
                                          )
                                        ])),
                                  ),
                                  // swap all
                                  Visibility(
                                    visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem.value!.category),
                                    child: InkWell(
                                      onTap: () async {
                                        swapAllDialog(context, modViewItem.value!);
                                      },
                                      child: Container(
                                          height: 22,
                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: Icon(
                                                Icons.swap_horizontal_circle_outlined,
                                                color: Theme.of(context).buttonTheme.colorScheme!.primary,
                                                size: 18,
                                              ),
                                            ),
                                            Text(
                                              curLangText!.uiSwapAllMods,
                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).buttonTheme.colorScheme!.primary),
                                            )
                                          ])),
                                    ),
                                  )
                                ]),
                              ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
            foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
            toolbarHeight: modViewItem.value != null ? 84 : 30,
            elevation: 0,
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),

          //Main list
          if (modViewItem.value != null)
            Flexible(
                child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                        }
                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                      }),
                    ),
                    child: SuperListView.builder(
                        physics: const SuperRangeMaintainingScrollPhysics(),
                        primary: true,
                        itemCount: modViewMods.length,
                        itemBuilder: (context, modIndex) {
                          var curMod = modViewMods[modIndex];

                          return ListenableBuilder(
                              listenable: curMod,
                              builder: (BuildContext context, Widget? child) {
                                // if (modViewETKeys.isEmpty || modViewETKeys.length != modViewItem.value!.mods.length) {
                                //   modViewETKeys = List.generate(modViewItem.value!.mods.length, (index) => GlobalKey());
                                // }

                                if (isModViewItemListExpanded.isEmpty || isModViewItemListExpanded.length != modViewMods.length) {
                                  isModViewItemListExpanded = List.generate(modViewMods.length, (index) => false);
                                }

                                if (expansionListFNodes.isEmpty || expansionListFNodes.length != modViewMods.length) {
                                  expansionListFNodes = List.generate(modViewMods.length, (index) => FocusNode());
                                }

                                //modset
                                int modViewModSetSubModIndex = -1;
                                if (context.watch<StateProvider>().setsWindowVisible && curMod.submods.where((element) => element.isSet).isNotEmpty) {
                                  modViewModSetSubModIndex = curMod.submods.indexWhere((e) => e.isSet);
                                }

                                return InkWell(
                                  focusColor: Colors.transparent,
                                  focusNode: expansionListFNodes[modIndex],
                                  //Hover for preview
                                  onTap: () {},
                                  onSecondaryTap: () {
                                    if (previewImages.isNotEmpty) {
                                      previewDialogImages = previewImages.toList();
                                      previewDialogModName = previewModName;
                                      previewDialog(context);
                                    }
                                  },
                                  onHover: (hovering) {
                                    previewImages.clear();
                                    if (hovering && !hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible) {
                                      if (modViewModSetSubModIndex != -1) {
                                        previewModName = curMod.submods[modViewModSetSubModIndex].submodName;
                                      } else {
                                        previewModName = curMod.modName;
                                      }
                                      previewImages = curMod.getPreviewWidgets();
                                    } else {
                                      // previewModName = '';
                                      // modPreviewWidgets.clear();
                                    }
                                    // setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: InfoPopupWidget(
                                      horizontalDirection: 'right',
                                      dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                      popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                      arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                      customContent: () => !hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible && !showPreviewPanel && !previewDismiss
                                          ? PreviewHoverPanel(previewWidgets: previewImages)
                                          : null,
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                        shape: RoundedRectangleBorder(side: BorderSide(width: 1, color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        //advanced
                                        child: ExpansionTile(
                                          backgroundColor: Colors.transparent,
                                          textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                          iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                          collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                          // key: modViewETKeys[modIndex],
                                          onExpansionChanged: (value) async {
                                            isModViewItemListExpanded[modIndex] = value;
                                            await Future.delayed(const Duration(milliseconds: 210));
                                            setState(() {});
                                          },
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(curMod.modName,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                            color: curMod.applyStatus
                                                                ? Theme.of(context).colorScheme.primary
                                                                : curMod.isNew
                                                                    ? Colors.amber
                                                                    : null)),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                                            ? Wrap(
                                                                spacing: 5,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                    ),
                                                                    child: Text(
                                                                        curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length < 2
                                                                            ? '${curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} ${curLangText!.uiVariant}'
                                                                            : '${curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} ${curLangText!.uiVariants}',
                                                                        style: const TextStyle(
                                                                          fontSize: 15,
                                                                        )),
                                                                  ),
                                                                  if (curMod.submods.where((element) => element.isSet && element.hasCmx!).isNotEmpty)
                                                                    Container(
                                                                      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: curMod.submods.where((element) => element.cmxApplied!).isNotEmpty
                                                                                ? Theme.of(context).colorScheme.primary
                                                                                : Theme.of(context).primaryColorLight),
                                                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                      ),
                                                                      child: Text(curLangText!.uiCmx,
                                                                          style: TextStyle(
                                                                            color: curMod.submods.where((element) => element.cmxApplied!).isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                                                            fontSize: 15,
                                                                          )),
                                                                    ),
                                                                  if (curMod.submods.where((element) => element.applyLocations!.isNotEmpty).isNotEmpty) const Icon(Icons.location_on_outlined),
                                                                ],
                                                              )
                                                            : Wrap(
                                                                spacing: 5,
                                                                children: [
                                                                  Container(
                                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                    ),
                                                                    child: searchTextController.value.text.isNotEmpty &&
                                                                            curMod.submods
                                                                                .where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase()))
                                                                                .isNotEmpty
                                                                        ? Text(
                                                                            curMod.submods
                                                                                        .where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase()))
                                                                                        .length <
                                                                                    2
                                                                                ? '${curMod.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).length} ${curLangText!.uiVariant}'
                                                                                : '${curMod.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).length} ${curLangText!.uiVariants}',
                                                                            style: const TextStyle(
                                                                              fontSize: 15,
                                                                            ))
                                                                        : Text(
                                                                            curMod.submods.length < 2
                                                                                ? '${curMod.submods.length} ${curLangText!.uiVariant}'
                                                                                : '${curMod.submods.length} ${curLangText!.uiVariants}',
                                                                            style: const TextStyle(
                                                                              fontSize: 15,
                                                                            )),
                                                                  ),
                                                                  if (curMod.submods.where((element) => element.hasCmx!).isNotEmpty)
                                                                    Container(
                                                                      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: curMod.submods.where((element) => element.cmxApplied!).isNotEmpty
                                                                                ? Theme.of(context).colorScheme.primary
                                                                                : Theme.of(context).primaryColorLight),
                                                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                      ),
                                                                      child: Text(curLangText!.uiCmx,
                                                                          style: TextStyle(
                                                                            color: curMod.submods.where((element) => element.cmxApplied!).isNotEmpty ? Theme.of(context).colorScheme.primary : null,
                                                                            fontSize: 15,
                                                                          )),
                                                                    ),
                                                                  if (curMod.submods.where((element) => element.applyLocations!.isNotEmpty).isNotEmpty) const Icon(Icons.location_on_outlined),
                                                                ],
                                                              )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              //More menu for normal mods
                                              if (curMod.submods.length > 1 && !context.watch<StateProvider>().setsWindowVisible ||
                                                  isModViewFromApplied && curMod.submods.length > 1 ||
                                                  curMod.submods.length == 1 && isModViewItemListExpanded[modIndex] && !context.watch<StateProvider>().setsWindowVisible ||
                                                  isModViewFromApplied && curMod.submods.length == 1 && isModViewItemListExpanded[modIndex])
                                                MenuAnchor(
                                                    builder: (BuildContext context, MenuController controller, Widget? child) {
                                                      return ModManTooltip(
                                                        message: curLangText!.uiMore,
                                                        child: InkWell(
                                                          child: const Icon(
                                                            Icons.more_vert,
                                                          ),
                                                          onHover: (value) {
                                                            if (value) {
                                                              previewDismiss = true;
                                                            } else {
                                                              previewDismiss = false;
                                                            }
                                                            setState(() {});
                                                          },
                                                          onTap: () {
                                                            if (controller.isOpen) {
                                                              controller.close();
                                                            } else {
                                                              controller.open();
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    onClose: () {
                                                      expansionListFNodes[modIndex].unfocus();
                                                    },
                                                    style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                      return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                    }), shape: WidgetStateProperty.resolveWith((states) {
                                                      return RoundedRectangleBorder(
                                                          side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                    })),
                                                    menuChildren: [
                                                      //add preview
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(Icons.preview_outlined),
                                                        child: Text(curLangText!.uiAddPreviews),
                                                        onPressed: () async {
                                                          const XTypeGroup typeGroup = XTypeGroup(
                                                            label: '.jpg, .png, .mp4, .webm',
                                                            extensions: <String>['jpg', 'png', 'mp4', 'webm'],
                                                          );
                                                          final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                          if (selectedFile != null) {
                                                            final copiedFile = await File(selectedFile.path).copy(curMod.location + p.separator + p.basename(selectedFile.path));
                                                            if (copiedFile.existsSync()) {
                                                              //save to mod
                                                              if (p.extension(copiedFile.path) == '.jpg' || p.extension(copiedFile.path) == '.png' && !curMod.previewImages.contains(copiedFile.path)) {
                                                                curMod.previewImages.add(copiedFile.path);
                                                              }
                                                              if (p.extension(copiedFile.path) == '.mp4' ||
                                                                  p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
                                                                curMod.previewVideos.add(copiedFile.path);
                                                              }
                                                              saveModdedItemListToJson();
                                                            }
                                                          }
                                                          setState(() {});
                                                        },
                                                      ),
                                                      // rename
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.edit_note,
                                                        ),
                                                        child: Text(curLangText!.uiRename),
                                                        onPressed: () async {
                                                          String newName = await modsRenameDialog(context, modViewItem.value!.location, curMod.modName);
                                                          if (newName.isNotEmpty) {
                                                            //change paths
                                                            String oldModPath = curMod.location;
                                                            String newModPath = Uri.file('${modViewItem.value!.location}/$newName').toFilePath();
                                                            if (oldModPath == modViewItem.value!.location) {
                                                              await Directory(newModPath).create(recursive: true);
                                                              curMod.modName = newName;
                                                              curMod.location = newModPath;
                                                              curMod.previewImages.clear();
                                                              curMod.previewVideos.clear();
                                                              renamedPreviewPathsGet(curMod.location, curMod.previewImages, curMod.previewVideos);
                                                              for (var submod in curMod.submods) {
                                                                submod.modName = newName;
                                                                submod.submodName = newName;
                                                                submod.location = submod.location.replaceFirst(oldModPath, newModPath);
                                                                submod.previewImages.clear();
                                                                submod.previewVideos.clear();
                                                                renamedPreviewPathsGet(submod.location, submod.previewImages, submod.previewVideos);
                                                                for (var modFile in submod.modFiles) {
                                                                  final movedFile = await File(modFile.location).rename(modFile.location.replaceFirst(oldModPath, newModPath));
                                                                  modFile.modName = newName;
                                                                  modFile.submodName = newName;
                                                                  modFile.location = movedFile.path;
                                                                }
                                                              }
                                                            } else {
                                                              await Directory(oldModPath).rename(newModPath);
                                                              curMod.modName = newName;
                                                              curMod.location = newModPath;
                                                              for (var imagePath in curMod.previewImages) {
                                                                imagePath = imagePath.replaceFirst(oldModPath, newModPath);
                                                              }
                                                              for (var videoPath in curMod.previewVideos) {
                                                                videoPath = videoPath.replaceFirst(oldModPath, newModPath);
                                                              }
                                                              for (var submod in curMod.submods) {
                                                                submod.modName = newName;
                                                                if (submod.location == oldModPath) {
                                                                  submod.submodName = newName;
                                                                }
                                                                submod.location = submod.location.replaceFirst(oldModPath, newModPath);
                                                                for (var imagePath in submod.previewImages) {
                                                                  imagePath = imagePath.replaceFirst(oldModPath, newModPath);
                                                                }
                                                                for (var videoPath in submod.previewVideos) {
                                                                  videoPath = videoPath.replaceFirst(oldModPath, newModPath);
                                                                }
                                                                for (var modFile in submod.modFiles) {
                                                                  modFile.modName = newName;
                                                                  if (submod.location == curMod.location) {
                                                                    modFile.submodName = newName;
                                                                  }
                                                                  modFile.location = modFile.location.replaceFirst(oldModPath, newModPath);
                                                                }
                                                              }
                                                            }
                                                            modSetList = await modSetLoader();
                                                            saveSetListToJson();
                                                            saveModdedItemListToJson();
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),

                                                      // export
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.import_export,
                                                        ),
                                                        child: Text(curLangText!.uiExportThisMod),
                                                        onPressed: () async => modExportHomePage(context, moddedItemsList, curMod.submods, false),
                                                      ),

                                                      // open in file explorer
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.folder_open_outlined,
                                                        ),
                                                        child: Text(curLangText!.uiOpenInFileExplorer),
                                                        onPressed: () async {
                                                          if (Directory(Uri.file(curMod.location).toFilePath()).existsSync()) {
                                                            await launchUrl(Uri.file(curMod.location));
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', curLangText!.uiDirNotFound, 2000));
                                                          }
                                                        },
                                                      ),

                                                      // delete
                                                      MenuItemButton(
                                                        leadingIcon: Icon(
                                                          Icons.delete_forever_outlined,
                                                          color: curMod.applyStatus ||
                                                                  curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                              ? Theme.of(context).disabledColor
                                                              : Colors.red,
                                                        ),
                                                        onPressed: curMod.applyStatus ||
                                                                curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                            ? null
                                                            : () async {
                                                                bool deleteConfirm = await modDeletionDialog(context, curMod.modName);
                                                                if (deleteConfirm) {
                                                                  if (modViewMods.length < 2) {
                                                                    deleteItemFromModMan(modViewItem.value!.location).then((value) async {
                                                                      String removedName = '${modViewCate!.categoryName} > ${modViewItem.value!.itemName}';
                                                                      if (modViewItem.value!.isSet) {
                                                                        for (var setName in modViewItem.value!.setNames) {
                                                                          int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                          if (setIndex != -1) {
                                                                            modSetList[setIndex].setItems.remove(modViewItem.value);
                                                                          }
                                                                        }
                                                                      }
                                                                      modViewCate!.removeItem(modViewItem.value);
                                                                      modViewItem.value != null;
                                                                      modViewItem.value = null;
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                          context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                      previewModName = '';
                                                                      previewImages.clear();
                                                                      saveModdedItemListToJson();
                                                                      setState(() {});
                                                                    });
                                                                  } else {
                                                                    deleteModFromModMan(curMod.location, modViewItem.value!.location).then((value) async {
                                                                      String removedName = '${curMod.modName} > ${curMod.submods.first.submodName}';
                                                                      modViewItem.value!.removeMod(curMod);
                                                                      if (modViewItem.value!.mods.isEmpty) {
                                                                        modViewCate!.removeItem(modViewItem.value);
                                                                        modViewItem.value != null;
                                                                        modViewItem.value = null;
                                                                      } else {
                                                                        modViewItem.value!.isNew = modViewItem.value!.getModsIsNewState();
                                                                      }
                                                                      previewModName = '';
                                                                      previewImages.clear();
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                          context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                      saveModdedItemListToJson();
                                                                      setState(() {});
                                                                    });
                                                                  }
                                                                }
                                                              },
                                                        child: Text(
                                                          curLangText!.uiRemoveFromMM,
                                                          style: TextStyle(
                                                              color: curMod.applyStatus ||
                                                                      curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                  ? Theme.of(context).disabledColor
                                                                  : Colors.red),
                                                        ),
                                                      ),
                                                    ]),

                                              //normal
                                              if (curMod.submods.length == 1 && !isModViewItemListExpanded[modIndex] && !context.watch<StateProvider>().setsWindowVisible ||
                                                  isModViewFromApplied && curMod.submods.length == 1 && !isModViewItemListExpanded[modIndex])
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    runAlignment: WrapAlignment.center,
                                                    spacing: 0,
                                                    children: [
                                                      //unapply button
                                                      if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus) != -1)
                                                        UnApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curMod.submods.first),
                                                      if (curMod.submods.first.modFiles.indexWhere((element) => !element.applyStatus) != -1)
                                                        ApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curMod.submods.first),

                                                      //quick apply
                                                      Visibility(
                                                        visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem.value!.category),
                                                        child: MenuAnchor(
                                                            builder: (BuildContext context, MenuController controller, Widget? child) {
                                                              return ModManTooltip(
                                                                message: curLangText!.uiSwapThisModToSelectedItemInList,
                                                                child: InkWell(
                                                                  child: const Stack(
                                                                    alignment: Alignment.bottomRight,
                                                                    children: [
                                                                      Icon(Icons.arrow_drop_down),
                                                                    ],
                                                                  ),
                                                                  onHover: (value) {
                                                                    if (value) {
                                                                      previewDismiss = true;
                                                                    } else {
                                                                      previewDismiss = false;
                                                                    }
                                                                    setState(() {});
                                                                  },
                                                                  onTap: () {
                                                                    if (controller.isOpen) {
                                                                      controller.close();
                                                                    } else {
                                                                      controller.open();
                                                                    }
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            onClose: () {
                                                              expansionListFNodes[modIndex].unfocus();
                                                            },
                                                            style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                              return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                            }), shape: WidgetStateProperty.resolveWith((states) {
                                                              return RoundedRectangleBorder(
                                                                  side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                            })),
                                                            menuChildren: quickApplyMenuButtons(context, curMod, curMod.submods.first)),
                                                      ),

                                                      //More menu
                                                      MenuAnchor(
                                                          builder: (BuildContext context, MenuController controller, Widget? child) {
                                                            return ModManTooltip(
                                                              message: curLangText!.uiMore,
                                                              child: InkWell(
                                                                child: const Icon(
                                                                  Icons.more_vert,
                                                                ),
                                                                onHover: (value) {
                                                                  if (value) {
                                                                    previewDismiss = true;
                                                                  } else {
                                                                    previewDismiss = false;
                                                                  }
                                                                  setState(() {});
                                                                },
                                                                onTap: () {
                                                                  if (controller.isOpen) {
                                                                    controller.close();
                                                                  } else {
                                                                    controller.open();
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          onClose: () {
                                                            expansionListFNodes[modIndex].unfocus();
                                                          },
                                                          style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                            return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                          }), shape: WidgetStateProperty.resolveWith((states) {
                                                            return RoundedRectangleBorder(
                                                                side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                          })),
                                                          menuChildren: [
                                                            // favorite
                                                            MenuItemButton(
                                                              leadingIcon: Icon(
                                                                curMod.submods.first.isFavorite ? FontAwesomeIcons.heartCircleMinus : FontAwesomeIcons.heartCirclePlus,
                                                                //size: 18,
                                                              ),
                                                              child: Text(
                                                                curMod.submods.first.isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                              ),
                                                              onPressed: () async {
                                                                if (curMod.submods.first.isFavorite) {
                                                                  curMod.submods.first.isFavorite = false;
                                                                  if (curMod.submods.where((element) => element.isFavorite).isEmpty) {
                                                                    curMod.isFavorite = false;
                                                                  }
                                                                  if (modViewMods.where((element) => element.isFavorite).isEmpty) {
                                                                    modViewItem.value!.isFavorite = false;
                                                                    modViewItem.value != null;
                                                                    modViewItem.value = null;
                                                                  }
                                                                } else {
                                                                  curMod.submods.first.isFavorite = true;
                                                                  curMod.isFavorite = true;
                                                                  modViewItem.value!.isFavorite = true;
                                                                }
                                                                saveModdedItemListToJson();
                                                                setState(() {});
                                                              },
                                                            ),

                                                            //Add to set
                                                            SubmenuButton(
                                                              menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                              }), shape: WidgetStateProperty.resolveWith((states) {
                                                                return RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                              })),
                                                              alignmentOffset: const Offset(0, 8),
                                                              menuChildren: modSetsMenuButtons(context, modViewItem.value!, curMod, curMod.submods.first),
                                                              leadingIcon: const Icon(
                                                                Icons.list_alt_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiAddToModSets),
                                                            ),

                                                            // Apply location select
                                                            SubmenuButton(
                                                              menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                              }), shape: WidgetStateProperty.resolveWith((states) {
                                                                return RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                              })),
                                                              alignmentOffset: const Offset(0, 8),
                                                              menuChildren: modApplyingLocationsMenuButtons(context, curMod.submods.first),
                                                              leadingIcon: const Icon(
                                                                Icons.add_location_alt_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiSelectApplyingLocations),
                                                            ),

                                                            // add or change cmx file
                                                            Visibility(
                                                                visible: curMod.submods.first.category == defaultCategoryDirs[1] ||
                                                                    curMod.submods.first.category == defaultCategoryDirs[6] ||
                                                                    curMod.submods.first.category == defaultCategoryDirs[11] ||
                                                                    curMod.submods.first.category == defaultCategoryDirs[15] ||
                                                                    curMod.submods.first.category == defaultCategoryDirs[16],
                                                                child: MenuItemButton(
                                                                  leadingIcon: const Icon(
                                                                    Icons.note_add_rounded,
                                                                  ),
                                                                  child: Text(curLangText!.uiAddChangeCmxFile),
                                                                  onPressed: () async {
                                                                    XTypeGroup typeGroup = XTypeGroup(
                                                                      label: curLangText!.uiCmxFile,
                                                                      extensions: const <String>['txt'],
                                                                    );
                                                                    XFile? selectedCmxFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                    if (selectedCmxFile != null && selectedCmxFile.path.isNotEmpty) {
                                                                      final copiedCmxFile =
                                                                          await File(selectedCmxFile.path).copy(Uri.file('${curMod.submods.first.location}/${selectedCmxFile.name}').toFilePath());
                                                                      if (copiedCmxFile.existsSync()) {
                                                                        curMod.submods.first.cmxFile = copiedCmxFile.path;
                                                                        curMod.submods.first.hasCmx = true;
                                                                        saveModdedItemListToJson();
                                                                        if (curMod.submods.first.cmxApplied!) {
                                                                          int startPos = -1, endPos = -1;
                                                                          (startPos, endPos) = await cmxModPatch(copiedCmxFile.path);
                                                                          if (startPos != -1 && endPos != -1) {
                                                                            curMod.submods.first.cmxStartPos = startPos;
                                                                            curMod.submods.first.cmxEndPos = endPos;
                                                                          }
                                                                        }
                                                                        saveModdedItemListToJson();
                                                                      }
                                                                    }
                                                                    setState(() {});
                                                                  },
                                                                )),

                                                            //add preview
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(Icons.preview_outlined),
                                                              child: Text(curLangText!.uiAddPreviews),
                                                              onPressed: () async {
                                                                const XTypeGroup typeGroup = XTypeGroup(
                                                                  label: '.jpg, .png, .mp4, .webm',
                                                                  extensions: <String>['jpg', 'png', 'mp4', 'webm'],
                                                                );
                                                                final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                if (selectedFile != null) {
                                                                  final copiedFile = await File(selectedFile.path).copy(curMod.location + p.separator + p.basename(selectedFile.path));
                                                                  if (copiedFile.existsSync()) {
                                                                    //save to mod
                                                                    if (p.extension(copiedFile.path) == '.jpg' ||
                                                                        p.extension(copiedFile.path) == '.png' && !curMod.previewImages.contains(copiedFile.path)) {
                                                                      curMod.previewImages.add(copiedFile.path);
                                                                    }
                                                                    if (p.extension(copiedFile.path) == '.mp4' ||
                                                                        p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
                                                                      curMod.previewVideos.add(copiedFile.path);
                                                                    }
                                                                    saveModdedItemListToJson();
                                                                  }
                                                                }
                                                                setState(() {});
                                                              },
                                                            ),

                                                            // rename
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.edit_note,
                                                              ),
                                                              child: Text(curLangText!.uiRename),
                                                              onPressed: () async {
                                                                String newName = await modsRenameDialog(context, modViewItem.value!.location, curMod.modName);
                                                                if (newName.isNotEmpty) {
                                                                  //change paths
                                                                  String oldModPath = curMod.location;
                                                                  String newModPath = Uri.file('${modViewItem.value!.location}/$newName').toFilePath();
                                                                  if (oldModPath == modViewItem.value!.location) {
                                                                    await Directory(newModPath).create(recursive: true);
                                                                    curMod.modName = newName;
                                                                    curMod.location = newModPath;
                                                                    curMod.previewImages.clear();
                                                                    curMod.previewVideos.clear();
                                                                    renamedPreviewPathsGet(curMod.location, curMod.previewImages, curMod.previewVideos);
                                                                    for (var submod in curMod.submods) {
                                                                      submod.modName = newName;
                                                                      submod.submodName = newName;
                                                                      submod.location = submod.location.replaceFirst(oldModPath, newModPath);
                                                                      submod.previewImages.clear();
                                                                      submod.previewVideos.clear();
                                                                      renamedPreviewPathsGet(submod.location, submod.previewImages, submod.previewVideos);
                                                                      for (var modFile in submod.modFiles) {
                                                                        final movedFile = await File(modFile.location).rename(modFile.location.replaceFirst(oldModPath, newModPath));
                                                                        modFile.modName = newName;
                                                                        modFile.submodName = newName;
                                                                        modFile.location = movedFile.path;
                                                                      }
                                                                    }
                                                                  } else {
                                                                    await Directory(oldModPath).rename(newModPath);
                                                                    curMod.modName = newName;
                                                                    curMod.location = newModPath;
                                                                    curMod.previewImages.clear();
                                                                    curMod.previewVideos.clear();
                                                                    renamedPreviewPathsGet(curMod.location, curMod.previewImages, curMod.previewVideos);
                                                                    for (var submod in curMod.submods) {
                                                                      submod.modName = newName;
                                                                      if (submod.location == oldModPath) {
                                                                        submod.submodName = newName;
                                                                      }
                                                                      submod.location = submod.location.replaceFirst(oldModPath, newModPath);
                                                                      submod.previewImages.clear();
                                                                      submod.previewVideos.clear();
                                                                      renamedPreviewPathsGet(submod.location, submod.previewImages, submod.previewVideos);
                                                                      for (var modFile in submod.modFiles) {
                                                                        modFile.modName = newName;
                                                                        if (submod.location == curMod.location) {
                                                                          modFile.submodName = newName;
                                                                        }
                                                                        modFile.location = modFile.location.replaceFirst(oldModPath, newModPath);
                                                                      }
                                                                    }
                                                                  }
                                                                  modSetList = await modSetLoader();
                                                                  saveSetListToJson();
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                }
                                                              },
                                                            ),

                                                            // swap
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.swap_horizontal_circle_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiSwapToAnotherItem),
                                                              onPressed: () async {
                                                                if (!defaultCategoryDirs.contains(modViewItem.value!.category)) {
                                                                  fromItemCategory = await modsSwapperCategorySelect(context);
                                                                }
                                                                modsSwapperDialog(context, modViewItem.value!, curMod, curMod.submods.first);
                                                              },
                                                            ),

                                                            // export
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.import_export,
                                                              ),
                                                              child: Text(curLangText!.uiExportThisMod),
                                                              onPressed: () async => modExportHomePage(context, moddedItemsList, [curMod.submods.first], false),
                                                            ),

                                                            // open in file explorer
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.folder_open_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiOpenInFileExplorer),
                                                              onPressed: () async {
                                                                if (Directory(Uri.file(curMod.submods.first.location).toFilePath()).existsSync()) {
                                                                  await launchUrl(Uri.file(curMod.submods.first.location));
                                                                } else {
                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', curLangText!.uiDirNotFound, 2000));
                                                                }
                                                              },
                                                            ),

                                                            // boundary
                                                            Visibility(
                                                              visible: curMod.submods.first.category == defaultCategoryDirs[1] ||
                                                                  curMod.submods.first.category == defaultCategoryDirs[3] ||
                                                                  curMod.submods.first.category == defaultCategoryDirs[4] ||
                                                                  curMod.submods.first.category == defaultCategoryDirs[5] ||
                                                                  curMod.submods.first.category == defaultCategoryDirs[15] ||
                                                                  curMod.submods.first.category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.radio_button_checked,
                                                                ),
                                                                child: Text(curLangText!.uiRemoveBoundaryRadius),
                                                                onPressed: () {
                                                                  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                    element.deleteSync(recursive: true);
                                                                  });
                                                                  isBoundaryEdited = false;
                                                                  modsBoundaryEditHomePage(context, curMod.submods.first);
                                                                },
                                                              ),
                                                            ),

                                                            // aqm inject
                                                            Visibility(
                                                              visible: curMod.submods.first.category == defaultCategoryDirs[1] || curMod.submods.first.category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.auto_fix_normal,
                                                                ),
                                                                onPressed: File(modManCustomAqmFilePath).existsSync()
                                                                    ? () async {
                                                                        isAqmInjecting = false;
                                                                        await modAqmInjectionHomePage(context, curMod.submods.first);
                                                                      }
                                                                    : null,
                                                                child: Text(File(modManCustomAqmFilePath).existsSync()
                                                                    ? curLangText!.uiInjectCustomAqmFile
                                                                    : '${curLangText!.uiInjectCustomAqmFile}\n${curLangText!.uiSelectFileInSettings}'),
                                                              ),
                                                            ),

                                                            // aqm inject removal
                                                            Visibility(
                                                              visible: curMod.submods.first.category == defaultCategoryDirs[1] || curMod.submods.first.category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.auto_fix_off,
                                                                ),
                                                                onPressed: () async {
                                                                  isAqmInjectionRemoving = false;
                                                                  await modAqmInjectionRemovalHomePage(context, curMod.submods.first);
                                                                },
                                                                child: Text(curLangText!.uiRemoveInjectedCustomAqm),
                                                              ),
                                                            ),

                                                            //remove from set
                                                            Visibility(
                                                              visible: context.watch<StateProvider>().setsWindowVisible && curMod.submods.first.isSet,
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.delete_forever_outlined,
                                                                ),
                                                                onPressed: () async {
                                                                  removeSubmodFromThisSet(selectedModSetName, modViewItem.value!, curMod, curMod.submods.first);
                                                                  saveSetListToJson();
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                },
                                                                child: Text(
                                                                  curLangText!.uiRemoveFromThisSet,
                                                                ),
                                                              ),
                                                            ),

                                                            // delete
                                                            MenuItemButton(
                                                              leadingIcon: Icon(
                                                                Icons.delete_forever_outlined,
                                                                color: curMod.applyStatus ||
                                                                        curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                    ? Theme.of(context).disabledColor
                                                                    : Colors.red,
                                                              ),
                                                              onPressed: curMod.applyStatus ||
                                                                      curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                  ? null
                                                                  : () async {
                                                                      bool deleteConfirm = await modDeletionDialog(context, curMod.submods.first.submodName);
                                                                      if (deleteConfirm) {
                                                                        if (curMod.submods.length < 2 && modViewMods.length < 2) {
                                                                          deleteItemFromModMan(modViewItem.value!.location).then((value) async {
                                                                            String removedName = '${modViewCate!.categoryName} > ${modViewItem.value!.itemName}';
                                                                            if (modViewItem.value!.isSet) {
                                                                              for (var setName in modViewItem.value!.setNames) {
                                                                                int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                                if (setIndex != -1) {
                                                                                  modSetList[setIndex].setItems.remove(modViewItem.value);
                                                                                }
                                                                              }
                                                                            }
                                                                            modViewCate!.removeItem(modViewItem.value);
                                                                            modViewItem.value != null;
                                                                            modViewItem.value = null;
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        } else {
                                                                          deleteSubmodFromModMan(curMod.submods.first.location, curMod.location).then((value) async {
                                                                            String removedName = '${curMod.modName} > ${curMod.submods.first.submodName}';
                                                                            curMod.submods.remove(curMod.submods.first);
                                                                            if (curMod.submods.isEmpty) {
                                                                              modViewItem.value!.removeMod(curMod);
                                                                            } else {
                                                                              curMod.isNew = curMod.getSubmodsIsNewState();
                                                                            }

                                                                            if (modViewItem.value!.mods.isEmpty) {
                                                                              modViewCate!.removeItem(modViewItem.value);
                                                                              modViewItem.value != null;
                                                                              modViewItem.value = null;
                                                                            } else {
                                                                              modViewItem.value!.isNew = modViewItem.value!.getModsIsNewState();
                                                                            }
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      }
                                                                    },
                                                              child: Text(
                                                                curLangText!.uiRemoveFromMM,
                                                                style: TextStyle(
                                                                    color: curMod.applyStatus ||
                                                                            curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                        ? Theme.of(context).disabledColor
                                                                        : Colors.red),
                                                              ),
                                                            ),
                                                          ])
                                                    ],
                                                  ),
                                                ),

                                              //ModSet
                                              if (!isModViewFromApplied && !isModViewItemListExpanded[modIndex] && modViewModSetSubModIndex != -1 && context.watch<StateProvider>().setsWindowVisible)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: Wrap(
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    runAlignment: WrapAlignment.center,
                                                    spacing: 0,
                                                    children: [
                                                      //cmx indicator
                                                      if (curMod.submods[modViewModSetSubModIndex].hasCmx!)
                                                        Container(
                                                          padding: const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 1),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    curMod.submods[modViewModSetSubModIndex].cmxApplied! ? Theme.of(context).colorScheme.primary : Theme.of(context).primaryColorLight),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                          ),
                                                          child: Text(curLangText!.uiCmx,
                                                              style: TextStyle(
                                                                color: curMod.submods[modViewModSetSubModIndex].cmxApplied! ? Theme.of(context).colorScheme.primary : null,
                                                                fontSize: 15,
                                                              )),
                                                        ),

                                                      //Add-Remove button
                                                      if (modViewModSetSubModIndex != -1 &&
                                                          curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus) != -1 &&
                                                          curMod.submods.length == 1)
                                                        UnApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curMod.submods[modViewModSetSubModIndex]),

                                                      if (modViewModSetSubModIndex != -1 &&
                                                          curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => !element.applyStatus) != -1 &&
                                                          curMod.submods.length == 1)
                                                        ApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curMod.submods[modViewModSetSubModIndex]),

                                                      //quick apply
                                                      Visibility(
                                                        visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem.value!.category),
                                                        child: MenuAnchor(
                                                            builder: (BuildContext context, MenuController controller, Widget? child) {
                                                              return ModManTooltip(
                                                                message: curLangText!.uiSwapThisModToSelectedItemInList,
                                                                child: InkWell(
                                                                  child: const Icon(
                                                                    Icons.arrow_drop_down,
                                                                  ),
                                                                  onHover: (value) {
                                                                    if (value) {
                                                                      previewDismiss = true;
                                                                    } else {
                                                                      previewDismiss = false;
                                                                    }
                                                                    setState(() {});
                                                                  },
                                                                  onTap: () {
                                                                    if (controller.isOpen) {
                                                                      controller.close();
                                                                    } else {
                                                                      controller.open();
                                                                    }
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            onClose: () {
                                                              expansionListFNodes[modIndex].unfocus();
                                                            },
                                                            style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                              return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                            }), shape: WidgetStateProperty.resolveWith((states) {
                                                              return RoundedRectangleBorder(
                                                                  side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                            })),
                                                            menuChildren: quickApplyMenuButtons(context, curMod, curMod.submods[modViewModSetSubModIndex])),
                                                      ),

                                                      //More menu
                                                      MenuAnchor(
                                                          builder: (BuildContext context, MenuController controller, Widget? child) {
                                                            return ModManTooltip(
                                                              message: curLangText!.uiMore,
                                                              child: InkWell(
                                                                child: const Icon(
                                                                  Icons.more_vert,
                                                                ),
                                                                onHover: (value) {
                                                                  if (value) {
                                                                    previewDismiss = true;
                                                                  } else {
                                                                    previewDismiss = false;
                                                                  }
                                                                  setState(() {});
                                                                },
                                                                onTap: () {
                                                                  if (controller.isOpen) {
                                                                    controller.close();
                                                                  } else {
                                                                    controller.open();
                                                                  }
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          onClose: () {
                                                            expansionListFNodes[modIndex].unfocus();
                                                          },
                                                          style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                            return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                          }), shape: WidgetStateProperty.resolveWith((states) {
                                                            return RoundedRectangleBorder(
                                                                side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                          })),
                                                          menuChildren: [
                                                            // favorite
                                                            MenuItemButton(
                                                              leadingIcon: Icon(
                                                                curMod.submods[modViewModSetSubModIndex].isFavorite ? FontAwesomeIcons.heartCircleMinus : FontAwesomeIcons.heartCirclePlus,
                                                                //size: 18,
                                                              ),
                                                              child: Text(
                                                                curMod.submods[modViewModSetSubModIndex].isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                              ),
                                                              onPressed: () async {
                                                                if (curMod.submods[modViewModSetSubModIndex].isFavorite) {
                                                                  curMod.submods[modViewModSetSubModIndex].isFavorite = false;
                                                                  if (curMod.submods.where((element) => element.isFavorite).isEmpty) {
                                                                    curMod.isFavorite = false;
                                                                  }
                                                                  if (modViewMods.where((element) => element.isFavorite).isEmpty) {
                                                                    modViewItem.value!.isFavorite = false;
                                                                    modViewItem.value != null;
                                                                    modViewItem.value = null;
                                                                  }
                                                                } else {
                                                                  curMod.submods[modViewModSetSubModIndex].isFavorite = true;
                                                                  curMod.isFavorite = true;
                                                                  modViewItem.value!.isFavorite = true;
                                                                }
                                                                saveModdedItemListToJson();
                                                                setState(() {});
                                                              },
                                                            ),

                                                            //Add to set
                                                            SubmenuButton(
                                                              menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                              }), shape: WidgetStateProperty.resolveWith((states) {
                                                                return RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                              })),
                                                              alignmentOffset: const Offset(0, 8),
                                                              menuChildren: modSetsMenuButtons(context, modViewItem.value!, curMod, curMod.submods[modViewModSetSubModIndex]),
                                                              leadingIcon: const Icon(
                                                                Icons.list_alt_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiAddToModSets),
                                                            ),

                                                            // Apply location select
                                                            SubmenuButton(
                                                              menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                              }), shape: WidgetStateProperty.resolveWith((states) {
                                                                return RoundedRectangleBorder(
                                                                    side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                              })),
                                                              alignmentOffset: const Offset(0, 8),
                                                              menuChildren: modApplyingLocationsMenuButtons(context, curMod.submods[modViewModSetSubModIndex]),
                                                              leadingIcon: const Icon(
                                                                Icons.add_location_alt_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiSelectApplyingLocations),
                                                            ),

                                                            // add or change cmx file
                                                            Visibility(
                                                              visible: curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[1] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[6] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[11] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[15] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.note_add_rounded,
                                                                ),
                                                                child: Text(curLangText!.uiAddChangeCmxFile),
                                                                onPressed: () async {
                                                                  XTypeGroup typeGroup = XTypeGroup(
                                                                    label: curLangText!.uiCmxFile,
                                                                    extensions: const <String>['txt'],
                                                                  );
                                                                  XFile? selectedCmxFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                  if (selectedCmxFile != null && selectedCmxFile.path.isNotEmpty) {
                                                                    final copiedCmxFile = await File(selectedCmxFile.path)
                                                                        .copy(Uri.file('${curMod.submods[modViewModSetSubModIndex].location}/${selectedCmxFile.name}').toFilePath());
                                                                    if (copiedCmxFile.existsSync()) {
                                                                      curMod.submods[modViewModSetSubModIndex].cmxFile = copiedCmxFile.path;
                                                                      curMod.submods[modViewModSetSubModIndex].hasCmx = true;
                                                                      saveModdedItemListToJson();
                                                                      if (curMod.submods[modViewModSetSubModIndex].cmxApplied!) {
                                                                        int startPos = -1, endPos = -1;
                                                                        (startPos, endPos) = await cmxModPatch(copiedCmxFile.path);
                                                                        if (startPos != -1 && endPos != -1) {
                                                                          curMod.submods[modViewModSetSubModIndex].cmxStartPos = startPos;
                                                                          curMod.submods[modViewModSetSubModIndex].cmxEndPos = endPos;
                                                                        }
                                                                      }
                                                                      saveModdedItemListToJson();
                                                                    }
                                                                  }
                                                                  setState(() {});
                                                                },
                                                              ),
                                                            ),

                                                            //add preview
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(Icons.preview_outlined),
                                                              child: Text(curLangText!.uiAddPreviews),
                                                              onPressed: () async {
                                                                const XTypeGroup typeGroup = XTypeGroup(
                                                                  label: '.jpg, .png, .mp4, .webm',
                                                                  extensions: <String>['jpg', 'png', 'mp4', 'webm'],
                                                                );
                                                                final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                if (selectedFile != null) {
                                                                  final copiedFile = await File(selectedFile.path)
                                                                      .copy(curMod.submods[modViewModSetSubModIndex].location + p.separator + p.basename(selectedFile.path));
                                                                  if (copiedFile.existsSync()) {
                                                                    //save to mod
                                                                    if (p.extension(copiedFile.path) == '.jpg' ||
                                                                        p.extension(copiedFile.path) == '.png' && !curMod.submods[modViewModSetSubModIndex].previewImages.contains(copiedFile.path)) {
                                                                      curMod.submods[modViewModSetSubModIndex].previewImages.add(copiedFile.path);
                                                                    }
                                                                    if (p.extension(copiedFile.path) == '.mp4' ||
                                                                        p.extension(copiedFile.path) == '.webm' && !curMod.submods[modViewModSetSubModIndex].previewVideos.contains(copiedFile.path)) {
                                                                      curMod.submods[modViewModSetSubModIndex].previewVideos.add(copiedFile.path);
                                                                    }
                                                                    saveModdedItemListToJson();
                                                                  }
                                                                }
                                                                setState(() {});
                                                              },
                                                            ),

                                                            // rename
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.edit_note,
                                                              ),
                                                              child: Text(curLangText!.uiRename),
                                                              onPressed: () async {
                                                                String newName = await modsRenameDialog(context, curMod.location, curMod.submods[modViewModSetSubModIndex].location);
                                                                if (newName.isNotEmpty) {
                                                                  //change paths
                                                                  String oldSubmodPath = curMod.submods[modViewModSetSubModIndex].location;
                                                                  String newSubmodPath = Uri.file('${curMod.location}/$newName').toFilePath();
                                                                  if (oldSubmodPath == curMod.location) {
                                                                    await Directory(newSubmodPath).create(recursive: true);
                                                                    curMod.submods[modViewModSetSubModIndex].submodName = newName;
                                                                    curMod.submods[modViewModSetSubModIndex].location = newSubmodPath;
                                                                    curMod.submods[modViewModSetSubModIndex].previewImages.clear();
                                                                    curMod.submods[modViewModSetSubModIndex].previewVideos.clear();
                                                                    renamedPreviewPathsGet(curMod.submods[modViewModSetSubModIndex].location, curMod.submods[modViewModSetSubModIndex].previewImages,
                                                                        curMod.submods[modViewModSetSubModIndex].previewVideos);
                                                                    for (var modFile in curMod.submods[modViewModSetSubModIndex].modFiles) {
                                                                      modFile.submodName = newName;
                                                                      String newModFilePath = modFile.location.replaceFirst(oldSubmodPath, newSubmodPath);
                                                                      final movedFile = await File(modFile.location).rename(newModFilePath);
                                                                      modFile.location = movedFile.path;
                                                                    }
                                                                  } else {
                                                                    await Directory(oldSubmodPath).rename(newSubmodPath);
                                                                    curMod.submods[modViewModSetSubModIndex].submodName = newName;
                                                                    curMod.submods[modViewModSetSubModIndex].location = newSubmodPath;
                                                                    curMod.submods[modViewModSetSubModIndex].previewImages.clear();
                                                                    curMod.submods[modViewModSetSubModIndex].previewVideos.clear();
                                                                    renamedPreviewPathsGet(curMod.submods[modViewModSetSubModIndex].location, curMod.submods[modViewModSetSubModIndex].previewImages,
                                                                        curMod.submods[modViewModSetSubModIndex].previewVideos);
                                                                    for (var modFile in curMod.submods[modViewModSetSubModIndex].modFiles) {
                                                                      modFile.submodName = newName;
                                                                      modFile.location = modFile.location.replaceFirst(oldSubmodPath, newSubmodPath);
                                                                    }
                                                                  }
                                                                  modSetList = await modSetLoader();
                                                                  saveSetListToJson();
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                }
                                                              },
                                                            ),

                                                            // swap
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.swap_horizontal_circle_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiSwapToAnotherItem),
                                                              onPressed: () async {
                                                                if (!defaultCategoryDirs.contains(modViewItem.value!.category)) {
                                                                  fromItemCategory = await modsSwapperCategorySelect(context);
                                                                }
                                                                modsSwapperDialog(context, modViewItem.value!, curMod, curMod.submods[modViewModSetSubModIndex]);
                                                              },
                                                            ),

                                                            // export
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.import_export,
                                                              ),
                                                              child: Text(curLangText!.uiExportThisMod),
                                                              onPressed: () async => modExportHomePage(context, moddedItemsList, [curMod.submods[modViewModSetSubModIndex]], false),
                                                            ),

                                                            // open in file explorer
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.folder_open_outlined,
                                                              ),
                                                              child: Text(curLangText!.uiOpenInFileExplorer),
                                                              onPressed: () async {
                                                                if (Directory(Uri.file(curMod.submods[modViewModSetSubModIndex].location).toFilePath()).existsSync()) {
                                                                  await launchUrl(Uri.file(curMod.submods[modViewModSetSubModIndex].location));
                                                                } else {
                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', curLangText!.uiDirNotFound, 2000));
                                                                }
                                                              },
                                                            ),

                                                            // boundary
                                                            Visibility(
                                                              visible: curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[1] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[3] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[4] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[5] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[15] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.radio_button_checked,
                                                                ),
                                                                child: Text(curLangText!.uiRemoveBoundaryRadius),
                                                                onPressed: () {
                                                                  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                    element.deleteSync(recursive: true);
                                                                  });
                                                                  isBoundaryEdited = false;
                                                                  modsBoundaryEditHomePage(context, curMod.submods[modViewModSetSubModIndex]);
                                                                },
                                                              ),
                                                            ),

                                                            // aqm inject
                                                            Visibility(
                                                              visible: curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[1] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.auto_fix_normal,
                                                                ),
                                                                onPressed: File(modManCustomAqmFilePath).existsSync()
                                                                    ? () async {
                                                                        isAqmInjecting = false;
                                                                        await modAqmInjectionHomePage(context, curMod.submods[modViewModSetSubModIndex]);
                                                                      }
                                                                    : null,
                                                                child: Text(File(modManCustomAqmFilePath).existsSync()
                                                                    ? curLangText!.uiInjectCustomAqmFile
                                                                    : '${curLangText!.uiInjectCustomAqmFile}\n${curLangText!.uiSelectFileInSettings}'),
                                                              ),
                                                            ),

                                                            // aqm inject removal
                                                            Visibility(
                                                              visible: curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[1] ||
                                                                  curMod.submods[modViewModSetSubModIndex].category == defaultCategoryDirs[16],
                                                              child: MenuItemButton(
                                                                leadingIcon: const Icon(
                                                                  Icons.auto_fix_off,
                                                                ),
                                                                onPressed: () async {
                                                                  isAqmInjectionRemoving = false;
                                                                  await modAqmInjectionRemovalHomePage(context, curMod.submods[modViewModSetSubModIndex]);
                                                                },
                                                                child: Text(curLangText!.uiRemoveInjectedCustomAqm),
                                                              ),
                                                            ),

                                                            // remove from modset
                                                            MenuItemButton(
                                                              leadingIcon: const Icon(
                                                                Icons.delete_forever_outlined,
                                                              ),
                                                              onPressed: () async {
                                                                removeSubmodFromThisSet(selectedModSetName, modViewItem.value!, curMod, curMod.submods[modViewModSetSubModIndex]);
                                                                saveSetListToJson();
                                                                saveModdedItemListToJson();
                                                                setState(() {});
                                                              },
                                                              child: Text(
                                                                curLangText!.uiRemoveFromThisSet,
                                                              ),
                                                            ),

                                                            // delete
                                                            MenuItemButton(
                                                              leadingIcon: Icon(
                                                                Icons.delete_forever_outlined,
                                                                color: curMod.applyStatus ||
                                                                        curMod.submods[modViewModSetSubModIndex].location == curMod.location &&
                                                                            Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                    ? Theme.of(context).disabledColor
                                                                    : Colors.red,
                                                              ),
                                                              onPressed: curMod.applyStatus ||
                                                                      curMod.submods[modViewModSetSubModIndex].location == curMod.location &&
                                                                          Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                  ? null
                                                                  : () async {
                                                                      bool deleteConfirm = await modDeletionDialog(context, curMod.submods[modViewModSetSubModIndex].submodName);
                                                                      if (deleteConfirm) {
                                                                        if (curMod.submods.length < 2 && modViewMods.length < 2) {
                                                                          deleteItemFromModMan(modViewItem.value!.location).then((value) async {
                                                                            String removedName = '${modViewCate!.categoryName} > ${modViewItem.value!.itemName}';
                                                                            if (modViewItem.value!.isSet) {
                                                                              for (var setName in modViewItem.value!.setNames) {
                                                                                int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                                if (setIndex != -1) {
                                                                                  modSetList[setIndex].setItems.remove(modViewItem.value);
                                                                                }
                                                                              }
                                                                            }
                                                                            modViewCate!.removeItem(modViewItem.value);
                                                                            modViewItem.value != null;
                                                                            modViewItem.value = null;
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        } else {
                                                                          deleteSubmodFromModMan(curMod.submods[modViewModSetSubModIndex].location, curMod.location).then((value) async {
                                                                            String removedName = '${curMod.modName} > ${curMod.submods[modViewModSetSubModIndex].submodName}';
                                                                            curMod.submods.remove(curMod.submods[modViewModSetSubModIndex]);
                                                                            if (curMod.submods.isEmpty) {
                                                                              modViewItem.value!.removeMod(curMod);
                                                                            } else {
                                                                              curMod.isNew = curMod.getSubmodsIsNewState();
                                                                            }

                                                                            if (modViewItem.value!.mods.isEmpty) {
                                                                              modViewCate!.removeItem(modViewItem.value);
                                                                              modViewItem.value != null;
                                                                              modViewItem.value = null;
                                                                            } else {
                                                                              modViewItem.value!.isNew = modViewItem.value!.getModsIsNewState();
                                                                            }
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      }
                                                                    },
                                                              child: Text(
                                                                curLangText!.uiRemoveFromMM,
                                                                style: TextStyle(
                                                                    color: curMod.applyStatus ||
                                                                            curMod.submods[modViewModSetSubModIndex].location == curMod.location &&
                                                                                Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                        ? Theme.of(context).disabledColor
                                                                        : Colors.red),
                                                              ),
                                                            ),
                                                          ])
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          children: [
                                            SuperListView.builder(
                                                shrinkWrap: true,
                                                // cacheExtent: double.maxFinite,
                                                primary: false,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: curMod.submods.length,
                                                itemBuilder: (context, submodIndex) {
                                                  var curSubmod = curMod.submods[submodIndex];
                                                  return Visibility(
                                                    visible: isFavListVisible && !isModViewFromApplied
                                                        ? curSubmod.isFavorite
                                                        : context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                                            ? curSubmod.isSet && curSubmod.setNames.contains(selectedModSetName)
                                                            : searchTextController.value.text.toLowerCase().isNotEmpty
                                                                ? curSubmod.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) ||
                                                                    curMod.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).isEmpty
                                                                : true,
                                                    child: InkWell(
                                                      focusColor: Colors.transparent,
                                                      //submod preview images
                                                      onTap: () {},
                                                      onSecondaryTap: () {
                                                        if (previewImages.isNotEmpty) {
                                                          previewDialogImages = previewImages.toList();
                                                          previewDialogModName = previewModName;
                                                          previewDialog(context);
                                                        }
                                                      },
                                                      onHover: (hovering) {
                                                        previewImages.clear();
                                                        if (hovering) {
                                                          hoveringOnSubmod = true;
                                                          hoveringOnModFile = false;
                                                        } else {
                                                          hoveringOnSubmod = false;
                                                        }
                                                        if (hovering && hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible) {
                                                          previewModName = curSubmod.submodName;
                                                          previewImages.clear();
                                                          previewImages = curSubmod.getPreviewWidgets();
                                                        } else {
                                                          previewImages.clear();
                                                          previewModName = curMod.modName;
                                                          previewImages = curMod.getPreviewWidgets();
                                                        }
                                                        // setState(() {});
                                                      },
                                                      child: InfoPopupWidget(
                                                        horizontalDirection: 'right',
                                                        dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                        popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                        arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                        customContent: () =>
                                                            hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible && !showPreviewPanel && previewImages.isNotEmpty && !previewDismiss
                                                                ? PreviewHoverPanel(previewWidgets: previewImages)
                                                                : null,
                                                        child: ExpansionTile(
                                                          backgroundColor: Colors.transparent,
                                                          textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                          iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                          collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                          title: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                curSubmod.submodName,
                                                                style: TextStyle(
                                                                    color: curSubmod.applyStatus
                                                                        ? Theme.of(context).colorScheme.primary
                                                                        : curSubmod.isNew
                                                                            ? Colors.amber
                                                                            : null),
                                                              )),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Wrap(
                                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                                  runAlignment: WrapAlignment.center,
                                                                  spacing: 0,
                                                                  children: [
                                                                    //cmx indicator
                                                                    if (curSubmod.hasCmx!)
                                                                      Container(
                                                                        padding: const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 1),
                                                                        decoration: BoxDecoration(
                                                                          border:
                                                                              Border.all(color: curSubmod.cmxApplied! ? Theme.of(context).colorScheme.primary : Theme.of(context).primaryColorLight),
                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                        ),
                                                                        child: Text(curLangText!.uiCmx,
                                                                            style: TextStyle(
                                                                              color: curSubmod.cmxApplied! ? Theme.of(context).colorScheme.primary : null,
                                                                              fontSize: 15,
                                                                            )),
                                                                      ),
                                                                    // apply locations
                                                                    if (curSubmod.applyLocations!.isNotEmpty) const Icon(Icons.location_on_outlined),

                                                                    //Apply button in submod
                                                                    //remove button
                                                                    if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1)
                                                                      UnApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curSubmod),
                                                                    if (curSubmod.modFiles.indexWhere((element) => !element.applyStatus) != -1)
                                                                      ApplyModsButton(curItem: modViewItem.value, curMod: curMod, curSubmod: curSubmod),

                                                                    // quick apply
                                                                    Visibility(
                                                                      visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem.value!.category),
                                                                      child: MenuAnchor(
                                                                          builder: (BuildContext context, MenuController controller, Widget? child) {
                                                                            return ModManTooltip(
                                                                              message: curLangText!.uiSwapThisModToSelectedItemInList,
                                                                              child: InkWell(
                                                                                child: const Icon(
                                                                                  Icons.arrow_drop_down,
                                                                                ),
                                                                                onHover: (value) {
                                                                                  if (value) {
                                                                                    previewDismiss = true;
                                                                                  } else {
                                                                                    previewDismiss = false;
                                                                                  }
                                                                                  setState(() {});
                                                                                },
                                                                                onTap: () {
                                                                                  if (controller.isOpen) {
                                                                                    controller.close();
                                                                                  } else {
                                                                                    controller.open();
                                                                                  }
                                                                                },
                                                                              ),
                                                                            );
                                                                          },
                                                                          onClose: () {
                                                                            expansionListFNodes[modIndex].unfocus();
                                                                          },
                                                                          style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                            return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                                          }), shape: WidgetStateProperty.resolveWith((states) {
                                                                            return RoundedRectangleBorder(
                                                                                side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                                          })),
                                                                          menuChildren: quickApplyMenuButtons(context, curMod, curSubmod)),
                                                                    ),

                                                                    //More menu
                                                                    MenuAnchor(
                                                                        builder: (BuildContext context, MenuController controller, Widget? child) {
                                                                          return ModManTooltip(
                                                                            message: curLangText!.uiMore,
                                                                            child: InkWell(
                                                                              child: const Icon(
                                                                                Icons.more_vert,
                                                                              ),
                                                                              onHover: (value) {
                                                                                if (value) {
                                                                                  previewDismiss = true;
                                                                                } else {
                                                                                  previewDismiss = false;
                                                                                }
                                                                                setState(() {});
                                                                              },
                                                                              onTap: () {
                                                                                if (controller.isOpen) {
                                                                                  controller.close();
                                                                                } else {
                                                                                  controller.open();
                                                                                }
                                                                                setState(() {});
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                        onClose: () {
                                                                          expansionListFNodes[modIndex].unfocus();
                                                                        },
                                                                        style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                          return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                                        }), shape: WidgetStateProperty.resolveWith((states) {
                                                                          return RoundedRectangleBorder(
                                                                              side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                                        })),
                                                                        menuChildren: [
                                                                          // favorite
                                                                          MenuItemButton(
                                                                            leadingIcon: Icon(
                                                                              curSubmod.isFavorite ? FontAwesomeIcons.heartCircleMinus : FontAwesomeIcons.heartCirclePlus,
                                                                              //size: 18,
                                                                            ),
                                                                            child: Text(
                                                                              curSubmod.isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                                            ),
                                                                            onPressed: () async {
                                                                              if (curSubmod.isFavorite) {
                                                                                curSubmod.isFavorite = false;
                                                                                if (curMod.submods.where((element) => element.isFavorite).isEmpty) {
                                                                                  curMod.isFavorite = false;
                                                                                }
                                                                                if (modViewMods.where((element) => element.isFavorite).isEmpty) {
                                                                                  modViewItem.value!.isFavorite = false;
                                                                                }
                                                                              } else {
                                                                                curSubmod.isFavorite = true;
                                                                                curMod.isFavorite = true;
                                                                                modViewItem.value!.isFavorite = true;
                                                                              }
                                                                              saveModdedItemListToJson();
                                                                              setState(() {});
                                                                            },
                                                                          ),

                                                                          //Add to set
                                                                          SubmenuButton(
                                                                            menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                              return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                                            }), shape: WidgetStateProperty.resolveWith((states) {
                                                                              return RoundedRectangleBorder(
                                                                                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                                            })),
                                                                            alignmentOffset: const Offset(0, 8),
                                                                            menuChildren: modSetsMenuButtons(context, modViewItem.value!, curMod, curSubmod),
                                                                            leadingIcon: const Icon(
                                                                              Icons.list_alt_outlined,
                                                                            ),
                                                                            child: Text(curLangText!.uiAddToModSets),
                                                                          ),

                                                                          // Apply location select
                                                                          SubmenuButton(
                                                                            menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                                                                              return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                                            }), shape: WidgetStateProperty.resolveWith((states) {
                                                                              return RoundedRectangleBorder(
                                                                                  side: BorderSide(color: Theme.of(context).primaryColorLight),
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(2)));
                                                                            })),
                                                                            alignmentOffset: const Offset(0, 8),
                                                                            menuChildren: modApplyingLocationsMenuButtons(context, curSubmod),
                                                                            leadingIcon: const Icon(
                                                                              Icons.add_location_alt_outlined,
                                                                            ),
                                                                            child: Text(curLangText!.uiSelectApplyingLocations),
                                                                          ),

                                                                          // add or change cmx file
                                                                          Visibility(
                                                                              visible: curSubmod.category == defaultCategoryDirs[1] ||
                                                                                  curSubmod.category == defaultCategoryDirs[6] ||
                                                                                  curSubmod.category == defaultCategoryDirs[11] ||
                                                                                  curSubmod.category == defaultCategoryDirs[15] ||
                                                                                  curSubmod.category == defaultCategoryDirs[16],
                                                                              child: MenuItemButton(
                                                                                leadingIcon: const Icon(
                                                                                  Icons.note_add_rounded,
                                                                                ),
                                                                                child: Text(curLangText!.uiAddChangeCmxFile),
                                                                                onPressed: () async {
                                                                                  XTypeGroup typeGroup = XTypeGroup(
                                                                                    label: curLangText!.uiCmxFile,
                                                                                    extensions: const <String>['txt'],
                                                                                  );
                                                                                  XFile? selectedCmxFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                                  if (selectedCmxFile != null && selectedCmxFile.path.isNotEmpty) {
                                                                                    final copiedCmxFile =
                                                                                        await File(selectedCmxFile.path).copy(Uri.file('${curSubmod.location}/${selectedCmxFile.name}').toFilePath());
                                                                                    if (copiedCmxFile.existsSync()) {
                                                                                      curSubmod.cmxFile = copiedCmxFile.path;
                                                                                      curSubmod.hasCmx = true;
                                                                                      saveModdedItemListToJson();
                                                                                      if (curSubmod.cmxApplied!) {
                                                                                        int startPos = -1, endPos = -1;
                                                                                        (startPos, endPos) = await cmxModPatch(copiedCmxFile.path);
                                                                                        if (startPos != -1 && endPos != -1) {
                                                                                          curSubmod.cmxStartPos = startPos;
                                                                                          curSubmod.cmxEndPos = endPos;
                                                                                        }
                                                                                      }
                                                                                      saveModdedItemListToJson();
                                                                                    }
                                                                                  }
                                                                                  setState(() {});
                                                                                },
                                                                              )),

                                                                          //add preview
                                                                          MenuItemButton(
                                                                            leadingIcon: const Icon(Icons.preview_outlined),
                                                                            child: Text(curLangText!.uiAddPreviews),
                                                                            onPressed: () async {
                                                                              const XTypeGroup typeGroup = XTypeGroup(
                                                                                label: '.jpg, .png, .mp4, .webm',
                                                                                extensions: <String>['jpg', 'png', 'mp4', 'webm'],
                                                                              );
                                                                              final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                              if (selectedFile != null) {
                                                                                final copiedFile = await File(selectedFile.path).copy(curSubmod.location + p.separator + p.basename(selectedFile.path));
                                                                                if (copiedFile.existsSync()) {
                                                                                  //save to submod
                                                                                  if (p.extension(copiedFile.path) == '.jpg' ||
                                                                                      p.extension(copiedFile.path) == '.png' && !curSubmod.previewImages.contains(copiedFile.path)) {
                                                                                    curSubmod.previewImages.add(copiedFile.path);
                                                                                  }
                                                                                  if (p.extension(copiedFile.path) == '.mp4' ||
                                                                                      p.extension(copiedFile.path) == '.webm' && !curSubmod.previewVideos.contains(copiedFile.path)) {
                                                                                    curSubmod.previewVideos.add(copiedFile.path);
                                                                                  }
                                                                                  //save to mod
                                                                                  if (p.extension(copiedFile.path) == '.jpg' ||
                                                                                      p.extension(copiedFile.path) == '.png' && !curMod.previewImages.contains(copiedFile.path)) {
                                                                                    curMod.previewImages.add(copiedFile.path);
                                                                                  }
                                                                                  if (p.extension(copiedFile.path) == '.mp4' ||
                                                                                      p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
                                                                                    curMod.previewVideos.add(copiedFile.path);
                                                                                  }
                                                                                  saveModdedItemListToJson();
                                                                                }
                                                                              }
                                                                              setState(() {});
                                                                            },
                                                                          ),

                                                                          // rename
                                                                          MenuItemButton(
                                                                            leadingIcon: const Icon(
                                                                              Icons.edit_note,
                                                                            ),
                                                                            child: Text(curLangText!.uiRename),
                                                                            onPressed: () async {
                                                                              String newName = await modsRenameDialog(context, curMod.location, curSubmod.location);
                                                                              if (newName.isNotEmpty) {
                                                                                //change paths
                                                                                String oldSubmodPath = curSubmod.location;
                                                                                String newSubmodPath = Uri.file('${curMod.location}/$newName').toFilePath();
                                                                                if (oldSubmodPath == curMod.location) {
                                                                                  await Directory(newSubmodPath).create(recursive: true);
                                                                                  curSubmod.submodName = newName;
                                                                                  curSubmod.location = newSubmodPath;
                                                                                  curSubmod.previewImages.clear();
                                                                                  curSubmod.previewVideos.clear();
                                                                                  renamedPreviewPathsGet(curSubmod.location, curSubmod.previewImages, curSubmod.previewVideos);
                                                                                  for (var modFile in curSubmod.modFiles) {
                                                                                    modFile.submodName = newName;
                                                                                    String newModFilePath = modFile.location.replaceFirst(oldSubmodPath, newSubmodPath);
                                                                                    final movedFile = await File(modFile.location).rename(newModFilePath);
                                                                                    modFile.location = movedFile.path;
                                                                                  }
                                                                                } else {
                                                                                  await Directory(oldSubmodPath).rename(newSubmodPath);
                                                                                  curSubmod.submodName = newName;
                                                                                  curSubmod.location = newSubmodPath;
                                                                                  curSubmod.previewImages.clear();
                                                                                  curSubmod.previewVideos.clear();
                                                                                  renamedPreviewPathsGet(curSubmod.location, curSubmod.previewImages, curSubmod.previewVideos);
                                                                                  for (var modFile in curSubmod.modFiles) {
                                                                                    modFile.submodName = newName;
                                                                                    modFile.location = modFile.location.replaceFirst(oldSubmodPath, newSubmodPath);
                                                                                  }
                                                                                }
                                                                                modSetList = await modSetLoader();
                                                                                saveSetListToJson();
                                                                                saveModdedItemListToJson();
                                                                                setState(() {});
                                                                              }
                                                                            },
                                                                          ),

                                                                          // swap
                                                                          MenuItemButton(
                                                                            leadingIcon: const Icon(
                                                                              Icons.swap_horizontal_circle_outlined,
                                                                            ),
                                                                            child: Text(curLangText!.uiSwapToAnotherItem),
                                                                            onPressed: () async {
                                                                              if (!defaultCategoryDirs.contains(modViewItem.value!.category)) {
                                                                                fromItemCategory = await modsSwapperCategorySelect(context);
                                                                              }
                                                                              modsSwapperDialog(context, modViewItem.value!, curMod, curSubmod);
                                                                            },
                                                                          ),

                                                                          // export
                                                                          MenuItemButton(
                                                                            leadingIcon: const Icon(
                                                                              Icons.import_export,
                                                                            ),
                                                                            child: Text(curLangText!.uiExportThisMod),
                                                                            onPressed: () async => modExportHomePage(context, moddedItemsList, [curSubmod], false),
                                                                          ),

                                                                          // open in file explorer
                                                                          MenuItemButton(
                                                                            leadingIcon: const Icon(
                                                                              Icons.folder_open_outlined,
                                                                            ),
                                                                            child: Text(curLangText!.uiOpenInFileExplorer),
                                                                            onPressed: () async {
                                                                              if (Directory(Uri.file(curSubmod.location).toFilePath()).existsSync()) {
                                                                                await launchUrl(Uri.file(curSubmod.location));
                                                                              } else {
                                                                                ScaffoldMessenger.of(context)
                                                                                    .showSnackBar(snackBarMessage(context, '${curLangText!.uiError}!', curLangText!.uiDirNotFound, 2000));
                                                                              }
                                                                            },
                                                                          ),

                                                                          // boundary
                                                                          Visibility(
                                                                            visible: curSubmod.category == defaultCategoryDirs[1] ||
                                                                                curSubmod.category == defaultCategoryDirs[3] ||
                                                                                curSubmod.category == defaultCategoryDirs[4] ||
                                                                                curSubmod.category == defaultCategoryDirs[5] ||
                                                                                curSubmod.category == defaultCategoryDirs[15] ||
                                                                                curSubmod.category == defaultCategoryDirs[16],
                                                                            child: MenuItemButton(
                                                                              leadingIcon: const Icon(
                                                                                Icons.radio_button_checked,
                                                                              ),
                                                                              child: Text(curLangText!.uiRemoveBoundaryRadius),
                                                                              onPressed: () async {
                                                                                Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                                                                  element.deleteSync(recursive: true);
                                                                                });
                                                                                isBoundaryEdited = false;
                                                                                await modsBoundaryEditHomePage(context, curSubmod);
                                                                              },
                                                                            ),
                                                                          ),

                                                                          // aqm inject
                                                                          Visibility(
                                                                            visible: curSubmod.category == defaultCategoryDirs[1] || curSubmod.category == defaultCategoryDirs[16],
                                                                            child: MenuItemButton(
                                                                              leadingIcon: const Icon(
                                                                                Icons.auto_fix_normal,
                                                                              ),
                                                                              onPressed: File(modManCustomAqmFilePath).existsSync()
                                                                                  ? () async {
                                                                                      isAqmInjecting = false;
                                                                                      await modAqmInjectionHomePage(context, curSubmod);
                                                                                    }
                                                                                  : null,
                                                                              child: Text(File(modManCustomAqmFilePath).existsSync()
                                                                                  ? curLangText!.uiInjectCustomAqmFile
                                                                                  : '${curLangText!.uiInjectCustomAqmFile}\n${curLangText!.uiSelectFileInSettings}'),
                                                                            ),
                                                                          ),

                                                                          // aqm inject removal
                                                                          Visibility(
                                                                            visible: curSubmod.category == defaultCategoryDirs[1] || curSubmod.category == defaultCategoryDirs[16],
                                                                            child: MenuItemButton(
                                                                              leadingIcon: const Icon(
                                                                                Icons.auto_fix_off,
                                                                              ),
                                                                              onPressed: () async {
                                                                                isAqmInjectionRemoving = false;
                                                                                await modAqmInjectionRemovalHomePage(context, curSubmod);
                                                                              },
                                                                              child: Text(curLangText!.uiRemoveInjectedCustomAqm),
                                                                            ),
                                                                          ),

                                                                          //remove from set
                                                                          Visibility(
                                                                            visible: context.watch<StateProvider>().setsWindowVisible && curSubmod.isSet,
                                                                            child: MenuItemButton(
                                                                              leadingIcon: const Icon(
                                                                                Icons.delete_forever_outlined,
                                                                              ),
                                                                              onPressed: () async {
                                                                                removeSubmodFromThisSet(selectedModSetName, modViewItem.value!, curMod, curSubmod);
                                                                                saveSetListToJson();
                                                                                saveModdedItemListToJson();
                                                                                setState(() {});
                                                                              },
                                                                              child: Text(
                                                                                curLangText!.uiRemoveFromThisSet,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          // delete
                                                                          MenuItemButton(
                                                                            leadingIcon: Icon(
                                                                              Icons.delete_forever_outlined,
                                                                              color: curSubmod.applyStatus ||
                                                                                      curSubmod.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                                  ? Theme.of(context).disabledColor
                                                                                  : Colors.red,
                                                                            ),
                                                                            onPressed: curSubmod.applyStatus ||
                                                                                    curSubmod.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                                ? null
                                                                                : () async {
                                                                                    bool deleteConfirm = await modDeletionDialog(context, curSubmod.submodName);
                                                                                    if (deleteConfirm) {
                                                                                      if (curMod.submods.length < 2 && modViewMods.length < 2) {
                                                                                        deleteItemFromModMan(modViewItem.value!.location).then((value) async {
                                                                                          String removedName = '${modViewCate!.categoryName} > ${modViewItem.value!.itemName}';
                                                                                          if (modViewItem.value!.isSet) {
                                                                                            for (var setName in modViewItem.value!.setNames) {
                                                                                              int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                                              if (setIndex != -1) {
                                                                                                modSetList[setIndex].setItems.remove(modViewItem.value);
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                          modViewCate!.removeItem(modViewItem.value);
                                                                                          modViewItem.value != null;
                                                                                          modViewItem.value = null;
                                                                                          previewModName = '';
                                                                                          previewImages.clear();
                                                                                          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                              uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                                          saveModdedItemListToJson();
                                                                                          setState(() {});
                                                                                        });
                                                                                      } else {
                                                                                        deleteSubmodFromModMan(curSubmod.location, curMod.location).then((value) async {
                                                                                          String removedName = '${curMod.modName} > ${curSubmod.submodName}';
                                                                                          curMod.submods.remove(curSubmod);
                                                                                          if (curMod.submods.isEmpty) {
                                                                                            modViewItem.value!.removeMod(curMod);
                                                                                          } else {
                                                                                            curMod.isNew = curMod.getSubmodsIsNewState();
                                                                                          }
                                                                                          if (modViewItem.value!.mods.isEmpty) {
                                                                                            modViewCate!.removeItem(modViewItem.value);
                                                                                            modViewItem.value != null;
                                                                                            modViewItem.value = null;
                                                                                          } else {
                                                                                            modViewItem.value!.isNew = modViewItem.value!.getModsIsNewState();
                                                                                          }
                                                                                          previewModName = '';
                                                                                          previewImages.clear();
                                                                                          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                              uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                                          saveModdedItemListToJson();
                                                                                          setState(() {});
                                                                                        });
                                                                                      }
                                                                                    }
                                                                                  },
                                                                            child: Text(
                                                                              curLangText!.uiRemoveFromMM,
                                                                              style: TextStyle(
                                                                                  color: curSubmod.applyStatus ||
                                                                                          curSubmod.location == curMod.location &&
                                                                                              Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                                                      ? Theme.of(context).disabledColor
                                                                                      : Colors.red),
                                                                            ),
                                                                          ),
                                                                        ])
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          children: [
                                                            SuperListView.builder(
                                                                shrinkWrap: true,
                                                                primary: false,
                                                                physics: const NeverScrollableScrollPhysics(),
                                                                itemCount: curSubmod.modFiles.length,
                                                                itemBuilder: (context, modFileIndex) {
                                                                  var curModFile = curSubmod.modFiles[modFileIndex];
                                                                  return Visibility(
                                                                      visible: context.watch<StateProvider>().setsWindowVisible ? curModFile.isSet : true,
                                                                      child: InkWell(
                                                                        onTap: () {},
                                                                        onSecondaryTap: () {
                                                                          if (previewImages.isNotEmpty) {
                                                                            previewDialogImages = previewImages.toList();
                                                                            previewDialogModName = previewModName;
                                                                            previewDialog(context);
                                                                          }
                                                                        },
                                                                        onHover: (hovering) {
                                                                          previewImages.clear();
                                                                          if (hovering) {
                                                                            hoveringOnModFile = true;
                                                                            hoveringOnSubmod = false;
                                                                          } else {
                                                                            hoveringOnSubmod = true;
                                                                            hoveringOnModFile = false;
                                                                          }
                                                                          if (hovering && previewWindowVisible && hoveringOnModFile) {
                                                                            previewModName = curModFile.modFileName;
                                                                          } else if (previewWindowVisible && hoveringOnSubmod && !hoveringOnModFile) {
                                                                            previewModName = curSubmod.submodName;
                                                                          }
                                                                          previewImages = curSubmod.getPreviewWidgets();
                                                                        },
                                                                        child: InfoPopupWidget(
                                                                            horizontalDirection: 'right',
                                                                            dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                                            popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                                            arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                                            customContent: () =>
                                                                                previewWindowVisible && hoveringOnModFile && !showPreviewPanel && previewImages.isNotEmpty && !previewDismiss
                                                                                    ? PreviewHoverPanel(previewWidgets: previewImages)
                                                                                    : null,
                                                                            child: ListTile(
                                                                              tileColor: Colors.transparent,
                                                                              //tileColor: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                                                              trailing: Wrap(
                                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                                runAlignment: WrapAlignment.center,
                                                                                spacing: 5,
                                                                                children: [
                                                                                  //Add-Remove button
                                                                                  if (!curModFile.applyStatus)
                                                                                    ModManTooltip(
                                                                                      message: uiInTextArg(curLangText!.uiApplyXToTheGame, curModFile.modFileName),
                                                                                      child: InkWell(
                                                                                        child: const Icon(
                                                                                          Icons.add,
                                                                                        ),
                                                                                        onTap: () async {
                                                                                          //apply mod files
                                                                                          if (await originalFilesCheck(context, [curModFile])) {
                                                                                            modFilesApply(context, [curModFile]).then((value) async {
                                                                                              if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
                                                                                                curSubmod.applyDate = DateTime.now();
                                                                                                modViewItem.value!.applyDate = DateTime.now();
                                                                                                curMod.applyDate = DateTime.now();
                                                                                                curSubmod.setApplyState(true);
                                                                                                curSubmod.isNew = false;
                                                                                                curMod.setApplyState(true);
                                                                                                curMod.isNew = false;
                                                                                                modViewItem.value!.setApplyState(true);
                                                                                                if (modViewMods.where((element) => element.isNew).isEmpty) {
                                                                                                  modViewItem.value!.isNew = false;
                                                                                                }
                                                                                                if (autoAqmInject) await aqmInjectionOnModsApply(context, curSubmod);
                                                                                                if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                                                  await applyOverlayedIcon(context, modViewItem.value!);
                                                                                                }
                                                                                                Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                                                                                                List<ModFile> appliedModFiles = value;
                                                                                                String fileAppliedText = '';
                                                                                                for (var element in appliedModFiles) {
                                                                                                  if (fileAppliedText.isEmpty) {
                                                                                                    fileAppliedText = uiInTextArgs(
                                                                                                        curLangText!.uiSuccessfullyAppliedXInY, ['<x>', '<y>'], [curMod.modName, curSubmod.submodName]);
                                                                                                  }
                                                                                                  fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                                }
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                    context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                              }

                                                                                              saveModdedItemListToJson();
                                                                                              setState(() {});
                                                                                            });
                                                                                          }
                                                                                          setState(() {});
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  if (curModFile.applyStatus)
                                                                                    ModManTooltip(
                                                                                      message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, curModFile.modFileName),
                                                                                      child: InkWell(
                                                                                        child: const Icon(
                                                                                          Icons.remove,
                                                                                        ),
                                                                                        onTap: () async {
                                                                                          //status
                                                                                          restoreOriginalFilesToTheGame(context, [curModFile]).then((value) async {
                                                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              curSubmod.setApplyState(false);
                                                                                              if (curSubmod.cmxApplied!) {
                                                                                                bool status = await cmxModRemoval(curSubmod.cmxStartPos!, curSubmod.cmxEndPos!);
                                                                                                if (status) {
                                                                                                  curSubmod.cmxApplied = false;
                                                                                                  curSubmod.cmxStartPos = -1;
                                                                                                  curSubmod.cmxEndPos = -1;
                                                                                                }
                                                                                              }
                                                                                              if (autoAqmInject) {
                                                                                                await aqmInjectionRemovalSilent(context, curSubmod);
                                                                                              }
                                                                                            }
                                                                                            if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              curMod.setApplyState(false);
                                                                                            }
                                                                                            if (modViewItem.value!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              modViewItem.value!.setApplyState(false);
                                                                                              if (modViewItem.value!.backupIconPath!.isNotEmpty) {
                                                                                                await restoreOverlayedIcon(modViewItem.value!);
                                                                                              }
                                                                                            }

                                                                                            await filesRestoredMessage(mainPageScaffoldKey.currentContext, [curModFile], value);
                                                                                            if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                              Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                                            }
                                                                                            saveModdedItemListToJson();
                                                                                            setState(() {});
                                                                                          });
                                                                                        },
                                                                                      ),
                                                                                    ),

                                                                                  //Remove from current Set
                                                                                  Visibility(
                                                                                    visible: context.watch<StateProvider>().setsWindowVisible,
                                                                                    child: ModManTooltip(
                                                                                      message: uiInTextArg(curLangText!.uiHoldToRemoveXFromThisSet, curModFile.modFileName),
                                                                                      child: InkWell(
                                                                                        onLongPress: () async {
                                                                                          removeModFileFromThisSet(selectedModSetName, modViewItem.value!, curMod, curSubmod, curModFile);
                                                                                          saveSetListToJson();
                                                                                          saveModdedItemListToJson();
                                                                                          setState(() {});
                                                                                        },
                                                                                        child: const Icon(Icons.delete_forever_outlined),
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                  //add preview
                                                                                  ModManTooltip(
                                                                                    message: curLangText!.uiAddPreviews,
                                                                                    child: InkWell(
                                                                                      onTap: () async {
                                                                                        const XTypeGroup typeGroup = XTypeGroup(
                                                                                          label: '.jpg, .png, .mp4, .webm',
                                                                                          extensions: <String>['jpg', 'png', 'mp4', 'webm'],
                                                                                        );
                                                                                        final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                                                                                        if (selectedFile != null) {
                                                                                          final copiedFile = await File(selectedFile.path).copy(curModFile.location + p.extension(selectedFile.path));
                                                                                          if (copiedFile.existsSync()) {
                                                                                            if ((p.extension(copiedFile.path) == '.jpg' || p.extension(copiedFile.path) == '.png') &&
                                                                                                !curModFile.previewImages!.contains(copiedFile.path)) {
                                                                                              curModFile.previewImages!.add(copiedFile.path);
                                                                                            }
                                                                                            if ((p.extension(copiedFile.path) == '.mp4' || p.extension(copiedFile.path) == '.webm') &&
                                                                                                !curModFile.previewVideos!.contains(copiedFile.path)) {
                                                                                              curModFile.previewVideos!.add(copiedFile.path);
                                                                                            }
                                                                                            //save to submod
                                                                                            if (p.extension(copiedFile.path) == '.jpg' ||
                                                                                                p.extension(copiedFile.path) == '.png' && !curSubmod.previewImages.contains(copiedFile.path)) {
                                                                                              curSubmod.previewImages.add(copiedFile.path);
                                                                                            }
                                                                                            if (p.extension(copiedFile.path) == '.mp4' ||
                                                                                                p.extension(copiedFile.path) == '.webm' && !curSubmod.previewVideos.contains(copiedFile.path)) {
                                                                                              curSubmod.previewVideos.add(copiedFile.path);
                                                                                            }
                                                                                            //save to mod
                                                                                            if (p.extension(copiedFile.path) == '.jpg' ||
                                                                                                p.extension(copiedFile.path) == '.png' && !curMod.previewImages.contains(copiedFile.path)) {
                                                                                              curMod.previewImages.add(copiedFile.path);
                                                                                            }
                                                                                            if (p.extension(copiedFile.path) == '.mp4' ||
                                                                                                p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
                                                                                              curMod.previewVideos.add(copiedFile.path);
                                                                                            }
                                                                                            saveModdedItemListToJson();
                                                                                          }
                                                                                        }
                                                                                        setState(() {});
                                                                                      },
                                                                                      child: const Icon(Icons.preview_outlined),
                                                                                    ),
                                                                                  ),

                                                                                  //Delete
                                                                                  ModManTooltip(
                                                                                    message: uiInTextArg(curLangText!.uiHoldToRemoveXFromModMan, curModFile.modFileName),
                                                                                    child: InkWell(
                                                                                      onLongPress: curModFile.applyStatus
                                                                                          ? null
                                                                                          : () async {
                                                                                              if (curSubmod.modFiles.length < 2 && curMod.submods.length < 2 && modViewMods.length < 2) {
                                                                                                deleteItemFromModMan(modViewItem.value!.location).then((value) async {
                                                                                                  String removedName = '${modViewCate!.categoryName} > ${modViewItem.value!.itemName}';
                                                                                                  modViewCate!.removeItem(modViewItem.value);
                                                                                                  modViewItem.value != null;
                                                                                                  modViewItem.value = null;
                                                                                                  previewModName = '';
                                                                                                  previewImages.clear();
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                                      uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                                                  saveModdedItemListToJson();
                                                                                                  setState(() {});
                                                                                                });
                                                                                              } else {
                                                                                                deleteModFileFromModMan(curModFile.location, curSubmod.location, curMod.location).then((value) async {
                                                                                                  String removedName = '${curMod.modName} > ${curSubmod.submodName} > $curModFile';
                                                                                                  curSubmod.modFiles.remove(curModFile);

                                                                                                  if (curSubmod.modFiles.isEmpty) {
                                                                                                    curMod.submods.remove(curSubmod);
                                                                                                  } else {
                                                                                                    curSubmod.isNew = curSubmod.getModFilesIsNewState();
                                                                                                  }
                                                                                                  if (curMod.submods.isEmpty) {
                                                                                                    modViewItem.value!.removeMod(curMod);
                                                                                                  } else {
                                                                                                    curMod.isNew = curMod.getSubmodsIsNewState();
                                                                                                  }
                                                                                                  if (modViewItem.value!.mods.isEmpty) {
                                                                                                    modViewCate!.removeItem(modViewItem.value);
                                                                                                    modViewItem.value != null;
                                                                                                    modViewItem.value = null;
                                                                                                  } else {
                                                                                                    modViewItem.value!.isNew = modViewItem.value!.getModsIsNewState();
                                                                                                  }
                                                                                                  previewModName = '';
                                                                                                  previewImages.clear();
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                                      uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                                                  saveModdedItemListToJson();
                                                                                                  setState(() {});
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                      child: Icon(
                                                                                        Icons.delete_forever_outlined,
                                                                                        color: curModFile.applyStatus ? Theme.of(context).disabledColor : Colors.red,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              title: Text(
                                                                                curModFile.modFileName,
                                                                                style: TextStyle(color: curModFile.applyStatus ? Theme.of(context).colorScheme.primary : null),
                                                                              ),
                                                                            )),
                                                                      ));
                                                                })
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                          // )
                        }))),
        ]);
      },
    );
  }

  //WIDGETS=============================================================================
  List<Widget> quickApplyMenuButtons(context, Mod mod, SubMod submod) {
    List<Widget> menuButtonList = [];
    List<CsvItem> quickApplyItems = quickApplyItemList.where((e) => e.category == submod.category || (e.category == defaultCategoryDirs[1] && submod.category == defaultCategoryDirs[16])).toList();
    //add popup
    menuButtonList.add(
      MenuItemButton(
          closeOnActivate: true,
          child: Text(curLangText!.uiAddRemoveQuickApplyItems),
          onPressed: () async {
            quickApplyDialog(context, submod.category);
            setState(() {});
          }),
    );

    //separator
    menuButtonList.add(Divider(height: 2, indent: 5, endIndent: 5, thickness: 1, color: Theme.of(context).primaryColorLight));

    for (var quickApplyItem in quickApplyItems) {
      menuButtonList.add(
        MenuItemButton(
            closeOnActivate: true,
            onPressed: playerItemData
                    .where((element) =>
                        (element.category == submod.category ||
                            (submod.category == defaultCategoryDirs[16] && element.category == defaultCategoryDirs[1]) ||
                            (submod.category == defaultCategoryDirs[2] && element.category == defaultCategoryDirs[11]) ||
                            (submod.category == defaultCategoryDirs[11] && element.category == defaultCategoryDirs[2])) &&
                        element.containsIceFiles(submod.getModFileNames()))
                    .isNotEmpty
                ? () async {
                    bool found = false;
                    Item? quickItem;
                    Mod? quickMod;
                    SubMod? quickSubmod;
                    isModViewModsApplying = true;
                    setState(() {});
                    //precheck
                    for (var cateType in moddedItemsList) {
                      for (var cate in cateType.categories
                          .where((element) => element.categoryName == quickApplyItem.category || (element.categoryName == defaultCategoryDirs[1] && submod.category == defaultCategoryDirs[16]))) {
                        for (var item in cate.items) {
                          if (item.itemName == quickApplyItem.getENName().replaceAll(RegExp(charToReplace), '_').trim() ||
                              item.itemName == quickApplyItem.getJPName().replaceAll(RegExp(charToReplace), '_').trim()) {
                            for (var mod in item.mods) {
                              if (mod.modName == submod.modName) {
                                for (var sub in mod.submods) {
                                  if (sub.submodName == submod.submodName || sub.submodName == submod.submodName) {
                                    quickItem = item;
                                    quickMod = mod;
                                    quickSubmod = sub;
                                    found = true;
                                    break;
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    if (!found) {
                      quickItem = null;
                      quickMod = null;
                      quickSubmod = null;
                      if (defaultCategoryDirs.indexOf(submod.category) == 0) {
                        //swapping acc
                        //from
                        CsvItem? filteredFromItem = playerItemData.firstWhere((element) => element.category == defaultCategoryDirs[0] && element.containsIceFiles(submod.getModFileNames()));
                        CsvIceFile fromItem = CsvIceFile.fromList(filteredFromItem.getInfos());
                        final fromItemIces = fromItem.getDetailedList().where((element) => element.split(': ').last.isNotEmpty && submod.getModFileNames().contains(element.split(': ').last)).toList();
                        //to
                        CsvIceFile toItem = CsvIceFile.fromList(quickApplyItem.getInfos());
                        List<String> toItemIces = [];
                        for (var line in toItem.getDetailedList()) {
                          if (fromItemIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                            toItemIces.add(line);
                          }
                        }

                        String swappedPath = await modsSwapperAccIceFilesGet(
                            context, false, mod, submod, fromItemIces, toItemIces, modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName());
                        //adding
                        var returnedVar = await modsAdderModFilesAdder(
                            context,
                            await modsAdderFilesProcess(context, [XFile(Uri.file('$swappedPath/${submod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath())],
                                modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName()));
                        List<Item> returnedItems = returnedVar.$2;
                        quickItem = returnedItems.first;
                        quickMod = quickItem.mods.firstWhere((e) => e.modName == submod.modName);
                        quickSubmod = quickMod.submods.firstWhere((e) => e.submodName == submod.submodName);
                      } else {
                        //swapping
                        //from
                        CsvItem? filteredFromItem = playerItemData.firstWhere((element) =>
                            (element.category == submod.category ||
                                (submod.category == defaultCategoryDirs[16] && element.category == defaultCategoryDirs[1]) ||
                                (submod.category == defaultCategoryDirs[2] && element.category == defaultCategoryDirs[11]) ||
                                (submod.category == defaultCategoryDirs[11] && element.category == defaultCategoryDirs[2])) &&
                            element.containsIceFiles(submod.getModFileNames()));
                        CsvIceFile fromItem = CsvIceFile.fromList(filteredFromItem.getInfos());
                        final fromItemIces = fromItem.getDetailedList().where((element) => element.split(': ').last.isNotEmpty && submod.getModFileNames().contains(element.split(': ').last)).toList();
                        String fromItemId = fromItem.id.toString();
                        //to
                        CsvIceFile toItem = CsvIceFile.fromList(quickApplyItem.getInfos());
                        List<String> toItemIces = [];
                        for (var line in toItem.getDetailedList()) {
                          if (fromItemIces.where((element) => element.split(': ').first == line.split(': ').first).isNotEmpty) {
                            toItemIces.add(line);
                          }
                        }
                        String toItemId = toItem.id.toString();

                        String swappedPath = await modsSwapperIceFilesGet(context, false, mod, submod, fromItemIces, toItemIces,
                            modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName(), fromItemId, toItemId);
                        //adding
                        var returnedVar = await modsAdderModFilesAdder(
                            context,
                            await modsAdderFilesProcess(context, [XFile(Uri.file('$swappedPath/${submod.modName.replaceAll(RegExp(charToReplaceWithoutSeparators), '_')}').toFilePath())],
                                modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName()));
                        List<Item> returnedItems = returnedVar.$2;
                        quickItem = returnedItems.first;
                        quickMod = quickItem.mods.firstWhere((e) => e.modName == submod.modName);
                        quickSubmod = quickMod.submods.firstWhere((e) => e.submodName == submod.submodName);
                      }
                    }
                    //apply
                    if (quickItem != null && quickMod != null) {
                      Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                        //apply mod files
                        if (await originalFilesCheck(context, quickSubmod!.modFiles)) {
                          //apply auto radius removal if on
                          if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, quickSubmod);
                          if (autoAqmInject) await aqmInjectionOnModsApply(context, quickSubmod);

                          await applyModsToTheGame(context, quickItem!, quickMod!, quickSubmod);

                          if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                            await applyOverlayedIcon(context, quickItem);
                          }
                          Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                        }
                        setState(() {});
                      });
                    }

                    clearAllTempDirs();
                    setState(() {});
                  }
                : null,
            child: Text(modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName())),
      );
    }

    return menuButtonList;
  }

  List<Widget> modApplyingLocationsMenuButtons(context, SubMod submod) {
    List<Widget> menuButtonList = [];
    List<String> gameDataPaths = Directory(Uri.file("$modManPso2binPath/data").toFilePath())
        .listSync()
        .whereType<Directory>()
        .where((element) => p.basename(element.path).contains('win32'))
        .map((e) => Uri.directory(e.path).toFilePath())
        .toList();
    gameDataPaths.sort((a, b) => a.compareTo(b));

    for (var dataPath in gameDataPaths) {
      menuButtonList.add(
        MenuItemButton(
            closeOnActivate: false,
            style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
              return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
            })),
            leadingIcon: submod.applyLocations!.contains(dataPath) ? const Icon(Icons.check_box_outlined) : const Icon(Icons.check_box_outline_blank_rounded),
            child: Text(p.basename(dataPath)),
            onPressed: () async {
              if (submod.applyLocations!.contains(dataPath)) {
                submod.applyLocations!.remove(dataPath);
                for (var modFile in submod.modFiles) {
                  modFile.applyLocations!.remove(dataPath);
                }
              } else {
                submod.applyLocations!.add(dataPath);
                for (var modFile in submod.modFiles) {
                  if (!modFile.applyLocations!.contains(dataPath)) {
                    modFile.applyLocations!.add(dataPath);
                  }
                }
              }
              saveModdedItemListToJson();
              setState(() {});
            }),
      );
    }

    //separator
    menuButtonList.add(Divider(height: 2, indent: 5, endIndent: 5, thickness: 1, color: Theme.of(context).primaryColorLight));

    //reset
    menuButtonList.add(
      MenuItemButton(
          closeOnActivate: false,
          style: ButtonStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
          })),
          leadingIcon: submod.applyLocations == null || submod.applyLocations!.isEmpty ? const Icon(Icons.check_box_outlined) : const Icon(Icons.check_box_outline_blank_rounded),
          child: Text(curLangText!.uiApplyToAllLocations),
          onPressed: () async {
            if (submod.applyLocations != null || submod.applyLocations!.isNotEmpty) {
              submod.applyLocations!.clear();
              for (var modFile in submod.modFiles) {
                modFile.applyLocations!.clear();
              }
            }
            saveModdedItemListToJson();
            setState(() {});
          }),
    );
    return menuButtonList;
  }
}
