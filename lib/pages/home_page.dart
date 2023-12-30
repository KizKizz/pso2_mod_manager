// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:advance_expansion_tile/advance_expansion_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_edit.dart';
import 'package:pso2_mod_manager/boundary/mods_boundary_functions.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/cmx/cmx_functions.dart';
import 'package:pso2_mod_manager/functions/app_update_dialog.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/apply_all_available_mods.dart';
import 'package:pso2_mod_manager/functions/apply_mods_functions.dart';
import 'package:pso2_mod_manager/functions/cate_mover.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/fav_list.dart';
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
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/preview_image_stack.dart';
import 'package:pso2_mod_manager/widgets/preview_video_stack.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.285), Area(weight: 0.335)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.40)]);
  List<GlobalKey<AdvanceExpansionTileState>> modViewETKeys = [];
  CarouselController previewCarouselController = CarouselController();

  bool hoveringOnSubmod = false;
  Category? modViewCate;
  double headersOpacityValue = 0.7;
  double headersExtraOpacityValue = 0.3;
  List<bool> cateTypeButtonsVisible = [];
  List<List<List<bool>>> itemButtonsVisible = [];
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
  List<CategoryType> searchedItemList = [];
  TextEditingController newSetTextController = TextEditingController();
  String selectedModSetName = '';
  final int applyButtonsDelay = 250;
  final int unapplyButtonsDelay = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!firstTimeUser && !Provider.of<StateProvider>(context, listen: false).isUpdateAvailable) {
        updatedVersionCheck(context);
      }
      dotnetVerCheck(context);
      ogFilesPermChecker(context);
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
      children: [
        if (!context.watch<StateProvider>().setsWindowVisible) itemsView(),
        if (context.watch<StateProvider>().setsWindowVisible) setList(),
        //if (!context.watch<StateProvider>().setsWindowVisible)
        modsView(),
        //if (context.watch<StateProvider>().setsWindowVisible) modInSetList(),
        if (!context.watch<StateProvider>().previewWindowVisible) appliedModsView(),
        if (context.watch<StateProvider>().previewWindowVisible)
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
                            : () {
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
                            hiddenItemCategories.clear();
                            showAllEmptyCategories(moddedItemsList);
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
                            onTap: isCatesReordering.indexWhere((element) => element) != -1
                                ? null
                                : () {
                                    if (isCateTypeReordering) {
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
                    style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                      return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                    }), shape: MaterialStateProperty.resolveWith((states) {
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
                                searchedItemList.clear();
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
                      searchedItemList = await searchListBuilder(moddedItemsList, value);
                      modViewItem = null;
                    } else {
                      searchedItemList.clear();
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
        Expanded(
            child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
              }
              return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
            }),
          ),
          child: SingleChildScrollView(
              child: isShowHideCates
                  //Hidden List
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const PageScrollPhysics(),
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
                                  Text(hiddenItemCategories[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ModManTooltip(
                                    message: '${curLangText!.uiUnhide} ${hiddenItemCategories[groupIndex].groupName}',
                                    child: InkWell(
                                        onTap: () {
                                          for (var cate in hiddenItemCategories[groupIndex].categories) {
                                            showHiddenCategory(hiddenItemCategories, hiddenItemCategories[groupIndex], cate);
                                          }
                                          setState(() {});
                                        },
                                        child: const Icon(
                                          FontAwesomeIcons.solidEye,
                                          size: 18,
                                        )),
                                  ),
                                ],
                              ),
                              subtitle: defaultCategoryTypes.contains(hiddenItemCategories[groupIndex].groupName) && curActiveLang == 'JP'
                                  ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(hiddenItemCategories[groupIndex].groupName)])
                                  : null,
                              initiallyExpanded: true,
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
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
                                            message: '${curLangText!.uiUnhide} ${curCategory.categoryName}',
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
                                              Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                                          subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                              ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                              : null,
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
                          shrinkWrap: true,
                          physics: const PageScrollPhysics(),
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
                                    title: Text(moddedItemsList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                        ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)])
                                        : null,
                                    trailing: const Icon(Icons.drag_handle_outlined),
                                  ),
                                ),
                              ),
                            );
                          })
                      //Normal Favorite ItemList
                      : isFavListVisible
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const PageScrollPhysics(),
                              padding: const EdgeInsets.only(left: 2),
                              itemCount: moddedItemsList.length,
                              itemBuilder: (context, groupIndex) {
                                if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != moddedItemsList.length) {
                                  itemButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
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
                                return Visibility(
                                  visible: moddedItemsList[groupIndex].categories.where((g) => g.items.where((i) => i.isFavorite).isNotEmpty).isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                      shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
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
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(moddedItemsList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              runAlignment: WrapAlignment.center,
                                              spacing: 5,
                                              children: [
                                                ModManTooltip(
                                                  message: '${curLangText!.uiRemove} ${moddedItemsList[groupIndex].groupName} ${curLangText!.uiFromFavList}',
                                                  child: InkWell(
                                                      onTap: () {
                                                        removeCateTypeFromFav(moddedItemsList[groupIndex]);
                                                        modViewItem = null;
                                                        saveModdedItemListToJson();
                                                        setState(() {});
                                                      },
                                                      child: const Icon(
                                                        FontAwesomeIcons.heartCircleMinus,
                                                        size: 18,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        subtitle: defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                            ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)])
                                            : null,
                                        initiallyExpanded: moddedItemsList[groupIndex].expanded,
                                        children: [
                                          //Main Normal Cate=========================================================
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: moddedItemsList[groupIndex].categories.length,
                                            itemBuilder: (context, categoryIndex) {
                                              var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];
                                              if (itemButtonsVisible[groupIndex].isEmpty || itemButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                itemButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                              }
                                              if (cateButtonsVisible[groupIndex].isEmpty || cateButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                cateButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => false);
                                              }
                                              return Visibility(
                                                visible: curCategory.items.where((element) => element.isFavorite).isNotEmpty,
                                                child: InkResponse(
                                                  highlightShape: BoxShape.rectangle,
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
                                                              Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                                                child: Container(
                                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                    decoration: BoxDecoration(
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                    ),
                                                                    child: curCategory.items.where((element) => element.isFavorite).length < 2
                                                                        ? Text('${curCategory.items.where((element) => element.isFavorite).length} ${curLangText!.uiItem}',
                                                                            style: const TextStyle(
                                                                              fontSize: 13,
                                                                            ))
                                                                        : Text('${curCategory.items.where((element) => element.isFavorite).length} ${curLangText!.uiItems}',
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
                                                              spacing: 5,
                                                              children: [
                                                                ModManTooltip(
                                                                  message: '${curLangText!.uiRemove} ${curCategory.categoryName} ${curLangText!.uiFromFavList}',
                                                                  child: InkWell(
                                                                      onTap: () async {
                                                                        removeCateFromFav(curCategory);
                                                                        modViewItem = null;
                                                                        saveModdedItemListToJson();
                                                                        setState(() {});
                                                                      },
                                                                      child: const Icon(
                                                                        FontAwesomeIcons.heartCircleMinus,
                                                                        size: 18,
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                          ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                                          : null,
                                                      children: [
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount: curCategory.items.length,
                                                            itemBuilder: (context, itemIndex) {
                                                              var curItem = curCategory.items[itemIndex];
                                                              if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty ||
                                                                  itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                itemButtonsVisible[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                              }
                                                              return Visibility(
                                                                visible: curItem.isFavorite,
                                                                child: SizedBox(
                                                                  height: 84,
                                                                  child: Container(
                                                                    margin: const EdgeInsets.all(1),
                                                                    color: Colors.transparent,
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
                                                                                          : curItem.isNew
                                                                                              ? Colors.amber
                                                                                              : Theme.of(context).hintColor,
                                                                                      width: curItem.isNew || curItem.applyStatus ? 3 : 1),
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
                                                                                  curItem.itemName.replaceAll('_', '/'),
                                                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                ),
                                                                                // Text(
                                                                                //   curItem.variantNames.join(' | '),
                                                                                //   style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
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
                                                                                        child: Text(
                                                                                          curItem.mods.where((element) => element.isFavorite).length < 2
                                                                                              ? '${curItem.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMod}'
                                                                                              : '${curItem.mods.where((element) => element.isFavorite).length} ${curLangText!.uiMods}',
                                                                                          style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                        ),
                                                                                        child: Text(
                                                                                          '${curItem.mods.where((element) => element.applyStatus && element.isFavorite).length} ${curLangText!.uiApplied}',
                                                                                          style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
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
                                                                              child: Wrap(
                                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                                runAlignment: WrapAlignment.center,
                                                                                spacing: 5,
                                                                                children: [
                                                                                  ModManTooltip(
                                                                                    message: '${curLangText!.uiRemove} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiFromFavList}',
                                                                                    child: InkWell(
                                                                                        onTap: () async {
                                                                                          removeItemFromFav(curItem);
                                                                                          modViewItem = null;
                                                                                          saveModdedItemListToJson();
                                                                                          setState(() {});
                                                                                        },
                                                                                        child: const Icon(
                                                                                          FontAwesomeIcons.heartCircleMinus,
                                                                                          size: 18,
                                                                                        )),
                                                                                  ),
                                                                                  //Open Buttons
                                                                                  ModManTooltip(
                                                                                      message: '${curLangText!.uiOpen} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiInFileExplorer}',
                                                                                      child: InkWell(
                                                                                        child: const Icon(Icons.folder_open),
                                                                                        onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                      )),
                                                                                  //Delete
                                                                                  ModManTooltip(
                                                                                    message: '${curLangText!.uiHoldToRemove} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiFromMM}',
                                                                                    child: InkWell(
                                                                                      onLongPress: curItem.applyStatus
                                                                                          ? null
                                                                                          : () async {
                                                                                              deleteItemFromModMan(curItem.location).then((value) {
                                                                                                String removedName = '${curCategory.categoryName} > ${curItem.itemName.replaceAll('_', '/')}';
                                                                                                if (modViewItem == curItem) {
                                                                                                  modViewItem = null;
                                                                                                }
                                                                                                curCategory.items.remove(curItem);
                                                                                                ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                                    '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                      onTap: () {
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
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : searchTextController.value.text.isNotEmpty
                              //Search Item List
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const PageScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 2),
                                  itemCount: searchedItemList.length,
                                  itemBuilder: (context, groupIndex) {
                                    if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != searchedItemList.length) {
                                      itemButtonsVisible = List.generate(searchedItemList.length, (index) => []);
                                    }
                                    if (cateButtonsVisible.isEmpty || cateButtonsVisible.length != searchedItemList.length) {
                                      cateButtonsVisible = List.generate(searchedItemList.length, (index) => []);
                                    }
                                    if (isCatesReordering.isEmpty || isCatesReordering.length != searchedItemList.length) {
                                      isCatesReordering = List.generate(searchedItemList.length, (index) => false);
                                    }
                                    if (isCateTypeListExpanded.isEmpty || isCateTypeListExpanded.length != searchedItemList.length) {
                                      isCateTypeListExpanded = List.generate(searchedItemList.length, (index) => true);
                                    }
                                    if (isCatesAscenAlpha.isEmpty || isCatesAscenAlpha.length != searchedItemList.length) {
                                      isCatesAscenAlpha = List.generate(searchedItemList.length, (index) => false);
                                    }
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (groupIndex != 0)
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                          ),
                                        //search catetype card
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
                                              onExpansionChanged: (value) {
                                                isCateTypeListExpanded[groupIndex] = value;
                                                setState(() {});
                                              },
                                              title: Text(searchedItemList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                              subtitle: defaultCateforyDirs.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                                  ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(moddedItemsList[groupIndex].groupName)])
                                                  : null,
                                              initiallyExpanded: searchedItemList[groupIndex].expanded,
                                              children: [
                                                //Search Main Normal Cate=========================================================
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemCount: searchedItemList[groupIndex].categories.length,
                                                  itemBuilder: (context, categoryIndex) {
                                                    var curCategory = searchedItemList[groupIndex].categories[categoryIndex];
                                                    if (itemButtonsVisible[groupIndex].isEmpty || itemButtonsVisible[groupIndex].length != searchedItemList[groupIndex].categories.length) {
                                                      itemButtonsVisible[groupIndex] = List.generate(searchedItemList[groupIndex].categories.length, (index) => []);
                                                    }
                                                    if (cateButtonsVisible[groupIndex].isEmpty || cateButtonsVisible[groupIndex].length != searchedItemList[groupIndex].categories.length) {
                                                      cateButtonsVisible[groupIndex] = List.generate(searchedItemList[groupIndex].categories.length, (index) => false);
                                                    }
                                                    int itemMatchingNum = cateItemSearchMatchesCheck(curCategory, searchTextController.value.text.toLowerCase());
                                                    return Visibility(
                                                      visible: curCategory.visible &&
                                                          (curCategory.categoryName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) || itemMatchingNum > 0),
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
                                                                    Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                                                      child: Container(
                                                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                          ),
                                                                          child: itemMatchingNum < 2
                                                                              ? Text('$itemMatchingNum ${curLangText!.uiItem}',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13,
                                                                                  ))
                                                                              : Text('$itemMatchingNum ${curLangText!.uiItems}',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13,
                                                                                  ))),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Visibility(
                                                                  visible: cateButtonsVisible[groupIndex][categoryIndex],
                                                                  child: const Wrap(
                                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                                    runAlignment: WrapAlignment.center,
                                                                    spacing: 5,
                                                                    children: [
                                                                      //Cate tile buttons
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                                ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                                                : null,
                                                            children: [
                                                              ListView.builder(
                                                                  shrinkWrap: true,
                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                  itemCount: curCategory.items.length,
                                                                  itemBuilder: (context, itemIndex) {
                                                                    var curItem = curCategory.items[itemIndex];
                                                                    if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty ||
                                                                        itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                      itemButtonsVisible[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                    }
                                                                    int modMatchingNum = itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase());
                                                                    return Visibility(
                                                                      visible: curItem.itemName.toLowerCase().contains(searchTextController.value.text.toLowerCase()) || modMatchingNum > 0,
                                                                      child: SizedBox(
                                                                        height: 84,
                                                                        child: Container(
                                                                          margin: const EdgeInsets.all(1),
                                                                          color: Colors.transparent,
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
                                                                                                : curItem.isNew
                                                                                                    ? Colors.amber
                                                                                                    : Theme.of(context).hintColor,
                                                                                            width: curItem.isNew || curItem.applyStatus ? 3 : 1),
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
                                                                                        curItem.itemName.replaceAll('_', '/'),
                                                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      // Text(
                                                                                      //   curItem.variantNames.join(' | '),
                                                                                      //   style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                      // ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(top: 5),
                                                                                        child: Wrap(
                                                                                          runAlignment: WrapAlignment.center,
                                                                                          alignment: WrapAlignment.center,
                                                                                          spacing: 5,
                                                                                          children: [
                                                                                            if (modMatchingNum == 0)
                                                                                              Container(
                                                                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                                decoration: BoxDecoration(
                                                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                                ),
                                                                                                child: Text(
                                                                                                  curItem.mods.length < 2
                                                                                                      ? '${curItem.mods.length} ${curLangText!.uiMod}'
                                                                                                      : '${curItem.mods.length} ${curLangText!.uiMods}',
                                                                                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                ),
                                                                                              ),
                                                                                            if (modMatchingNum > 0)
                                                                                              Container(
                                                                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                                decoration: BoxDecoration(
                                                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                                ),
                                                                                                child: Text(
                                                                                                  modMatchingNum < 2
                                                                                                      ? '$modMatchingNum ${curLangText!.uiMod}'
                                                                                                      : '$modMatchingNum ${curLangText!.uiMods}',
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
                                                                                                  '${curItem.mods.where((element) => element.applyStatus).length} ${curLangText!.uiApplied}',
                                                                                                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                )),
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
                                                                                    child: Wrap(
                                                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                                                      runAlignment: WrapAlignment.center,
                                                                                      spacing: 5,
                                                                                      children: [
                                                                                        //Open Buttons
                                                                                        ModManTooltip(
                                                                                            message: '${curLangText!.uiOpen} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiInFileExplorer}',
                                                                                            child: InkWell(
                                                                                              child: const Icon(Icons.folder_open),
                                                                                              onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                            )),
                                                                                        //Delete
                                                                                        ModManTooltip(
                                                                                          message: '${curLangText!.uiHoldToRemove} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiFromMM}',
                                                                                          child: InkWell(
                                                                                            onLongPress: curItem.applyStatus
                                                                                                ? null
                                                                                                : () async {
                                                                                                    deleteItemFromModMan(curItem.location).then((value) {
                                                                                                      String removedName = '${curCategory.categoryName} > ${curItem.itemName.replaceAll('_', '/')}';
                                                                                                      if (modViewItem == curItem) {
                                                                                                        modViewItem = null;
                                                                                                      }
                                                                                                      curCategory.items.remove(curItem);
                                                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                                          '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                            onTap: () {
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
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                )

                              //Normal Catetype List
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const PageScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 2),
                                  itemCount: moddedItemsList.length,
                                  itemBuilder: (context, groupIndex) {
                                    if (cateTypeButtonsVisible.isEmpty || cateTypeButtonsVisible.length != moddedItemsList.length) {
                                      cateTypeButtonsVisible = List.generate(moddedItemsList.length, (index) => false);
                                    }
                                    if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != moddedItemsList.length) {
                                      itemButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
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
                                          visible: moddedItemsList[groupIndex].visible,
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
                                                      Text(moddedItemsList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                                                                visible: isCateTypeListExpanded[groupIndex] &&
                                                                    !isCatesReordering[groupIndex] &&
                                                                    !defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName),
                                                                child: ModManTooltip(
                                                                  message: '${curLangText!.uiHoldToDelete} ${moddedItemsList[groupIndex].groupName} ${curLangText!.uiFromMM}',
                                                                  child: InkWell(
                                                                      child: const Icon(Icons.delete_forever_outlined),
                                                                      onLongPress: () {
                                                                        if (moddedItemsList[groupIndex].categories.isEmpty) {
                                                                          modViewItem = null;
                                                                          moddedItemsList.remove(moddedItemsList[groupIndex]);
                                                                        } else {
                                                                          categoryGroupRemover(context, moddedItemsList[groupIndex]);
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
                                                                  message: '${curLangText!.uiAddANewCateTo} ${moddedItemsList[groupIndex].groupName}',
                                                                  child: InkWell(
                                                                      onTap: () async {
                                                                        String newCategoryName = await categoryAdder(context);
                                                                        if (newCategoryName.isNotEmpty) {
                                                                          Directory(Uri.file('$modManModsDirPath/$newCategoryName').toFilePath()).createSync();
                                                                          moddedItemsList[groupIndex].categories.insert(
                                                                              0,
                                                                              Category(newCategoryName, moddedItemsList[groupIndex].groupName,
                                                                                  Uri.file('$modManModsDirPath/$newCategoryName').toFilePath(), 0, true, []));
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
                                                  subtitle: defaultCategoryTypes.contains(moddedItemsList[groupIndex].groupName) && curActiveLang == 'JP'
                                                      ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(moddedItemsList[groupIndex].groupName)])
                                                      : null,
                                                  trailing: !isCatesReordering[groupIndex]
                                                      ? null
                                                      : ModManTooltip(
                                                          message: curLangText!.uiBack,
                                                          child: InkWell(
                                                              child: const Icon(
                                                                Icons.arrow_back_ios_new,
                                                              ),
                                                              onTap: () {
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
                                                          padding: const EdgeInsets.only(left: 2, right: 1),
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
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
                                                                      Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                                                        child: Container(
                                                                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                            ),
                                                                            child: curCategory.items.length < 2
                                                                                ? Text('${moddedItemsList[groupIndex].categories[categoryIndex].items.length} ${curLangText!.uiItem}',
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
                                                                  subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                                      ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                                                      : null,
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
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        itemCount: moddedItemsList[groupIndex].categories.length,
                                                        itemBuilder: (context, categoryIndex) {
                                                          var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];
                                                          if (itemButtonsVisible[groupIndex].isEmpty || itemButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                            itemButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                                          }
                                                          if (cateButtonsVisible[groupIndex].isEmpty || cateButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                                            cateButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => false);
                                                          }
                                                          return Visibility(
                                                            visible: curCategory.visible,
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
                                                                          Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                                                            child: Container(
                                                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                ),
                                                                                child: curCategory.items.length < 2
                                                                                    ? Text('${moddedItemsList[groupIndex].categories[categoryIndex].items.length} ${curLangText!.uiItem}',
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
                                                                      Visibility(
                                                                        visible: cateButtonsVisible[groupIndex][categoryIndex],
                                                                        child: Wrap(
                                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                                          runAlignment: WrapAlignment.center,
                                                                          spacing: 10,
                                                                          children: [
                                                                            //Move cate
                                                                            ModManTooltip(
                                                                              message: 'Move ${curCategory.categoryName} to another Category Group',
                                                                              child: InkWell(
                                                                                  onTap: () async {
                                                                                    await categoryMover(context, moddedItemsList[groupIndex], curCategory);
                                                                                    setState(() {});
                                                                                  },
                                                                                  child: const Icon(Icons.move_down_rounded)),
                                                                            ),
                                                                            //Hide cate
                                                                            ModManTooltip(
                                                                              message: '${curLangText!.uiHoldToHide} ${curCategory.categoryName} ${curLangText!.uiFromItemList}',
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
                                                                              visible: !defaultCateforyDirs.contains(curCategory.categoryName),
                                                                              child: ModManTooltip(
                                                                                message:
                                                                                    '${curLangText!.uiHoldToRemove} ${curCategory.categoryName} ${curLangText!.uiFrom} ${moddedItemsList[groupIndex].groupName}',
                                                                                child: InkWell(
                                                                                    onLongPress: () {
                                                                                      if (curCategory.items.isEmpty) {
                                                                                        Directory(curCategory.location).deleteSync(recursive: true);
                                                                                        moddedItemsList[groupIndex].categories.remove(curCategory);
                                                                                        for (var cate in moddedItemsList[groupIndex].categories) {
                                                                                          cate.position = moddedItemsList[groupIndex].categories.indexOf(cate);
                                                                                        }
                                                                                        modViewItem = null;
                                                                                      } else {
                                                                                        categoryRemover(context, moddedItemsList[groupIndex], curCategory);
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
                                                                  subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                                                      ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                                                      : null,
                                                                  children: [
                                                                    ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        itemCount: curCategory.items.length,
                                                                        itemBuilder: (context, itemIndex) {
                                                                          var curItem = curCategory.items[itemIndex];
                                                                          if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty ||
                                                                              itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                            itemButtonsVisible[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                          }

                                                                          return SizedBox(
                                                                            height: 84,
                                                                            child: Container(
                                                                              margin: const EdgeInsets.all(1),
                                                                              color: Colors.transparent,
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
                                                                                                    : curItem.isNew
                                                                                                        ? Colors.amber
                                                                                                        : Theme.of(context).hintColor,
                                                                                                width: curItem.isNew || curItem.applyStatus ? 3 : 1),
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
                                                                                            curItem.itemName.replaceAll('_', '/'),
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
                                                                                                  child: Text(
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
                                                                                                message:
                                                                                                    '${curLangText!.uiOpen} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiInFileExplorer}',
                                                                                                child: InkWell(
                                                                                                  child: const Icon(Icons.folder_open),
                                                                                                  onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                                )),
                                                                                            //Delete
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 5),
                                                                                              child: ModManTooltip(
                                                                                                message:
                                                                                                    '${curLangText!.uiHoldToRemove} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiFromMM}',
                                                                                                child: InkWell(
                                                                                                  onLongPress: curItem.applyStatus
                                                                                                      ? null
                                                                                                      : () async {
                                                                                                          deleteItemFromModMan(curItem.location).then((value) {
                                                                                                            String removedName =
                                                                                                                '${curCategory.categoryName} > ${curItem.itemName.replaceAll('_', '/')}';
                                                                                                            if (modViewItem == curItem) {
                                                                                                              modViewItem = null;
                                                                                                            }
                                                                                                            curCategory.items.remove(curItem);
                                                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                                context,
                                                                                                                '${curLangText!.uiSuccess}!',
                                                                                                                '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}',
                                                                                                                3000));
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
                                )),
        )),
      ],
    );
  }

//MODVIEW LIST====================================================================================================================================================================================
  Widget modsView() {
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
                      thickness: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return !isModViewListHidden && modViewItem != null ? 5 : 0;
                        }
                        return !isModViewListHidden && modViewItem != null ? 3 : 0;
                      }),
                      thumbColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                        }
                        return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                      }),
                    ),
                    child: SingleChildScrollView(
                      physics: modViewItem == null ? const NeverScrollableScrollPhysics() : null,
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        !isModViewListHidden && modViewItem != null
                            ? Text(modViewItem!.itemName.replaceAll('_', '/'))
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
        Expanded(
            child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                    }
                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                  }),
                ),
                child: SingleChildScrollView(
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const PageScrollPhysics(),
                        //padding: const EdgeInsets.symmetric(horizontal: 1),
                        itemCount: modViewItem!.mods.length,
                        itemBuilder: (context, modIndex) {
                          modViewETKeys.add(GlobalKey());
                          var curMod = modViewItem!.mods[modIndex];
                          if (isModViewItemListExpanded.isEmpty || isModViewItemListExpanded.length != modViewItem!.mods.length) {
                            isModViewItemListExpanded = List.generate(modViewItem!.mods.length, (index) => false);
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
                                    ? curMod.modName.toLowerCase().contains(searchTextController.value.text.toLowerCase())
                                    : searchTextController.value.text.toLowerCase().isNotEmpty && !isModViewFromApplied && itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) == 0
                                        ? true
                                        : context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                            ? curMod.isSet && curMod.setNames.contains(selectedModSetName)
                                            : true,
                            child: InkWell(
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
                                if (hovering && previewWindowVisible) {
                                  if (modViewModSetSubModIndex != -1) {
                                    hoveringOnSubmod = true;
                                    previewModName = curMod.submods[modViewModSetSubModIndex].submodName;
                                    hoveringOnSubmod = true;
                                    for (var path in curMod.submods[modViewModSetSubModIndex].previewImages) {
                                      previewImages.add(PreviewImageStack(imagePath: path, overlayText: curMod.submods[modViewModSetSubModIndex].submodName));
                                    }
                                    for (var path in curMod.submods[modViewModSetSubModIndex].previewVideos) {
                                      previewImages.add(PreviewVideoStack(videoPath: path, overlayText: curMod.submods[modViewModSetSubModIndex].submodName));
                                    }
                                  } else {
                                    hoveringOnSubmod = true;
                                    previewModName = curMod.modName;
                                    for (var path in curMod.previewImages) {
                                      previewImages.add(PreviewImageStack(
                                          imagePath: path,
                                          overlayText: curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                              ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                              : curMod.modName));
                                    }
                                    for (var path in curMod.previewVideos) {
                                      previewImages.add(PreviewVideoStack(
                                          videoPath: path,
                                          overlayText: curMod.submods.indexWhere((element) => element.previewVideos.contains(path)) != -1
                                              ? curMod.submods[curMod.submods.indexWhere((element) => element.previewVideos.contains(path))].submodName
                                              : curMod.modName));
                                    }
                                  }
                                } else {
                                  hoveringOnSubmod = false;
                                  previewModName = '';
                                  previewImages.clear();
                                  // videoPlayer.remove(0);
                                }
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                  //color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(width: curMod.isNew ? 2 : 1, color: curMod.isNew ? Colors.amber : Theme.of(context).primaryColorLight),
                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                  child: AdvanceExpansionTile(
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
                                              Text(curMod.modName,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: curMod.applyStatus ? Theme.of(context).colorScheme.primary : null)),
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
                                                              )
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
                                                              child: Text(
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
                                                              )
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
                                              style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                                return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                              }), shape: MaterialStateProperty.resolveWith((states) {
                                                return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                                              })),
                                              menuChildren: [
                                                // rename
                                                MenuItemButton(
                                                  leadingIcon: const Icon(
                                                    Icons.edit_note,
                                                  ),
                                                  child: Text(curLangText!.uiRename),
                                                  onPressed: () async {
                                                    String newName = await modsRenameDialog(context, curMod.location, curMod.submods.first.location);
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
                                                      await modSetLoader();
                                                      saveSetListToJson();
                                                      saveModdedItemListToJson();
                                                      setState(() {});
                                                    }
                                                  },
                                                ),

                                                // open in file explorer
                                                MenuItemButton(
                                                  leadingIcon: const Icon(
                                                    Icons.folder_open_outlined,
                                                  ),
                                                  child: Text(curLangText!.uiOpenInFileExplorer),
                                                  onPressed: () async => await launchUrl(Uri.file(curMod.location)),
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
                                                  onPressed:
                                                      curMod.applyStatus || curMod.submods.first.location == curMod.location && Directory(curMod.location).listSync().whereType<Directory>().isNotEmpty
                                                          ? null
                                                          : () async {
                                                              bool deleteConfirm = await modDeletionDialog(context, curMod.modName);
                                                              if (deleteConfirm) {
                                                                if (modViewItem!.mods.length < 2) {
                                                                  deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                    String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                    modViewCate!.items.remove(modViewItem);
                                                                    modViewItem = null;
                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                        context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
                                                                    previewModName = '';
                                                                    previewImages.clear();
                                                                    saveModdedItemListToJson();
                                                                    setState(() {});
                                                                  });
                                                                } else {
                                                                  deleteModFromModMan(curMod.location, modViewItem!.location).then((value) {
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
                                                                        context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                              spacing: 5,
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
                                                          message: '${curLangText!.uiRemove} ${curMod.submods.first.submodName} ${curLangText!.uiFromTheGame}',
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
                                                                    if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                      curMod.submods.first.applyStatus = false;
                                                                    }
                                                                    if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                      curMod.applyStatus = false;
                                                                    }
                                                                    if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                      modViewItem!.applyStatus = false;
                                                                    }

                                                                    filesRestoredMessage(context, curMod.submods.first.modFiles, unappliedModFiles);
                                                                    appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                    isModViewModsRemoving = false;
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
                                                          message: '${curLangText!.uiApply} ${curMod.submods.first.submodName} ${curLangText!.uiToTheGame}',
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
                                                                  if (removeBoundaryRadiusOnModsApply) {
                                                                    removeBoundaryOnModsApply(context, curMod.submods.first).then((value) async {
                                                                      await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods.first);
                                                                      setState(() {});
                                                                    });
                                                                  } else {
                                                                    await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods.first);
                                                                    setState(() {});
                                                                  }
                                                                }
                                                                setState(() {});
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                                                    style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                                      return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                    }), shape: MaterialStateProperty.resolveWith((states) {
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
                                                        child: curActiveLang == 'JP'
                                                            ? Text(
                                                                curMod.submods.first.isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                              )
                                                            : Text(
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
                                                        alignmentOffset: const Offset(0, 8),
                                                        menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curMod.submods.first),
                                                        leadingIcon: const Icon(
                                                          Icons.list_alt_outlined,
                                                        ),
                                                        child: Text(curLangText!.uiAddToModSets),
                                                      ),

                                                      // add or change cmx file
                                                      Visibility(
                                                          visible: curMod.submods.first.category == defaultCateforyDirs[1] ||
                                                              curMod.submods.first.category == defaultCateforyDirs[6] ||
                                                              curMod.submods.first.category == defaultCateforyDirs[11] ||
                                                              curMod.submods.first.category == defaultCateforyDirs[15] ||
                                                              curMod.submods.first.category == defaultCateforyDirs[16],
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

                                                      // rename
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.edit_note,
                                                        ),
                                                        child: Text(curLangText!.uiRename),
                                                        onPressed: () async {
                                                          String newName = await modsRenameDialog(context, curMod.location, curMod.submods.first.location);
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
                                                            await modSetLoader();
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
                                                        onPressed: () async => modsSwapperDialog(context, modViewItem!, curMod.submods.first),
                                                      ),

                                                      // open in file explorer
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.folder_open_outlined,
                                                        ),
                                                        child: Text(curLangText!.uiOpenInFileExplorer),
                                                        onPressed: () async => await launchUrl(Uri.file(curMod.submods.first.location)),
                                                      ),

                                                      // boundary
                                                      Visibility(
                                                        visible: curMod.submods.first.category == defaultCateforyDirs[1] ||
                                                            curMod.submods.first.category == defaultCateforyDirs[3] ||
                                                            curMod.submods.first.category == defaultCateforyDirs[4] ||
                                                            curMod.submods.first.category == defaultCateforyDirs[5] ||
                                                            curMod.submods.first.category == defaultCateforyDirs[15] ||
                                                            curMod.submods.first.category == defaultCateforyDirs[16],
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

                                                      //remove from set
                                                      Visibility(
                                                        visible: context.watch<StateProvider>().setsWindowVisible && curMod.submods.first.isSet,
                                                        child: MenuItemButton(
                                                          leadingIcon: const Icon(
                                                            Icons.delete_forever_outlined,
                                                          ),
                                                          onPressed: () {
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
                                                                    deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                      String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                      modViewCate!.items.remove(modViewItem);
                                                                      modViewItem = null;
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                          context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
                                                                      previewModName = '';
                                                                      previewImages.clear();
                                                                      saveModdedItemListToJson();
                                                                      setState(() {});
                                                                    });
                                                                  } else {
                                                                    deleteSubmodFromModMan(curMod.submods.first.location, curMod.location).then((value) {
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
                                                                          context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                              spacing: 5,
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
                                                if (modViewModSetSubModIndex != -1 && curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus == true) != -1)
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
                                                          message: '${curLangText!.uiRemove} ${curMod.submods[modViewModSetSubModIndex].submodName} ${curLangText!.uiFromTheGame}',
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
                                                                      bool status = await cmxModRemoval(
                                                                          curMod.submods[modViewModSetSubModIndex].cmxStartPos!, curMod.submods[modViewModSetSubModIndex].cmxEndPos!);
                                                                      if (status) {
                                                                        curMod.submods[modViewModSetSubModIndex].cmxApplied = false;
                                                                        curMod.submods[modViewModSetSubModIndex].cmxStartPos = -1;
                                                                        curMod.submods[modViewModSetSubModIndex].cmxEndPos = -1;
                                                                      }
                                                                    }
                                                                    if (curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                      curMod.submods[modViewModSetSubModIndex].applyStatus = false;
                                                                    }
                                                                    if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                      curMod.applyStatus = false;
                                                                    }
                                                                    if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                      modViewItem!.applyStatus = false;
                                                                    }

                                                                    filesRestoredMessage(context, curMod.submods[modViewModSetSubModIndex].modFiles, value);
                                                                    appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                    isModViewModsRemoving = false;
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

                                                if (modViewModSetSubModIndex != -1 && curMod.submods[modViewModSetSubModIndex].modFiles.indexWhere((element) => element.applyStatus == false) != -1)
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
                                                          message: '${curLangText!.uiApply} ${curMod.submods[modViewModSetSubModIndex].submodName} ${curLangText!.uiToTheGame}',
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
                                                                  if (removeBoundaryRadiusOnModsApply) {
                                                                    removeBoundaryOnModsApply(context, curMod.submods[modViewModSetSubModIndex]).then((value) async {
                                                                      await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]);
                                                                      setState(() {});
                                                                    });
                                                                  } else {
                                                                    await applyModsToTheGame(context, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]);
                                                                    setState(() {});
                                                                  }
                                                                }
                                                                setState(() {});
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                                                    style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                                      return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                    }), shape: MaterialStateProperty.resolveWith((states) {
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
                                                        child: curActiveLang == 'JP'
                                                            ? Text(
                                                                curMod.submods[modViewModSetSubModIndex].isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                              )
                                                            : Text(
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
                                                        alignmentOffset: const Offset(0, 8),
                                                        menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curMod.submods[modViewModSetSubModIndex]),
                                                        leadingIcon: const Icon(
                                                          Icons.list_alt_outlined,
                                                        ),
                                                        child: Text(curLangText!.uiAddToModSets),
                                                      ),

                                                      // add or change cmx file
                                                      Visibility(
                                                        visible: curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[1] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[6] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[11] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[15] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[16],
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
                                                            await modSetLoader();
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
                                                        onPressed: () async => modsSwapperDialog(context, modViewItem!, curMod.submods[modViewModSetSubModIndex]),
                                                      ),

                                                      // open in file explorer
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.folder_open_outlined,
                                                        ),
                                                        child: Text(curLangText!.uiOpenInFileExplorer),
                                                        onPressed: () async => await launchUrl(Uri.file(curMod.submods[modViewModSetSubModIndex].location)),
                                                      ),

                                                      // boundary
                                                      Visibility(
                                                        visible: curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[1] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[3] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[4] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[5] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[15] ||
                                                            curMod.submods[modViewModSetSubModIndex].category == defaultCateforyDirs[16],
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

                                                      // remove from modset
                                                      MenuItemButton(
                                                        leadingIcon: const Icon(
                                                          Icons.delete_forever_outlined,
                                                        ),
                                                        onPressed: () {
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
                                                                    deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                      String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                      modViewCate!.items.remove(modViewItem);
                                                                      modViewItem = null;
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                          context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
                                                                      previewModName = '';
                                                                      previewImages.clear();
                                                                      saveModdedItemListToJson();
                                                                      setState(() {});
                                                                    });
                                                                  } else {
                                                                    deleteSubmodFromModMan(curMod.submods[modViewModSetSubModIndex].location, curMod.location).then((value) {
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
                                                                          context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: curMod.submods.length,
                                          itemBuilder: (context, submodIndex) {
                                            var curSubmod = curMod.submods[submodIndex];
                                            return Visibility(
                                              visible: isFavListVisible && !isModViewFromApplied
                                                  ? curSubmod.isFavorite
                                                  : context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                                      ? curSubmod.isSet && curSubmod.setNames.contains(selectedModSetName)
                                                      : true,
                                              child: InkWell(
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
                                                  if (hovering && previewWindowVisible) {
                                                    hoveringOnSubmod = true;
                                                    previewModName = curSubmod.submodName;
                                                    previewImages.clear();
                                                    // videoPlayer.remove(0);
                                                    for (var path in curSubmod.previewImages) {
                                                      previewImages.add(PreviewImageStack(imagePath: path, overlayText: curSubmod.submodName));
                                                    }
                                                    for (var path in curSubmod.previewVideos) {
                                                      previewImages.add(PreviewVideoStack(videoPath: path, overlayText: curSubmod.submodName));
                                                    }
                                                  } else {
                                                    previewModName = curMod.modName;
                                                    hoveringOnSubmod = false;
                                                    for (var path in curMod.previewImages) {
                                                      previewImages.add(PreviewImageStack(
                                                          imagePath: path,
                                                          overlayText: curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                                              ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                                              : curMod.modName));
                                                    }
                                                    for (var path in curMod.previewVideos) {
                                                      previewImages.add(PreviewVideoStack(
                                                          videoPath: path,
                                                          overlayText: curMod.submods.indexWhere((element) => element.previewVideos.contains(path)) != -1
                                                              ? curMod.submods[curMod.submods.indexWhere((element) => element.previewVideos.contains(path))].submodName
                                                              : curMod.modName));
                                                    }
                                                  }
                                                  setState(() {});
                                                },
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
                                                          spacing: 5,
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
                                                                      message: '${curLangText!.uiRemove} ${curSubmod.submodName} ${curLangText!.uiFromTheGame}',
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
                                                                              if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                curSubmod.applyStatus = false;
                                                                              }
                                                                              if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                curMod.applyStatus = false;
                                                                              }
                                                                              if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                modViewItem!.applyStatus = false;
                                                                              }

                                                                              filesRestoredMessage(context, curSubmod.modFiles, value);
                                                                              appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                              isModViewModsRemoving = false;
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
                                                                      message: '${curLangText!.uiApply} ${curSubmod.submodName} ${curLangText!.uiToTheGame}',
                                                                      child: InkWell(
                                                                        onTap: () async {
                                                                          isModViewModsApplying = true;
                                                                          setState(() {});
                                                                          Future.delayed(Duration(milliseconds: applyButtonsDelay), () async {
                                                                            //apply mod files
                                                                            if (await originalFilesCheck(context, curSubmod.modFiles)) {
                                                                              //local original files backup
                                                                              //await localOriginalFilesBackup(curSubmod.modFiles);
                                                                              //apply auto radius removal if on
                                                                              if (removeBoundaryRadiusOnModsApply) {
                                                                                removeBoundaryOnModsApply(context, curSubmod).then((value) async {
                                                                                  await applyModsToTheGame(context, modViewItem!, curMod, curSubmod);
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                await applyModsToTheGame(context, modViewItem!, curMod, curSubmod);
                                                                                setState(() {});
                                                                              }
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

                                                            //More menu
                                                            MenuAnchor(
                                                                builder: (BuildContext context, MenuController controller, Widget? child) {
                                                                  return ModManTooltip(
                                                                    message: curLangText!.uiMore,
                                                                    child: InkWell(
                                                                      child: const Icon(
                                                                        Icons.more_vert,
                                                                      ),
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
                                                                style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                                                  return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                                                                }), shape: MaterialStateProperty.resolveWith((states) {
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
                                                                    child: curActiveLang == 'JP'
                                                                        ? Text(
                                                                            curSubmod.isFavorite ? curLangText!.uiRemoveFromFavList : curLangText!.uiAddToFavList,
                                                                          )
                                                                        : Text(
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
                                                                    alignmentOffset: const Offset(0, 8),
                                                                    menuChildren: modSetsMenuButtons(context, modViewItem!, curMod, curSubmod),
                                                                    leadingIcon: const Icon(
                                                                      Icons.list_alt_outlined,
                                                                    ),
                                                                    child: Text(curLangText!.uiAddToModSets),
                                                                  ),

                                                                  // add or change cmx file
                                                                  Visibility(
                                                                      visible: curSubmod.category == defaultCateforyDirs[1] ||
                                                                          curSubmod.category == defaultCateforyDirs[6] ||
                                                                          curSubmod.category == defaultCateforyDirs[11] ||
                                                                          curSubmod.category == defaultCateforyDirs[15] ||
                                                                          curSubmod.category == defaultCateforyDirs[16],
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
                                                                        await modSetLoader();
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
                                                                    onPressed: () async => modsSwapperDialog(context, modViewItem!, curSubmod),
                                                                  ),

                                                                  // open in file explorer
                                                                  MenuItemButton(
                                                                    leadingIcon: const Icon(
                                                                      Icons.folder_open_outlined,
                                                                    ),
                                                                    child: Text(curLangText!.uiOpenInFileExplorer),
                                                                    onPressed: () async => await launchUrl(Uri.file(curSubmod.location)),
                                                                  ),

                                                                  // boundary
                                                                  Visibility(
                                                                    visible: curSubmod.category == defaultCateforyDirs[1] ||
                                                                        curSubmod.category == defaultCateforyDirs[3] ||
                                                                        curSubmod.category == defaultCateforyDirs[4] ||
                                                                        curSubmod.category == defaultCateforyDirs[5] ||
                                                                        curSubmod.category == defaultCateforyDirs[15] ||
                                                                        curSubmod.category == defaultCateforyDirs[16],
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
                                                                        modsBoundaryEditHomePage(context, curSubmod);
                                                                      },
                                                                    ),
                                                                  ),

                                                                  //remove from set
                                                                  Visibility(
                                                                    visible: context.watch<StateProvider>().setsWindowVisible && curSubmod.isSet,
                                                                    child: MenuItemButton(
                                                                      leadingIcon: const Icon(
                                                                        Icons.delete_forever_outlined,
                                                                      ),
                                                                      onPressed: () {
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
                                                                                deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                                  String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                                  modViewCate!.items.remove(modViewItem);
                                                                                  modViewItem = null;
                                                                                  previewModName = '';
                                                                                  previewImages.clear();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                      '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                deleteSubmodFromModMan(curSubmod.location, curMod.location).then((value) {
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
                                                                                      '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                                        physics: const NeverScrollableScrollPhysics(),
                                                        itemCount: curSubmod.modFiles.length,
                                                        itemBuilder: (context, modFileIndex) {
                                                          var curModFile = curSubmod.modFiles[modFileIndex];
                                                          return Visibility(
                                                            visible: context.watch<StateProvider>().setsWindowVisible ? curModFile.isSet : true,
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
                                                                      message: '${curLangText!.uiApply} ${curModFile.modFileName} ${curLangText!.uiToTheGame}',
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
                                                                                List<ModFile> appliedModFiles = value;
                                                                                String fileAppliedText = '';
                                                                                for (var element in appliedModFiles) {
                                                                                  if (fileAppliedText.isEmpty) {
                                                                                    fileAppliedText = '${curLangText!.uiSuccessfullyApplied} ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                                  }
                                                                                  fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                }
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                    snackBarMessage(context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                appliedItemList = await appliedListBuilder(moddedItemsList);
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
                                                                      message: '${curLangText!.uiRemove} ${curModFile.modFileName} ${curLangText!.uiFromTheGame}',
                                                                      child: InkWell(
                                                                        child: const Icon(
                                                                          Icons.remove,
                                                                        ),
                                                                        onTap: () async {
                                                                          //status
                                                                          restoreOriginalFilesToTheGame(context, [curModFile]).then((value) async {
                                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                              curSubmod.applyStatus = false;
                                                                            }
                                                                            if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                              curMod.applyStatus = false;
                                                                            }
                                                                            if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                              modViewItem!.applyStatus = false;
                                                                            }

                                                                            filesRestoredMessage(context, [curModFile], value);
                                                                            appliedItemList = await appliedListBuilder(moddedItemsList);
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
                                                                      message: '${curLangText!.uiHoldToRemove} ${curModFile.modFileName} ${curLangText!.uiFromThisSet}',
                                                                      child: InkWell(
                                                                        onLongPress: () {
                                                                          removeModFileFromThisSet(selectedModSetName, modViewItem!, curMod, curSubmod, curModFile);
                                                                          saveSetListToJson();
                                                                          saveModdedItemListToJson();
                                                                          setState(() {});
                                                                        },
                                                                        child: const Icon(Icons.delete_forever_outlined),
                                                                      ),
                                                                    ),
                                                                  ),

                                                                  //Delete
                                                                  ModManTooltip(
                                                                    message: '${curLangText!.uiHoldToRemove} ${curModFile.modFileName} ${curLangText!.uiFromMM}',
                                                                    child: InkWell(
                                                                      onLongPress: curModFile.applyStatus
                                                                          ? null
                                                                          : () async {
                                                                              if (curSubmod.modFiles.length < 2 && curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                                deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                                  String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                                  modViewCate!.items.remove(modViewItem);
                                                                                  modViewItem = null;
                                                                                  previewModName = '';
                                                                                  previewImages.clear();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                      '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              } else {
                                                                                deleteModFileFromModMan(curModFile.location, curSubmod.location, curMod.location).then((value) {
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
                                                                                      '${curLangText!.uiSuccessfullyRemoved} $removedName ${curLangText!.uiFromMM}', 3000));
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
                                                            ),
                                                          );
                                                        })
                                                  ],
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
                        }))))
    ]);
  }

//APPLIED MOD LIST=====================================================================================================================================================================================
  Widget appliedModsView() {
    int totalModFilesInAppliedList = 0;
    for (var type in appliedItemList) {
      for (var cate in type.categories) {
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
                  onTap: appliedItemList.isEmpty
                      ? null
                      : () async {
                          if (selectedModFilesInAppliedList.isEmpty || selectedModFilesInAppliedList.length < totalModFilesInAppliedList) {
                            for (var type in appliedItemList) {
                              for (var cate in type.categories) {
                                for (var item in cate.items) {
                                  if (item.applyStatus) {
                                    for (var mod in item.mods) {
                                      if (mod.applyStatus) {
                                        for (var submod in mod.submods) {
                                          if (submod.applyStatus) {
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
                            : appliedItemList.isEmpty
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
                          color: appliedItemList.isEmpty ? Theme.of(context).disabledColor : null,
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
                        onLongPress: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                isModViewModsRemoving = true;
                                isModViewModsApplying = true;
                                setState(() {});
                                Future.delayed(Duration(milliseconds: applyButtonsDelay), () {
                                  reapplySelectedAppliedMods(context).then((value) {
                                    isModViewModsRemoving = false;
                                    isModViewModsApplying = false;
                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, value.first, value[1], 3000));
                                    setState(() {});
                                  });
                                });
                              },
                        child: Icon(
                          Icons.playlist_add,
                          color: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
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
                        onLongPress: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty
                            ? null
                            : () {
                                isModViewModsRemoving = true;
                                isModViewModsApplying = true;
                                setState(() {});
                                Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                  unapplySelectedAppliedMods(context).then((value) {
                                    isModViewModsRemoving = false;
                                    isModViewModsApplying = false;
                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, value.first, value[1], 3000));
                                    setState(() {});
                                  });
                                });
                              },
                        child: Icon(
                          Icons.playlist_remove,
                          color: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                        )),
                  ),
                ),
              ],
            ),
            //Add selected to mod set
            MenuAnchor(
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return ModManTooltip(
                    message: curLangText!.uiAddSelectedModsToModSets,
                    child: InkWell(
                      onTap: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty
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
                        color: appliedItemList.isEmpty || selectedModFilesInAppliedList.isEmpty ? Theme.of(context).disabledColor : null,
                      ),
                    ),
                  );
                },
                style: MenuStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8);
                }), shape: MaterialStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2)));
                })),
                menuChildren: modSetsMenuItemButtons(context, selectedModFilesInAppliedList))
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
      Expanded(
        child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                }
                return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
              }),
            ),
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const PageScrollPhysics(),
                padding: const EdgeInsets.only(right: 2),
                itemCount: appliedItemList.length,
                itemBuilder: (context, groupIndex) {
                  int cateListLength = appliedItemList[groupIndex].categories.where((element) => element.items.indexWhere((i) => i.applyStatus == true) != -1).length;
                  List<Category> cateList = appliedItemList[groupIndex].categories.where((element) => element.items.indexWhere((i) => i.applyStatus == true) != -1).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groupIndex != 0)
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
                          //color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            collapsedTextColor: Theme.of(context).colorScheme.primary,
                            collapsedIconColor: Theme.of(context).colorScheme.primary,
                            title: Text(appliedItemList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: defaultCategoryTypes.contains(appliedItemList[groupIndex].groupName) && curActiveLang == 'JP'
                                ? Text(defaultCategoryTypesJP[defaultCategoryTypes.indexOf(appliedItemList[groupIndex].groupName)])
                                : null,
                            initiallyExpanded: appliedItemList[groupIndex].expanded,
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
                                              Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                                      subtitle: defaultCateforyDirs.contains(curCategory.categoryName) && curActiveLang == 'JP'
                                          ? Text(defaultCateforyDirsJP[defaultCateforyDirs.indexOf(curCategory.categoryName)])
                                          : null,
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
                                              int totalModFiles = 0;
                                              int totalAppliedModFiles = 0;
                                              for (var mod in curMods) {
                                                for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                  allAppliedModFiles.add([]);
                                                  allAppliedModFiles.last.addAll(submod.modFiles);
                                                  applyingModNames.add('${mod.modName} > ${submod.submodName}');
                                                  allPreviewImages.addAll(submod.previewImages);
                                                  totalModFiles += submod.modFiles.length;
                                                  totalAppliedModFiles += submod.modFiles.where((element) => element.applyStatus).length;
                                                }
                                              }
                                              return InkResponse(
                                                highlightShape: BoxShape.rectangle,
                                                onTap: () => '',
                                                onSecondaryTap: () {
                                                  if (previewImages.isNotEmpty) {
                                                    previewDialogImages = previewImages.toList();
                                                    previewDialogModName = previewModName;
                                                    previewDialog(context);
                                                  }
                                                },
                                                onHover: (hovering) {
                                                  if (hovering) {
                                                    previewModName = curItem.itemName.replaceAll('_', '/');
                                                    hoveringOnSubmod = true;
                                                    for (var mod in curMods) {
                                                      for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                        for (var path in submod.previewImages) {
                                                          previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                        }
                                                      }
                                                    }
                                                    for (var mod in curMods) {
                                                      for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                        for (var path in submod.previewVideos) {
                                                          previewImages.add(PreviewVideoStack(videoPath: path, overlayText: submod.submodName));
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    hoveringOnSubmod = false;
                                                    previewModName = '';
                                                    previewImages.clear();
                                                    // videoPlayer.remove(0);
                                                  }
                                                  setState(() {});
                                                },
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
                                                                      : curItem.isNew
                                                                          ? Colors.amber
                                                                          : Theme.of(context).hintColor,
                                                                  width: curItem.isNew || curItem.applyStatus ? 3 : 1),
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
                                                                    curItem.itemName.replaceAll('_', '/'),
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
                                                                          message: '${curLangText!.uiOpen} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiInFileExplorer}',
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
                                                                              ? '${curLangText!.uiDeselect} ${applyingModNames[m]}'
                                                                              : '${curLangText!.uiSelect} ${applyingModNames[m]}',
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              if (modFilesInList(selectedModFilesInAppliedList, allAppliedModFiles[m])) {
                                                                                for (var modFile in allAppliedModFiles[m]) {
                                                                                  selectedModFilesInAppliedList.removeWhere((element) => element.location == modFile.location);
                                                                                }
                                                                              } else {
                                                                                selectedModFilesInAppliedList.addAll(allAppliedModFiles[m]);
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
                                                                                  message: '${curLangText!.uiRemove} ${applyingModNames[m]} ${curLangText!.uiFromTheGame}',
                                                                                  child: InkWell(
                                                                                    child: const Icon(
                                                                                      FontAwesomeIcons.squareMinus,
                                                                                    ),
                                                                                    onTap: () async {
                                                                                      isModViewModsRemoving = true;
                                                                                      setState(() {});
                                                                                      Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                                                                        restoreOriginalFilesToTheGame(context, allAppliedModFiles[m]).then((value) async {
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
                                                                                                submod.applyStatus = false;
                                                                                                submod.applyDate = DateTime(0);
                                                                                              }
                                                                                              if (submod.applyStatus) {
                                                                                                for (var path in submod.previewImages) {
                                                                                                  previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                                                                }
                                                                                                for (var path in submod.previewVideos) {
                                                                                                  previewImages.add(PreviewVideoStack(videoPath: path, overlayText: submod.submodName));
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
                                                                                          }

                                                                                          filesRestoredMessage(context, allAppliedModFiles[m], value);
                                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                          if (appliedItemList.isEmpty) {
                                                                                            previewModName = '';
                                                                                            previewImages.clear();

                                                                                            // videoPlayer.remove(0);
                                                                                          }
                                                                                          isModViewModsRemoving = false;
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
                                                                        if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1)
                                                                          ModManTooltip(
                                                                            message: '${curLangText!.uiApply} ${applyingModNames[m]} ${curLangText!.uiToTheGame}',
                                                                            child: InkWell(
                                                                              onTap: () async {
                                                                                //apply mod files
                                                                                if (await originalFilesCheck(context, allAppliedModFiles[m])) {
                                                                                  //local original files backup
                                                                                  //await localOriginalFilesBackup(allAppliedModFiles[m]);

                                                                                  modFilesApply(context, allAppliedModFiles[m]).then((value) async {
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
                                                                                      List<ModFile> appliedModFiles = value;
                                                                                      String fileAppliedText = '';
                                                                                      for (var element in appliedModFiles) {
                                                                                        if (fileAppliedText.isEmpty) {
                                                                                          fileAppliedText = '${curLangText!.uiSuccessfullyApplied} ${applyingModNames[m]}:\n';
                                                                                        }
                                                                                        fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                      }
                                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                          context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                      appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                    }

                                                                                    saveModdedItemListToJson();
                                                                                    setState(() {});
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
                                              );
                                            }),
                                      ]);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )),
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
          child: CarouselSlider(
            carouselController: previewCarouselController,
            options: CarouselOptions(
              aspectRatio: 2.0,
              viewportFraction: 1,
              enlargeCenterPage: true,
              scrollDirection: Axis.vertical,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              reverse: true,
              autoPlayInterval: previewImages.where((element) => element.toString().contains('PreviewVideoStack')).isNotEmpty ? const Duration(seconds: 5) : const Duration(seconds: 1),
              autoPlay: previewImages.length > 1 ? true : false,
            ),
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
      Expanded(
          child: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                  }
                  return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                }),
              ),
              child: SingleChildScrollView(
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: const PageScrollPhysics(),
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
                                                      message: '${curLangText!.uiRemoveAllModsIn} ${curSet.setName} ${curLangText!.uiFromTheGame}',
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
                                                                for (var mod in item.mods) {
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
                                                                      submod.applyStatus = false;
                                                                    }
                                                                    if (submod.applyStatus) {
                                                                      for (var path in submod.previewImages) {
                                                                        previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                                      }
                                                                      for (var path in submod.previewVideos) {
                                                                        previewImages.add(PreviewVideoStack(videoPath: path, overlayText: submod.submodName));
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
                                                                }
                                                              }

                                                              filesRestoredMessage(context, allAppliedModFiles, value);
                                                              appliedItemList = await appliedListBuilder(moddedItemsList);
                                                              if (appliedItemList.isEmpty) {
                                                                previewModName = '';
                                                                previewImages.clear();
                                                                // videoPlayer.remove(0);
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
                                            if (curSet.setItems
                                                    .indexWhere((element) => element.mods.where((e) => e.isSet && e.setNames.contains(curSet.setName) && e.applyStatus == false).isNotEmpty) !=
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
                                                      message: '${curLangText!.uiApplyAllModsIn} ${curSet.setName} ${curLangText!.uiToTheGame}',
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
                                                                    int curModIndex = curItem.mods.indexWhere((element) => element.isSet && element.setNames.contains(curSet.setName));
                                                                    int curSubModIndex =
                                                                        curItem.mods[curModIndex].submods.indexWhere((element) => element.isSet && element.setNames.contains(curSet.setName));
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
                                                                  }
                                                                  appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                  List<ModFile> appliedModFiles = value;
                                                                  String fileAppliedText = '';

                                                                  for (var element in appliedModFiles.where((e) => e.applyStatus)) {
                                                                    if (fileAppliedText.isEmpty) {
                                                                      fileAppliedText = '${curLangText!.uiSuccessfullyAppliedAllModsIn} ${curSet.setName}:\n';
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

                                            //Delete
                                            ModManTooltip(
                                              message: '${curLangText!.uiHoldToRemove} ${curSet.setName} ${curLangText!.uiFromMM}',
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
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      snackBarMessage(context, '${curLangText!.uiSuccess}!', '${curLangText!.uiSuccessfullyRemoved} $tempSetName ${curLangText!.uiFromMM}', 3000));
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
                                            itemCount: curSet.setItems.length,
                                            itemBuilder: (context, itemIndex) {
                                              var curItem = curSet.setItems[itemIndex];
                                              List<Mod> curMods = curItem.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName) && element.applyStatus).toList();
                                              List<List<ModFile>> allAppliedModFiles = [];
                                              List<String> applyingModNames = [];
                                              List<String> allPreviewImages = [];
                                              int totalModFiles = 0;
                                              int totalAppliedModFiles = 0;
                                              for (var mod in curMods) {
                                                for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                  allAppliedModFiles.add([]);
                                                  allAppliedModFiles.last.addAll(submod.modFiles);
                                                  applyingModNames.add('${mod.modName} > ${submod.submodName}');
                                                  allPreviewImages.addAll(submod.previewImages);
                                                  totalModFiles += submod.modFiles.length;
                                                  totalAppliedModFiles += submod.modFiles.where((element) => element.applyStatus).length;
                                                }
                                              }
                                              return InkResponse(
                                                highlightShape: BoxShape.rectangle,
                                                onTap: () => '',
                                                onSecondaryTap: () {
                                                  if (previewImages.isNotEmpty) {
                                                    previewDialogImages = previewImages.toList();
                                                    previewDialogModName = previewModName;
                                                    previewDialog(context);
                                                  }
                                                },
                                                onHover: (hovering) {
                                                  if (hovering && previewWindowVisible) {
                                                    hoveringOnSubmod = true;
                                                    previewModName = curItem.itemName.replaceAll('_', '/');
                                                    for (var mod in curMods) {
                                                      for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                        for (var path in submod.previewImages) {
                                                          previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                        }
                                                      }
                                                    }
                                                    for (var mod in curMods) {
                                                      for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                        for (var path in submod.previewVideos) {
                                                          previewImages.add(PreviewVideoStack(videoPath: path, overlayText: submod.submodName));
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    hoveringOnSubmod = false;
                                                    previewModName = '';
                                                    previewImages.clear();
                                                    // videoPlayer.remove(0);
                                                  }
                                                  setState(() {});
                                                },
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
                                                                      : curItem.isNew
                                                                          ? Colors.amber
                                                                          : Theme.of(context).hintColor,
                                                                  width: curItem.isNew || curItem.applyStatus ? 3 : 1),
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
                                                                    curItem.itemName.replaceAll('_', '/'),
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
                                                                          message: '${curLangText!.uiOpen} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiInFileExplorer}',
                                                                          child: InkWell(
                                                                            child: const Icon(Icons.folder_open),
                                                                            onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                          )),
                                                                      //remove from set
                                                                      ModManTooltip(
                                                                          message: '${curLangText!.uiHoldToRemove} ${curItem.itemName.replaceAll('_', '/')} ${curLangText!.uiFromThisSet}',
                                                                          child: InkWell(
                                                                            onLongPress: () {
                                                                              String tempItemName = curItem.itemName.replaceAll('_', '/');
                                                                              removeModSetNameFromItems(curSet.setName, [curItem]);
                                                                              modViewItem = null;
                                                                              curSet.setItems.remove(curItem);
                                                                              saveSetListToJson();
                                                                              saveModdedItemListToJson();
                                                                              ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, '${curLangText!.uiSuccess}!',
                                                                                  '${curLangText!.uiSuccessfullyRemoved} $tempItemName ${curLangText!.uiFrom} ${curSet.setName}', 3000));
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
                                                                                  message: '${curLangText!.uiRemove} ${applyingModNames[m]} ${curLangText!.uiFromTheGame}',
                                                                                  child: InkWell(
                                                                                    child: const Icon(
                                                                                      FontAwesomeIcons.squareMinus,
                                                                                    ),
                                                                                    onTap: () async {
                                                                                      isModViewModsRemoving = true;
                                                                                      setState(() {});
                                                                                      Future.delayed(Duration(milliseconds: unapplyButtonsDelay), () {
                                                                                        //status
                                                                                        restoreOriginalFilesToTheGame(context, allAppliedModFiles[m]).then((value) async {
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
                                                                                                submod.applyStatus = false;
                                                                                              }
                                                                                              if (submod.applyStatus) {
                                                                                                for (var path in submod.previewImages) {
                                                                                                  previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                                                                }
                                                                                                for (var path in submod.previewVideos) {
                                                                                                  previewImages.add(PreviewVideoStack(videoPath: path, overlayText: submod.submodName));
                                                                                                }
                                                                                              }
                                                                                            }
                                                                                            if (mod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                              mod.applyStatus = false;
                                                                                            }
                                                                                          }

                                                                                          if (curItem.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                                            curItem.applyStatus = false;
                                                                                          }

                                                                                          filesRestoredMessage(context, allAppliedModFiles[m], value);
                                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                          if (appliedItemList.isEmpty) {
                                                                                            previewModName = '';
                                                                                            previewImages.clear();
                                                                                            // videoPlayer.remove(0);
                                                                                          }

                                                                                          isModViewModsRemoving = false;
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
                                                                        if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1)
                                                                          ModManTooltip(
                                                                            message: '${curLangText!.uiApply} ${applyingModNames[m]} ${curLangText!.uiToTheGame}',
                                                                            child: InkWell(
                                                                              onTap: () async {
                                                                                //apply mod files
                                                                                if (await originalFilesCheck(context, allAppliedModFiles[m])) {
                                                                                  //local original files backup
                                                                                  //await localOriginalFilesBackup(allAppliedModFiles[m]);
                                                                                  modFilesApply(context, allAppliedModFiles[m]).then((value) async {
                                                                                    if (value.indexWhere((element) => element.applyStatus) != -1) {
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
                                                                                      List<ModFile> appliedModFiles = value;
                                                                                      String fileAppliedText = '';
                                                                                      for (var element in appliedModFiles) {
                                                                                        if (fileAppliedText.isEmpty) {
                                                                                          fileAppliedText = '${curLangText!.uiSuccessfullyApplied} ${applyingModNames[m]}:\n';
                                                                                        }
                                                                                        fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                      }
                                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                          context, '${curLangText!.uiSuccess}!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                      appliedItemList = await appliedListBuilder(moddedItemsList);
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
                                              );
                                            })
                                      ])))
                        ]);
                      }))))
    ]);
  }
}
