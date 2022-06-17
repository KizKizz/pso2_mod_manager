// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:url_launcher/url_launcher.dart';

List<ModCategory> cateList = [];
Future? modFilesListGet;
Future? futureImagesGet;
Future? appliedModsListGet;
List<File> modPreviewImgList = [];
List<List<ModFile>> modFilesList = [];
List<List<ModFile>> appliedModsList = [];
List<ModFile> modAppliedDup = [];
List<ModFile> originalFilesMissingList = [];
List<ModFile> backupFilesMissingList = [];
List<bool> isLoading = [];

//New Cate
bool addCategoryVisible = false;
final categoryFormKey = GlobalKey<FormState>();
TextEditingController categoryAddController = TextEditingController();

//NewItem
bool addItemVisible = false;
final newMultipleItemsFormKey = GlobalKey<FormState>();
final newSingleItemFormKey = GlobalKey<FormState>();
TextEditingController newItemAddController = TextEditingController();
TextEditingController newSingleItemAddController = TextEditingController();
List<String> dropdownCategories = [];
String? selectedCategoryForMutipleItems;
String? selectedCategoryForSingleItem;
final _newItemDropdownKey = GlobalKey<FormState>();
bool _dragging = false;
//final List<XFile> _newItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test')];
final List<XFile> _newItemDragDropList = [];
final List<XFile> _newSingleItemDragDropList = [];
bool isItemAddBtnClicked = false;

//NewItem Exist Item
bool addModToItemVisible = false;
final newModToItemFormKey = GlobalKey<FormState>();
TextEditingController newModToItemAddController = TextEditingController();
bool _newModToItemDragging = false;
//final List<XFile> _newModToItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test\\Red ball gag - Copy')];
final List<XFile> _newModToItemDragDropList = [];
int _newModToItemIndex = 0;
bool isModAddBtnClicked = false;

