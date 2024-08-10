// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/apply_mods_functions.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/home_page.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:signals/signals_flutter.dart';

class ApplyRemoveModsButton extends StatefulWidget {
  const ApplyRemoveModsButton({super.key, this.curItem, required this.curMod, required this.curSubmod});

  final Item? curItem;
  final Mod curMod;
  final SubMod curSubmod;

  @override
  State<ApplyRemoveModsButton> createState() => _ApplyRemoveModsButtonState();
}

class _ApplyRemoveModsButtonState extends State<ApplyRemoveModsButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: modViewModsApplyRemoving.watch(context),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        ),
        //button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //apply button
            Visibility(
              visible: !modViewModsApplyRemoving.watch(context) && widget.curSubmod.modFiles.indexWhere((element) => !element.applyStatus) != -1,
              child: ModManTooltip(
                message: uiInTextArg(curLangText!.uiApplyXToTheGame, widget.curSubmod.submodName),
                child: InkWell(
                  onTap: () async {
                    modViewModsApplyRemoving.value = true;
                    // setState(() {});
                    Future.delayed(const Duration(milliseconds: applyButtonsDelay), () async {
                      //apply mod files
                      if (await originalFilesCheck(context, widget.curSubmod.modFiles)) {
                        //apply auto radius removal if on
                        if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, widget.curSubmod);
                        if (autoAqmInject) await aqmInjectionOnModsApply(context, widget.curSubmod);

                        await applyModsToTheGame(context, widget.curItem!, widget.curMod, widget.curSubmod);

                        saveApplyButtonState.value = SaveApplyButtonState.extra;
                      }
                      // setState(() {});
                    });
                  },
                  child: const Icon(
                    FontAwesomeIcons.squarePlus,
                  ),
                ),
              ),
            ),
            //unapply button
            Visibility(
              visible: !modViewModsApplyRemoving.watch(context) && widget.curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1,
              child: Padding(
                padding: const EdgeInsets.only(left: 2.5),
                child: ModManTooltip(
                  message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, widget.curSubmod.submodName),
                  child: InkWell(
                    child: const Icon(
                      FontAwesomeIcons.squareMinus,
                    ),
                    onTap: () async {
                      modViewModsApplyRemoving.value = true;
                      // setState(() {});
                
                      Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                        //status
                        restoreOriginalFilesToTheGame(context, widget.curSubmod.modFiles).then((value) async {
                          if (widget.curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                            widget.curSubmod.setApplyState(false);
                            if (widget.curSubmod.cmxApplied!) {
                              bool status = await cmxModRemoval(widget.curSubmod.cmxStartPos!, widget.curSubmod.cmxEndPos!);
                              if (status) {
                                widget.curSubmod.cmxApplied = false;
                                widget.curSubmod.cmxStartPos = -1;
                                widget.curSubmod.cmxEndPos = -1;
                              }
                            }
                            if (autoAqmInject) {
                              await aqmInjectionRemovalSilent(context, widget.curSubmod);
                            }
                          }
                          if (widget.curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                            widget.curMod.setApplyState(false);
                          }
                          if (widget.curItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                            widget.curItem!.setApplyState(false);
                            if (widget.curItem!.backupIconPath!.isNotEmpty) {
                              await restoreOverlayedIcon(widget.curItem!);
                            }
                          }
                
                          await filesRestoredMessage(mainPageScaffoldKey.currentContext, widget.curSubmod.modFiles, value);
                          modViewModsApplyRemoving.value = false;
                          if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                            saveApplyButtonState.value = SaveApplyButtonState.none;
                          }
                          saveModdedItemListToJson();
                          // setState(() {});
                        });
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}