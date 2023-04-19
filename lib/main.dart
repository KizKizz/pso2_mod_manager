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
import 'package:pso2_mod_manager/functions/test.dart';
import 'package:pso2_mod_manager/home_page.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/lang_loading_page.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/mod_classes.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/mods_loader.dart';
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
TranslationText? curLangText;
String langSettingsPath = '';
String curLanguageDirPath = '';
List<TranslationLanguage> langList = [];
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
    languagePackCheck();

    test();

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

  Future<void> languagePackCheck() async {
    curLanguageDirPath = '${Directory.current.path}${s}Language';
    langSettingsPath = '${Directory.current.path}${s}Language${s}LanguageSettings.json';

    if (!File(langSettingsPath).existsSync()) {
      await File(langSettingsPath).create(recursive: true);
      TranslationLanguage newENLang = TranslationLanguage('EN', '$curLanguageDirPath${s}EN.json', true);
      await File('$curLanguageDirPath${s}EN.json').create(recursive: true);
      TranslationText newEN = defaultUILangLoader();
      //Json Write
      [newEN].map((translationText) => translationText.toJson()).toList();
      File('$curLanguageDirPath${s}EN.json').writeAsStringSync(json.encode([newEN]));
      langList.add(newENLang);
      langDropDownList.add(newLangTextController.text.toUpperCase());
      //Json Write
      langList.map((translation) => translation.toJson()).toList();
      File(langSettingsPath).writeAsStringSync(json.encode(langList));
      langList = await translationLoader();
      for (var lang in langList) {
        langDropDownList.add(lang.langInitial);
        if (lang.langFilePath != '$curLanguageDirPath$s${lang.langInitial}.json') {
          lang.langFilePath = '$curLanguageDirPath$s${lang.langInitial}.json';
          //Json Write
          langList.map((translation) => translation.toJson()).toList();
          File(langSettingsPath).writeAsStringSync(json.encode(langList));
        }
        if (lang.selected) {
          langDropDownSelected = lang.langInitial;
          curSelectedLangPath = '$curLanguageDirPath$s${lang.langInitial}.json';
        }
      }
    } else {
      List<TranslationLanguage> tempLangList = await translationLoader();
      for (var lang in tempLangList) {
        if (!File(lang.langFilePath).existsSync()) {
          if (lang.selected) {
            if (lang.langInitial != 'EN') {
              tempLangList.singleWhere((element) => element.langInitial == 'EN').selected = true;
            } else {
              await File('$curLanguageDirPath${s}EN.json').create(recursive: true);
              TranslationText newEN = defaultUILangLoader();
              //Json Write
              [newEN].map((translationText) => translationText.toJson()).toList();
              File('$curLanguageDirPath${s}EN.json').writeAsStringSync(json.encode([newEN]));
            }
          }
        } else {
          if (lang.langInitial == 'EN') {
            TranslationText newEN = defaultUILangLoader();
            //Json Write
            [newEN].map((translationText) => translationText.toJson()).toList();
            File(lang.langFilePath).writeAsStringSync(json.encode([newEN]));
          } else {
            String curLangString = File('$curLanguageDirPath${s}EN.json').readAsStringSync();
            curLangString = curLangString.replaceRange(0, 2, '');
            curLangString = curLangString.replaceRange(curLangString.length - 2, null, '');
            List<String> newTranslationItems = curLangString.split('",');
            String tempTranslationFromFile = File(lang.langFilePath).readAsStringSync();
            tempTranslationFromFile = tempTranslationFromFile.replaceRange(0, 2, '');
            tempTranslationFromFile = tempTranslationFromFile.replaceRange(tempTranslationFromFile.length - 2, null, '');
            List<String> curTranslationItems = tempTranslationFromFile.split('",');
            curTranslationItems.last = curTranslationItems.last.replaceRange(curTranslationItems.last.length - 1, null, '');
            String curLastItem = curTranslationItems.last;

            if (newTranslationItems.length != curTranslationItems.length) {
              for (var item in newTranslationItems) {
                if (curTranslationItems.indexWhere((element) => element.substring(0, element.indexOf(':')) == item.substring(0, item.indexOf(':'))) == -1) {
                  curTranslationItems.insert(newTranslationItems.indexOf(item), item);
                }
              }
              String finalTranslation = curTranslationItems.join('",');
              finalTranslation = finalTranslation.padLeft(finalTranslation.length + 1, '[{');
              if (curLastItem == curTranslationItems.last) {
                finalTranslation = finalTranslation.padRight(finalTranslation.length + 1, '"}]');
              } else {
                finalTranslation = finalTranslation.padRight(finalTranslation.length + 1, '}]');
              }
              File(lang.langFilePath).writeAsStringSync(finalTranslation);
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WindowTitleBarBox(
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Row(
                children: [
                  Expanded(
                    child: MoveWindow(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 7),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                              message: 'Version: $appVersion | Made by キス★',
                              height: 25,
                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                              waitDuration: const Duration(seconds: 2),
                              child: const Text(
                                'PSO2NGS Mod Manager',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                              )),
                          if (versionToSkipUpdate == appVersion && curLangText != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Tooltip(
                                message: curLangText!.titleNewUpdateToolTip,
                                height: 25,
                                textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                                waitDuration: const Duration(milliseconds: 100),
                                child: MaterialButton(
                                    visualDensity: VisualDensity.compact,
                                    height: 20,
                                    minWidth: 10,
                                    onPressed: () {
                                      launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                                    },
                                    child: Icon(
                                      Icons.download,
                                      size: 25,
                                      color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.red : Colors.amber,
                                    )),
                              ),
                            ),
                        ],
                      ),
                    )),
                  ),

                  //Buttons
                  if (curLangText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: [
                          //Add Items/Mods
                          Tooltip(
                            message: curLangText!.addModsTooltip,
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: SizedBox(
                              width: curActiveLang == 'JP' ? 110 : 105,
                              child: MaterialButton(
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.tealAccent : Colors.blue,
                                onPressed: (() {
                                  Directory(tempDirPath).listSync(recursive: false).forEach((element) {
                                    element.deleteSync(recursive: true);
                                  });
                                  Directory('${Directory.current.path}${s}unpack').listSync(recursive: false).forEach((element) {
                                    element.deleteSync(recursive: true);
                                  });
                                  modAddHandler(context);
                                }),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(curLangText!.addModsBtnLabel, style: const TextStyle(fontWeight: FontWeight.w400))
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Mod sets
                          Tooltip(
                            message: curLangText!.modSetsTooltipText,
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: SizedBox(
                              width: 99,
                              child: MaterialButton(
                                onPressed: (() {
                                  if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) {
                                    modFilesFromSetList.clear();
                                    modFilesList.clear();
                                    modsSetAppBarName = '';
                                    modsViewAppBarName = '';
                                    Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetFalse();
                                  } else {
                                    modFilesFromSetList.clear();
                                    modFilesList.clear();
                                    modsSetAppBarName = '';
                                    modsViewAppBarName = '';
                                    Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
                                  }
                                }),
                                child: Row(
                                  children: [
                                    if (!Provider.of<StateProvider>(context, listen: false).setsWindowVisible)
                                      const Icon(
                                        Icons.list_alt_outlined,
                                        size: 18,
                                      ),
                                    if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible)
                                      const Icon(
                                        Icons.view_list_outlined,
                                        size: 18,
                                      ),
                                    const SizedBox(width: 2.5),
                                    if (!Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.modSetsBtnText, style: const TextStyle(fontWeight: FontWeight.w400)),
                                    if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.modListBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Checksum
                          Tooltip(
                            message: checkSumFilePath != null && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                ? curLangText!.checksumToolTipText
                                : curLangText!.checksumHoldBtnTooltip,
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: MaterialButton(
                              onLongPress: () async {
                                if (checkSumFilePath == null || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                  checksumLocation = await FilePicker.platform.pickFiles(
                                    dialogTitle: curLangText!.checksumSelectPopupText,
                                    allowMultiple: false,
                                    // type: FileType.custom,
                                    // allowedExtensions: ['\'\''],
                                    lockParentWindow: true,
                                  );
                                  if (checksumLocation != null) {
                                    String? checksumPath = checksumLocation!.paths.first;
                                    File(checksumPath!).copySync('$checksumDirPath$s${checksumPath.split(s).last}');
                                    checkSumFilePath = '$checksumDirPath$s${checksumPath.split(s).last}';
                                    File(checkSumFilePath.toString()).copySync('$binDirPath${s}data${s}win32$s${XFile(checkSumFilePath!).name}');
                                    Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
                                    setState(() {});
                                  }
                                } else {
                                  await launchUrl(Uri.parse('file:$checksumDirPath'));
                                }
                              },
                              onPressed: (() async {
                                if (checkSumFilePath == null || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                  _checksumDownloading = true;
                                  setState(() {});
                                  await Dio().download(netChecksumFileLink, '$checksumDirPath$s$netChecksumFileName').then((value) {
                                    _checksumDownloading = false;
                                    checkSumFilePath = '$checksumDirPath$s$netChecksumFileName';
                                    File(checkSumFilePath.toString()).copySync('$binDirPath${s}data${s}win32$s${XFile(checkSumFilePath!).name}');
                                    Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
                                    setState(() {});
                                  });
                                } else {
                                  await launchUrl(Uri.parse('file:$checksumDirPath'));
                                }
                              }),
                              child: checkSumFilePath != null && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.fingerprint,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 2.5),
                                        Text('${curLangText!.checksumBtnText} ', style: const TextStyle(fontWeight: FontWeight.w400)),
                                        Text('OK',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color)),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        const Icon(
                                          Icons.fingerprint,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 2.5),
                                        if (!_checksumDownloading && checkSumFilePath == null)
                                          Text(curLangText!.checksumMissingBtnText, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red)),
                                        if (!_checksumDownloading && !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match)
                                          Text(curLangText!.checksumOutdatedErrorText, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red)),
                                        if (_checksumDownloading) Text(curLangText!.checksumDownloadingBtnLabel, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
                                      ],
                                    ),
                            ),
                          ),

                          //Preview
                          Tooltip(
                            message: curLangText!.previewTooltipText,
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
                                  Text('${curLangText!.previewBtnText} ', style: const TextStyle(fontWeight: FontWeight.w400)),
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

                          //Open Folder menu
                          Tooltip(
                            message: curLangText!.foldersTooltipText,
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
                                        children: [
                                          const Icon(
                                            Icons.folder_copy_outlined,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 2.5),
                                          Text(curLangText!.foldersBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  isDense: true,
                                  items: topBtnMenuItems
                                      .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              if (item == curLangText!.modsFolderBtnText && item.isNotEmpty) const Icon(Icons.rule_folder_outlined),
                                              if (item == curLangText!.backupFolderBtnText && item.isNotEmpty) const Icon(Icons.backup_table),
                                              if (item == curLangText!.deletedItemsBtnText && item.isNotEmpty) const Icon(Icons.delete_rounded),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(bottom: 3),
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    //fontWeight: FontWeight.bold,
                                                    //color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          )))
                                      .toList(),
                                  onChanged: (value) async {
                                    if (value == curLangText!.modsFolderBtnText) {
                                      await launchUrl(Uri.parse('file:$modsDirPath'));
                                    } else if (value == curLangText!.backupFolderBtnText) {
                                      await launchUrl(Uri.parse('file:$backupDirPath'));
                                    } else if (value == curLangText!.deletedItemsBtnText) {
                                      await launchUrl(Uri.parse('file:$deletedItemsPath'));
                                    }
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

                          //Path menu
                          Tooltip(
                            message: curLangText!.pathsReselectTooltipText,
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
                                        children: [
                                          const Icon(
                                            Icons.folder_open_outlined,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 2.5),
                                          Text(curLangText!.pathsReselectBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                    ),
                                  ),
                                  isDense: true,
                                  items: [
                                    ...MenuItems.pathMenuItems.map(
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

                          //Dark theme
                          if (MyApp.themeNotifier.value == ThemeMode.dark)
                            Tooltip(
                              message: curLangText!.darkModeTooltipText,
                              height: 25,
                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                              waitDuration: const Duration(seconds: 1),
                              child: SizedBox(
                                width: 70,
                                child: MaterialButton(
                                  onPressed: (() async {
                                    MyApp.themeNotifier.value = ThemeMode.light;
                                    final prefs = await SharedPreferences.getInstance();

                                    prefs.setBool('isDarkModeOn', false);
                                    //setState(() {});
                                  }),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.light_mode_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2.5),
                                      Text(curLangText!.lightModeBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (MyApp.themeNotifier.value == ThemeMode.light)
                            Tooltip(
                              message: curLangText!.lightModeTooltipText,
                              height: 25,
                              textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                              waitDuration: const Duration(seconds: 1),
                              child: SizedBox(
                                width: 70,
                                child: MaterialButton(
                                  onPressed: (() async {
                                    final prefs = await SharedPreferences.getInstance();
                                    MyApp.themeNotifier.value = ThemeMode.dark;
                                    prefs.setBool('isDarkModeOn', true);
                                    //setState(() {});
                                  }),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.dark_mode_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2.5),
                                      Text(curLangText!.darkModeBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          //Language select
                          Tooltip(
                            message: curLangText!.languageTooltipText,
                            height: 25,
                            textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                            waitDuration: const Duration(seconds: 1),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: InkWell(
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Add a new language"),
                                      content: SizedBox(
                                        height: 110,
                                        width: 300,
                                        child: Column(
                                          children: [
                                            const Text('Enter new language\'s initial:\n(2 characters, ex: EN for English)'),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                height: 50,
                                                width: 60,
                                                child: TextFormField(
                                                  inputFormatters: [UpperCaseTextFormatter()],
                                                  controller: newLangTextController,
                                                  maxLines: 1,
                                                  maxLength: 2,
                                                  style: const TextStyle(fontSize: 15),
                                                  decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.only(left: 10, top: 10),
                                                    //hintText: '',
                                                    border: OutlineInputBorder(),
                                                    //isDense: true,
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Language initial can\'t be empty';
                                                    }
                                                    if (langDropDownList.indexWhere((e) => e == value) != -1) {
                                                      return 'Language initial already exists';
                                                    }
                                                    return null;
                                                  },
                                                  onChanged: (text) {
                                                    setState(() {
                                                      setState(
                                                        () {},
                                                      );
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            String newLangPath = '${Directory.current.path}${s}Language$s${newLangTextController.text.toUpperCase()}.json';
                                            TranslationText? newText = curLangText;
                                            if (!File(newLangPath).existsSync()) {
                                              await File(newLangPath).create(recursive: true);
                                            }
                                            TranslationLanguage newLang = TranslationLanguage(newLangTextController.text.toUpperCase(), newLangPath, false);
                                            langList.add(newLang);
                                            langList.sort(((a, b) => a.langInitial.compareTo(b.langInitial)));
                                            langDropDownList.add(newLangTextController.text.toUpperCase());
                                            newLangTextController.clear();
                                            //Json Write
                                            [newText].map((translText) => translText?.toJson()).toList();
                                            File(newLangPath).writeAsStringSync(json.encode([newText]));
                                            //Json Write
                                            langList.map((translation) => translation.toJson()).toList();
                                            File(langSettingsPath).writeAsStringSync(json.encode(langList));
                                            setState(() {});
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text("Add"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                  customButton: AbsorbPointer(
                                    absorbing: true,
                                    child: SizedBox(
                                      width: 34,
                                      child: MaterialButton(
                                        onPressed: (() {}),
                                        child: Text(langDropDownSelected),
                                      ),
                                    ),
                                  ),
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                                  ),
                                  buttonDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  isDense: true,
                                  dropdownElevation: 3,
                                  dropdownPadding: const EdgeInsets.symmetric(vertical: 2),
                                  //dropdownWidth: 250,
                                  //offset: const Offset(-130, 0),
                                  iconSize: 15,
                                  itemHeight: 20,
                                  itemPadding: const EdgeInsets.symmetric(horizontal: 5),
                                  items: langDropDownList
                                      .map((item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(bottom: 3),
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    //fontWeight: FontWeight.bold,
                                                    //color: Colors.white,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              )
                                            ],
                                          )))
                                      .toList(),
                                  value: langDropDownSelected,
                                  onChanged: (value) async {
                                    langDropDownSelected = value.toString();
                                    for (var lang in langList) {
                                      if (lang.langInitial == value) {
                                        lang.selected = true;
                                        curSelectedLangPath = lang.langFilePath;
                                        curActiveLang = lang.langInitial;
                                        convertLangTextData(jsonDecode(File(curSelectedLangPath).readAsStringSync()));
                                      } else {
                                        lang.selected = false;
                                      }
                                    }

                                    topBtnMenuItems = [curLangText!.modsFolderBtnText, curLangText!.backupFolderBtnText, curLangText!.deletedItemsBtnText];
                                    sortTypeList = [curLangText!.sortCateByNameText, curLangText!.sortCateByNumItemsText];

                                    //Json Write
                                    langList.map((translation) => translation.toJson()).toList();
                                    File(langSettingsPath).writeAsStringSync(json.encode(langList));
                                    Provider.of<StateProvider>(context, listen: false).languageReloadTrue();
                                    setState(() {});
                                    await Future.delayed(const Duration(seconds: 2));
                                    Provider.of<StateProvider>(context, listen: false).languageReloadFalse();
                                    setState(() {});
                                  },
                                )),
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
          if (context.watch<StateProvider>().isUpdateAvailable && versionToSkipUpdate != appVersion && curLangText != null)
            ScaffoldMessenger(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor),
                ),
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
                            curLangText!.newUpdateAvailText,
                            style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text('${curLangText!.newAppVerText} $newVersion - ${curLangText!.curAppVerText} $appVersion'),
                          ),
                          TextButton(
                              onPressed: (() {
                                setState(() {
                                  patchNotesDialog(context);
                                });
                              }),
                              child: Text(curLangText!.patchNoteLabelText)),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                                onPressed: (() async {
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setString('versionToSkipUpdate', appVersion);
                                  versionToSkipUpdate = appVersion;
                                  Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                  setState(() {});
                                }),
                                child: Text(curLangText!.skipVersionUpdateBtnLabel)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                                onPressed: (() {
                                  Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                  setState(() {});
                                }),
                                child: Text(curLangText!.dismissBtnText)),
                          ),
                          ElevatedButton(
                              onPressed: (() {
                                Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                              }),
                              child: Text(curLangText!.updateBtnText)),
                        ],
                      )
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          //New Ref sheets
          if (context.watch<StateProvider>().refSheetsUpdateAvailable)
            ScaffoldMessenger(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor),
                ),
                child: MaterialBanner(
                  backgroundColor: Theme.of(context).canvasColor,
                  elevation: 0,
                  padding: const EdgeInsets.all(0),
                  leadingPadding: const EdgeInsets.only(left: 15, right: 5),
                  leading: Icon(
                    Icons.newspaper,
                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent,
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (context.watch<StateProvider>().refSheetsCount < 1)
                        Text(
                          curLangText!.itemRefUpdateAvailableText,
                          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                        ),
                      if (context.watch<StateProvider>().refSheetsCount > 0)
                        Text(
                          '${curLangText!.downloadingText} ${context.watch<StateProvider>().refSheetsCount} ${curLangText!.filesOfText} ${localRefSheetsList.length}',
                          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                        ),
                      ElevatedButton(
                          onPressed: context.watch<StateProvider>().refSheetsCount < 1
                              ? (() {
                                  //Indexing files

                                  for (var file in Directory('$refSheetsDirPath${s}Player').listSync(recursive: true).where((element) => p.extension(element.path) == '.csv')) {
                                    localRefSheetsList.add(file.path);
                                  }

                                  downloadNewRefSheets(context, localRefSheetsList).then((_) async {
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setInt('refSheetsVersion', refSheetsNewVersion);
                                    //print('complete');
                                    Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableFalse();
                                    Provider.of<StateProvider>(context, listen: false).refSheetsCountReset();
                                  });

                                  setState(() {});
                                })
                              : null,
                          child: Text(curLangText!.downloadUpdateBtnLabel)),
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          //First use Notice
          if (_firstTimeUser)
            ScaffoldMessenger(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).hintColor),
                ),
                child: MaterialBanner(
                  backgroundColor: Theme.of(context).canvasColor,
                  elevation: 0,
                  padding: const EdgeInsets.all(0),
                  leadingPadding: const EdgeInsets.only(left: 15, right: 5),
                  leading: Icon(
                    Icons.new_releases_outlined,
                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent,
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        curLangText!.newUserNoticeText,
                        style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isFirstTimeLoad', false);
                            _firstTimeUser = false;
                            setState(() {});
                          },
                          child: Text(curLangText!.dismissBtnText)),
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          Expanded(child: curLangText == null ? const LangLoadingPage() : const PathsLoadingPage())
        ],
      ),
    );
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
