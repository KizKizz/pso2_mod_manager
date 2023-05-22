import 'dart:io';

import 'package:advance_expansion_tile/advance_expansion_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/category_class.dart';
import 'package:pso2_mod_manager/classes/category_type_class.dart';
import 'package:pso2_mod_manager/classes/item_class.dart';
import 'package:pso2_mod_manager/classes/mod_file_class.dart';
import 'package:pso2_mod_manager/functions/applied_list_builder.dart';
import 'package:pso2_mod_manager/functions/delete_from_mm.dart';
import 'package:pso2_mod_manager/functions/modfiles_apply.dart';
import 'package:pso2_mod_manager/functions/modfiles_unapply.dart';
import 'package:pso2_mod_manager/functions/og_ice_paths_fetcher.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
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

  String previewModName = '';
  bool hoveringOnSubmod = false;
  Item? modViewItem;
  List<Widget> previewImages = [];
  double headersOpacityValue = 0.7;
  double headersExtraOpacityValue = 0.3;
  List<List<List<bool>>> itemButtonsVisible = [];
  bool isApplyingModFiles = false;
  bool isCateTypeReordering = false;
  List<bool> isCatesReordering = [];
  List<bool> isCateTypeListExpanded = [];

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
        if (!context.watch<StateProvider>().setsWindowVisible) modsView(),
        if (context.watch<StateProvider>().setsWindowVisible) setList(),
        if (context.watch<StateProvider>().setsWindowVisible) modInSetList(),
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

    return context.watch<StateProvider>().languageReload
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  curLangText!.loadingUIText,
                  style: const TextStyle(fontSize: 20),
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

