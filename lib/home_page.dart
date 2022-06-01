import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/scroll_controller.dart';

List<ModCategory> cateList = [];
Future? modFilesListGet;
Future? futureImagesGet;
List<File> modPreviewImgList = [];
List<List<ModFile>> modFilesList = [];
bool originalFileFound = false;
bool backupFileFound = false;

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
    return Column(
      children: [
        AppBar(
          title: Container(padding: const EdgeInsets.only(bottom: 10), child: const Text('Items')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                  children: [
                    for (int i = 0; i < cateList[index].numOfItems; i++)
                      Ink(
                        color: selectedIndex[index] == i ? Theme.of(context).highlightColor : Colors.transparent,
                        child: ListTile(
                          leading: Image.file(cateList[index].imageIcons[i].first),
                          title: Text(cateList[index].itemNames[i]),
                          subtitle: Text('Mods: ${cateList[index].numOfMods[i]} | Applied: ${cateList[index].numOfApplied[i]}'),
                          onTap: () {
                            setState(() {
                              isPreviewImgsOn = false;
                              modFilesListGet = getModFilesByCategory(cateList[index].allModFiles, cateList[index].itemNames[i]);
                              selectedIndex = List.filled(cateList.length, -1);
                              selectedIndex[index] = i;
                              modNameCatSelected = -1;
                              modsViewAppBarName = cateList[index].itemNames[i];
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
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        ),
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
                                                    child: MaterialButton(
                                                      onPressed: (() {
                                                        setState(() {});
                                                      }),
                                                      child: Icon(Icons.add_circle_outline_outlined, color: Theme.of(context).primaryColor),
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
                                                    title: Text(modFilesList[index][i].iceName),
                                                    //subtitle: Text(modFilesList[index][i].icePath),
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
                                                                      content: Text('Backup file of "${modFilesList[index][i].modName} > ${modFilesList[index][i].iceParent} > ${modFilesList[index][i].iceName}" not found'),
                                                                    ));
                                                                  }
                                                                });
                                                              }),
                                                              child: const Icon(Icons.remove_outlined),
                                                            )
                                                          : MaterialButton(
                                                              onPressed: (() {
                                                                setState(() {
                                                                  singleModAdder([modFilesList[index][i]]);
                                                                  if (!originalFileFound) {
                                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                                      duration: const Duration(seconds: 2),
                                                                      //backgroundColor: Theme.of(context).focusColor,
                                                                      content: Text('Original file of "${modFilesList[index][i].modName} > ${modFilesList[index][i].iceParent} > ${modFilesList[index][i].iceName}" not found'),
                                                                    ));
                                                                  }
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
          foregroundColor: Theme.of(context).primaryColor,
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
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        )
      ],
    );
  }
}
