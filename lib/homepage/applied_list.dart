// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/modfiles_contain_in_list_function.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/preview_dialog.dart';
import 'package:pso2_mod_manager/functions/reapply_applied_mods.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/functions/unapply_all_mods.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/home_page.dart';
import 'package:pso2_mod_manager/homepage/mod_view.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';
import 'package:pso2_mod_manager/sharing/mods_export.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/preview_hover_panel.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class AppliedList extends StatefulWidget {
  const AppliedList({super.key});

  @override
  State<AppliedList> createState() => _AppliedListState();
}

class _AppliedListState extends State<AppliedList> {
  @override
  Widget build(BuildContext context) {
    int totalModFilesInAppliedList = 0;
    for (var type in moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0)) {
      for (var cate in type.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
        for (var item in cate.items) {
          if (item.applyStatus) {
            for (var mod in item.mods) {
              if (mod.applyStatus) {
                for (var submod in mod.submods) {
                  if (submod.applyStatus) {
                    totalModFilesInAppliedList += submod.modFiles.where((element) => element.applyStatus).length;
                  }
                }
              }
            }
          }
        }
      }
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: <Widget>[
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, spacing: 5, children: [
            //checkbox
            ModManTooltip(
              message: selectedModFilesInAppliedList.length < totalModFilesInAppliedList ? curLangText!.uiSelectAllAppliedMods : curLangText!.uiDeselectAllAppliedMods,
              child: InkWell(
                  onTap: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty
                      ? null
                      : () async {
                          if (selectedModFilesInAppliedList.isEmpty || selectedModFilesInAppliedList.length < totalModFilesInAppliedList) {
                            for (var type in moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0)) {
                              for (var cate in type.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
                                for (var item in cate.items) {
                                  if (item.applyStatus) {
                                    for (var mod in item.mods) {
                                      if (mod.applyStatus) {
                                        for (var submod in mod.submods) {
                                          if (submod.applyStatus) {
                                            selectedSubmodsInAppliedList.add(submod);
                                            selectedModFilesInAppliedList.addAll(submod.modFiles.where((element) => element.applyStatus));
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          } else {
                            selectedSubmodsInAppliedList.clear();
                            selectedModFilesInAppliedList.clear();
                          }
                          setState(() {});
                        },
                  child: Row(
                    children: [
                      Icon(
                        //size: 28,
                        color: selectedModFilesInAppliedList.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty
                                ? Theme.of(context).disabledColor
                                : null,
                        selectedModFilesInAppliedList.isEmpty
                            ? Icons.check_box_outline_blank_outlined
                            : selectedModFilesInAppliedList.length < totalModFilesInAppliedList
                                ? Icons.check_box_rounded
                                : Icons.check_box_outlined,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        selectedModFilesInAppliedList.isEmpty || selectedModFilesInAppliedList.length < totalModFilesInAppliedList ? curLangText!.uiSelectAll : curLangText!.uiDeselectAll,
                        style: TextStyle(
                          color: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty ? Theme.of(context).disabledColor : null,
                        ),
                      )
                    ],
                  )),
            ),
            //Reapply selected applied mods to game
            Stack(
              children: [
                Visibility(
                  visible: modViewModsApplyRemoving.watch(context),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
                Visibility(
                  visible: !modViewModsApplyRemoving.watch(context),
                  child: ModManTooltip(
                    message: curLangText!.uiHoldToReapplySelectedMods,
                    child: InkWell(
                        onLongPress: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                modViewModsApplyRemoving.value = true;
                                setState(() {});
                                Future.delayed(const Duration(milliseconds: applyButtonsDelay), () async {
                                  final reappliedList = await reapplySelectedAppliedMods(context);
                                  // .then((value) {

                                  saveModdedItemListToJson();
                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, reappliedList.first, reappliedList[1], 3000));
                                  modViewModsApplyRemoving.value = false;
                                  setState(() {});
                                });
                                // });
                              },
                        child: Icon(
                          Icons.playlist_add,
                          color: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                        )),
                  ),
                ),
              ],
            ),
            //Remove selected mods from game
            Stack(
              children: [
                Visibility(
                  visible: modViewModsApplyRemoving.watch(context),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(),
                  ),
                ),
                Visibility(
                  visible: !modViewModsApplyRemoving.watch(context),
                  child: ModManTooltip(
                    message: curLangText!.uiHoldToRemoveSelectedMods,
                    child: InkWell(
                        onLongPress: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                modViewModsApplyRemoving.value = true;
                                setState(() {});
                                Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () async {
                                  final unappliedList = await unapplySelectedAppliedMods(context);
                                  // .then((value) {

                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, unappliedList.first, unappliedList[1], 3000));
                                  if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                    saveApplyButtonState.value = SaveApplyButtonState.none;
                                  }
                                  modViewModsApplyRemoving.value = false;
                                  setState(() {});
                                });
                                // });
                              },
                        child: Icon(
                          Icons.playlist_remove,
                          color: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                        )),
                  ),
                ),
              ],
            ),
            //Export selected mods
            ModManTooltip(
              message: curLangText!.uiExportSelectedMods,
              child: InkWell(
                  onTap: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedSubmodsInAppliedList.isEmpty
                      ? null
                      : () {
                          selectedSubmodsInAppliedList.removeWhere((element) => !element.applyStatus);
                          modExportHomePage(context, moddedItemsList, selectedSubmodsInAppliedList, true);
                        },
                  child: Icon(
                    Icons.import_export,
                    color: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedSubmodsInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                  )),
            ),
            //Add selected to mod set
            MenuAnchor(
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return ModManTooltip(
                    message: curLangText!.uiAddSelectedModsToModSets,
                    child: InkWell(
                      onTap: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty
                          ? null
                          : () {
                              if (controller.isOpen) {
                                controller.close();
                              } else {
                                controller.open();
                              }
                            },
                      child: Icon(
                        Icons.create_new_folder_outlined,
                        color: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                      ),
                    ),
                  );
                },
                style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                  return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                }), shape: WidgetStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                })),
                menuChildren: modSetsMenuItemButtons(context, selectedModFilesInAppliedList)),
          ]),
          const SizedBox(
            width: 10,
          ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(curLangText!.uiAppliedMods),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 5),
                child: Container(
                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text(
                    context.watch<StateProvider>().profileName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: 30,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 1),
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
            // shrinkWrap: true,
            physics: const SuperRangeMaintainingScrollPhysics(),
            padding: const EdgeInsets.only(right: 2),
            itemCount: moddedItemsList.length,
            itemBuilder: (context, groupIndex) {
              int cateListLength = moddedItemsList[groupIndex].categories.where((e) => e.getNumOfAppliedItems() > 0).length;
              List<Category> cateList = moddedItemsList[groupIndex].categories.where((e) => e.getNumOfAppliedItems() > 0).toList();
              return Visibility(
                visible: moddedItemsList[groupIndex].getNumOfAppliedCates() > 0,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: ExpansionTile(
                    backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                    collapsedBackgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                    // borderRadius: const BorderRadius.all(Radius.circular(2)),
                    shape: Border.all(color: Theme.of(context).primaryColorLight),
                    collapsedShape: Border.all(color: Theme.of(context).primaryColorLight),
                    collapsedTextColor: Theme.of(context).colorScheme.primary,
                    collapsedIconColor: Theme.of(context).colorScheme.primary,
                    childrenPadding: EdgeInsets.zero,
                    title: Text(
                        defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName)
                            ? defaultCategoryTypeNames[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)]
                            : moddedItemsList[groupIndex].groupName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    // subtitle: defaultCategoryTypes.contains(appliedItemList[groupIndex].groupName) && curActiveLang == 'JP'
                    //     ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(appliedItemList[groupIndex].groupName)])
                    //     : null,
                    initiallyExpanded: moddedItemsList[groupIndex].expanded,
                    children: [
                      SuperListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cateListLength,
                        itemBuilder: (context, categoryIndex) {
                          var curCategory = cateList[categoryIndex];
                          int itemListLength = curCategory.items.where((element) => element.applyStatus).length;
                          List<Item> itemList = curCategory.items.where((element) => element.applyStatus).toList();
                          return ExpansionTile(
                              backgroundColor: Colors.transparent,
                              textColor: Theme.of(context).textTheme.bodyMedium!.color,
                              iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                              collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                              collapsedTextColor: Theme.of(context).textTheme.bodyMedium!.color,
                              initiallyExpanded: true,
                              childrenPadding: const EdgeInsets.all(0),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                          defaultCategoryDirs.contains(curCategory.categoryName)
                                              ? defaultCategoryNames[defaultCategoryDirs.indexOf(curCategory.categoryName)]
                                              : curCategory.categoryName,
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                        child: Container(
                                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Theme.of(context).highlightColor),
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                            ),
                                            child: curCategory.items.where((element) => element.applyStatus).length < 2
                                                ? Text('${curCategory.items.where((element) => element.applyStatus).length} ${curLangText!.uiItem}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ))
                                                : Text('${curCategory.items.where((element) => element.applyStatus).length} ${curLangText!.uiItems}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // subtitle: defaultCategoryDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                              //     ? Text(defaultCategoryDirsJP[defaultCategoryDirs.indexOf(curCategory.categoryName)])
                              //     : null,
                              children: [
                                SuperListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: itemListLength,
                                    itemBuilder: (context, itemIndex) {
                                      var curItem = itemList[itemIndex];

                                      return ListenableBuilder(
                                          listenable: curItem,
                                          builder: (BuildContext context, Widget? child) {
                                            List<Mod> curMods = curItem.mods.where((element) => element.applyStatus).toList();
                                            List<List<ModFile>> allAppliedModFiles = [];
                                            List<String> applyingModNames = [];
                                            List<String> allPreviewImages = [];
                                            List<String> allPreviewVideos = [];
                                            int totalModFiles = 0;
                                            int totalAppliedModFiles = 0;
                                            List<SubMod> curSubmods = [];
                                            for (var mod in curMods) {
                                              for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                curSubmods.add(submod);
                                                allAppliedModFiles.add([]);
                                                allAppliedModFiles.last.addAll(submod.modFiles);
                                                applyingModNames.add('${mod.modName} > ${submod.submodName}');
                                                allPreviewImages.addAll(submod.previewImages);
                                                allPreviewVideos.addAll(submod.previewVideos);
                                                totalModFiles += submod.modFiles.length;
                                                totalAppliedModFiles += submod.modFiles.where((element) => element.applyStatus).length;
                                              }
                                            }
                                            return InkResponse(
                                              highlightShape: BoxShape.rectangle,
                                              focusColor: Colors.transparent,
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
                                                if (hovering && previewWindowVisible) {
                                                  previewImages.clear();
                                                  previewModName = curItem.category == defaultCategoryDirs[17]
                                                      ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                          ? curItem.itemName
                                                          : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                      : curItem.itemName.replaceAll('_', '/');
                                                  // hoveringOnSubmod = true;
                                                  for (var mod in curMods) {
                                                    for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                      previewImages = submod.getPreviewWidgets();
                                                    }
                                                  }
                                                } else {
                                                  // hoveringOnSubmod = false;
                                                  previewModName = '';
                                                  previewImages.clear();
                                                }
                                                // setState(() {});
                                              },
                                              child: InfoPopupWidget(
                                                horizontalDirection: 'left',
                                                dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                customContent: () => previewWindowVisible && !showPreviewPanel && previewWindowVisible && previewImages.isNotEmpty && !previewDismiss
                                                    ? PreviewHoverPanel(previewWidgets: previewImages)
                                                    : null,
                                                child: ListTile(
                                                  tileColor: Colors.transparent,
                                                  onTap: () {
                                                    isModViewListHidden = false;
                                                    isModViewFromApplied = true;
                                                    // modViewListVisible = true;
                                                    modViewItem.value = curItem;
                                                    setState(() {});
                                                  },
                                                  iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                  title: Row(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                                                        child: Container(
                                                            width: 80,
                                                            height: 80,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(
                                                                  color: curItem.applyStatus
                                                                      ? Theme.of(context).colorScheme.primary
                                                                      : curItem.mods.where((element) => element.isNew).isNotEmpty
                                                                          ? Colors.amber
                                                                          : Theme.of(context).hintColor,
                                                                  width: curItem.mods.where((element) => element.isNew).isNotEmpty || curItem.applyStatus ? 3 : 1),
                                                            ),
                                                            child: curItem.icons.first.contains('assets/img/placeholdersquare.png')
                                                                ? Image.asset(
                                                                    'assets/img/placeholdersquare.png',
                                                                    filterQuality: FilterQuality.none,
                                                                    fit: BoxFit.fitWidth,
                                                                  )
                                                                : curItem.icons.length > 1
                                                                    ? ItemIconsCarousel(iconPaths: curItem.icons)
                                                                    : Image.file(
                                                                        File(curItem.icons.first),
                                                                        filterQuality: FilterQuality.none,
                                                                        fit: BoxFit.cover,
                                                                      )),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    curItem.category == defaultCategoryDirs[17]
                                                                        ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                                            ? curItem.itemName
                                                                            : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                        : curItem.itemName.replaceAll('_', '/'),
                                                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 5),
                                                                  child: Wrap(
                                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                                    runAlignment: WrapAlignment.center,
                                                                    children: [
                                                                      ModManTooltip(
                                                                          message: uiInTextArg(
                                                                              curLangText!.uiOpenXInFileExplorer,
                                                                              curItem.category == defaultCategoryDirs[17]
                                                                                  ? curItem.itemName.split('_').isNotEmpty &&
                                                                                          curItem.itemName.split('_').first == 'it' &&
                                                                                          curItem.itemName.split('_')[1] == 'wp'
                                                                                      ? curItem.itemName
                                                                                      : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                  : curItem.itemName.replaceAll('_', '/')),
                                                                          child: InkWell(
                                                                            child: const Icon(Icons.folder_open),
                                                                            onTap: () async => await launchUrlString(curItem.location),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            const Divider(
                                                              endIndent: 5,
                                                              height: 5,
                                                              thickness: 1,
                                                            ),
                                                            for (int m = 0; m < applyingModNames.length; m++)
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      applyingModNames[m],
                                                                      //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 5),
                                                                    child: Wrap(
                                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                                      runAlignment: WrapAlignment.center,
                                                                      spacing: 2.5,
                                                                      children: [
                                                                        //checkbox
                                                                        ModManTooltip(
                                                                          message: modFilesInList(selectedModFilesInAppliedList, allAppliedModFiles[m])
                                                                              ? uiInTextArg(curLangText!.uiDeselectX, applyingModNames[m])
                                                                              : uiInTextArg(curLangText!.uiSelectX, applyingModNames[m]),
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              if (modFilesInList(selectedModFilesInAppliedList, allAppliedModFiles[m])) {
                                                                                for (var modFile in allAppliedModFiles[m]) {
                                                                                  selectedModFilesInAppliedList.removeWhere((element) => element.location == modFile.location);
                                                                                  selectedSubmodsInAppliedList.removeWhere((element) => element.location == p.dirname(modFile.location));
                                                                                }
                                                                              } else {
                                                                                selectedModFilesInAppliedList.addAll(allAppliedModFiles[m]);
                                                                                for (var type in moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0)) {
                                                                                  for (var cate in type.categories.where((e) => e.getNumOfAppliedItems() > 0)) {
                                                                                    for (var item in cate.items) {
                                                                                      if (item.applyStatus) {
                                                                                        for (var mod in item.mods) {
                                                                                          if (mod.applyStatus) {
                                                                                            for (var submod in mod.submods) {
                                                                                              if (submod.applyStatus && submod.location == File(allAppliedModFiles[m].first.location).parent.path) {
                                                                                                selectedSubmodsInAppliedList.add(submod);
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                }
                                                                              }
                                                                              setState(() {});
                                                                            },
                                                                            child: Icon(
                                                                              size: 28,
                                                                              color:
                                                                                  modFilesInList(selectedModFilesInAppliedList, allAppliedModFiles[m]) ? Theme.of(context).colorScheme.primary : null,
                                                                              modFilesInList(selectedModFilesInAppliedList, allAppliedModFiles[m])
                                                                                  ? Icons.check_box_outlined
                                                                                  : Icons.check_box_outline_blank_outlined,
                                                                            ),
                                                                          ),
                                                                        ),

                                                                        //apply unapply buttons
                                                                        Stack(
                                                                          children: [
                                                                            Visibility(
                                                                              visible: modViewModsApplyRemoving.watch(context),
                                                                              child: const SizedBox(
                                                                                width: 20,
                                                                                height: 20,
                                                                                child: CircularProgressIndicator(),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                //Unapply
                                                                                Visibility(
                                                                                  visible: !modViewModsApplyRemoving.watch(context) &&
                                                                                      allAppliedModFiles[m].indexWhere((element) => element.applyStatus) != -1,
                                                                                  child: ModManTooltip(
                                                                                    message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, applyingModNames[m]),
                                                                                    child: InkWell(
                                                                                      child: const Icon(
                                                                                        FontAwesomeIcons.squareMinus,
                                                                                      ),
                                                                                      onTap: () async {
                                                                                        modViewModsApplyRemoving.value = true;
                                                                                        setState(() {});
                                                                                        Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () async {
                                                                                          await restoreOriginalFilesToTheGame(context, allAppliedModFiles[m]).then((value) async {
                                                                                            previewImages.clear();
                                                                                            // videoPlayer.remove(0);
                                                                                            for (var mod in curMods) {
                                                                                              for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                                                                if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                                  if (submod.cmxApplied!) {
                                                                                                    bool status = await cmxModRemoval(submod.cmxStartPos!, submod.cmxEndPos!);
                                                                                                    if (status) {
                                                                                                      submod.cmxApplied = false;
                                                                                                      submod.cmxStartPos = -1;
                                                                                                      submod.cmxEndPos = -1;
                                                                                                    }
                                                                                                  }
                                                                                                  if (autoAqmInject && (mod.category == defaultCategoryDirs[1] || mod.category == defaultCategoryDirs[16])) {
                                                                                                    await aqmInjectionRemovalSilent(context, submod);
                                                                                                  }
                                                                                                  submod.setApplyState(false);
                                                                                                  submod.applyDate = DateTime(0);
                                                                                                }
                                                                                                if (submod.applyStatus) {
                                                                                                  previewImages = submod.getPreviewWidgets();
                                                                                                }
                                                                                              }
                                                                                              if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                                mod.setApplyState(false);
                                                                                                mod.applyDate = DateTime(0);
                                                                                              }
                                                                                            }

                                                                                            if (curItem.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              curItem.setApplyState(false);
                                                                                              curItem.applyDate = DateTime(0);
                                                                                              if (curItem.backupIconPath!.isNotEmpty) {
                                                                                                await restoreOverlayedIcon(curItem);
                                                                                              }
                                                                                            }

                                                                                            await filesRestoredMessage(mainPageScaffoldKey.currentContext, allAppliedModFiles[m], value);
                                                                                            if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                              previewModName = '';
                                                                                              previewImages.clear();
                                                                                              // Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                                            }

                                                                                            saveModdedItemListToJson();
                                                                                            modViewModsApplyRemoving.value = false;
                                                                                            // await Future.delayed(const Duration(seconds: 5));
                                                                                            setState(() {
                                                                                              if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                                saveApplyButtonState.value = SaveApplyButtonState.none;
                                                                                              }
                                                                                            });
                                                                                          });
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                //apply
                                                                                Visibility(
                                                                                    visible: !modViewModsApplyRemoving.watch(context) &&
                                                                                        allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.only(left: 2.5),
                                                                                      child: ModManTooltip(
                                                                                        message: uiInTextArg(curLangText!.uiApplyXToTheGame, applyingModNames[m]),
                                                                                        child: InkWell(
                                                                                          onTap: () async {
                                                                                            //apply mod files
                                                                                            if (await originalFilesCheck(context, allAppliedModFiles[m])) {
                                                                                              modViewModsApplyRemoving.value = true;
                                                                                              //local original files backup
                                                                                              //await localOriginalFilesBackup(allAppliedModFiles[m]);

                                                                                              final appliedModFiles = await modFilesApply(context, null, allAppliedModFiles[m]);
                                                                                              // .then((value) async {
                                                                                              if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus) != -1) {
                                                                                                int curModIndex =
                                                                                                    curItem.mods.indexWhere((element) => element.modName == allAppliedModFiles[m].first.modName);
                                                                                                int curSubModIndex = curItem.mods[curModIndex].submods
                                                                                                    .indexWhere((element) => element.submodName == allAppliedModFiles[m].first.submodName);
                                                                                                curItem.mods[curModIndex].submods[curSubModIndex].setApplyState(true);
                                                                                                curItem.mods[curModIndex].submods[curSubModIndex].isNew = false;
                                                                                                curItem.mods[curModIndex].submods[curSubModIndex].applyDate = DateTime.now();
                                                                                                curItem.mods[curModIndex].setApplyState(true);
                                                                                                if (curItem.mods[curModIndex].submods.where((e) => e.isNew).isEmpty) {
                                                                                                  curItem.mods[curModIndex].isNew = false;
                                                                                                }
                                                                                                curItem.mods[curModIndex].applyDate = DateTime.now();
                                                                                                curItem.setApplyState(true);
                                                                                                if (curItem.mods.where((element) => element.isNew).isEmpty) {
                                                                                                  curItem.isNew = false;
                                                                                                }
                                                                                                curItem.applyDate = DateTime.now();
                                                                                                if (autoAqmInject) {
                                                                                                  await aqmInjectionOnModsApply(context, curItem.mods[curModIndex].submods[curSubModIndex]);
                                                                                                }
                                                                                                if (markModdedItem) {
                                                                                                  await applyOverlayedIcon(context, curItem);
                                                                                                  saveSetListToJson();
                                                                                                }
                                                                                                saveApplyButtonState.value = SaveApplyButtonState.extra;
                                                                                                // List<ModFile> appliedModFiles = value;
                                                                                                String fileAppliedText = '';
                                                                                                for (var element in appliedModFiles) {
                                                                                                  if (fileAppliedText.isEmpty) {
                                                                                                    fileAppliedText = uiInTextArg(curLangText!.uiSuccessfullyAppliedX, applyingModNames[m]);
                                                                                                  }
                                                                                                  fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                                }
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                    context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                              }

                                                                                              saveModdedItemListToJson();
                                                                                              modViewModsApplyRemoving.value = false;
                                                                                              // });
                                                                                            }
                                                                                          },
                                                                                          child: const Icon(
                                                                                            FontAwesomeIcons.squarePlus,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    )),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            Wrap(
                                                              spacing: 5,
                                                              children: [
                                                                Text(
                                                                  '$totalAppliedModFiles / $totalModFiles ${curLangText!.uiFilesApplied}',
                                                                  style: TextStyle(color: Theme.of(context).hintColor),
                                                                ),
                                                                if (curMods.where((mod) => mod.submods.where((submod) => submod.hasCmx!).isNotEmpty).isNotEmpty)
                                                                  Container(
                                                                    padding: const EdgeInsets.only(left: 2, right: 2, top: 0, bottom: 1),
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: curMods.where((mod) => mod.submods.where((submod) => submod.cmxApplied!).isNotEmpty).isNotEmpty
                                                                              ? Theme.of(context).colorScheme.primary
                                                                              : Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                    ),
                                                                    child: Text(curLangText!.uiCmx,
                                                                        style: TextStyle(
                                                                          color: curMods.where((mod) => mod.submods.where((submod) => submod.cmxApplied!).isNotEmpty).isNotEmpty
                                                                              ? Theme.of(context).colorScheme.primary
                                                                              : null,
                                                                          fontSize: 15,
                                                                        )),
                                                                  ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    }),
                              ]);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
