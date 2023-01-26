// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

List<ModCategory> cateList = [];
List<ModCategory> cateListSearchResult = [];
Future? modFilesListGet;
Future? modFilesListFromSetGet;
Future? futureImagesGet;
Future? appliedModsListGet;
Future? modSetsListGet;
List<File> modPreviewImgList = [];
List<List<List<ModFile>>> modFilesList = [];
List<List<ModFile>> modFilesFromSetList = [];
List<List<ModFile>> appliedModsList = [];
List<ModFile> modAppliedDup = [];
List<ModFile> originalFilesMissingList = [];
List<ModFile> backupFilesMissingList = [];
List<ModSet> setsList = [];
List<String> setsDropDownList = [];
String? setsSelectedDropDown;
List<List<bool>> isLoading = [];
List<bool> isLoadingSetList = [];
List<bool> isLoadingModSetList = [];
List<bool> isLoadingAppliedList = [];
List<String> sortTypeList = [curLangText!.sortCateByNameText, curLangText!.sortCateByNumItemsText];
int selectedSortType = 0;
String selectedSortTypeString = '';
bool isModAddFolderOnly = true;
bool isViewingFav = false;
bool isSearching = false;
bool isRefreshing = false;
bool previewZoomState = true;
int totalAppliedItems = 0;
int totalAppliedFiles = 0;
TextEditingController searchBoxTextController = TextEditingController();
String modsViewAppBarName = '';
String modsSetAppBarName = '';
List<String> defaultCatesList = [
  'Favorites',
  'Accessories',
  'Basewears',
  'Body Paints',
  'Emotes',
  'Face Paints',
  'Innerwears',
  'Misc',
  'Motions',
  'Outerwears',
  'Setwears',
  'Mags',
  'Stickers',
  'Hairs',
  'Cast Body Parts',
  'Cast Arm Parts',
  'Cast Leg Parts',
  'Eyes',
  'Costumes'
];

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
TextEditingController newSingleItemModNameController = TextEditingController();
List<String> dropdownCategories = [];
String? selectedCategoryForMutipleItems;
String? selectedCategoryForSingleItem;
final _newItemDropdownKey = GlobalKey<FormState>();
bool _dragging = false;
bool _draggingItemIcon = false;
//final List<XFile> _newItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test')];
final List<XFile> _newItemDragDropList = [];
final List<XFile> _newSingleItemDragDropList = [];
XFile? _singleItemIcon;
bool isItemAddBtnClicked = false;
String curClickedCategory = '';

//NewItem Exist Item
bool addModToItemVisible = false;
final newModToItemFormKey = GlobalKey<FormState>();
TextEditingController newModToItemAddController = TextEditingController();
bool _newModToItemDragging = false;
//final List<XFile> _newModToItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test\\Red ball gag - Copy')];
final List<XFile> _newModToItemDragDropList = [];
//int _newModToItemIndex = 0;
bool isModAddBtnClicked = false;

