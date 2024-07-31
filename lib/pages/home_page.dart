// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:io';

import 'package:advance_expansion_tile/advance_expansion_tile.dart';
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
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
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
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool hoveringOnSubmod = false;
bool hoveringOnModFile = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.285), Area(weight: 0.335)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.40)]);
  List<GlobalKey<AdvanceExpansionTileState>> modViewETKeys = [];

  Category? modViewCate;
  double headersOpacityValue = 0.7;
  double headersExtraOpacityValue = 0.3;
  List<bool> cateTypeButtonsVisible = [];
  List<List<List<bool>>> itemButtonsVisible = [];
  List<List<List<bool>>> itemClicked = [];
  bool isApplyingModFiles = false;
  bool isCateTypeReordering = false;
  bool isCateTypeAscenAlpha = false;
  List<bool> isCatesReordering = [];
  List<bool> isCateTypeListExpanded = [];
  List<bool> isCatesAscenAlpha = [];
  List<bool> isModViewItemListExpanded = [];
  bool isShowHideCates = false;
  List<List<bool>> cateButtonsVisible = [];
  bool isFavListVisible = false;
  TextEditingController searchTextController = TextEditingController();
  // List<CategoryType> searchedItemList = [];
  List<String> searchResultCateTypes = [];
  TextEditingController newSetTextController = TextEditingController();
  String selectedModSetName = '';
  final int applyButtonsDelay = 10;
  final int unapplyButtonsDelay = 0;
  double modviewPanelWidth = 0;
  List<FocusNode> expansionListFNodes = [];
  bool _previewDismiss = false;
  ItemListSort _itemListSortState = ItemListSort.none;
  ModViewListSort _modViewListSortState = ModViewListSort.none;

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
      if (File(modManAppliedModsJsonPath).existsSync()) Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('apply');
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
      controller: _viewsController,
      onWeightChange: () {
        modviewPanelWidth = appWindow.size.width * (_viewsController.areas[1].weight! / 1);
        debugPrint(modviewPanelWidth.toString());
      },
      children: [
        if (!context.watch<StateProvider>().setsWindowVisible) itemsView(),
        if (context.watch<StateProvider>().setsWindowVisible) setList(),
        //if (!context.watch<StateProvider>().setsWindowVisible)
        modsView(),
        //if (context.watch<StateProvider>().setsWindowVisible) modInSetList(),
        if (!context.watch<StateProvider>().previewWindowVisible || !context.watch<StateProvider>().showPreviewPanel) appliedModsView(),
        if (context.watch<StateProvider>().previewWindowVisible && context.watch<StateProvider>().showPreviewPanel)
          MultiSplitView(
            axis: Axis.vertical,
            controller: _verticalViewsController,
            children: [modPreviewView(), appliedModsView()],
          )
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

//ITEM LIST=====================================================================================================================================================================================
  Widget itemsView() {
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            //Show all hidden
            Visibility(
              visible: !isFavListVisible && !isCateTypeReordering && !isShowHideCates && searchTextController.value.text.isEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ModManTooltip(
                  message: curLangText!.uiHoldToApplyAllAvailableModsToTheGame,
                  child: InkWell(
                      onLongPress: () async {
                        isApplyAllApplied = false;
                        await applyAllAvailableModsDialog(context);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.add_to_queue_outlined,
                        size: 19,
                      )),
                ),
              ),
            ),
            Visibility(
              visible: !isCateTypeReordering && !isShowHideCates && searchTextController.value.text.isEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ModManTooltip(
                  message: isFavListVisible ? curLangText!.uiBack : curLangText!.uiShowFavList,
                  child: InkWell(
                      onTap: () {
                        if (isFavListVisible) {
                          isFavListVisible = false;
                        } else {
                          isFavListVisible = true;
                        }
                        modViewItem = null;
                        setState(() {});
                      },
                      child: Icon(
                        isFavListVisible ? Icons.arrow_back_ios_new : FontAwesomeIcons.heart,
                        size: 18,
                      )),
                ),
              ),
            ),

            //====================================================
            if (!isCateTypeReordering && isShowHideCates)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: 10,
                children: [
                  //Show all hidden
                  ModManTooltip(
                    message: curLangText!.uiUnhideAllCate,
                    child: InkWell(
                        onTap: hiddenItemCategories.isEmpty
                            ? null
                            : () async {
                                for (var cateType in hiddenItemCategories) {
                                  for (var cate in cateType.categories) {
                                    showAllHiddenCategory(hiddenItemCategories, cateType, cate);
                                  }
                                }
                                hiddenItemCategories.clear();
                                saveModdedItemListToJson();
                                setState(() {});
                              },
                        child: Icon(
                          FontAwesomeIcons.solidEye,
                          size: 18,
                          color: hiddenItemCategories.isEmpty ? Theme.of(context).disabledColor : null,
                        )),
                  ),
                  //Hide empty cates button
                  ModManTooltip(
                    message: isEmptyCatesHide ? curLangText!.uiTurnOffAutoHideEmptyCate : curLangText!.uiTurnOnAutoHideEmptyCate,
                    child: InkWell(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          if (isEmptyCatesHide) {
                            isEmptyCatesHide = false;
                            prefs.setBool('isShowHideEmptyCategories', false);
                            showAllEmptyCategories(moddedItemsList);
                            hiddenItemCategories = getAllHiddenCategories(moddedItemsList);
                          } else {
                            isEmptyCatesHide = true;
                            prefs.setBool('isShowHideEmptyCategories', true);
                            hiddenItemCategories = await hideAllEmptyCategories(moddedItemsList);
                          }
                          saveModdedItemListToJson();
                          setState(() {});
                        },
                        child: Icon(
                          isEmptyCatesHide ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 18,
                          color: isEmptyCatesHide ? Theme.of(context).colorScheme.primary : null,
                        )),
                  ),
                ],
              ),
            //Show/Hide button
            if (!isCateTypeReordering && !isFavListVisible && isShowHideCates)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ModManTooltip(
                  message: curLangText!.uiBack,
                  child: InkWell(
                      onTap: isCatesReordering.indexWhere((element) => element) != -1
                          ? null
                          : () {
                              if (isShowHideCates) {
                                isShowHideCates = false;
                              }
                              setState(() {});
                            },
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: isCatesReordering.indexWhere((element) => element) != -1 ? Theme.of(context).disabledColor : null,
                      )),
                ),
              ),

            ///=====================================
            if (!isShowHideCates)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: 5,
                  children: [
                    //Sort by alpha
                    if (isCateTypeReordering)
                      ModManTooltip(
                        message: isCateTypeAscenAlpha ? curLangText!.uiSortByNameDescen : curLangText!.uiSortByNameAscen,
                        child: InkWell(
                            onTap: () {
                              if (isCateTypeAscenAlpha) {
                                //sort cates in catetype
                                moddedItemsList.sort(((a, b) => b.groupName.compareTo(a.groupName)));
                                isCateTypeAscenAlpha = false;
                              } else {
                                //sort cates in catetype
                                moddedItemsList.sort(((a, b) => a.groupName.compareTo(b.groupName)));
                                isCateTypeAscenAlpha = true;
                              }
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.sort_by_alpha_outlined,
                            )),
                      ),
                    //Sort Back button
                    Visibility(
                      visible: isCateTypeReordering,
                      child: ModManTooltip(
                        message: curLangText!.uiBack,
                        child: InkWell(
                            onTap: !isCateTypeReordering
                                ? null
                                : () async {
                                    if (isCateTypeReordering) {
                                      int pos = 0;
                                      for (var type in moddedItemsList) {
                                        type.position = pos;
                                        pos++;
                                      }
                                      //Save to json
                                      saveModdedItemListToJson();
                                      isCateTypeReordering = false;
                                    }
                                    setState(() {});
                                  },
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: isCatesReordering.indexWhere((element) => element) != -1 ? Theme.of(context).disabledColor : null,
                            )),
                      ),
                    ),
                  ],
                ),
              ),

            //Buttons Menu
            Visibility(
                visible: !isFavListVisible && !isCateTypeReordering && !isShowHideCates && searchTextController.value.text.isEmpty,
                child: MenuAnchor(
                    builder: (BuildContext context, MenuController controller, Widget? child) {
                      return ModManTooltip(
                        message: curLangText!.uiMore,
                        child: InkWell(
                          child: const Icon(
                            Icons.more_vert,
                          ),
                          onHover: (value) {
                            if (value) {
                              _previewDismiss = true;
                            } else {
                              _previewDismiss = false;
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
                    style: MenuStyle(backgroundColor: WidgetStateProperty.resolveWith((states) {
                      return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                    }), shape: WidgetStateProperty.resolveWith((states) {
                      return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                    })),
                    menuChildren: [
                      // add new cate group
                      MenuItemButton(
                        leadingIcon: const Icon(
                          Icons.add_to_photos_outlined,
                        ),
                        child: Text(curLangText!.uiAddNewCateGroup),
                        onPressed: () async {
                          String newCateTypeName = await categoryGroupAdder(context);
                          if (newCateTypeName.isNotEmpty) {
                            moddedItemsList.insert(0, CategoryType(newCateTypeName, 0, true, true, []));
                            for (var cateType in moddedItemsList) {
                              cateType.position = moddedItemsList.indexOf(cateType);
                            }
                            saveModdedItemListToJson();
                            setState(() {});
                          }
                        },
                      ),
                      // sort item list
                      MenuItemButton(
                        leadingIcon: const Icon(
                          Icons.sort_outlined,
                        ),
                        child: Text(curLangText!.uiSortItemList),
                        onPressed: () async {
                          isCateTypeReordering = true;
                          setState(() {});
                        },
                      ),
                      // show/hide cate
                      MenuItemButton(
                        leadingIcon: const Icon(
                          Icons.highlight_alt_rounded,
                        ),
                        child: Text(curLangText!.uiShowHideCate),
                        onPressed: () async {
                          isShowHideCates = true;
                          setState(() {});
                        },
                      ),
                    ]))
          ],
          //Title
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                child: Text(isFavListVisible
                    ? curLangText!.uiFavItemList
                    : isShowHideCates
                        ? curLangText!.uiHiddenItemList
                        : isCateTypeReordering
                            ? curLangText!.uiSortItemList
                            : curLangText!.uiItemList),
              ),
              //Search
              Visibility(
                visible: !isCateTypeReordering && !isShowHideCates && !isFavListVisible,
                child: Expanded(
                    child: TextField(
                  controller: searchTextController,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                      hintText: curLangText!.uiSearchForMods,
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      isCollapsed: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                      suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                      suffixIcon: InkWell(
                        onTap: searchTextController.text.isEmpty
                            ? null
                            : () {
                                searchTextController.clear();
                                // searchedItemList.clear();
                                searchResultCateTypes.clear();
                                modViewItem = null;
                                setState(() {});
                              },
                        child: Icon(
                          searchTextController.text.isEmpty ? Icons.search : Icons.close,
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
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      // searchedItemList = await searchListBuilder(moddedItemsList, value);
                      searchResultCateTypes = searchResultCateTypesGet(moddedItemsList, value);
                      modViewItem = null;
                    } else {
                      // searchedItemList.clear();
                      searchResultCateTypes.clear();
                      modViewItem = null;
                    }
                    setState(() {});
                  },
                )),
              )
            ],
          ),
          backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          elevation: 0,
        ),
        const Divider(
          height: 1,
          thickness: 1,
        ),

        //Main body
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
          child: isShowHideCates
              //Hidden List
              ? ListView.builder(
                  physics: const ScrollPhysics(),
                  cacheExtent: double.maxFinite,
                  primary: false,
                  padding: const EdgeInsets.only(left: 2),
                  itemCount: hiddenItemCategories.length,
                  itemBuilder: (context, groupIndex) {
                    List<Category> hiddenCateList = hiddenItemCategories[groupIndex].categories.toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Card(
                        margin: EdgeInsets.zero,
                        color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                        child: ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedTextColor: Theme.of(context).colorScheme.primary,
                          collapsedIconColor: Theme.of(context).colorScheme.primary,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  defaultCategoryTypes.contains(hiddenItemCategories[groupIndex].groupName)
                                      ? defaultCategoryTypeNames[defaultCategoryTypes.indexOf(hiddenItemCategories[groupIndex].groupName)]
                                      : hiddenItemCategories[groupIndex].groupName,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              ModManTooltip(
                                message: uiInTextArg(curLangText!.uiUnhideX, hiddenItemCategories[groupIndex].groupName),
                                // message: '${curLangText!.uiUnhide} ${hiddenItemCategories[groupIndex].groupName}',
                                child: InkWell(
                                    onTap: () {
                                      showHiddenType(hiddenItemCategories, hiddenItemCategories[groupIndex]);
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      FontAwesomeIcons.solidEye,
                                      size: 18,
                                    )),
                              ),
                            ],
                          ),
                          // subtitle: defaultCategoryTypes.contains(hiddenItemCategories[groupIndex].groupName) && curActiveLang == 'JP'
                          //     ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(hiddenItemCategories[groupIndex].groupName)])
                          //     : null,
                          initiallyExpanded: true,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              cacheExtent: double.maxFinite,
                              primary: false,
                              itemCount: hiddenCateList.length,
                              itemBuilder: (context, categoryIndex) {
                                var curCategory = hiddenCateList[categoryIndex];
                                return Visibility(
                                  visible: !curCategory.visible,
                                  child: SizedBox(
                                    //height: 63,
                                    child: ListTile(
                                      onTap: () {},
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                                      tileColor: Colors.transparent,
                                      minVerticalPadding: 5,
                                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                      trailing: ModManTooltip(
                                        message: uiInTextArg(curLangText!.uiUnhideX, curCategory.categoryName),
                                        child: InkWell(
                                            onTap: () {
                                              showHiddenCategory(hiddenItemCategories, hiddenItemCategories[groupIndex], curCategory);
                                              setState(() {});
                                            },
                                            child: const Icon(
                                              FontAwesomeIcons.solidEye,
                                              size: 18,
                                            )),
                                      ),
                                      title: Row(
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
                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                ),
                                                child: curCategory.items.length < 2
                                                    ? Text('${hiddenItemCategories[groupIndex].categories[categoryIndex].items.length} ${curLangText!.uiItem}',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ))
                                                    : Text('${curCategory.items.length} ${curLangText!.uiItems}',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ))),
                                          ),
                                        ],
                                      ),
                                      // subtitle: defaultCategoryDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                      //     ? Text(defaultCategoryDirsJP[defaultCategoryDirs.indexOf(curCategory.categoryName)])
                                      //     : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : isCateTypeReordering
                  //Redordering ItemList
                  ? ReorderableListView.builder(
                      padding: const EdgeInsets.only(left: 2, right: 1),
                      physics: const ScrollPhysics(),
                      cacheExtent: double.maxFinite,
                      primary: false,
                      buildDefaultDragHandles: false,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          CategoryType item = moddedItemsList.removeAt(oldIndex);
                          item.position = newIndex;
                          moddedItemsList.insert(newIndex, item);
                        });
                      },
                      itemCount: moddedItemsList.length,
                      itemBuilder: (context, groupIndex) {
                        return ReorderableDragStartListener(
                          key: Key('$groupIndex'),
                          index: groupIndex,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  shape: BoxShape.rectangle,
                                  border: Border.all(color: Theme.of(context).primaryColorLight)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                                onTap: () {},
                                title: Text(
                                    defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName)
                                        ? defaultCategoryTypeNames[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)]
                                        : moddedItemsList[groupIndex].groupName,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                // subtitle: defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                //     ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)])
                                //     : null,
                                trailing: const Icon(Icons.drag_handle_outlined),
                              ),
                            ),
                          ),
                        );
                      })
                  // ==========================================================================================
                  //Normal Catetype List
                  : ListView.builder(
                      physics: const ScrollPhysics(),
                      padding: const EdgeInsets.only(left: 2),
                      cacheExtent: double.maxFinite,
                      primary: false,
                      itemCount: moddedItemsList.length,
                      itemBuilder: (context, groupIndex) {
                        if (cateTypeButtonsVisible.isEmpty || cateTypeButtonsVisible.length != moddedItemsList.length) {
                          cateTypeButtonsVisible = List.generate(moddedItemsList.length, (index) => false);
                        }
                        if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != moddedItemsList.length) {
                          itemButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
                        }
                        if (itemClicked.isEmpty || itemClicked.length != moddedItemsList.length) {
                          itemClicked = List.generate(moddedItemsList.length, (index) => []);
                        }
                        if (cateButtonsVisible.isEmpty || cateButtonsVisible.length != moddedItemsList.length) {
                          cateButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
                        }
                        if (isCatesReordering.isEmpty || isCatesReordering.length != moddedItemsList.length) {
                          isCatesReordering = List.generate(moddedItemsList.length, (index) => false);
                        }
                        if (isCateTypeListExpanded.isEmpty || isCateTypeListExpanded.length != moddedItemsList.length) {
                          isCateTypeListExpanded = List.generate(moddedItemsList.length, (index) => true);
                        }
                        if (isCatesAscenAlpha.isEmpty || isCatesAscenAlpha.length != moddedItemsList.length) {
                          isCatesAscenAlpha = List.generate(moddedItemsList.length, (index) => false);
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (groupIndex != 0)
                              const Divider(
                                height: 1,
                                thickness: 1,
                              ),
                            //catetype card
                            Visibility(
                              visible: isFavListVisible
                                  ? moddedItemsList[groupIndex].categories.where((g) => g.items.where((i) => i.isFavorite).isNotEmpty).isNotEmpty
                                  : searchTextController.value.text.isNotEmpty
                                      ? searchResultCateTypes.contains(moddedItemsList[groupIndex].groupName)
                                      : moddedItemsList[groupIndex].visible,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                  child: InkWell(
                                    hoverColor: Colors.transparent,
                                    onTap: () {},
                                    onHover: (value) {
                                      if (value) {
                                        cateTypeButtonsVisible[groupIndex] = true;
                                      } else {
                                        cateTypeButtonsVisible[groupIndex] = false;
                                      }
                                      setState(() {});
                                    },
                                    child: ExpansionTile(
                                      backgroundColor: Colors.transparent,
                                      collapsedTextColor: Theme.of(context).colorScheme.primary,
                                      collapsedIconColor: Theme.of(context).colorScheme.primary,
                                      onExpansionChanged: (value) {
                                        isCateTypeListExpanded[groupIndex] = value;
                                        setState(() {});
                                      },
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName)
                                                  ? defaultCategoryTypeNames[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)]
                                                  : moddedItemsList[groupIndex].groupName,
                                              style: const TextStyle(fontWeight: FontWeight.w600)),
                                          Visibility(
                                            visible: cateTypeButtonsVisible[groupIndex],
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                runAlignment: WrapAlignment.center,
                                                spacing: 5,
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        isCateTypeListExpanded[groupIndex] && !isCatesReordering[groupIndex] && !defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName),
                                                    child: ModManTooltip(
                                                      message: uiInTextArg(curLangText!.uiHoldToRemoveXFromModMan, moddedItemsList[groupIndex].groupName),
                                                      // message: '${curLangText!.uiHoldToDelete} ${moddedItemsList[groupIndex].groupName} ${curLangText!.uiFromMM}',
                                                      child: InkWell(
                                                          child: const Icon(Icons.delete_forever_outlined),
                                                          onLongPress: () async {
                                                            if (moddedItemsList[groupIndex].categories.isEmpty) {
                                                              modViewItem = null;
                                                              moddedItemsList.remove(moddedItemsList[groupIndex]);
                                                            } else {
                                                              await categoryGroupRemover(context, moddedItemsList[groupIndex]);
                                                            }
                                                            saveModdedItemListToJson();
                                                            setState(() {});
                                                          }),
                                                    ),
                                                  ),
                                                  //Sort by alpha
                                                  if (isCatesReordering[groupIndex])
                                                    ModManTooltip(
                                                      message: isCatesAscenAlpha[groupIndex] ? curLangText!.uiSortByNameDescen : curLangText!.uiSortByNameAscen,
                                                      child: InkWell(
                                                          onTap: () {
                                                            if (isCatesAscenAlpha[groupIndex]) {
                                                              //sort cates in catetype
                                                              moddedItemsList[groupIndex].categories.sort(((a, b) => b.categoryName.compareTo(a.categoryName)));
                                                              isCatesAscenAlpha[groupIndex] = false;
                                                            } else {
                                                              //sort cates in catetype
                                                              moddedItemsList[groupIndex].categories.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
                                                              isCatesAscenAlpha[groupIndex] = true;
                                                            }
                                                            setState(() {});
                                                          },
                                                          child: const Icon(
                                                            Icons.sort_by_alpha_outlined,
                                                          )),
                                                    ),
                                                  if (isCateTypeListExpanded[groupIndex] && !isCatesReordering[groupIndex])
                                                    ModManTooltip(
                                                      message: curLangText!.uiSortCateInThisGroup,
                                                      child: InkWell(
                                                          child: const Icon(Icons.sort_outlined),
                                                          onTap: () {
                                                            isCatesReordering[groupIndex] = true;
                                                            setState(() {});
                                                          }),
                                                    ),
                                                  //Add new cate to group
                                                  Visibility(
                                                    visible: isCateTypeListExpanded[groupIndex] && !isCatesReordering[groupIndex],
                                                    child: ModManTooltip(
                                                      message: uiInTextArg(curLangText!.uiAddNewCateToXGroup, moddedItemsList[groupIndex].groupName),
                                                      child: InkWell(
                                                          onTap: () async {
                                                            String newCategoryName = await categoryAdder(context);
                                                            if (newCategoryName.isNotEmpty) {
                                                              Directory(Uri.file('$modManModsDirPath/$newCategoryName').toFilePath()).createSync();
                                                              moddedItemsList[groupIndex].categories.insert(
                                                                  0,
                                                                  Category(newCategoryName, moddedItemsList[groupIndex].groupName, Uri.file('$modManModsDirPath/$newCategoryName').toFilePath(), 0,
                                                                      true, []));
                                                              for (var cate in moddedItemsList[groupIndex].categories) {
                                                                cate.position = moddedItemsList[groupIndex].categories.indexOf(cate);
                                                              }
                                                              saveModdedItemListToJson();
                                                              setState(() {});
                                                            }
                                                          },
                                                          child: const Icon(
                                                            Icons.add_circle_outline,
                                                            size: 20,
                                                          )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      // subtitle: defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                      //     ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)])
                                      //     : null,
                                      trailing: !isCatesReordering[groupIndex]
                                          ? null
                                          : ModManTooltip(
                                              message: curLangText!.uiBack,
                                              child: InkWell(
                                                  child: const Icon(
                                                    Icons.arrow_back_ios_new,
                                                  ),
                                                  onTap: () async {
                                                    int pos = 0;
                                                    for (var cate in moddedItemsList[groupIndex].categories) {
                                                      cate.position = pos;
                                                      pos++;
                                                    }
                                                    //Save to json
                                                    saveModdedItemListToJson();
                                                    isCatesReordering[groupIndex] = false;

                                                    setState(() {});
                                                  }),
                                            ),
                                      initiallyExpanded: moddedItemsList[groupIndex].expanded,
                                      children: [
                                        //Sort Cate=========================================================
                                        Visibility(
                                          visible: isCatesReordering[groupIndex],
                                          child: ReorderableListView.builder(
                                              shrinkWrap: true,
                                              padding: const EdgeInsets.only(left: 2, right: 1),
                                              physics: const ScrollPhysics(),
                                              cacheExtent: double.maxFinite,
                                              primary: false,
                                              buildDefaultDragHandles: false,
                                              onReorder: (int oldIndex, int newIndex) {
                                                setState(() {
                                                  if (oldIndex < newIndex) {
                                                    newIndex -= 1;
                                                  }
                                                  Category item = moddedItemsList[groupIndex].categories.removeAt(oldIndex);
                                                  item.position = newIndex;
                                                  moddedItemsList[groupIndex].categories.insert(newIndex, item);
                                                });
                                              },
                                              itemCount: moddedItemsList[groupIndex].categories.length,
                                              itemBuilder: (context, categoryIndex) {
                                                var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];
                                                return ReorderableDragStartListener(
                                                  key: Key('$categoryIndex'),
                                                  index: categoryIndex,
                                                  child: SizedBox(
                                                    //height: 63,
                                                    child: ListTile(
                                                      onTap: () {},
                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                                                      tileColor: Colors.transparent,
                                                      minVerticalPadding: 5,
                                                      textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                                      trailing: const Icon(Icons.drag_handle_outlined),
                                                      title: Row(
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
                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                ),
                                                                child: curCategory.items.length < 2
                                                                    ? Text('${curCategory.items.length} ${curLangText!.uiItem}',
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                        ))
                                                                    : Text('${curCategory.items.length} ${curLangText!.uiItems}',
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                        ))),
                                                          ),
                                                        ],
                                                      ),
                                                      // subtitle: defaultCategoryDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                      //     ? Text(defaultCategoryDirsJP[defaultCategoryDirs.indexOf(curCategory.categoryName)])
                                                      //     : null,
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),

                                        //Main Normal Cate=========================================================
                                        Visibility(
                                          visible: !isCatesReordering[groupIndex],
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            // physics: const NeverScrollableScrollPhysics(),
                                            cacheExtent: double.maxFinite,
                                            primary: false,
                                            itemCount: moddedItemsList[groupIndex].categories.length,
                                            itemBuilder: (context, categoryIndex) {
                                              var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];
                                              //sort
                                              if (_itemListSortState != context.watch<StateProvider>().itemListSortState) {
                                                if (context.watch<StateProvider>().itemListSortState == ItemListSort.alphabeticalOrder) {
                                                  _itemListSortState = ItemListSort.alphabeticalOrder;
                                                  itemClicked[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                                } else if (context.watch<StateProvider>().itemListSortState == ItemListSort.recentModsAdded) {
                                                  _itemListSortState = ItemListSort.recentModsAdded;
                                                  itemClicked[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                                }
                                              }
                                              if (itemButtonsVisible[groupIndex].isEmpty || itemButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                itemButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                              }
                                              if (itemClicked[groupIndex].isEmpty || itemClicked[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                itemClicked[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                              }
                                              if (cateButtonsVisible[groupIndex].isEmpty || cateButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                cateButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => false);
                                              }
                                              return Visibility(
                                                visible: isFavListVisible
                                                    ? curCategory.items.where((element) => element.isFavorite).isNotEmpty
                                                    : searchTextController.value.text.isNotEmpty
                                                        ? curCategory.visible &&
                                                            (curCategory.categoryName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) ||
                                                                cateItemSearchMatchesCheck(curCategory, searchTextController.value.text.toLowerCase()) > 0)
                                                        : curCategory.visible,
                                                child: InkResponse(
                                                  highlightShape: BoxShape.rectangle,
                                                  hoverColor: Colors.transparent,
                                                  onTap: () {},
                                                  onHover: (value) {
                                                    if (value) {
                                                      cateButtonsVisible[groupIndex][categoryIndex] = true;
                                                    } else {
                                                      cateButtonsVisible[groupIndex][categoryIndex] = false;
                                                    }
                                                    setState(() {});
                                                  },
                                                  child: ExpansionTile(
                                                      backgroundColor: Colors.transparent,
                                                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                      iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                      collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                      collapsedTextColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                      initiallyExpanded: false,
                                                      childrenPadding: EdgeInsets.zero,
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
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                    ),
                                                                    child: isFavListVisible
                                                                        ? Text(
                                                                            curCategory.items.where((element) => element.isFavorite).length < 2
                                                                                ? '${curCategory.items.where((element) => element.isFavorite).length} ${curLangText!.uiItem} '
                                                                                : '${curCategory.items.where((element) => element.isFavorite).length} ${curLangText!.uiItems}',
                                                                            style: const TextStyle(
                                                                              fontSize: 13,
                                                                            ))
                                                                        : searchTextController.value.text.isNotEmpty
                                                                            ? Text(
                                                                                cateItemSearchMatchesCheck(curCategory, searchTextController.value.text.toLowerCase()) < 2
                                                                                    ? '${cateItemSearchMatchesCheck(curCategory, searchTextController.value.text.toLowerCase())} ${curLangText!.uiItem} '
                                                                                    : '${cateItemSearchMatchesCheck(curCategory, searchTextController.value.text.toLowerCase())} ${curLangText!.uiItems}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 13,
                                                                                ))
                                                                            : Text(
                                                                                curCategory.items.length < 2
                                                                                    ? '${curCategory.items.length} ${curLangText!.uiItem} '
                                                                                    : '${curCategory.items.length} ${curLangText!.uiItems}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 13,
                                                                                ))),
                                                              ),
                                                            ],
                                                          ),
                                                          Visibility(
                                                            visible: cateButtonsVisible[groupIndex][categoryIndex],
                                                            child: Wrap(
                                                              crossAxisAlignment: WrapCrossAlignment.center,
                                                              runAlignment: WrapAlignment.center,
                                                              spacing: 10,
                                                              children: [
                                                                //Move cate
                                                                ModManTooltip(
                                                                  message: curLangText!.uiMoveThisCategoryToAnotherGroup,
                                                                  child: InkWell(
                                                                      onTap: () async {
                                                                        await categoryMover(context, moddedItemsList[groupIndex], curCategory);
                                                                        setState(() {});
                                                                      },
                                                                      child: const Icon(Icons.move_down_rounded)),
                                                                ),
                                                                //Hide cate
                                                                ModManTooltip(
                                                                  message: uiInTextArg(curLangText!.uiHoldToHideXFromItemList, curCategory.categoryName),
                                                                  child: InkWell(
                                                                      onLongPress: () async {
                                                                        hideCategory(moddedItemsList[groupIndex], curCategory);
                                                                        hiddenItemCategories = await hiddenCategoriesGet(moddedItemsList);
                                                                        setState(() {});
                                                                      },
                                                                      child: const Icon(
                                                                        FontAwesomeIcons.solidEyeSlash,
                                                                        size: 16,
                                                                      )),
                                                                ),
                                                                Visibility(
                                                                  visible: !defaultCategoryDirs.contains(curCategory.categoryName),
                                                                  child: ModManTooltip(
                                                                    message: uiInTextArgs(
                                                                        curLangText!.uiHoldToRemoveXfromY, ['<x>', '<y>'], [curCategory.categoryName, moddedItemsList[groupIndex].groupName]),
                                                                    child: InkWell(
                                                                        onLongPress: () async {
                                                                          if (curCategory.items.isEmpty) {
                                                                            Directory(curCategory.location).deleteSync(recursive: true);
                                                                            moddedItemsList[groupIndex].categories.remove(curCategory);
                                                                            for (var cate in moddedItemsList[groupIndex].categories) {
                                                                              cate.position = moddedItemsList[groupIndex].categories.indexOf(cate);
                                                                            }
                                                                            modViewItem = null;
                                                                          } else {
                                                                            await categoryRemover(context, moddedItemsList[groupIndex], curCategory);
                                                                          }
                                                                          saveModdedItemListToJson();
                                                                          setState(() {});
                                                                        },
                                                                        child: const Icon(
                                                                          Icons.delete_sweep_outlined,
                                                                        )),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      // subtitle: defaultCategoryDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                      //     ? Text(defaultCategoryDirsJP[defaultCategoryDirs.indexOf(curCategory.categoryName)])
                                                      //     : null,
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            // physics: const NeverScrollableScrollPhysics(),
                                                            cacheExtent: double.maxFinite,
                                                            primary: false,
                                                            itemCount: curCategory.items.length,
                                                            prototypeItem: const SizedBox(height: 84),
                                                            itemBuilder: (context, itemIndex) {
                                                              var curItem = curCategory.items[itemIndex];
                                                              if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty ||
                                                                  itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                itemButtonsVisible[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                              }
                                                              if (itemClicked[groupIndex][categoryIndex].isEmpty || itemClicked[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                itemClicked[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                              }

                                                              return Visibility(
                                                                visible: isFavListVisible
                                                                    ? curItem.isFavorite
                                                                    : searchTextController.value.text.isNotEmpty
                                                                        ? curItem.itemName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) ||
                                                                            itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase()) > 0
                                                                        : true,
                                                                child: SizedBox(
                                                                  height: 84,
                                                                  child: Container(
                                                                    margin: const EdgeInsets.all(1),
                                                                    color: itemClicked[groupIndex][categoryIndex][itemIndex] ? Theme.of(context).highlightColor.withOpacity(0.2) : Colors.transparent,
                                                                    //shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                                                                    child: InkWell(
                                                                      child: Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(top: 2, bottom: 2, left: 15, right: 10),
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
                                                                                Text(
                                                                                  curItem.category == defaultCategoryDirs[17]
                                                                                      ? curItem.itemName.split('_').isNotEmpty &&
                                                                                              curItem.itemName.split('_').first == 'it' &&
                                                                                              curItem.itemName.split('_')[1] == 'wp'
                                                                                          ? curItem.itemName
                                                                                          : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                      : curItem.itemName.replaceAll('_', '/'),
                                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                ),
                                                                                // Text(
                                                                                //   curItem.variantNames.join(' | '),
                                                                                //   style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                // ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(top: 5),
                                                                                  child: Wrap(
                                                                                    runAlignment: WrapAlignment.center,
                                                                                    alignment: WrapAlignment.center,
                                                                                    spacing: 5,
                                                                                    children: [
                                                                                      Container(
                                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                        ),
                                                                                        child: isFavListVisible
                                                                                            ? Text(
                                                                                                curItem.mods.where((element) => element.isFavorite).length < 2
                                                                                                    ? '${curItem.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMod}'
                                                                                                    : '${curItem.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMods}',
                                                                                                style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                              )
                                                                                            : searchTextController.value.text.isNotEmpty
                                                                                                ? Text(
                                                                                                    itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase()) < 2
                                                                                                        ? '${itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase())} ${curLangText!.uiMod}'
                                                                                                        : '${itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase())} ${curLangText!.uiMods}',
                                                                                                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                  )
                                                                                                : Text(
                                                                                                    curItem.mods.length < 2
                                                                                                        ? '${curItem.mods.length} ${curLangText!.uiMod}'
                                                                                                        : '${curItem.mods.length} ${curLangText!.uiMods}',
                                                                                                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                  ),
                                                                                      ),
                                                                                      Container(
                                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                        ),
                                                                                        child: Text(
                                                                                          '${curItem.mods.where((element) => element.applyStatus == true).length} ${curLangText!.uiApplied}',
                                                                                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Visibility(
                                                                            visible: itemButtonsVisible[groupIndex][categoryIndex][itemIndex],
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(right: 15),
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                children: [
                                                                                  //Buttons
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
                                                                                        onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                      )),
                                                                                  //Delete
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 5),
                                                                                    child: ModManTooltip(
                                                                                      message: uiInTextArg(
                                                                                          curLangText!.uiHoldToRemoveXFromModMan,
                                                                                          curItem.category == defaultCategoryDirs[17]
                                                                                              ? curItem.itemName.split('_').isNotEmpty &&
                                                                                                      curItem.itemName.split('_').first == 'it' &&
                                                                                                      curItem.itemName.split('_')[1] == 'wp'
                                                                                                  ? curItem.itemName
                                                                                                  : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                                                                              : curItem.itemName.replaceAll('_', '/')),
                                                                                      child: InkWell(
                                                                                        onLongPress: curItem.applyStatus
                                                                                            ? null
                                                                                            : () async {
                                                                                                deleteItemFromModMan(curItem.location).then((value) async {
                                                                                                  String removedName =
                                                                                                      '${curCategory.categoryName} > ${curItem.category == defaultCategoryDirs[17] ? curItem.itemName.split('_').isNotEmpty && curItem.itemName.split('_').first == 'it' && curItem.itemName.split('_')[1] == 'wp' ? curItem.itemName : curItem.itemName.replaceFirst('_', '*').replaceAll('_', '/') : curItem.itemName.replaceAll('_', '/')}';
                                                                                                  if (modViewItem == curItem) {
                                                                                                    modViewItem = null;
                                                                                                  }
                                                                                                  curCategory.items.remove(curItem);
                                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                                      uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                                                  saveModdedItemListToJson();
                                                                                                  setState(() {});
                                                                                                });
                                                                                              },
                                                                                        child: Icon(
                                                                                          Icons.delete_forever_outlined,
                                                                                          color: curItem.applyStatus ? Theme.of(context).disabledColor : null,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      onTap: () {
                                                                        itemClicked = List.generate(moddedItemsList.length, (index) => []);
                                                                        itemClicked[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                                                        itemClicked[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                        itemClicked[groupIndex][categoryIndex][itemIndex] = true;
                                                                        for (var element in modViewETKeys) {
                                                                          element.currentState?.collapse();
                                                                        }
                                                                        modViewETKeys.clear();
                                                                        isModViewListHidden = false;
                                                                        isModViewFromApplied = false;
                                                                        modViewCate = curCategory;
                                                                        modViewItem = curItem;
                                                                        setState(() {});
                                                                      },
                                                                      onHover: (value) {
                                                                        setState(() {
                                                                          if (value) {
                                                                            itemButtonsVisible[groupIndex][categoryIndex][itemIndex] = true;
                                                                          } else {
                                                                            itemButtonsVisible[groupIndex][categoryIndex][itemIndex] = false;
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      ]),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
        )),
      ],
    );
  }

//MODVIEW LIST====================================================================================================================================================================================
  Widget modsView() {
    modviewPanelWidth = appWindow.size.width * (_viewsController.areas[1].weight! / 1);
    //normal
    List<String> appBarAppliedModNames = [];
    if (modViewItem != null && !isFavListVisible) {
      for (var mod in modViewItem!.mods.where((element) => element.applyStatus)) {
        for (var sub in mod.submods.where((element) => element.applyStatus)) {
          appBarAppliedModNames.add('${mod.modName} > ${sub.submodName}');
        }
      }
    }
    //fav
    if (modViewItem != null && isFavListVisible && !isModViewFromApplied) {
      for (var mod in modViewItem!.mods.where((element) => element.applyStatus && element.isFavorite)) {
        for (var sub in mod.submods.where((element) => element.applyStatus && element.isFavorite)) {
          appBarAppliedModNames.add('${mod.modName} > ${sub.submodName}');
        }
      }
    }
    //search
    if (modViewItem != null && searchTextController.value.text.isNotEmpty && !isModViewFromApplied) {
      for (var mod in modViewItem!.mods.where((element) => element.applyStatus && modSearchMatchesCheck(element, searchTextController.value.text.toLowerCase()) > 0)) {
        for (var sub in mod.submods.where((element) => element.applyStatus && submodSearchMatchesCheck(element, searchTextController.value.text.toLowerCase()) > 0)) {
          if (!appBarAppliedModNames.contains('${mod.modName} > ${sub.submodName}')) {
            appBarAppliedModNames.add('${mod.modName} > ${sub.submodName}');
          }
        }
      }
      //count all if 0 mod matched
      if (appBarAppliedModNames.isEmpty) {
        for (var mod in modViewItem!.mods.where((element) => element.applyStatus)) {
          for (var sub in mod.submods.where((element) => element.applyStatus)) {
            appBarAppliedModNames.add('${mod.modName} > ${sub.submodName}');
          }
        }
      }
    }
    //set
    if (modViewItem != null && context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied) {
      for (var mod in modViewItem!.mods.where((element) => element.applyStatus && element.isSet && element.setNames.contains(selectedModSetName))) {
        for (var sub in mod.submods.where((element) => element.applyStatus && element.isSet && element.setNames.contains(selectedModSetName))) {
          if (!appBarAppliedModNames.contains('${mod.modName} > ${sub.submodName}')) {
            appBarAppliedModNames.add('${mod.modName} > ${sub.submodName}');
          }
        }
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
          if (isModViewListHidden || modViewItem == null) Container(),
          if (!isModViewListHidden && modViewItem != null)
            Align(
              alignment: Alignment.topCenter,
              child: ModManTooltip(
                message: curLangText!.uiClearAvailableModsView,
                child: InkWell(
                    child: const Icon(
                      Icons.clear,
                    ),
                    onTap: () async {
                      modViewItem = null;
                      setState(() {});
                    }),
              ),
            ),
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!isModViewListHidden && modViewItem != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 2, right: 10),
                  child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                            color: modViewItem!.applyStatus
                                ? Theme.of(context).colorScheme.primary
                                : modViewItem!.isNew
                                    ? Colors.amber
                                    : Theme.of(context).hintColor,
                            width: modViewItem!.isNew || modViewItem!.applyStatus ? 3 : 1),
                      ),
                      child: modViewItem!.icons.first.contains('assets/img/placeholdersquare.png')
                          ? Image.asset(
                              'assets/img/placeholdersquare.png',
                              filterQuality: FilterQuality.none,
                              fit: BoxFit.fitWidth,
                            )
                          : ItemIconsCarousel(iconPaths: modViewItem!.icons)),
                ),
              Expanded(
                child: SizedBox(
                  height: !isModViewListHidden && modViewItem != null ? 84 : 30,
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      // ignore: deprecated_member_use
                      thickness: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return !isModViewListHidden && modViewItem != null ? 5 : 0;
                        }
                        return !isModViewListHidden && modViewItem != null ? 3 : 0;
                      }),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.hovered)) {
                          return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                        }
                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                      }),
                    ),
                    child: SingleChildScrollView(
                      physics: modViewItem == null ? const NeverScrollableScrollPhysics() : null,
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        !isModViewListHidden && modViewItem != null
                            ? Text(modViewItem!.category == defaultCategoryDirs[17]
                                ? modViewItem!.itemName.split('_').isNotEmpty && modViewItem!.itemName.split('_').first == 'it' && modViewItem!.itemName.split('_')[1] == 'wp'
                                    ? modViewItem!.itemName
                                    : modViewItem!.itemName.replaceFirst('_', '*').replaceAll('_', '/')
                                : modViewItem!.itemName.replaceAll('_', '/'))
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(curLangText!.uiAvailableMods),
                              ),
                        if (modViewItem != null)
                          const Divider(
                            endIndent: 5,
                            height: 5,
                            thickness: 1,
                          ),

                        //normal
                        if (modViewItem != null && !isFavListVisible && searchTextController.value.text.isEmpty && !context.watch<StateProvider>().setsWindowVisible)
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: Text(
                                modViewItem!.mods.length < 2 ? '${modViewItem!.mods.length} ${curLangText!.uiMod}' : '${modViewItem!.mods.length} ${curLangText!.uiMods}',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                              ),
                            ),
                            // export
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: MaterialButton(
                                  onPressed: () async {
                                    List<SubMod> submodsToExport = [];
                                    for (var mod in modViewItem!.mods) {
                                      submodsToExport.addAll(mod.submods);
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
                                      child: Row(children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(
                                            Icons.import_export,
                                            size: 18,
                                          ),
                                        ),
                                        Text(curLangText!.uiExportAllMods)
                                      ])),
                                ))
                          ]),
                        //fav
                        if (modViewItem != null && isFavListVisible && searchTextController.value.text.isEmpty && !isModViewFromApplied)
                          Container(
                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(
                              modViewItem!.mods.where((element) => element.isFavorite).length < 2
                                  ? '${modViewItem!.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMod}'
                                  : '${modViewItem!.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMods}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ),
                        //searching
                        if (modViewItem != null && searchTextController.value.text.isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) == 0)
                          Container(
                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(
                              modViewItem!.mods.length < 2 ? '${modViewItem!.mods.length} ${curLangText!.uiMod}' : '${modViewItem!.mods.length} ${curLangText!.uiMods}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ),
                        if (modViewItem != null && searchTextController.value.text.isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) > 0)
                          Container(
                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(
                              itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) < 2
                                  ? '${itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text)} ${curLangText!.uiMod}'
                                  : '${itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text)} ${curLangText!.uiMods}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ),
                        //set
                        if (modViewItem != null && context.watch<StateProvider>().setsWindowVisible && !isFavListVisible && searchTextController.value.text.isEmpty && !isModViewFromApplied)
                          Container(
                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Text(
                              modViewItem!.mods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length < 2
                                  ? '${modViewItem!.mods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} ${curLangText!.uiMod}'
                                  : '${modViewItem!.mods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} ${curLangText!.uiMods}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                          ),

                        //Applied text
                        if (modViewItem != null && appBarAppliedModNames.isNotEmpty)
                          for (int i = 0; i < appBarAppliedModNames.length; i++)
                            Text(
                              '${curLangText!.uiApplied}: ${appBarAppliedModNames[i]}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.primary),
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
        toolbarHeight: !isModViewListHidden && modViewItem != null ? 84 : 30,
        elevation: 0,
      ),
      const Divider(
        height: 1,
        thickness: 1,
      ),
      //Main list
      if (!isModViewListHidden && modViewItem != null)
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
                child: ListView.builder(
                    // shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    primary: true,
                    cacheExtent: double.maxFinite,
                    //padding: const EdgeInsets.symmetric(horizontal: 1),
                    itemCount: modViewItem!.mods.length,
                    itemBuilder: (context, modIndex) {
                      // modViewETKeys.add(GlobalKey());
                      var curMod = modViewItem!.mods[modIndex];
                      if (modViewETKeys.isEmpty || modViewETKeys.length != modViewItem!.mods.length) {
                        modViewETKeys = List.generate(modViewItem!.mods.length, (index) => GlobalKey());
                      }

                      if (isModViewItemListExpanded.isEmpty || isModViewItemListExpanded.length != modViewItem!.mods.length) {
                        isModViewItemListExpanded = List.generate(modViewItem!.mods.length, (index) => false);
                      }

                      if (expansionListFNodes.isEmpty || expansionListFNodes.length != modViewItem!.mods.length) {
                        expansionListFNodes = List.generate(modViewItem!.mods.length, (index) => FocusNode());
                      }

                      //modset
                      int modViewModSetSubModIndex = -1;
                      if (context.watch<StateProvider>().setsWindowVisible && curMod.submods.where((element) => element.isSet).isNotEmpty) {
                        modViewModSetSubModIndex = curMod.submods.indexWhere((e) => e.isSet);
                      }

                      return Visibility(
                        visible: isFavListVisible && !isModViewFromApplied
                            ? curMod.isFavorite
                            : searchTextController.value.text.toLowerCase().isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) > 0
                                ? curMod.modName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) ||
                                    curMod.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).isNotEmpty
                                : searchTextController.value.text.toLowerCase().isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) == 0
                                    ? true
                                    : context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                        ? curMod.isSet && curMod.setNames.contains(selectedModSetName)
                                        : true,
                        child: InkWell(
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
                                previewImages.clear();
                                previewImages.addAll(curMod.submods[modViewModSetSubModIndex].previewImages
                                    .toSet()
                                    .map((path) => PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curMod.itemName).last)));
                                previewImages.addAll(curMod.submods[modViewModSetSubModIndex].previewVideos
                                    .toSet()
                                    .map((path) => PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curMod.itemName).last)));
                              } else {
                                previewModName = curMod.modName;
                                previewImages.clear();
                                for (var element in curMod.submods) {
                                  previewImages.addAll(element.previewImages.toSet().map((path) => PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curMod.itemName).last)));
                                }
                                for (var element in curMod.submods) {
                                  previewImages.addAll(element.previewVideos.toSet().map((path) => PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curMod.itemName).last)));
                                }
                              }
                            } else {
                              previewModName = '';
                              previewImages.clear();
                            }
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: InfoPopupWidget(
                              horizontalDirection: 'right',
                              dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                              popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                              arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                              customContent: () => !hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible && !showPreviewPanel && previewImages.isNotEmpty && !_previewDismiss
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minWidth: appWindow.size.width / 5, minHeight: appWindow.size.height / 5, maxWidth: appWindow.size.width / 3, maxHeight: appWindow.size.height / 3),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        child: FlutterCarousel(
                                          options: CarouselOptions(
                                              autoPlay: previewImages.length > 1,
                                              autoPlayInterval: previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                                                  ? const Duration(seconds: 5)
                                                  : previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                                                      ? const Duration(seconds: 1)
                                                      : const Duration(seconds: 2),
                                              disableCenter: true,
                                              viewportFraction: 1.0,
                                              height: double.infinity,
                                              floatingIndicator: false,
                                              enableInfiniteScroll: true,
                                              indicatorMargin: 4,
                                              slideIndicator: CircularWaveSlideIndicator(
                                                  itemSpacing: 10,
                                                  indicatorRadius: 4,
                                                  currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                                  indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
                                          items: previewImages,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Card(
                                margin: EdgeInsets.zero,
                                color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                //color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(width: curMod.isNew ? 2 : 1, color: curMod.isNew ? Colors.amber : Theme.of(context).primaryColorLight),
                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                //advanced
                                child: ExpansionTile(
                                  backgroundColor: Colors.transparent,
                                  textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                  iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                  collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                  key: modViewETKeys[modIndex],
                                  onExpansionChanged: (value) {
                                    isModViewItemListExpanded[modIndex] = value;
                                    setState(() {});
                                  },
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(curMod.modName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: curMod.applyStatus ? Theme.of(context).colorScheme.primary : null)),
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
                                                                    curMod.submods.where((element) => element.submodName.toLowerCase().contains(searchTextController.value.text.toLowerCase())).length <
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
                                                      _previewDismiss = true;
                                                    } else {
                                                      _previewDismiss = false;
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
                                              return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
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
                                                      if (p.extension(copiedFile.path) == '.mp4' || p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
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
                                                  String newName = await modsRenameDialog(context, modViewItem!.location, curMod.modName);
                                                  if (newName.isNotEmpty) {
                                                    //change paths
                                                    String oldModPath = curMod.location;
                                                    String newModPath = Uri.file('${modViewItem!.location}/$newName').toFilePath();
                                                    if (oldModPath == modViewItem!.location) {
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
                                                  color:
                                                      curMod.applyStatus || curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                          ? Theme.of(context).disabledColor
                                                          : Colors.red,
                                                ),
                                                onPressed:
                                                    curMod.applyStatus || curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                        ? null
                                                        : () async {
                                                            bool deleteConfirm = await modDeletionDialog(context, curMod.modName);
                                                            if (deleteConfirm) {
                                                              if (modViewItem!.mods.length < 2) {
                                                                deleteItemFromModMan(modViewItem!.location).then((value) async {
                                                                  String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                  if (modViewItem!.isSet) {
                                                                    for (var setName in modViewItem!.setNames) {
                                                                      int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                      if (setIndex != -1) {
                                                                        modSetList[setIndex].setItems.remove(modViewItem);
                                                                      }
                                                                    }
                                                                  }
                                                                  modViewCate!.items.remove(modViewItem);
                                                                  modViewItem = null;
                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                      context, '${curLangText!.uiSuccess}!', uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName), 3000));
                                                                  previewModName = '';
                                                                  previewImages.clear();
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                });
                                                              } else {
                                                                deleteModFromModMan(curMod.location, modViewItem!.location).then((value) async {
                                                                  String removedName = '${curMod.modName} > ${curMod.submods.first.submodName}';
                                                                  modViewItem!.mods.remove(curMod);
                                                                  if (modViewItem!.mods.isEmpty) {
                                                                    modViewCate!.items.remove(modViewItem);
                                                                    modViewItem = null;
                                                                  } else {
                                                                    modViewItem!.isNew = modViewItem!.getModsIsNewState();
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
                                              //Add-Remove button
                                              if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                Stack(
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
                                                        message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, curMod.submods.first.submodName),
                                                        child: InkWell(
                                                            child: const Icon(
                                                              FontAwesomeIcons.squareMinus,
                                                            ),
                                                            onTap: () async {
                                                              isModViewModsRemoving = true;
                                                              setState(() {});
                                                              //status
                                                              Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                                                restoreOriginalFilesToTheGame(context, curMod.submods.first.modFiles).then((unappliedModFiles) async {
                                                                  if (curMod.submods.first.cmxApplied!) {
                                                                    bool status = await cmxModRemoval(curMod.submods.first.cmxStartPos!, curMod.submods.first.cmxEndPos!);
                                                                    if (status) {
                                                                      curMod.submods.first.cmxApplied = false;
                                                                      curMod.submods.first.cmxStartPos = -1;
                                                                      curMod.submods.first.cmxEndPos = -1;
                                                                    }
                                                                  }
                                                                  if (autoAqmInject) {
                                                                    await aqmInjectionRemovalSilent(context, curMod.submods.first);
                                                                  }
                                                                  if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                    curMod.submods.first.applyStatus = false;
                                                                  }
                                                                  if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                    curMod.applyStatus = false;
                                                                  }
                                                                  if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                    modViewItem!.applyStatus = false;
                                                                    if (modViewItem!.backupIconPath!.isNotEmpty) {
                                                                      await restoreOverlayedIcon(modViewItem!);
                                                                    }
                                                                  }

                                                                  await filesRestoredMessage(mainPageScaffoldKey.currentContext, curMod.submods.first.modFiles, unappliedModFiles);
                                                                  isModViewModsRemoving = false;
                                                                  if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                    Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                  }
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                });
                                                                //}
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                Stack(
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
                                                        message: uiInTextArg(curLangText!.uiApplyXToTheGame, curMod.submods.first.submodName),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            FontAwesomeIcons.squarePlus,
                                                          ),
                                                          onTap: () async {
                                                            isModViewModsApplying = true;
                                                            setState(() {});
                                                            Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                                              //apply mod files
                                                              if (await originalFilesCheck(context, curMod.submods.first.modFiles)) {
                                                                //local backup
                                                                //await localOriginalFilesBackup(curMod.submods.first.modFiles);
                                                                //apply auto radius removal if on
                                                                if (autoAqmInject) await aqmInjectionOnModsApply(context, curMod.submods.first);
                                                                if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, curMod.submods.first);

                                                                await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods.first);

                                                                if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                  await applyOverlayedIcon(context, modViewItem!);
                                                                }
                                                                Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                                                              }
                                                              setState(() {});
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              //quick apply
                                              Visibility(
                                                visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem!.category),
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
                                                              _previewDismiss = true;
                                                            } else {
                                                              _previewDismiss = false;
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
                                                    menuChildren: quickApplyMenuButtons(context, curMod.submods.first)),
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
                                                            _previewDismiss = true;
                                                          } else {
                                                            _previewDismiss = false;
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
                                                          if (modViewItem!.mods.where((element) => element.isFavorite).isEmpty) {
                                                            modViewItem!.isFavorite = false;
                                                            modViewItem = null;
                                                          }
                                                        } else {
                                                          curMod.submods.first.isFavorite = true;
                                                          curMod.isFavorite = true;
                                                          modViewItem!.isFavorite = true;
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
                                                      menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curMod.submods.first),
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
                                                            if (p.extension(copiedFile.path) == '.jpg' || p.extension(copiedFile.path) == '.png' && !curMod.previewImages.contains(copiedFile.path)) {
                                                              curMod.previewImages.add(copiedFile.path);
                                                            }
                                                            if (p.extension(copiedFile.path) == '.mp4' || p.extension(copiedFile.path) == '.webm' && !curMod.previewVideos.contains(copiedFile.path)) {
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
                                                        String newName = await modsRenameDialog(context, modViewItem!.location, curMod.modName);
                                                        if (newName.isNotEmpty) {
                                                          //change paths
                                                          String oldModPath = curMod.location;
                                                          String newModPath = Uri.file('${modViewItem!.location}/$newName').toFilePath();
                                                          if (oldModPath == modViewItem!.location) {
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
                                                        if (!defaultCategoryDirs.contains(modViewItem!.category)) {
                                                          fromItemCategory = await modsSwapperCategorySelect(context);
                                                        }
                                                        modsSwapperDialog(context, modViewItem!, curMod.submods.first);
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
                                                          removeSubmodFromThisSet(selectedModSetName, modViewItem!, curMod, curMod.submods.first);
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
                                                                if (curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                  deleteItemFromModMan(modViewItem!.location).then((value) async {
                                                                    String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                    if (modViewItem!.isSet) {
                                                                      for (var setName in modViewItem!.setNames) {
                                                                        int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                        if (setIndex != -1) {
                                                                          modSetList[setIndex].setItems.remove(modViewItem);
                                                                        }
                                                                      }
                                                                    }
                                                                    modViewCate!.items.remove(modViewItem);
                                                                    modViewItem = null;
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
                                                                      modViewItem!.mods.remove(curMod);
                                                                    } else {
                                                                      curMod.isNew = curMod.getSubmodsIsNewState();
                                                                    }

                                                                    if (modViewItem!.mods.isEmpty) {
                                                                      modViewCate!.items.remove(modViewItem);
                                                                      modViewItem = null;
                                                                    } else {
                                                                      modViewItem!.isNew = modViewItem!.getModsIsNewState();
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
                                                        color: curMod.submods[modViewModSetSubModIndex].cmxApplied! ? Theme.of(context).colorScheme.primary : Theme.of(context).primaryColorLight),
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
                                                  curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus == true) != -1 &&
                                                  curMod.submods.length == 1)
                                                Stack(
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
                                                        message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, curMod.submods[modViewModSetSubModIndex].submodName),
                                                        child: InkWell(
                                                            child: const Icon(
                                                              FontAwesomeIcons.squareMinus,
                                                            ),
                                                            onTap: () async {
                                                              isModViewModsRemoving = true;
                                                              setState(() {});

                                                              Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                                                //status
                                                                restoreOriginalFilesToTheGame(context, curMod.submods[modViewModSetSubModIndex].modFiles).then((value) async {
                                                                  if (curMod.submods[modViewModSetSubModIndex].cmxApplied!) {
                                                                    bool status =
                                                                        await cmxModRemoval(curMod.submods[modViewModSetSubModIndex].cmxStartPos!, curMod.submods[modViewModSetSubModIndex].cmxEndPos!);
                                                                    if (status) {
                                                                      curMod.submods[modViewModSetSubModIndex].cmxApplied = false;
                                                                      curMod.submods[modViewModSetSubModIndex].cmxStartPos = -1;
                                                                      curMod.submods[modViewModSetSubModIndex].cmxEndPos = -1;
                                                                    }
                                                                  }
                                                                  if (autoAqmInject) {
                                                                    await aqmInjectionRemovalSilent(context, curMod.submods[modViewModSetSubModIndex]);
                                                                  }
                                                                  if (curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                    curMod.submods[modViewModSetSubModIndex].applyStatus = false;
                                                                  }
                                                                  if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                    curMod.applyStatus = false;
                                                                  }
                                                                  if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                    modViewItem!.applyStatus = false;
                                                                    if (modViewItem!.backupIconPath!.isNotEmpty) {
                                                                      await restoreOverlayedIcon(modViewItem!);
                                                                    }
                                                                  }

                                                                  await filesRestoredMessage(mainPageScaffoldKey.currentContext, curMod.submods[modViewModSetSubModIndex].modFiles, value);
                                                                  isModViewModsRemoving = false;
                                                                  if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                    Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                  }
                                                                  saveModdedItemListToJson();
                                                                  setState(() {});
                                                                });
                                                                //}
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              if (modViewModSetSubModIndex != -1 &&
                                                  curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus == false) != -1 &&
                                                  curMod.submods.length == 1)
                                                Stack(
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
                                                        message: uiInTextArg(curLangText!.uiApplyXToTheGame, curMod.submods[modViewModSetSubModIndex].submodName),
                                                        child: InkWell(
                                                          child: const Icon(
                                                            FontAwesomeIcons.squarePlus,
                                                          ),
                                                          onTap: () async {
                                                            isModViewModsApplying = true;
                                                            setState(() {});
                                                            Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                                              //apply mod files
                                                              if (await originalFilesCheck(context, curMod.submods[modViewModSetSubModIndex].modFiles)) {
                                                                //local original files backup
                                                                //await localOriginalFilesBackup(curMod.submods[modViewModSetSubModIndex].modFiles);
                                                                //apply auto radius removal if on
                                                                if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, curMod.submods[modViewModSetSubModIndex]);
                                                                if (autoAqmInject) await aqmInjectionOnModsApply(context, curMod.submods[modViewModSetSubModIndex]);

                                                                await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]);

                                                                if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                  await applyOverlayedIcon(context, modViewItem!);
                                                                }
                                                                Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                                                              }
                                                              setState(() {});
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                              //quick apply
                                              Visibility(
                                                visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem!.category),
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
                                                              _previewDismiss = true;
                                                            } else {
                                                              _previewDismiss = false;
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
                                                    menuChildren: quickApplyMenuButtons(context, curMod.submods[modViewModSetSubModIndex])),
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
                                                            _previewDismiss = true;
                                                          } else {
                                                            _previewDismiss = false;
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
                                                          if (modViewItem!.mods.where((element) => element.isFavorite).isEmpty) {
                                                            modViewItem!.isFavorite = false;
                                                            modViewItem = null;
                                                          }
                                                        } else {
                                                          curMod.submods[modViewModSetSubModIndex].isFavorite = true;
                                                          curMod.isFavorite = true;
                                                          modViewItem!.isFavorite = true;
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
                                                      menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]),
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
                                                          final copiedFile =
                                                              await File(selectedFile.path).copy(curMod.submods[modViewModSetSubModIndex].location + p.separator + p.basename(selectedFile.path));
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
                                                        if (!defaultCategoryDirs.contains(modViewItem!.category)) {
                                                          fromItemCategory = await modsSwapperCategorySelect(context);
                                                        }
                                                        modsSwapperDialog(context, modViewItem!, curMod.submods[modViewModSetSubModIndex]);
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
                                                        removeSubmodFromThisSet(selectedModSetName, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]);
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
                                                                if (curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                  deleteItemFromModMan(modViewItem!.location).then((value) async {
                                                                    String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                    if (modViewItem!.isSet) {
                                                                      for (var setName in modViewItem!.setNames) {
                                                                        int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                        if (setIndex != -1) {
                                                                          modSetList[setIndex].setItems.remove(modViewItem);
                                                                        }
                                                                      }
                                                                    }
                                                                    modViewCate!.items.remove(modViewItem);
                                                                    modViewItem = null;
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
                                                                      modViewItem!.mods.remove(curMod);
                                                                    } else {
                                                                      curMod.isNew = curMod.getSubmodsIsNewState();
                                                                    }

                                                                    if (modViewItem!.mods.isEmpty) {
                                                                      modViewCate!.items.remove(modViewItem);
                                                                      modViewItem = null;
                                                                    } else {
                                                                      modViewItem!.isNew = modViewItem!.getModsIsNewState();
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
                                    ListView.builder(
                                        shrinkWrap: true,
                                        cacheExtent: double.maxFinite,
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
                                                  for (var path in curSubmod.previewImages.toSet()) {
                                                    previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curSubmod.itemName).last));
                                                  }
                                                  for (var path in curSubmod.previewVideos.toSet()) {
                                                    previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curSubmod.itemName).last));
                                                  }
                                                } else {
                                                  previewImages.clear();
                                                  previewModName = curMod.modName;
                                                  for (var path in curMod.previewImages) {
                                                    previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curMod.itemName).last));
                                                  }
                                                  for (var path in curMod.previewVideos) {
                                                    previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curMod.itemName).last));
                                                  }
                                                }
                                                setState(() {});
                                              },
                                              child: InfoPopupWidget(
                                                horizontalDirection: 'right',
                                                dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                customContent: () => hoveringOnSubmod && !hoveringOnModFile && previewWindowVisible && !showPreviewPanel && previewImages.isNotEmpty && !_previewDismiss
                                                    ? ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            minWidth: appWindow.size.width / 5,
                                                            minHeight: appWindow.size.height / 5,
                                                            maxWidth: appWindow.size.width / 3,
                                                            maxHeight: appWindow.size.height / 3),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                          child: FlutterCarousel(
                                                            options: CarouselOptions(
                                                                autoPlay: previewImages.length > 1,
                                                                autoPlayInterval: previewImages.length > 1 &&
                                                                        previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                                                                    ? const Duration(seconds: 5)
                                                                    : previewImages.length > 1 &&
                                                                            previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                                                                        ? const Duration(seconds: 1)
                                                                        : const Duration(seconds: 2),
                                                                disableCenter: true,
                                                                viewportFraction: 1.0,
                                                                height: double.infinity,
                                                                floatingIndicator: false,
                                                                enableInfiniteScroll: true,
                                                                indicatorMargin: 4,
                                                                slideIndicator: CircularWaveSlideIndicator(
                                                                    itemSpacing: 10,
                                                                    indicatorRadius: 4,
                                                                    currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                                                    indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
                                                            items: previewImages,
                                                          ),
                                                        ),
                                                      )
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
                                                                  border: Border.all(color: curSubmod.cmxApplied! ? Theme.of(context).colorScheme.primary : Theme.of(context).primaryColorLight),
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
                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                              Stack(
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
                                                                      message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, curSubmod.submodName),
                                                                      child: InkWell(
                                                                        child: const Icon(
                                                                          FontAwesomeIcons.squareMinus,
                                                                        ),
                                                                        onTap: () async {
                                                                          isModViewModsRemoving = true;
                                                                          setState(() {});

                                                                          Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                                                            //status
                                                                            restoreOriginalFilesToTheGame(context, curSubmod.modFiles).then((value) async {
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
                                                                              if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                curSubmod.applyStatus = false;
                                                                              }
                                                                              if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                curMod.applyStatus = false;
                                                                              }
                                                                              if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                modViewItem!.applyStatus = false;
                                                                                if (modViewItem!.backupIconPath!.isNotEmpty) {
                                                                                  await restoreOverlayedIcon(modViewItem!);
                                                                                }
                                                                              }

                                                                              await filesRestoredMessage(mainPageScaffoldKey.currentContext, curSubmod.modFiles, value);
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
                                                              ),
                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                              Stack(
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
                                                                      message: uiInTextArg(curLangText!.uiApplyXToTheGame, curSubmod.submodName),
                                                                      child: InkWell(
                                                                        onTap: () async {
                                                                          isModViewModsApplying = true;
                                                                          setState(() {});
                                                                          Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                                                            //apply mod files
                                                                            if (await originalFilesCheck(context, curSubmod.modFiles)) {
                                                                              //apply auto radius removal if on
                                                                              if (removeBoundaryRadiusOnModsApply) await removeBoundaryOnModsApply(context, curSubmod);
                                                                              if (autoAqmInject) await aqmInjectionOnModsApply(context, curSubmod);

                                                                              await applyModsToTheGame(context, modViewItem!, curMod, curSubmod);

                                                                              if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                                await applyOverlayedIcon(context, modViewItem!);
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
                                                              ),

                                                            // quick apply
                                                            Visibility(
                                                              visible: !isModViewModsApplying && !defaultCategoryDirsToIgnoreQuickSwapApply.contains(modViewItem!.category),
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
                                                                            _previewDismiss = true;
                                                                          } else {
                                                                            _previewDismiss = false;
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
                                                                  menuChildren: quickApplyMenuButtons(context, curSubmod)),
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
                                                                          _previewDismiss = true;
                                                                        } else {
                                                                          _previewDismiss = false;
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
                                                                        if (modViewItem!.mods.where((element) => element.isFavorite).isEmpty) {
                                                                          modViewItem!.isFavorite = false;
                                                                        }
                                                                      } else {
                                                                        curSubmod.isFavorite = true;
                                                                        curMod.isFavorite = true;
                                                                        modViewItem!.isFavorite = true;
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
                                                                    menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curSubmod),
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
                                                                      if (!defaultCategoryDirs.contains(modViewItem!.category)) {
                                                                        fromItemCategory = await modsSwapperCategorySelect(context);
                                                                      }
                                                                      modsSwapperDialog(context, modViewItem!, curSubmod);
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
                                                                        removeSubmodFromThisSet(selectedModSetName, modViewItem!, curMod, curSubmod);
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
                                                                              if (curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                                deleteItemFromModMan(modViewItem!.location).then((value) async {
                                                                                  String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                                  if (modViewItem!.isSet) {
                                                                                    for (var setName in modViewItem!.setNames) {
                                                                                      int setIndex = modSetList.indexWhere((element) => element.setName == setName);
                                                                                      if (setIndex != -1) {
                                                                                        modSetList[setIndex].setItems.remove(modViewItem);
                                                                                      }
                                                                                    }
                                                                                  }
                                                                                  modViewCate!.items.remove(modViewItem);
                                                                                  modViewItem = null;
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
                                                                                    modViewItem!.mods.remove(curMod);
                                                                                  } else {
                                                                                    curMod.isNew = curMod.getSubmodsIsNewState();
                                                                                  }
                                                                                  if (modViewItem!.mods.isEmpty) {
                                                                                    modViewCate!.items.remove(modViewItem);
                                                                                    modViewItem = null;
                                                                                  } else {
                                                                                    modViewItem!.isNew = modViewItem!.getModsIsNewState();
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
                                                                                  curSubmod.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
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
                                                    ListView.builder(
                                                        shrinkWrap: true,
                                                        cacheExtent: double.maxFinite,
                                                        prototypeItem: const ListTile(),
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

                                                                    //set preview images
                                                                    previewImages.addAll(curModFile.previewImages!
                                                                        .toSet()
                                                                        .map((path) => PreviewImageStack(imagePath: path, overlayText: path.split(curSubmod.itemName).last)));
                                                                    //set preview videos
                                                                    previewImages.addAll(curModFile.previewVideos!
                                                                        .toSet()
                                                                        .map((path) => PreviewVideoStack(videoPath: path, overlayText: path.split(curSubmod.itemName).last)));
                                                                  } else if (previewWindowVisible && hoveringOnSubmod && !hoveringOnModFile) {
                                                                    previewModName = curSubmod.submodName;
                                                                    previewImages.clear();
                                                                    for (var path in curSubmod.previewImages.toSet()) {
                                                                      previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(curSubmod.itemName).last));
                                                                    }
                                                                    for (var path in curSubmod.previewVideos.toSet()) {
                                                                      previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(curSubmod.itemName).last));
                                                                    }
                                                                  }
                                                                  setState(() {});
                                                                },
                                                                child: InfoPopupWidget(
                                                                    horizontalDirection: 'right',
                                                                    dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                                    popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                                    arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                                    customContent: () => previewWindowVisible && hoveringOnModFile && !showPreviewPanel && previewImages.isNotEmpty && !_previewDismiss
                                                                        ? ConstrainedBox(
                                                                            constraints: BoxConstraints(
                                                                                minWidth: appWindow.size.width / 5,
                                                                                minHeight: appWindow.size.height / 5,
                                                                                maxWidth: appWindow.size.width / 3,
                                                                                maxHeight: appWindow.size.height / 3),
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                  color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                              child: FlutterCarousel(
                                                                                options: CarouselOptions(
                                                                                    autoPlay: previewImages.length > 1,
                                                                                    autoPlayInterval: previewImages.length > 1 &&
                                                                                            previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                                                                                        ? const Duration(seconds: 5)
                                                                                        : previewImages.length > 1 &&
                                                                                                previewImages.where((element) => element.toString() == ('PreviewImageStack')).length ==
                                                                                                    previewImages.length
                                                                                            ? const Duration(seconds: 1)
                                                                                            : const Duration(seconds: 2),
                                                                                    disableCenter: true,
                                                                                    viewportFraction: 1.0,
                                                                                    height: double.infinity,
                                                                                    floatingIndicator: false,
                                                                                    enableInfiniteScroll: true,
                                                                                    indicatorMargin: 4,
                                                                                    slideIndicator: CircularWaveSlideIndicator(
                                                                                        itemSpacing: 10,
                                                                                        indicatorRadius: 4,
                                                                                        currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                                                                        indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
                                                                                items: previewImages,
                                                                              ),
                                                                            ),
                                                                          )
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
                                                                          if (curModFile.applyStatus == false)
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
                                                                                        modViewItem!.applyDate = DateTime.now();
                                                                                        curMod.applyDate = DateTime.now();
                                                                                        curSubmod.applyStatus = true;
                                                                                        curSubmod.isNew = false;
                                                                                        curMod.applyStatus = true;
                                                                                        curMod.isNew = false;
                                                                                        modViewItem!.applyStatus = true;
                                                                                        if (modViewItem!.mods.where((element) => element.isNew).isEmpty) {
                                                                                          modViewItem!.isNew = false;
                                                                                        }
                                                                                        if (autoAqmInject) await aqmInjectionOnModsApply(context, curSubmod);
                                                                                        if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                                          await applyOverlayedIcon(context, modViewItem!);
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
                                                                          if (curModFile.applyStatus == true)
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
                                                                                      curSubmod.applyStatus = false;
                                                                                      if (autoAqmInject) {
                                                                                        await aqmInjectionRemovalSilent(context, curSubmod);
                                                                                      }
                                                                                    }
                                                                                    if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                      curMod.applyStatus = false;
                                                                                    }
                                                                                    if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                      modViewItem!.applyStatus = false;
                                                                                      if (modViewItem!.backupIconPath!.isNotEmpty) {
                                                                                        await restoreOverlayedIcon(modViewItem!);
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
                                                                                  removeModFileFromThisSet(selectedModSetName, modViewItem!, curMod, curSubmod, curModFile);
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
                                                                                      if (curSubmod.modFiles.length < 2 && curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                                        deleteItemFromModMan(modViewItem!.location).then((value) async {
                                                                                          String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                                          modViewCate!.items.remove(modViewItem);
                                                                                          modViewItem = null;
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
                                                                                            modViewItem!.mods.remove(curMod);
                                                                                          } else {
                                                                                            curMod.isNew = curMod.getSubmodsIsNewState();
                                                                                          }
                                                                                          if (modViewItem!.mods.isEmpty) {
                                                                                            modViewCate!.items.remove(modViewItem);
                                                                                            modViewItem = null;
                                                                                          } else {
                                                                                            modViewItem!.isNew = modViewItem!.getModsIsNewState();
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
                        ),
                      );
                    })))
    ]);
  }

