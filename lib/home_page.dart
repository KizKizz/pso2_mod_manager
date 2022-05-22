import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:pso2_mod_manager/contents_helper.dart';
import 'package:pso2_mod_manager/main.dart';

List<Directory> modCatDirsList = getDirsInParentDir(Directory(modsDirPath));
List<List<Directory>> modItemDirsList = List.generate(
    modCatDirsList.length, (i) => getDirsInParentDir(modCatDirsList[i]));
List<String> modCatDirHeadersList = getHeadersFromList(modCatDirsList);
List<Directory> modDirsList = [];
List<File> modPreviewImgList = [];
Future? futureItemsGet = futureGetDirsInParentDir(Directory(modsDirPath));
Future? futureImagesGet = futureGetImgInDir(Directory(modsDirPath));

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MultiSplitViewController _viewsController =
      MultiSplitViewController(areas: [Area(weight: 0.3), Area(weight: 0.3)]);
  final MultiSplitViewController _verticalViewsController =
      MultiSplitViewController(areas: [Area(weight: 0.5)]);
  String modsViewAppBarName = '';
  List<int> selectedIndex = List.generate(modCatDirsList.length, (index) => -1);
  final CarouselController imgSliderController = CarouselController();

  int modNameCatSelected = -1;
  bool isModSelected = false;
  bool isPreviewImgFound = false;
  int currentImg = 0;
  
  bool isSameImgData = false;

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
    List<List<List<Directory>>> iVDirsList = List.generate(
        modItemDirsList.length,
        (index) => getDirsInParentDirs(modItemDirsList[index]));

    List<List<String>> iVDirHeadersList = List.generate(modItemDirsList.length,
        (index) => getHeadersFromList(modItemDirsList[index]));

    return Column(
      children: [
        AppBar(
          title: Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text('Items')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modCatDirsList.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  initiallyExpanded: false,
                  onExpansionChanged: (newState) {
                    setState(() {
                      if (!newState) {
                        selectedIndex = List.filled(modCatDirsList.length, -1);
                        isPreviewImgFound = false;
                      } else {
                        selectedIndex = List.filled(modCatDirsList.length, -1);
                        isPreviewImgFound = false;
                      }
                    });
                  },
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(modCatDirHeadersList[index]),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, top: 3),
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 2, right: 2, bottom: 1),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).highlightColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child:
                                Text('${modItemDirsList[index].length} Items',
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ))),
                      ),
                    ],
                  ),
                  children: [
                    for (int i = 0; i < modItemDirsList[index].length; i++)
                      Ink(
                        color: selectedIndex[index] == i
                            ? Theme.of(context).primaryColorLight
                            : Colors.transparent,
                        child: ListTile(
                          leading: Image.file(
                              itemsDirListIcon(modItemDirsList[index][i].path)),
                          title: Text(iVDirHeadersList[index][i]),
                          subtitle: Text(
                              'Mods: ${iVDirsList[index][i].length} | Applied: 0'),
                          onTap: () {
                            setState(() {
                              selectedIndex =
                                  List.filled(modCatDirsList.length, -1);
                              selectedIndex[index] = i;
                              modNameCatSelected = -1;
                              modsViewAppBarName = iVDirHeadersList[index][i];
                              futureItemsGet = futureGetDirsInParentDir(
                                  modItemDirsList[index][i]);
                              isModSelected = true;
                              isPreviewImgFound = false;
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
                  modsViewAppBarName.isEmpty
                      ? const Text('Available Mods')
                      : Text('Mods for $modsViewAppBarName'),
                ],
              )),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        ),
        if (isModSelected)
          Expanded(
              child: FutureBuilder(
                  future: futureItemsGet,
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
                        modDirsList = snapshot.data;
                        return SingleChildScrollView(
                            controller: ScrollController(),
                            child: ListView.builder(
                                key: Key(
                                    'builder ${modNameCatSelected.toString()}'),
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: modDirsList.length,
                                itemBuilder: (context, index) {
                                  var filesFromPath =
                                      getFilesFromPath(modDirsList[index].path);
                                  var fileHeaders =
                                      getHeaderFromDir(modDirsList[index]);
                                  var modFileHeaders =
                                      getFileHeadersFromList(filesFromPath);
                                  var modHeaders =
                                      getParentHeadersFromFilesList(
                                              filesFromPath)
                                          .toSet()
                                          .toList();
                                  List<List<FileSystemEntity>> modsByType = [];
                                  for (var header in modHeaders) {
                                    modsByType.add(filesFromPath
                                        .where((e) =>
                                            getParentHeaderFromFile(e) ==
                                            header)
                                        .toList());
                                  }
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5.0)),
                                        side: BorderSide(
                                            width: 1,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    child: ExpansionTile(
                                        //key: Key(index.toString()),
                                        // initiallyExpanded:
                                        //     index == modNameCatSelected,
                                        // onExpansionChanged: ((newState) {
                                        //   if (newState) {
                                        //     setState(() {
                                        //       //const Duration(seconds: 20000);
                                        //       modNameCatSelected = index;
                                        //     });
                                        //   }
                                        //   // else {
                                        //   //   setState(() {
                                        //   //     modNameCatSelected = -1;
                                        //   //   });
                                        //   // }
                                        // }),
                                        title: Text(fileHeaders),
                                        onExpansionChanged: (value) {
                                          setState(() {
                                            if (value) {
                                              futureImagesGet =
                                                  futureGetImgInDir(Directory(
                                                      modDirsList[index].path));
                                              isPreviewImgFound = true;
                                            } else {
                                              isPreviewImgFound = false;
                                            }
                                          });
                                        },
                                        children: [
                                          for (int i = 0;
                                              i < modHeaders.length;
                                              i++)
                                            ExpansionTile(
                                                initiallyExpanded:
                                                    fileHeaders ==
                                                        modHeaders[i],
                                                onExpansionChanged: (value) {
                                                  setState(() {
                                                    futureImagesGet =
                                                        futureGetImgInDir(
                                                            Directory(
                                                                modsByType[i][0]
                                                                    .parent
                                                                    .path));
                                                    isPreviewImgFound = true;
                                                    // print(
                                                    //     '${modsByType[i][0]} \n');
                                                  });
                                                },
                                                title: Text(modHeaders[i]),
                                                children: [
                                                  for (int n = 0;
                                                      n < modsByType[i].length;
                                                      n++)
                                                    ListTile(
                                                      title: Text(
                                                          getFileHeadersFromList(
                                                              modsByType[
                                                                  i])[n]),
                                                      subtitle: modsViewAppBarName !=
                                                                  getMoreParentHeadersFromFilesList(
                                                                          modsByType[
                                                                              i])[
                                                                      n] &&
                                                              modHeaders[i] !=
                                                                  getMoreParentHeadersFromFilesList(
                                                                          modsByType[
                                                                              i])[
                                                                      n] &&
                                                              fileHeaders !=
                                                                  getMoreParentHeadersFromFilesList(
                                                                      modsByType[
                                                                          i])[n]
                                                          ? Text(
                                                              getMoreParentHeadersFromFilesList(
                                                                  modsByType[
                                                                      i])[n])
                                                          : null,
                                                    )
                                                ])
                                        ]),
                                  );
                                }));
                      }
                    }
                  })),
      ],
    );
  }

  Widget modPreviewView() {
    return Column(
      children: [
        AppBar(
          title: Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text('Preview')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        ),
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
                      if (snapshot.data != modPreviewImgList) {
                        isSameImgData = false;
                        modPreviewImgList = snapshot.data;
                      } else {
                        isSameImgData = true;
                      }
                      //print(modPreviewImgList.toString());
                      List<Widget> previewImageSliders = modPreviewImgList
                          .map((item) => Container(
                                margin: const EdgeInsets.all(2.0),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5.0)),
                                    child: Stack(
                                      children: <Widget>[
                                        Image.file(item,
                                            fit: BoxFit.cover, width: 1000.0),
                                        //Text(modPreviewImgList.toString())
                                      ],
                                    )),
                              ))
                          .toList();
                      return Column(
                        children: [
                          //if (isPreviewImgFound && !isSameImgData)
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
                          //if (isPreviewImgFound && !isSameImgData)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: modPreviewImgList
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return GestureDetector(
                                  // onTap: () => imgSliderController
                                  //     .animateToPage(entry.key),
                                  child: Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white
                                                : Colors.black)
                                            .withOpacity(currentImg == entry.key
                                                ? 0.9
                                                : 0.4)),
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
          title: Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: const Text('Applied Mods')),
          backgroundColor: Theme.of(context).canvasColor,
          foregroundColor: Theme.of(context).primaryColor,
          toolbarHeight: 30,
        )
      ],
    );
  }
}
