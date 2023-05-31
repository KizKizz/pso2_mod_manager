import 'dart:io';

import 'package:advance_expansion_tile/advance_expansion_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/classes/mod_set_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/fav_list.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/mod_set_functions.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/modfiles_unapply.dart';
import 'package:pso2_mod_manager/functions/new_cate_adder.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/functions/search_list_builder.dart';
import 'package:pso2_mod_manager/functions/show_hide_cates.dart';
import 'package:pso2_mod_manager/functions/unapply_all_mods.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
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

  String itemListAppBarName = 'Item List';
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

  @override
  void initState() {
    setState(() {});
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
                    curLangText!.loadingUIText,
                    style: const TextStyle(fontSize: 20),
                  ),
                if (listsReloading)
                  const Text(
                    'Reloading Mods',
                    style: TextStyle(fontSize: 20),
                  ),
                const SizedBox(
                  height: 20,
                ),
                const CircularProgressIndicator(),
              ],
            ),
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
              visible: !isCateTypeReordering && !isShowHideCates && searchTextController.value.text.isEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ModManTooltip(
                  message: isFavListVisible ? 'Back' : 'Show Favorite List',
                  child: InkWell(
                      onTap: () {
                        if (isFavListVisible) {
                          isFavListVisible = false;
                          itemListAppBarName = 'Item List';
                        } else {
                          isFavListVisible = true;
                          itemListAppBarName = 'Favorite Item List';
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
                    message: 'Unhide all categories',
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
                    message: isEmptyCatesHide ? 'Turn off auto hide empty categories' : 'Turn on auto hide empty categories',
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
            if (!isCateTypeReordering && !isFavListVisible && searchTextController.value.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ModManTooltip(
                  message: isShowHideCates ? 'Back' : 'Show/Hide categories',
                  child: InkWell(
                      onTap: isCatesReordering.indexWhere((element) => element) != -1
                          ? null
                          : () {
                              if (isShowHideCates) {
                                isShowHideCates = false;
                                itemListAppBarName = 'Item List';
                              } else {
                                isShowHideCates = true;
                                itemListAppBarName = 'Hidden Item List';
                              }
                              setState(() {});
                            },
                      child: Icon(
                        isShowHideCates ? Icons.arrow_back_ios_new : Icons.highlight_alt_rounded,
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
                        message: isCateTypeAscenAlpha ? 'Sort by name decending' : 'Sort by name ascending',
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
                    //Sort button
                    Visibility(
                      visible: !isFavListVisible && searchTextController.value.text.isEmpty,
                      child: ModManTooltip(
                        message: isCateTypeReordering ? 'Back' : 'Sort Item List',
                        child: InkWell(
                            onTap: isCatesReordering.indexWhere((element) => element) != -1
                                ? null
                                : () {
                                    if (isCateTypeReordering) {
                                      //Save to json
                                      saveModdedItemListToJson();
                                      isCateTypeReordering = false;
                                      itemListAppBarName = 'Item List';
                                    } else {
                                      isCateTypeReordering = true;
                                      itemListAppBarName = 'Sort Item List';
                                    }
                                    setState(() {});
                                  },
                            child: Icon(
                              !isCateTypeReordering ? Icons.sort_outlined : Icons.arrow_back_ios_new,
                              color: isCatesReordering.indexWhere((element) => element) != -1 ? Theme.of(context).disabledColor : null,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            //Add new cate group
            Visibility(
              visible: !isCateTypeReordering && !isShowHideCates && searchTextController.value.text.isEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: ModManTooltip(
                  message: 'Add new Category Group',
                  child: InkWell(
                      onTap: () async {
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
                      child: const Icon(
                        Icons.add_to_photos_outlined,
                        size: 20,
                      )),
                ),
              ),
            ),
          ],
          //Title
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                child: Text(itemListAppBarName),
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
                      hintText: 'Search for mods',
                      hintStyle: TextStyle(color: Theme.of(context).hintColor),
                      isCollapsed: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: 5, right: 5, bottom: 2),
                      suffixIconConstraints: const BoxConstraints(minWidth: 20, minHeight: 28),
                      suffixIcon: InkWell(
                        onTap: () {
                          searchTextController.clear();
                          searchedItemList.clear();
                          modViewItem = null;
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
                      padding: const EdgeInsets.only(left: 2),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: hiddenItemCategories.length,
                      itemBuilder: (context, groupIndex) {
                        List<Category> hiddenCateList = hiddenItemCategories[groupIndex].categories.toList();
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
                                        message: 'Unhide ${hiddenItemCategories[groupIndex].groupName}',
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
                                            height: 63,
                                            child: ListTile(
                                                onTap: () {},
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                                                tileColor: Colors.transparent,
                                                minVerticalPadding: 5,
                                                textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                                trailing: ModManTooltip(
                                                  message: 'Unhide ${curCategory.categoryName}',
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
                                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                          decoration: BoxDecoration(
                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                          ),
                                                          child: curCategory.items.length < 2
                                                              ? Text('${hiddenItemCategories[groupIndex].categories[categoryIndex].items.length}${curLangText!.itemLabelText}',
                                                                  style: const TextStyle(
                                                                    fontSize: 13,
                                                                  ))
                                                              : Text('${curCategory.items.length}${curLangText!.itemsLabelText}',
                                                                  style: const TextStyle(
                                                                    fontSize: 13,
                                                                  ))),
                                                    ),
                                                  ],
                                                )),
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
                  : isCateTypeReordering
                      //Redordering ItemList
                      ? ReorderableListView.builder(
                          padding: const EdgeInsets.only(left: 2, right: 1),
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
                          physics: const NeverScrollableScrollPhysics(),
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
                              padding: const EdgeInsets.only(left: 2),
                              physics: const NeverScrollableScrollPhysics(),
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
                                                      message: 'Remove ${moddedItemsList[groupIndex].groupName} from Favorite List',
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
                                                                        padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                        decoration: BoxDecoration(
                                                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                        ),
                                                                        child: curCategory.items.where((element) => element.isFavorite).length < 2
                                                                            ? Text('${curCategory.items.where((element) => element.isFavorite).length}${curLangText!.itemLabelText}',
                                                                                style: const TextStyle(
                                                                                  fontSize: 13,
                                                                                ))
                                                                            : Text('${curCategory.items.where((element) => element.isFavorite).length}${curLangText!.itemsLabelText}',
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
                                                                      message: 'Remove ${curCategory.categoryName} from Favorite List',
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
                                                                                      border: Border.all(color: curItem.isNew ? Colors.amber : Theme.of(context).hintColor),
                                                                                    ),
                                                                                    child: Image.file(
                                                                                      File(curItem.icon),
                                                                                      filterQuality: FilterQuality.none,
                                                                                      fit: BoxFit.fitWidth,
                                                                                    )),
                                                                              ),
                                                                              Expanded(
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      curItem.itemName,
                                                                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                    ),
                                                                                    Text(
                                                                                      curItem.mods.where((element) => element.isFavorite).length < 2
                                                                                          ? '${curItem.mods.where((element) => element.isFavorite).length} Mod'
                                                                                          : '${curItem.mods.where((element) => element.isFavorite).length} Mods',
                                                                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                    ),
                                                                                    Text(
                                                                                      '${curItem.mods.where((element) => element.applyStatus && element.isFavorite).length} Applied',
                                                                                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                    ),
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
                                                                                        message: 'Remove ${curItem.itemName} from Favorite List',
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
                                                                                          message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                                          child: InkWell(
                                                                                            child: const Icon(Icons.folder_open),
                                                                                            onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                          )),
                                                                                      //Delete
                                                                                      ModManTooltip(
                                                                                        message: 'Hold to remove ${curItem.itemName} from Mod Manager',
                                                                                        child: InkWell(
                                                                                          onLongPress: curItem.applyStatus
                                                                                              ? null
                                                                                              : () async {
                                                                                                  deleteItemFromModMan(curItem.location).then((value) {
                                                                                                    String removedName = '${curCategory.categoryName} > ${curItem.itemName}';
                                                                                                    if (modViewItem == curItem) {
                                                                                                      modViewItem = null;
                                                                                                    }
                                                                                                    curCategory.items.remove(curItem);
                                                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                        context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
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
                                    ),
                                  ],
                                );
                              },
                            )
                          : searchTextController.value.text.isNotEmpty
                              //Search Item List
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(left: 2),
                                  physics: const NeverScrollableScrollPhysics(),
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
                                                      visible: curCategory.visible && (curCategory.categoryName.contains(searchTextController.value.text.toLowerCase()) || itemMatchingNum > 0),
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
                                                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                          ),
                                                                          child: itemMatchingNum < 2
                                                                              ? Text('$itemMatchingNum${curLangText!.itemLabelText}',
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13,
                                                                                  ))
                                                                              : Text('$itemMatchingNum${curLangText!.itemsLabelText}',
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
                                                                      visible: curItem.itemName.contains(searchTextController.value.text.toLowerCase()) || modMatchingNum > 0,
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
                                                                                        border: Border.all(color: curItem.isNew ? Colors.amber : Theme.of(context).hintColor),
                                                                                      ),
                                                                                      child: Image.file(
                                                                                        File(curItem.icon),
                                                                                        filterQuality: FilterQuality.none,
                                                                                        fit: BoxFit.fitWidth,
                                                                                      )),
                                                                                ),
                                                                                Expanded(
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        curItem.itemName,
                                                                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      Text(
                                                                                        modMatchingNum < 2 ? '$modMatchingNum Mod' : '$modMatchingNum Mods',
                                                                                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                      ),
                                                                                      Text(
                                                                                        '${curItem.mods.where((element) => element.applyStatus && element.itemName.contains(searchTextController.value.text.toLowerCase())).length} Applied',
                                                                                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                      ),
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
                                                                                            message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                                            child: InkWell(
                                                                                              child: const Icon(Icons.folder_open),
                                                                                              onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                            )),
                                                                                        //Delete
                                                                                        ModManTooltip(
                                                                                          message: 'Hold to remove ${curItem.itemName} from Mod Manager',
                                                                                          child: InkWell(
                                                                                            onLongPress: curItem.applyStatus
                                                                                                ? null
                                                                                                : () async {
                                                                                                    deleteItemFromModMan(curItem.location).then((value) {
                                                                                                      String removedName = '${curCategory.categoryName} > ${curItem.itemName}';
                                                                                                      if (modViewItem == curItem) {
                                                                                                        modViewItem = null;
                                                                                                      }
                                                                                                      curCategory.items.remove(curItem);
                                                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                          context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
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
                                  padding: const EdgeInsets.only(left: 2),
                                  physics: const NeverScrollableScrollPhysics(),
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
                                                                  message: 'Hold to delete ${moddedItemsList[groupIndex].groupName} from Mod Manager',
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
                                                                  message: isCatesAscenAlpha[groupIndex] ? 'Sort by descending name order' : 'Sort by ascending name order',
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
                                                                  message: 'Sort categories in this group',
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
                                                                  message: 'Add a new Category to ${moddedItemsList[groupIndex].groupName}',
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
                                                  trailing: !isCatesReordering[groupIndex]
                                                      ? null
                                                      : ModManTooltip(
                                                          message: 'Back',
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
                                                                height: 63,
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
                                                                              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                              ),
                                                                              child: curCategory.items.length < 2
                                                                                  ? Text('${moddedItemsList[groupIndex].categories[categoryIndex].items.length}${curLangText!.itemLabelText}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 13,
                                                                                      ))
                                                                                  : Text('${curCategory.items.length}${curLangText!.itemsLabelText}',
                                                                                      style: const TextStyle(
                                                                                        fontSize: 13,
                                                                                      ))),
                                                                        ),
                                                                      ],
                                                                    )),
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
                                                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                                                decoration: BoxDecoration(
                                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                ),
                                                                                child: curCategory.items.length < 2
                                                                                    ? Text('${moddedItemsList[groupIndex].categories[categoryIndex].items.length}${curLangText!.itemLabelText}',
                                                                                        style: const TextStyle(
                                                                                          fontSize: 13,
                                                                                        ))
                                                                                    : Text('${curCategory.items.length}${curLangText!.itemsLabelText}',
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
                                                                            ModManTooltip(
                                                                              message: 'Hide ${curCategory.categoryName} from Item List',
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
                                                                                message: 'Hold to remove ${curCategory.categoryName} from ${moddedItemsList[groupIndex].groupName}',
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
                                                                                            border: Border.all(color: curItem.isNew ? Colors.amber : Theme.of(context).hintColor),
                                                                                          ),
                                                                                          child: Image.file(
                                                                                            File(curItem.icon),
                                                                                            filterQuality: FilterQuality.none,
                                                                                            fit: BoxFit.fitWidth,
                                                                                          )),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            curItem.itemName,
                                                                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                                                          ),
                                                                                          Text(
                                                                                            curItem.mods.length < 2 ? '${curItem.mods.length} Mod' : '${curItem.mods.length} Mods',
                                                                                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                          ),
                                                                                          Text(
                                                                                            '${curItem.mods.where((element) => element.applyStatus == true).length} Applied',
                                                                                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                          ),
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
                                                                                                message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                                                child: InkWell(
                                                                                                  child: const Icon(Icons.folder_open),
                                                                                                  onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                                                )),
                                                                                            //Delete
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 5),
                                                                                              child: ModManTooltip(
                                                                                                message: 'Hold to remove ${curItem.itemName} from Mod Manager',
                                                                                                child: InkWell(
                                                                                                  onLongPress: curItem.applyStatus
                                                                                                      ? null
                                                                                                      : () async {
                                                                                                          deleteItemFromModMan(curItem.location).then((value) {
                                                                                                            String removedName = '${curCategory.categoryName} > ${curItem.itemName}';
                                                                                                            if (modViewItem == curItem) {
                                                                                                              modViewItem = null;
                                                                                                            }
                                                                                                            curCategory.items.remove(curItem);
                                                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                                context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
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
                                ),
            ),
          ),
        ),
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
                message: 'Clear Available Mods view',
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
                        border: Border.all(color: modViewItem!.isNew ? Colors.amber : Theme.of(context).hintColor),
                      ),
                      child: Image.file(
                        File(modViewItem!.icon),
                        filterQuality: FilterQuality.none,
                        fit: BoxFit.fitWidth,
                      )),
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
                            ? Text(modViewItem!.itemName)
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(curLangText!.availableModsHeaderText),
                              ),
                        if (modViewItem != null)
                          const Divider(
                            endIndent: 5,
                            height: 5,
                            thickness: 1,
                          ),
                        //normal
                        if (modViewItem != null && !isFavListVisible && searchTextController.value.text.isEmpty)
                          Text(
                            modViewItem!.mods.length < 2 ? '${modViewItem!.mods.length} Mod' : '${modViewItem!.mods.length} Mods',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        //fav
                        if (modViewItem != null && isFavListVisible && searchTextController.value.text.isEmpty && !isModViewFromApplied)
                          Text(
                            modViewItem!.mods.where((element) => element.isFavorite).length < 2
                                ? '${modViewItem!.mods.where((element) => element.isFavorite).length} Mod'
                                : '${modViewItem!.mods.where((element) => element.isFavorite).length} Mods',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        //searching
                        if (modViewItem != null && searchTextController.value.text.isNotEmpty && !isModViewFromApplied)
                          Text(
                            itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text) < 2
                                ? '${itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text)} Mod'
                                : '${itemModSearchMatchesCheck(modViewItem!, searchTextController.value.text)} Mods',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        if (modViewItem != null && appBarAppliedModNames.isNotEmpty)
                          for (int i = 0; i < appBarAppliedModNames.length; i++)
                            Text(
                              'Applied: ${appBarAppliedModNames[i]}',
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
                        //padding: const EdgeInsets.symmetric(horizontal: 1),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modViewItem!.mods.length,
                        itemBuilder: (context, modIndex) {
                          modViewETKeys.add(GlobalKey());
                          var curMod = modViewItem!.mods[modIndex];
                          if (isModViewItemListExpanded.isEmpty || isModViewItemListExpanded.length != modViewItem!.mods.length) {
                            isModViewItemListExpanded = List.generate(modViewItem!.mods.length, (index) => false);
                          }

                          return Visibility(
                            visible: isFavListVisible && !isModViewFromApplied
                                ? curMod.isFavorite
                                : searchTextController.value.text.toLowerCase().isNotEmpty && !isModViewFromApplied
                                    ? curMod.modName.toLowerCase().contains(searchTextController.value.text.toLowerCase())
                                    : context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                        ? curMod.isSet && curMod.setNames.contains(selectedModSetName)
                                        : true,
                            child: InkWell(
                              //Hover for preview
                              onTap: () {},
                              onHover: (hovering) {
                                if (hovering) {
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
                                        listIndex: previewImages.length + 1,
                                        videoPath: path,
                                        overlayText: curMod.submods.indexWhere((element) => element.previewVideos.contains(path)) != -1
                                            ? curMod.submods[curMod.submods.indexWhere((element) => element.previewVideos.contains(path))].submodName
                                            : curMod.modName));
                                  }
                                } else {
                                  hoveringOnSubmod = false;
                                  previewModName = '';
                                  previewImages.clear();
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
                                      side: BorderSide(color: curMod.isNew ? Colors.amber : Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
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
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  context.watch<StateProvider>().setsWindowVisible && !isModViewFromApplied
                                                      ? Text(
                                                          curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length < 2
                                                              ? '${curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} Variant'
                                                              : '${curMod.submods.where((element) => element.isSet && element.setNames.contains(selectedModSetName)).length} Variants',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          ))
                                                      : Text(curMod.submods.length < 2 ? '${curMod.submods.length} Variant' : '${curMod.submods.length} Variants',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (curMod.submods.length == 1 && !isModViewItemListExpanded[modIndex])
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              runAlignment: WrapAlignment.center,
                                              spacing: 5,
                                              children: [
                                                //Add-Remove button
                                                if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                  ModManTooltip(
                                                    message: 'Remove ${curMod.submods.first.submodName} from the game',
                                                    child: InkWell(
                                                        child: const Icon(
                                                          FontAwesomeIcons.squareMinus,
                                                        ),
                                                        onTap: () async {
                                                          //status
                                                          String filesUnapplied = '';
                                                          //check backups
                                                          bool allBkFilesFound = true;
                                                          for (var modFile in curMod.submods.first.modFiles) {
                                                            for (var bkFile in modFile.bkLocations) {
                                                              if (!File(bkFile).existsSync()) {
                                                                allBkFilesFound = false;
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                break;
                                                              }
                                                            }
                                                          }
                                                          if (allBkFilesFound) {
                                                            modFilesUnapply(context, curMod.submods.first.modFiles).then((value) async {
                                                              List<ModFile> unappliedModFiles = value;
                                                              if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                curMod.submods.first.applyStatus = false;
                                                              }
                                                              if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                curMod.applyStatus = false;
                                                              }
                                                              if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                modViewItem!.applyStatus = false;
                                                              }

                                                              for (var element in unappliedModFiles) {
                                                                if (filesUnapplied.isEmpty) {
                                                                  filesUnapplied = 'Sucessfully removed ${curMod.modName} > ${curMod.submods.first.submodName}:\n';
                                                                }
                                                                filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                              }
                                                              ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                              appliedItemList = await appliedListBuilder(moddedItemsList);

                                                              saveModdedItemListToJson();
                                                              setState(() {});
                                                            });
                                                          }
                                                        }),
                                                  ),
                                                if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                  ModManTooltip(
                                                    message: 'Apply ${curMod.submods.first.submodName} to the game',
                                                    child: InkWell(
                                                      child: const Icon(
                                                        FontAwesomeIcons.squarePlus,
                                                      ),
                                                      onTap: () async {
                                                        bool allOGFilesFound = true;
                                                        //get og file paths
                                                        for (var modFile in curMod.submods.first.modFiles) {
                                                          modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                          if (modFile.ogLocations.isEmpty) {
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${modFile.modFileName}', 3000));
                                                            allOGFilesFound = false;
                                                            break;
                                                          }
                                                        }
                                                        //apply mod files
                                                        if (allOGFilesFound) {
                                                          modFilesApply(context, curMod.submods.first.modFiles).then((value) async {
                                                            if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus) != -1) {
                                                              curMod.submods.first.applyDate = DateTime.now();
                                                              modViewItem!.applyDate = DateTime.now();
                                                              curMod.applyDate = DateTime.now();
                                                              curMod.submods.first.applyStatus = true;
                                                              curMod.submods.first.isNew = false;
                                                              curMod.applyStatus = true;
                                                              curMod.isNew = false;
                                                              modViewItem!.applyStatus = true;
                                                              modViewItem!.isNew = false;
                                                              List<ModFile> appliedModFiles = value;
                                                              String fileAppliedText = '';
                                                              for (var element in appliedModFiles) {
                                                                if (fileAppliedText.isEmpty) {
                                                                  fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curMod.submods.first.submodName}:\n';
                                                                }
                                                                fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                              }
                                                              ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                              appliedItemList = await appliedListBuilder(moddedItemsList);
                                                            }

                                                            saveModdedItemListToJson();
                                                            setState(() {});
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),

                                                //Favorite
                                                ModManTooltip(
                                                  message: curMod.submods.first.isFavorite
                                                      ? 'Remove ${curMod.submods.first.submodName} from Favorite List'
                                                      : 'Add ${curMod.submods.first.submodName} to Favorite List',
                                                  child: InkWell(
                                                    child: Icon(curMod.submods.first.isFavorite ? FontAwesomeIcons.heartCircleMinus : FontAwesomeIcons.heartCirclePlus, size: 18),
                                                    onTap: () async {
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
                                                ),
                                                //Open folder
                                                ModManTooltip(
                                                  message: 'Open ${curMod.submods.first.submodName} in File Explorer',
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.folder_open_outlined,
                                                    ),
                                                    onTap: () async => await launchUrl(Uri.file(curMod.submods.first.location)),
                                                  ),
                                                ),
                                                //Delete
                                                ModManTooltip(
                                                  message: 'Hold to remove ${curMod.submods.first.submodName} from Mod Manager',
                                                  child: InkWell(
                                                    onLongPress: curMod.applyStatus
                                                        ? null
                                                        : () async {
                                                            if (curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                              deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                modViewCate!.items.remove(modViewItem);
                                                                modViewItem = null;
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                previewModName = '';
                                                                previewImages.clear();
                                                                setState(() {});
                                                              });
                                                            } else {
                                                              deleteModFromModMan(curMod.submods.first.location, curMod.location).then((value) {
                                                                String removedName = '${curMod.modName} > ${curMod.submods.first.submodName}';
                                                                curMod.submods.remove(curMod.submods.first);
                                                                if (curMod.submods.isEmpty) {
                                                                  modViewItem!.mods.remove(curMod);
                                                                }
                                                                if (modViewItem!.mods.isEmpty) {
                                                                  modViewCate!.items.remove(modViewItem);
                                                                }
                                                                if (modViewItem!.mods.isEmpty) {
                                                                  modViewCate!.items.remove(modViewItem);
                                                                  modViewItem = null;
                                                                }
                                                                previewModName = '';
                                                                previewImages.clear();
                                                                ScaffoldMessenger.of(context)
                                                                    .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                setState(() {});
                                                              });
                                                            }
                                                          },
                                                    child: Icon(
                                                      Icons.delete_forever_outlined,
                                                      color: curMod.applyStatus ? Theme.of(context).disabledColor : null,
                                                    ),
                                                  ),
                                                ),
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
                                                onHover: (hovering) {
                                                  if (hovering) {
                                                    hoveringOnSubmod = true;
                                                    previewModName = curSubmod.submodName;
                                                    previewImages.clear();
                                                    for (var path in curSubmod.previewImages) {
                                                      previewImages.add(PreviewImageStack(imagePath: path, overlayText: curSubmod.submodName));
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
                                                        style: TextStyle(color: curSubmod.applyStatus ? Theme.of(context).colorScheme.primary : null),
                                                      )),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 5),
                                                        child: Wrap(
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          runAlignment: WrapAlignment.center,
                                                          spacing: 5,
                                                          children: [
                                                            //Apply button in submod
                                                            //remove button
                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                              ModManTooltip(
                                                                message: 'Remove ${curSubmod.submodName} from the game',
                                                                child: InkWell(
                                                                  child: const Icon(
                                                                    FontAwesomeIcons.squareMinus,
                                                                  ),
                                                                  onTap: () async {
                                                                    //status
                                                                    String filesUnapplied = '';
                                                                    //check backups
                                                                    bool allBkFilesFound = true;
                                                                    for (var modFile in curSubmod.modFiles) {
                                                                      for (var bkFile in modFile.bkLocations) {
                                                                        if (!File(bkFile).existsSync()) {
                                                                          allBkFilesFound = false;
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                          break;
                                                                        }
                                                                      }
                                                                    }
                                                                    if (allBkFilesFound) {
                                                                      modFilesUnapply(context, curSubmod.modFiles).then((value) async {
                                                                        List<ModFile> unappliedModFiles = value;
                                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                          curSubmod.applyStatus = false;
                                                                        }
                                                                        if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                          curMod.applyStatus = false;
                                                                        }
                                                                        if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                          modViewItem!.applyStatus = false;
                                                                        }
                                                                        for (var element in unappliedModFiles) {
                                                                          if (filesUnapplied.isEmpty) {
                                                                            filesUnapplied = 'Sucessfully removed ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                          }
                                                                          filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                        }

                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                        appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        saveModdedItemListToJson();
                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                              ModManTooltip(
                                                                message: 'Apply ${curSubmod.submodName} to the game',
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    bool allOGFilesFound = true;
                                                                    //get og file paths
                                                                    for (var modFile in curSubmod.modFiles) {
                                                                      modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                                      if (modFile.ogLocations.isEmpty) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${modFile.modFileName}', 3000));
                                                                        allOGFilesFound = false;
                                                                        break;
                                                                      }
                                                                    }
                                                                    //apply mod files
                                                                    if (allOGFilesFound) {
                                                                      modFilesApply(context, curSubmod.modFiles).then((value) async {
                                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) != -1) {
                                                                          curSubmod.applyDate = DateTime.now();
                                                                          modViewItem!.applyDate = DateTime.now();
                                                                          curMod.applyDate = DateTime.now();
                                                                          curSubmod.applyStatus = true;
                                                                          curSubmod.isNew = false;
                                                                          curMod.applyStatus = true;
                                                                          curMod.isNew = false;
                                                                          modViewItem!.applyStatus = true;
                                                                          modViewItem!.isNew = false;
                                                                          List<ModFile> appliedModFiles = value;
                                                                          String fileAppliedText = '';
                                                                          for (var element in appliedModFiles) {
                                                                            if (fileAppliedText.isEmpty) {
                                                                              fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                            }
                                                                            fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                          }
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        }

                                                                        saveModdedItemListToJson();
                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                  child: const Icon(
                                                                    FontAwesomeIcons.squarePlus,
                                                                  ),
                                                                ),
                                                              ),

                                                            //Favorite
                                                            ModManTooltip(
                                                              message: curSubmod.isFavorite ? 'Remove ${curSubmod.submodName} from Favorite List' : 'Add ${curSubmod.submodName} to Favorite List',
                                                              child: InkWell(
                                                                child: Icon(
                                                                  curSubmod.isFavorite ? FontAwesomeIcons.heartCircleMinus : FontAwesomeIcons.heartCirclePlus,
                                                                  size: 18,
                                                                ),
                                                                onTap: () async {
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
                                                            ),
                                                            //Open folder
                                                            ModManTooltip(
                                                              message: 'Open ${curSubmod.submodName} in File Explorer',
                                                              child: InkWell(
                                                                child: const Icon(
                                                                  Icons.folder_open_outlined,
                                                                ),
                                                                onTap: () async => await launchUrl(Uri.file(curSubmod.location)),
                                                              ),
                                                            ),
                                                            //Delete
                                                            ModManTooltip(
                                                              message: 'Hold to remove ${curSubmod.submodName} from Mod Manager',
                                                              child: InkWell(
                                                                onLongPress: curSubmod.applyStatus
                                                                    ? null
                                                                    : () async {
                                                                        if (curMod.submods.length < 2 && modViewItem!.mods.length < 2) {
                                                                          deleteItemFromModMan(modViewItem!.location).then((value) {
                                                                            String removedName = '${modViewCate!.categoryName} > ${modViewItem!.itemName}';
                                                                            modViewCate!.items.remove(modViewItem);
                                                                            modViewItem = null;
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                            setState(() {});
                                                                          });
                                                                        } else {
                                                                          deleteModFromModMan(curSubmod.location, curMod.location).then((value) {
                                                                            String removedName = '${curMod.modName} > ${curSubmod.submodName}';
                                                                            curMod.submods.remove(curSubmod);
                                                                            if (curMod.submods.isEmpty) {
                                                                              modViewItem!.mods.remove(curMod);
                                                                            }
                                                                            if (modViewItem!.mods.isEmpty) {
                                                                              modViewCate!.items.remove(modViewItem);
                                                                            }
                                                                            if (modViewItem!.mods.isEmpty) {
                                                                              modViewCate!.items.remove(modViewItem);
                                                                              modViewItem = null;
                                                                            }
                                                                            previewModName = '';
                                                                            previewImages.clear();
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      },
                                                                child: Icon(
                                                                  Icons.delete_forever_outlined,
                                                                  color: curSubmod.applyStatus ? Theme.of(context).disabledColor : null,
                                                                ),
                                                              ),
                                                            ),
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
                                                          return ListTile(
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
                                                                    message: 'Apply ${curModFile.modFileName} to the game',
                                                                    child: InkWell(
                                                                      child: const Icon(
                                                                        Icons.add,
                                                                      ),
                                                                      onTap: () async {
                                                                        bool allOGFilesFound = true;
                                                                        //get og file paths
                                                                        curModFile.ogLocations = ogIcePathsFetcher(curModFile.modFileName);
                                                                        if (curModFile.ogLocations.isEmpty) {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${curModFile.modFileName}', 3000));
                                                                          allOGFilesFound = false;
                                                                        }
                                                                        //apply mod files
                                                                        if (allOGFilesFound) {
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
                                                                              modViewItem!.isNew = false;
                                                                              List<ModFile> appliedModFiles = value;
                                                                              String fileAppliedText = '';
                                                                              for (var element in appliedModFiles) {
                                                                                if (fileAppliedText.isEmpty) {
                                                                                  fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                                }
                                                                                fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                              }
                                                                              ScaffoldMessenger.of(context)
                                                                                  .showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                              appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                            }

                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),
                                                                if (curModFile.applyStatus == true)
                                                                  ModManTooltip(
                                                                    message: 'Remove ${curModFile.modFileName} from the game',
                                                                    child: InkWell(
                                                                      child: const Icon(
                                                                        Icons.remove,
                                                                      ),
                                                                      onTap: () async {
                                                                        //status
                                                                        String filesUnapplied = '';
                                                                        //check backups
                                                                        bool allBkFilesFound = true;
                                                                        for (var bkFile in curModFile.bkLocations) {
                                                                          if (!File(bkFile).existsSync()) {
                                                                            allBkFilesFound = false;
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${curModFile.modFileName}', 3000));

                                                                            break;
                                                                          }
                                                                        }
                                                                        if (allBkFilesFound) {
                                                                          modFilesUnapply(context, [curModFile]).then((value) async {
                                                                            List<ModFile> unappliedModFiles = value;
                                                                            if (curSubmod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                              curSubmod.applyStatus = false;
                                                                            }
                                                                            if (curMod.submods.indexWhere((element) => element.applyStatus) == -1) {
                                                                              curMod.applyStatus = false;
                                                                            }
                                                                            if (modViewItem!.mods.indexWhere((element) => element.applyStatus) == -1) {
                                                                              modViewItem!.applyStatus = false;
                                                                            }
                                                                            for (var element in unappliedModFiles) {
                                                                              if (filesUnapplied.isEmpty) {
                                                                                filesUnapplied = 'Sucessfully removed ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                              }
                                                                              filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                            }
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                            appliedItemList = await appliedListBuilder(moddedItemsList);

                                                                            saveModdedItemListToJson();
                                                                            setState(() {});
                                                                          });
                                                                        }
                                                                      },
                                                                    ),
                                                                  ),

                                                                //Delete
                                                                ModManTooltip(
                                                                  message: 'Hold to remove ${curModFile.modFileName} from Mod Manager',
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
                                                                                ScaffoldMessenger.of(context)
                                                                                    .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                              });
                                                                              setState(() {});
                                                                            } else {
                                                                              deleteModFileFromModMan(curModFile.location, curSubmod.location, curMod.location).then((value) {
                                                                                String removedName = '${curMod.modName} > ${curSubmod.submodName} > $curModFile';
                                                                                curSubmod.modFiles.remove(curModFile);

                                                                                if (curSubmod.modFiles.isEmpty) {
                                                                                  curMod.submods.remove(curSubmod);
                                                                                }
                                                                                if (curMod.submods.isEmpty) {
                                                                                  modViewItem!.mods.remove(curMod);
                                                                                }
                                                                                if (modViewItem!.mods.isEmpty) {
                                                                                  modViewCate!.items.remove(modViewItem);
                                                                                }
                                                                                if (modViewItem!.mods.isEmpty) {
                                                                                  modViewCate!.items.remove(modViewItem);
                                                                                  modViewItem = null;
                                                                                }
                                                                                previewModName = '';
                                                                                previewImages.clear();
                                                                                ScaffoldMessenger.of(context)
                                                                                    .showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $removedName from Mod Manager', 3000));
                                                                                setState(() {});
                                                                              });
                                                                            }
                                                                          },
                                                                    child: Icon(
                                                                      Icons.delete_forever_outlined,
                                                                      color: curModFile.applyStatus ? Theme.of(context).disabledColor : null,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            title: Text(
                                                              curModFile.modFileName,
                                                              style: TextStyle(color: curModFile.applyStatus ? Theme.of(context).colorScheme.primary : null),
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
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, spacing: 10, children: [
              //Remove all mods from game
              ModManTooltip(
                message: 'Hold to remove all applied mods from the game',
                child: InkWell(
                    onLongPress: appliedItemList.isEmpty
                        ? null
                        : () {
                            unapplyAllMods(context);
                            setState(() {});
                          },
                    child: Icon(
                      Icons.playlist_remove,
                      color: appliedItemList.isEmpty ? Theme.of(context).disabledColor : null,
                    )),
              ),
              //Add to mod set
              ModManTooltip(
                message: 'Add all applied mods to Mod Sets',
                child: InkWell(
                    onTap: appliedItemList.isEmpty
                        ? null
                        : () {
                            isModSetAdding = true;
                            isModViewListHidden = true;
                            Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
                            setState(() {});
                          },
                    child: Icon(
                      FontAwesomeIcons.folderPlus,
                      size: 18,
                      color: appliedItemList.isEmpty ? Theme.of(context).disabledColor : null,
                    )),
              ),
            ]),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 5),
          child: Text(curLangText!.appliedModsHeadersText),
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
              padding: const EdgeInsets.only(right: 2),
              physics: const NeverScrollableScrollPhysics(),
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
                                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Theme.of(context).highlightColor),
                                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: curCategory.items.length < 2
                                                      ? Text(
                                                          '${appliedItemList[groupIndex].categories[categoryIndex].items.where((element) => element.applyStatus).length}${curLangText!.itemLabelText}',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          ))
                                                      : Text('${curCategory.items.where((element) => element.applyStatus).length}${curLangText!.itemsLabelText}',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          ))),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
                                              onHover: (hovering) {
                                                if (hovering) {
                                                  previewModName = curItem.itemName;
                                                  hoveringOnSubmod = true;
                                                  for (var mod in curMods) {
                                                    for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                      for (var path in submod.previewImages) {
                                                        previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  hoveringOnSubmod = false;
                                                  previewModName = '';
                                                  previewImages.clear();
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
                                                            border: Border.all(color: curItem.isNew ? Colors.amber : Theme.of(context).hintColor),
                                                          ),
                                                          child: Image.file(
                                                            File(curItem.icon),
                                                            filterQuality: FilterQuality.none,
                                                            fit: BoxFit.fitWidth,
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
                                                              Text(
                                                                curItem.itemName,
                                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 5),
                                                                child: Wrap(
                                                                  crossAxisAlignment: WrapCrossAlignment.center,
                                                                  runAlignment: WrapAlignment.center,
                                                                  children: [
                                                                    ModManTooltip(
                                                                        message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
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
                                                                      if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == true) != -1)
                                                                        ModManTooltip(
                                                                          message: 'Remove ${applyingModNames[m]} from the game',
                                                                          child: InkWell(
                                                                            child: const Icon(
                                                                              FontAwesomeIcons.squareMinus,
                                                                            ),
                                                                            onTap: () async {
                                                                              //status
                                                                              String filesUnapplied = '';
                                                                              //check backups
                                                                              bool allBkFilesFound = true;
                                                                              for (var modFile in allAppliedModFiles[m]) {
                                                                                for (var bkFile in modFile.bkLocations) {
                                                                                  if (!File(bkFile).existsSync()) {
                                                                                    allBkFilesFound = false;
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                                    break;
                                                                                  }
                                                                                }
                                                                              }
                                                                              if (allBkFilesFound) {
                                                                                modFilesUnapply(context, allAppliedModFiles[m]).then((value) async {
                                                                                  List<ModFile> unappliedModFiles = value;
                                                                                  previewImages.clear();
                                                                                  for (var mod in curMods) {
                                                                                    for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                                                      if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                        submod.applyStatus = false;
                                                                                        submod.applyDate = DateTime(0);
                                                                                      }
                                                                                      if (submod.applyStatus) {
                                                                                        for (var path in submod.previewImages) {
                                                                                          previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
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
                                                                                  for (var element in unappliedModFiles) {
                                                                                    if (filesUnapplied.isEmpty) {
                                                                                      filesUnapplied = 'Sucessfully removed ${applyingModNames[m]}:\n';
                                                                                    }
                                                                                    filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                  }
                                                                                  ScaffoldMessenger.of(context)
                                                                                      .showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                                  appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                  if (appliedItemList.isEmpty) {
                                                                                    previewModName = '';
                                                                                    previewImages.clear();
                                                                                  }

                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      //Apply button in submod
                                                                      if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1)
                                                                        ModManTooltip(
                                                                          message: 'Apply ${applyingModNames[m]} to the game',
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              bool allOGFilesFound = true;
                                                                              //get og file paths
                                                                              for (var modFile in allAppliedModFiles[m]) {
                                                                                modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                                                if (modFile.ogLocations.isEmpty) {
                                                                                  ScaffoldMessenger.of(context)
                                                                                      .showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${modFile.modFileName}', 3000));
                                                                                  allOGFilesFound = false;
                                                                                  break;
                                                                                }
                                                                              }
                                                                              //apply mod files
                                                                              if (allOGFilesFound) {
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
                                                                                    curItem.isNew = false;
                                                                                    curItem.applyDate = DateTime.now();
                                                                                    List<ModFile> appliedModFiles = value;
                                                                                    String fileAppliedText = '';
                                                                                    for (var element in appliedModFiles) {
                                                                                      if (fileAppliedText.isEmpty) {
                                                                                        fileAppliedText = 'Sucessfully applied ${applyingModNames[m]}:\n';
                                                                                      }
                                                                                      fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                    }
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                    appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                  }

                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              }
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
                                                            '$totalAppliedModFiles / $totalModFiles Files applied',
                                                            //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
                                                          ),
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
          child: Text(previewModName.isNotEmpty ? 'Preview: $previewModName' : curLangText!.previewHeaderText),
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
                child: const Text(
                  'No preview available',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      if ((previewImages.isNotEmpty && !hoveringOnSubmod) || (previewImages.isNotEmpty && hoveringOnSubmod))
        Expanded(
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: 2.0,
              viewportFraction: 1,
              enlargeCenterPage: true,
              scrollDirection: Axis.vertical,
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              reverse: true,
              autoPlayInterval: const Duration(seconds: 1),
              autoPlay: previewImages.length > 1 ? true : false,
              onPageChanged: (index, reason) {
                if (previewImages[index].toString().contains('PreviewVideoStack')) {}
              },
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
                message: 'Create new Mod Set',
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
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 5, right: 5),
              child: Text('Mod Sets'),
            ),
            //Search
            Expanded(
                child: TextField(
              controller: newSetTextController,
              maxLines: 1,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  hintText: 'Enter new Mod Set name',
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
                    padding: const EdgeInsets.only(left: 2),
                    physics: const NeverScrollableScrollPhysics(),
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
                                            Text(curSet.setName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                              child: Container(
                                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Theme.of(context).highlightColor),
                                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                  ),
                                                  child: curSet.setItems.length < 2
                                                      ? Text('${curSet.setItems.length}${curLangText!.itemLabelText}',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          ))
                                                      : Text('${curSet.setItems.length}${curLangText!.itemsLabelText}',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                          ))),
                                            ),
                                          ],
                                        ),
                                        Wrap(crossAxisAlignment: WrapCrossAlignment.center, runAlignment: WrapAlignment.center, spacing: 5, children: [
                                          if (curSet.setItems.indexWhere((element) => element.applyStatus == true) != -1)
                                            ModManTooltip(
                                              message: 'Remove all mods in ${curSet.setName} from the game',
                                              child: InkWell(
                                                child: const Icon(
                                                  FontAwesomeIcons.squareMinus,
                                                ),
                                                onTap: () async {
                                                  //status
                                                  String filesUnapplied = '';
                                                  //check backups
                                                  bool allBkFilesFound = true;
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

                                                  for (var modFile in allAppliedModFiles) {
                                                    for (var bkFile in modFile.bkLocations) {
                                                      if (!File(bkFile).existsSync()) {
                                                        allBkFilesFound = false;
                                                        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                        break;
                                                      }
                                                    }
                                                  }
                                                  if (allBkFilesFound) {
                                                    modFilesUnapply(context, allAppliedModFiles).then((value) async {
                                                      List<ModFile> unappliedModFiles = value;
                                                      previewImages.clear();
                                                      for (var item in curSet.setItems) {
                                                        for (var mod in item.mods) {
                                                          for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                            if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                              submod.applyStatus = false;
                                                            }
                                                            if (submod.applyStatus) {
                                                              for (var path in submod.previewImages) {
                                                                previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
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

                                                      for (var element in unappliedModFiles) {
                                                        if (filesUnapplied.isEmpty) {
                                                          filesUnapplied = 'Sucessfully removed all mods in ${curSet.setName}:\n';
                                                        }
                                                        if (!filesUnapplied.contains('${element.itemName} > ${element.modName} > ${element.submodName}\n')) {
                                                          filesUnapplied += '${element.itemName} > ${element.modName} > ${element.submodName}\n';
                                                        }
                                                      }
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                      appliedItemList = await appliedListBuilder(moddedItemsList);
                                                      if (appliedItemList.isEmpty) {
                                                        previewModName = '';
                                                        previewImages.clear();
                                                      }

                                                      saveModdedItemListToJson();
                                                      setState(() {});
                                                    });
                                                  }
                                                },
                                              ),
                                            ),

                                          //Apply button in submod
                                          if (curSet.setItems.indexWhere((element) => element.applyStatus == false) != -1)
                                            ModManTooltip(
                                              message: 'Apply all mods in ${curSet.setName} to the game',
                                              child: InkWell(
                                                onTap: () async {
                                                  bool allOGFilesFound = true;
                                                  //get og file paths
                                                  List<ModFile> allAppliedModFiles = [];
                                                  for (var item in curSet.setItems.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                    for (var mod in item.mods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                      for (var submod in mod.submods.where((element) => element.isSet && element.setNames.contains(curSet.setName))) {
                                                        allAppliedModFiles.addAll(submod.modFiles.where((element) => !element.applyStatus));
                                                      }
                                                    }
                                                  }

                                                  for (var modFile in allAppliedModFiles) {
                                                    modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                    if (modFile.ogLocations.isEmpty) {
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${modFile.modFileName}', 3000));
                                                      allOGFilesFound = false;
                                                      break;
                                                    }
                                                  }
                                                  //apply mod files
                                                  if (allOGFilesFound) {
                                                    modFilesApply(context, allAppliedModFiles).then((value) async {
                                                      if (allAppliedModFiles.indexWhere((element) => element.applyStatus) != -1) {
                                                        for (var curItem in curSet.setItems) {
                                                          int curModIndex = curItem.mods.indexWhere((element) => element.isSet && element.setNames.contains(curSet.setName));
                                                          int curSubModIndex = curItem.mods[curModIndex].submods.indexWhere((element) => element.isSet && element.setNames.contains(curSet.setName));
                                                          curItem.mods[curModIndex].submods[curSubModIndex].applyStatus = true;
                                                          curItem.mods[curModIndex].submods[curSubModIndex].isNew = false;
                                                          curItem.mods[curModIndex].submods[curSubModIndex].applyDate = DateTime.now();
                                                          curItem.mods[curModIndex].applyStatus = true;
                                                          curItem.mods[curModIndex].isNew = false;
                                                          curItem.mods[curModIndex].applyDate = DateTime.now();

                                                          curItem.applyStatus = true;
                                                          curItem.isNew = false;
                                                          curItem.applyDate = DateTime.now();
                                                        }
                                                        List<ModFile> appliedModFiles = value;
                                                        String fileAppliedText = '';

                                                        for (var element in appliedModFiles.where((e) => e.applyStatus)) {
                                                          if (fileAppliedText.isEmpty) {
                                                            fileAppliedText = 'Sucessfully applied all mods in ${curSet.setName}:\n';
                                                          }
                                                          if (!fileAppliedText.contains('${element.itemName} > ${element.modName} > ${element.submodName}\n')) {
                                                            fileAppliedText += '${element.itemName} > ${element.modName} > ${element.submodName}\n';
                                                          }
                                                        }
                                                        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                        appliedItemList = await appliedListBuilder(moddedItemsList);
                                                      }

                                                      saveModdedItemListToJson();
                                                      setState(() {});
                                                    });
                                                  }
                                                },
                                                child: const Icon(
                                                  FontAwesomeIcons.squarePlus,
                                                ),
                                              ),
                                            ),
                                          ModManTooltip(
                                            message: 'Add to this set',
                                            child: InkWell(
                                                onTap: !isModSetAdding
                                                    ? null
                                                    : () {
                                                        curSet.setItems = itemsFromAppliedListFetch(appliedItemList);
                                                        setModSetNameToItems(curSet.setName, curSet.setItems);
                                                        isModSetAdding = false;
                                                        saveModdedItemListToJson();
                                                        saveSetListToJson();
                                                        setState(() {});
                                                      },
                                                child: Icon(
                                                  FontAwesomeIcons.folderPlus,
                                                  size: 20,
                                                  color: !isModSetAdding ? Theme.of(context).disabledColor : null,
                                                )),
                                          ),
                                          //Delete
                                          ModManTooltip(
                                            message: 'Hold to remove ${curSet.setName} from Mod Manager',
                                            child: InkWell(
                                              onLongPress: curSet.setItems.where((element) => element.applyStatus).isNotEmpty
                                                  ? null
                                                  : () async {
                                                      String tempSetName = curSet.setName;
                                                      removeModSetNameFromItems(curSet.setName, curSet.setItems);
                                                      modSetList.remove(curSet);
                                                      modViewItem = null;
                                                      saveSetListToJson();
                                                      saveModdedItemListToJson();
                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(context, 'Success!', 'Succesfully removed $tempSetName from Mod Manager', 3000));
                                                      setState(() {});
                                                    },
                                              child: Icon(
                                                Icons.folder_delete,
                                                color: curSet.setItems.where((element) => element.applyStatus).isNotEmpty ? Theme.of(context).disabledColor : null,
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
                                              onHover: (hovering) {
                                                if (hovering) {
                                                  hoveringOnSubmod = true;
                                                  previewModName = curItem.itemName;
                                                  for (var mod in curMods) {
                                                    for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                      for (var path in submod.previewImages) {
                                                        previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
                                                      }
                                                    }
                                                  }
                                                } else {
                                                  hoveringOnSubmod = false;
                                                  previewModName = '';
                                                  previewImages.clear();
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
                                                            border: Border.all(color: curItem.isNew ? Colors.amber : Theme.of(context).hintColor),
                                                          ),
                                                          child: Image.file(
                                                            File(curItem.icon),
                                                            filterQuality: FilterQuality.none,
                                                            fit: BoxFit.fitWidth,
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
                                                              Text(
                                                                curItem.itemName,
                                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                                                                        message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                        child: InkWell(
                                                                          child: const Icon(Icons.folder_open),
                                                                          onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                        )),
                                                                    //delete
                                                                    ModManTooltip(
                                                                        message: 'Hold to remove ${curItem.itemName} from this set',
                                                                        child: InkWell(
                                                                          onLongPress: curItem.applyStatus
                                                                              ? null
                                                                              : () {
                                                                                  String tempItemName = curItem.itemName;
                                                                                  removeModSetNameFromItems(curSet.setName, [curItem]);
                                                                                  modViewItem = null;
                                                                                  curSet.setItems.remove(curItem);
                                                                                  saveSetListToJson();
                                                                                  saveModdedItemListToJson();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                                                      snackBarMessage(context, 'Success!', 'Succesfully removed $tempItemName from ${curSet.setName}', 3000));
                                                                                  setState(() {});
                                                                                },
                                                                          child: Icon(Icons.delete_forever_outlined, color: curItem.applyStatus ? Theme.of(context).disabledColor : null),
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
                                                                        ModManTooltip(
                                                                          message: 'Remove ${applyingModNames[m]} from the game',
                                                                          child: InkWell(
                                                                            child: const Icon(
                                                                              FontAwesomeIcons.squareMinus,
                                                                            ),
                                                                            onTap: () async {
                                                                              //status
                                                                              String filesUnapplied = '';
                                                                              //check backups
                                                                              bool allBkFilesFound = true;
                                                                              for (var modFile in allAppliedModFiles[m]) {
                                                                                for (var bkFile in modFile.bkLocations) {
                                                                                  if (!File(bkFile).existsSync()) {
                                                                                    allBkFilesFound = false;
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(snackBarMessage(context, 'Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                                    break;
                                                                                  }
                                                                                }
                                                                              }
                                                                              if (allBkFilesFound) {
                                                                                modFilesUnapply(context, allAppliedModFiles[m]).then((value) async {
                                                                                  List<ModFile> unappliedModFiles = value;
                                                                                  previewImages.clear();
                                                                                  for (var mod in curMods) {
                                                                                    for (var submod in mod.submods.where((element) => element.applyStatus)) {
                                                                                      if (submod.modFiles.indexWhere((element) => element.applyStatus) == -1) {
                                                                                        submod.applyStatus = false;
                                                                                      }
                                                                                      if (submod.applyStatus) {
                                                                                        for (var path in submod.previewImages) {
                                                                                          previewImages.add(PreviewImageStack(imagePath: path, overlayText: submod.submodName));
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
                                                                                  for (var element in unappliedModFiles) {
                                                                                    if (filesUnapplied.isEmpty) {
                                                                                      filesUnapplied = 'Sucessfully removed ${applyingModNames[m]}:\n';
                                                                                    }
                                                                                    filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                  }
                                                                                  ScaffoldMessenger.of(context)
                                                                                      .showSnackBar(snackBarMessage(context, 'Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                                  appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                  if (appliedItemList.isEmpty) {
                                                                                    previewModName = '';
                                                                                    previewImages.clear();
                                                                                  }

                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      //Apply button in submod
                                                                      if (allAppliedModFiles[m].indexWhere((element) => element.applyStatus == false) != -1)
                                                                        ModManTooltip(
                                                                          message: 'Apply ${applyingModNames[m]} to the game',
                                                                          child: InkWell(
                                                                            onTap: () async {
                                                                              bool allOGFilesFound = true;
                                                                              //get og file paths
                                                                              for (var modFile in allAppliedModFiles[m]) {
                                                                                modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                                                if (modFile.ogLocations.isEmpty) {
                                                                                  ScaffoldMessenger.of(context)
                                                                                      .showSnackBar(snackBarMessage(context, 'Error', 'Could not find original file for ${modFile.modFileName}', 3000));
                                                                                  allOGFilesFound = false;
                                                                                  break;
                                                                                }
                                                                              }
                                                                              //apply mod files
                                                                              if (allOGFilesFound) {
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
                                                                                    curItem.isNew = false;
                                                                                    curItem.applyDate = DateTime.now();
                                                                                    List<ModFile> appliedModFiles = value;
                                                                                    String fileAppliedText = '';
                                                                                    for (var element in appliedModFiles) {
                                                                                      if (fileAppliedText.isEmpty) {
                                                                                        fileAppliedText = 'Sucessfully applied ${applyingModNames[m]}:\n';
                                                                                      }
                                                                                      fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                                    }
                                                                                    ScaffoldMessenger.of(context)
                                                                                        .showSnackBar(snackBarMessage(context, 'Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                                    appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                                  }

                                                                                  saveModdedItemListToJson();
                                                                                  setState(() {});
                                                                                });
                                                                              }
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
                                                            '$totalAppliedModFiles / $totalModFiles Files applied',
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
                    }),
              )))
    ]);
  }
}
