// ignore_for_file: unnecessary_new

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import 'package:window_manager/window_manager.dart';

String binDirPath = '';
String mainModManDirPath = '';
String mainModDirPath = '';
String modsDirPath = '';
String backupDirPath = '';
String checksumDirPath = '';
String modSettingsPath = '';
String deletedItemsPath = '';
String? checkSumFilePath;
FilePickerResult? checksumLocation;
bool _previewWindowVisible = true;
double windowsWidth = 1280.0;
double windowsHeight = 720.0;
Future? filesData;
List<ModFile> allModFiles = [];
var dataStreamController = StreamController();

Future<void> main() async {
  DartVLC.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  windowsWidth = (prefs.getDouble('windowsWidth') ?? 1280.0);
  windowsHeight = (prefs.getDouble('windowsHeight') ?? 720.0);

  // WindowOptions windowOptions = const WindowOptions(
  //   size: Size(1280, 720),
  //   center: true,
  //   //backgroundColor: Colors.transparent,
  //   skipTaskbar: true,
  //   //titleBarStyle: TitleBarStyle.hidden
  // );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => stateProvider()),
  ], child: const RestartWidget(child: MyApp())));
  doWhenWindowReady(() {
    Size initialSize = Size(windowsWidth, windowsHeight);
    appWindow.minSize = const Size(1280, 500);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'PSO2NGS Mod Manager';
    appWindow.show();
  });

  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });
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
                //primarySwatch: Colors.blueGrey
                primaryColor: Colors.black),
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

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  final imgStream = StreamController();
  bool isDarkModeOn = false;
  String appVersion = '';

  @override
  void initState() {
    windowManager.addListener(this);
    miscCheck();
    dirPathCheck();
    getAppVer();
    super.initState();
  }

  Future<void> getAppVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  @override
  Future<void> onWindowResized() async {
    Size curWindowSize = await windowManager.getSize();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('windowsWidth', curWindowSize.width);
    prefs.setDouble('windowsHeight', curWindowSize.height);
  }

  void miscCheck() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //Darkmode check
      isDarkModeOn = (prefs.getBool('isDarkModeOn') ?? false);
      if (isDarkModeOn) {
        MyApp.themeNotifier.value = ThemeMode.dark;
      }
      //previewWindows Check
      _previewWindowVisible = (prefs.getBool('previewWindowVisible') ?? true);
      if (_previewWindowVisible) {
        Provider.of<stateProvider>(context, listen: false).previewWindowVisibleSetTrue();
      } else {
        Provider.of<stateProvider>(context, listen: false).previewWindowVisibleSetFalse();
      }
    });
  }

  void dirPathCheck() async {
    final prefs = await SharedPreferences.getInstance();
    //prefs.clear();
    binDirPath = prefs.getString('binDirPath') ?? '';
    mainModManDirPath = prefs.getString('mainModManDirPath') ?? '';

    if (mainModManDirPath.isEmpty) {
      getMainModManDirPath();
    } else {
      //Fill in paths
      mainModDirPath = '$mainModManDirPath\\PSO2 Mod Manager';
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
        context.read<stateProvider>().mainModManPathFoundTrue();
      });

      //Checksum check
      if (checkSumFilePath == null) {
        final filesInCSFolder = Directory(checksumDirPath).listSync().whereType<File>();
        for (var file in filesInCSFolder) {
          if (p.extension(file.path) == '') {
            checkSumFilePath = file.path;
          }
        }
      }
    }
    if (binDirPath.isEmpty) {
      getDirPath();
    } else {
      setState(() {
        context.read<stateProvider>().mainBinFoundTrue();
      });
    }
  }

  void getDirPath() {
    binDirDialog(context, 'Error', 'pso2_bin folder not found. Select it now?\n\'Exit\' will close the app', false);
  }

  void getMainModManDirPath() {
    mainModManDirDialog(context, 'Mod Manager Folder Not Found', 'Select a path to store your mods?\n\'No\' will create a folder inside \'pso2_bin\'', false);
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
                        child: Tooltip(
                            message: 'Version: $appVersion | Build by キス★',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 2),
                            child: Text(
                              'PSO2NGS Mod Manager',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: checkSumFilePath == null ? 13 : 15,
                              ),
                            )),
                      )),
                    ),
                    //Buttons
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        children: [
                          //reload app
                          Tooltip(
                            message: 'Reload Entire App',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              onPressed: Provider.of<stateProvider>(context, listen: false).addingBoxState
                                  ? null
                                  : (() async {
                                      RestartWidget.restartApp(context);
                                    }),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.refresh,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.5),
                                  Text('Reload', style: TextStyle(fontWeight: FontWeight.w400))
                                ],
                              ),
                            ),
                          ),

                          //pso2bin reselect
                          Tooltip(
                            message: 'Reselect \'pso2_bin\' Folder',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              onPressed: (() {
                                binDirDialog(context, 'Info', 'Reselecting pso2_bin folder?', true).then((_) {
                                  //RestartWidget.restartApp(context);
                                  setState(() {
                                    //setstate
                                  });
                                });
                              }),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.folder,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.5),
                                  Text('_bin Reselect', style: TextStyle(fontWeight: FontWeight.w400))
                                ],
                              ),
                            ),
                          ),

                          //MM Dir reselect
                          Tooltip(
                            message: 'Reselect Path to store Mod Manager Folder',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              onPressed: (() {
                                mainModManDirDialog(context, 'Mod Manager Path Reselect', 'Select a new path to store your mods?', false).then((_) {
                                  setState(() {
                                    //setstate
                                  });
                                });
                              }),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.folder_open_outlined,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.5),
                                  Text('Path Reselect', style: TextStyle(fontWeight: FontWeight.w400))
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
                                  SizedBox(width: 2.5),
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
                                if (checkSumFilePath == null) {
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
                                        SizedBox(width: 2.5),
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
                                        SizedBox(width: 2.5),
                                        Text('Checksum missing. Click!', style: TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
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
                              //visualDensity: VisualDensity.compact,
                              onPressed: (() async {
                                await launchUrl(Uri.parse('file:$backupDirPath'));
                              }),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.backup_table,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.5),
                                  Text('Backups', style: TextStyle(fontWeight: FontWeight.w400))
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
                                  SizedBox(width: 2.5),
                                  Text('Mods', style: TextStyle(fontWeight: FontWeight.w400))
                                ],
                              ),
                            ),
                          ),

                          //Preview
                          Tooltip(
                            message: 'Show/Hide Preview Window',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              //visualDensity: VisualDensity.compact,
                              onPressed: (() async {
                                final prefs = await SharedPreferences.getInstance();
                                if (Provider.of<stateProvider>(context, listen: false).previewWindowVisible) {
                                  Provider.of<stateProvider>(context, listen: false).previewWindowVisibleSetFalse();
                                  prefs.setBool('previewWindowVisible', false);
                                  previewPlayer.stop();
                                } else {
                                  Provider.of<stateProvider>(context, listen: false).previewWindowVisibleSetTrue();
                                  prefs.setBool('previewWindowVisible', true);
                                }
                              }),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.preview_outlined,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 2.5),
                                  const Text('Preview: ', style: TextStyle(fontWeight: FontWeight.w400)),
                                  if (context.watch<stateProvider>().previewWindowVisible)
                                    SizedBox(
                                        width: 23,
                                        child: Text('ON',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color))),
                                  if (context.watch<stateProvider>().previewWindowVisible == false)
                                    const SizedBox(width: 23, child: Text('OFF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))
                                ],
                              ),
                            ),
                          ),

                          //Dark theme
                          if (MyApp.themeNotifier.value == ThemeMode.dark)
                            SizedBox(
                              width: 70,
                              child: MaterialButton(
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
                                    SizedBox(width: 2.5),
                                    Text('Light', style: TextStyle(fontWeight: FontWeight.w400))
                                  ],
                                ),
                              ),
                            ),
                          if (MyApp.themeNotifier.value == ThemeMode.light)
                            SizedBox(
                              width: 70,
                              child: MaterialButton(
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
                                    SizedBox(width: 2.5),
                                    Text('Dark', style: TextStyle(fontWeight: FontWeight.w400))
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const WindowButtons(),
                  ],
                ),
              ),
            ),
            context.watch<stateProvider>().isMainBinFound && context.watch<stateProvider>().isMainModManPathFound
                ? const DataLoadingPage()
                : Column(
                    children: const [
                      Text(
                        'Waiting for user\'s action',
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
