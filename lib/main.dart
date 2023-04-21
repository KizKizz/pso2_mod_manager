// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/functions/language_loader.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/lang_loading_page.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
import 'package:pso2_mod_manager/pages/ui_language_loading_page.dart';
import 'package:pso2_mod_manager/paths_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_text.dart';
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
String modSetsSettingsPath = '';
String deletedItemsPath = '';
String curSelectedLangPath = '';
//String languageDirPath = '${Directory.current.path}${s}Language$s';
String langSettingsPath = '';
String curLanguageDirPath = '';

String curActiveLang = '';
List<String> langDropDownList = [];
String langDropDownSelected = '';
List<String> topBtnMenuItems = [];
String s = '/';
String appVersion = '';
int refSheetsVersion = -1;
String? checkSumFilePath;
FilePickerResult? checksumLocation;
bool _previewWindowVisible = true;
double windowsWidth = 1280.0;
double windowsHeight = 720.0;
//Future? filesData;
Directory dataDir = Directory('');
List<File> iceFiles = [];
List<ModFile> allModFiles = [];
var dataStreamController = StreamController();
TextEditingController newSetTextController = TextEditingController();
TextEditingController newLangTextController = TextEditingController();
final newSetFormKey = GlobalKey<FormState>();
List<String> localRefSheetsList = [];
bool _checksumDownloading = false;
String tempDirPath = '${Directory.current.path}${s}temp';
String zamboniExePath = '${Directory.current.path}${s}Zamboni${s}Zamboni.exe';
bool _firstTimeUser = false;
String versionToSkipUpdate = '';
String? localChecksumMD5;
String? win32ChecksumMD5;
String win32CheckSumFilePath = '';
Uri modsListJsonPath = Uri();

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
    // if (Platform.isWindows) {
    //   WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
    //     appWindow.size = initialSize + const Offset(0, 5);
    //   });
    // } else {
    //   appWindow.size = initialSize;
    // }
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

  @override
  void initState() {
    if (Platform.isWindows) {
      s = '\\';
    }
    windowManager.addListener(this);
    miscCheck();
    getSortType();
    getAppVer();
    getRefSheetsVersion();
    ApplicationConfig().checkForUpdates(context);
    ApplicationConfig().checkRefSheetsForUpdates(context);
    ApplicationConfig().checkChecksumFileForUpdates(context);
    //languagePackCheck();

    super.initState();
  }

  Future<void> getAppVer() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }

  Future<void> getRefSheetsVersion() async {
    final prefs = await SharedPreferences.getInstance();
    refSheetsVersion = (prefs.getInt('refSheetsVersion') ?? 0);
  }

  Future<void> getSortType() async {
    final prefs = await SharedPreferences.getInstance();
    // 0 => sort by name, 1 => sort by item amount
    selectedSortType = (prefs.getInt('selectedSortType') ?? 0);
  }

  @override
  Future<void> onWindowResized() async {
    Size curWindowSize = await windowManager.getSize();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('windowsWidth', curWindowSize.width);
    prefs.setDouble('windowsHeight', curWindowSize.height);
  }

  Future<void> miscCheck() async {
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

      // First time user load
      _firstTimeUser = (prefs.getBool('isFirstTimeLoad') ?? true);

      // Check version to skip update
      versionToSkipUpdate = (prefs.getString('versionToSkipUpdate') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const UILanguageLoadingPage();
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
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
  static const List<MenuItem> pathMenuItems = [_binFolder, modManFolder];
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

  static onChanged(BuildContext context, MenuItem item) async {
    switch (item) {
      case MenuItems._binFolder:
        binDirDialog(context, curLangText!.pso2binReselectPopupText, '${curLangText!.curPathText}\n\'$binDirPath\'\n\n${curLangText!.chooseNewPathText}', true);
        break;
      case MenuItems.modManFolder:
        mainModManDirDialog(context, curLangText!.modmanReselectPopupText, '${curLangText!.curPathText}\n\'$mainModDirPath\'\n\n${curLangText!.chooseNewPathText}', true);
        break;
    }
  }
}
