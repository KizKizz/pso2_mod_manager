// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pso2_mod_manager/app_colorscheme.dart';
import 'package:pso2_mod_manager/app_localization/app_locale.dart';
import 'package:pso2_mod_manager/app_localization/app_text.dart';
import 'package:pso2_mod_manager/app_pages_index.dart';
import 'package:pso2_mod_manager/app_paths/main_paths.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_functions.dart';
import 'package:pso2_mod_manager/settings/other_settings.dart';
import 'package:pso2_mod_manager/shared_prefs.dart';
import 'package:pso2_mod_manager/system_loads/app_locale_page.dart';
import 'package:pso2_mod_manager/v3_widgets/background_slideshow.dart';
import 'package:pso2_mod_manager/mod_checksum/checksum_indicator.dart';
import 'package:pso2_mod_manager/v3_widgets/info_box.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "PSO2NGS Mod Manager", onSecondWindow: (args) {
    debugPrint(args.toString());
  });
  await windowManager.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  curAppVersion = packageInfo.version;

  await prefsLoad();
  await AppLocale().localeInit();
  checksumAvailability.value = await checksumFileFetch();

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
            debugShowCheckedModeBanner: false,
            theme: lightModeSeedColor == lightColorScheme.primary ? ThemeData.from(colorScheme: lightColorScheme) : ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: lightModeSeedColor)),
            darkTheme: darkModeSeedColor == darkColorScheme.primary
                ? ThemeData.from(colorScheme: darkColorScheme)
                : ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: darkModeSeedColor, brightness: Brightness.dark)),
            themeMode: currentMode,
            home: const MyHomePage(
              title: 'PSO2NGS Mod Manager',
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.maxFinite, 25),
          child: AppBar(
            title: DragToMoveArea(
                child: Row(
                  crossAxisAlignment:CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.headlineSmall!.color),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'v$curAppVersion',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic, color: Theme.of(context).textTheme.headlineSmall!.color),
                      ),
                    ),
                  ],
                ),
                const ChecksumIndicator()
              ],
            )),
            titleSpacing: 5,
            actions: [
              SizedBox(
                width: 35,
                height: double.maxFinite,
                child: InkWell(
                  onTap: () => windowManager.minimize(),
                  child: const Icon(
                    Icons.minimize,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(
                width: 35,
                height: double.maxFinite,
                child: InkWell(
                  onTap: () async => await windowManager.isMaximized() ? windowManager.restore() : windowManager.maximize(),
                  child: const Icon(
                    Icons.crop_square,
                    size: 16,
                  ),
                ),
              ),
              SizedBox(
                width: 45,
                height: double.maxFinite,
                child: InkWell(
                  hoverColor: Colors.red,
                  onTap: () => windowManager.close(),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
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