//APPLIED MOD LIST=====================================================================================================================================================================================
  Widget appliedModsView() {
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
    return Column(children: [
      AppBar(
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
                    message: curLangText!.uiHoldToReapplySelectedMods,
                    child: InkWell(
                        onLongPress: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                isModViewModsRemoving = true;
                                isModViewModsApplying = true;
                                setState(() {});
                                Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                  final reappliedList = await reapplySelectedAppliedMods(context);
                                  // .then((value) {
                                  isModViewModsRemoving = false;
                                  isModViewModsApplying = false;
                                  saveModdedItemListToJson();
                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, reappliedList.first, reappliedList[1], 3000));
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
                    message: curLangText!.uiHoldToRemoveSelectedMods,
                    child: InkWell(
                        onLongPress: moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                isModViewModsRemoving = true;
                                isModViewModsApplying = true;
                                setState(() {});
                                Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () async {
                                  final unappliedList = await unapplySelectedAppliedMods(context);
                                  // .then((value) {
                                  isModViewModsRemoving = false;
                                  isModViewModsApplying = false;
                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, unappliedList.first, unappliedList[1], 3000));
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
      const Divider(
        height: 1,
        thickness: 1,
        //color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
      if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isNotEmpty)
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
            child: ListView.builder(
              // shrinkWrap: true,
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.only(right: 2),
              itemCount: moddedItemsList.length,
              itemBuilder: (context, groupIndex) {
                int cateListLength = moddedItemsList[groupIndex].categories.where((e) => e.getNumOfAppliedItems() > 0).length;
                List<Category> cateList = moddedItemsList[groupIndex].categories.where((e) => e.getNumOfAppliedItems() > 0).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (groupIndex != 0)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        //color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),
                    Visibility(
                      visible: moddedItemsList[groupIndex].getNumOfAppliedCates() > 0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                          //color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            collapsedTextColor: Theme.of(context).colorScheme.primary,
                            collapsedIconColor: Theme.of(context).colorScheme.primary,
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
                              ListView.builder(
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
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: itemListLength,
                                            itemBuilder: (context, itemIndex) {
                                              var curItem = itemList[itemIndex];
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
                                                        for (var path in submod.previewImages) {
                                                          previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                        }
                                                      }
                                                    }
                                                    for (var mod in curMods) {
                                                      for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                        for (var path in submod.previewVideos) {
                                                          previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    // hoveringOnSubmod = false;
                                                    previewModName = '';
                                                    previewImages.clear();
                                                  }
                                                  setState(() {});
                                                },
                                                child: InfoPopupWidget(
                                                  horizontalDirection: 'left',
                                                  dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                                  popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                                  arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                                  customContent: () => previewWindowVisible && !showPreviewPanel && previewWindowVisible && previewImages.isNotEmpty && !_previewDismiss
                                                      ? ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                              minWidth: appWindow.size.width / 5,
                                                              minHeight: appWindow.size.height / 5,
                                                              maxWidth: appWindow.size.width / 3,
                                                              maxHeight: appWindow.size.height / 3),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                            child: FlutterCarousel(
                                                              options: CarouselOptions(
                                                                  autoPlay: previewImages.length > 1,
                                                                  autoPlayInterval: previewImages.length > 1 &&
                                                                          previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                                                                      ? const Duration(seconds: 5)
                                                                      : previewImages.length > 1 &&
                                                                              previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                                                                          ? const Duration(seconds: 1)
                                                                          : const Duration(seconds: 2),
                                                                  disableCenter: true,
                                                                  viewportFraction: 1.0,
                                                                  height: double.infinity,
                                                                  floatingIndicator: false,
                                                                  enableInfiniteScroll: true,
                                                                  indicatorMargin: 4,
                                                                  slideIndicator: CircularWaveSlideIndicator(
                                                                      itemSpacing: 10,
                                                                      indicatorRadius: 4,
                                                                      currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                                                      indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
                                                              items: previewImages,
                                                            ),
                                                          ),
                                                        )
                                                      : null,
                                                  child: ListTile(
                                                    tileColor: Colors.transparent,
                                                    onTap: () {
                                                      isModViewListHidden = false;
                                                      isModViewFromApplied = true;
                                                      modViewItem = curItem;
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
                                                                          ? curItem.itemName.split('_').isNotEmpty &&
                                                                                  curItem.itemName.split('_').first == 'it' &&
                                                                                  curItem.itemName.split('_')[1] == 'wp'
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
                                                                              onTap: () async => await launchUrl(Uri.file(curItem.location)),
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

                                                                          if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == true) != -1)
                                                                            Stack(
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
                                                                                    message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, applyingModNames[m]),
                                                                                    child: InkWell(
                                                                                      child: const Icon(
                                                                                        FontAwesomeIcons.squareMinus,
                                                                                      ),
                                                                                      onTap: () async {
                                                                                        isModViewModsRemoving = true;
                                                                                        setState(() {});
                                                                                        Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () async {
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
                                                                                                  if (autoAqmInject) {
                                                                                                    await aqmInjectionRemovalSilent(context, submod);
                                                                                                  }
                                                                                                  submod.applyStatus = false;
                                                                                                  submod.applyDate = DateTime(0);
                                                                                                }
                                                                                                if (submod.applyStatus) {
                                                                                                  for (var path in submod.previewImages) {
                                                                                                    previewImages
                                                                                                        .add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                                                                  }
                                                                                                  for (var path in submod.previewVideos) {
                                                                                                    previewImages
                                                                                                        .add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                                                                  }
                                                                                                }
                                                                                              }
                                                                                              if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                                mod.applyStatus = false;
                                                                                                mod.applyDate = DateTime(0);
                                                                                              }
                                                                                            }

                                                                                            if (curItem.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              curItem.applyStatus = false;
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
                                                                                            isModViewModsRemoving = false;
                                                                                            isModViewModsApplying = false;

                                                                                            saveModdedItemListToJson();
                                                                                            // await Future.delayed(const Duration(seconds: 5));
                                                                                            setState(() {
                                                                                              if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                                Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                                              }
                                                                                            });
                                                                                          });
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

                                                                                    final appliedModFiles = await modFilesApply(context, allAppliedModFiles[m]);
                                                                                    // .then((value) async {
                                                                                    if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus) != -1) {
                                                                                      int curModIndex = curItem.mods.indexWhere((element) => element.modName == allAppliedModFiles[m].first.modName);
                                                                                      int curSubModIndex = curItem.mods[curModIndex].submods
                                                                                          .indexWhere((element) => element.submodName == allAppliedModFiles[m].first.submodName);
                                                                                      curItem.mods[curModIndex].submods[curSubModIndex].applyStatus = true;
                                                                                      curItem.mods[curModIndex].submods[curSubModIndex].isNew = false;
                                                                                      curItem.mods[curModIndex].submods[curSubModIndex].applyDate = DateTime.now();
                                                                                      curItem.mods[curModIndex].applyStatus = true;
                                                                                      curItem.mods[curModIndex].isNew = false;
                                                                                      curItem.mods[curModIndex].applyDate = DateTime.now();
                                                                                      curItem.applyStatus = true;
                                                                                      if (curItem.mods.where((element) => element.isNew).isEmpty) {
                                                                                        curItem.isNew = false;
                                                                                      }
                                                                                      curItem.applyDate = DateTime.now();
                                                                                      if (autoAqmInject) await aqmInjectionOnModsApply(context, curItem.mods[curModIndex].submods[curSubModIndex]);
                                                                                      if (Provider.of<StateProvider>(context, listen: false).markModdedItem) {
                                                                                        await applyOverlayedIcon(context, curItem);
                                                                                      }
                                                                                      Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
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
                                                                                    setState(() {});
                                                                                    // });
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
                                                              Wrap(
                                                                spacing: 5,
                                                                children: [
                                                                  Text(
                                                                    '$totalAppliedModFiles / $totalModFiles ${curLangText!.uiFilesApplied}',
                                                                    //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
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
                                            }),
                                      ]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
    ]);
  }

