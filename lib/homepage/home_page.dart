// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:info_popup/info_popup.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_inject_functions.dart';
import 'package:pso2_mod_manager/aqmInjection/aqm_removal.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_edit.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/csv_ice_file_class.dart';
import 'package:pso2_mod_manager/classes/csv_item_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/classes/sub_mod_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/app_update_dialog.dart';
import 'package:pso2_mod_manager/functions/apply_all_available_mods.dart';
import 'package:pso2_mod_manager/functions/apply_mods_functions.dart';
import 'package:pso2_mod_manager/functions/cate_mover.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/fav_list.dart';
import 'package:pso2_mod_manager/functions/icon_overlay.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/dotnet_check.dart';
import 'package:pso2_mod_manager/functions/mod_deletion_dialog.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/modfiles_contain_in_list_function.dart';
import 'package:pso2_mod_manager/functions/mods_rename_functions.dart';
import 'package:pso2_mod_manager/functions/new_cate_adder.dart';
import 'package:pso2_mod_manager/functions/og_files_perm_checker.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/preview_dialog.dart';
import 'package:pso2_mod_manager/functions/reapply_applied_mods.dart';
import 'package:pso2_mod_manager/functions/restore_functions.dart';
import 'package:pso2_mod_manager/functions/search_list_builder.dart';
import 'package:pso2_mod_manager/functions/show_hide_cates.dart';
import 'package:pso2_mod_manager/functions/unapply_all_mods.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/applied_list.dart';
import 'package:pso2_mod_manager/homepage/item_list.dart';
import 'package:pso2_mod_manager/homepage/modset_list.dart';
import 'package:pso2_mod_manager/homepage/mod_view.dart';
import 'package:pso2_mod_manager/homepage/preview.dart';
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
import 'package:pso2_mod_manager/quickSwapApply/quick_swap_apply_homepage.dart';
import 'package:pso2_mod_manager/quickSwapApply/quick_swap_apply_popup.dart';
import 'package:pso2_mod_manager/sharing/mods_export.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/swapAll/swap_all_apply_popup.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/preview_hover_panel.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

final MultiSplitViewController viewsController = MultiSplitViewController(areas: [Area(weight: 0.285), Area(weight: 0.335)]);
// final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.40)]);
Category? modViewCate;
double headersOpacityValue = 0.7;
TextEditingController searchTextController = TextEditingController();
const int applyButtonsDelay = 10;
const int unapplyButtonsDelay = 10;
bool previewDismiss = false;
String selectedModSetName = '';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double headersExtraOpacityValue = 0.1;
  double modviewPanelWidth = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!firstTimeUser && !Provider.of<StateProvider>(context, listen: false).isUpdateAvailable) {
        updatedVersionCheck(context);
      }
      dotnetVerCheck(context);
      ogFilesPermChecker(context);
      Provider.of<StateProvider>(context, listen: false).startupLoadingFinishSet(true);
      //quick button state
      if (File(modManAppliedModsJsonPath).existsSync()) saveApplyButtonState.value = SaveApplyButtonState.apply;
      //quick apply items
      quickApplyItemList = await quickSwapApplyItemListGet();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //set headers opacity values
    if (context.watch<StateProvider>().uiOpacityValue + headersExtraOpacityValue > 1.0) {
      headersOpacityValue = 1.0;
    } else if (context.watch<StateProvider>().uiOpacityValue == 0) {
      headersExtraOpacityValue = 0.3;
    } else {
      headersOpacityValue = context.watch<StateProvider>().uiOpacityValue + headersExtraOpacityValue;
    }

    MultiSplitView mainViews = MultiSplitView(
      controller: viewsController,
      onWeightChange: () {
        modviewPanelWidth = appWindow.size.width * (viewsController.areas[1].weight! / 1);
        debugPrint(modviewPanelWidth.toString());
      },
      children: [
        if (!context.watch<StateProvider>().setsWindowVisible) const ItemList(),
        if (context.watch<StateProvider>().setsWindowVisible) const ModSetList(),
        //if (!context.watch<StateProvider>().setsWindowVisible)
        const ModView(),
        const AppliedList(),
        //if (context.watch<StateProvider>().setsWindowVisible) modInSetList(),
        // if (!context.watch<StateProvider>().previewWindowVisible || !context.watch<StateProvider>().showPreviewPanel) const AppliedList(),
        // if (context.watch<StateProvider>().previewWindowVisible && context.watch<StateProvider>().showPreviewPanel)
          // MultiSplitView(
          //   axis: Axis.vertical,
          //   controller: _verticalViewsController,
          //   children: const [Preview(), AppliedList()],
          // )
      ],
    );

    MultiSplitViewTheme viewsTheme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerThickness: 2,
            dividerPainter: DividerPainters.dashed(
                //highlightedThickness: 5,
                //thickness: 3,
                //backgroundColor: Theme.of(context).hintColor,
                //size: MediaQuery.of(context).size.height,
                size: 50,
                color: Theme.of(context).hintColor,
                highlightedColor: Theme.of(context).primaryColor)),
        child: mainViews);

    return context.watch<StateProvider>().reloadSplashScreen
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (context.watch<StateProvider>().languageReload)
                  Text(
                    curLangText!.uiLoadingUILanguage,
                    style: const TextStyle(fontSize: 20),
                  ),
                if (listsReloading)
                  Text(
                    curLangText!.uiReloadingMods,
                    style: const TextStyle(fontSize: 20),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const CircularProgressIndicator(),
              ],
            ),
          )
        : context.watch<StateProvider>().reloadProfile
            ? Center(
                child: Text(curLangText!.uiSwitchingProfile, style: const TextStyle(fontSize: 20)),
              )
            : Stack(children: [
                if (showBackgroundImage && context.watch<StateProvider>().backgroundImageTrigger)
                  Image.file(
                    backgroundImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: viewsTheme,
                ),
              ]);
  }
}