//=====================================================================================================================================================================================
  Widget itemsView() {
    var searchBoxLeftPadding = 10;
    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Tooltip(
              message: isCateTypeReordering ? 'Save' : 'Sort Category Groups',
              height: 25,
              textStyle: const TextStyle(fontSize: 14),
              decoration: BoxDecoration(
                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                  border: Border.all(color: Theme.of(context).primaryColorLight),
                  borderRadius: const BorderRadius.all(Radius.circular(2))),
              waitDuration: const Duration(milliseconds: 500),
              child: InkWell(
                  onTap: isCatesReordering.indexWhere((element) => element) != -1
                      ? null
                      : () {
                          if (isCateTypeReordering) {
                            isCateTypeReordering = false;
                          } else {
                            isCateTypeReordering = true;
                          }
                          setState(() {});
                        },
                  child: Icon(
                    !isCateTypeReordering ? Icons.sort_outlined : Icons.check,
                    color: isCatesReordering.indexWhere((element) => element) != -1 ? Theme.of(context).disabledColor : null,
                  )),
            ),
          ],
          //Title
          title: searchBoxLeftPadding == 15
              ? null
              : Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(curLangText!.itemsHeaderText),
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
              child: isCateTypeReordering
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
                          final CategoryType item = moddedItemsList.removeAt(oldIndex);
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
                               border: Border.all(color: Theme.of(context).primaryColorLight)
                              ),
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
                  //Normal ItemList
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(left: 2, right: 1),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moddedItemsList.length,
                      itemBuilder: (context, groupIndex) {
                        if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != moddedItemsList.length) {
                          itemButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
                        }
                        if (isCatesReordering.isEmpty || isCatesReordering.length != moddedItemsList.length) {
                          isCatesReordering = List.generate(moddedItemsList.length, (index) => false);
                        }
                        if (isCateTypeListExpanded.isEmpty || isCateTypeListExpanded.length != isCateTypeListExpanded.length) {
                          isCateTypeListExpanded = List.generate(moddedItemsList.length, (index) => true);
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
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(moddedItemsList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Wrap(
                                          children: [
                                            if (isCateTypeListExpanded[groupIndex])
                                              Tooltip(
                                                message: isCatesReordering[groupIndex] ? 'Save' : 'Sort Category',
                                                height: 25,
                                                textStyle: const TextStyle(fontSize: 14),
                                                decoration: BoxDecoration(
                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                waitDuration: const Duration(milliseconds: 500),
                                                child: InkWell(
                                                    child: Icon(
                                                      !isCatesReordering[groupIndex] ? Icons.sort_outlined : Icons.check,
                                                    ),
                                                    onTap: () {
                                                      if (isCatesReordering[groupIndex]) {
                                                        isCatesReordering[groupIndex] = false;
                                                      } else {
                                                        isCatesReordering[groupIndex] = true;
                                                      }
                                                      setState(() {});
                                                    }),
                                              ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  initiallyExpanded: moddedItemsList[groupIndex].expanded,
                                  children: [
                                    //Sort Cate
                                    if (isCatesReordering[groupIndex])
                                      ReorderableListView.builder(
                                          padding: const EdgeInsets.only(left: 2, right: 1),
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          buildDefaultDragHandles: false,
                                          onReorder: (int oldIndex, int newIndex) {
                                            setState(() {
                                              if (oldIndex < newIndex) {
                                                newIndex -= 1;
                                              }
                                              final Category item = moddedItemsList[groupIndex].categories.removeAt(oldIndex);
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
                                    //Normal Cate
                                    if (!isCatesReordering[groupIndex])
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: moddedItemsList[groupIndex].categories.length,
                                        itemBuilder: (context, categoryIndex) {
                                          var curCategory = moddedItemsList[groupIndex].categories[categoryIndex];
                                          if (itemButtonsVisible[groupIndex].isEmpty || itemButtonsVisible[groupIndex].length != moddedItemsList[groupIndex].categories.length) {
                                            itemButtonsVisible[groupIndex] = List.generate(moddedItemsList[groupIndex].categories.length, (index) => []);
                                          }
                                          return ExpansionTile(
                                              backgroundColor: Colors.transparent,
                                              textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                              iconColor: Theme.of(context).textTheme.bodyMedium!.color,
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
                                                  Row(
                                                    children: [
                                                      if (!defaultCateforyDirs.contains(curCategory.categoryName))
                                                        Tooltip(
                                                            message: '${curLangText!.deleteBtnTooltipText} ${curCategory.categoryName}',
                                                            height: 25,
                                                            textStyle: const TextStyle(fontSize: 14),
                                                            decoration: BoxDecoration(
                                                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                            ),
                                                            waitDuration: const Duration(milliseconds: 500),
                                                            child: SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: MaterialButton(
                                                                  onPressed: (() {
                                                                    setState(() {});
                                                                  }),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.delete_sweep_rounded,
                                                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                      )
                                                                    ],
                                                                  )),
                                                            )),
                                                    ],
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
                                                      if (itemButtonsVisible[groupIndex][categoryIndex].isEmpty || itemButtonsVisible[groupIndex][categoryIndex].length != curCategory.items.length) {
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
                                                                        Tooltip(
                                                                            message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                            height: 25,
                                                                            textStyle: const TextStyle(fontSize: 14),
                                                                            decoration: BoxDecoration(
                                                                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                                            ),
                                                                            waitDuration: const Duration(milliseconds: 500),
                                                                            child: InkWell(
                                                                              child: const Icon(Icons.folder_open),
                                                                              onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                            )),
                                                                        //Delete
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 5),
                                                                          child: Tooltip(
                                                                            message: 'Hold to remove ${curItem.itemName} from Mod Manager',
                                                                            height: 25,
                                                                            textStyle: const TextStyle(fontSize: 14),
                                                                            decoration: BoxDecoration(
                                                                                color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                                borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                            waitDuration: const Duration(milliseconds: 500),
                                                                            child: InkWell(
                                                                              child: const Icon(
                                                                                Icons.delete_forever_outlined,
                                                                              ),
                                                                              onLongPress: () async {
                                                                                setState(() {});
                                                                              },
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
      ],
    );
  }

//=====================================================================================================================================================================================
  Widget modsView() {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[
          if (modViewItem == null) Container(),
          if (modViewItem != null)
            Align(
              alignment: Alignment.topCenter,
              child: Tooltip(
                message: 'Clear Available Mods view',
                height: 25,
                textStyle: const TextStyle(fontSize: 14),
                decoration: BoxDecoration(
                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                    border: Border.all(color: Theme.of(context).primaryColorLight),
                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                waitDuration: const Duration(milliseconds: 500),
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
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (modViewItem != null)
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
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  child: modViewItem != null
                      ? Text(modViewItem!.itemName)
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(curLangText!.availableModsHeaderText),
                        )),
              if (modViewItem != null)
                Text(
                  modViewItem!.mods.length < 2 ? '${modViewItem!.mods.length} Mod' : '${modViewItem!.mods.length} Mods',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
              if (modViewItem != null && modViewItem!.mods.where((element) => element.applyStatus == true).isNotEmpty)
                Text(
                  'Applied: ${modViewItem!.mods.firstWhere((m) => m.applyStatus == true).modName} > ${modViewItem!.mods.firstWhere((m) => m.applyStatus == true).submods.firstWhere((e) => e.applyStatus).submodName}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.primary),
                ),
            ]),
          ],
        ),
        backgroundColor: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(headersOpacityValue),
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: modViewItem != null ? 84 : 30,
        elevation: 0,
      ),
      const Divider(
        height: 1,
        thickness: 1,
        //color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
      if (modViewItem != null)
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
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modViewItem!.mods.length,
                        itemBuilder: (context, modIndex) {
                          modViewETKeys.add(GlobalKey());
                          var curMod = modViewItem!.mods[modIndex];
                          return InkWell(
                            //Hover for preview
                            onTap: () {},
                            onHover: (hovering) {
                              if (hovering) {
                                previewModName = curMod.modName;
                                for (var path in curMod.previewImages) {
                                  previewImages.add(Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Image.file(
                                        File(path),
                                        //fit: BoxFit.cover,
                                      ),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).canvasColor.withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(color: Theme.of(context).hintColor),
                                            ),
                                            height: 25,
                                            child: Center(
                                                child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Text(
                                                  curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                                      ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                                      : curMod.modName,
                                                  style: const TextStyle(fontSize: 17)),
                                            ))),
                                      )
                                    ],
                                  ));
                                }
                              } else {
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
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(curMod.modName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(curMod.submods.length < 2 ? '${curMod.submods.length} Variant' : '${curMod.submods.length} Variants',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (curMod.submods.length == 1)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Wrap(
                                            spacing: 5,
                                            children: [
                                              //Add-Remove button
                                              if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                Tooltip(
                                                  message: 'Remove ${curMod.submods.first.submodName} from the game',
                                                  height: 25,
                                                  textStyle: const TextStyle(fontSize: 14),
                                                  decoration: BoxDecoration(
                                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                  waitDuration: const Duration(milliseconds: 500),
                                                  child: InkWell(
                                                      child: const Icon(
                                                        Icons.remove_circle_outline_rounded,
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
                                                              ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                              break;
                                                            }
                                                          }
                                                        }
                                                        if (allBkFilesFound) {
                                                          modFilesUnapply(context, curMod.submods.first.modFiles).then((value) async {
                                                            List<ModFile> unappliedModFiles = value;
                                                            if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
                                                              modViewItem!.applyStatus = false;
                                                              curMod.applyStatus = false;
                                                              curMod.submods.first.applyStatus = false;
                                                            }
                                                            for (var element in unappliedModFiles) {
                                                              if (filesUnapplied.isEmpty) {
                                                                filesUnapplied = 'Sucessfully remove ${curMod.modName} > ${curMod.submods.first.submodName}:\n';
                                                              }
                                                              filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                            }
                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                            appliedItemList = await appliedListBuilder(moddedItemsList);
                                                            setState(() {});
                                                          });
                                                        }
                                                      }),
                                                ),
                                              if (curMod.submods.first.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                Tooltip(
                                                  message: 'Apply ${curMod.submods.first.submodName} to the game',
                                                  height: 25,
                                                  textStyle: const TextStyle(fontSize: 14),
                                                  decoration: BoxDecoration(
                                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                  waitDuration: const Duration(milliseconds: 500),
                                                  child: InkWell(
                                                    child: const Icon(
                                                      Icons.add_circle_outline_rounded,
                                                    ),
                                                    onTap: () async {
                                                      bool allOGFilesFound = true;
                                                      //get og file paths
                                                      for (var modFile in curMod.submods.first.modFiles) {
                                                        modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                        if (modFile.ogLocations.isEmpty) {
                                                          ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Error', 'Could not find original file for ${modFile.modFileName}', 3000));
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
                                                            curMod.applyStatus = true;
                                                            modViewItem!.applyStatus = true;
                                                            List<ModFile> appliedModFiles = value;
                                                            String fileAppliedText = '';
                                                            for (var element in appliedModFiles) {
                                                              if (fileAppliedText.isEmpty) {
                                                                fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curMod.submods.first.submodName}:\n';
                                                              }
                                                              fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                            }
                                                            ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                            appliedItemList = await appliedListBuilder(moddedItemsList);
                                                          }

                                                          setState(() {});
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),

                                              //Favorite
                                              Tooltip(
                                                message: 'Add ${curMod.submods.first.submodName} to favorite',
                                                height: 25,
                                                textStyle: const TextStyle(fontSize: 14),
                                                decoration: BoxDecoration(
                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                waitDuration: const Duration(milliseconds: 500),
                                                child: InkWell(
                                                  child: const Icon(
                                                    Icons.favorite_border_outlined,
                                                  ),
                                                  onTap: () async {
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              //Open folder
                                              Tooltip(
                                                message: 'Open ${curMod.submods.first.submodName} in File Explorer',
                                                height: 25,
                                                textStyle: const TextStyle(fontSize: 14),
                                                decoration: BoxDecoration(
                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                waitDuration: const Duration(milliseconds: 500),
                                                child: InkWell(
                                                  child: const Icon(
                                                    Icons.folder_open_outlined,
                                                  ),
                                                  onTap: () async => await launchUrl(Uri.file(curMod.submods.first.location)),
                                                ),
                                              ),
                                              //Delete
                                              Tooltip(
                                                message: 'Hold to remove ${curMod.submods.first.submodName} from Mod Manager',
                                                height: 25,
                                                textStyle: const TextStyle(fontSize: 14),
                                                decoration: BoxDecoration(
                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                waitDuration: const Duration(milliseconds: 500),
                                                child: InkWell(
                                                  child: const Icon(
                                                    Icons.delete_forever_outlined,
                                                  ),
                                                  onLongPress: () async {
                                                    setState(() {});
                                                  },
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
                                          return InkWell(
                                            //submod preview images
                                            onTap: () {},
                                            onHover: (hovering) {
                                              if (hovering) {
                                                hoveringOnSubmod = true;
                                                previewModName = curSubmod.submodName;
                                                previewImages.clear();
                                                for (var path in curSubmod.previewImages) {
                                                  previewImages.add(Stack(
                                                    alignment: Alignment.bottomCenter,
                                                    children: [
                                                      Image.file(
                                                        File(path),
                                                        //fit: BoxFit.cover,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(color: Theme.of(context).hintColor),
                                                            ),
                                                            height: 25,
                                                            child: Center(
                                                                child: Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                    child: Center(child: Text(curSubmod.submodName, style: const TextStyle(fontSize: 17)))))),
                                                      )
                                                    ],
                                                  ));
                                                }
                                              } else {
                                                previewModName = curMod.modName;
                                                hoveringOnSubmod = false;
                                                for (var path in curMod.previewImages) {
                                                  previewImages.add(Stack(
                                                    alignment: Alignment.bottomCenter,
                                                    children: [
                                                      Image.file(
                                                        File(path),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                              color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                              borderRadius: BorderRadius.circular(3),
                                                              border: Border.all(color: Theme.of(context).hintColor),
                                                            ),
                                                            height: 25,
                                                            child: Center(
                                                                child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                                              child: Text(
                                                                  curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                                                      ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                                                      : curMod.modName,
                                                                  style: const TextStyle(fontSize: 17)),
                                                            ))),
                                                      )
                                                    ],
                                                  ));
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
                                                  Expanded(child: Text(curSubmod.submodName)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: Wrap(
                                                      spacing: 5,
                                                      children: [
                                                        //Apply button in submod
                                                        //remove button
                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                          Tooltip(
                                                            message: 'Remove ${curSubmod.submodName} from the game',
                                                            height: 25,
                                                            textStyle: const TextStyle(fontSize: 14),
                                                            decoration: BoxDecoration(
                                                                color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                            waitDuration: const Duration(milliseconds: 500),
                                                            child: InkWell(
                                                              child: const Icon(
                                                                Icons.remove_circle_outline_rounded,
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
                                                                          .showSnackBar(snackBarMessage('Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                      break;
                                                                    }
                                                                  }
                                                                }
                                                                if (allBkFilesFound) {
                                                                  modFilesUnapply(context, curSubmod.modFiles).then((value) async {
                                                                    List<ModFile> unappliedModFiles = value;
                                                                    if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
                                                                      modViewItem!.applyStatus = false;
                                                                      curMod.applyStatus = false;
                                                                      curSubmod.applyStatus = false;
                                                                    }
                                                                    for (var element in unappliedModFiles) {
                                                                      if (filesUnapplied.isEmpty) {
                                                                        filesUnapplied = 'Sucessfully remove ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                      }
                                                                      filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                    }
                                                                    ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                    appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                    setState(() {});
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                          Tooltip(
                                                            message: 'Apply ${curSubmod.submodName} to the game',
                                                            height: 25,
                                                            textStyle: const TextStyle(fontSize: 14),
                                                            decoration: BoxDecoration(
                                                                color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                            waitDuration: const Duration(milliseconds: 500),
                                                            child: InkWell(
                                                              onTap: () async {
                                                                bool allOGFilesFound = true;
                                                                //get og file paths
                                                                for (var modFile in curSubmod.modFiles) {
                                                                  modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                                  if (modFile.ogLocations.isEmpty) {
                                                                    ScaffoldMessenger.of(context)
                                                                        .showSnackBar(snackBarMessage('Error', 'Could not find original file for ${modFile.modFileName}', 3000));
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
                                                                      curMod.applyStatus = true;
                                                                      modViewItem!.applyStatus = true;
                                                                      List<ModFile> appliedModFiles = value;
                                                                      String fileAppliedText = '';
                                                                      for (var element in appliedModFiles) {
                                                                        if (fileAppliedText.isEmpty) {
                                                                          fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                        }
                                                                        fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                      }
                                                                      ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                      appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                    }

                                                                    setState(() {});
                                                                  });
                                                                }
                                                              },
                                                              child: const Icon(
                                                                Icons.add_circle_outline_rounded,
                                                              ),
                                                            ),
                                                          ),

                                                        //Favorite
                                                        Tooltip(
                                                          message: 'Add ${curSubmod.submodName} to favorite',
                                                          height: 25,
                                                          textStyle: const TextStyle(fontSize: 14),
                                                          decoration: BoxDecoration(
                                                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                          waitDuration: const Duration(milliseconds: 500),
                                                          child: InkWell(
                                                            child: const Icon(
                                                              Icons.favorite_border_outlined,
                                                            ),
                                                            onTap: () async {
                                                              setState(() {});
                                                            },
                                                          ),
                                                        ),
                                                        //Open folder
                                                        Tooltip(
                                                          message: 'Open ${curSubmod.submodName} in File Explorer',
                                                          height: 25,
                                                          textStyle: const TextStyle(fontSize: 14),
                                                          decoration: BoxDecoration(
                                                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                          waitDuration: const Duration(milliseconds: 500),
                                                          child: InkWell(
                                                            child: const Icon(
                                                              Icons.folder_open_outlined,
                                                            ),
                                                            onTap: () async => await launchUrl(Uri.file(curSubmod.location)),
                                                          ),
                                                        ),
                                                        //Delete
                                                        Tooltip(
                                                          message: 'Hold to remove ${curSubmod.submodName} from Mod Manager',
                                                          height: 25,
                                                          textStyle: const TextStyle(fontSize: 14),
                                                          decoration: BoxDecoration(
                                                              color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                              border: Border.all(color: Theme.of(context).primaryColorLight),
                                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                          waitDuration: const Duration(milliseconds: 500),
                                                          child: InkWell(
                                                            onLongPress: curSubmod.applyStatus
                                                                ? null
                                                                : () async {
                                                                    deleteFilesFromModMan([]);
                                                                    setState(() {});
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
                                                          spacing: 10,
                                                          children: [
                                                            //Add-Remove button
                                                            if (curModFile.applyStatus == false)
                                                              Tooltip(
                                                                message: 'Apply ${curModFile.modFileName} to the game',
                                                                height: 25,
                                                                textStyle: const TextStyle(fontSize: 14),
                                                                decoration: BoxDecoration(
                                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                waitDuration: const Duration(milliseconds: 500),
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
                                                                          .showSnackBar(snackBarMessage('Error', 'Could not find original file for ${curModFile.modFileName}', 3000));
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
                                                                          curMod.applyStatus = true;
                                                                          modViewItem!.applyStatus = true;
                                                                          List<ModFile> appliedModFiles = value;
                                                                          String fileAppliedText = '';
                                                                          for (var element in appliedModFiles) {
                                                                            if (fileAppliedText.isEmpty) {
                                                                              fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                            }
                                                                            fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                          }
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage('Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        }

                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            if (curModFile.applyStatus == true)
                                                              Tooltip(
                                                                message: 'Remove ${curModFile.modFileName} from the game',
                                                                height: 25,
                                                                textStyle: const TextStyle(fontSize: 14),
                                                                decoration: BoxDecoration(
                                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                waitDuration: const Duration(milliseconds: 500),
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
                                                                            .showSnackBar(snackBarMessage('Error', 'Could not find backup file for ${curModFile.modFileName}', 3000));

                                                                        break;
                                                                      }
                                                                    }
                                                                    if (allBkFilesFound) {
                                                                      modFilesUnapply(context, [curModFile]).then((value) async {
                                                                        List<ModFile> unappliedModFiles = value;
                                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
                                                                          modViewItem!.applyStatus = false;
                                                                          curMod.applyStatus = false;
                                                                          curSubmod.applyStatus = false;
                                                                        }
                                                                        for (var element in unappliedModFiles) {
                                                                          if (filesUnapplied.isEmpty) {
                                                                            filesUnapplied = 'Sucessfully remove ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                          }
                                                                          filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                        }
                                                                        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                        appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ),

                                                            //Delete
                                                            Tooltip(
                                                              message: 'Hold to remove ${curModFile.modFileName} from Mod Manager',
                                                              height: 25,
                                                              textStyle: const TextStyle(fontSize: 14),
                                                              decoration: BoxDecoration(
                                                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                              waitDuration: const Duration(milliseconds: 500),
                                                              child: InkWell(
                                                                child: const Icon(
                                                                  Icons.delete_forever_outlined,
                                                                ),
                                                                onLongPress: () async {
                                                                  setState(() {});
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        title: Text(curModFile.modFileName),
                                                      );
                                                    })
                                              ],
                                            ),
                                          );
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }))))
    ]);
  }

//=====================================================================================================================================================================================
  Widget appliedModsView() {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5),
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
              padding: const EdgeInsets.only(left: 1, right: 2),
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
                                    initiallyExpanded: false,
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
                                            var curMod = curItem.mods.firstWhere((element) => element.applyStatus);
                                            var curSubmod = curMod.submods.firstWhere((element) => element.applyStatus);
                                            List<ModFile> appliedModFiles = curSubmod.modFiles;
                                            return InkResponse(
                                              highlightShape: BoxShape.rectangle,
                                              onTap: () => '',
                                              onHover: (hovering) {
                                                if (hovering) {
                                                  previewModName = curSubmod.submodName;
                                                  for (var path in curSubmod.previewImages) {
                                                    previewImages.add(Stack(
                                                      alignment: Alignment.bottomCenter,
                                                      children: [
                                                        Image.file(
                                                          File(path),
                                                          //fit: BoxFit.cover,
                                                        ),
                                                        FittedBox(
                                                          fit: BoxFit.fitWidth,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                                borderRadius: BorderRadius.circular(3),
                                                                border: Border.all(color: Theme.of(context).hintColor),
                                                              ),
                                                              height: 25,
                                                              child: Center(
                                                                  child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                                                child: Text(curSubmod.submodName, style: const TextStyle(fontSize: 17)),
                                                              ))),
                                                        )
                                                      ],
                                                    ));
                                                  }
                                                } else {
                                                  previewModName = '';
                                                  previewImages.clear();
                                                }
                                                setState(() {});
                                              },
                                              child: ExpansionTile(
                                                backgroundColor: Colors.transparent,
                                                iconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                textColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                collapsedIconColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                collapsedTextColor: Theme.of(context).textTheme.bodyMedium!.color,
                                                //shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
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
                                                          Text(
                                                            curItem.itemName,
                                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                          ),
                                                          const Divider(
                                                            endIndent: 5,
                                                            height: 10,
                                                            thickness: 2,
                                                            //color: Theme.of(context).textTheme.headlineMedium?.color,
                                                          ),
                                                          Text(
                                                            '${curMod.modName} > ${curSubmod.submodName}',
                                                            //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
                                                          ),
                                                          Text(
                                                            '${curSubmod.modFiles.where((element) => element.applyStatus).length} / ${curSubmod.modFiles.length} Files applied',
                                                            //style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 15),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          //Buttons
                                                          //remove button
                                                          if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) != -1)
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 5),
                                                              child: Tooltip(
                                                                message: 'Remove ${curSubmod.submodName} from the game',
                                                                height: 25,
                                                                textStyle: const TextStyle(fontSize: 14),
                                                                decoration: BoxDecoration(
                                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                waitDuration: const Duration(milliseconds: 500),
                                                                child: InkWell(
                                                                  child: const Icon(
                                                                    Icons.remove_circle_outline_rounded,
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
                                                                              .showSnackBar(snackBarMessage('Error', 'Could not find backup file for ${modFile.modFileName}', 3000));

                                                                          break;
                                                                        }
                                                                      }
                                                                    }
                                                                    if (allBkFilesFound) {
                                                                      modFilesUnapply(context, curSubmod.modFiles).then((value) async {
                                                                        List<ModFile> unappliedModFiles = value;
                                                                        if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
                                                                          modViewItem!.applyStatus = false;
                                                                          curMod.applyStatus = false;
                                                                          curSubmod.applyStatus = false;
                                                                        }
                                                                        for (var element in unappliedModFiles) {
                                                                          if (filesUnapplied.isEmpty) {
                                                                            filesUnapplied = 'Sucessfully remove ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                          }
                                                                          filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                        }
                                                                        ScaffoldMessenger.of(context).showSnackBar(snackBarMessage('Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                        appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          //Apply button in submod
                                                          if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == false) != -1)
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 5),
                                                              child: Tooltip(
                                                                message: 'Apply ${curSubmod.submodName} to the game',
                                                                height: 25,
                                                                textStyle: const TextStyle(fontSize: 14),
                                                                decoration: BoxDecoration(
                                                                    color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                waitDuration: const Duration(milliseconds: 500),
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    bool allOGFilesFound = true;
                                                                    //get og file paths
                                                                    for (var modFile in curSubmod.modFiles) {
                                                                      modFile.ogLocations = ogIcePathsFetcher(modFile.modFileName);
                                                                      if (modFile.ogLocations.isEmpty) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(snackBarMessage('Error', 'Could not find original file for ${modFile.modFileName}', 3000));
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
                                                                          curMod.applyStatus = true;
                                                                          modViewItem!.applyStatus = true;
                                                                          List<ModFile> appliedModFiles = value;
                                                                          String fileAppliedText = '';
                                                                          for (var element in appliedModFiles) {
                                                                            if (fileAppliedText.isEmpty) {
                                                                              fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                            }
                                                                            fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                          }
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage('Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                        }

                                                                        setState(() {});
                                                                      });
                                                                    }
                                                                  },
                                                                  child: const Icon(
                                                                    Icons.add_circle_outline_rounded,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 5),
                                                            child: Tooltip(
                                                                message: '${curLangText!.openBtnTooltipText}${curItem.itemName}${curLangText!.inExplorerBtnTootipText}',
                                                                height: 25,
                                                                textStyle: const TextStyle(fontSize: 14),
                                                                decoration: BoxDecoration(
                                                                  color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                                ),
                                                                waitDuration: const Duration(milliseconds: 500),
                                                                child: InkWell(
                                                                  child: const Icon(Icons.folder_open),
                                                                  onTap: () async => await launchUrl(Uri.file(curItem.location)),
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
                                                      itemCount: appliedModFiles.length,
                                                      itemBuilder: (context, modFileIndex) {
                                                        var curModFile = appliedModFiles[modFileIndex];
                                                        return ListTile(
                                                          tileColor: Colors.transparent,
                                                          //tileColor: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                                                          trailing: Wrap(
                                                            spacing: 10,
                                                            children: [
                                                              //Add-Remove button
                                                              if (curModFile.applyStatus == false)
                                                                Tooltip(
                                                                  message: 'Apply ${curModFile.modFileName} to the game',
                                                                  height: 25,
                                                                  textStyle: const TextStyle(fontSize: 14),
                                                                  decoration: BoxDecoration(
                                                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                  waitDuration: const Duration(milliseconds: 500),
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
                                                                            .showSnackBar(snackBarMessage('Error', 'Could not find original file for ${curModFile.modFileName}', 3000));
                                                                        allOGFilesFound = false;
                                                                      }
                                                                      //apply mod files
                                                                      if (allOGFilesFound) {
                                                                        modFilesApply(context, [curModFile]).then((value) async {
                                                                          if (curItem.mods.first.submods.first.modFiles.indexWhere((element) => element.applyStatus) != -1) {
                                                                            curSubmod.applyDate = DateTime.now();
                                                                            curItem.applyDate = DateTime.now();
                                                                            curMod.applyDate = DateTime.now();
                                                                            curSubmod.applyStatus = true;
                                                                            curMod.applyStatus = true;
                                                                            curItem.applyStatus = true;
                                                                            List<ModFile> appliedModFiles = value;
                                                                            String fileAppliedText = '';
                                                                            for (var element in appliedModFiles) {
                                                                              if (fileAppliedText.isEmpty) {
                                                                                fileAppliedText = 'Sucessfully applied ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                              }
                                                                              fileAppliedText += '${appliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                            }
                                                                            ScaffoldMessenger.of(context)
                                                                                .showSnackBar(snackBarMessage('Success!', fileAppliedText.trim(), appliedModFiles.length * 1000));
                                                                            appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                          }

                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              if (curModFile.applyStatus == true)
                                                                Tooltip(
                                                                  message: 'Remove ${curModFile.modFileName} from the game',
                                                                  height: 25,
                                                                  textStyle: const TextStyle(fontSize: 14),
                                                                  decoration: BoxDecoration(
                                                                      color: Color(context.watch<StateProvider>().uiBackgroundColorValue).withOpacity(0.8),
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                                  waitDuration: const Duration(milliseconds: 500),
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
                                                                              .showSnackBar(snackBarMessage('Error', 'Could not find backup file for ${curModFile.modFileName}', 3000));

                                                                          break;
                                                                        }
                                                                      }
                                                                      if (allBkFilesFound) {
                                                                        modFilesUnapply(context, [curModFile]).then((value) async {
                                                                          List<ModFile> unappliedModFiles = value;
                                                                          if (curSubmod.modFiles.indexWhere((element) => element.applyStatus == true) == -1) {
                                                                            curItem.applyStatus = false;
                                                                            curMod.applyStatus = false;
                                                                            curSubmod.applyStatus = false;
                                                                          }
                                                                          for (var element in unappliedModFiles) {
                                                                            if (filesUnapplied.isEmpty) {
                                                                              filesUnapplied = 'Sucessfully remove ${curMod.modName} > ${curSubmod.submodName}:\n';
                                                                            }
                                                                            filesUnapplied += '${unappliedModFiles.indexOf(element) + 1}.  ${element.modFileName}\n';
                                                                          }
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(snackBarMessage('Success!', filesUnapplied.trim(), unappliedModFiles.length * 1000));

                                                                          appliedItemList = await appliedListBuilder(moddedItemsList);
                                                                          setState(() {});
                                                                        });
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          title: Text(curModFile.modFileName),
                                                        );
                                                      })
                                                ],
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

//=====================================================================================================================================================================================
  Widget modPreviewView() {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        title: Padding(
          padding: const EdgeInsets.only(bottom: 5),
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
      if (previewImages.isEmpty || (previewImages.isEmpty && hoveringOnSubmod))
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
            ),
            items: previewImages,
          ),
        )
    ]);
  }

//=====================================================================================================================================================================================
  //Mod Set
  Widget setList() {
    return Container();
  }

//=====================================================================================================================================================================================
  Widget modInSetList() {
    return Container();
  }

//Extra=======================================================================================================================================================================================
  SnackBar snackBarMessage(String title, String message, int durationMS) {
    return SnackBar(
        elevation: 0,
        width: windowsWidth * 0.5,
        padding: const EdgeInsets.all(10),
        duration: Duration(milliseconds: durationMS < 3000 ? durationMS : 3000),
        backgroundColor: Color(Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValue).withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(5))),
        showCloseIcon: true,
        closeIconColor: Theme.of(context).textTheme.bodyMedium?.color,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ));
  }
}
