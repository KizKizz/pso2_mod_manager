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
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

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
                                                setState(() {});
                                                Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () {
                                                  //status
                                                  List<ModFile> allAppliedModFiles = [];
                                                  for (var item in curSet.setItems) {
                                                    if (item.applyStatus) {
                                                      for (var mod in item.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                        if (mod.applyStatus) {
                                                          for (var submod in mod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                            if (submod.applyStatus) {
                                                              allAppliedModFiles.addAll(submod.modFiles.where((element) => element.applyStatus));
                                                            }
                                                          }
                                                        }
                                                      }
                                                    }
                                                  }
        
                                                  restoreOriginalFilesToTheGame(context, allAppliedModFiles).then((value) async {
                                                    previewImages.clear();
                                                    // videoPlayer.remove(0);
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
                                                          if (submod.applyStatus) {
                                                            for (var path in submod.previewImages) {
                                                              previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                            }
                                                            for (var path in submod.previewVideos) {
                                                              previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                            }
                                                          }
                                                        }
                                                        if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                          mod.setApplyState(false);
                                                        }
                                                      }
                                                    }
        
                                                    for (var item in curSet.setItems) {
                                                      if (item.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                        item.setApplyState(false);
                                                        if (item.backupIconPath!.isNotEmpty) {
                                                          await restoreOverlayedIcon(item);
                                                        }
                                                      }
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
                                                  //}
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
        
                                  //Apply button in submod
                                  if (curSet.setItems.indexWhere((element) => element.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus == false).isNotEmpty) != -1)
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
                                                setState(() {});
                                                Future.delayed(const Duration(milliseconds: applyButtonsDelay), () async {
                                                  for (var item in curSet.setItems) {
                                                    for (var mod in item.mods) {
                                                      for (var submod in mod.submods) {
                                                        //apply mod files
                                                        if (await originalFilesCheck(context, submod.modFiles)) {
                                                          //apply auto radius removal if on
                                                          if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, submod);
                                                          if (autoAqmInject) await aqmInjectionOnModsApply(context, submod);
        
                                                          await applyModsToTheGame(context, item, mod, submod);
        
                                                          if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                            await applyOverlayedIcon(context, item);
                                                          }
                                                          saveApplyButtonState.value = SaveApplyButtonState.extra;
                                                        }
                                                      }
                                                    }
                                                  }
        
                                                  // List<ModFile> appliedModFiles = value;
                                                  // String fileAppliedText = '';
        
                                                  // for (var element in appliedModFiles.where((e) => e.applyStatus)) {
                                                  //   if (fileAppliedText.isEmpty) {
                                                  //     fileAppliedText = uiInTextArg(curLangText!.uiSuccessfullyAppliedX, curSet.setName);
                                                  //   }
                                                  //   if (!fileAppliedText.contains('${element.itemName} > ${element.modName} > ${element.submodName}\n')) {
                                                  //     fileAppliedText += '${element.itemName} > ${element.modName} > ${element.submodName}\n';
                                                  //   }
                                                  // }
                                                  // ScaffoldMessenger.of(context)
                                                  //     .showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                  // }
                                                  modViewModsApplyRemoving.value = false;
                                                  saveModdedItemListToJson();
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, tempSetName), 3000));
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
                                    List<List<ModFile>> allAppliedModFiles = [];
                                    List<String> applyingModNames = [];
                                    List<String> allPreviewImages = [];
                                    List<String> allPreviewVideos = [];
                                    int totalModFiles = 0;
                                    int totalAppliedModFiles = 0;
                                    List<SubMod> curSubmods = [];
                                    for (var mod in curMods) {
                                      for (var submod in mod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName))) {
                                        // curSubmods.add(submod);
                                        // allAppliedModFiles.add([]);
                                        // allAppliedModFiles.last.addAll(submod.modFiles.where((e) => e.applyStatus));
                                        // applyingModNames.add('${mod.modName} > ${submod.submodName}');
                                        allPreviewImages.addAll(submod.previewImages);
                                        allPreviewVideos.addAll(submod.previewVideos);
                                        totalModFiles += submod.modFiles.length;
                                      }
                                      curSubmods.addAll(mod.submods.where((e) => e.isSet && e.setNames.contains(curSet.setName)));
                                      if (allPreviewImages.isEmpty) allPreviewImages.addAll(mod.previewImages);
                                      if (allPreviewVideos.isEmpty) allPreviewVideos.addAll(mod.previewVideos);
                                    }
                                    for (var mod in curMods) {
                                      for (var submod in mod.submods.where((e) => e.applyStatus)) {
                                        allAppliedModFiles.add([]);
                                        allAppliedModFiles.last.addAll(submod.modFiles.where((e) => e.applyStatus));
                                        applyingModNames.add('${mod.modName} > ${submod.submodName}');
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
                                                            spacing: 5,
                                                            children: [
                                                              //open
                                                              ModManTooltip(
                                                                  message: uiInTextArg(
                                                                      curLangText!.uiOpenXInFileExplorer,
                                                                      curItem.category == defaultCategoryDirs[17]
                                                                          ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                                              ? curItem.itemName
                                                                              : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                          : curItem.itemName.replaceAll('_', '/')),
                                                                  child: InkWell(
                                                                    child: const Icon(Icons.folder_open),
                                                                    onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                  )),
                                                              //remove from set
                                                              ModManTooltip(
                                                                  message: uiInTextArg(
                                                                      curLangText!.uiHoldToRemoveXFromThisSet,
                                                                      curItem.category == defaultCategoryDirs[17]
                                                                          ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                                              ? curItem.itemName
                                                                              : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                          : curItem.itemName.replaceAll('_', '/')),
                                                                  child: InkWell(
                                                                    onLongPress: () async {
                                                                      String tempItemName = curItem.category == defaultCategoryDirs[17]
                                                                          ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp'
                                                                              ? curItem.itemName
                                                                              : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                          : curItem.itemName.replaceAll('_', '/');
                                                                      removeModSetNameFromItems(curSet.setName, [curItem]);
                                                                      // modViewListVisible = false;
                                                                      modViewItem.value = null;
                                                                      curSet.setItems.remove(curItem);
                                                                      saveSetListToJson();
                                                                      saveModdedItemListToJson();
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                          uiInTextArgs(curLangText!.uiSuccessfullyRemovedXFromY, ['<x>', '<y>'], [tempItemName, curSet.setName]), 3000));
                                                                      setState(() {});
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
                                                              spacing: 5,
                                                              children: [
                                                                if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == true) != -1)
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
                                                                          message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, applyingModNames[m]),
                                                                          child: InkWell(
                                                                            child: const Icon(
                                                                              FontAwesomeIcons.squareMinus,
                                                                            ),
                                                                            onTap: () async {
                                                                              modViewModsApplyRemoving.value = true;
                                                                              setState(() {});
                                                                              Future.delayed(const Duration(milliseconds: unapplyButtonsDelay), () async {
                                                                                //status
                                                                                final unappliedList = await restoreOriginalFilesToTheGame(context, allAppliedModFiles[m]);
                                                                                // .then((value) async {
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
                                                                                      if (autoAqmInject) {
                                                                                        await aqmInjectionRemovalSilent(context, submod);
                                                                                      }
                                                                                      submod.setApplyState(false);
                                                                                    }
                                                                                    if (submod.applyStatus) {
                                                                                      for (var path in submod.previewImages) {
                                                                                        previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path)));
                                                                                      }
                                                                                      for (var path in submod.previewVideos) {
                                                                                        previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path)));
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                  if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                    mod.setApplyState(false);
                                                                                  }
                                                                                }
        
                                                                                if (curItem.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                  curItem.setApplyState(false);
                                                                                  if (curItem.backupIconPath!.isNotEmpty) {
                                                                                    await restoreOverlayedIcon(curItem);
                                                                                  }
                                                                                }
        
                                                                                await filesRestoredMessage(mainPageScaffoldKey.currentContext, allAppliedModFiles[m], unappliedList);
                                                                                if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                  previewModName = '';
                                                                                  previewImages.clear();
                                                                                  saveApplyButtonState.value = SaveApplyButtonState.none;
                                                                                }
        
                                                                                modViewModsApplyRemoving.value = false;
                                                                                saveModdedItemListToJson();
                                                                                setState(() {});
                                                                                // });
                                                                                //}
                                                                              });
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                //Apply button in submod
                                                                if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1)
                                                                  ModManTooltip(
                                                                    message: uiInTextArg(curLangText!.uiApplyXToTheGame, applyingModNames[m]),
                                                                    child: InkWell(
                                                                      onTap: () async {
                                                                        //apply mod files
                                                                        if (await originalFilesCheck(context, allAppliedModFiles[m])) {
                                                                          //local original files backup
                                                                          //await localOriginalFilesBackup(allAppliedModFiles[m]);
                                                                          modFilesApply(context, allAppliedModFiles[m]).then((value) async {
                                                                            if (value.indexWhere((element) => element.applyStatus) != -1) {
                                                                              int curModIndex = curItem.mods.indexWhere((element) => element.modName == allAppliedModFiles[m].first.modName);
                                                                              int curSubModIndex =
                                                                                  curItem.mods[curModIndex].submods.indexWhere((element) => element.submodName == allAppliedModFiles[m].first.submodName);
                                                                              curItem.mods[curModIndex].submods[curSubModIndex].setApplyState(true);
                                                                              curItem.mods[curModIndex].submods[curSubModIndex].isNew = false;
                                                                              curItem.mods[curModIndex].submods[curSubModIndex].applyDate = DateTime.now();
                                                                              curItem.mods[curModIndex].setApplyState(true);
                                                                              curItem.mods[curModIndex].isNew = false;
                                                                              curItem.mods[curModIndex].applyDate = DateTime.now();
        
                                                                              curItem.setApplyState(true);
                                                                              if (curItem.mods.where((element) => element.isNew).isEmpty) {
                                                                                curItem.isNew = false;
                                                                              }
                                                                              curItem.applyDate = DateTime.now();
                                                                              if (autoAqmInject) await aqmInjectionOnModsApply(context, curItem.mods[curModIndex].submods[curSubModIndex]);
                                                                              if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                                await applyOverlayedIcon(context, curItem);
                                                                              }
                                                                              List<ModFile> appliedModFiles = value;
                                                                              String fileAppliedText = '';
                                                                              for (var element in appliedModFiles) {
                                                                                if (fileAppliedText.isEmpty) {
                                                                                  fileAppliedText = uiInTextArg(curLangText!.uiSuccessfullyAppliedX, applyingModNames[m]);
                                                                                }
                                                                                fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                              }
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                  snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                              saveApplyButtonState.value = SaveApplyButtonState.extra;
                                                                              setState(() {});
                                                                            }
        
                                                                            saveModdedItemListToJson();
                                                                          });
                                                                        }
                                                                        setState(() {});
                                                                      },
                                                                      child: const Icon(
                                                                        FontAwesomeIcons.squarePlus,
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    Text(
                                                      '$totalAppliedModFiles / $totalModFiles ${curLangText!.uiFilesApplied}',
                                                      //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
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
                })),
      ),
    );
  }
}
