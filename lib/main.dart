// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pso2_mod_manager/app_colorscheme.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_title_bar.dart';
import 'package:pso2_mod_manager/material_app_service.dart';
import 'package:pso2_mod_manager/v3_functions/pso2_version_check.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/v3_home/settings.dart';
import 'package:pso2_mod_manager/v3_widgets/background_slideshow.dart';
import 'package:pso2_mod_manager/v3_widgets/inactive_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "PSO2NGS Mod Manager", onSecondWindow: (args) {
    debugPrint(args.toString());
  });
  await windowManager.ensureInitialized();
  MediaKit.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  curAppVersion = packageInfo.version;

  await prefsLoad();
  await AppLocale().localeInit();
  pso2RegionVersion.value = await pso2RegionCheck();

  WindowOptions windowOptions = WindowOptions(
      size: Size(prefs.getDouble('windowWidth') ?? 1280, prefs.getDouble('windowHeight') ?? 720),
      center: false,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false);
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (prefs.getDouble('windowXPosition') != null && prefs.getDouble('windowYPosition') != null) {
      await windowManager.setPosition(Offset(prefs.getDouble('windowXPosition') ?? 0, prefs.getDouble('windowYPosition') ?? 0));
    } else {
      windowManager.center();
    }
    await windowManager.show();
    await windowManager.focus();
    if (windowMaximizedState.value) windowManager.maximize();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(appThemeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            navigatorKey: MaterialAppService.navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: lightModeSeedColor == lightColorScheme.primary ? ThemeData.from(colorScheme: lightColorScheme) : ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: lightModeSeedColor)),
            darkTheme: darkModeSeedColor == darkColorScheme.primary
                ? ThemeData.from(colorScheme: darkColorScheme)
                : ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: darkModeSeedColor, brightness: Brightness.dark)),
            themeMode: currentMode,
            home: const MyHomePage(),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  @override
  void initState() {
    backgroundImageFiles.value = backgroundImageFetch();
    windowManager.addListener(this);
    super.initState();
  }

  @override
  Future<void> onWindowResize() async {
    Size curWindowSize = await windowManager.getSize();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('windowWidth', curWindowSize.width);
    prefs.setDouble('windowHeight', curWindowSize.height);
  }

  @override
  Future<void> onWindowMove() async {
    Offset curWindowPosition = await windowManager.getPosition();
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('windowXPosition', curWindowPosition.dx);
    prefs.setDouble('windowYPosition', curWindowPosition.dy);
  }

  @override
  Future<void> onWindowBlur() async {
    if (appLoadingFinished.watch(context) && hideUIWhenAppUnfocused) {
      await Future.delayed(Duration(seconds: hideUIInitDelaySeconds));
      if (!await windowManager.isFocused()) {
        showMessageOnInactiveOverlay.value = false;
        await inactiveOverlay(context);
      }
    }
  }

  @override
  Future<void> onWindowFocus() async {
    if (appLoadingFinished.watch(context) && hideUIWhenAppUnfocused) {
      if (await windowManager.isFocused()) {
        showMessageOnInactiveOverlay.value = true;
      } else {
        showMessageOnInactiveOverlay.value = false;
      }
    }
  }

  @override
  Future<void> onWindowMaximize() async {
    final prefs = await SharedPreferences.getInstance();
    windowMaximizedState.value = true;
    prefs.setBool('windowMaximizedState', windowMaximizedState.value);
  }

  @override
  Future<void> onWindowUnmaximize() async {
    final prefs = await SharedPreferences.getInstance();
    windowMaximizedState.value = false;
    prefs.setBool('windowMaximizedState', windowMaximizedState.value);
  }

  @override
  Widget build(BuildContext context) {
    // Refresh
    if (settingChangeStatus.watch(context) != settingChangeStatus.peek()) {
      setState(
        () {},
      );
    }

    return Scaffold(
        appBar: const PreferredSize(preferredSize: Size(double.maxFinite, 25), child: AppTitleBar()),
        body: Stack(
          children: [
            Visibility(
                visible: backgroundImageFiles.watch(context).isNotEmpty && !hideAppBackgroundSlides.watch(context),
                child: const BackgroundSlideshow(
                  isMini: false,
                )),
            curPage.watch(context)
          ],
        ));
  }
}