//PREVIEW=====================================================================================================================================================================================
  Widget modPreviewView() {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: <Widget>[Container()],
        title: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: Text(previewModName.isNotEmpty ? '${curLangText!.uiPreview}: $previewModName' : curLangText!.uiPreview),
        ),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: 30,
        elevation: 0,
      ),
      const Divider(
        height: 1,
        thickness: 1,
        //color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
      if (previewImages.isEmpty && hoveringOnSubmod)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: Theme.of(context).canvasColor.withOpacity(0.8), borderRadius: const BorderRadius.all(Radius.circular(2))),
                child: Text(
                  curLangText!.uiNoPreViewAvailable,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      if ((previewImages.isNotEmpty && !hoveringOnSubmod) || (previewImages.isNotEmpty && hoveringOnSubmod))
        Expanded(
          child: FlutterCarousel(
            options: CarouselOptions(
                autoPlay: previewImages.length > 1,
                autoPlayInterval: previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                    ? const Duration(seconds: 5)
                    : previewImages.length > 1 && previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                        ? const Duration(seconds: 1)
                        : const Duration(seconds: 2),
                disableCenter: true,
                viewportFraction: 1.0,
                height: double.infinity,
                floatingIndicator: false,
                enableInfiniteScroll: true,
                indicatorMargin: 4,
                slideIndicator: CircularWaveSlideIndicator(
                    itemSpacing: 10, indicatorRadius: 4, currentIndicatorColor: Theme.of(context).colorScheme.primary, indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
            items: previewImages,
          ),
        )
    ]);
  }

