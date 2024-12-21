// ignore_for_file: use_build_context_synchronously, unused_import

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pso2_mod_manager/app_locale.dart';
import 'package:pso2_mod_manager/global_vars.dart';
import 'package:pso2_mod_manager/system_loads/language_select.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "PSO2NGS Mod Manager", onSecondWindow: (args) {
    debugPrint(args.toString());
  });
  await FlutterLocalization.instance.ensureInitialized();
  await windowManager.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  curAppVersion = packageInfo.version;

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
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: MyApp.themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)),
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
    windowManager.addListener(this);

    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.en),
        const MapLocale('jp', AppLocale.jp),
      ],
      initLanguageCode: 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
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

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.maxFinite, 25),
          child: AppBar(
            title: DragToMoveArea(
                child: Row(
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
                )
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
        body: const LanguageSelect());
  }
}
