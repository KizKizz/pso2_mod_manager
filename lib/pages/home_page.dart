import 'dart:io';

import 'package:advance_expansion_tile/advance_expansion_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/classes/mod_class.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.285), Area(weight: 0.335)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.40)]);
  List<GlobalKey<AdvanceExpansionTileState>> modViewETKeys = [];

  String modViewItemName = '';
  String previewModName = '';
  bool hoveringOnSubmod = false;
  List<Mod> modViewList = [];
  List<Widget> previewImages = [];
  double headersOpacityValue = 0.7;
  double headersExtraOpacityValue = 0.3;
  List<List<List<bool>>> itemButtonsVisible = [];

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
            if (context.watch<StateProvider>().backgroundImageTrigger)
              Image.file(
                backgroundImage,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            viewsTheme,
            
          ]);
  }

//=====================================================================================================================================================================================
  Widget itemsView() {
    var searchBoxLeftPadding = 10;

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          title: searchBoxLeftPadding == 15 ? null : Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.itemsHeaderText)),
          backgroundColor: Theme.of(context).canvasColor.withOpacity(headersOpacityValue),
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moddedItemsList.length,
                itemBuilder: (context, groupIndex) {
                  if (itemButtonsVisible.isEmpty || itemButtonsVisible.length != moddedItemsList.length) {
                    itemButtonsVisible = List.generate(moddedItemsList.length, (index) => []);
                  }
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
                        padding: const EdgeInsets.only(left: 2),
                        child: Card(
                          margin: const EdgeInsets.all(1),
                          color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                          child: ExpansionTile(
                            backgroundColor: Colors.transparent,
                            collapsedTextColor: Theme.of(context).colorScheme.primary,
                            title: Text(moddedItemsList[groupIndex].groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            initiallyExpanded: moddedItemsList[groupIndex].expanded,
                            children: [
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
                                      initiallyExpanded: false,
                                      childrenPadding: const EdgeInsets.all(0),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(curCategory.categoryName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                                child: Container(
                                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Theme.of(context).highlightColor),
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
                                                      color: Theme.of(context).canvasColor.withOpacity(0.8),
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
                                                                style: const TextStyle(fontSize: 16),
                                                              ),
                                                              Text(
                                                                curItem.mods.length < 2 ? '${curItem.mods.length} Mod' : '${curItem.mods.length} Mods',
                                                                style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
                                                              ),
                                                              Text(
                                                                '${curItem.mods.where((element) => element.applyStatus == true).length} Applied',
                                                                style: TextStyle(color: Theme.of(context).textTheme.displaySmall?.color),
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
                                                                      color: Theme.of(context).canvasColor.withOpacity(0.8),
                                                                      border: Border.all(color: Theme.of(context).primaryColorLight),
                                                                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                                    ),
                                                                    waitDuration: const Duration(milliseconds: 500),
                                                                    child: InkWell(
                                                                      child: const Icon(Icons.folder_open),
                                                                      onTap: () async => await launchUrl(Uri.file(curItem.location)),
                                                                    )),
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
                                                      modViewItemName = curItem.itemName;
                                                      modViewList = curItem.mods;
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
        actions: <Widget>[Container()],
        title: Container(padding: const EdgeInsets.only(bottom: 10), child: modViewItemName.isNotEmpty ? Text(modViewItemName) : Text(curLangText!.availableModsHeaderText)),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(headersOpacityValue),
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: 30,
        elevation: 0,
      ),
      const Divider(
        height: 1,
        thickness: 1,
        //color: Theme.of(context).textTheme.headlineMedium?.color,
      ),
      if (modViewList.isNotEmpty)
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: modViewList.length,
                        itemBuilder: (context, modIndex) {
                          modViewETKeys.add(GlobalKey());
                          var curMod = modViewList[modIndex];
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
                                      Container(
                                          //width: double.minPositive,
                                          height: 25,
                                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                                          child: Center(
                                              child: Text(
                                                  curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                                      ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                                      : curMod.modName,
                                                  style: const TextStyle(fontSize: 17))))
                                    ],
                                  ));
                                }
                              } else {
                                previewModName = '';
                                previewImages.clear();
                              }
                              setState(() {});
                            },
                            child: Card(
                              margin: const EdgeInsets.all(1),
                              color: Theme.of(context).canvasColor.withOpacity(context.watch<StateProvider>().uiOpacityValue),
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: curMod.isNew ? Colors.amber : Theme.of(context).primaryColorLight), borderRadius: const BorderRadius.all(Radius.circular(2))),
                              child: AdvanceExpansionTile(
                                key: modViewETKeys[modIndex],
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(curMod.modName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text(curMod.submods.length < 2 ? '${curMod.submods.length} Variant' : '${curMod.submods.length} Variants',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            )),
                                      ],
                                    ),
                                    Wrap(
                                      children: [
                                        //Add-Remove button
                                        if (curMod.submods.length == 1)
                                          Tooltip(
                                            message: 'Add this mod to game',
                                            height: 25,
                                            textStyle: const TextStyle(fontSize: 14),
                                            decoration: BoxDecoration(
                                                color: Theme.of(context).canvasColor.withOpacity(0.8),
                                                border: Border.all(color: Theme.of(context).primaryColorLight),
                                                borderRadius: const BorderRadius.all(Radius.circular(2)),
                                                backgroundBlendMode: BlendMode.darken),
                                            waitDuration: const Duration(milliseconds: 500),
                                            child: InkWell(
                                              child: Icon(
                                                Icons.post_add_outlined,
                                                color: Theme.of(context).hintColor,
                                              ),
                                              onTap: () async {
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                      ],
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
                                                    Container(
                                                        height: 25,
                                                        color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                        child: Center(child: Text(curSubmod.submodName, style: const TextStyle(fontSize: 17))))
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
                                                    Container(
                                                        height: 25,
                                                        color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                        child: Center(
                                                            child: Text(
                                                                curMod.submods.indexWhere((element) => element.previewImages.contains(path)) != -1
                                                                    ? curMod.submods[curMod.submods.indexWhere((element) => element.previewImages.contains(path))].submodName
                                                                    : curMod.modName,
                                                                style: const TextStyle(fontSize: 17))))
                                                  ],
                                                ));
                                              }
                                            }
                                            setState(() {});
                                          },
                                          child: ExpansionTile(
                                            backgroundColor: Colors.transparent,
                                            title: Text(curSubmod.submodName),
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
        title: Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.appliedModsHeadersText)),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(headersOpacityValue),
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
              child: SingleChildScrollView(child: Container())))
    ]);
  }

//=====================================================================================================================================================================================
  Widget modPreviewView() {
    return Column(children: [
      AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        title: Container(padding: const EdgeInsets.only(bottom: 10), child: previewModName.isNotEmpty ? Text('Preview: $previewModName') : Text(curLangText!.previewHeaderText)),
        backgroundColor: Theme.of(context).canvasColor.withOpacity(headersOpacityValue),
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
            children: const [
              Text(
                'No preview available',
                style: TextStyle(fontSize: 15),
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
}
