// ignore_for_file: unnecessary_new

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:url_launcher/url_launcher.dart';

String binDirPath = '';
String mainModDirPath = '';
String modsDirPath = '';
String backupDirPath = '';
String checksumDirPath = '';
String modSettingsPath = '';
String deletedItemsPath = '';
String? checkSumFilePath;
FilePickerResult? checksumLocation;
Future? filesData;
List<ModFile> allModFiles = [];
var dataStreamController = StreamController();
void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => stateProvider()),
  ], child: const RestartWidget(child: MyApp())));
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
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: currentMode,
            home: const MyHomePage(
              title: '',
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final imgStream = StreamController();
  bool isDarkModeOn = false;

  @override
  void initState() {
    miscCheck();
    dirPathCheck();
    super.initState();
  }

  void miscCheck() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Darkmode check
      isDarkModeOn = (prefs.getBool('isDarkModeOn') ?? false);
      if (isDarkModeOn) {
        MyApp.themeNotifier.value = ThemeMode.dark;
      }
    });
  }

  void dirPathCheck() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';

    if (binDirPath.isEmpty) {
      getDirPath();
    } else {
      //Fill in paths
      mainModDirPath = '$binDirPath\\PSO2 Mod Manager';
      modsDirPath = '$mainModDirPath\\Mods';
      backupDirPath = '$mainModDirPath\\Backups';
      checksumDirPath = '$mainModDirPath\\Checksum';
      modSettingsPath = '$mainModDirPath\\PSO2ModManSettings.json';
      deletedItemsPath = '$mainModDirPath\\Deleted Items';
      //Check if exist, create dirs
      if (!Directory(mainModDirPath).existsSync()) {
        await Directory(mainModDirPath).create(recursive: true);
      }
      if (!Directory(modsDirPath).existsSync()) {
        await Directory(modsDirPath).create(recursive: true);
        await Directory('$modsDirPath\\Accessories').create(recursive: true);
        await Directory('$modsDirPath\\Basewears').create(recursive: true);
        await Directory('$modsDirPath\\Body Paints').create(recursive: true);
        await Directory('$modsDirPath\\Emotes').create(recursive: true);
        await Directory('$modsDirPath\\Face Paints').create(recursive: true);
        await Directory('$modsDirPath\\Innerwears').create(recursive: true);
        await Directory('$modsDirPath\\Misc').create(recursive: true);
        await Directory('$modsDirPath\\Motions').create(recursive: true);
        await Directory('$modsDirPath\\Outerwears').create(recursive: true);
        await Directory('$modsDirPath\\Setwears').create(recursive: true);
      }
      if (!Directory(backupDirPath).existsSync()) {
        await Directory(backupDirPath).create(recursive: true);
      }
      if (!Directory(checksumDirPath).existsSync()) {
        await Directory(checksumDirPath).create(recursive: true);
      }
      if (!File(deletedItemsPath).existsSync()) {
        await Directory(deletedItemsPath).create(recursive: true);
      }
      if (!File(modSettingsPath).existsSync()) {
        await File(modSettingsPath).create(recursive: true);
      }
      setState(() {
        context.read<stateProvider>().mainBinFoundTrue();
      });

      //Checksum check
      if (Directory(checksumDirPath).listSync().whereType<File>().isNotEmpty && checkSumFilePath == null) {
        checkSumFilePath = Directory(checksumDirPath).listSync().whereType<File>().first.path;
      }
    }
  }

  void getDirPath() {
    const CustomPopups().binDirDialog(context, 'Error', 'pso2_bin folder not found. Select now?', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            style: TextStyle(fontWeight: FontWeight.w500),
                          )),
                    )),
                    //Buttons
                    Row(
                      children: [
                        //Add Mod Button
                        // MaterialButton(
                        //   onPressed: (() {
                        //     const CustomPopups().addModDialog(context);
                        //     //setState(() {});
                        //   }),
                        //   child: Row(
                        //     children: const [Icon(Icons.add), SizedBox(width: 2.5), Text('Add Mod')],
                        //   ),
                        // ),
                        //DarkMode Button

                        //Backup
                        Tooltip(
                          message: 'Reselect \'pso2_bin\' Folder',
                          height: 25,
                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          waitDuration: const Duration(seconds: 1),
                          child: MaterialButton(
                            onPressed: (() {
                              const CustomPopups().binDirDialog(context, 'Info', 'Reselecting pso2_bin folder?', true);
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('_bin Reselect', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),

                        //deleted items
                        Tooltip(
                          message: 'Open Deleted Items Folder',
                          height: 25,
                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          waitDuration: const Duration(seconds: 1),
                          child: MaterialButton(
                            onPressed: (() async {
                             await launchUrl(Uri.parse('file:$deletedItemsPath'));
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('Deleted Items', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),

                        //Checksum
                        Tooltip(
                          message: 'Open Checksum Folder',
                          height: 25,
                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          waitDuration: const Duration(seconds: 1),
                          child: MaterialButton(
                            onPressed: (() async {
                              if (checksumLocation == null) {
                                checksumLocation = await FilePicker.platform.pickFiles(
                                  dialogTitle: 'Select your checksum file',
                                  allowMultiple: false,
                                  // type: FileType.custom,
                                  // allowedExtensions: ['\'\''],
                                  lockParentWindow: true,
                                );
                                if (checksumLocation != null) {
                                  String? checksumPath = checksumLocation!.paths.first;
                                  File(checksumPath!).copySync('$checksumDirPath\\${checksumPath.split('\\').last}');
                                  checkSumFilePath = '$checksumDirPath\\${checksumPath.split('\\').last}';
                                  setState(() {});
                                }
                              } else {
                                await launchUrl(Uri.parse('file:$checksumDirPath'));
                              }
                            }),
                            child: checkSumFilePath != null
                                ? Row(
                                    children: const [
                                      Icon(
                                        Icons.fingerprint,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text('Checksum', style: TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  )
                                : Row(
                                    children: const [
                                      Icon(
                                        Icons.fingerprint,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 5),
                                      Text('Checksum file missing. Click here!', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
                                    ],
                                  ),
                          ),
                        ),

                        //Backup
                        Tooltip(
                          message: 'Open Backup Folder',
                          height: 25,
                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          waitDuration: const Duration(seconds: 1),
                          child: MaterialButton(
                            onPressed: (() async {
                              await launchUrl(Uri.parse('file:$backupDirPath'));
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.backup_table,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('Backup', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),

                        //Mod
                        Tooltip(
                          message: 'Open Mods Folder',
                          height: 25,
                          textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          waitDuration: const Duration(seconds: 1),
                          child: MaterialButton(
                            onPressed: (() async {
                              await launchUrl(Uri.parse('file:$modsDirPath'));
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.rule_folder_outlined,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('Mods', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),

                        //Dark theme
                        if (MyApp.themeNotifier.value == ThemeMode.dark)
                          MaterialButton(
                            onPressed: (() async {
                              final prefs = await SharedPreferences.getInstance();
                              MyApp.themeNotifier.value = ThemeMode.light;
                              prefs.setBool('isDarkModeOn', false);
                              //setState(() {});
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.light_mode_outlined,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('Light', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        if (MyApp.themeNotifier.value == ThemeMode.light)
                          MaterialButton(
                            onPressed: (() async {
                              final prefs = await SharedPreferences.getInstance();
                              MyApp.themeNotifier.value = ThemeMode.dark;
                              prefs.setBool('isDarkModeOn', true);
                              //setState(() {});
                            }),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.dark_mode_outlined,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text('Dark', style: TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                      ],
                    ),
                    const WindowButtons(),
                  ],
                ),
              ),
            ),
            context.watch<stateProvider>().isMainBinFound
                ? const DataLoadingPage()
                : Column(
                    children: const [
                      Text(
                        'Waiting for user action',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CircularProgressIndicator(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

