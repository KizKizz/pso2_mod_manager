// ignore_for_file: unnecessary_new, unused_import, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/data_loading_page.dart';
import 'package:pso2_mod_manager/file_functions.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pso2_mod_manager/popup_handlers.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
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
String s = '/';
String appVersion = '';
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
    ChangeNotifierProvider(create: (_) => StateProvider()),
  ], child: const MyApp()));
  doWhenWindowReady(() {
    Size initialSize = Size(windowsWidth, windowsHeight);
    appWindow.minSize = const Size(1280, 500);
    //Temp fix for windows 10 white screen, remove when conflicts solved
    if (Platform.isWindows) {
      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        appWindow.size = initialSize + const Offset(0, 1);
      });
    } else {
      appWindow.size = initialSize;
    }
    //appWindow.size = initialSize;
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

  @override
  void initState() {
    if (Platform.isWindows) {
      s = '\\';
    }
    windowManager.addListener(this);
    getAppVer();
    ApplicationConfig().checkForUpdates(context);
    miscCheck();
    dirPathCheck();
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
        Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetTrue();
      } else {
        Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetFalse();
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
      mainModDirPath = '$mainModManDirPath${s}PSO2 Mod Manager';
      modsDirPath = '$mainModDirPath${s}Mods';
      backupDirPath = '$mainModDirPath${s}Backups';
      checksumDirPath = '$mainModDirPath${s}Checksum';
      modSettingsPath = '$mainModDirPath${s}PSO2ModManSettings.json';
      deletedItemsPath = '$mainModDirPath${s}Deleted Items';
      //Check if exist, create dirs
      if (!Directory(mainModDirPath).existsSync()) {
        await Directory(mainModDirPath).create(recursive: true);
      }
      if (!Directory(modsDirPath).existsSync()) {
        await Directory(modsDirPath).create(recursive: true);
        await Directory('$modsDirPath${s}Accessories').create(recursive: true);
        await Directory('$modsDirPath${s}Basewears').create(recursive: true);
        await Directory('$modsDirPath${s}Body Paints').create(recursive: true);
        await Directory('$modsDirPath${s}Emotes').create(recursive: true);
        await Directory('$modsDirPath${s}Face Paints').create(recursive: true);
        await Directory('$modsDirPath${s}Innerwears').create(recursive: true);
        await Directory('$modsDirPath${s}Misc').create(recursive: true);
        await Directory('$modsDirPath${s}Motions').create(recursive: true);
        await Directory('$modsDirPath${s}Outerwears').create(recursive: true);
        await Directory('$modsDirPath${s}Setwears').create(recursive: true);
      }
      if (!Directory(backupDirPath).existsSync()) {
        await Directory(backupDirPath).create(recursive: true);
      }
      if (!Directory('$backupDirPath${s}win32_na').existsSync()) {
        await Directory('$backupDirPath${s}win32_na').create(recursive: true);
      }
      if (!Directory('$backupDirPath${s}win32reboot_na').existsSync()) {
        await Directory('$backupDirPath${s}win32reboot_na').create(recursive: true);
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
        context.read<StateProvider>().mainModManPathFoundTrue();
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
        context.read<StateProvider>().mainBinFoundTrue();
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
                            message: 'Version: $appVersion | Made by キス★',
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
                          // //pso2bin reselect
                          // Tooltip(
                          //   message: 'Reselect \'pso2_bin\' Folder',
                          //   height: 25,
                          //   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          //   waitDuration: const Duration(seconds: 1),
                          //   child: MaterialButton(
                          //     onPressed: (() {
                          //       binDirDialog(context, 'pso2_bin Path Reselect', 'Current path:\n\'$binDirPath\'\n\nChoose a new path?', true).then((_) {
                          //         setState(() {
                          //           //setstate
                          //         });
                          //       });
                          //     }),
                          //     child: Row(
                          //       children: const [
                          //         Icon(
                          //           Icons.folder,
                          //           size: 18,
                          //         ),
                          //         SizedBox(width: 2.5),
                          //         Text('_bin Reselect', style: TextStyle(fontWeight: FontWeight.w400))
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // //MM Dir reselect
                          // Tooltip(
                          //   message: 'Reselect Path to store Mod Manager Folder',
                          //   height: 25,
                          //   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          //   waitDuration: const Duration(seconds: 1),
                          //   child: MaterialButton(
                          //     onPressed: (() {
                          //       mainModManDirDialog(context, 'Mod Manager Path Reselect', 'Current path:\n\'$mainModDirPath\'\n\nChoose a new path?', true);
                          //     }),
                          //     child: Row(
                          //       children: const [
                          //         Icon(
                          //           Icons.folder_open_outlined,
                          //           size: 18,
                          //         ),
                          //         SizedBox(width: 2.5),
                          //         Text('Path Reselect', style: TextStyle(fontWeight: FontWeight.w400))
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          //Path menu

                          Tooltip(
                            message: 'Reselect \'pso2_bin\' Folder and Mod Manager Folder Path',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  customButton: AbsorbPointer(
                                    absorbing: true,
                                    child: MaterialButton(
                                      onPressed: (() {}),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.folder_open_outlined,
                                            size: 18,
                                          ),
                                          SizedBox(width: 2.5),
                                          Text('Paths Reselect', style: TextStyle(fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  isDense: true,
                                  // focusColor: Theme.of(context).highlightColor,
                                  // iconSize: 20,
                                  // iconEnabledColor: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
                                  // icon: const Icon(Icons.arrow_drop_down),
                                  // iconOnClick: const Icon(Icons.arrow_drop_up),
                                  // hint: Text('Paths Reselect',
                                  //     style: TextStyle(
                                  //         color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
                                  //         fontSize: 14,
                                  //         fontWeight: FontWeight.w400)),
                                  items: [
                                    ...MenuItems.firstItems.map(
                                      (item) => DropdownMenuItem<MenuItem>(
                                        value: item,
                                        child: MenuItems.buildItem(context, item),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    MenuItems.onChanged(context, value as MenuItem);
                                  },
                                  itemHeight: 35,
                                  dropdownWidth: 130,
                                  itemPadding: const EdgeInsets.only(left: 5, right: 5),
                                  dropdownPadding: const EdgeInsets.symmetric(vertical: 5),
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                  ),
                                  dropdownElevation: 8,
                                  offset: const Offset(0, -3),
                                ),
                              ),
                            ),
                          ),

                          //Mod sets
                          Tooltip(
                            message: 'Manage Mod Sets',
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              onPressed: (() {
                                // binDirDialog(context, 'pso2_bin Path Reselect', 'Current path:\n\'$binDirPath\'\n\nChoose a new path?', true).then((_) {
                                //   setState(() {
                                //     //setstate
                                //   });
                                // });
                              }),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.album,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.5),
                                  Text('Mod Sets', style: TextStyle(fontWeight: FontWeight.w400))
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
                                    File(checksumPath!).copySync('$checksumDirPath$s${checksumPath.split(s).last}');
                                    checkSumFilePath = '$checksumDirPath$s${checksumPath.split(s).last}';
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
                                if (Provider.of<StateProvider>(context, listen: false).previewWindowVisible) {
                                  Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetFalse();
                                  prefs.setBool('previewWindowVisible', false);
                                  previewPlayer.stop();
                                } else {
                                  Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetTrue();
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
                                  if (context.watch<StateProvider>().previewWindowVisible)
                                    SizedBox(
                                        width: 23,
                                        child: Text('ON',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color))),
                                  if (context.watch<StateProvider>().previewWindowVisible == false)
                                    const SizedBox(width: 23, child: FittedBox(fit: BoxFit.contain, child: Text('OFF', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))))
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

            //New version banner
            if (context.watch<StateProvider>().isUpdateAvailable)
              ScaffoldMessenger(
                  child: MaterialBanner(
                backgroundColor: Theme.of(context).canvasColor,
                elevation: 0,
                padding: const EdgeInsets.all(0),
                leadingPadding: const EdgeInsets.only(left: 15, right: 5),
                leading: Icon(
                  Icons.new_releases,
                  color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent,
                ),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'New Update Available!',
                          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('New Version: $newVersion - Your Version: $appVersion'),
                        ),
                        TextButton(
                            onPressed: (() {
                              setState(() {
                                patchNotesDialog(context);
                              });
                            }),
                            child: const Text('Patch Notes...')),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: ElevatedButton(
                              onPressed: (() {
                                Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                setState(() {});
                              }),
                              child: const Text('Dismiss')),
                        ),
                        ElevatedButton(
                            onPressed: (() {
                              Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                              launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                            }),
                            child: const Text('Update')),
                      ],
                    )
                  ],
                ),
                actions: const [SizedBox()],
              )),
            context.watch<StateProvider>().isMainBinFound && context.watch<StateProvider>().isMainModManPathFound
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

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> firstItems = [_binFolder, modManFolder];

  static const _binFolder = MenuItem(text: 'pso2_bin', icon: Icons.folder);
  static const modManFolder = MenuItem(text: 'Mod Manager', icon: Icons.folder_open_outlined);

  static Widget buildItem(context, MenuItem item) {
    return Row(
      children: [
        Icon(
          item.icon,
          color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
          size: 20,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          item.text,
          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color, fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems._binFolder:
        binDirDialog(context, 'pso2_bin Path Reselect', 'Current path:\n\'$binDirPath\'\n\nChoose a new path?', true);
        break;
      case MenuItems.modManFolder:
        mainModManDirDialog(context, 'Mod Manager Path Reselect', 'Current path:\n\'$mainModDirPath\'\n\nChoose a new path?', true);
        break;
    }
  }
}