//Mod Set=====================================================================================================================================================================================
  Widget setList() {
    return Column(children: [
      AppBar(
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
      const Divider(
        height: 1,
        thickness: 1,
        //color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
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
              child: ListView.builder(
                  // shrinkWrap: true,
                  physics: const ScrollPhysics(),
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
                          child: Card(
                              margin: EdgeInsets.zero,
                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                              shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                              child: ExpansionTile(
                                  backgroundColor: Colors.transparent,
                                  collapsedTextColor: Theme.of(context).colorScheme.primary,
                                  collapsedIconColor: Theme.of(context).colorScheme.primary,
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
                                                  message: uiInTextArg(curLangText!.uiRemoveAllModsInXFromTheGame, curSet.setName),
                                                  child: InkWell(
                                                    child: const Icon(
                                                      FontAwesomeIcons.squareMinus,
                                                    ),
                                                    onTap: () async {
                                                      isModViewModsRemoving = true;
                                                      isModViewModsApplying = true;
                                                      setState(() {});
                                                      Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
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
                                                                  submod.applyStatus = false;
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
                                                                mod.applyStatus = false;
                                                              }
                                                            }
                                                          }

                                                          for (var item in curSet.setItems) {
                                                            if (item.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                              item.applyStatus = false;
                                                              if (item.backupIconPath!.isNotEmpty) {
                                                                await restoreOverlayedIcon(item);
                                                              }
                                                            }
                                                          }

                                                          await filesRestoredMessage(mainPageScaffoldKey.currentContext, allAppliedModFiles, value);
                                                          if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                            previewModName = '';
                                                            previewImages.clear();
                                                            Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                          }
                                                          isModViewModsRemoving = false;
                                                          isModViewModsApplying = false;
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
                                        if (curSet.setItems.indexWhere((element) => element.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus == false).isNotEmpty) !=
                                            -1)
                                          Stack(
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
                                                  message: uiInTextArg(curLangText!.uiApplyAllModsInXToTheGame, curSet.setName),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      isModViewModsApplying = true;
                                                      setState(() {});
                                                      Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                                        List<ModFile> allAppliedModFiles = [];
                                                        for (var item in curSet.setItems.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                          for (var mod in item.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                            for (var submod in mod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                              allAppliedModFiles.addAll(submod.modFiles.where((element) => !element.applyStatus));
                                                            }
                                                          }
                                                        }

                                                        //apply mod files
                                                        if (await originalFilesCheck(context, allAppliedModFiles)) {
                                                          modFilesApply(context, allAppliedModFiles).then((value) async {
                                                            if (value.indexWhere((element) => element.applyStatus) != -1) {
                                                              for (var curItem in curSet.setItems) {
                                                                for (var curMod in curItem.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                                  for (var curSubmod in curMod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                                    curSubmod.applyStatus = true;
                                                                    curSubmod.isNew = false;
                                                                    curSubmod.applyDate = DateTime.now();
                                                                    if (autoAqmInject) await aqmInjectionOnModsApply(context, curSubmod);
                                                                  }
                                                                  curMod.applyStatus = true;
                                                                  curMod.isNew = false;
                                                                  curMod.applyDate = DateTime.now();
                                                                }
                                                                curItem.applyDate = DateTime.now();
                                                                curItem.applyStatus = true;
                                                                if (curItem.mods.where((element) => element.isNew).isEmpty) {
                                                                  curItem.isNew = false;
                                                                }
                                                                if (Provider.of<StateProvider>(context, listen: false).markModdedItem) await applyOverlayedIcon(context, curItem);
                                                                Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
                                                              }
                                                              List<ModFile> appliedModFiles = value;
                                                              String fileAppliedText = '';

                                                              for (var element in appliedModFiles.where((e) => e.applyStatus)) {
                                                                if (fileAppliedText.isEmpty) {
                                                                  fileAppliedText = uiInTextArg(curLangText!.uiSuccessfullyAppliedX, curSet.setName);
                                                                }
                                                                if (!fileAppliedText.contains('${element.itemName} > ${element.modName} > ${element.submodName}\n')) {
                                                                  fileAppliedText += '${element.itemName} > ${element.modName} > ${element.submodName}\n';
                                                                }
                                                              }
                                                              ScaffoldMessenger.of(context)
                                                                  .showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                            }
                                                            isModViewModsApplying = false;
                                                            saveModdedItemListToJson();
                                                            setState(() {});
                                                          });
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
                                              modViewItem = null;
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
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        cacheExtent: double.maxFinite,
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
                                            for (var submod in mod.submods) {
                                              curSubmods.add(submod);
                                              // allAppliedModFiles.add([]);
                                              // allAppliedModFiles.last.addAll(submod.modFiles.where((e) => e.applyStatus));
                                              // applyingModNames.add('${mod.modName} > ${submod.submodName}');
                                              allPreviewImages.addAll(submod.previewImages);
                                              allPreviewVideos.addAll(submod.previewVideos);
                                              totalModFiles += submod.modFiles.length;
                                            }
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
                                                for (var mod in curMods) {
                                                  for (var submod in mod.submods) {
                                                    for (var path in submod.previewImages.toSet()) {
                                                      previewImages.add(PreviewImageStack(imagePath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                    }
                                                  }
                                                }
                                                for (var mod in curMods) {
                                                  for (var submod in mod.submods) {
                                                    for (var path in submod.previewVideos.toSet()) {
                                                      previewImages.add(PreviewVideoStack(videoPath: path, overlayText: p.dirname(path).split(mod.itemName).last));
                                                    }
                                                  }
                                                }
                                              } else {
                                                previewModName = '';
                                                previewImages.clear();
                                              }
                                              setState(() {});
                                            },
                                            child: InfoPopupWidget(
                                              horizontalDirection: 'right',
                                              dismissTriggerBehavior: PopupDismissTriggerBehavior.anyWhere,
                                              popupClickTriggerBehavior: PopupClickTriggerBehavior.none,
                                              arrowTheme: const InfoPopupArrowTheme(arrowSize: Size.zero),
                                              customContent: () => previewWindowVisible && !showPreviewPanel && previewImages.isNotEmpty && !_previewDismiss
                                                  ? ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                          minWidth: appWindow.size.width / 5,
                                                          minHeight: appWindow.size.height / 5,
                                                          maxWidth: appWindow.size.width / 3,
                                                          maxHeight: appWindow.size.height / 3),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                            borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                        child: FlutterCarousel(
                                                          options: CarouselOptions(
                                                              autoPlay: previewImages.length > 1,
                                                              autoPlayInterval: previewImages.length > 1 &&
                                                                      previewImages.where((element) => element.toString() == ('PreviewVideoStack')).length == previewImages.length
                                                                  ? const Duration(seconds: 5)
                                                                  : previewImages.length > 1 &&
                                                                          previewImages.where((element) => element.toString() == ('PreviewImageStack')).length == previewImages.length
                                                                      ? const Duration(seconds: 1)
                                                                      : const Duration(seconds: 2),
                                                              disableCenter: true,
                                                              viewportFraction: 1.0,
                                                              height: double.infinity,
                                                              floatingIndicator: false,
                                                              enableInfiniteScroll: true,
                                                              indicatorMargin: 4,
                                                              slideIndicator: CircularWaveSlideIndicator(
                                                                  itemSpacing: 10,
                                                                  indicatorRadius: 4,
                                                                  currentIndicatorColor: Theme.of(context).colorScheme.primary,
                                                                  indicatorBackgroundColor: Theme.of(context).hintColor.withOpacity(0.3))),
                                                          items: previewImages,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                              child: ListTile(
                                                tileColor: Colors.transparent,
                                                onTap: () {
                                                  isModViewListHidden = false;
                                                  isModViewFromApplied = false;
                                                  modViewItem = curItem;
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
                                                                                ? curItem.itemName.split('_').isNotEmpty &&
                                                                                        curItem.itemName.split('_').first == 'it' &&
                                                                                        curItem.itemName.split('_')[1] == 'wp'
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
                                                                            removeModSetNameFromItems(curSet.setName, [curItem]);
                                                                            modViewItem = null;
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
                                                                                message: uiInTextArg(curLangText!.uiRemoveXFromTheGame, applyingModNames[m]),
                                                                                child: InkWell(
                                                                                  child: const Icon(
                                                                                    FontAwesomeIcons.squareMinus,
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    isModViewModsRemoving = true;
                                                                                    setState(() {});
                                                                                    Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () async {
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
                                                                                            submod.applyStatus = false;
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
                                                                                          mod.applyStatus = false;
                                                                                        }
                                                                                      }

                                                                                      if (curItem.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                        curItem.applyStatus = false;
                                                                                        if (curItem.backupIconPath!.isNotEmpty) {
                                                                                          await restoreOverlayedIcon(curItem);
                                                                                        }
                                                                                      }

                                                                                      await filesRestoredMessage(mainPageScaffoldKey.currentContext, allAppliedModFiles[m], unappliedList);
                                                                                      if (moddedItemsList.where((e) => e.getNumOfAppliedCates() > 0).isEmpty) {
                                                                                        previewModName = '';
                                                                                        previewImages.clear();
                                                                                        Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('');
                                                                                      }

                                                                                      isModViewModsRemoving = false;
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
                                                                                    // for (var curMod in curItem.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                                                    //   for (var curSubmod
                                                                                    //       in curMod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                                                    //     curSubmod.applyStatus = true;
                                                                                    //     curSubmod.isNew = false;
                                                                                    //     curSubmod.applyDate = DateTime.now();
                                                                                    //   }
                                                                                    //   curMod.applyStatus = true;
                                                                                    //   curMod.isNew = false;
                                                                                    //   curMod.applyDate = DateTime.now();
                                                                                    // }
                                                                                    // curItem.applyDate = DateTime.now();
                                                                                    // curItem.applyStatus = true;
                                                                                    // if (curItem.mods.where((element) => element.isNew).isEmpty) {
                                                                                    //   curItem.isNew = false;
                                                                                    // }

                                                                                    int curModIndex = curItem.mods.indexWhere((element) => element.modName == allAppliedModFiles[m].first.modName);
                                                                                    int curSubModIndex = curItem.mods[curModIndex].submods
                                                                                        .indexWhere((element) => element.submodName == allAppliedModFiles[m].first.submodName);
                                                                                    curItem.mods[curModIndex].submods[curSubModIndex].applyStatus = true;
                                                                                    curItem.mods[curModIndex].submods[curSubModIndex].isNew = false;
                                                                                    curItem.mods[curModIndex].submods[curSubModIndex].applyDate = DateTime.now();
                                                                                    curItem.mods[curModIndex].applyStatus = true;
                                                                                    curItem.mods[curModIndex].isNew = false;
                                                                                    curItem.mods[curModIndex].applyDate = DateTime.now();

                                                                                    curItem.applyStatus = true;
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
                                                                                    Provider.of<StateProvider>(context, listen: false).quickApplyStateSet('extra');
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
                                  ])))
                    ]);
                  })))
    ]);
  }

//WIDGETS=============================================================================
  List<Widget> quickApplyMenuButtons(context, SubMod submod) {
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
                            context, false, submod, fromItemIces, toItemIces, modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName());
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

                        String swappedPath = await modsSwapperIceFilesGet(
                            context, false, submod, fromItemIces, toItemIces, modManCurActiveItemNameLanguage == 'JP' ? quickApplyItem.getJPName() : quickApplyItem.getENName(), fromItemId, toItemId);
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
                      isModViewModsApplying = true;
                      setState(() {});
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
