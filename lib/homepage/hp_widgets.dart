// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
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
import 'package:pso2_mod_manager/homepage/mod_view.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/pages/main_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';

class ApplyModsButton extends StatefulWidget {
  const ApplyModsButton({super.key, required this.curItem, required this.curMod, required this.curSubmod});

  final Item? curItem;
  final Mod curMod;
  final SubMod curSubmod;

  @override
  State<ApplyModsButton> createState() => _ApplyModsButtonState();
}

class _ApplyModsButtonState extends State<ApplyModsButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: isModViewModsApplying,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        ),
        Visibility(
          visible: !isModViewModsApplying,
          child: ModManTooltip(
            message: uiInTextArg(curLangText!.uiApplyXToTheGame, widget.curSubmod.submodName),
            child: InkWell(
              onTap: () async {
                isModViewModsApplying = true;
                setState(() {});
                Future.delayed(const Duration(milliseconds: applyButtonsDelay), () async {
                  //apply mod files
                  if (await originalFilesCheck(context, widget.curSubmod.modFiles)) {
                    //apply auto radius removal if on
                    if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, widget.curSubmod);
                    if (autoAqmInject) await aqmInjectionOnModsApply(context, widget.curSubmod);

                    await applyModsToTheGame(context, widget.curItem!, widget.curMod, widget.curSubmod);

                    if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                      await applyOverlayedIcon(context, modViewItem.value!);
                    }
                    Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                  }
                  setState(() {});
                });
              },
              child: const Icon(
                FontAwesomeIcons.squarePlus,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UnApplyModsButton extends StatefulWidget {
  const UnApplyModsButton({super.key, required this.curItem, required this.curMod, required this.curSubmod});

  final Item? curItem;
  final Mod curMod;
  final SubMod curSubmod;

  @override
  State<UnApplyModsButton> createState() => _UnApplyModsButtonState();
}

class _UnApplyModsButtonState extends State<UnApplyModsButton> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: isModViewModsRemoving,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        ),
        Visibility(
          visible: !isModViewModsRemoving,
          child: ModManTooltip(
            message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, widget.curSubmod.submodName),
            child: InkWell(
              child: const Icon(
                FontAwesomeIcons.squareMinus,
              ),
              onTap: () async {
                isModViewModsRemoving = true;
                setState(() {});

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
                    isModViewModsRemoving = false;
                    if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                      Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                    }
                    saveModdedItemListToJson();
                    setState(() {});
                  });
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
