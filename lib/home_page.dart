// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';

List<ModCategory> cateList = [];
Future? modFilesListGet;
Future? futureImagesGet;
List<File> modPreviewImgList = [];
List<List<ModFile>> modFilesList = [];
List<List<ModFile>> appliedModsList = [];
List<ModFile> modAppliedDup = [];
bool originalFileFound = false;
bool backupFileFound = false;

//New Cate
bool addCategoryVisible = false;
final categoryFormKey = GlobalKey<FormState>();
TextEditingController categoryAddController = TextEditingController();

//NewItem
bool addItemVisible = false;
final newItemFormKey = GlobalKey<FormState>();
TextEditingController newItemAddController = TextEditingController();
List<String> dropdownCategories = [];
String? selectedCategory;
final _newItemDropdownKey = GlobalKey<FormState>();
bool _dragging = false;
//final List<XFile> _newItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test')];
final List<XFile> _newItemDragDropList = [];

//NewItem Exist Item
bool addModToItemVisible = false;
final newModToItemFormKey = GlobalKey<FormState>();
TextEditingController newModToItemAddController = TextEditingController();
bool _newModToItemDragging = false;
//final List<XFile> _newModToItemDragDropList = [XFile('E:\\PSO2_ModTest\\7 Bite o Donut Test\\Red ball gag - Copy')];
final List<XFile> _newModToItemDragDropList = [];
int _newModToItemIndex = 0;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MultiSplitViewController _viewsController = MultiSplitViewController(areas: [Area(weight: 0.3), Area(weight: 0.3)]);
  final MultiSplitViewController _verticalViewsController = MultiSplitViewController(areas: [Area(weight: 0.5)]);
  String modsViewAppBarName = '';
  List<int> selectedIndex = List.generate(cateList.length, (index) => -1);
  final CarouselController imgSliderController = CarouselController();

  int modNameCatSelected = -1;
  bool isModSelected = false;
  int currentImg = 0;
  bool isPreviewImgsOn = false;

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
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
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
                                    addCategoryVisible = true;
                                  });
                                }),
                          child: Stack(
                            children: const [
                              Icon(Icons.category_outlined),
                              Positioned(
                                  left: 11.5,
                                  bottom: 10,
                                  child: Icon(
                                    Icons.add,
                                    size: 16,
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
                                    addItemVisible = true;
                                  });
                                }),
                          child: Row(
                            children: const [Icon(Icons.add_box_outlined)],
                          )),
                    ))),
          ],
        ),

        //Add Category Panel
        if (addCategoryVisible)
          Container(
            //height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                  spreadRadius: -1,
                  blurRadius: 3,
                  offset: const Offset(0, 4), // changes position of shadow
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
                                addCategoryVisible = false;
                              });
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Close')],
                            )),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Add Category')],
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),

        //Add Item Panel
        if (addItemVisible)
          Container(
            //height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                  spreadRadius: -1,
                  blurRadius: 3,
                  offset: const Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
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
                        value: selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: newItemFormKey,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 10),
                        child: TextFormField(
                          controller: newItemAddController,
                          //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          //maxLength: 100,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            labelText: 'Change Item Name\n(optional, single item)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Category name can\'t be empty';
                            // }
                            if (cateList.indexWhere((e) => e.categoryName == selectedCategory && e.itemNames.indexWhere((element) => element == value) != -1) != -1) {
                              return 'Item name already exist';
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

              //Drop Zone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DropTarget(
                  //enable: true,
                  onDragDone: (detail) {
                    setState(() {
                      _newItemDragDropList.addAll(detail.files);
                      
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
                          if (_newItemDragDropList.isEmpty) const Center(child: Text("Drop Modded Item Folder(s) Here")),
                          if (_newItemDragDropList.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0; i < _newItemDragDropList.length; i++) Text(' ${_newItemDragDropList[i].name}'),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      )),
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
                            onPressed: (() {
                              setState(() {
                                _newItemDragDropList.clear();
                                newItemAddController.clear();
                                selectedCategory = null;
                                addItemVisible = false;
                              });
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Close')],
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: ElevatedButton(
                            onPressed: selectedCategory != null && _newItemDragDropList.isNotEmpty
                                ? (() {
                                    setState(() {
                                      if (newItemFormKey.currentState!.validate()) {
                                        dragDropFilesAdd(_newItemDragDropList, selectedCategory, newItemAddController.text);
                                        //selectedCategory = null;
                                        _newItemDragDropList.clear();
                                        newItemAddController.clear();
                                        //addItemVisible = false;

                                      }
                                    });
                                  })
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Add Item(s)')],
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ]),
          ),

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
                      // Test
                    ],
                  ),
                  children: [
                    for (int i = 0; i < cateList[index].numOfItems; i++)
                      Ink(
                        color: selectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                        child: ListTile(
                          leading: cateList[index].imageIcons[i].first.path.split('/').last != 'placeholdersquare.jpg'
                          ? Image.file(cateList[index].imageIcons[i].first)
                          : Image.asset(cateList[index].imageIcons[i].first.path),
                          title: Text(cateList[index].itemNames[i]),
                          subtitle: Text('Mods: ${cateList[index].numOfMods[i]} | Applied: ${cateList[index].numOfApplied[i]}'),
                          trailing: cateList[index].allModFiles.indexWhere((element) => element.modName == cateList[index].itemNames[i] && element.isNew == true) == -1 ? null : Icon(Icons.new_releases, color: Theme.of(context).indicatorColor),
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
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Tooltip(
                    message: 'Add Mod to $modsViewAppBarName',
                    height: 25,
                    textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                    waitDuration: const Duration(seconds: 1),
                    child: SizedBox(
                      width: 40,
                      height: 30,
                      child: MaterialButton(
                          onPressed: addModToItemVisible || modsViewAppBarName.isEmpty
                              ? null
                              : (() {
                                  setState(() {
                                    addModToItemVisible = true;
                                  });
                                }),
                          child: Row(
                            children: const [Icon(Icons.add_box_outlined)],
                          )),
                    ))),
          ],
        ),

        //Add Mod to Existing Item
        if (addModToItemVisible)
          Container(
            //height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.3),
                  spreadRadius: -1,
                  blurRadius: 3,
                  offset: const Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(
                children: [
                  Expanded(
                    child: Form(
                      key: newModToItemFormKey,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                        child: TextFormField(
                          controller: newModToItemAddController,
                          //maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          //maxLength: 100,
                          style: const TextStyle(fontSize: 15),
                          decoration: const InputDecoration(
                            labelText: 'Change Mod Name (optional, single mod)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            // if (value == null || value.isEmpty) {
                            //   return 'Category name can\'t be empty';
                            // }
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

              //Drop Zone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: DropTarget(
                  //enable: true,
                  onDragDone: (detail) {
                    setState(() {
                      _newModToItemDragDropList.addAll(detail.files);
                     
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
                          if (_newModToItemDragDropList.isEmpty) const Center(child: Text("Drop Mod Folder(s) Here")),
                          if (_newModToItemDragDropList.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0; i < _newModToItemDragDropList.length; i++) Text(' ${_newModToItemDragDropList[i].name}'),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      )),
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
                            onPressed: (() {
                              setState(() {
                                _newModToItemDragDropList.clear();
                                newModToItemAddController.clear();
                                addModToItemVisible = false;
                              });
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Close')],
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: ElevatedButton(
                            onPressed: _newModToItemDragDropList.isNotEmpty
                                ? (() {
                                    setState(() {
                                      if (newModToItemFormKey.currentState!.validate()) {
                                        if (modFilesList.isNotEmpty) {
                                          dragDropModsAdd(_newModToItemDragDropList, modsViewAppBarName, modFilesList.first.first.modPath, _newModToItemIndex, newModToItemAddController.text);
                                        }

                                        _newModToItemDragDropList.clear();
                                        newModToItemAddController.clear();
                                        //addItemVisible = false;
                                      }
                                    });
                                  })
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text('Add Mod(s)')],
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ]),
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
                                            initiallyExpanded: true,
                                            textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                            iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                            // leading: modFilesList[index].indexWhere((e) => e.isNew == true) != -1
                                            //     ? Icon(
                                            //         Icons.new_releases,
                                            //         color: Theme.of(context).indicatorColor,
                                            //       )
                                            //     : null,
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(modFilesList[index].first.iceParent),
                                                ),
                                                if (modFilesList[index].length > 1)
                                                  SizedBox(
                                                    width: 40,
                                                    height: 40,
                                                    child: Tooltip(
                                                      message: 'Apply All Files',
                                                      height: 25,
                                                      textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                                      waitDuration: const Duration(seconds: 1),
                                                      child: MaterialButton(
                                                        onPressed: (() {
                                                          setState(() {
                                                            modsToDataAdder(modFilesList[index].toList());
                                                          });
                                                        }),
                                                        child: Icon(
                                                          Icons.add_outlined,
                                                          color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
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
                                                        ? Icon(
                                                            Icons.new_releases,
                                                            color: Theme.of(context).indicatorColor,
                                                          )
                                                        : null,
                                                    title: Text(modFilesList[index][i].iceName),
                                                    //subtitle: Text(modFilesList[index][i].icePath),
                                                    minLeadingWidth: 10,
                                                    trailing: SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: modFilesList[index][i].isApplied
                                                          ? MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsRemover([modFilesList[index][i]]);
                                                                  if (!backupFileFound) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      duration: const Duration(seconds: 2),
                                                                      //backgroundColor: Theme.of(context).focusColor,
                                                                      content: Text('Backup file of "${modFilesList[index][i].modName} ${modFilesList[index][i].iceParent} > ${modFilesList[index][i].iceName}" not found'),
                                                                    ));
                                                                  }
                                                                });
                                                              }),
                                                              child: const Icon(Icons.remove_outlined),
                                                            )
                                                          : MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  modsToDataAdder([modFilesList[index][i]]);
                                                                  appliedModsList.add(modFilesList[index]);
                                                                  if (!originalFileFound) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      duration: const Duration(seconds: 2),
                                                                      //backgroundColor: Theme.of(context).focusColor,
                                                                      content: Text('Original file of "${modFilesList[index][i].modName} ${modFilesList[index][i].iceParent} > ${modFilesList[index][i].iceName}" not found'),
                                                                    ));
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
                                                                              for (int i = 0; i < modAppliedDup.length; i++) Text('Replaced: ${modAppliedDup[i].categoryName} > ${modAppliedDup[i].modName} ${modAppliedDup[i].iceParent}'),
                                                                            ],
                                                                          ),
                                                                        )));
                                                                  }

                                                                  modAppliedDup.clear();
                                                                });
                                                              }),
                                                              child: const Icon(Icons.add_outlined),
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

  Widget modPreviewView() {
    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Preview')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
        ),
        if (isPreviewImgsOn)
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
                                options: CarouselOptions(
                                    autoPlay: previewImageSliders.length > 1,
                                    reverse: true,
                                    viewportFraction: 1,
                                    enlargeCenterPage: true,
                                    aspectRatio: 2.0,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        currentImg = index;
                                      });
                                    }),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: modPreviewImgList.asMap().entries.map((entry) {
                                return GestureDetector(
                                  // onTap: () => imgSliderController
                                  //     .animateToPage(entry.key),
                                  child: Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity(currentImg == entry.key ? 0.9 : 0.4)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }
                    }
                  }))
      ],
    );
  }

  Widget filesView() {
    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Applied Mods')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          toolbarHeight: 30,
        ),
        // Expanded(
        //     child: Container(
        //         child: ListView.builder(
        //             key: Key('builder ${modNameCatSelected.toString()}'),
        //             shrinkWrap: true,
        //             physics: const NeverScrollableScrollPhysics(),
        //             itemCount: appliedModsList.length,
        //             itemBuilder: (context, index) {
        //               return InkWell(
        //                   onTap: () {},
        //                   onHover: (value) {
        //                     if (value) {
        //                       setState(() {
        //                         isPreviewImgsOn = true;
        //                         futureImagesGet = appliedModsList[index].first.images;
        //                       });
        //                     }
        //                     // else {
        //                     //   setState(() {
        //                     //     isPreviewImgsOn = false;
        //                     //   });
        //                     // }
        //                   },
        //                   child: Card(
        //                       shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(5.0)), side: BorderSide(width: 1, color: Theme.of(context).primaryColor)),
        //                       child: ExpansionTile(
        //                         initiallyExpanded: true,
        //                         textColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
        //                         iconColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
        //                         // leading: modFilesList[index].indexWhere((e) => e.isNew == true) != -1
        //                         //     ? Icon(
        //                         //         Icons.new_releases,
        //                         //         color: Theme.of(context).indicatorColor,
        //                         //       )
        //                         //     : null,
        //                         title: Row(
        //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                           children: [
        //                             Flexible(
        //                               child: Text(modFilesList[index].first.iceParent),
        //                             ),
        //                             if (appliedModsList[index].length > 1)
        //                               SizedBox(
        //                                 width: 40,
        //                                 height: 40,
        //                                 child: Tooltip(
        //                                   message: 'Remove All Files',
        //                                   height: 25,
        //                                   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
        //                                   waitDuration: const Duration(seconds: 1),
        //                                   child: MaterialButton(
        //                                     onPressed: (() {
        //                                       setState(() {
        //                                         modsRemover(appliedModsList[index].toList());
        //                                       });
        //                                     }),
        //                                     child: Icon(
        //                                       Icons.add_outlined,
        //                                       color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
        //                                     ),
        //                                   ),
        //                                 ),
        //                               ),
        //                           ],
        //                         ),
        //                         children: [
        //                           for (int i = 0; i < modFilesList[index].length; i++)
        //                             InkWell(
        //                               // onHover: (value) {
        //                               //   if (value &&
        //                               //       modPreviewImgList.indexWhere((e) =>
        //                               //               e.path.contains(
        //                               //                   modFilesList[
        //                               //                           index]
        //                               //                       .first
        //                               //                       .iceParent)) ==
        //                               //           -1) {
        //                               //     setState(() {
        //                               //       isPreviewImgsOn = true;
        //                               //       futureImagesGet =
        //                               //           modFilesList[index]
        //                               //                   [i]
        //                               //               .images;
        //                               //     });
        //                               //   }
        //                               // },
        //                               child: ListTile(
        //                                 leading: appliedModsList[index][i].isNew == true
        //                                     ? Icon(
        //                                         Icons.new_releases,
        //                                         color: Theme.of(context).indicatorColor,
        //                                       )
        //                                     : null,
        //                                 title: Text(appliedModsList[index][i].iceName),
        //                                 //subtitle: Text(modFilesList[index][i].icePath),
        //                                 minLeadingWidth: 10,
        //                                 trailing: SizedBox(
        //                                   width: 40,
        //                                   height: 40,
        //                                   child: appliedModsList[index][i].isApplied
        //                                       ? MaterialButton(
        //                                           onPressed: (() {
        //                                             setState(() {
        //                                               modsRemover([appliedModsList[index][i]]);
        //                                               if (!backupFileFound) {
        //                                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                                                   duration: const Duration(seconds: 2),
        //                                                   //backgroundColor: Theme.of(context).focusColor,
        //                                                   content: Text('Backup file of "${appliedModsList[index][i].modName} ${appliedModsList[index][i].iceParent} > ${appliedModsList[index][i].iceName}" not found'),
        //                                                 ));
        //                                               }
        //                                             });
        //                                           }),
        //                                           child: const Icon(Icons.remove_outlined),
        //                                         )
        //                                       : MaterialButton(
        //                                           onPressed: (() {
        //                                             setState(() {
        //                                               singleModAdder([appliedModsList[index][i]]);
        //                                               if (!originalFileFound) {
        //                                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                                                   duration: const Duration(seconds: 2),
        //                                                   //backgroundColor: Theme.of(context).focusColor,
        //                                                   content: Text('Original file of "${appliedModsList[index][i].modName} ${appliedModsList[index][i].iceParent} > ${appliedModsList[index][i].iceName}" not found'),
        //                                                 ));
        //                                               }
        //                                             });
        //                                           }),
        //                                           child: const Icon(Icons.add_outlined),
        //                                         ),
        //                                 ),
        //                               ),
        //                             )
        //                         ],
        //                       )));
        //             })))
      ],
    );
  }
}