//Media Player controls
Player previewPlayer = Player(id: 69, commandlineArguments: ['--no-video-title-show']);
MediaType mediaType = MediaType.file;
CurrentState current = CurrentState();
List<Media> medias = <Media>[];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.285), Area(weight: 0.335)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.40)]);

  List<int> selectedIndex = List.generate(cateList.length, (index) => -1);
  List<int> searchListSelectedIndex = List.generate(cateListSearchResult.length, (index) => -1);
  CarouselController imgSliderController = CarouselController();
  List<Widget> previewImageSliders = [];

  int modNameCatSelected = -1;
  bool isModSelected = false;
  bool isSetSelected = false;
  int currentImg = 0;
  bool isPreviewImgsOn = false;
  bool isPreviewVidOn = false;
  bool modViewExpandAll = false;
  bool isErrorInSingleItemName = false;
  double searchBoxLeftPadding = 80;
  int reappliedCount = 0;
  int setApplyingIndex = -1;

  //Slide up
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
    _itemAdderTabcontroller.addListener(() {
      setState(() {
        if (_itemAdderTabcontroller.index == 0) {
          _newItemDragDropList.clear();
          newItemAddController.clear();
          selectedCategoryForMutipleItems = null;
          //isErrorInSingleItemName = false;
          context.read<StateProvider>().itemsDropAddClear();
        } else {
          _newSingleItemDragDropList.clear();
          _singleItemIcon = null;
          newSingleItemAddController.clear();
          newSingleItemModNameController.clear();
          selectedCategoryForSingleItem = null;
          isErrorInSingleItemName = false;
          context.read<StateProvider>().singleItemDropAddClear();
        }
      });
    });
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
    _verticalViewsController.dispose();
    super.dispose();
  }

  void refreshHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MultiSplitView mainViews = MultiSplitView(
      controller: _viewsController,
      children: [
        if (!context.watch<StateProvider>().setsWindowVisible) itemsView(),
        if (!context.watch<StateProvider>().setsWindowVisible) modsView(),
        if (context.watch<StateProvider>().setsWindowVisible) setList(),
        if (context.watch<StateProvider>().setsWindowVisible) modInSetList(),
        if (!context.watch<StateProvider>().previewWindowVisible) filesView(),
        if (context.watch<StateProvider>().previewWindowVisible)
          MultiSplitView(
            axis: Axis.vertical,
            controller: _verticalViewsController,
            children: [modPreviewView(), filesView()],
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

    return context.watch<StateProvider>().languageReload
        ? Column(
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
          )
        : viewsTheme;
  }

  Widget itemsView() {
    dropdownCategories.clear();
    for (var category in cateList) {
      if (category.categoryName != 'Favorites') {
        dropdownCategories.add(category.categoryName);
      }
    }

    if (selectedSortType == 0) {
      selectedSortTypeString = curLangText!.sortCateByNameText;
    } else {
      selectedSortTypeString = curLangText!.sortCateByNumItemsText;
    }

    return Column(
      children: [
        AppBar(
          automaticallyImplyLeading: false,
          title: searchBoxLeftPadding == 15 ? null : Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.itemsHeaderText)),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          flexibleSpace: Container(
              height: 30,
              width: double.maxFinite,
              padding: EdgeInsets.only(left: searchBoxLeftPadding, right: 135, bottom: 3),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    if (hasFocus) {
                      searchBoxLeftPadding = 15;
                    } else {
                      if (searchBoxTextController.text.isEmpty) {
                        searchBoxLeftPadding = 80;
                      } else {
                        searchBoxLeftPadding = 15;
                      }
                    }
                  });
                },
                child: TextFormField(
                  controller: searchBoxTextController,
                  maxLines: 1,
                  onChanged: (value) {
                    if (value != '') {
                      setState(() {
                        modFilesList.clear();
                        modsViewAppBarName = curLangText!.availableModsHeaderText;
                        isSearching = true;
                        cateListSearchResult = searchFilterResults(cateList, value);
                        searchListSelectedIndex = List.generate(cateListSearchResult.length, (index) => -1);
                      });
                    } else {
                      setState(() {
                        isSearching = false;
                        modFilesList.clear();
                        modsViewAppBarName = curLangText!.availableModsHeaderText;
                        cateListSearchResult = [];
                      });
                    }
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 10, top: 10),
                      border: const OutlineInputBorder(),
                      hintText: curLangText!.searchLabelText,
                      suffixIcon: searchBoxTextController.text == ''
                          ? null
                          : SizedBox(
                              width: 25,
                              child: MaterialButton(
                                  onPressed: searchBoxTextController.text == ''
                                      ? null
                                      : (() {
                                          setState(() {
                                            searchBoxTextController.clear();
                                            modFilesList.clear();
                                            modsViewAppBarName = curLangText!.availableModsHeaderText;
                                            isSearching = false;
                                            searchBoxLeftPadding = 80;
                                          });
                                        }),
                                  child: const Icon(Icons.clear)),
                            )),
                ),
              )),
          actions: [
            Tooltip(
                message: curLangText!.refreshBtnTootipText,
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: SizedBox(
                  width: 40,
                  height: 30,
                  child: MaterialButton(
                      onPressed: isRefreshing
                          ? null
                          : (() {
                              if (!isRefreshing) {
                                //closing adders
                                setState(() {
                                  if (addCategoryVisible) {
                                    categoryAddController.clear();
                                    //addCategoryVisible = false;
                                    switch (cateAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        cateAdderAniController.reverse().whenComplete(() {
                                          addCategoryVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;

                                      default:
                                    }
                                  }

                                  if (addItemVisible) {
                                    _newItemDragDropList.clear();
                                    _newSingleItemDragDropList.clear();
                                    _singleItemIcon = null;
                                    newItemAddController.clear();
                                    newSingleItemAddController.clear();
                                    newSingleItemModNameController.clear();
                                    selectedCategoryForMutipleItems = null;
                                    selectedCategoryForSingleItem = null;
                                    isErrorInSingleItemName = false;
                                    context.read<StateProvider>().singleItemDropAddClear();
                                    context.read<StateProvider>().itemsDropAddClear();
                                    Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
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
                                  }

                                  if (addModToItemVisible) {
                                    _newModToItemDragDropList.clear();
                                    newModToItemAddController.clear();
                                    isModAddFolderOnly = true;
                                    context.read<StateProvider>().modsDropAddClear();
                                    //addModToItemVisible = false;
                                    switch (modAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        modAdderAniController.reverse().whenComplete(() {
                                          addModToItemVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;
                                      default:
                                    }
                                  }

                                  isModSelected = false;
                                  modsViewAppBarName = curLangText!.availableModsHeaderText;
                                  isRefreshing = true;
                                });
                              }
                              Future.delayed(const Duration(milliseconds: 500), () async {
                                allModFiles = await modsLoader();
                                cateList = categories(allModFiles);
                                appliedModsListGet = getAppliedModsList();
                                iceFiles = dataDir.listSync(recursive: true).whereType<File>().toList();
                                // ignore: use_build_context_synchronously
                                Provider.of<StateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);
                                isRefreshing = false;
                              }).whenComplete(() {
                                isRefreshing = false;
                                setState(() {});
                              });
                            }),
                      child: Row(
                        children: [
                          Icon(
                            Icons.refresh,
                            color: isRefreshing
                                ? Theme.of(context).disabledColor
                                : MyApp.themeNotifier.value == ThemeMode.light
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).iconTheme.color,
                          )
                        ],
                      )),
                )),
            Tooltip(
                message: curLangText!.newCatBtnTooltipText,
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
                                    Provider.of<StateProvider>(context, listen: false).addingBoxStateTrue();
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
                )),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Tooltip(
                message: curLangText!.sortCategoryTooltipText,
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    customButton: AbsorbPointer(
                      absorbing: true,
                      child: SizedBox(
                        width: 34,
                        child: MaterialButton(
                          onPressed: (() {}),
                          padding: const EdgeInsets.only(right: 3),
                          child: Center(
                              child: Icon(
                            Icons.sort_sharp,
                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
                          )),
                        ),
                      ),
                    ),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                    ),
                    buttonDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    //isDense: true,
                    dropdownElevation: 3,
                    dropdownPadding: const EdgeInsets.symmetric(vertical: 2),
                    dropdownWidth: 160,
                    offset: const Offset(-120, 0),
                    iconSize: 15,
                    itemHeight: 30,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 5),
                    items: sortTypeList
                        .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        //fontSize: 14,
                                        //fontWeight: FontWeight.bold,
                                        //color: Colors.white,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            )))
                        .toList(),
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      if (value == curLangText!.sortCateByNumItemsText) {
                        prefs.setInt('selectedSortType', 1);
                        cateList.sort(((a, b) => b.numOfItems.compareTo(a.numOfItems)));
                        ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                        cateList.insert(0, favCate);
                        selectedSortTypeString = curLangText!.sortCateByNumItemsText;
                      } else if (value == curLangText!.sortCateByNameText) {
                        prefs.setInt('selectedSortType', 0);
                        cateList.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
                        ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                        cateList.insert(0, favCate);
                        selectedSortTypeString = curLangText!.sortCateByNameText;
                      }
                      // ignore: use_build_context_synchronously
                      Provider.of<StateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);
                      setState(() {});
                    },
                  )),
                ),
              ),
            )
            // New Item button
            // Padding(
            //     padding: const EdgeInsets.only(right: 10),
            //     child: Tooltip(
            //         message: curLangText!.newItemBtnTooltipText,
            //         height: 25,
            //         textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
            //         waitDuration: const Duration(seconds: 1),
            //         child: SizedBox(
            //           width: 40,
            //           height: 30,
            //           child: MaterialButton(
            //               onPressed: addItemVisible
            //                   ? null
            //                   : (() {
            //                       setState(() {
            //                         switch (itemAdderAniController.status) {
            //                           case AnimationStatus.dismissed:
            //                             Provider.of<StateProvider>(context, listen: false).addingBoxStateTrue();
            //                             addItemVisible = true;
            //                             itemAdderAniController.forward();
            //                             break;
            //                           default:
            //                         }
            //                       });
            //                     }),
            //               child: Row(
            //                 children: [
            //                   Icon(
            //                     Icons.add_box_outlined,
            //                     color: addItemVisible
            //                         ? Theme.of(context).disabledColor
            //                         : MyApp.themeNotifier.value == ThemeMode.light
            //                             ? Theme.of(context).primaryColorDark
            //                             : Theme.of(context).iconTheme.color,
            //                   )
            //                 ],
            //               )),
            //         ))),
          ],
        ),

        //Category List
        if (isRefreshing)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              curLangText!.refreshBtnTootipText,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        if (!isSearching && !isRefreshing)
          Expanded(
            child: SingleChildScrollView(
              controller: AdjustableScrollController(80),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: Provider.of<StateProvider>(context, listen: false).cateListItemCount,
                itemBuilder: (context, index) {
                  return AbsorbPointer(
                    absorbing: isSearching,
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Colors.white,
                      iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Colors.white,
                      collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Colors.white,
                      collapsedIconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Colors.white,
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
                              if (cateList[index].categoryName == 'Favorites')
                                Text(
                                  cateList[index].categoryName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              if (cateList[index].categoryName != 'Favorites') Text(cateList[index].categoryName),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                child: Container(
                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).highlightColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                    child: cateList[index].numOfItems < 2
                                        ? Text('${cateList[index].numOfItems}${curLangText!.itemLabelText}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ))
                                        : Text('${cateList[index].numOfItems}${curLangText!.itemsLabelText}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ))),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (!defaultCatesList.contains(cateList[index].categoryName))
                                Tooltip(
                                    message: '${curLangText!.deleteBtnTooltipText} ${cateList[index].categoryName}',
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
                                                        curLangText!.deleteCatPopupText,
                                                        '${curLangText!.deleteBtnTooltipText}"${cateList[index].categoryName}"${curLangText!.deleteCatPopupMsgText}',
                                                        true,
                                                        cateList[index].categoryPath,
                                                        cateList[index].allModFiles)
                                                    .then((_) async {
                                                  modSetsListGet = getSetsList();
                                                  setsList = await modSetsListGet;
                                                  setsDropDownList.clear();
                                                  for (var set in setsList) {
                                                    setsDropDownList.add(set.setName);
                                                  }
                                                  setsList.map((set) => set.toJson()).toList();
                                                  File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
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
                                                categoryDeleteDialog(
                                                    context,
                                                    popupHeight,
                                                    curLangText!.deleteCatPopupText,
                                                    '${curLangText!.cannotDeleteCatPopupText}"${cateList[index].categoryName}"${curLangText!.cannotDeleteCatPopupUnapplyText}$stillApplied',
                                                    false,
                                                    cateList[index].categoryPath, []);
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
                        //Fav list
                        if (cateList[index].categoryName == 'Favorites')
                          for (int i = 0; i < cateList[index].itemNames.length; i++)
                            Ink(
                              color: selectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                              child: ListTile(
                                leading: cateList[index].imageIcons[i].first.path.split(s).last != 'placeholdersquare.png'
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
                                          filterQuality: FilterQuality.none,
                                          fit: BoxFit.fitWidth,
                                        )),
                                title: Text(cateList[index].itemNames[i]),
                                subtitle: Text('${curLangText!.modscolonLableText} ${cateList[index].numOfMods[i]} | ${curLangText!.appliedcolonLabelText} ${cateList[index].numOfApplied[i]}'),
                                trailing: Wrap(
                                  children: [
                                    if (cateList[index].allModFiles.indexWhere((element) => element.modName == cateList[index].itemNames[i] && element.isNew == true) != -1)
                                      SizedBox(height: 50, child: Icon(Icons.new_releases, color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber)),

                                    //Buttons
                                    Tooltip(
                                        message: '${curLangText!.openBtnTooltipText}${cateList[index].itemNames[i]}${curLangText!.inExplorerBtnTootipText}',
                                        height: 25,
                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                        waitDuration: const Duration(seconds: 2),
                                        child: SizedBox(
                                          width: 34,
                                          height: 50,
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                await launchUrl(Uri.parse('file:${cateList[index].allModFiles.firstWhere((element) => element.modName == cateList[index].itemNames[i]).modPath}'));
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
                                    if (cateList[index].categoryName == 'Favorites')
                                      SizedBox(
                                        width: 34,
                                        height: 50,
                                        child: Tooltip(
                                          message: '${curLangText!.removeBtnTooltipText}"${cateList[index].itemNames[i]}"${curLangText!.fromFavTooltipText}',
                                          height: 25,
                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                          waitDuration: const Duration(seconds: 1),
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                List<List<List<ModFile>>> modListToRemoveFav = await getModFilesByCategory(cateList[index].allModFiles, cateList[index].itemNames[i]);
                                                for (var mainParent in modListToRemoveFav) {
                                                  for (var element in mainParent) {
                                                    cateList[index] = addOrRemoveFav(cateList, element, cateList[index], false);
                                                  }
                                                }
                                                setState(() {});
                                              }),
                                              child: const FaIcon(
                                                FontAwesomeIcons.heartCircleXmark,
                                                size: 17,
                                                //color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).hintColor : Theme.of(context).hintColor,
                                              )),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    //close add mods window
                                    _newModToItemDragDropList.clear();
                                    newModToItemAddController.clear();
                                    isModAddFolderOnly = true;
                                    context.read<StateProvider>().modsDropAddClear();
                                    //addModToItemVisible = false;
                                    switch (modAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        modAdderAniController.reverse().whenComplete(() {
                                          addModToItemVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;
                                      default:
                                    }
                                    //main func
                                    isViewingFav = true;
                                    isPreviewImgsOn = false;
                                    modFilesListGet = getModFilesByCategory(cateList[index].allModFiles, cateList[index].itemNames[i]);
                                    curClickedCategory = cateList[index].categoryName;
                                    selectedIndex = List.filled(cateList.length, -1);
                                    selectedIndex[index] = i;
                                    modNameCatSelected = -1;
                                    modsViewAppBarName = cateList[index].itemNames[i];
                                    //_newModToItemIndex = index;
                                    isModSelected = true;
                                    isLoading.clear();
                                  });
                                },
                              ),
                            ),

                        //Non fav
                        if (cateList[index].categoryName != 'Favorites')
                          for (int i = 0; i < cateList[index].itemNames.length; i++)
                            Ink(
                              color: selectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                              child: ListTile(
                                leading: cateList[index].imageIcons[i].first.path.split('/').last != 'placeholdersquare.png'
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
                                          filterQuality: FilterQuality.none,
                                          fit: BoxFit.fitWidth,
                                        )),
                                title: Text(cateList[index].itemNames[i]),
                                subtitle: Text('${curLangText!.modscolonLableText} ${cateList[index].numOfMods[i]} | ${curLangText!.fileAppliedColonLabelText} ${cateList[index].numOfApplied[i]}'),
                                trailing: Wrap(
                                  children: [
                                    if (cateList[index].allModFiles.indexWhere((element) => element.modName == cateList[index].itemNames[i] && element.isNew == true) != -1)
                                      SizedBox(
                                          height: 50,
                                          child: Icon(
                                            Icons.new_releases,
                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber,
                                          )),

                                    //Buttons
                                    Tooltip(
                                        message: '${curLangText!.openBtnTooltipText}${cateList[index].itemNames[i]}${curLangText!.inExplorerBtnTootipText}',
                                        height: 25,
                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                        waitDuration: const Duration(seconds: 2),
                                        child: SizedBox(
                                          width: 34,
                                          height: 50,
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                await launchUrl(Uri.parse('file:${cateList[index].categoryPath}$s${cateList[index].itemNames[i]}'));
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
                                        message: '${curLangText!.deleteBtnTooltipText}${cateList[index].itemNames[i]}',
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
                                                            curLangText!.deleteItemPopupText,
                                                            '${curLangText!.deleteBtnTooltipText}"${cateList[index].itemNames[i]}"${curLangText!.deleteItemPopupMsgText}',
                                                            true,
                                                            cateList[index],
                                                            cateList[index].itemNames[i],
                                                            cateList[index].allModFiles)
                                                        .then((_) {
                                                      setState(() async {
                                                        modsViewAppBarName = curLangText!.availableModsHeaderText;
                                                        isModSelected = false;
                                                        modSetsListGet = getSetsList();
                                                        setsList = await modSetsListGet;
                                                        setsDropDownList.clear();
                                                        for (var set in setsList) {
                                                          setsDropDownList.add(set.setName);
                                                        }
                                                        setsList.map((set) => set.toJson()).toList();
                                                        File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                        //setstate
                                                      });
                                                    });
                                                  } else if (cateList[index].allModFiles.indexWhere((element) => element.isFav && element.modName == cateList[index].itemNames[i]) != -1) {
                                                    double popupHeight = 40;
                                                    itemDeleteDialog(
                                                        context,
                                                        popupHeight,
                                                        curLangText!.deleteItemPopupText,
                                                        '${curLangText!.cannotDeleteCatPopupText}"${cateList[index].itemNames[i]}"${curLangText!.removeFromFavFirstMsgText}',
                                                        false,
                                                        cateList[index],
                                                        cateList[index].itemNames[i], []);
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
                                                    itemDeleteDialog(
                                                        context,
                                                        popupHeight,
                                                        curLangText!.deleteItemPopupText,
                                                        '${curLangText!.cannotDeleteCatPopupText}"${cateList[index].itemNames[i]}"${curLangText!.cannotDeleteCatPopupUnapplyText}$stillApplied',
                                                        false,
                                                        cateList[index],
                                                        cateList[index].itemNames[i], []);
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
                                    //close add mods window
                                    _newModToItemDragDropList.clear();
                                    newModToItemAddController.clear();
                                    isModAddFolderOnly = true;
                                    context.read<StateProvider>().modsDropAddClear();
                                    //addModToItemVisible = false;
                                    switch (modAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        modAdderAniController.reverse().whenComplete(() {
                                          addModToItemVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;
                                      default:
                                    }
                                    //main func
                                    isViewingFav = false;
                                    isPreviewImgsOn = false;
                                    modFilesListGet = getModFilesByCategory(cateList[index].allModFiles, cateList[index].itemNames[i]);
                                    selectedIndex = List.filled(cateList.length, -1);
                                    curClickedCategory = cateList[index].categoryName;
                                    selectedIndex[index] = i;
                                    modNameCatSelected = -1;
                                    modsViewAppBarName = cateList[index].itemNames[i];
                                    //_newModToItemIndex = index;
                                    isModSelected = true;
                                    isLoading.clear();
                                  });
                                },
                              ),
                            )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

        //Search Result Category List
        if (isSearching && cateListSearchResult.isEmpty)
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(curLangText!.noSearchResultFoundText),
          )),
        if (isSearching && cateListSearchResult.isNotEmpty)
          Expanded(
            child: SingleChildScrollView(
              controller: AdjustableScrollController(80),
              child: AbsorbPointer(
                absorbing: !isSearching,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cateListSearchResult.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      initiallyExpanded: false,
                      textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                      iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                      collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                      collapsedIconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                      onExpansionChanged: (newState) {
                        setState(() {
                          if (!newState) {
                            searchListSelectedIndex = List.filled(cateListSearchResult.length, -1);
                          } else {
                            searchListSelectedIndex = List.filled(cateListSearchResult.length, -1);
                          }
                        });
                      },
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              if (cateListSearchResult[index].categoryName == 'Favorites')
                                Text(
                                  cateListSearchResult[index].categoryName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              if (cateListSearchResult[index].categoryName != 'Favorites') Text(cateListSearchResult[index].categoryName),
                              Padding(
                                padding: const EdgeInsets.only(left: 10, top: 3),
                                child: Container(
                                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 1),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).highlightColor),
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                    ),
                                    child: Text('${cateListSearchResult[index].numOfItems}${curLangText!.itemsLabelText}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                        ))),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: [
                        //Fav list
                        if (cateListSearchResult[index].categoryName == 'Favorites')
                          for (int i = 0; i < cateListSearchResult[index].itemNames.length; i++)
                            Ink(
                              color: searchListSelectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                              child: ListTile(
                                leading: cateListSearchResult[index].imageIcons[i].first.path.split('/').last != 'placeholdersquare.png'
                                    ? SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.file(
                                          cateListSearchResult[index].imageIcons[i].first,
                                          fit: BoxFit.fitWidth,
                                        ))
                                    : SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                          cateListSearchResult[index].imageIcons[i].first.path,
                                          filterQuality: FilterQuality.none,
                                          fit: BoxFit.fitWidth,
                                        )),
                                title: Text(cateListSearchResult[index].itemNames[i]),
                                subtitle: Text(
                                    '${curLangText!.modscolonLableText} ${cateListSearchResult[index].numOfMods[i]} | ${curLangText!.appliedcolonLabelText} ${cateListSearchResult[index].numOfApplied[i]}'),
                                trailing: Wrap(
                                  children: [
                                    if (cateListSearchResult[index].allModFiles.indexWhere((element) => element.modName == cateListSearchResult[index].itemNames[i] && element.isNew == true) != -1)
                                      SizedBox(
                                          height: 50,
                                          child: Icon(
                                            Icons.new_releases,
                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber,
                                          )),

                                    //Buttons
                                    Tooltip(
                                        message: '${curLangText!.openBtnTooltipText}${cateListSearchResult[index].itemNames[i]}${curLangText!.inExplorerBtnTootipText}',
                                        height: 25,
                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                        waitDuration: const Duration(seconds: 2),
                                        child: SizedBox(
                                          width: 34,
                                          height: 50,
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                await launchUrl(Uri.parse('file:${cateListSearchResult[index].categoryPath}$s${cateListSearchResult[index].itemNames[i]}'));
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
                                    if (cateListSearchResult[index].categoryName == 'Favorites')
                                      SizedBox(
                                        width: 34,
                                        height: 50,
                                        child: Tooltip(
                                          message: '${curLangText!.removeBtnTooltipText}"${cateListSearchResult[index].itemNames[i]}"${curLangText!.fromFavTooltipText}',
                                          height: 25,
                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                          waitDuration: const Duration(seconds: 1),
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                List<List<List<ModFile>>> modListToRemoveFav =
                                                    await getModFilesByCategory(cateListSearchResult[index].allModFiles, cateListSearchResult[index].itemNames[i]);
                                                for (var mainParent in modListToRemoveFav) {
                                                  for (var element in mainParent) {
                                                    cateListSearchResult[index] = addOrRemoveFav(cateListSearchResult, element, cateListSearchResult[index], false);
                                                  }
                                                }
                                                setState(() {});
                                              }),
                                              child: const FaIcon(
                                                FontAwesomeIcons.heartCircleXmark,
                                                size: 17,
                                                //color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).hintColor : Theme.of(context).hintColor,
                                              )),
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    //add mod window reset
                                    _newModToItemDragDropList.clear();
                                    newModToItemAddController.clear();
                                    isModAddFolderOnly = true;
                                    context.read<StateProvider>().modsDropAddClear();
                                    //addModToItemVisible = false;
                                    switch (modAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        modAdderAniController.reverse().whenComplete(() {
                                          addModToItemVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;
                                      default:
                                    }

                                    //main func
                                    isViewingFav = true;
                                    isPreviewImgsOn = false;
                                    modFilesListGet = getModFilesByCategory(cateListSearchResult[index].allModFiles, cateListSearchResult[index].itemNames[i]);
                                    searchListSelectedIndex = List.filled(cateListSearchResult.length, -1);
                                    searchListSelectedIndex[index] = i;
                                    modNameCatSelected = -1;
                                    modsViewAppBarName = cateListSearchResult[index].itemNames[i];
                                    //_newModToItemIndex = index;
                                    isModSelected = true;
                                    isLoading.clear();
                                  });
                                },
                              ),
                            ),

                        //Non fav
                        if (cateListSearchResult[index].categoryName != 'Favorites')
                          for (int i = 0; i < cateListSearchResult[index].itemNames.length; i++)
                            Ink(
                              color: searchListSelectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                              child: ListTile(
                                leading: cateListSearchResult[index].imageIcons[i].first.path.split('/').last != 'placeholdersquare.png'
                                    ? SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.file(
                                          cateListSearchResult[index].imageIcons[i].first,
                                          fit: BoxFit.fitWidth,
                                        ))
                                    : SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                          cateListSearchResult[index].imageIcons[i].first.path,
                                          filterQuality: FilterQuality.none,
                                          fit: BoxFit.fitWidth,
                                        )),
                                title: Text(cateListSearchResult[index].itemNames[i]),
                                subtitle: Text(
                                    '${curLangText!.modscolonLableText} ${cateListSearchResult[index].numOfMods[i]} | ${curLangText!.fileAppliedColonLabelText} ${cateListSearchResult[index].numOfApplied[i]}'),
                                trailing: Wrap(
                                  children: [
                                    if (cateListSearchResult[index].allModFiles.indexWhere((element) => element.modName == cateListSearchResult[index].itemNames[i] && element.isNew == true) != -1)
                                      SizedBox(
                                          height: 50,
                                          child: Icon(
                                            Icons.new_releases,
                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber,
                                          )),

                                    //Buttons
                                    Tooltip(
                                        message: '${curLangText!.openBtnTooltipText}${cateListSearchResult[index].itemNames[i]}${curLangText!.inExplorerBtnTootipText}',
                                        height: 25,
                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                        waitDuration: const Duration(seconds: 2),
                                        child: SizedBox(
                                          width: 34,
                                          height: 50,
                                          child: MaterialButton(
                                              onPressed: (() async {
                                                await launchUrl(Uri.parse('file:${cateListSearchResult[index].categoryPath}$s${cateListSearchResult[index].itemNames[i]}'));
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
                                        message: '${curLangText!.deleteBtnTooltipText}${cateListSearchResult[index].itemNames[i]}',
                                        height: 25,
                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                        waitDuration: const Duration(seconds: 2),
                                        child: SizedBox(
                                          width: 36,
                                          height: 50,
                                          child: MaterialButton(
                                              onPressed: (() {
                                                setState(() {
                                                  if (cateListSearchResult[index]
                                                          .allModFiles
                                                          .indexWhere((element) => element.modName == cateListSearchResult[index].itemNames[i] && element.isApplied == true) ==
                                                      -1) {
                                                    ModCategory curCate = cateList.firstWhere((element) => element.categoryName == cateListSearchResult[index].categoryName);
                                                    String curItem = cateListSearchResult[index].itemNames[i];
                                                    itemDeleteDialog(
                                                            context,
                                                            100,
                                                            curLangText!.deleteItemPopupText,
                                                            '${curLangText!.deleteBtnTooltipText}"${cateListSearchResult[index].itemNames[i]}"${curLangText!.deleteItemPopupMsgText}',
                                                            true,
                                                            cateListSearchResult[index],
                                                            cateListSearchResult[index].itemNames[i],
                                                            cateListSearchResult[index].allModFiles)
                                                        .then((_) {
                                                      //Remove from normal Item List

                                                      curCate.imageIcons.removeAt(curCate.itemNames.indexOf(curItem));
                                                      curCate.numOfMods.removeAt(curCate.itemNames.indexWhere((element) => element == curItem));
                                                      curCate.itemNames.removeWhere((element) => element == curItem);
                                                      curCate.allModFiles.removeWhere((element) => element.modName == curItem);
                                                      curCate.numOfItems--;
                                                      setState(() {
                                                        modsViewAppBarName = curLangText!.availableModsHeaderText;
                                                        isModSelected = false;
                                                        //setstate
                                                      });
                                                    });
                                                  } else if (cateListSearchResult[index]
                                                          .allModFiles
                                                          .indexWhere((element) => element.isFav && element.modName == cateListSearchResult[index].itemNames[i]) !=
                                                      -1) {
                                                    double popupHeight = 40;
                                                    itemDeleteDialog(
                                                        context,
                                                        popupHeight,
                                                        curLangText!.deleteItemPopupText,
                                                        '${curLangText!.cannotDeleteCatPopupText}"${cateListSearchResult[index].itemNames[i]}"${curLangText!.removeFromFavFirstMsgText}',
                                                        false,
                                                        cateListSearchResult[index],
                                                        cateListSearchResult[index].itemNames[i], []);
                                                  } else {
                                                    List<ModFile> tempList = cateListSearchResult[index]
                                                        .allModFiles
                                                        .where((element) => element.modName == cateListSearchResult[index].itemNames[i] && element.isApplied == true)
                                                        .toList();
                                                    List<String> stillAppliedList = [];
                                                    double popupHeight = 40;
                                                    for (var element in tempList) {
                                                      stillAppliedList.add('${element.modName}${element.iceParent} > ${element.iceName}');
                                                      popupHeight += 24;
                                                    }
                                                    String stillApplied = stillAppliedList.join('\n');
                                                    itemDeleteDialog(
                                                        context,
                                                        popupHeight,
                                                        curLangText!.deleteItemPopupText,
                                                        '${curLangText!.cannotDeleteCatPopupText}"${cateListSearchResult[index].itemNames[i]}"${curLangText!.unappyFilesFirstMsgText}$stillApplied',
                                                        false,
                                                        cateListSearchResult[index],
                                                        cateListSearchResult[index].itemNames[i], []);
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
                                    //close add mods window
                                    _newModToItemDragDropList.clear();
                                    newModToItemAddController.clear();
                                    isModAddFolderOnly = true;
                                    context.read<StateProvider>().modsDropAddClear();
                                    //addModToItemVisible = false;
                                    switch (modAdderAniController.status) {
                                      case AnimationStatus.completed:
                                        modAdderAniController.reverse().whenComplete(() {
                                          addModToItemVisible = false;
                                          Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          setState(() {});
                                        });
                                        break;
                                      default:
                                    }

                                    //main func
                                    isViewingFav = false;
                                    isPreviewImgsOn = false;
                                    modFilesListGet = getModFilesByCategory(cateListSearchResult[index].allModFiles, cateListSearchResult[index].itemNames[i]);
                                    searchListSelectedIndex = List.filled(cateListSearchResult.length, -1);
                                    searchListSelectedIndex[index] = i;
                                    curClickedCategory = '';
                                    modNameCatSelected = -1;
                                    modsViewAppBarName = cateListSearchResult[index].itemNames[i];
                                    //_newModToItemIndex = index;
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
                      decoration: InputDecoration(
                        labelText: curLangText!.newCatNameLabelText,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return curLangText!.newCatNameEmptyErrorText;
                        }
                        if (cateList.indexWhere((e) => e.categoryName == value) != -1) {
                          return curLangText!.newCatNameDupErrorText;
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
                                        Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                        setState(() {});
                                      });
                                      break;

                                    default:
                                  }
                                });
                              }),
                              child: Text(curLangText!.closeBtnText)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ElevatedButton(
                              onPressed: (() {
                                modFilesList.clear();
                                modsViewAppBarName = curLangText!.availableModsHeaderText;
                                if (categoryFormKey.currentState!.validate()) {
                                  cateList.add(ModCategory(categoryAddController.text, '$modsDirPath\\${categoryAddController.text}', [], [], 0, [], [], []));
                                  if (selectedSortType == 1) {
                                    cateList.sort(((a, b) => b.numOfItems.compareTo(a.numOfItems)));
                                    ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                                    cateList.insert(0, favCate);
                                  } else if (selectedSortType == 0) {
                                    cateList.sort(((a, b) => a.categoryName.compareTo(b.categoryName)));
                                    ModCategory favCate = cateList.removeAt(cateList.indexWhere((element) => element.categoryName == 'Favorites'));
                                    cateList.insert(0, favCate);
                                  }
                                  // cateList.sort(
                                  //   (a, b) {
                                  //     if (b.categoryName != 'Favorites' || a.categoryName != 'Favorites') {
                                  //       return b.numOfItems.compareTo(a.numOfItems);
                                  //     } else {
                                  //       return 0;
                                  //     }
                                  //   },
                                  // );
                                  Directory('$modsDirPath\\${categoryAddController.text}').create(recursive: true);
                                  selectedIndex = List.generate(cateList.length, (index) => -1);

                                  for (var parentList in modFilesList) {
                                    for (var modList in parentList) {
                                      modList.map((mod) => mod.toJson()).toList();
                                      File(modSettingsPath).writeAsStringSync(json.encode(modList));
                                    }
                                  }
                                  Provider.of<StateProvider>(context, listen: false).cateListItemCountSetNoListener(cateList.length);
                                  categoryAddController.clear();
                                  Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                  //addCategoryVisible = false;
                                }

                                //     Future.delayed(const Duration(milliseconds: 100), () async {
                                //   //allModFiles = await modsLoader();
                                //   //cateList = categories(allModFiles);
                                //   //appliedModsListGet = getAppliedModsList();
                                //   //iceFiles = dataDir.listSync(recursive: true).whereType<File>().toList();
                                //   // ignore: use_build_context_synchronously

                                //   //isRefreshing = false;
                                // }).whenComplete(() {
                                //   //isRefreshing = false;
                                //   setState(() {});
                                // });
                                setState(() {});
                              }),
                              child: Text(curLangText!.addCatBtnText)),
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
                  onTap: (index) {},
                  tabs: [
                    Tab(
                      height: 25,
                      text: curLangText!.singleAddBtnText,
                    ),
                    Tab(
                      height: 25,
                      text: curLangText!.multiAddBtnText,
                    ),
                  ],
                ),
                SizedBox(
                  height: !isErrorInSingleItemName ? 270 : 300,
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
                                  context.read<StateProvider>().singleItemsDropAdd(detail.files);
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
                                      if (_newSingleItemDragDropList.isEmpty)
                                        Center(
                                            child: Column(
                                          children: [
                                            Text(curLangText!.singleDropBoxLabelText),
                                          ],
                                        )),
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
                                                    child: Text(context.watch<StateProvider>().newSingleItemDropDisplay),
                                                  )),
                                            ),
                                          ),
                                        )
                                    ],
                                  )),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 0, left: 10, right: 10),
                              child: CustomDropdownButton2(
                                hint: curLangText!.addSelectCatLabelText,
                                dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                ),
                                buttonDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Theme.of(context).hintColor),
                                ),
                                buttonWidth: double.infinity,
                                buttonHeight: 37.5,
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
                          Row(children: [
                            //Item icon Drop Zone,
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
                              child: DropTarget(
                                //enable: true,
                                onDragDone: (detail) {
                                  setState(() {
                                    _singleItemIcon = detail.files.last;
                                  });
                                },
                                onDragEntered: (detail) {
                                  setState(() {
                                    _draggingItemIcon = true;
                                  });
                                },
                                onDragExited: (detail) {
                                  setState(() {
                                    _draggingItemIcon = false;
                                  });
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).hintColor),
                                      color: _draggingItemIcon ? Colors.blue.withOpacity(0.4) : Colors.black26,
                                    ),
                                    height: 85,
                                    width: 85,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_singleItemIcon == null)
                                          Center(
                                              child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [Text(curLangText!.iconDropBoxLabelText)],
                                          )),
                                        if (_singleItemIcon != null)
                                          Expanded(
                                            child: SizedBox(
                                                width: double.infinity,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 1),
                                                  child: Center(
                                                    child: Image.file(
                                                      File(_singleItemIcon!.path),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                )),
                                          )
                                      ],
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 10),
                                  //   child: CustomDropdownButton2(
                                  //     hint: 'Select a Category',
                                  //     dropdownDecoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(3),
                                  //       border: Border.all(color: Theme.of(context).cardColor),
                                  //     ),
                                  //     buttonDecoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(3),
                                  //       border: Border.all(color: Theme.of(context).hintColor),
                                  //     ),
                                  //     buttonWidth: double.infinity,
                                  //     buttonHeight: 37.5,
                                  //     itemHeight: 40,
                                  //     dropdownElevation: 3,
                                  //     icon: const Icon(Icons.arrow_drop_down),
                                  //     iconSize: 30,
                                  //     //dropdownWidth: 361,
                                  //     dropdownHeight: double.maxFinite,
                                  //     dropdownItems: dropdownCategories,
                                  //     value: selectedCategoryForSingleItem,
                                  //     onChanged: (value) {
                                  //       setState(() {
                                  //         selectedCategoryForSingleItem = value;
                                  //       });
                                  //     },
                                  //   ),
                                  // ),
                                  Form(
                                    key: newSingleItemFormKey,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 10),
                                      child: SizedBox(
                                        height: isErrorInSingleItemName ? 62.5 : 37.5,
                                        child: TextFormField(
                                          controller: newSingleItemAddController,
                                          //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                          //maxLength: 100,
                                          style: const TextStyle(fontSize: 15),
                                          decoration: InputDecoration(
                                            labelText: curLangText!.addItemNamLabelText,
                                            border: const OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              isErrorInSingleItemName = true;
                                              return curLangText!.newItemNameEmpty;
                                            }
                                            if (selectedCategoryForSingleItem == 'Basewears' ||
                                                selectedCategoryForSingleItem == 'Setwears' ||
                                                selectedCategoryForSingleItem == 'Outerwears' ||
                                                selectedCategoryForSingleItem == 'Innerwears') {
                                              if (cateList.indexWhere((e) =>
                                                      e.categoryName == selectedCategoryForSingleItem &&
                                                      e.itemNames.indexWhere((element) => element.toLowerCase().substring(0, element.length - 4).trim() == value.toLowerCase()) != -1) !=
                                                  -1) {
                                                isErrorInSingleItemName = true;
                                                return curLangText!.newItemNameDuplicate;
                                              }
                                            } else {
                                              if (cateList.indexWhere((e) =>
                                                      e.categoryName == selectedCategoryForSingleItem && e.itemNames.indexWhere((element) => element.toLowerCase() == value.toLowerCase()) != -1) !=
                                                  -1) {
                                                isErrorInSingleItemName = true;
                                                return curLangText!.newItemNameDuplicate;
                                              }
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
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 0, left: 0, right: 10),
                                    child: SizedBox(
                                      height: isErrorInSingleItemName ? 62.5 : 37.5,
                                      child: TextFormField(
                                        controller: newSingleItemModNameController,
                                        //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                        //maxLength: 100,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: InputDecoration(
                                          labelText: curLangText!.addModNameLabelText,
                                          border: const OutlineInputBorder(),
                                          isDense: true,
                                        ),
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
                                ],
                              ),
                            ),
                          ]),
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
                                      _newItemDragDropList.add(file);
                                      context.read<StateProvider>().itemsDropAdd([file]);
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
                                              Text(
                                                curLangText!.multiItemsLeftOver,
                                                style: const TextStyle(fontWeight: FontWeight.w600),
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
                                  height: 205,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (_newItemDragDropList.isEmpty) Center(child: Text(curLangText!.multiDropBoxLabelText)),
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
                                                      child: Text(context.watch<StateProvider>().newItemDropDisplay),
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
                                    hint: curLangText!.addSelectCatLabelText,
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
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
                                      _singleItemIcon = null;
                                      newItemAddController.clear();
                                      newSingleItemAddController.clear();
                                      newSingleItemModNameController.clear();
                                      selectedCategoryForMutipleItems = null;
                                      selectedCategoryForSingleItem = null;
                                      isErrorInSingleItemName = false;
                                      context.read<StateProvider>().singleItemDropAddClear();
                                      context.read<StateProvider>().itemsDropAddClear();
                                      Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
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
                            child: Text(curLangText!.closeBtnText),
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
                                        selectedIndex.fillRange(0, selectedIndex.length, -1);
                                        modFilesList.clear();
                                        modsViewAppBarName = curLangText!.availableModsHeaderText;
                                        if (_itemAdderTabcontroller.index == 1) {
                                          isItemAddBtnClicked = true;
                                          dragDropFilesAdd(context, _newItemDragDropList, selectedCategoryForMutipleItems, newItemAddController.text.isEmpty ? null : newItemAddController.text)
                                              .then((_) {
                                            setState(() {
                                              //setstate to refresh list
                                              _newItemDragDropList.clear();
                                              _singleItemIcon = null;
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
                                                  context,
                                                  _newSingleItemDragDropList,
                                                  _singleItemIcon,
                                                  selectedCategoryForSingleItem,
                                                  newSingleItemAddController.text.isEmpty ? null : newSingleItemAddController.text.trim(),
                                                  newSingleItemModNameController.text.isEmpty ? null : newSingleItemModNameController.text.trim())
                                              .then((_) {
                                            setState(() {
                                              //setstate to refresh list
                                              _newSingleItemDragDropList.clear();
                                              newSingleItemAddController.clear();
                                              newSingleItemModNameController.clear();
                                              isItemAddBtnClicked = false;
                                              _singleItemIcon = null;
                                            });
                                          });
                                        }
                                      });
                                    })
                                  : null,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [Text(curLangText!.addBtnText)],
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
                  modsViewAppBarName.isEmpty ? Text(curLangText!.availableModsHeaderText) : Text(modsViewAppBarName),
                ],
              )),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          // actions: [
          //  //Add mod to item button
          //   Tooltip(
          //       message:
          //           modsViewAppBarName == '' || modsViewAppBarName == curLangText!.availableModsHeaderText ? curLangText!.addModTootipText : '${curLangText!.addModToTooltipText} $modsViewAppBarName',
          //       height: 25,
          //       textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
          //       waitDuration: const Duration(seconds: 1),
          //       child: SizedBox(
          //         width: 40,
          //         height: 30,
          //         child: MaterialButton(
          //             onPressed: addModToItemVisible || modsViewAppBarName.isEmpty || !isModSelected
          //                 ? null
          //                 : (() {
          //                     setState(() {
          //                       //addModToItemVisible = true;
          //                       switch (modAdderAniController.status) {
          //                         case AnimationStatus.dismissed:
          //                           addModToItemVisible = true;
          //                           modAdderAniController.forward();
          //                           Provider.of<StateProvider>(context, listen: false).addingBoxStateTrue();
          //                           break;
          //                         default:
          //                       }
          //                     });
          //                   }),
          //             child: Row(
          //               children: [
          //                 Icon(
          //                   Icons.add_box_outlined,
          //                   color: addModToItemVisible || modsViewAppBarName.isEmpty || !isModSelected
          //                       ? Theme.of(context).disabledColor
          //                       : MyApp.themeNotifier.value == ThemeMode.light
          //                           ? Theme.of(context).primaryColorDark
          //                           : Theme.of(context).iconTheme.color,
          //                 )
          //               ],
          //             )),
          //       )),
          // ],
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
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        modFilesList = snapshot.data;
                        if (isLoading.isEmpty) {
                          isLoading = List.generate(modFilesList.length, (index) => []);
                          for (var item in modFilesList) {
                            isLoading[modFilesList.indexOf(item)] = List.generate(item.length, (index) => false);
                          }
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
                                  return Card(
                                    margin: const EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                        side: BorderSide(
                                            width: 1,
                                            color: modFilesList[index].first.indexWhere((e) => e.isNew == true) != -1
                                                ? MyApp.themeNotifier.value == ThemeMode.light
                                                    ? Theme.of(context).primaryColorDark
                                                    : Colors.amber
                                                : Theme.of(context).primaryColorLight)),
                                    child: ExpansionTile(
                                      initiallyExpanded: false,
                                      textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                      iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                      collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                      backgroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).highlightColor : Theme.of(context).primaryColor,
                                      title: Row(
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: Text(
                                              modFilesList[index].first.first.iceParent.split(' > ').first,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, top: 18, bottom: 13),
                                            child: Container(
                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Theme.of(context).highlightColor),
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                ),
                                                child: modFilesList[index].length < 2
                                                    ? Text('${modFilesList[index].length} ${curLangText!.modLabelText}',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ))
                                                    : Text('${modFilesList[index].length} ${curLangText!.modsLabelText}',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ))),
                                          ),
                                        ],
                                      ),
                                      children: [
                                        for (int subParentIndex = 0; subParentIndex < modFilesList[index].length; subParentIndex++)
                                          InkWell(
                                              onTap: () {},
                                              onHover: (value) {
                                                if (value) {
                                                  setState(() {
                                                    if (modFilesList[index][subParentIndex].first.images != null) {
                                                      isPreviewImgsOn = true;
                                                      futureImagesGet = modFilesList[index][subParentIndex].first.images;
                                                    }
                                                    //print(modFilesList[index].first.previewVids!.length);
                                                    if (modFilesList[index][subParentIndex].first.previewVids!.isNotEmpty) {
                                                      previewZoomState = false;
                                                      isPreviewVidOn = true;
                                                      isPreviewImgsOn = false;
                                                      previewPlayer.setVolume(0.0);
                                                      bool itemFound = false;
                                                      for (var vid in modFilesList[index][subParentIndex].first.previewVids!) {
                                                        if (medias.contains(Media.file(vid))) {
                                                          itemFound = true;
                                                        } else {
                                                          medias.clear();
                                                        }
                                                      }

                                                      if (medias.isEmpty || !itemFound) {
                                                        for (var vid in modFilesList[index][subParentIndex].first.previewVids!) {
                                                          medias.add(Media.file(vid));
                                                        }
                                                        previewPlayer.open(Playlist(medias: medias), autoStart: true);
                                                      } else {
                                                        previewPlayer.bufferingProgressController.done;
                                                        previewPlayer.play();
                                                      }
                                                    }
                                                  });
                                                } else {
                                                  setState(() {
                                                    isPreviewImgsOn = false;
                                                    isPreviewVidOn = false;
                                                    previewZoomState = true;
                                                    previewPlayer.pause();
                                                    currentImg = 0;
                                                  });
                                                }
                                              },
                                              child: GestureDetector(
                                                onSecondaryTap: () => modPreviewImgList.isNotEmpty && previewZoomState ? pictureDialog(context, previewImageSliders) : null,
                                                child: Card(
                                                    margin: const EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 2),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: modFilesList[index][subParentIndex].indexWhere((e) => e.isNew == true) != -1
                                                                ? MyApp.themeNotifier.value == ThemeMode.light
                                                                    ? Theme.of(context).primaryColorDark
                                                                    : Colors.amber
                                                                : Theme.of(context).primaryColorLight)),
                                                    child: ExpansionTile(
                                                      initiallyExpanded: modViewExpandAll,
                                                      textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                      iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                      collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                      title: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Flexible(
                                                            child: Text(modFilesList[index][subParentIndex]
                                                                .first
                                                                .iceParent
                                                                .replaceFirst('${modFilesList[index].first.first.iceParent.split(' > ').first} > ', '')),
                                                          ),
                                                          //if (modFilesList[index].length > 1)
                                                          Row(
                                                            children: [
                                                              //Buttons
                                                              SizedBox(
                                                                width: 40,
                                                                height: 40,
                                                                child: Tooltip(
                                                                  message: modFilesList[index][subParentIndex].first.isFav
                                                                      ? '${curLangText!.removeBtnTooltipText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.toFavTooltipText}'
                                                                      : '${curLangText!.addBtnTooltipText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.toFavTooltipText}',
                                                                  height: 25,
                                                                  textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                  waitDuration: const Duration(seconds: 1),
                                                                  child: MaterialButton(
                                                                    onPressed: (() {
                                                                      var favCate = cateList.firstWhere((element) => element.categoryName == 'Favorites');
                                                                      if (modFilesList[index][subParentIndex].first.isFav) {
                                                                        favCate = addOrRemoveFav(cateList, modFilesList[index][subParentIndex], favCate, false);
                                                                      } else {
                                                                        favCate = addOrRemoveFav(cateList, modFilesList[index][subParentIndex], favCate, true);
                                                                      }
                                                                      setState(() {});
                                                                      if (curClickedCategory == 'Favorites') {
                                                                        modFilesList[index].remove(modFilesList[index][subParentIndex]);
                                                                        if (modFilesList[index].isEmpty) {
                                                                          modFilesList.remove(modFilesList[index]);
                                                                          modsViewAppBarName = curLangText!.availableModsHeaderText;
                                                                        }
                                                                      }

                                                                      Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
                                                                    }),
                                                                    child: modFilesList[index][subParentIndex].first.isFav
                                                                        ? FaIcon(
                                                                            FontAwesomeIcons.heartCircleMinus,
                                                                            size: 19,
                                                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).hintColor : Theme.of(context).hintColor,
                                                                          )
                                                                        : FaIcon(
                                                                            FontAwesomeIcons.heartCirclePlus,
                                                                            size: 19,
                                                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                              //loading && add
                                                              if (isLoading[index][subParentIndex])
                                                                const SizedBox(
                                                                  width: 40,
                                                                  height: 40,
                                                                  child: CircularProgressIndicator(),
                                                                ),

                                                              //if (modFilesList[index].length > 1 && modFilesList[index].indexWhere((element) => element.isApplied == true) != -1 && !isLoading[index])
                                                              if (modFilesList[index][subParentIndex].indexWhere((element) => element.isApplied == true) != -1 && !isLoading[index][subParentIndex])
                                                                SizedBox(
                                                                  width: 40,
                                                                  height: 40,
                                                                  child: Tooltip(
                                                                    message:
                                                                        '${curLangText!.unapplyModUnderTooltipText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.fromTheGameTooltipText}',
                                                                    height: 25,
                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                    waitDuration: const Duration(seconds: 1),
                                                                    child: MaterialButton(
                                                                      onPressed: (() {
                                                                        setState(() {
                                                                          modsRemover(modFilesList[index][subParentIndex].where((element) => element.isApplied).toList());
                                                                        });
                                                                      }),
                                                                      child: Icon(
                                                                        Icons.playlist_remove,
                                                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              //if (modFilesList[index].length > 1 && modFilesList[index].indexWhere((element) => element.isApplied == false) != -1 && !isLoading[index])
                                                              if (modFilesList[index][subParentIndex].indexWhere((element) => element.isApplied == false) != -1 && !isLoading[index][subParentIndex])
                                                                SizedBox(
                                                                  width: 40,
                                                                  height: 40,
                                                                  child: Tooltip(
                                                                    message:
                                                                        '${curLangText!.applyModUnderTooltipText}"${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.toTheGameTooltipText}',
                                                                    height: 25,
                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                    waitDuration: const Duration(seconds: 1),
                                                                    child: MaterialButton(
                                                                      onPressed: (() {
                                                                        setState(() {
                                                                          isLoading[index][subParentIndex] = true;
                                                                          modsToDataAdder(modFilesList[index][subParentIndex].where((element) => element.isApplied == false).toList()).then((_) {
                                                                            setState(() {
                                                                              isLoading[index][subParentIndex] = false;
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
                                                                                                '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                                                '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
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
                                                              if (!isViewingFav)
                                                                Tooltip(
                                                                    message: '${curLangText!.deleteBtnTooltipText}$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}',
                                                                    height: 25,
                                                                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                    waitDuration: const Duration(seconds: 2),
                                                                    child: SizedBox(
                                                                      width: 36,
                                                                      height: 40,
                                                                      child: MaterialButton(
                                                                          onPressed: (() {
                                                                            setState(() {
                                                                              if (modFilesList[index][subParentIndex].indexWhere((element) => element.isApplied == true) == -1) {
                                                                                modDeleteDialog(
                                                                                        context,
                                                                                        100,
                                                                                        curLangText!.deleteModPopupText,
                                                                                        '${curLangText!.deleteBtnTooltipText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.deleteModPopupMsgText}',
                                                                                        true,
                                                                                        modFilesList[index][subParentIndex].first.modPath,
                                                                                        modFilesList[index][subParentIndex].first.iceParent,
                                                                                        modFilesList[index][subParentIndex].first.modName,
                                                                                        modFilesList[index][subParentIndex])
                                                                                    .then((_) async {
                                                                                  modSetsListGet = getSetsList();
                                                                                  setsList = await modSetsListGet;
                                                                                  setsDropDownList.clear();
                                                                                  for (var set in setsList) {
                                                                                    setsDropDownList.add(set.setName);
                                                                                  }
                                                                                  setsList.map((set) => set.toJson()).toList();
                                                                                  File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                                  setState(() {
                                                                                    //setstate to refresh list
                                                                                  });
                                                                                });
                                                                              } else if (modFilesList[index][subParentIndex].first.isFav) {
                                                                                double popupHeight = 40;
                                                                                modDeleteDialog(
                                                                                    context,
                                                                                    popupHeight,
                                                                                    curLangText!.deleteModPopupText,
                                                                                    '${curLangText!.cannotDeleteCatPopupText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.removeFromFavFirstMsgText}',
                                                                                    false,
                                                                                    modFilesList[index][subParentIndex].first.modPath,
                                                                                    modFilesList[index][subParentIndex].first.iceParent,
                                                                                    modFilesList[index][subParentIndex].first.modName, []);
                                                                              } else {
                                                                                List<ModFile> tempList = cateList[cateList
                                                                                        .indexWhere((element) => element.categoryName == modFilesList[index][subParentIndex].first.categoryName)]
                                                                                    .allModFiles
                                                                                    .where(
                                                                                        (element) => element.modName == modFilesList[index][subParentIndex].first.modName && element.isApplied == true)
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
                                                                                    curLangText!.deleteModPopupText,
                                                                                    '${curLangText!.cannotDeleteCatPopupText}"$modsViewAppBarName ${modFilesList[index][subParentIndex].first.iceParent}"${curLangText!.unappyFilesFirstMsgText}$stillApplied',
                                                                                    false,
                                                                                    modFilesList[index][subParentIndex].first.modPath,
                                                                                    modFilesList[index][subParentIndex].first.iceParent,
                                                                                    modFilesList[index][subParentIndex].first.modName, []);
                                                                              }
                                                                            });
                                                                          }),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.delete_rounded,
                                                                                size: 20,
                                                                                color:
                                                                                    MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                              )
                                                                            ],
                                                                          )),
                                                                    )),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      children: [
                                                        for (int i = 0; i < modFilesList[index][subParentIndex].length; i++)
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
                                                            leading: modFilesList[index][subParentIndex][i].isNew == true
                                                                ? Icon(
                                                                    Icons.new_releases,
                                                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber,
                                                                  )
                                                                : null,
                                                            title: Text(modFilesList[index][subParentIndex][i].iceName),
                                                            //subtitle: Text(modFilesList[index][i].icePath),
                                                            minLeadingWidth: 10,
                                                            trailing: SizedBox(
                                                              width: 40,
                                                              height: 40,
                                                              child: modFilesList[index][subParentIndex][i].isApplied
                                                                  ? Tooltip(
                                                                      message: curLangText!.unapplyThisModTooltipText,
                                                                      height: 25,
                                                                      textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                      waitDuration: const Duration(seconds: 2),
                                                                      child: MaterialButton(
                                                                        onPressed: (() {
                                                                          setState(() {
                                                                            modsRemover([modFilesList[index][subParentIndex][i]]);
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
                                                                                              '${curLangText!.backupFileOf}"${backupFilesMissingList[i].modName} ${backupFilesMissingList[i].iceParent} > ${backupFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
                                                                                      ],
                                                                                    ),
                                                                                  )));
                                                                            }
                                                                          });
                                                                        }),
                                                                        child: const Icon(Icons.replay),
                                                                      ))
                                                                  : Tooltip(
                                                                      message: curLangText!.applyThisModTooltipText,
                                                                      height: 25,
                                                                      textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                                      waitDuration: const Duration(seconds: 2),
                                                                      child: MaterialButton(
                                                                        onPressed: (() {
                                                                          setState(() {
                                                                            modsToDataAdder([modFilesList[index][subParentIndex][i]]);
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
                                                                                              '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                                              '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
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
                                                    )),
                                              )),
                                      ],
                                    ),
                                  );
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
                        context.read<StateProvider>().modsDropAdd(detail.files);
                        for (var element in detail.files) {
                          if (!Directory(element.path).existsSync()) {
                            isModAddFolderOnly = false;
                            break;
                          }
                        }
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
                            if (_newModToItemDragDropList.isEmpty) Center(child: Text(curLangText!.singleDropBoxLabelText)),
                            if (_newModToItemDragDropList.isNotEmpty)
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          child: Text(context.watch<StateProvider>().newModDropDisplay),
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
                            enabled: !isModAddFolderOnly,
                            controller: newModToItemAddController,
                            //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            //maxLength: 100,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: curLangText!.modNameLabelText,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (!isModAddFolderOnly && (value == null || value.isEmpty)) {
                                return curLangText!.newItemNameEmpty;
                              }
                              // if (modFilesList..indexWhere((e) => e.indexWhere((element) => element.iceParent.split(' > ').last == value) != -1) != -1) {
                              //   return curLangText!.newItemNameDuplicate;
                              // }
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
                                        isModAddFolderOnly = true;
                                        context.read<StateProvider>().modsDropAddClear();
                                        //addModToItemVisible = false;
                                        switch (modAdderAniController.status) {
                                          case AnimationStatus.completed:
                                            modAdderAniController.reverse().whenComplete(() {
                                              addModToItemVisible = false;
                                              Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                              setState(() {});
                                            });
                                            break;
                                          default:
                                        }
                                      });
                                    }),
                              child: Text(curLangText!.closeBtnText)),
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
                                          // if (modFilesList.isNotEmpty) {
                                          //   isModAddBtnClicked = true;
                                          //   if (isModAddFolderOnly) {
                                          //     dragDropModsAddFoldersOnly(context, _newModToItemDragDropList, modsViewAppBarName, modFilesList.first.first.modPath, _newModToItemIndex, null).then((_) {
                                          //       setState(() {
                                          //         //setstate to refresh list
                                          //         _newModToItemDragDropList.clear();
                                          //         newModToItemAddController.clear();
                                          //         isModAddBtnClicked = false;
                                          //         isPreviewImgsOn = false;
                                          //         Provider.of<StateProvider>(context, listen: false).addingBoxStateFalse();
                                          //       });
                                          //     });
                                          //   } else {
                                          //     isModAddFolderOnly = true;
                                          //     dragDropModsAdd(context, _newModToItemDragDropList, modFilesList.first.first.categoryName, modsViewAppBarName, modFilesList.first.first.modPath,
                                          //             newModToItemAddController.text.isEmpty ? null : newModToItemAddController.text)
                                          //         .then((_) {
                                          //       setState(() {
                                          //         //setstate to refresh list
                                          //         _newModToItemDragDropList.clear();
                                          //         newModToItemAddController.clear();
                                          //         isModAddBtnClicked = false;
                                          //         isPreviewImgsOn = false;
                                          //       });
                                          //     });
                                          //   }
                                          // }

                                          //addItemVisible = false;
                                        }
                                      });
                                    })
                                  : null,
                              child: Text(curLangText!.addBtnText)),
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
        //if (context.watch<StateProvider>().previewWindowVisible)
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.previewHeaderText)),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
        ),
        if (isPreviewImgsOn && context.watch<StateProvider>().previewWindowVisible)
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
                        previewImageSliders = modPreviewImgList
                            .map((item) => Container(
                                  margin: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      child: Stack(
                                        children: <Widget>[
                                          Image.file(item),
                                          //Text(modPreviewImgList.toString())
                                        ],
                                      )),
                                ))
                            .toList();
                        List<Widget> previewImageSlidersBox = [];
                        for (var element in previewImageSliders) {
                          previewImageSlidersBox.add(FittedBox(
                            fit: BoxFit.contain,
                            child: element,
                          ));
                        }
                        previewImageSliders = previewImageSlidersBox;
                        return Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onSecondaryTap: (() => modPreviewImgList.isNotEmpty && previewZoomState ? pictureDialog(context, previewImageSliders) : null),
                                child: CarouselSlider(
                                  items: previewImageSliders,
                                  carouselController: imgSliderController,
                                  options: CarouselOptions(
                                      autoPlayAnimationDuration: const Duration(milliseconds: 500),
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
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // if (previewImageSliders.isNotEmpty)
                                //   SizedBox(
                                //     width: 40,
                                //     child: MaterialButton(
                                //       onPressed: (() => imgSliderController.previousPage()),
                                //       child: const Icon(Icons.arrow_left),
                                //     ),
                                //   ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: modPreviewImgList.asMap().entries.map((entry) {
                                    return GestureDetector(
                                      onTap: () => imgSliderController.animateToPage(entry.key),
                                      child: Container(
                                        width: 5.0,
                                        height: 5.0,
                                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentImg == entry.key ? 0.9 : 0.4)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                // if (previewImageSliders.isNotEmpty)
                                //   SizedBox(
                                //     width: 40,
                                //     child: MaterialButton(
                                //       onPressed: (() => imgSliderController.nextPage()),
                                //       child: const Icon(Icons.arrow_right),
                                //     ),
                                //   ),
                              ],
                            ),
                          ],
                        );
                      }
                    }
                  })),
        if (isPreviewVidOn && context.watch<StateProvider>().previewWindowVisible)
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
    //Applied count
    if (appliedModsList.isNotEmpty) {
      totalAppliedFiles = 0;
      totalAppliedItems = appliedModsList.length;
      for (var item in appliedModsList) {
        totalAppliedFiles += item.length;
      }
    }

    void getSets() async {
      List<ModSet> tempSetsList = await modSetsListGet;
      if (setsList.isEmpty) {
        setsList = await modSetsListGet;
      }
      for (var set in tempSetsList) {
        setsDropDownList.add(set.setName);
      }
      setState(() {});
    }

    if (setsDropDownList.isEmpty) {
      getSets();
    }

    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.appliedModsHeadersText)),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          actions: [
            if (appliedModsList.isNotEmpty || totalAppliedItems > 0)
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 6, bottom: 4),
                child: Container(
                    padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).highlightColor),
                      borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: totalAppliedItems < 2
                        ? Text('$totalAppliedItems${curLangText!.itemLabelText} | $totalAppliedFiles ${curLangText!.fileAppliedLabelText}',
                            style: const TextStyle(
                              fontSize: 13,
                            ))
                        : Text('$totalAppliedItems${curLangText!.itemsLabelText} | $totalAppliedFiles ${curLangText!.fileAppliedLabelText}',
                            style: const TextStyle(
                              fontSize: 13,
                            ))),
              ),
            Tooltip(
              message: setsList.isNotEmpty ? curLangText!.modsSetSaveTooltipText : curLangText!.modsSetClickTooltipText,
              height: 25,
              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
              waitDuration: const Duration(seconds: 1),
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                  customButton: AbsorbPointer(
                    absorbing: true,
                    child: SizedBox(
                      width: 42,
                      child: MaterialButton(
                        onPressed: appliedModsList.isEmpty || setsDropDownList.isEmpty ? null : (() {}),
                        child: Row(
                          children: [
                            Icon(
                              Icons.list_alt_outlined,
                              size: 25,
                              color: totalAppliedFiles < 1 || setsDropDownList.isEmpty
                                  ? Theme.of(context).disabledColor
                                  : MyApp.themeNotifier.value == ThemeMode.light
                                      ? Theme.of(context).primaryColorDark
                                      : Theme.of(context).iconTheme.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                  ),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  isDense: true,
                  dropdownElevation: 3,
                  dropdownPadding: null,
                  dropdownWidth: 250,
                  offset: const Offset(-130, 0),
                  iconSize: 15,
                  itemHeight: 40,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 5),
                  items: setsDropDownList
                      .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).highlightColor),
                                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: setsList[setsList.indexWhere((element) => element.setName == item)].numOfItems < 2
                                      ? Text('${setsList[setsList.indexWhere((element) => element.setName == item)].numOfItems}${curLangText!.itemLabelText}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ))
                                      : Text('${setsList[setsList.indexWhere((element) => element.setName == item)].numOfItems}${curLangText!.itemsLabelText}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ))),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 3),
                                width: 187,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    //fontWeight: FontWeight.bold,
                                    //color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          )))
                      .toList(),
                  value: setsSelectedDropDown,
                  onChanged: totalAppliedFiles < 1 || setsDropDownList.isEmpty
                      ? null
                      : (value) {
                          setsSelectedDropDown = value.toString();
                          List<String> appliedList = [];
                          for (var list in appliedModsList) {
                            for (var file in list) {
                              appliedList.add(file.icePath);
                            }
                          }
                          final setIndex = setsList.indexWhere((element) => element.setName == value.toString());
                          setsList[setIndex].modFiles = appliedList.join('|');
                          setsList[setIndex].numOfItems = totalAppliedItems;
                          setsList[setIndex].isApplied = true;
                          setsList[setIndex].filesInSetList = setsList[setIndex].getModFiles(setsList[setIndex].modFiles);
                          //Json Write
                          setsList.map((set) => set.toJson()).toList();
                          File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                          setState(() {});
                        },
                )),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Tooltip(
                message: curLangText!.holdToRemoveAllBtnTooltipText,
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: MaterialButton(
                  onLongPress: appliedModsList.isEmpty || totalAppliedItems < 1
                      ? null
                      : (() {
                          setState(() {
                            reappliedCount = appliedModsList.length;
                            for (var modList in appliedModsList) {
                              reapplyMods(modList.where((element) => element.isApplied).toList()).then((_) {
                                setState(() {
                                  reappliedCount--;
                                  if (reappliedCount == 0) {
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
                                                      '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
                                              ],
                                            ),
                                          )));
                                    }
                                    originalFilesMissingList.clear();
                                    Text(curLangText!.doneBtnText);
                                  }
                                });
                              });
                            }
                          });
                        }),
                  onPressed: appliedModsList.isEmpty || totalAppliedItems < 1 ? null : () {},
                  child: Row(
                    children: [
                      if (reappliedCount > 0) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                      if (reappliedCount < 1)
                        Icon(
                          Icons.add_to_queue,
                          color: totalAppliedItems < 1
                              ? Theme.of(context).disabledColor
                              : MyApp.themeNotifier.value == ThemeMode.light
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context).iconTheme.color,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Tooltip(
                message: curLangText!.holdToRemoveAllBtnTooltipText,
                height: 25,
                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                waitDuration: const Duration(seconds: 1),
                child: MaterialButton(
                  onLongPress: appliedModsList.isEmpty || totalAppliedItems < 1
                      ? null
                      : (() {
                          setState(() {
                            List<ModFile> tempDelete = [];
                            for (var list in appliedModsList) {
                              for (var mod in list) {
                                tempDelete.add(mod);
                              }
                            }
                            modsRemover(tempDelete.where((element) => element.isApplied).toList());
                            isPreviewImgsOn = false;
                            isPreviewVidOn = false;
                            totalAppliedFiles = 0;
                            totalAppliedItems = 0;
                          });
                        }),
                  onPressed: appliedModsList.isEmpty || totalAppliedItems < 1 ? null : () {},
                  child: Icon(
                    Icons.remove_from_queue,
                    color: totalAppliedItems < 1
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
                      //if (isLoadingAppliedList.isEmpty) {
                      isLoadingAppliedList = List.generate(appliedModsList.length, (index) => false);
                      //}
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
                                          if (appliedModsList[index].first.images != null) {
                                            isPreviewImgsOn = true;
                                            futureImagesGet = appliedModsList[index].first.images;
                                          }
                                          //print(modFilesList[index].first.previewVids!.length);
                                          if (appliedModsList[index].first.previewVids!.isNotEmpty) {
                                            previewZoomState = false;
                                            isPreviewVidOn = true;
                                            isPreviewImgsOn = false;
                                            previewPlayer.setVolume(0.0);
                                            bool itemFound = false;
                                            for (var vid in appliedModsList[index].first.previewVids!) {
                                              if (medias.contains(Media.file(vid))) {
                                                itemFound = true;
                                              } else {
                                                medias.clear();
                                              }
                                            }

                                            if (medias.isEmpty || !itemFound) {
                                              for (var vid in appliedModsList[index].first.previewVids!) {
                                                medias.add(Media.file(vid));
                                              }
                                              previewPlayer.open(Playlist(medias: medias), autoStart: true);
                                            } else {
                                              previewPlayer.bufferingProgressController.done;
                                              previewPlayer.play();
                                            }
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          isPreviewImgsOn = false;
                                          isPreviewVidOn = false;
                                          previewZoomState = true;
                                          previewPlayer.pause();
                                          currentImg = 0;
                                        });
                                      }
                                    },
                                    child: GestureDetector(
                                      onSecondaryTap: () => modPreviewImgList.isNotEmpty && previewZoomState ? pictureDialog(context, previewImageSliders) : null,
                                      child: Card(
                                          margin: const EdgeInsets.only(left: 3, right: 4, top: 2, bottom: 2),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)), side: BorderSide(width: 1, color: Theme.of(context).primaryColorLight)),
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
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.black : Colors.white,
                                                        )),
                                                    Text(
                                                      appliedModsList[index].first.iceParent.trimLeft(),
                                                      style: TextStyle(
                                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.black : Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                )),

                                                //loading && add
                                                if (isLoadingAppliedList[index])
                                                  const SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                //if (appliedModsList[index].length > 1)
                                                Row(
                                                  children: [
                                                    if (appliedModsList[index].indexWhere((element) => element.isApplied == false) != -1 && !isLoadingAppliedList[index])
                                                      SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: Tooltip(
                                                          message: 'Apply unapplied mods under ${appliedModsList[index].first.iceParent} to the game',
                                                          height: 25,
                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                          waitDuration: const Duration(seconds: 1),
                                                          child: MaterialButton(
                                                            onPressed: (() {
                                                              setState(() {
                                                                isLoadingAppliedList[index] = true;
                                                                modsToDataAdder(appliedModsList[index].where((element) => element.isApplied == false).toList()).then((_) {
                                                                  setState(() {
                                                                    isLoadingAppliedList[index] = false;
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
                                                                                      '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                                      '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
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
                                                    if (appliedModsList.indexWhere((element) => element.indexWhere((e) => e.isApplied == true) != -1) != -1)
                                                      SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: Tooltip(
                                                          message:
                                                              '${curLangText!.unapplyModUnderTooltipText}"$modsViewAppBarName ${appliedModsList[index].first.iceParent}"${curLangText!.fromTheGameTooltipText}',
                                                          height: 25,
                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                          waitDuration: const Duration(seconds: 2),
                                                          child: MaterialButton(
                                                            onPressed: (() {
                                                              setState(() {
                                                                isPreviewImgsOn = false;
                                                                isPreviewVidOn = false;
                                                                modsRemover(appliedModsList[index].where((element) => element.isApplied).toList());
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
                                                ),
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
                                                              message: curLangText!.unapplyThisModTooltipText,
                                                              height: 25,
                                                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                              waitDuration: const Duration(seconds: 2),
                                                              child: MaterialButton(
                                                                onPressed: (() {
                                                                  setState(() {
                                                                    isPreviewImgsOn = false;
                                                                    isPreviewVidOn = false;
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
                                                                                      '${curLangText!.backupFileOf}"${backupFilesMissingList[i].modName} ${backupFilesMissingList[i].iceParent} > ${backupFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
                                                                              ],
                                                                            ),
                                                                          )));
                                                                    }
                                                                  });
                                                                }),
                                                                child: const Icon(Icons.replay),
                                                              ))
                                                          : Tooltip(
                                                              message: curLangText!.applyThisModTooltipText,
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
                                                                                      '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                          )),
                                    ));
                              }));
                    }
                  }
                }))
      ],
    );
  }

  Widget setList() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      AppBar(
        title: Container(padding: const EdgeInsets.only(bottom: 10), child: Text(curLangText!.setsHeaderText)),
        backgroundColor: Theme.of(context).canvasColor,
        foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
        toolbarHeight: 30,
        flexibleSpace: Container(
            height: 30,
            width: double.maxFinite,
            padding: EdgeInsets.only(left: searchBoxLeftPadding, right: 105, bottom: 3),
            child: Form(
              key: newSetFormKey,
              child: SizedBox(
                height: 30,
                width: double.maxFinite,
                child: TextFormField(
                  controller: newSetTextController,
                  maxLines: 1,
                  //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  //maxLength: 100,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 10, top: 10),
                    hintText: 'New Set Name',
                    border: OutlineInputBorder(),
                    //isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return curLangText!.newItemNameEmpty;
                    }
                    if (cateList.indexWhere((e) => e.categoryName == value) != -1) {
                      return curLangText!.newItemNameDuplicate;
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
            )),
        actions: [
          SizedBox(
            width: 96,
            height: 40,
            child: Tooltip(
              message: curLangText!.addNewSetTootipText,
              height: 25,
              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
              waitDuration: const Duration(seconds: 1),
              child: MaterialButton(
                onPressed: newSetTextController.text.isNotEmpty
                    ? (() {
                        if (newSetFormKey.currentState!.validate()) {
                          isLoadingSetList.insert(0, false);
                          setsList.insert(0, ModSet(newSetTextController.text, 0, '', false, []));
                          newSetTextController.clear();
                          setsDropDownList.clear();
                          for (var set in setsList) {
                            setsDropDownList.add(set.setName);
                          }
                          setsList.map((set) => set.toJson()).toList();
                          File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                          setState(() {});
                        }
                      })
                    : null,
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_to_queue,
                    ),
                    const SizedBox(width: 5,),
                    Text(curLangText!.addSetBtnText),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      //List
      Expanded(
        child: FutureBuilder(
            future: modSetsListGet,
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
                  setsList = snapshot.data;
                  for (var set in setsList) {
                    if (setsDropDownList.isEmpty) {
                      setsDropDownList.add(set.setName);
                    } else {
                      if (!setsDropDownList.contains(set.setName)) {
                        setsDropDownList.insert(0, set.setName);
                      }
                    }
                  }
                  if (isLoadingSetList.isEmpty) {
                    isLoadingSetList = List.generate(setsList.length, (index) => false);
                  }
                  //print(snapshot.data);
                  return SingleChildScrollView(
                      controller: AdjustableScrollController(80),
                      child: ListView.builder(
                          //key: Key('builder ${modNameCatSelected.toString()}'),
                          shrinkWrap: true,
                          //physics: const NeverScrollableScrollPhysics(),
                          itemCount: setsList.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 60,
                              child: Card(
                                margin: const EdgeInsets.only(left: 3, right: 4, top: 2, bottom: 2),
                                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(5.0)), side: BorderSide(width: 1, color: Theme.of(context).primaryColorLight)),
                                child: ListTile(
                                  minVerticalPadding: 0,
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0, top: 2),
                                        child: SizedBox(
                                          width: 200,
                                          child: Text(
                                            setsList[index].setName,
                                            style: const TextStyle(overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 0, top: 5, bottom: 2),
                                            child: Container(
                                                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Theme.of(context).highlightColor),
                                                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                ),
                                                child: setsList[index].numOfItems < 2
                                                    ? setsList[index].filesInSetList.length > 1
                                                        ? Text('${setsList[index].numOfItems}${curLangText!.itemsLabelText} | ${setsList[index].filesInSetList.length}${curLangText!.filesLabelText}',
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                            ))
                                                        : Text('${setsList[index].numOfItems}${curLangText!.itemLabelText} | ${setsList[index].filesInSetList.length}${curLangText!.fileLabelText}',
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                            ))
                                                    : setsList[index].filesInSetList.length > 1
                                                        ? Text('${setsList[index].numOfItems}${curLangText!.itemsLabelText} | ${setsList[index].filesInSetList.length}${curLangText!.filesLabelText}',
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                            ))
                                                        : Text('${setsList[index].numOfItems}${curLangText!.itemsLabelText} | ${setsList[index].filesInSetList.length}${curLangText!.fileLabelText}',
                                                            style: const TextStyle(
                                                              fontSize: 13,
                                                            ))),
                                          ),
                                          if (setsList[index].filesInSetList.indexWhere((element) => element.isApplied) != -1)
                                            Padding(
                                                padding: const EdgeInsets.only(left: 5, top: 5, bottom: 2),
                                                child: setsList[index].filesInSetList.indexWhere((element) => element.isApplied) != -1
                                                    ? Tooltip(
                                                        message: curLangText!.curFilesInSetAppliedTooltipText,
                                                        height: 25,
                                                        textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                        waitDuration: const Duration(milliseconds: 500),
                                                        child: Container(
                                                            padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Theme.of(context).highlightColor),
                                                              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                            ),
                                                            child: setsList[index].filesInSetList.where((element) => element.isApplied).length > 1
                                                                ? Text('${setsList[index].filesInSetList.where((element) => element.isApplied).length} ${curLangText!.fileAppliedLabelText}',
                                                                    style: TextStyle(
                                                                        fontSize: 13, color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber))
                                                                : Text('${setsList[index].filesInSetList.where((element) => element.isApplied).length} ${curLangText!.fileAppliedLabelText}',
                                                                    style: TextStyle(
                                                                        fontSize: 13, color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber))),
                                                      )
                                                    : const SizedBox()),
                                        ],
                                      )
                                    ],
                                  ),
                                  onTap: setsList[index].numOfItems > 0
                                      ? () {
                                          setState(() {
                                            //main func
                                            modsSetAppBarName = setsList[index].setName;
                                            setApplyingIndex = index;
                                            isViewingFav = false;
                                            isPreviewImgsOn = false;
                                            modFilesListFromSetGet = getModFilesBySet(setsList[index].modFiles);
                                            selectedIndex = List.filled(cateList.length, -1);
                                            selectedIndex[index] = index;
                                            modNameCatSelected = -1;
                                            //modsViewAppBarName = cateList[index].itemNames[i];
                                            //_newModToItemIndex = index;
                                            isSetSelected = true;
                                            isLoadingModSetList.clear();
                                          });
                                        }
                                      : null,
                                  trailing: Wrap(
                                    children: [
                                      if (setsList[index].filesInSetList.indexWhere((element) => element.isApplied) != -1)
                                        Stack(
                                          children: [
                                            if (isLoadingSetList[index])
                                              const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: CircularProgressIndicator(),
                                              ),
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Tooltip(
                                                message: '${curLangText!.unapplyModUnderTooltipText}${setsList[index].setName}${curLangText!.fromTheGameTooltipText}',
                                                height: 25,
                                                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                waitDuration: const Duration(seconds: 1),
                                                child: MaterialButton(
                                                  onPressed: (() async {
                                                    isLoadingSetList[index] = true;
                                                    modFilesFromSetList = await getModFilesBySet(setsList[index].modFiles);
                                                    List<List<ModFile>> modFilesToRemove = [];
                                                    for (var list in modFilesFromSetList) {
                                                      List<ModFile> temp = [];
                                                      for (var file in list) {
                                                        if (file.isApplied) {
                                                          temp.add(file);
                                                        }
                                                      }
                                                      modFilesToRemove.add(temp);
                                                    }
                                                    setState(() {
                                                      for (var list in modFilesToRemove) {
                                                        modsRemover(list.where((element) => element.isApplied).toList());
                                                        setState(() {
                                                          isLoadingSetList[index] = false;
                                                          setsList[index].isApplied = false;
                                                        });
                                                        setsList.map((set) => set.toJson()).toList();
                                                        File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                      }
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
                                        ),
                                      //Add
                                      if (setsList[index].numOfItems > 0)
                                        Stack(
                                          children: [
                                            if (isLoadingSetList[index])
                                              const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: CircularProgressIndicator(),
                                              ),
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Tooltip(
                                                message: '${curLangText!.applyModUnderTooltipText}"${setsList[index].setName}"${curLangText!.toTheGameTooltipText}',
                                                height: 25,
                                                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                waitDuration: const Duration(seconds: 1),
                                                child: MaterialButton(
                                                  onPressed: (() async {
                                                    isLoadingSetList[index] = true;
                                                    modFilesFromSetList = await getModFilesBySet(setsList[index].modFiles);
                                                    List<List<ModFile>> modFilesToApply = [];
                                                    for (var list in modFilesFromSetList) {
                                                      List<ModFile> temp = [];
                                                      for (var file in list) {
                                                        if (!file.isApplied) {
                                                          temp.add(file);
                                                        }
                                                      }
                                                      modFilesToApply.add(temp);
                                                    }
                                                    setState(() {
                                                      for (var list in modFilesToApply) {
                                                        modsToDataAdder(list.where((element) => element.isApplied == false).toList()).then((_) {
                                                          setState(() {
                                                            isLoadingSetList[index] = false;
                                                            setsList[index].isApplied = true;
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
                                                                              '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                              '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
                                                                      ],
                                                                    ),
                                                                  )));
                                                              modAppliedDup.clear();
                                                            }
                                                          });
                                                          setsList.map((set) => set.toJson()).toList();
                                                          File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                        });
                                                      }
                                                    });
                                                  }),
                                                  child: Icon(
                                                    Icons.playlist_add,
                                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        width: 40,
                                        child: Tooltip(
                                            message: '${curLangText!.holdToDeleteBtnTooltipText} ${setsList[index].setName}',
                                            height: 25,
                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                            waitDuration: const Duration(seconds: 2),
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: MaterialButton(
                                                  onPressed: (() {}),
                                                  onLongPress: (() {
                                                    if (setsList[index].filesInSetList.indexWhere((element) => element.isApplied) != -1) {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                          duration: const Duration(seconds: 3),
                                                          //backgroundColor: Theme.of(context).focusColor,
                                                          content: SizedBox(
                                                            height: 20,
                                                            child: Text(curLangText!.setRemovalErrorText),
                                                          )));
                                                    } else {
                                                      setsDropDownList.removeAt(index);
                                                      setsList.removeAt(index);
                                                      isLoadingSetList.removeAt(index);
                                                      setsList.map((set) => set.toJson()).toList();
                                                      File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                      setState(() {});
                                                    }
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
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }));
                }
              }
            }),
      )
    ]);
  }

  Widget modInSetList() {
    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: modsSetAppBarName.isEmpty ? Text(curLangText!.modsInSetHeaderText) : Text(modsSetAppBarName)),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
        ),
        if (isSetSelected)
          Expanded(
              child: FutureBuilder(
                  future: modFilesListFromSetGet,
                  builder: (
                    BuildContext context,
                    AsyncSnapshot snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        modFilesFromSetList = snapshot.data;
                        if (isLoadingModSetList.isEmpty) {
                          isLoadingModSetList = List.generate(modFilesFromSetList.length, (index) => false);
                        }
                        //print(snapshot.data);
                        return SingleChildScrollView(
                            controller: AdjustableScrollController(80),
                            child: ListView.builder(
                                //key: Key('builder ${modNameCatSelected.toString()}'),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: modFilesFromSetList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () {},
                                      onHover: (value) {
                                        if (value) {
                                          setState(() {
                                            if (modFilesFromSetList[index].first.images != null) {
                                              isPreviewImgsOn = true;
                                              futureImagesGet = modFilesFromSetList[index].first.images;
                                            }
                                            //print(modFilesFromSetList[index].first.previewVids!.length);
                                            if (modFilesFromSetList[index].first.previewVids!.isNotEmpty) {
                                              previewZoomState = false;
                                              isPreviewVidOn = true;
                                              isPreviewImgsOn = false;
                                              previewPlayer.setVolume(0.0);
                                              bool itemFound = false;
                                              for (var vid in modFilesFromSetList[index].first.previewVids!) {
                                                if (medias.contains(Media.file(vid))) {
                                                  itemFound = true;
                                                } else {
                                                  medias.clear();
                                                }
                                              }

                                              if (medias.isEmpty || !itemFound) {
                                                for (var vid in modFilesFromSetList[index].first.previewVids!) {
                                                  medias.add(Media.file(vid));
                                                }
                                                //previewPlayer.open(Playlist(medias: medias, playlistMode: PlaylistMode.single), autoStart: true);
                                                previewPlayer.open(Playlist(medias: medias), autoStart: true);
                                              } else {
                                                previewPlayer.bufferingProgressController.done;
                                                previewPlayer.play();
                                              }
                                            }
                                          });
                                        } else {
                                          setState(() {
                                            isPreviewImgsOn = false;
                                            isPreviewVidOn = false;
                                            previewZoomState = true;
                                            previewPlayer.pause();
                                            currentImg = 0;
                                          });
                                        }
                                      },
                                      child: GestureDetector(
                                        onSecondaryTap: () => modPreviewImgList.isNotEmpty && previewZoomState ? pictureDialog(context, previewImageSliders) : null,
                                        child: Card(
                                            margin: const EdgeInsets.only(left: 3, right: 3, top: 2, bottom: 2),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                side: BorderSide(
                                                    width: 1,
                                                    color: modFilesFromSetList[index].indexWhere((e) => e.isNew == true) != -1
                                                        ? MyApp.themeNotifier.value == ThemeMode.light
                                                            ? Theme.of(context).primaryColorDark
                                                            : Colors.amber
                                                        : Theme.of(context).primaryColorLight)),
                                            child: ExpansionTile(
                                              initiallyExpanded: modViewExpandAll,
                                              textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                              iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                              collapsedTextColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('${modFilesFromSetList[index].first.categoryName} > ${modFilesFromSetList[index].first.modName}',
                                                            style: TextStyle(fontWeight: FontWeight.w600, color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.black : Colors.white)),
                                                        Text(modFilesFromSetList[index].first.iceParent),
                                                      ],
                                                    ),
                                                  ),
                                                  //if (modFilesFromSetList[index].length > 1)
                                                  Row(
                                                    children: [
                                                      //Buttons
                                                      SizedBox(
                                                        width: 40,
                                                        height: 40,
                                                        child: Tooltip(
                                                          message: modFilesFromSetList[index].first.isFav
                                                              ? '${curLangText!.removeBtnTooltipText}"$modsViewAppBarName ${modFilesFromSetList[index].first.iceParent}"${curLangText!.fromFavTooltipText}'
                                                              : '${curLangText!.addBtnTooltipText}"$modsViewAppBarName ${modFilesFromSetList[index].first.iceParent}"${curLangText!.toFavTooltipText}',
                                                          height: 25,
                                                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                          waitDuration: const Duration(seconds: 1),
                                                          child: MaterialButton(
                                                            onPressed: (() {
                                                              var favCate = cateList.firstWhere((element) => element.categoryName == 'Favorites');
                                                              if (modFilesFromSetList[index].first.isFav) {
                                                                favCate = addOrRemoveFav(cateList, modFilesFromSetList[index], favCate, false);
                                                              } else {
                                                                favCate = addOrRemoveFav(cateList, modFilesFromSetList[index], favCate, true);
                                                              }
                                                              setState(() {});
                                                              Provider.of<StateProvider>(context, listen: false).singleItemsDropAddRemoveFirst();
                                                            }),
                                                            child: modFilesFromSetList[index].first.isFav
                                                                ? FaIcon(
                                                                    FontAwesomeIcons.heartCircleMinus,
                                                                    size: 19,
                                                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).hintColor : Theme.of(context).hintColor,
                                                                  )
                                                                : FaIcon(
                                                                    FontAwesomeIcons.heartCirclePlus,
                                                                    size: 19,
                                                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                      //loading && add
                                                      if (isLoadingModSetList[index])
                                                        const SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child: CircularProgressIndicator(),
                                                        ),

                                                      //if (modFilesFromSetList[index].length > 1 && modFilesFromSetList[index].indexWhere((element) => element.isApplied == true) != -1 && !isLoadingModSetList[index])
                                                      if (modFilesFromSetList[index].indexWhere((element) => element.isApplied == true) != -1 && !isLoadingModSetList[index])
                                                        SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child: Tooltip(
                                                            message:
                                                                '${curLangText!.unapplyModUnderTooltipText}"$modsViewAppBarName ${modFilesFromSetList[index].first.iceParent}"${curLangText!.fromTheGameTooltipText}',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 1),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsRemover(modFilesFromSetList[index].where((element) => element.isApplied).toList());

                                                                  for (var list in setsList) {
                                                                    if (list.filesInSetList.indexWhere((element) => element.isApplied) != -1) {
                                                                      list.isApplied = true;
                                                                    } else {
                                                                      list.isApplied = false;
                                                                    }
                                                                    setsList.map((set) => set.toJson()).toList();
                                                                    File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                  }
                                                                });
                                                              }),
                                                              child: Icon(
                                                                Icons.playlist_remove,
                                                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      //if (modFilesFromSetList[index].length > 1 && modFilesFromSetList[index].indexWhere((element) => element.isApplied == false) != -1 && !isLoadingModSetList[index])
                                                      if (modFilesFromSetList[index].indexWhere((element) => element.isApplied == false) != -1 && !isLoadingModSetList[index])
                                                        SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child: Tooltip(
                                                            message: '"${curLangText!.applyModUnderTooltipText}"${modFilesFromSetList[index].first.iceParent}"${curLangText!.toTheGameTooltipText}',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 1),
                                                            child: MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  isLoadingModSetList[index] = true;
                                                                  modsToDataAdder(modFilesFromSetList[index].where((element) => element.isApplied == false).toList()).then((_) {
                                                                    setState(() {
                                                                      isLoadingModSetList[index] = false;
                                                                      for (var list in setsList) {
                                                                        if (list.filesInSetList.indexWhere((element) => element.isApplied) != -1) {
                                                                          list.isApplied = true;
                                                                        } else {
                                                                          list.isApplied = false;
                                                                        }
                                                                        setsList.map((set) => set.toJson()).toList();
                                                                        File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                      }
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
                                                                                        '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                                        '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
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
                                                      if (!isViewingFav)
                                                        Tooltip(
                                                            message:
                                                                '${curLangText!.holdToRemoveBtnTooltipText}"${modFilesFromSetList[index].first.iceParent}"${curLangText!.fromText}"${setsList[setApplyingIndex].setName}"',
                                                            height: 25,
                                                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                            waitDuration: const Duration(seconds: 2),
                                                            child: SizedBox(
                                                              width: 36,
                                                              height: 40,
                                                              child: MaterialButton(
                                                                  onPressed: () {},
                                                                  onLongPress: (() {
                                                                    setState(() {
                                                                      if (modFilesFromSetList[index].indexWhere((element) => element.isApplied) != -1) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                            duration: const Duration(seconds: 3),
                                                                            //backgroundColor: Theme.of(context).focusColor,
                                                                            content: SizedBox(
                                                                              height: 20,
                                                                              child: Text(curLangText!.setRemovalErrorText),
                                                                            )));
                                                                      } else {
                                                                        List<String> tempModList = setsList[setApplyingIndex].modFiles.split('|');
                                                                        for (var modFile in modFilesFromSetList[index]) {
                                                                          tempModList.removeWhere((element) => element == modFile.icePath);
                                                                        }
                                                                        setsList[setApplyingIndex].modFiles = tempModList.join('|');
                                                                        setsList[setApplyingIndex].numOfItems--;
                                                                        modFilesFromSetList.removeAt(index);
                                                                        setsList.map((set) => set.toJson()).toList();
                                                                        File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                      }
                                                                    });
                                                                  }),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.filter_list_off_outlined,
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
                                                for (int i = 0; i < modFilesFromSetList[index].length; i++)
                                                  InkWell(
                                                      // onHover: (value) {
                                                      //   if (value &&
                                                      //       modPreviewImgList.indexWhere((e) =>
                                                      //               e.path.contains(
                                                      //                   modFilesFromSetList[
                                                      //                           index]
                                                      //                       .first
                                                      //                       .iceParent)) ==
                                                      //           -1) {
                                                      //     setState(() {
                                                      //       isPreviewImgsOn = true;
                                                      //       futureImagesGet =
                                                      //           modFilesFromSetList[index]
                                                      //                   [i]
                                                      //               .images;
                                                      //     });
                                                      //   }
                                                      // },
                                                      child: ListTile(
                                                    leading: modFilesFromSetList[index][i].isNew == true
                                                        ? Icon(
                                                            Icons.new_releases,
                                                            color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amber,
                                                          )
                                                        : null,
                                                    title: Text(modFilesFromSetList[index][i].iceName),
                                                    //subtitle: Text(modFilesFromSetList[index][i].icePath),
                                                    minLeadingWidth: 10,
                                                    trailing: SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: modFilesFromSetList[index][i].isApplied
                                                          ? Tooltip(
                                                              message: curLangText!.unapplyThisModTooltipText,
                                                              height: 25,
                                                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                              waitDuration: const Duration(seconds: 2),
                                                              child: MaterialButton(
                                                                onPressed: (() {
                                                                  setState(() {
                                                                    modsRemover([modFilesFromSetList[index][i]]);
                                                                    for (var list in setsList) {
                                                                      if (list.filesInSetList.indexWhere((element) => element.isApplied) != -1) {
                                                                        list.isApplied = true;
                                                                      } else {
                                                                        list.isApplied = false;
                                                                      }
                                                                      setsList.map((set) => set.toJson()).toList();
                                                                      File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                    }
                                                                    //appliedModsList.remove(modFilesFromSetList[index]);
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
                                                                                      '${curLangText!.originalFileOf}"${backupFilesMissingList[i].modName} ${backupFilesMissingList[i].iceParent} > ${backupFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
                                                                              ],
                                                                            ),
                                                                          )));
                                                                    }
                                                                  });
                                                                }),
                                                                child: const Icon(Icons.replay),
                                                              ))
                                                          : Tooltip(
                                                              message: curLangText!.applyThisModTooltipText,
                                                              height: 25,
                                                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                              waitDuration: const Duration(seconds: 2),
                                                              child: MaterialButton(
                                                                onPressed: (() {
                                                                  setState(() {
                                                                    modsToDataAdder([modFilesFromSetList[index][i]]);
                                                                    for (var list in setsList) {
                                                                      if (list.filesInSetList.indexWhere((element) => element.isApplied) != -1) {
                                                                        list.isApplied = true;
                                                                      } else {
                                                                        list.isApplied = false;
                                                                      }
                                                                      setsList.map((set) => set.toJson()).toList();
                                                                      File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                    }
                                                                    setsList.map((set) => set.toJson()).toList();
                                                                    File(modSetsSettingsPath).writeAsStringSync(json.encode(setsList));
                                                                    //appliedModsList.add(modFilesFromSetList[index]);
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
                                                                                      '${curLangText!.originalFileOf}"${originalFilesMissingList[i].modName} ${originalFilesMissingList[i].iceParent} > ${originalFilesMissingList[i].iceName}"${curLangText!.isNotFound}'),
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
                                                                                      '${curLangText!.replaced}${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent} > ${modAppliedDup[i].iceName}'),
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
                                            )),
                                      ));
                                }));
                      }
                    }
                  })),
      ],
    );
  }
}
