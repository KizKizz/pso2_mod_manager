import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  runApp(const MyApp());
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
  String binDirPath = '';
  String mainModDirPath = '';
  String modsDirPath = '';
  String backupDirPath = '';
  String checksumDirPath = '';

  @override
  void initState() {
    super.initState();
    dirPathCheck();
  }

  void dirPathCheck() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';
    if (binDirPath.isEmpty) {
      _binDirDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Text(widget.title),
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //bin Folder Not Found Popup
  _binDirDialog() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return _SystemPadding(
            child: AlertDialog(
              titlePadding: const EdgeInsets.only(top: 10),
              title: const Center(
                child: Text('Error',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              contentPadding: const EdgeInsets.only(left: 16, right: 16),
              content: const SizedBox(
                  //width: 300,
                  height: 70,
                  child: Center(
                      child: Text(
                          'pso2_bin\'s directory path not found. Select now?'))),
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Exit'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await windowManager.destroy();
                    }),
                ElevatedButton(
                    onPressed: (() async {
                      Navigator.of(context).pop();
                      String? binDirTempPath = '';
                      binDirTempPath =
                          await FilePicker.platform.getDirectoryPath(
                        dialogTitle: 'Select \'pso2_bin\' Directory Path',
                        lockParentWindow: true,
                      );

                      if (binDirTempPath == null) {
                        _binDirDialog();
                      } else {
                        List<String> getCorrectPath =
                            binDirTempPath.toString().split('\\');
                        //print(getCorrectPath.last);
                        if (getCorrectPath.last == 'pso2_bin') {
                          binDirPath = binDirTempPath.toString();
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('binDirPath', binDirPath);
                          //Fill in paths
                          mainModDirPath = '$binDirPath\\PSO2 Mod Manager';
                          modsDirPath = '$mainModDirPath\\Mods';
                          backupDirPath = '$mainModDirPath\\Backups';
                          checksumDirPath = '$mainModDirPath\\Checksum';
                          //Check if exist, create dirs
                          if (!Directory(mainModDirPath).existsSync()) {
                            await Directory(mainModDirPath)
                                .create(recursive: true);
                          }
                          if (!Directory(modsDirPath).existsSync()) {
                            await Directory(modsDirPath)
                                .create(recursive: true);
                          }
                          if (!Directory(backupDirPath).existsSync()) {
                            await Directory(backupDirPath)
                                .create(recursive: true);
                          }
                          if (!Directory(checksumDirPath).existsSync()) {
                            await Directory(checksumDirPath)
                                .create(recursive: true);
                          }
                        } else {
                          binDirTempPath =
                              await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Select \'pso2_bin\' Directory Path',
                            lockParentWindow: true,
                          );
                        }
                      }
                    }),
                    child: const Text('Yes'))
              ],
            ),
          );
        });
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  const _SystemPadding({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
