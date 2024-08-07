import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/enum_classes.dart';
import 'package:pso2_mod_manager/functions/apply_all_available_mods.dart';
import 'package:pso2_mod_manager/functions/cate_mover.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/json_write.dart';
import 'package:pso2_mod_manager/functions/new_cate_adder.dart';
import 'package:pso2_mod_manager/functions/search_list_builder.dart';
import 'package:pso2_mod_manager/functions/show_hide_cates.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/homepage/home_page.dart';
import 'package:pso2_mod_manager/homepage/mod_view.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_translation_helper.dart';
import 'package:pso2_mod_manager/widgets/item_icons_carousel.dart';
import 'package:pso2_mod_manager/widgets/snackbar.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';

bool isFavListVisible = false;

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  List<bool> cateTypeButtonsVisible = [];
  List<List<List<bool>>> itemButtonsVisible = [];
  List<List<List<bool>>> itemClicked = [];
  bool isCateTypeReordering = false;
  bool isCateTypeAscenAlpha = false;
  List<bool> isCatesReordering = [];
  List<bool> isCateTypeListExpanded = [];
  List<bool> isCatesAscenAlpha = [];
  bool isShowHideCates = false;
  List<List<bool>> cateButtonsVisible = [];
  List<String> searchResultCateTypes = [];
  ItemListSort _itemListSortState = ItemListSort.none;

  @override
  Widget build(BuildContext context) {
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
                        // modViewListVisible = false;
                        modViewItem.value = null;
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
                                // modViewListVisible = false;
                                modViewItem.value = null;
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
                      // modViewListVisible = false;
                      modViewItem.value = null;
                    } else {
                      // searchedItemList.clear();
                      searchResultCateTypes.clear();
                      // modViewListVisible = false;
                      modViewItem.value = null;
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
              ? SuperListView.builder(
                  physics: const SuperRangeMaintainingScrollPhysics(),
                  // cacheExtent: double.maxFinite,
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
                            SuperListView.builder(
                              shrinkWrap: true,
                              physics: const SuperRangeMaintainingScrollPhysics(),
                              // cacheExtent: double.maxFinite,
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
                      physics: const SuperRangeMaintainingScrollPhysics(),
                      // cacheExtent: double.maxFinite,
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
                  : SuperListView.builder(
                      physics: const SuperRangeMaintainingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 2),
                      // cacheExtent: double.maxFinite,
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
                                                              // modViewListVisible = false;
                                                              modViewItem.value = null;
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
                                              physics: const SuperRangeMaintainingScrollPhysics(),
                                              // cacheExtent: double.maxFinite,
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
                                          child: SuperListView.builder(
                                            shrinkWrap: true,
                                            // physics: const NeverScrollableScrollPhysics(),
                                            // cacheExtent: double.maxFinite,
                                            primary: false,
                                            itemCount: moddedItemsList[groupIndex].categories.length,
                                            itemBuilder: (context, categoryIndex) {
                                              var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];

                                              return ListenableBuilder(
                                                  listenable: curCategory,
                                                  builder: (BuildContext context, Widget? child) {
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
                                                                      padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13, right: 2.5),
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
                                                                    Visibility(
                                                                      visible: curCategory.items.where((element) => element.isNew).isNotEmpty,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(top: 18, bottom: 13, right: 2.5),
                                                                        child: Container(
                                                                          padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                          decoration: BoxDecoration(
                                                                            border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                          ),
                                                                          child: Text(
                                                                            '${curCategory.items.where((element) => element.isNew).length} ${curLangText!.uiNew}',
                                                                            style: const TextStyle(fontSize: 13, color: Colors.amber),
                                                                          ),
                                                                        ),
                                                                      ),
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
                                                                                  // modViewListVisible = false;
                                                                                  modViewItem.value = null;
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
                                                              SuperListView.builder(
                                                                  shrinkWrap: true,
                                                                  // physics: const NeverScrollableScrollPhysics(),
                                                                  // cacheExtent: double.maxFinite,
                                                                  primary: false,
                                                                  itemCount: curCategory.items.length,
                                                                  // prototypeItem: const SizedBox(height: 84),
                                                                  itemBuilder: (context, itemIndex) {
                                                                    var curItem = curCategory.items[itemIndex];
                                                                    if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty ||
                                                                        itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                      itemButtonsVisible[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                    }
                                                                    if (itemClicked[groupIndex][categoryIndex].isEmpty || itemClicked[groupIndex][categoryIndex].length != curCategory.items.length) {
                                                                      itemClicked[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                    }

                                                                    return ListenableBuilder(
                                                                      listenable: curItem,
                                                                      builder: (BuildContext context, Widget? child) {
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
                                                                              color: itemClicked[groupIndex][categoryIndex][itemIndex]
                                                                                  ? Theme.of(context).highlightColor.withOpacity(0.2)
                                                                                  : Colors.transparent,
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
                                                                                              spacing: 2.5,
                                                                                              runSpacing: 2.5,
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
                                                                                                      : searchTextController.value.text.isNotEmpty &&
                                                                                                              itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase()) <= 0
                                                                                                          ? Text(
                                                                                                              curItem.mods.length < 2
                                                                                                                  ? '${curItem.mods.length} ${curLangText!.uiMod}'
                                                                                                                  : '${curItem.mods.length} ${curLangText!.uiMods}',
                                                                                                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                                                                                            )
                                                                                                          : searchTextController.value.text.isNotEmpty &&
                                                                                                                  itemModSearchMatchesCheck(curItem, searchTextController.value.text.toLowerCase()) > 0
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
                                                                                                Visibility(
                                                                                                  visible: curItem.mods.where((element) => element.isNew == true).isNotEmpty,
                                                                                                  child: Container(
                                                                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                                                                                    decoration: BoxDecoration(
                                                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      curItem.mods.where((element) => element.isNew == true).length < 2
                                                                                                          ? '${curItem.mods.where((element) => element.isNew == true).length} ${curLangText!.uiNewMod}'
                                                                                                          : '${curItem.mods.where((element) => element.isNew == true).length} ${curLangText!.uiNewMods}',
                                                                                                      style: const TextStyle(color: Colors.amber),
                                                                                                    ),
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
                                                                                                            if (modViewItem.value == curItem) {
                                                                                                              // modViewListVisible = false;
                                                                                                              modViewItem.value = null;
                                                                                                            }
                                                                                                            curCategory.items.remove(curItem);
                                                                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage(
                                                                                                                context,
                                                                                                                '${curLangText!.uiSuccess}!',
                                                                                                                uiInTextArg(curLangText!.uiSuccessfullyRemovedXFromModMan, removedName),
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
                                                                                  itemClicked = List.generate(moddedItemsList.length, (index) => []);
                                                                                  itemClicked[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                                                                  itemClicked[groupIndex][categoryIndex] = List.generate(curCategory.items.length, (index) => false);
                                                                                  itemClicked[groupIndex][categoryIndex][itemIndex] = true;
                                                                                  // for (var element in modViewETKeys) {
                                                                                  //   element.currentState?.collapse();
                                                                                  // }
                                                                                  // modViewETKeys.clear();
                                                                                  isModViewListHidden = false;
                                                                                  isModViewFromApplied = false;
                                                                                  modViewCate = curCategory;
                                                                                  modViewItem.value = curItem;
                                                                                  // modViewListVisible = true;
                                                                                  setState(() {});
                                                                                },
                                                                                onHover: (value) {
                                                                                  if (value) {
                                                                                    itemButtonsVisible[groupIndex][categoryIndex][itemIndex] = true;
                                                                                  } else {
                                                                                    itemButtonsVisible[groupIndex][categoryIndex][itemIndex] = false;
                                                                                  }
                                                                                  setState(() {});
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  }),
                                                            ]),
                                                      ),
                                                    );
                                                  });
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
}
