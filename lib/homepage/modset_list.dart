// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_popup/info_popup.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/apply_mods_functions.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/preview_dialog.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
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
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher_string.dart';

class ModSetList extends StatefulWidget {
  const ModSetList({super.key});

  @override
  State<ModSetList> createState() => _ModSetListState();
}

class _ModSetListState extends State<ModSetList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, spacing: 10, children: [
                //Show all hidden
                ModManTooltip(
                  message: curLangText!.uiCreateNewModSet,
                  child: InkWell(
                      onTap: newSetTextController.value.text.isEmpty
                          ? null
                          : () {
                              modSetList.add(ModSet(newSetTextController.value.text, 0, true, false, DateTime.now(), []));
                              modSetList.sort(
                                (a, b) => b.addedDate.compareTo(a.addedDate),
                              );
                              for (var set in modSetList) {
                                set.position = modSetList.indexOf(set);
                              }
                              saveSetListToJson();
                              newSetTextController.clear();
                              setState(() {});
                            },
                      child: Icon(
                        FontAwesomeIcons.circlePlus,
                        size: 18,
                        color: newSetTextController.value.text.isEmpty ? Theme.of(context).disabledColor : null,
                      )),
                ),
              ]),
            )
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                child: Text(curLangText!.uiModSets),
              ),
              //New name
              Expanded(
                  child: TextField(
                controller: newSetTextController,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                    hintText: curLangText!.uiEnterNewModSetName,
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    isCollapsed: true,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                    suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                    suffixIcon: InkWell(
                      onTap: () {
                        newSetTextController.clear();
                        setState(() {});
                      },
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    constraints: BoxConstraints.tight(const Size.fromHeight(26)),
                    // Set border for enabled state (default)
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).hintColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Set border for focused state
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    )),
                onChanged: (value) => setState(() {}),
                onSubmitted: (value) {
                  modSetList.add(ModSet(newSetTextController.value.text, 0, true, false, DateTime.now(), []));
                  modSetList.sort(
                    (a, b) => b.addedDate.compareTo(a.addedDate),
                  );
                  saveSetListToJson();
                  newSetTextController.clear();
                  setState(() {});
                },
              ))
            ],
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
                  padding: const EdgeInsets.only(left: 2),
                  itemCount: modSetList.length,
                  itemBuilder: (context, setIndex) {
                    var curSet = modSetList[setIndex];
                    return ListenableBuilder(
                        listenable: curSet,
                        builder: (BuildContext context, Widget? child) {
                          // int cateListLength = appliedItemList[groupIndex].categories.where((element) => element.items.indexWhere((i) => i.applyStatus == true) != -1).length;
                          // List<Category> cateList = appliedItemList[groupIndex].categories.where((element) => element.items.indexWhere((i) => i.applyStatus == true) != -1).toList();
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (setIndex != 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                //color: Theme.of(context).textTheme.headlineMedium?.color,
                              ),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: ExpansionTile(
                                    backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                    collapsedBackgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                    // borderRadius: const BorderRadius.all(Radius.circular(2)),
                                    shape: Border.all(color: Theme.of(context).primaryColorLight),
                                    collapsedShape: Border.all(color: Theme.of(context).primaryColorLight),
                                    collapsedTextColor: Theme.of(context).colorScheme.primary,
                                    collapsedIconColor: Theme.of(context).colorScheme.primary,
                                    tilePadding: const EdgeInsets.only(left: 10),
                                    title: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Text(curSet.setName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                              child: Container(
                                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Theme.of(context).highlightColor),
                                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: curSet.setItems.length < 2
                                                      ? Text('${curSet.setItems.length} ${curLangText!.uiItem}',
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                          ))
                                                      : Text('${curSet.setItems.length} ${curLangText!.uiItems}',
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                          ))),
                                            ),
                                          ],
                                        ),
                                        Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, spacing: 5, children: [
                                          if (curSet.setItems.indexWhere((element) => element.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus).isNotEmpty) != -1)
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
                                                    message: uiInTextArg(curLangText!.uiRemoveAllModsInXFromTheGame, curSet.setName),
                                                    child: InkWell(
                                                      child: const Icon(
                                                        FontAwesomeIcons.squareMinus,
                                                      ),
                                                      onTap: () async {
                                                        modViewModsApplyRemoving.value = true;
                                                        Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () {
                                                          //status
                                                          List<ModFile> allAppliedModFiles = [];
                                                          for (var item in curSet.setItems.where((e) => e.applyStatus)) {
                                                            for (var submod
                                                                in item.getSubmods().where((element) => element.isSet && element.setNames.contains(curSet.setName) && element.applyStatus)) {
                                                              allAppliedModFiles.addAll(submod.modFiles.where((e) => e.applyStatus && e.isSet && e.setNames.contains(curSet.setName)));
                                                            }
                                                          }

                                                          restoreOriginalFilesToTheGame(context, allAppliedModFiles).then((value) async {
                                                            previewImages.clear();
                                                            for (var item in curSet.setItems) {
                                                              for (var mod in item.mods.where((element) => element.applyStatus && element.isSet && element.setNames.contains(curSet.setName))) {
                                                                for (var submod in mod.submods.where((element) => element.applyStatus && element.isSet && element.setNames.contains(curSet.setName))) {
                                                                  if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                    if (submod.cmxApplied!) {
                                                                      bool status = await cmxModRemoval(submod.cmxStartPos!, submod.cmxEndPos!);
                                                                      if (status) {
                                                                        submod.cmxApplied = false;
                                                                        submod.cmxStartPos = -1;
                                                                        submod.cmxEndPos = -1;
                                                                      }
                                                                    }
                                                                    if (autoAqmInject) {
                                                                      await aqmInjectionRemovalSilent(context, submod);
                                                                    }
                                                                    submod.setApplyState(false);
                                                                  }
                                                                }
                                                                if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                  mod.setApplyState(false);
                                                                }
                                                              }
                                                              if (item.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                item.setApplyState(false);
                                                                if (item.backupIconPath!.isNotEmpty) {
                                                                  await restoreOverlayedIcon(item);
                                                                }
                                                              }
                                                              modViewModsApplyRemoving.value = true;
                                                            }

                                                            await filesRestoredMessage(mainPageScaffoldKey.currentContext, allAppliedModFiles, value);
                                                            if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                              previewModName = '';
                                                              previewImages.clear();
                                                              saveApplyButtonState.value = SaveApplyButtonState.none;
                                                            }
                                                            modViewModsApplyRemoving.value = false;
                                                            saveModdedItemListToJson();
                                                            setState(() {});
                                                          });
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          //Apply button in submod
                                          if (curSet.setItems.indexWhere((element) => element.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus == false).isNotEmpty) !=
                                              -1)
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
                                                    message: uiInTextArg(curLangText!.uiApplyAllModsInXToTheGame, curSet.setName),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        modViewModsApplyRemoving.value = true;
                                                        List<String> appliedModNames = [];
                                                        List<String> appliedSubmodNames = [];
                                                        List<String> appliedModFileNames = [];
                                                        // setState(() {});
                                                        Future.delayed(const Duration(milliseconds: applyButtonsDelay), () async {
                                                          for (var item in curSet.setItems.where((e) => !e.applyStatus)) {
                                                            for (var mod in item.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && !e.applyStatus)) {
                                                              for (var submod in mod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && !e.applyStatus)) {
                                                                // if (!submod.compareModFilesInList(appliedModFileNames) ||
                                                                //     !appliedModNames.contains(mod.modName) ||
                                                                //     !appliedSubmodNames.contains(submod.submodName)) {
                                                                //apply mod files
                                                                if (await originalFilesCheck(context, submod.modFiles)) {
                                                                  //apply auto radius removal if on
                                                                  if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, submod);
                                                                  if (autoAqmInject) await aqmInjectionOnModsApply(context, submod);

                                                                  bool appliedStatus = await applyModsToTheGame(context, item, mod, submod);

                                                                  if (appliedStatus) {
                                                                    if (!appliedModNames.contains(mod.modName)) appliedModNames.add(mod.modName);
                                                                    if (!appliedSubmodNames.contains(submod.submodName)) appliedSubmodNames.add(submod.submodName);
                                                                    appliedModFileNames.addAll(submod.modFiles.map((e) => e.modFileName).where((e) => !appliedModFileNames.contains(e)));
                                                                    saveApplyButtonState.value = SaveApplyButtonState.extra;
                                                                  }
                                                                }
                                                              }
                                                              // }
                                                            }
                                                            modViewModsApplyRemoving.value = true;
                                                          }
                                                          modViewModsApplyRemoving.value = false;
                                                          saveModdedItemListToJson();
                                                          saveSetListToJson();
                                                          setState(() {});

                                                          // });
                                                          //   }
                                                          //   setState(() {});
                                                        });
                                                      },
                                                      child: const Icon(
                                                        FontAwesomeIcons.squarePlus,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                          //Export All
                                          ModManTooltip(
                                            message: curLangText!.uiExportAllMods,
                                            child: InkWell(
                                              onTap: () async {
                                                List<SubMod> submodsToExport = [];
                                                for (var item in curSet.setItems) {
                                                  for (var mod in item.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                    submodsToExport.addAll(mod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName)));
                                                  }
                                                }
                                                await modExportHomePage(context, moddedItemsList, submodsToExport, false);
                                              },
                                              child: const Icon(
                                                Icons.import_export,
                                                size: 26,
                                                //color: curSet.setItems.where((element) => element.applyStatus).isNotEmpty ? Theme.of(context).disabledColor : null,
                                              ),
                                            ),
                                          ),

                                          //Rename
                                          ModManTooltip(
                                            message: curLangText!.uiRenameThisSet,
                                            child: InkWell(
                                              onTap: () async {
                                                await modsetRename(context, curSet);
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                size: 26,
                                                //color: curSet.setItems.where((element) => element.applyStatus).isNotEmpty ? Theme.of(context).disabledColor : null,
                                              ),
                                            ),
                                          ),

                                          //Delete
                                          ModManTooltip(
                                            message: uiInTextArg(curLangText!.uiHoldToRemoveXFromModMan, curSet.setName),
                                            child: InkWell(
                                              onLongPress:
                                                  // curSet.setItems.where((element) => element.applyStatus).isNotEmpty
                                                  //     ? null
                                                  //     :
                                                  () async {
                                                String tempSetName = curSet.setName;
                                                removeModSetNameFromItems(curSet.setName, curSet.setItems);
                                                modSetList.remove(curSet);
                                                // modViewListVisible = false;
                                                modViewItem.value = null;
                                                saveSetListToJson();
                                                saveModdedItemListToJson();
                                                ScaffoldMessenger.of(mainPageScaffoldKey.currentState!.context).showSnackBar(snackBarMessage(mainPageScaffoldKey.currentState!.context,
                                                    '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, tempSetName), 3000));
                                                setState(() {});
                                              },
                                              child: const Icon(
                                                Icons.folder_delete,
                                                size: 26,
                                                //color: curSet.setItems.where((element) => element.applyStatus).isNotEmpty ? Theme.of(context).disabledColor : null,
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                    initiallyExpanded: curSet.expanded,
                                    children: [
                                      SuperListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          // cacheExtent: double.maxFinite,
                                          primary: false,
                                          itemCount: curSet.setItems.length,
                                          itemBuilder: (context, itemIndex) {
                                            var curItem = curSet.setItems[itemIndex];
                                            List<Mod> curMods = curItem.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName)).toList();
                                            // List<List<ModFile>> allAppliedModFiles = [];
                                            List<String> allPreviewImages = [];
                                            List<String> allPreviewVideos = [];
                                            int totalModFiles = 0;
                                            int totalAppliedModFiles = 0;
                                            // List<SubMod> curSubmods = [];
                                            for (var mod in curMods) {
                                              for (var submod in mod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName))) {
                                                allPreviewImages.addAll(submod.previewImages);
                                                allPreviewVideos.addAll(submod.previewVideos);
                                                totalModFiles += submod.modFiles.length;
                                              }
                                              // curSubmods.addAll(mod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName)));
                                              if (allPreviewImages.isEmpty) allPreviewImages.addAll(mod.previewImages);
                                              if (allPreviewVideos.isEmpty) allPreviewVideos.addAll(mod.previewVideos);

                                              for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                                // allAppliedModFiles.add([]);
                                                // allAppliedModFiles.last.addAll(submod.modFiles.where((e) => e.applyStatus));
                                                totalAppliedModFiles += submod.modFiles.where((element) => element.applyStatus).length;
                                              }
                                            }

                                            return InkResponse(
                                              highlightShape: BoxShape.rectangle,
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
                                                  previewModName = curItem.category == defaultCategoryDirs[17]
                                                      ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                          ? curItem.itemName
                                                          : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                      : curItem.itemName.replaceAll('_', '/');

                                                  for (var path in allPreviewImages) {
                                                    previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curItem.itemName).last));
                                                  }

                                                  for (var path in allPreviewVideos) {
                                                    previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curItem.itemName).last));
                                                  }
                                                } else {
                                                  previewModName = '';
                                                  previewImages.clear();
                                                }
                                                // setState(() {});
                                              },
                                              child: InfoPopupWidget(
                                                horizontalDirection: 'right',
                                                dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                customContent: () =>
                                                    previewWindowVisible && !showPreviewPanel && previewImages.isNotEmpty && !previewDismiss ? PreviewHoverPanel(previewWidgets: previewImages) : null,
                                                child: ListTile(
                                                  tileColor: Colors.transparent,
                                                  onTap: () {
                                                    isModViewListHidden = false;
                                                    isModViewFromApplied = false;
                                                    modViewItem.value = curItem;
                                                    // modViewListVisible = true;
                                                    selectedModSetName = curSet.setName;
                                                    // setState(() {});
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
                                                                      : curItem.mods.where((element) => element.isNew && element.isSet && element.setNames.contains(curSet.setName)).isNotEmpty
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
                                                                    spacing: 5,
                                                                    children: [
                                                                      //open
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
                                                                      //remove from set
                                                                      ModManTooltip(
                                                                          message: uiInTextArg(
                                                                              curLangText!.uiHoldToRemoveXFromThisSet,
                                                                              curItem.category == defaultCategoryDirs[17]
                                                                                  ? curItem.itemName.split('_').isNotEmpty &&
                                                                                          curItem.itemName.split('_').first == 'it' &&
                                                                                          curItem.itemName.split('_')[1] == 'wp'
                                                                                      ? curItem.itemName
                                                                                      : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                  : curItem.itemName.replaceAll('_', '/')),
                                                                          child: InkWell(
                                                                            onLongPress: () async {
                                                                              String tempItemName = curItem.category == defaultCategoryDirs[17]
                                                                                  ? curItem.itemName.split('_').isNotEmpty &&
                                                                                          curItem.itemName.split('_').first == 'it' &&
                                                                                          curItem.itemName.split('_')[1] == 'wp'
                                                                                      ? curItem.itemName
                                                                                      : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                  : curItem.itemName.replaceAll('_', '/');
                                                                              await removeModSetNameFromItems(curSet.setName, [curItem]);
                                                                              // modViewListVisible = false;
                                                                              modViewItem.value = null;
                                                                              curSet.removeItem(curItem);
                                                                              saveSetListToJson();
                                                                              saveModdedItemListToJson();
                                                                              ScaffoldMessenger.of(mainPageScaffoldKey.currentState!.context).showSnackBar(snackBarMessage(
                                                                                  mainPageScaffoldKey.currentState!.context,
                                                                                  '${curLangText!.uiSuccess}!',
                                                                                  uiInTextArgs(curLangText!.uiSuccessfullyRemovedXFromY, ['<x>', '<y>'], [tempItemName, curSet.setName]),
                                                                                  3000));
                                                                              // setState(() {});
                                                                            },
                                                                            child: const Icon(Icons.delete_forever_outlined),
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
                                                            for (var curMod in curMods)
                                                              for (var curSubmod in curMod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName)))
                                                                Visibility(
                                                                    visible: curSubmod.applyStatus,
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${curSubmod.modName} > ${curSubmod.submodName}',
                                                                                // style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 5),
                                                                              child: Wrap(
                                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                                runAlignment: WrapAlignment.center,
                                                                                spacing: 5,
                                                                                children: [
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
                                                                                      Wrap(
                                                                                        spacing: 2.5,
                                                                                        children: [
                                                                                          //Unapply
                                                                                          Visibility(
                                                                                            visible: !modViewModsApplyRemoving.watch(context) &&
                                                                                                curSubmod.modFiles
                                                                                                    .where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus)
                                                                                                    .isNotEmpty,
                                                                                            child: ModManTooltip(
                                                                                              message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, '${curSubmod.modName} > ${curSubmod.submodName}'),
                                                                                              child: InkWell(
                                                                                                child: const Icon(
                                                                                                  FontAwesomeIcons.squareMinus,
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  modViewModsApplyRemoving.value = true;
                                                                                                  setState(() {});
                                                                                                  Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () async {
                                                                                                    //status
                                                                                                    await restoreOriginalFilesToTheGame(
                                                                                                            context,
                                                                                                            curSubmod.modFiles
                                                                                                                .where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus)
                                                                                                                .toList())
                                                                                                        .then((value) async {
                                                                                                      if (value.where((e) => !e.applyStatus).isNotEmpty) {
                                                                                                        if (curSubmod.modFiles.where((e) => !e.applyStatus).isNotEmpty) {
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
                                                                                                          curSubmod.setApplyState(false);
                                                                                                          curSubmod.applyDate = DateTime(0);
                                                                                                        }

                                                                                                        if (curMod.submods.where((element) => !element.applyStatus).isNotEmpty) {
                                                                                                          curMod.setApplyState(false);
                                                                                                          curMod.applyDate = DateTime(0);
                                                                                                        }

                                                                                                        if (curItem.mods.where((element) => !element.applyStatus).isNotEmpty) {
                                                                                                          if (curItem.backupIconPath!.isNotEmpty) {
                                                                                                            await restoreOverlayedIcon(curItem);
                                                                                                          }
                                                                                                          curItem.setApplyState(false);
                                                                                                        }

                                                                                                        if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                                          saveApplyButtonState.value = SaveApplyButtonState.none;
                                                                                                        }

                                                                                                        await filesRestoredMessage(
                                                                                                            mainPageScaffoldKey.currentContext,
                                                                                                            curSubmod.modFiles.where((e) => e.isSet && e.setNames.contains(curSet.setName)).toList(),
                                                                                                            value);
                                                                                                      }
                                                                                                      saveModdedItemListToJson();
                                                                                                      modViewModsApplyRemoving.value = false;
                                                                                                      setState(() {});
                                                                                                    });
                                                                                                  });
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          //Apply
                                                                                          Visibility(
                                                                                            visible: !modViewModsApplyRemoving.watch(context) &&
                                                                                                curSubmod.modFiles
                                                                                                    .where((e) => e.isSet && e.setNames.contains(curSet.setName) && !e.applyStatus)
                                                                                                    .isNotEmpty,
                                                                                            child: ModManTooltip(
                                                                                              message: uiInTextArg(curLangText!.uiApplyXToTheGame, '${curSubmod.modName} > ${curSubmod.submodName}'),
                                                                                              child: InkWell(
                                                                                                onTap: () async {
                                                                                                  modViewModsApplyRemoving.value = true;
                                                                                                  //apply mod files
                                                                                                  if (await originalFilesCheck(
                                                                                                      context,
                                                                                                      curSubmod.modFiles
                                                                                                          .where((e) => e.isSet && e.setNames.contains(curSet.setName) && !e.applyStatus)
                                                                                                          .toList())) {
                                                                                                    //local original files backup
                                                                                                    //await localOriginalFilesBackup(allAppliedModFiles[m]);
                                                                                                    modFilesApply(
                                                                                                            context,
                                                                                                            null,
                                                                                                            curSubmod.modFiles
                                                                                                                .where((e) => e.isSet && e.setNames.contains(curSet.setName) && !e.applyStatus)
                                                                                                                .toList())
                                                                                                        .then((value) async {
                                                                                                      if (value.where((element) => element.applyStatus).isNotEmpty) {
                                                                                                        if (curSubmod.modFiles.where((e) => e.applyStatus).isNotEmpty) {
                                                                                                          if (autoAqmInject) await aqmInjectionOnModsApply(context, curSubmod);
                                                                                                          curSubmod.setApplyState(true);
                                                                                                          curSubmod.isNew = false;
                                                                                                          curSubmod.applyDate = DateTime.now();
                                                                                                        }

                                                                                                        if (curMod.submods.where((e) => e.applyStatus).isNotEmpty) {
                                                                                                          curMod.setApplyState(true);
                                                                                                          curMod.isNew = false;
                                                                                                          curMod.applyDate = DateTime.now();
                                                                                                        }

                                                                                                        if (curItem.mods.where((e) => e.applyStatus).isNotEmpty) {
                                                                                                          if (curItem.mods.where((element) => element.isNew).isNotEmpty) {
                                                                                                            curItem.isNew = false;
                                                                                                          }
                                                                                                          if (markModdedItem) {
                                                                                                            await applyOverlayedIcon(context, curItem);
                                                                                                            saveModdedItemListToJson();
                                                                                                          }
                                                                                                          curItem.setApplyState(true);
                                                                                                          curItem.applyDate = DateTime.now();
                                                                                                        }

                                                                                                        List<ModFile> appliedModFiles = value;
                                                                                                        String fileAppliedText = '';
                                                                                                        for (var element in appliedModFiles) {
                                                                                                          if (fileAppliedText.isEmpty) {
                                                                                                            fileAppliedText = uiInTextArg(
                                                                                                                curLangText!.uiSuccessfullyAppliedX, '${curSubmod.modName} > ${curSubmod.submodName}');
                                                                                                          }
                                                                                                          fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                                        }
                                                                                                        ScaffoldMessenger.of(mainPageScaffoldKey.currentState!.context).showSnackBar(snackBarMessage(
                                                                                                            mainPageScaffoldKey.currentState!.context,
                                                                                                            '${curLangText!.uiSuccess}!',
                                                                                                            fileAppliedText.trim(),
                                                                                                            appliedModFiles.length * 1000));
                                                                                                        saveApplyButtonState.value = SaveApplyButtonState.extra;
                                                                                                      }

                                                                                                      saveModdedItemListToJson();
                                                                                                      modViewModsApplyRemoving.value = false;
                                                                                                      setState(() {});
                                                                                                    });
                                                                                                  }
                                                                                                },
                                                                                                child: const Icon(
                                                                                                  FontAwesomeIcons.squarePlus,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                  //Apply button in submod
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
                                                                      ],
                                                                    )),
                                                            Text(
                                                              '$totalAppliedModFiles / $totalModFiles ${curLangText!.uiFilesApplied}',
                                                              style: TextStyle(color: Theme.of(context).hintColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })
                                    ]))
                          ]);
                        });
                  })),
        ));
  }
}