//Media Player controls
Player previewPlayer = Player(id: 69, registerTexture: true);
MediaType mediaType = MediaType.file;
CurrentState current = CurrentState();
List<Media> medias = <Media>[
  Media.file(File('E:\\Steam\\steamapps\\common\\PHANTASYSTARONLINE2_NA_STEAM\\pso2_bin\\PSO2 Mod Manager\\Mods\\Emotes\\Glow stick Wave 1\\FS_Cowgirl3_Over_Glowstickwave1\\FS_Cowgirl3_Preview.mp4')),
  Media.file(File('E:\\Steam\\steamapps\\common\\PHANTASYSTARONLINE2_NA_STEAM\\pso2_bin\\PSO2 Mod Manager\\Mods\\Emotes\\Glow stick Wave 1\\FS_Cowgirl3_Over_Glowstickwave1\\FS_Cowgirl3_Preview.mp4')),
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.30), Area(weight: 0.325)]);
  final MultiSplitViewController _viewsControllerNoPreview = MultiSplitViewController(areas: [Area(weight: 0.30), Area(weight: 0.5)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.5)]);
  String modsViewAppBarName = '';
  List<int> selectedIndex = List.generate(cateList.length, (index) => -1);
  CarouselController imgSliderController = CarouselController();

  int modNameCatSelected = -1;
  bool isModSelected = false;
  int currentImg = 0;
  bool isPreviewImgsOn = false;
  bool isPreviewVidOn = true;
  bool modViewExpandAll = false;
  bool isErrorInSingleItemName = false;

  late AnimationController cateAdderAniController;
  late Animation<Offset> cateAdderAniOffset;
  late AnimationController itemAdderAniController;
  late Animation<Offset> itemAdderAniOffset;
  late AnimationController modAdderAniController;
  late Animation<Offset> modAdderAniOffset;

  late TabController _itemAdderTabcontroller;

  @override
  void initState() {
    super.initState();
    _itemAdderTabcontroller = TabController(length: 2, vsync: this);
    cateAdderAniController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    cateAdderAniOffset = Tween<Offset>(begin: const Offset(0.0, 1.1), end: const Offset(0.0, 0.0)).animate(cateAdderAniController);
    itemAdderAniController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    itemAdderAniOffset = Tween<Offset>(begin: const Offset(0.0, 1.1), end: const Offset(0.0, 0.0)).animate(itemAdderAniController);
    modAdderAniController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    modAdderAniOffset = Tween<Offset>(begin: const Offset(0.0, 1.1), end: const Offset(0.0, 0.0)).animate(modAdderAniController);
  }

  @override
  void dispose() {
    cateAdderAniController.dispose();
    itemAdderAniController.dispose();
    modAdderAniController.dispose();
    _itemAdderTabcontroller.dispose();
    previewPlayer.dispose();
    _viewsController.dispose();
    _viewsControllerNoPreview.dispose();
    _verticalViewsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitView mainViews = MultiSplitView(
      controller: _viewsController,
      children: [
        itemsView(),
        modsView(),
        MultiSplitView(
          axis: Axis.vertical,
          controller: _verticalViewsController,
          children: context.watch<stateProvider>().previewWindowVisible ? [modPreviewView(), filesView()] : [filesView()],
        )
      ],
    );

    MultiSplitViewTheme viewsTheme = MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
            dividerThickness: 4,
            dividerPainter: DividerPainters.dashed(
                //highlightedThickness: 5,
                //thickness: 3,
                //backgroundColor: Theme.of(context).hintColor,
                //size: MediaQuery.of(context).size.height,
                color: Theme.of(context).hintColor,
                highlightedColor: Theme.of(context).primaryColor)),
        child: mainViews);

    return Expanded(child: viewsTheme);
  }

  Widget itemsView() {
    dropdownCategories.clear();
    for (var category in cateList) {
      dropdownCategories.add(category.categoryName);
    }

    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Items')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 2.5),
                child: Tooltip(
                    message: 'New Category',
                    height: 25,
                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                    waitDuration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: MaterialButton(
                          onPressed: addCategoryVisible
                              ? null
                              : (() {
                                  setState(() {
                                    switch (cateAdderAniController.status) {
                                      case AnimationStatus.dismissed:
                                        addCategoryVisible = true;
                                        cateAdderAniController.forward();
                                        break;
                                      default:
                                    }
                                  });
                                }),
                          child: Stack(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                color: addCategoryVisible
                                    ? Theme.of(context).disabledColor
                                    : MyApp.themeNotifier.value == ThemeMode.light
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context).iconTheme.color,
                              ),
                              Positioned(
                                  left: 11.5,
                                  bottom: 10,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
                                    color: addCategoryVisible
                                        ? Theme.of(context).disabledColor
                                        : MyApp.themeNotifier.value == ThemeMode.light
                                            ? Theme.of(context).primaryColorDark
                                            : Theme.of(context).iconTheme.color,
                                  )),
                            ],
                          )),
                    ))),
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Tooltip(
                    message: 'New Item',
                    height: 25,
                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                    waitDuration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: MaterialButton(
                          onPressed: addItemVisible
                              ? null
                              : (() {
                                  setState(() {
                                    switch (itemAdderAniController.status) {
                                      case AnimationStatus.dismissed:
                                        addItemVisible = true;
                                        itemAdderAniController.forward();
                                        break;
                                      default:
                                    }
                                  });
                                }),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_box_outlined,
                                color: addItemVisible
                                    ? Theme.of(context).disabledColor
                                    : MyApp.themeNotifier.value == ThemeMode.light
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context).iconTheme.color,
                              )
                            ],
                          )),
                    ))),
          ],
        ),

        //Category List
        Expanded(
          child: SingleChildScrollView(
            controller: AdjustableScrollController(80),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cateList.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  initiallyExpanded: false,
                  textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  onExpansionChanged: (newState) {
                    setState(() {
                      if (!newState) {
                        selectedIndex = List.filled(cateList.length, -1);
                      } else {
                        selectedIndex = List.filled(cateList.length, -1);
                      }
                    });
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(cateList[index].categoryName),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 3),
                            child: Container(
                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).highlightColor),
                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                ),
                                child: Text('${cateList[index].numOfItems} Items',
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ))),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Tooltip(
                              message: 'Remove ${cateList[index].categoryName}',
                              height: 25,
                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                              waitDuration: const Duration(seconds: 2),
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: MaterialButton(
                                    onPressed: (() {
                                      setState(() {
                                        if (cateList[index].allModFiles.indexWhere((element) => element.isApplied == true) == -1) {
                                          categoryDeleteDialog(
                                                  context,
                                                  100,
                                                  'Remove Category',
                                                  'Remove "${cateList[index].categoryName}" and move it to Deleted Items folder?\nThis will also remove all items in this category',
                                                  true,
                                                  cateList[index].categoryPath,
                                                  cateList[index].allModFiles)
                                              .then((_) {
                                            setState(() {
                                              //setstate to refresh list
                                            });
                                          });
                                        } else {
                                          List<ModFile> tempList = cateList[index].allModFiles.where((element) => element.isApplied == true).toList();
                                          List<String> stillAppliedList = [];
                                          double popupHeight = 40;
                                          for (var element in tempList) {
                                            stillAppliedList.add('${element.modName}${element.iceParent} > ${element.iceName}');
                                            popupHeight += 24;
                                          }
                                          String stillApplied = stillAppliedList.join('\n');
                                          categoryDeleteDialog(context, popupHeight, 'Remove Category', 'Cannot remove "${cateList[index].categoryName}". Unaplly these mods first:\n\n$stillApplied',
                                              false, cateList[index].categoryPath, []);
                                        }
                                      });
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
                    for (int i = 0; i < cateList[index].itemNames.length; i++)
                      Ink(
                        color: selectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                        child: ListTile(
                          leading: cateList[index].imageIcons[i].first.path.split('/').last != 'placeholdersquare.jpg'
                              ? SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.file(
                                    cateList[index].imageIcons[i].first,
                                    fit: BoxFit.fitWidth,
                                  ))
                              : SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.asset(
                                    cateList[index].imageIcons[i].first.path,
                                    fit: BoxFit.fitWidth,
                                  )),
                          title: Text(cateList[index].itemNames[i]),
                          subtitle: Text('Mods: ${cateList[index].numOfMods[i]} | Applied: ${cateList[index].numOfApplied[i]}'),
                          trailing: Wrap(
                            children: [
                              if (cateList[index].allModFiles.indexWhere((element) => element.modName == cateList[index].itemNames[i] && element.isNew == true) != -1)
                                const SizedBox(height: 50, child: Icon(Icons.new_releases, color: Colors.amber)),

                              //Buttons
                              Tooltip(
                                  message: 'Open ${cateList[index].itemNames[i]} in File Explorer',
                                  height: 25,
                                  textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                  waitDuration: const Duration(seconds: 2),
                                  child: SizedBox(
                                    width: 34,
                                    height: 50,
                                    child: MaterialButton(
                                        onPressed: (() async {
                                          await launchUrl(Uri.parse('file:${cateList[index].categoryPath}\\${cateList[index].itemNames[i]}'));
                                        }),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.folder_open_rounded,
                                              size: 18,
                                            )
                                          ],
                                        )),
                                  )),
                              Tooltip(
                                  message: 'Remove ${cateList[index].itemNames[i]}',
                                  height: 25,
                                  textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                  waitDuration: const Duration(seconds: 2),
                                  child: SizedBox(
                                    width: 36,
                                    height: 50,
                                    child: MaterialButton(
                                        onPressed: (() {
                                          setState(() {
                                            if (cateList[index].allModFiles.indexWhere((element) => element.modName == cateList[index].itemNames[i] && element.isApplied == true) == -1) {
                                              itemDeleteDialog(
                                                      context,
                                                      100,
                                                      'Remove Item',
                                                      'Remove "${cateList[index].itemNames[i]}" and move it to Deleted Items folder?\nThis will also remove all mods in this item',
                                                      true,
                                                      cateList[index],
                                                      cateList[index].itemNames[i],
                                                      cateList[index].allModFiles)
                                                  .then((_) {
                                                setState(() {
                                                  modsViewAppBarName = 'Available Mods';
                                                  isModSelected = false;
                                                  //setstate
                                                });
                                              });
                                            } else {
                                              List<ModFile> tempList =
                                                  cateList[index].allModFiles.where((element) => element.modName == cateList[index].itemNames[i] && element.isApplied == true).toList();
                                              List<String> stillAppliedList = [];
                                              double popupHeight = 40;
                                              for (var element in tempList) {
                                                stillAppliedList.add('${element.modName}${element.iceParent} > ${element.iceName}');
                                                popupHeight += 24;
                                              }
                                              String stillApplied = stillAppliedList.join('\n');
                                              itemDeleteDialog(context, popupHeight, 'Remove Item', 'Cannot remove "${cateList[index].itemNames[i]}". Unaplly these mods first:\n\n$stillApplied',
                                                  false, cateList[index], cateList[index].itemNames[i], []);
                                            }
                                          });
                                        }),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.delete_forever_outlined,
                                              size: 20,
                                            )
                                          ],
                                        )),
                                  )),
                            ],
                          ),
                          onTap: () {
                            setState(() {
                              isPreviewImgsOn = false;
                              modFilesListGet = getModFilesByCategory(cateList[index].allModFiles, cateList[index].itemNames[i]);
                              selectedIndex = List.filled(cateList.length, -1);
                              selectedIndex[index] = i;
                              modNameCatSelected = -1;
                              modsViewAppBarName = cateList[index].itemNames[i];
                              _newModToItemIndex = index;
                              isModSelected = true;
                              isLoading.clear();
                            });
                          },
                        ),
                      )
                  ],
                );
              },
            ),
          ),
        ),

        //Add Category Panel
        if (addCategoryVisible)
          SlideTransition(
            position: cateAdderAniOffset,
            child: Container(
              //height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    spreadRadius: -1,
                    blurRadius: 3,
                    offset: const Offset(0, -4), // changes position of shadow
                  ),
                ],
              ),
              child: Column(children: [
                Form(
                  key: categoryFormKey,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                    child: TextFormField(
                      controller: categoryAddController,
                      //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      //maxLength: 100,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        labelText: 'New Category Name',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category name can\'t be empty';
                        }
                        if (cateList.indexWhere((e) => e.categoryName == value) != -1) {
                          return 'Category name already exist';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          setState(
                            () {},
                          );
                        });
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                              onPressed: (() {
                                setState(() {
                                  categoryAddController.clear();
                                  //addCategoryVisible = false;
                                  switch (cateAdderAniController.status) {
                                    case AnimationStatus.completed:
                                      cateAdderAniController.reverse().whenComplete(() {
                                        addCategoryVisible = false;
                                        setState(() {});
                                      });
                                      break;

                                    default:
                                  }
                                });
                              }),
                              child: const Text('Close')),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                              onPressed: (() {
                                setState(() {
                                  //more
                                  if (categoryFormKey.currentState!.validate()) {
                                    cateList.add(ModCategory(categoryAddController.text, '$modsDirPath\\${categoryAddController.text}', [], [], 0, [], [], []));
                                    cateList.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
                                    Directory('$modsDirPath\\${categoryAddController.text}').create(recursive: true);
                                    selectedIndex = List.generate(cateList.length, (index) => -1);

                                    for (var modList in modFilesList) {
                                      modList.map((mod) => mod.toJson()).toList();
                                      File(modSettingsPath).writeAsStringSync(json.encode(modList));
                                    }

                                    categoryAddController.clear();
                                    //addCategoryVisible = false;
                                  }
                                });
                              }),
                              child: const Text('Add Category')),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),

        //Add Item Panel
        if (addItemVisible)
          SlideTransition(
            position: itemAdderAniOffset,
            child: Container(
              //height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    spreadRadius: -1,
                    blurRadius: 3,
                    offset: const Offset(0, -4), // changes position of shadow
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TabBar(
                  labelColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                  controller: _itemAdderTabcontroller,
                  onTap: (index) {
                    if (index == 0) {
                      _newItemDragDropList.clear();
                      newItemAddController.clear();
                      selectedCategoryForMutipleItems = null;
                      //isErrorInSingleItemName = false;
                      context.read<stateProvider>().itemsDropAddClear();
                    } else {
                      _newSingleItemDragDropList.clear();
                      newSingleItemAddController.clear();
                      selectedCategoryForMutipleItems = null;
                      isErrorInSingleItemName = false;
                      context.read<stateProvider>().singleItemDropAddClear();
                    }
                  },
                  tabs: const [
                    Tab(
                      height: 25,
                      text: 'Single Item',
                    ),
                    Tab(
                      height: 25,
                      text: 'Multiple Items',
                    ),
                  ],
                ),
                SizedBox(
                  height: !isErrorInSingleItemName ? 220 : 250,
                  child: TabBarView(
                    controller: _itemAdderTabcontroller,
                    children: [
                      // Single Item adder tab
                      Column(
                        children: [
                          //Drop Zone,
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                            child: DropTarget(
                              //enable: true,
                              onDragDone: (detail) {
                                setState(() {
                                  detail.files.sort(((a, b) => a.name.compareTo(b.name)));
                                  _newSingleItemDragDropList.addAll(detail.files);
                                  context.read<stateProvider>().singleItemsDropAdd(detail.files);
                                });
                              },
                              onDragEntered: (detail) {
                                setState(() {
                                  _dragging = true;
                                });
                              },
                              onDragExited: (detail) {
                                setState(() {
                                  _dragging = false;
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: Theme.of(context).hintColor),
                                    color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                                  ),
                                  height: 110,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_newSingleItemDragDropList.isEmpty) const Center(child: Text("Drop Modded .ice Files And Folder(s) Here To Add")),
                                      if (_newSingleItemDragDropList.isNotEmpty)
                                        Expanded(
                                          child: SingleChildScrollView(
                                            controller: ScrollController(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                                    child: Text(context.watch<stateProvider>().newSingleItemDropDisplay),
                                                  )),
                                            ),
                                          ),
                                        )
                                    ],
                                  )),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                                  child: CustomDropdownButton2(
                                    hint: 'Select a Category',
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).cardColor),
                                    ),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).hintColor),
                                    ),
                                    //buttonWidth: 300,
                                    buttonHeight: 40,
                                    itemHeight: 40,
                                    dropdownElevation: 3,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    //dropdownWidth: 361,
                                    dropdownHeight: double.maxFinite,
                                    dropdownItems: dropdownCategories,
                                    value: selectedCategoryForSingleItem,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategoryForSingleItem = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Form(
                              key: newSingleItemFormKey,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                                child: TextFormField(
                                  controller: newSingleItemAddController,
                                  //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  //maxLength: 100,
                                  style: const TextStyle(fontSize: 15),
                                  decoration: const InputDecoration(
                                    labelText: 'Item Name',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      isErrorInSingleItemName = true;
                                      return 'Name can\'t be empty';
                                    }
                                    if (cateList.indexWhere((e) => e.categoryName == selectedCategoryForSingleItem && e.itemNames.indexWhere((element) => element == value) != -1) != -1) {
                                      isErrorInSingleItemName = true;
                                      return 'The name already exist';
                                    }
                                    return null;
                                  },
                                  onChanged: (text) {
                                    setState(() {
                                      setState(
                                        () {},
                                      );
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      //Multiple Item Adding Tab
                      Column(
                        children: [
                          //Drop Zone,
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                            child: DropTarget(
                              //enable: true,
                              onDragDone: (detail) {
                                setState(() {
                                  var leftoverFiles = [];
                                  detail.files.sort(((a, b) => a.name.compareTo(b.name)));
                                  for (var file in detail.files) {
                                    if (Directory(file.path).existsSync()) {
                                      _newItemDragDropList.addAll(detail.files);
                                      context.read<stateProvider>().itemsDropAdd(detail.files);
                                    } else {
                                      leftoverFiles.add(file.name);
                                    }
                                  }

                                  if (leftoverFiles.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        duration: Duration(seconds: leftoverFiles.length),
                                        //backgroundColor: Theme.of(context).focusColor,
                                        content: SizedBox(
                                          height: 20 + (leftoverFiles.length * 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'The file(s) bellow won\'t be added. Use the \'Single Item\' Tab or \'Add Mod\' instead.',
                                                style: TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              for (int i = 0; i < leftoverFiles.length; i++) Text(leftoverFiles[i]),
                                            ],
                                          ),
                                        )));
                                  }
                                  leftoverFiles.clear();
                                });
                              },
                              onDragEntered: (detail) {
                                setState(() {
                                  _dragging = true;
                                });
                              },
                              onDragExited: (detail) {
                                setState(() {
                                  _dragging = false;
                                });
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: Theme.of(context).hintColor),
                                    color: _dragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                                  ),
                                  height: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_newItemDragDropList.isEmpty) const Center(child: Text("Drop Modded Item Folder(s) Here To Add")),
                                      if (_newItemDragDropList.isNotEmpty)
                                        Expanded(
                                          child: SingleChildScrollView(
                                            controller: ScrollController(),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: SizedBox(
                                                  width: double.infinity,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 5),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                                      child: Text(context.watch<stateProvider>().newItemDropDisplay),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        )
                                    ],
                                  )),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                                  child: CustomDropdownButton2(
                                    key: _newItemDropdownKey,
                                    hint: 'Select a Category',
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).cardColor),
                                    ),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).hintColor),
                                    ),
                                    //buttonWidth: 300,
                                    buttonHeight: 43,
                                    itemHeight: 40,
                                    dropdownElevation: 3,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 30,
                                    //dropdownWidth: 361,
                                    dropdownHeight: double.maxFinite,
                                    dropdownItems: dropdownCategories,
                                    value: selectedCategoryForMutipleItems,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategoryForMutipleItems = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: Form(
                              //     key: newMultipleItemsFormKey,
                              //     child: Padding(
                              //       padding: const EdgeInsets.only(top: 10, bottom: 0, left: 5, right: 10),
                              //       child: TextFormField(
                              //         controller: newItemAddController,
                              //         //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              //         //maxLength: 100,
                              //         style: const TextStyle(fontSize: 15),
                              //         decoration: const InputDecoration(
                              //           labelText: 'Change Item Name\n(optional, single item)',
                              //           border: OutlineInputBorder(),
                              //           isDense: true,
                              //         ),
                              //         validator: (value) {
                              //           // if (value == null || value.isEmpty) {
                              //           //   return 'Category name can\'t be empty';
                              //           // }
                              //           if (cateList.indexWhere((e) => e.categoryName == selectedCategoryForMutipleItems && e.itemNames.indexWhere((element) => element == value) != -1) != -1) {
                              //             return 'The name already exist';
                              //           }
                              //           return null;
                              //         },
                              //         onChanged: (text) {
                              //           setState(() {
                              //             setState(
                              //               () {},
                              //             );
                              //           });
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                //Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                            onPressed: isItemAddBtnClicked
                                ? null
                                : (() {
                                    setState(() {
                                      _newItemDragDropList.clear();
                                      _newSingleItemDragDropList.clear();
                                      newItemAddController.clear();
                                      newSingleItemAddController.clear();
                                      selectedCategoryForMutipleItems = null;
                                      selectedCategoryForSingleItem = null;
                                      isErrorInSingleItemName = false;
                                      context.read<stateProvider>().singleItemDropAddClear();
                                      context.read<stateProvider>().itemsDropAddClear();
                                      //addItemVisible = false;
                                      switch (itemAdderAniController.status) {
                                        case AnimationStatus.completed:
                                          itemAdderAniController.reverse().whenComplete(() {
                                            addItemVisible = false;
                                            setState(() {});
                                          });
                                          break;
                                        default:
                                      }
                                    });
                                  }),
                            child: const Text('Close'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                              onPressed: (selectedCategoryForMutipleItems != null && _newItemDragDropList.isNotEmpty && !isItemAddBtnClicked) ||
                                      (selectedCategoryForSingleItem != null && _newSingleItemDragDropList.isNotEmpty && !isItemAddBtnClicked)
                                  ? (() {
                                      setState(() {
                                        //if (newMultipleItemsFormKey.currentState!.validate() && _itemAdderTabcontroller.index == 1) {
                                        if (_itemAdderTabcontroller.index == 1) {
                                          isItemAddBtnClicked = true;
                                          dragDropFilesAdd(context, _newItemDragDropList, selectedCategoryForMutipleItems, newItemAddController.text.isEmpty ? null : newItemAddController.text)
                                              .then((_) {
                                            setState(() {
                                              //setstate to refresh list
                                              _newItemDragDropList.clear();
                                              newItemAddController.clear();
                                              isItemAddBtnClicked = false;
                                            });
                                          });
                                          //selectedCategoryForMutipleItems = null;
                                          //addItemVisible = false;
                                        } else if (newSingleItemFormKey.currentState!.validate() && _itemAdderTabcontroller.index == 0) {
                                          isErrorInSingleItemName = false;
                                          isItemAddBtnClicked = true;
                                          dragDropSingleFilesAdd(
                                                  context, _newSingleItemDragDropList, selectedCategoryForSingleItem, newSingleItemAddController.text.isEmpty ? null : newSingleItemAddController.text)
                                              .then((_) {
                                            setState(() {
                                              //setstate to refresh list
                                              _newSingleItemDragDropList.clear();
                                              newSingleItemAddController.clear();
                                              isItemAddBtnClicked = false;
                                            });
                                          });
                                        }
                                      });
                                    })
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [Text('Add')],
                              )),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
      ],
    );
  }

  Widget modsView() {
    return Column(
      children: [
        AppBar(
          title: Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  modsViewAppBarName.isEmpty ? const Text('Available Mods') : Text(modsViewAppBarName),
                ],
              )),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          actions: [
            Tooltip(
                message: modsViewAppBarName == '' || modsViewAppBarName == 'Available Mods' ? 'Add Mods' : 'Add Mods To $modsViewAppBarName',
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: SizedBox(
                  width: 40,
                  height: 30,
                  child: MaterialButton(
                      onPressed: addModToItemVisible || modsViewAppBarName.isEmpty || !isModSelected
                          ? null
                          : (() {
                              setState(() {
                                //addModToItemVisible = true;
                                switch (modAdderAniController.status) {
                                  case AnimationStatus.dismissed:
                                    addModToItemVisible = true;
                                    modAdderAniController.forward();
                                    break;
                                  default:
                                }
                              });
                            }),
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_box_outlined,
                            color: addModToItemVisible || modsViewAppBarName.isEmpty || !isModSelected
                                ? Theme.of(context).disabledColor
                                : MyApp.themeNotifier.value == ThemeMode.light
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).iconTheme.color,
                          )
                        ],
                      )),
                )),
          ],
        ),

        //Mod view
        if (isModSelected)
          Expanded(
              child: FutureBuilder(
                  future: modFilesListGet,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        modFilesList = snapshot.data;
                        if (isLoading.isEmpty) {
                          isLoading = List.generate(modFilesList.length, (index) => false);
                        }
                        //print(snapshot.data);
                        return SingleChildScrollView(
                            controller: AdjustableScrollController(80),
                            child: ListView.builder(
                                key: Key('builder ${modNameCatSelected.toString()}'),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: modFilesList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () {},
                                      onHover: (value) {
                                        if (value) {
                                          setState(() {
                                            isPreviewImgsOn = true;
                                            futureImagesGet = modFilesList[index].first.images;
                                            previewPlayer.stop();
                                            previewPlayer.setVolume(0);
                                            previewPlayer.open(Playlist(medias: medias), autoStart: true);
                                            ;
                                          });
                                        }
                                        // else {
                                        //   setState(() {
                                        //     isPreviewImgsOn = false;
                                        //   });
                                        // }
                                      },
                                      child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                              side: BorderSide(width: 1, color: modFilesList[index].indexWhere((e) => e.isNew == true) != -1 ? Colors.amber : Theme.of(context).primaryColorLight)),
                                          child: ExpansionTile(
                                            initiallyExpanded: modViewExpandAll,
                                            textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                            iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                            collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(modFilesList[index].first.iceParent),
                                                ),
                                                //if (modFilesList[index].length > 1)
                                                Row(
                                                  children: [
                                                    if (isLoading[index])
                                                      const SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: CircularProgressIndicator(),
                                                      ),
                                                    //Buttons
                                                    if (modFilesList[index].length > 1 && modFilesList[index].indexWhere((element) => element.isApplied == true) != -1 && !isLoading[index])
                                                      SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: Tooltip(
                                                          message: 'Remove all mods under "$modsViewAppBarName ${modFilesList[index].first.iceParent}" from the game',
                                                          height: 25,
                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                          waitDuration: const Duration(seconds: 1),
                                                          child: MaterialButton(
                                                            onPressed: (() {
                                                              setState(() {
                                                                modsRemover(modFilesList[index].toList());
                                                              });
                                                            }),
                                                            child: Icon(
                                                              Icons.playlist_remove,
                                                              color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (modFilesList[index].length > 1 && modFilesList[index].indexWhere((element) => element.isApplied == false) != -1 && !isLoading[index])
                                                      SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: Tooltip(
                                                          message: 'Apply mods under ${modFilesList[index].first.iceParent} to the game',
                                                          height: 25,
                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                          waitDuration: const Duration(seconds: 1),
                                                          child: MaterialButton(
                                                            onPressed: (() {
                                                              setState(() {
                                                                isLoading[index] = true;
                                                                modsToDataAdder(modFilesList[index]).then((_) {
                                                                  setState(() {
                                                                    isLoading[index] = false;
                                                                    //Messages
                                                                    if (originalFilesMissingList.isNotEmpty) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                          duration: const Duration(seconds: 2),
                                                                          //backgroundColor: Theme.of(context).focusColor,
                                                                          content: SizedBox(
                                                                            height: originalFilesMissingList.length * 20,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                for (int i = 0; i < originalFilesMissingList.length; i++)
                                                                                  Text(
                                                                                      'Original file of "${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}" is not found'),
                                                                              ],
                                                                            ),
                                                                          )));
                                                                    }

                                                                    if (modAppliedDup.isNotEmpty) {
                                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                          duration: Duration(seconds: modAppliedDup.length),
                                                                          //backgroundColor: Theme.of(context).focusColor,
                                                                          content: SizedBox(
                                                                            height: modAppliedDup.length * 20,
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                for (int i = 0; i < modAppliedDup.length; i++)
                                                                                  Text(
                                                                                      'Replaced: ${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
                                                                              ],
                                                                            ),
                                                                          )));
                                                                      modAppliedDup.clear();
                                                                    }
                                                                  });
                                                                });
                                                              });
                                                            }),
                                                            child: Icon(
                                                              Icons.playlist_add,
                                                              color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    Tooltip(
                                                        message: 'Remove $modsViewAppBarName ${modFilesList[index].first.iceParent}',
                                                        height: 25,
                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                        waitDuration: const Duration(seconds: 2),
                                                        child: SizedBox(
                                                          width: 36,
                                                          height: 40,
                                                          child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  if (modFilesList[index].indexWhere((element) => element.isApplied == true) == -1) {
                                                                    modDeleteDialog(
                                                                            context,
                                                                            100,
                                                                            'Remove Mods',
                                                                            'Remove "$modsViewAppBarName ${modFilesList[index].first.iceParent}" and move it to Deleted Items folder?\nThis will also remove all filess in this mod',
                                                                            true,
                                                                            modFilesList[index].first.modPath,
                                                                            modFilesList[index].first.iceParent,
                                                                            modFilesList[index].first.modName,
                                                                            modFilesList[index])
                                                                        .then((_) {
                                                                      setState(() {
                                                                        //setstate to refresh list
                                                                      });
                                                                    });
                                                                  } else {
                                                                    List<ModFile> tempList = cateList[index]
                                                                        .allModFiles
                                                                        .where((element) => element.modName == modFilesList[index].first.modName && element.isApplied == true)
                                                                        .toList();
                                                                    List<String> stillAppliedList = [];
                                                                    double popupHeight = 40;
                                                                    for (var element in tempList) {
                                                                      stillAppliedList.add('${element.modName}${element.iceParent} > ${element.iceName}');
                                                                      popupHeight += 24;
                                                                    }
                                                                    String stillApplied = stillAppliedList.join('\n');
                                                                    modDeleteDialog(
                                                                        context,
                                                                        popupHeight,
                                                                        'Remove Mod',
                                                                        'Cannot remove "$modsViewAppBarName ${modFilesList[index].first.iceParent}". Unaplly these files first:\n\n$stillApplied',
                                                                        false,
                                                                        modFilesList[index].first.modPath,
                                                                        modFilesList[index].first.iceParent,
                                                                        modFilesList[index].first.modName, []);
                                                                  }
                                                                });
                                                              }),
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons.delete_rounded,
                                                                    size: 20,
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
                                              for (int i = 0; i < modFilesList[index].length; i++)
                                                InkWell(
                                                    // onHover: (value) {
                                                    //   if (value &&
                                                    //       modPreviewImgList.indexWhere((e) =>
                                                    //               e.path.contains(
                                                    //                   modFilesList[
                                                    //                           index]
                                                    //                       .first
                                                    //                       .iceParent)) ==
                                                    //           -1) {
                                                    //     setState(() {
                                                    //       isPreviewImgsOn = true;
                                                    //       futureImagesGet =
                                                    //           modFilesList[index]
                                                    //                   [i]
                                                    //               .images;
                                                    //     });
                                                    //   }
                                                    // },
                                                    child: ListTile(
                                                  leading: modFilesList[index][i].isNew == true
                                                      ? const Icon(
                                                          Icons.new_releases,
                                                          color: Colors.amber,
                                                        )
                                                      : null,
                                                  title: Text(modFilesList[index][i].iceName),
                                                  //subtitle: Text(modFilesList[index][i].icePath),
                                                  minLeadingWidth: 10,
                                                  trailing: SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: modFilesList[index][i].isApplied
                                                        ? Tooltip(
                                                            message: 'Remove this mod from the game',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 2),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsRemover([modFilesList[index][i]]);
                                                                  //appliedModsList.remove(modFilesList[index]);
                                                                  if (backupFilesMissingList.isNotEmpty) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: const Duration(seconds: 2),
                                                                        //backgroundColor: Theme.of(context).focusColor,
                                                                        content: SizedBox(
                                                                          height: backupFilesMissingList.length * 20,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              for (int i = 0; i < backupFilesMissingList.length; i++)
                                                                                Text(
                                                                                    'Backup file of "${backupFilesMissingList[i].modName} ${backupFilesMissingList[i].iceParent} > ${backupFilesMissingList[i].iceName}" is not found'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }
                                                                });
                                                              }),
                                                              child: const Icon(Icons.replay),
                                                            ))
                                                        : Tooltip(
                                                            message: 'Apply this mod to the game',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 2),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsToDataAdder([modFilesList[index][i]]);
                                                                  //appliedModsList.add(modFilesList[index]);
                                                                  if (originalFilesMissingList.isNotEmpty) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: const Duration(seconds: 2),
                                                                        //backgroundColor: Theme.of(context).focusColor,
                                                                        content: SizedBox(
                                                                          height: originalFilesMissingList.length * 20,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              for (int i = 0; i < originalFilesMissingList.length; i++)
                                                                                Text(
                                                                                    'Original file of "${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}" is not found'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }

                                                                  if (modAppliedDup.isNotEmpty) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: Duration(seconds: modAppliedDup.length),
                                                                        //backgroundColor: Theme.of(context).focusColor,
                                                                        content: SizedBox(
                                                                          height: modAppliedDup.length * 20,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              for (int i = 0; i < modAppliedDup.length; i++)
                                                                                Text(
                                                                                    'Replaced: ${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }

                                                                  modAppliedDup.clear();
                                                                });
                                                              }),
                                                              child: const Icon(Icons.add_to_drive),
                                                            ),
                                                          ),
                                                  ),
                                                ))
                                            ],
                                          )));
                                }));
                      }
                    }
                  })),

        //Add Mod to Existing Item
        if (addModToItemVisible)
          SlideTransition(
            position: modAdderAniOffset,
            child: Container(
              //height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    spreadRadius: -1,
                    blurRadius: 3,
                    offset: const Offset(0, -4), // changes position of shadow
                  ),
                ],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                //Drop Zone
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                  child: DropTarget(
                    //enable: true,
                    onDragDone: (detail) {
                      setState(() {
                        detail.files.sort(((a, b) => a.name.compareTo(b.name)));
                        _newModToItemDragDropList.addAll(detail.files);
                        context.read<stateProvider>().modsDropAdd(detail.files);
                      });
                    },
                    onDragEntered: (detail) {
                      setState(() {
                        _newModToItemDragging = true;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _newModToItemDragging = false;
                      });
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Theme.of(context).hintColor),
                          color: _newModToItemDragging ? Colors.blue.withOpacity(0.4) : Colors.black26,
                        ),
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_newModToItemDragDropList.isEmpty) const Center(child: Text("Drop Modded .ice Files And Folder(s) Here To Add")),
                            if (_newModToItemDragDropList.isNotEmpty)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Text(context.watch<stateProvider>().newModDropDisplay),
                                        )),
                                  ),
                                ),
                              )
                          ],
                        )),
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: newModToItemFormKey,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                          child: TextFormField(
                            controller: newModToItemAddController,
                            //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            //maxLength: 100,
                            style: const TextStyle(fontSize: 15),
                            decoration: const InputDecoration(
                              labelText: 'Mod Name',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Mod name can\'t be empty';
                              }
                              if (modFilesList.indexWhere((e) => e.indexWhere((element) => element.iceParent.split(' > ').last == value) != -1) != -1) {
                                return 'Mod name already exist';
                              }
                              return null;
                            },
                            onChanged: (text) {
                              setState(() {
                                setState(
                                  () {},
                                );
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                //Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                              onPressed: isModAddBtnClicked
                                  ? null
                                  : (() {
                                      setState(() {
                                        _newModToItemDragDropList.clear();
                                        newModToItemAddController.clear();
                                        context.read<stateProvider>().modsDropAddClear();
                                        //addModToItemVisible = false;
                                        switch (modAdderAniController.status) {
                                          case AnimationStatus.completed:
                                            modAdderAniController.reverse().whenComplete(() {
                                              addModToItemVisible = false;
                                              setState(() {});
                                            });
                                            break;
                                          default:
                                        }
                                      });
                                    }),
                              child: const Text('Close')),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                              onPressed: _newModToItemDragDropList.isNotEmpty && !isModAddBtnClicked
                                  ? (() {
                                      setState(() {
                                        if (newModToItemFormKey.currentState!.validate()) {
                                          if (modFilesList.isNotEmpty) {
                                            isModAddBtnClicked = true;
                                            dragDropModsAdd(context, _newModToItemDragDropList, modsViewAppBarName, modFilesList.first.first.modPath, _newModToItemIndex,
                                                    newModToItemAddController.text.isEmpty ? null : newModToItemAddController.text)
                                                .then((_) {
                                              setState(() {
                                                //setstate to refresh list
                                                _newModToItemDragDropList.clear();
                                                newModToItemAddController.clear();
                                                isModAddBtnClicked = false;
                                                isPreviewImgsOn = false;
                                              });
                                            });
                                          }

                                          //addItemVisible = false;
                                        }
                                      });
                                    })
                                  : null,
                              child: const Text('Add')),
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          ),
      ],
    );
  }

  Widget modPreviewView() {
    return Column(
      children: [
        //if (context.watch<stateProvider>().previewWindowVisible)
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Preview')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
        ),
        if (isPreviewImgsOn && !isPreviewVidOn)
          Expanded(
              child: FutureBuilder(
                  future: futureImagesGet,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        modPreviewImgList = snapshot.data;
                        //print(modPreviewImgList.toString());
                        List<Widget> previewImageSliders = modPreviewImgList
                            .map((item) => Container(
                                  margin: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      child: Stack(
                                        children: <Widget>[
                                          Image.file(item, fit: BoxFit.cover, width: 1000.0),
                                          //Text(modPreviewImgList.toString())
                                        ],
                                      )),
                                ))
                            .toList();
                        return Column(
                          children: [
                            Expanded(
                              child: CarouselSlider(
                                items: previewImageSliders,
                                carouselController: imgSliderController,
                                options: CarouselOptions(
                                    autoPlay: previewImageSliders.length > 1,
                                    reverse: true,
                                    viewportFraction: 1,
                                    enlargeCenterPage: true,
                                    //aspectRatio: 1.0,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentImg = index;
                                      });
                                    }),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (previewImageSliders.isNotEmpty)
                                  SizedBox(
                                    width: 40,
                                    child: MaterialButton(
                                      onPressed: (() => imgSliderController.previousPage()),
                                      child: const Icon(Icons.arrow_left),
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: modPreviewImgList.asMap().entries.map((entry) {
                                    return GestureDetector(
                                      onTap: () => imgSliderController.animateToPage(entry.key),
                                      child: Container(
                                        width: 10.0,
                                        height: 10.0,
                                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentImg == entry.key ? 0.9 : 0.4)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (previewImageSliders.isNotEmpty)
                                  SizedBox(
                                    width: 40,
                                    child: MaterialButton(
                                      onPressed: (() => imgSliderController.nextPage()),
                                      child: const Icon(Icons.arrow_right),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }
                    }
                  })),
        if (isPreviewVidOn)
          Expanded(
            child: Scaffold(
              body: Video(
                player: previewPlayer,
                fit: BoxFit.fill,
              ),
            ),
          )
      ],
    );
  }

  Widget filesView() {
    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Applied Mods')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          actions: [
            SizedBox(
              width: 40,
              height: 40,
              child: Tooltip(
                message: 'Hold to remove all applied mods from the game',
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: MaterialButton(
                  onLongPress: appliedModsList.isEmpty
                      ? null
                      : (() {
                          setState(() {
                            List<ModFile> tempDelete = [];
                            for (var list in appliedModsList) {
                              for (var mod in list) {
                                tempDelete.add(mod);
                              }
                            }
                            modsRemover(tempDelete);
                          });
                        }),
                  onPressed: appliedModsList.isEmpty ? null : () {},
                  child: Icon(
                    Icons.playlist_remove,
                    color: appliedModsList.isEmpty
                        ? Theme.of(context).disabledColor
                        : MyApp.themeNotifier.value == ThemeMode.light
                            ? Theme.of(context).primaryColorDark
                            : Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
            child: FutureBuilder(
                future: appliedModsListGet,
                builder: (
                  BuildContext context,
                  AsyncSnapshot snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      appliedModsList = snapshot.data;
                      //print(snapshot.data);
                      return SingleChildScrollView(
                          controller: AdjustableScrollController(80),
                          child: ListView.builder(
                              //key: Key('builder ${modNameCatSelected.toString()}'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: appliedModsList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                    onTap: () {},
                                    onHover: (value) {
                                      if (value) {
                                        setState(() {
                                          isPreviewImgsOn = true;
                                          futureImagesGet = appliedModsList[index].first.images;
                                        });
                                      }
                                      // else {
                                      //   setState(() {
                                      //     isPreviewImgsOn = false;
                                      //   });
                                      // }
                                    },
                                    child: Card(
                                        shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(5.0)), side: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
                                        child: ExpansionTile(
                                          initiallyExpanded: false,
                                          textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                          iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                          collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                  child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${appliedModsList[index].first.categoryName} > ${appliedModsList[index].first.modName}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      )),
                                                  Text(appliedModsList[index].first.iceParent.trimLeft()),
                                                ],
                                              )),
                                              //if (appliedModsList[index].length > 1)
                                              Row(
                                                children: [
                                                  if (appliedModsList.indexWhere((element) => element.indexWhere((e) => e.isApplied == true) != -1) != -1)
                                                    SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: Tooltip(
                                                        message: 'Remove mods under "$modsViewAppBarName ${appliedModsList[index].first.iceParent}" from the game',
                                                        height: 25,
                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                        waitDuration: const Duration(seconds: 2),
                                                        child: MaterialButton(
                                                          onPressed: (() {
                                                            setState(() {
                                                              modsRemover(appliedModsList[index].toList());
                                                            });
                                                          }),
                                                          child: Icon(
                                                            Icons.playlist_remove,
                                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              )
                                            ],
                                          ),
                                          children: [
                                            for (int i = 0; i < appliedModsList[index].length; i++)
                                              InkWell(
                                                // onHover: (value) {
                                                //   if (value &&
                                                //       modPreviewImgList.indexWhere((e) =>
                                                //               e.path.contains(
                                                //                   modFilesList[
                                                //                           index]
                                                //                       .first
                                                //                       .iceParent)) ==
                                                //           -1) {
                                                //     setState(() {
                                                //       isPreviewImgsOn = true;
                                                //       futureImagesGet =
                                                //           modFilesList[index]
                                                //                   [i]
                                                //               .images;
                                                //     });
                                                //   }
                                                // },
                                                child: ListTile(
                                                  // leading: appliedModsList[index][i].isNew == true
                                                  //     ? Icon(
                                                  //         Icons.new_releases,
                                                  //         color: Theme.of(context).indicatorColor,
                                                  //       )
                                                  //     : null,
                                                  title: Text(appliedModsList[index][i].iceName),
                                                  //subtitle: Text(modFilesList[index][i].icePath),
                                                  minLeadingWidth: 10,
                                                  trailing: SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: appliedModsList[index][i].isApplied
                                                        ? Tooltip(
                                                            message: 'Remove this mod from the game',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 2),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsRemover([appliedModsList[index][i]]);
                                                                  //appliedModsList.remove(modFilesList[index]);
                                                                  if (backupFilesMissingList.isNotEmpty) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: const Duration(seconds: 2),
                                                                        //backgroundColor: Theme.of(context).focusColor,
                                                                        content: SizedBox(
                                                                          height: backupFilesMissingList.length * 20,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              for (int i = 0; i < backupFilesMissingList.length; i++)
                                                                                Text(
                                                                                    'Backup file of "${backupFilesMissingList[i].modName} ${backupFilesMissingList[i].iceParent} > ${backupFilesMissingList[i].iceName}" is not found'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }
                                                                });
                                                              }),
                                                              child: const Icon(Icons.replay),
                                                            ))
                                                        : Tooltip(
                                                            message: 'Apply this mod to the game',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 1),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsToDataAdder([appliedModsList[index][i]]);
                                                                  //appliedModsList.add(modFilesList[index]);
                                                                  if (originalFilesMissingList.isNotEmpty) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                        duration: const Duration(seconds: 2),
                                                                        //backgroundColor: Theme.of(context).focusColor,
                                                                        content: SizedBox(
                                                                          height: originalFilesMissingList.length * 20,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              for (int i = 0; i < originalFilesMissingList.length; i++)
                                                                                Text(
                                                                                    'Original file of "${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}" is not found'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }
                                                                });
                                                              }),
                                                              child: const Icon(Icons.add_to_drive),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        )));
                              }));
                    }
                  }
                }))
      ],
    );
  }
}
