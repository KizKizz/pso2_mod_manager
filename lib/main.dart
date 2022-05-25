// ignore_for_file: unnecessary_new

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/contents_helper.dart';
import 'package:pso2_mod_manager/custom_bottom_appbar.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:path/path.dart' as p;

String binDirPath = '';
String mainModDirPath = '';
String modsDirPath = '';
String backupDirPath = '';
String checksumDirPath = '';
Future? filesData = getDataFromModDirsFuture(modsDirPath);
var dataStreamController = StreamController();

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(1280, 720);
    appWindow.minSize = const Size(852, 480);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'PSO2NGS Mod Manager';
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isDataLoaded = false;

  final imgStream = StreamController();

  @override
  void initState() {
    dirPathCheck();

    super.initState();
  }

  void dirPathCheck() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';
    if (binDirPath.isEmpty) {
      getDirPath();
    } else {
      //Fill in paths
      mainModDirPath = '$binDirPath\\PSO2 Mod Manager';
      modsDirPath = '$mainModDirPath\\Mods';
      backupDirPath = '$mainModDirPath\\Backups';
      checksumDirPath = '$mainModDirPath\\Checksum';
      //Check if exist, create dirs
      if (!Directory(mainModDirPath).existsSync()) {
        await Directory(mainModDirPath).create(recursive: true);
      }
      if (!Directory(modsDirPath).existsSync()) {
        await Directory(modsDirPath).create(recursive: true);
      }
      if (!Directory(backupDirPath).existsSync()) {
        await Directory(backupDirPath).create(recursive: true);
      }
      if (!Directory(checksumDirPath).existsSync()) {
        await Directory(checksumDirPath).create(recursive: true);
      }
      setState(() {
        isDataLoaded = true;
      });
    }
  }

  void getDirPath() {
    const CustomPopups().binDirDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return !isDataLoaded
        ? const CircularProgressIndicator()
        : Scaffold(
            body: WindowBorder(
              color: Colors.black,
              width: 1,
              child: Column(
                children: [
                  WindowTitleBarBox(
                    child: Container(
                      color: Theme.of(context).canvasColor,
                      child: Row(
                        children: [
                          Expanded(
                              child: MoveWindow(
                            child: Container(
                                padding: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'PSO2NGS Mod Manager',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                )),
                          )),
                          const WindowButtons(),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                      future: filesData,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: SizedBox(
                                width: 200,
                                height: 200,
                                child: Text('data')
                                //CircularProgressIndicator()
                                ));
                        } else {
                          if (snapshot.hasError) {
                            return const Text('Error');
                          } else {
                            mainDataList = snapshot.data;
                            categoryList = getCategoryList(mainDataList);
                            cateList = categoryAdder(mainDataList);

                            //Mod Item
                            for (var cate in cateList) {
                              final filesList =
                                  cate.categorySubList.whereType<File>();
                              List<ModFile> filesInCate = [];
                              for (var file in filesList) {
                                final fileExtension = p.extension(file.path);
                                List<File> imgList = [];
                                if (fileExtension == '.jpg' ||
                                    fileExtension == '.png') {
                                  imgList.add(file);
                                }
                                if (fileExtension == '') {
                                  ModFile newMod = ModFile(
                                      file.path,
                                      getDirHeader(file.parent),
                                      getFileName(file),
                                      getDirHeader(Directory(
                                          getRootParentDirPath(
                                              file, cate.categoryName))),
                                      getRootParentDirPath(
                                          file, cate.categoryName),
                                      cate.categoryName,
                                      imgList,
                                      false,
                                      true);
                                  filesInCate.add(newMod);
                                }
                              }
                              modFilesList.add(filesInCate);
                            }

                            return const HomePage();
                          }
                        }
                      })
                ],
              ),
            ),
            //bottomNavigationBar: const CustomBottomAppBar(
            //fabLocation: _fabLocation,
            //shape: _showNotch ? const CircularNotchedRectangle() : null,
            //  ),
          );
  }
}
