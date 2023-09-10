// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/filesDownloader/ice_files_download.dart';
import 'package:pso2_mod_manager/functions/clear_temp_dirs.dart';
import 'package:pso2_mod_manager/functions/color_picker.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/modsSwapper/mods_swapper_popup.dart';
import 'package:pso2_mod_manager/pages/ui_language_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

//Colors
Color lightModePrimaryColor = const Color(0xffffffff);
Color lightModePrimaryColorLight = const Color(0xff3181ff);
Color lightModePrimaryColorDark = const Color(0xff000000);
Color lightModeCanvasColor = const Color(0xffffffff);
Color lightModeUIBackgroundColor = const Color(0xffffffff);
MaterialColor lightModePrimarySwatch = Colors.blue;

Color darkModePrimaryColor = const Color(0xff000000);
Color darkModePrimaryColorLight = const Color(0xff3181ff);
Color darkModePrimaryColorDark = const Color(0xff000000);
Color darkModeCanvasColor = const Color(0xff2e2d2d);
Color darkModeUIBackgroundColor = const Color(0xff2e2d2d);
MaterialColor darkModePrimarySwatch = Colors.blue;

//Background image
File backgroundImage = File('');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  windowsWidth = (prefs.getDouble('windowsWidth') ?? 1280.0);
  windowsHeight = (prefs.getDouble('windowsHeight') ?? 720.0);
  //Colors from prefs
  lightModePrimaryColor = Color(prefs.getInt('lightModePrimaryColor') ?? 0xffffffff);
  lightModePrimaryColorLight = Color(prefs.getInt('lightModePrimaryColorLight') ?? 0xff3181ff);
  lightModePrimaryColorDark = Color(prefs.getInt('lightModePrimaryColorDark') ?? 0xff000000);
  lightModeCanvasColor = Color(prefs.getInt('lightModeCanvasColor') ?? 0xffffffff);
  lightModeUIBackgroundColor = Color(prefs.getInt('lightModeUIBackgroundColor') ?? 0xffffffff);

  Color savedLightModePrimarySwatch = Color(prefs.getInt('lightModePrimarySwatch') ?? Colors.blue.value);
  CustomMaterialColor savedLightMaterialColor = CustomMaterialColor(savedLightModePrimarySwatch.red, savedLightModePrimarySwatch.green, savedLightModePrimarySwatch.blue);
  lightModePrimarySwatch = savedLightMaterialColor.materialColor;

  darkModePrimaryColor = Color(prefs.getInt('darkModePrimaryColor') ?? 0xff000000);
  darkModePrimaryColorLight = Color(prefs.getInt('darkModePrimaryColorLight') ?? 0xff706f6f);
  darkModePrimaryColorDark = Color(prefs.getInt('darkModePrimaryColorDark') ?? 0xff000000);
  darkModeCanvasColor = Color(prefs.getInt('darkModeCanvasColor') ?? 0xff2e2d2d);
  darkModeUIBackgroundColor = Color(prefs.getInt('darkModeUIBackgroundColor') ?? 0xff2e2d2d);

  Color savedDarkModePrimarySwatch = Color(prefs.getInt('darkModePrimarySwatch') ?? Colors.blue.value);
  CustomMaterialColor savedDarkMaterialColor = CustomMaterialColor(savedDarkModePrimarySwatch.red, savedDarkModePrimarySwatch.green, savedDarkModePrimarySwatch.blue);
  darkModePrimarySwatch = savedDarkMaterialColor.materialColor;

  //Background image path from prefs
  backgroundImage = File(prefs.getString('backgroundImagePath') ?? '');

  //video init
  WidgetsFlutterBinding.ensureInitialized();

  /// [MediaKit.ensureInitialized] must be called before using the library.
  MediaKit.ensureInitialized();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => StateProvider()),
  ], child: const MyApp()));
  doWhenWindowReady(() {
    Size initialSize = Size(windowsWidth, windowsHeight);
    appWindow.minSize = const Size(1280, 500);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'PSO2NGS Mod Manager';
    appWindow.show();

    if (Platform.isWindows) {
      WidgetsBinding.instance.scheduleFrameCallback((timeStamp) {
        appWindow.size = initialSize + const Offset(0, 1);
      });
    } else {
      appWindow.size = initialSize;
    }
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
            // theme: ThemeData(primarySwatch: Colors.green, colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow)),
            // //primaryColor: Colors.black),
            // darkTheme: ThemeData.dark(),
            //themeMode: ThemeMode.light, // Change it as you want
            theme: ThemeData(
                primaryColor: lightModePrimaryColor,
                primaryColorLight: lightModePrimaryColorLight,
                primaryColorDark: lightModePrimaryColorDark,
                brightness: Brightness.light,
                canvasColor: lightModeCanvasColor,
                //indicatorColor: Colors.white,
                primarySwatch: lightModePrimarySwatch,
                // next line is important!
                appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark)),
            darkTheme: ThemeData(
                primaryColor: darkModePrimaryColor,
                primaryColorLight: darkModePrimaryColorLight,
                primaryColorDark: darkModePrimaryColorDark,
                brightness: Brightness.dark,
                canvasColor: darkModeCanvasColor,
                //indicatorColor: Colors.white,
                primarySwatch: darkModePrimarySwatch,
                // next line is important!
                appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light)),

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
    windowManager.addListener(this);
    miscCheck();
    getAppVer();

    getRefSheetsVersion();
    ApplicationConfig().checkForUpdates(context);

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
      //first Time Language Set
      firstTimeLanguageSet = (prefs.getBool('firstTimeLanguageSet') ?? false);
      //mods adder group same item variants
      modsAdderGroupSameItemVariants = prefs.getBool('modsAdderGroupSameItemVariants') ?? false;
      //profile names
      modManProfile1Name = (prefs.getString('modManProfile1Name') ?? 'Profile 1');
      modManProfile2Name = (prefs.getString('modManProfile2Name') ?? 'Profile 2');
      modManCurActiveProfile = (prefs.getInt('modManCurActiveProfile') ?? 1);
      if (modManCurActiveProfile == 1) {
        Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile1Name);
      } else {
        Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile2Name);
      }
      //mods swapper check
      // isEmotesToStandbyMotions = (prefs.getBool('isEmotesToStandbyMotions') ?? false);
      isReplacingNQWithHQ = (prefs.getBool('modsSwapperIsReplacingNQWithHQ') ?? false);
      isCopyAll = (prefs.getBool('modsSwapperIsCopyAll') ?? false);
      isRemoveExtras = (prefs.getBool('modsSwapperIsRemoveExtras') ?? false);

      //Background Image check
      showBackgroundImage = (prefs.getBool('showBgImage') ?? true);
      if (backgroundImage.path.isNotEmpty) {
        if (backgroundImage.existsSync()) {
          Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerTrue();
        } else {
          Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerFalse();
        }
      }

      //Empty categories hide
      isEmptyCatesHide = (prefs.getBool('isShowHideEmptyCategories') ?? false);

      //auto fetching icon
      isAutoFetchingIconsOnStartup = (prefs.getString('isAutoFetchingIconsOnStartup') ?? 'minimal');

      //Sliding item icons
      bool isSlidingItemIcons = (prefs.getBool('isSlidingItemIcons') ?? true);
      if (isSlidingItemIcons) {
        Provider.of<StateProvider>(context, listen: false).isSlidingItemIconsTrue();
      } else {
        Provider.of<StateProvider>(context, listen: false).isSlidingItemIconsFalse();
      }

      //UI opacity
      Provider.of<StateProvider>(context, listen: false).uiOpacityValueSet((prefs.getDouble('uiOpacityValue') ?? 0.6));

      //Darkmode check
      isDarkModeOn = (prefs.getBool('isDarkModeOn') ?? false);
      if (isDarkModeOn) {
        MyApp.themeNotifier.value = ThemeMode.dark;
      }
      //Set uibackground color value
      if (MyApp.themeNotifier.value == ThemeMode.light) {
        Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(lightModeUIBackgroundColor.value);
      } else {
        Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(darkModeUIBackgroundColor.value);
      }

      //previewWindows Check
      previewWindowVisible = (prefs.getBool('previewWindowVisible') ?? true);
      if (previewWindowVisible) {
        Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetTrue();
      } else {
        Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetFalse();
      }

      // First time user load
      firstTimeUser = (prefs.getBool('isFirstTimeLoadV2') ?? true);

      // Check version to skip update
      versionToSkipUpdate = (prefs.getString('versionToSkipUpdate') ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: UILanguageLoadingPage(),
    );
  }
}
