// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/functions/changelog_dialog.dart';
import 'package:pso2_mod_manager/functions/checksum_check.dart';
import 'package:pso2_mod_manager/functions/color_picker.dart';
import 'package:pso2_mod_manager/functions/new_profile_name.dart';
import 'package:pso2_mod_manager/functions/text_input_uppercase.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/itemsSwapper/items_swapper_popup.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/loaders/mod_files_loader.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/modsAdder/mods_adder_homepage.dart';
import 'package:pso2_mod_manager/pages/home_page.dart';
import 'package:pso2_mod_manager/pages/mods_loading_page.dart';
import 'package:pso2_mod_manager/pages/profiles_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:pso2_mod_manager/vital_gauge/vital_gauge_swapper_homepage.dart';
import 'package:pso2_mod_manager/widgets/tooltip.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

List<String> saveValues = ['off', 'minimal', 'all'];

List<bool> _selectedIconLoaderSwitches = <bool>[false, false, false];

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    _selectedIconLoaderSwitches[saveValues.indexWhere((element) => element == isAutoFetchingIconsOnStartup)] = true;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  int totalSheetFilesCount = File(modManRefSheetListFilePath).readAsLinesSync().length;

  @override
  Widget build(BuildContext context) {
    List<Widget> iconLoaderSwitches = <Widget>[
      ModManTooltip(message: curLangText!.uiWillNotFetchItemIcon, child: Text(curLangText!.uiOFF)),
      ModManTooltip(message: curLangText!.uiOnlyFetchOneIcon, child: Text(curLangText!.uiMinimal)),
      ModManTooltip(message: curLangText!.uiFetchAllMissingItemIcons, child: Text(curLangText!.uiAll))
    ];
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Title
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
            child: Text(
              curLangText!.uiSettings,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color,
              ),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            //color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
          Expanded(
            child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.7);
                    }
                    return Theme.of(context).textTheme.displaySmall?.color?.withOpacity(0.5);
                  }),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      //Language
                      InkWell(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(curLangText!.uiAddANewLanguage),
                              content: SizedBox(
                                height: 110,
                                width: 300,
                                child: Column(
                                  children: [
                                    Text(curLangText!.uiNewLanguageInititalInput),
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
                                              return curLangText!.uiNewLanguageInitialEmptyError;
                                            }
                                            if (langDropDownList.indexWhere((e) => e == value) != -1) {
                                              return curLangText!.uiNewLanguageInititalAlreadyExisted;
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
                                  child: Text(curLangText!.uiCancel),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                                    String newLangPath = Uri.file('$modManLanguageDirPath/${newLangTextController.text.toUpperCase()}.json').toFilePath();
                                    TranslationText? newText = curLangText;
                                    if (!File(newLangPath).existsSync()) {
                                      await File(newLangPath).create(recursive: true);
                                    }
                                    TranslationLanguage newLang = TranslationLanguage(newLangTextController.text.toUpperCase(), newLangPath, false);
                                    languageList.add(newLang);
                                    languageList.sort(((a, b) => a.langInitial.compareTo(b.langInitial)));
                                    langDropDownList.add(newLangTextController.text.toUpperCase());
                                    newLangTextController.clear();
                                    //Json Write to language file
                                    File(newLangPath).writeAsStringSync(encoder.convert(newText));
                                    //Json Write to settings
                                    languageList.map((lang) => lang.toJson()).toList();
                                    File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
                                    setState(() {});
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text(curLangText!.uiAdd),
                                ),
                              ],
                            ),
                          );
                        },
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                          customButton: AbsorbPointer(
                            absorbing: true,
                            child: MaterialButton(
                              onPressed: (() {}),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.language,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${curLangText!.uiCurrentLanguage}: $langDropDownSelected',
                                          style: const TextStyle(fontWeight: FontWeight.normal),
                                        ),
                                        const Icon(Icons.arrow_drop_down)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          buttonStyleData: ButtonStyleData(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                            ),
                          ),
                          iconStyleData: const IconStyleData(iconSize: 15),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 20,
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          isDense: true,
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
                                              //fontSize: 14,
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
                            for (var lang in languageList) {
                              if (lang.langInitial == value) {
                                lang.selected = true;
                                curActiveLang = lang.langInitial;
                                var jsonData = jsonDecode(File(lang.langFilePath).readAsStringSync());
                                curLangText = TranslationText.fromJson(jsonData);
                              } else {
                                lang.selected = false;
                              }
                            }

                            //Json Write
                            const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                            languageList.map((lang) => lang.toJson()).toList();
                            File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
                            Provider.of<StateProvider>(context, listen: false).reloadSplashScreenTrue();
                            Provider.of<StateProvider>(context, listen: false).languageReloadTrue();
                            setState(() {});
                            await Future.delayed(const Duration(seconds: 2));
                            Provider.of<StateProvider>(context, listen: false).reloadSplashScreenFalse();
                            Provider.of<StateProvider>(context, listen: false).languageReloadFalse();
                            setState(() {});
                          },
                        )),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //profiles select
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.filter_1_rounded,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('${curLangText!.uiProfiles}:'),
                              ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 5, left: 22, bottom: 5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5, bottom: 2.5),
                                      child: ModManTooltip(
                                        message: curLangText!.uiClickToChangeToThisProfileHoldToRename,
                                        child: MaterialButton(
                                          minWidth: 120,
                                          height: 30,
                                          //color: Theme.of(context).primaryColorDark,
                                          onPressed: modManCurActiveProfile == 1
                                              ? null
                                              : () async {
                                                  Navigator.pop(context);
                                                  final prefs = await SharedPreferences.getInstance();
                                                  modManCurActiveProfile = 1;
                                                  prefs.setInt('modManCurActiveProfile', modManCurActiveProfile);
                                                  Provider.of<StateProvider>(context, listen: false).reloadProfileTrue();
                                                  modViewItem = null;
                                                  ogModFilesReset();
                                                  Future.delayed(const Duration(milliseconds: 500), () {
                                                    profileLoader(context).then((value) {
                                                      Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile1Name);
                                                      Provider.of<StateProvider>(context, listen: false).reloadProfileFalse();
                                                    });
                                                  });

                                                  //setState(() {});
                                                },
                                          onLongPress: () async {
                                            String newName = await newProfileNameDialog(context);
                                            if (newName.isNotEmpty) {
                                              final prefs = await SharedPreferences.getInstance();
                                              prefs.setString('modManProfile1Name', newName);
                                              modManProfile1Name = newName;
                                              Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile1Name);
                                              setState(() {});
                                            }
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: modManCurActiveProfile == 1
                                                      ? MyApp.themeNotifier.value == ThemeMode.light
                                                          ? Color(lightModePrimarySwatch.value)
                                                          : Color(darkModePrimarySwatch.value)
                                                      : Theme.of(context).hintColor),
                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                          child: Text(modManProfile1Name,
                                              style: TextStyle(
                                                  color: modManCurActiveProfile == 1
                                                      ? MyApp.themeNotifier.value == ThemeMode.light
                                                          ? Color(lightModePrimarySwatch.value)
                                                          : Color(darkModePrimarySwatch.value)
                                                      : Theme.of(context).hintColor)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 5, bottom: 2.5),
                                      child: ModManTooltip(
                                        message: curLangText!.uiClickToChangeToThisProfileHoldToRename,
                                        child: MaterialButton(
                                          minWidth: 120,
                                          height: 30,
                                          //color: Theme.of(context).primaryColorDark,
                                          onPressed: modManCurActiveProfile == 2
                                              ? null
                                              : () async {
                                                  Navigator.pop(context);
                                                  final prefs = await SharedPreferences.getInstance();
                                                  modManCurActiveProfile = 2;
                                                  prefs.setInt('modManCurActiveProfile', modManCurActiveProfile);
                                                  Provider.of<StateProvider>(context, listen: false).reloadProfileTrue();
                                                  modViewItem = null;
                                                  ogModFilesReset();
                                                  Future.delayed(const Duration(milliseconds: 500), () {
                                                    profileLoader(context).then((value) {
                                                      Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile2Name);
                                                      Provider.of<StateProvider>(context, listen: false).reloadProfileFalse();
                                                    });
                                                  });

                                                  //setState(() {});
                                                },
                                          onLongPress: () async {
                                            String newName = await newProfileNameDialog(context);
                                            if (newName.isNotEmpty) {
                                              final prefs = await SharedPreferences.getInstance();
                                              prefs.setString('modManProfile2Name', newName);
                                              modManProfile2Name = newName;
                                              Provider.of<StateProvider>(context, listen: false).setProfileName(modManProfile2Name);
                                              setState(() {});
                                            }
                                          },
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: modManCurActiveProfile == 2
                                                      ? MyApp.themeNotifier.value == ThemeMode.light
                                                          ? Color(lightModePrimarySwatch.value)
                                                          : Color(darkModePrimarySwatch.value)
                                                      : Theme.of(context).hintColor),
                                              borderRadius: const BorderRadius.all(Radius.circular(2))),
                                          child: Text(modManProfile2Name,
                                              style: TextStyle(
                                                  color: modManCurActiveProfile == 2
                                                      ? MyApp.themeNotifier.value == ThemeMode.light
                                                          ? Color(lightModePrimarySwatch.value)
                                                          : Color(darkModePrimarySwatch.value)
                                                      : Theme.of(context).hintColor)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ),

                      //Path reselect
                      MaterialButton(
                        height: 40,
                        onPressed: (() {
                          pso2PathsReloader(context);
                        }),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_copy_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              curLangText!.uiReselectPso2binPath,
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //MM Path reselect
                      MaterialButton(
                        height: 40,
                        onPressed: (() {
                          modManPathReloader(context);
                        }),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_copy_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(curLangText!.uiReselectModManFolderPath, style: const TextStyle(fontWeight: FontWeight.normal)),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      const Divider(
                        indent: 5,
                        endIndent: 5,
                        height: 1,
                        thickness: 1,
                        //color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      //Path open
                      MaterialButton(
                        height: 40,
                        onPressed: (() async {
                          await launchUrl(Uri.file(modManModsDirPath));
                        }),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              curLangText!.uiOpenModsFolder,
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //Path open
                      //Open Backup removed due to backups being downloaded from sega
                      // MaterialButton(
                      //   height: 40,
                      //   onPressed: (() async {
                      //     await launchUrl(Uri.file(modManBackupsDirPath));
                      //   }),
                      //   child: Row(
                      //     children: [
                      //       const Icon(
                      //         Icons.folder_open_outlined,
                      //         size: 18,
                      //       ),
                      //       const SizedBox(width: 10),
                      //       Text(
                      //         curLangText!.uiOpenBackupFolder,
                      //         style: const TextStyle(fontWeight: FontWeight.normal),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 5,
                      // ),

                      //Path open
                      MaterialButton(
                        height: 40,
                        onPressed: (() async {
                          await launchUrl(Uri.file(modManDeletedItemsDirPath));
                        }),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              curLangText!.uiOpenDeletedItemsFolder,
                              style: const TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Divider(
                        indent: 5,
                        endIndent: 5,
                        height: 1,
                        thickness: 1,
                        //color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      //Other options
                      //Auto fetching item icon on startup
                      Padding(
                        padding: const EdgeInsets.only(top: 5, left: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_motion,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text('${curLangText!.uiStartupItemIconsFetching}:'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 25, bottom: 5),
                              child: ToggleButtons(
                                onPressed: (int index) async {
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setString('isAutoFetchingIconsOnStartup', saveValues[index]);
                                  isAutoFetchingIconsOnStartup = saveValues[index];
                                  setState(() {
                                    for (int i = 0; i < _selectedIconLoaderSwitches.length; i++) {
                                      _selectedIconLoaderSwitches[i] = i == index;
                                    }
                                  });
                                },
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                selectedBorderColor: Theme.of(context).colorScheme.primary,
                                constraints: const BoxConstraints(
                                  minHeight: 25.0,
                                  minWidth: 74.0,
                                ),
                                isSelected: _selectedIconLoaderSwitches,
                                children: iconLoaderSwitches,
                              ),
                            ),
                          ],
                        ),
                      ),

                      //Sliding item icons
                      ModManTooltip(
                        message: Provider.of<StateProvider>(context, listen: false).isSlidingItemIcons ? curLangText!.uiTurnOffSlidingItemIcons : curLangText!.uiTurnOnSlidingItemIcons,
                        child: MaterialButton(
                          height: 40,
                          onPressed: (() async {
                            final prefs = await SharedPreferences.getInstance();
                            if (Provider.of<StateProvider>(context, listen: false).isSlidingItemIcons) {
                              prefs.setBool('isSlidingItemIcons', false);
                              Provider.of<StateProvider>(context, listen: false).isSlidingItemIconsFalse();
                            } else {
                              prefs.setBool('isSlidingItemIcons', true);
                              Provider.of<StateProvider>(context, listen: false).isSlidingItemIconsTrue();
                            }
                            setState(() {});
                          }),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.slideshow_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(Provider.of<StateProvider>(context, listen: false).isSlidingItemIcons ? '${curLangText!.uiSlidingItemIcons}: ON' : '${curLangText!.uiSlidingItemIcons}: OFF',
                                  style: const TextStyle(fontWeight: FontWeight.w400))
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      const Divider(
                        indent: 5,
                        endIndent: 5,
                        height: 1,
                        thickness: 1,
                        //color: Theme.of(context).textTheme.headlineMedium?.color,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Text(
                          '${curLangText!.uiTheme}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      //Dark theme
                      if (MyApp.themeNotifier.value == ThemeMode.dark)
                        ModManTooltip(
                          message: curLangText!.uiSwitchToLightTheme,
                          child: MaterialButton(
                            height: 40,
                            onPressed: (() async {
                              MyApp.themeNotifier.value = ThemeMode.light;
                              final prefs = await SharedPreferences.getInstance();
                              Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(lightModeUIBackgroundColor.value);
                              prefs.setBool('isDarkModeOn', false);
                              //setState(() {});
                            }),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.dark_mode,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text('${curLangText!.uiAppearance}: ${curLangText!.uiDarkTheme}', style: const TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                      if (MyApp.themeNotifier.value == ThemeMode.light)
                        ModManTooltip(
                          message: curLangText!.uiSwitchToDarkTheme,
                          child: MaterialButton(
                            height: 40,
                            onPressed: (() async {
                              final prefs = await SharedPreferences.getInstance();
                              MyApp.themeNotifier.value = ThemeMode.dark;
                              prefs.setBool('isDarkModeOn', true);
                              Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(darkModeUIBackgroundColor.value);
                              //setState(() {});
                            }),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.light_mode,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text('${curLangText!.uiAppearance}: ${curLangText!.uiLightTheme}', style: const TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 5,
                      ),

                      //Opacity slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.opacity_outlined,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text('${curLangText!.uiUIOpacity}:'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Slider(
                            min: 0.0,
                            max: 1.0,
                            value: context.watch<StateProvider>().uiOpacityValue,
                            onChanged: (value) async {
                              Provider.of<StateProvider>(context, listen: false).uiOpacityValueSet(value);
                              final prefs = await SharedPreferences.getInstance();
                              prefs.setDouble('uiOpacityValue', value);
                            }),
                      ),
                      //Theme color picker
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.color_lens,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text('${curLangText!.uiUIColors}:'),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiPrimarySwatch,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(lightModePrimarySwatch.value) : Color(darkModePrimarySwatch.value),
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = Color(lightModePrimarySwatch.value);
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                CustomMaterialColor newMaterialColor = CustomMaterialColor(selectedColor!.red, selectedColor!.green, selectedColor!.blue);
                                                lightModePrimarySwatch = newMaterialColor.materialColor;
                                                prefs.setInt('lightModePrimarySwatch', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                          } else {
                                            currentColor = Color(darkModePrimarySwatch.value);
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                CustomMaterialColor newMaterialColor = CustomMaterialColor(selectedColor!.red, selectedColor!.green, selectedColor!.blue);
                                                darkModePrimarySwatch = newMaterialColor.materialColor;
                                                prefs.setInt('darkModePrimarySwatch', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                          }

                                          setState(() {});
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiMainUIBackground,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: MyApp.themeNotifier.value == ThemeMode.light ? Color(lightModeUIBackgroundColor.value) : Color(darkModeUIBackgroundColor.value),
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = lightModeUIBackgroundColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                lightModeUIBackgroundColor = selectedColor!;
                                                prefs.setInt('lightModeUIBackgroundColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(lightModeUIBackgroundColor.value);
                                                setState(() {});
                                                selectedColor = null;
                                              }
                                            });
                                          } else {
                                            currentColor = darkModeUIBackgroundColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                darkModeUIBackgroundColor = selectedColor!;
                                                prefs.setInt('darkModeUIBackgroundColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(darkModeUIBackgroundColor.value);
                                                setState(() {});
                                                selectedColor = null;
                                              }
                                            });
                                          }
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiPrimaryColor,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = lightModePrimaryColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                lightModePrimaryColor = selectedColor!;
                                                prefs.setInt('lightModePrimaryColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          } else {
                                            currentColor = darkModePrimaryColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                darkModePrimaryColor = selectedColor!;
                                                prefs.setInt('darkModePrimaryColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          }
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiPrimaryLight,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: Theme.of(context).primaryColorLight,
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = lightModePrimaryColorLight;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                lightModePrimaryColorLight = selectedColor!;
                                                prefs.setInt('lightModePrimaryColorLight', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          } else {
                                            currentColor = darkModePrimaryColorLight;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                darkModePrimaryColorLight = selectedColor!;
                                                prefs.setInt('darkModePrimaryColorLight', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          }
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiPrimaryDark,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: Theme.of(context).primaryColorDark,
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = lightModePrimaryColorDark;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                lightModePrimaryColorDark = selectedColor!;
                                                prefs.setInt('lightModePrimaryColorDark', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          } else {
                                            currentColor = darkModePrimaryColorDark;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                darkModePrimaryColorDark = selectedColor!;
                                                prefs.setInt('darkModePrimaryColorDark', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          }
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 2.5),
                                    child: ModManTooltip(
                                      message: curLangText!.uiMainCanvasBackground,
                                      child: MaterialButton(
                                        minWidth: 120,
                                        height: 30,
                                        color: Theme.of(context).canvasColor,
                                        onPressed: () async {
                                          final prefs = await SharedPreferences.getInstance();
                                          if (MyApp.themeNotifier.value == ThemeMode.light) {
                                            currentColor = lightModeCanvasColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                lightModeCanvasColor = selectedColor!;
                                                prefs.setInt('lightModeCanvasColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          } else {
                                            currentColor = darkModeCanvasColor;
                                            pickerColor = currentColor;
                                            getColor(context).then((_) {
                                              if (selectedColor != null) {
                                                darkModeCanvasColor = selectedColor!;
                                                prefs.setInt('darkModeCanvasColor', selectedColor!.value);
                                                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                                MyApp.themeNotifier.notifyListeners();
                                                selectedColor = null;
                                              }
                                            });
                                            setState(() {});
                                          }
                                        },
                                        shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5, bottom: 2.5),
                                child: MaterialButton(
                                  minWidth: 242,
                                  height: 30,
                                  //color: Theme.of(context).primaryColor,
                                  onLongPress: () async {
                                    final prefs = await SharedPreferences.getInstance();

                                    if (MyApp.themeNotifier.value == ThemeMode.light) {
                                      lightModePrimaryColor = const Color(0xffffffff);
                                      lightModePrimaryColorLight = const Color(0xff3181ff);
                                      lightModePrimaryColorDark = const Color(0xff000000);
                                      lightModeCanvasColor = const Color(0xffffffff);
                                      lightModeUIBackgroundColor = const Color(0xffffffff);
                                      lightModePrimarySwatch = Colors.blue;
                                      //Save to prefs
                                      prefs.setInt('lightModePrimaryColor', lightModePrimaryColor.value);
                                      prefs.setInt('lightModePrimaryColorLight', lightModePrimaryColorLight.value);
                                      prefs.setInt('lightModePrimaryColorDark', lightModePrimaryColorDark.value);
                                      prefs.setInt('lightModeCanvasColor', lightModeCanvasColor.value);
                                      prefs.setInt('lightModeUIBackgroundColor', lightModeUIBackgroundColor.value);
                                      prefs.setInt('lightModePrimarySwatch', Colors.blue.value);
                                      Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(lightModeUIBackgroundColor.value);
                                    } else {
                                      darkModePrimaryColor = const Color(0xff000000);
                                      darkModePrimaryColorLight = const Color(0xff706f6f);
                                      darkModePrimaryColorDark = const Color(0xff000000);
                                      darkModeCanvasColor = const Color(0xff2e2d2d);
                                      darkModeUIBackgroundColor = const Color(0xff2e2d2d);
                                      darkModePrimarySwatch = Colors.blue;
                                      //Save to prefs
                                      prefs.setInt('darkModePrimaryColor', darkModePrimaryColor.value);
                                      prefs.setInt('darkModePrimaryColorLight', darkModePrimaryColorLight.value);
                                      prefs.setInt('darkModePrimaryColorDark', darkModePrimaryColorDark.value);
                                      prefs.setInt('darkModeCanvasColor', darkModeCanvasColor.value);
                                      prefs.setInt('darkModeUIBackgroundColor', darkModeUIBackgroundColor.value);
                                      prefs.setInt('darkModePrimarySwatch', Colors.blue.value);
                                      Provider.of<StateProvider>(context, listen: false).uiBackgroundColorValueSet(darkModeUIBackgroundColor.value);
                                    }
                                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    MyApp.themeNotifier.notifyListeners();
                                    setState(() {});
                                  },
                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                  onPressed: () {},
                                  child: Text(curLangText!.uiHoldToResetColors),
                                ),
                              ),

                              //Background Image
                              Padding(
                                padding: const EdgeInsets.only(left: 7, right: 7, top: 10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.image,
                                      size: 18,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text('${curLangText!.uiBackgroundImage}:'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 232),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      InkWell(
                                        child: Container(
                                          child: backgroundImage.path != ''
                                              ? Stack(
                                                  alignment: Alignment.bottomCenter,
                                                  children: [
                                                    Image.file(
                                                      backgroundImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                        width: double.infinity,
                                                        color: Theme.of(context).canvasColor.withOpacity(0.5),
                                                        child: Center(child: Text(curLangText!.uiClicktoChangeBackgroundImage)))
                                                  ],
                                                )
                                              : Center(child: Text(curLangText!.uiNoBackgroundImageFound)),
                                        ),
                                        onTap: () async {
                                          //await FilePicker.platform.pickFiles(dialogTitle: curLangText!.uiSelectBackgroundImage, lockParentWindow: true, type: FileType.image).then((value) async {
                                          const XTypeGroup typeGroup = XTypeGroup(
                                            label: 'images',
                                            extensions: <String>['png', 'jpg'],
                                          );
                                          await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]).then((value) async {
                                            if (value != null) {
                                              final prefs = await SharedPreferences.getInstance();
                                              //backgroundImage = File(value.paths.first!);
                                              backgroundImage = File(value.path);
                                              prefs.setString('backgroundImagePath', backgroundImage.path);
                                              Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerTrue();
                                            }
                                          });
                                          setState(() {});
                                          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                          MyApp.themeNotifier.notifyListeners();
                                        },
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (Provider.of<StateProvider>(context, listen: false).backgroundImageTrigger ||
                                              (!showBackgroundImage && !Provider.of<StateProvider>(context, listen: false).backgroundImageTrigger))
                                            ModManTooltip(
                                              message: showBackgroundImage ? curLangText!.uiHideBackgroundImage : curLangText!.uiShowBackgroundImage,
                                              child: InkWell(
                                                child: Container(
                                                  decoration: ShapeDecoration(
                                                    color: Colors.blue,
                                                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                  ),
                                                  child: Icon(
                                                    showBackgroundImage ? Icons.hide_image_outlined : Icons.image_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onTap: () async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  if (showBackgroundImage) {
                                                    showBackgroundImage = false;
                                                    prefs.setBool('showBgImage', false);
                                                    Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerFalse();
                                                  } else {
                                                    showBackgroundImage = true;
                                                    prefs.setBool('showBgImage', true);
                                                    Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerTrue();
                                                  }
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                          if (Provider.of<StateProvider>(context, listen: false).backgroundImageTrigger ||
                                              (!showBackgroundImage && !Provider.of<StateProvider>(context, listen: false).backgroundImageTrigger))
                                            ModManTooltip(
                                              message: curLangText!.uiHoldToRemoveBackgroundImage,
                                              child: InkWell(
                                                child: Container(
                                                  decoration: ShapeDecoration(
                                                    color: Colors.red,
                                                    shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                                  ),
                                                  child: const Icon(
                                                    Icons.delete_forever_outlined,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onLongPress: () async {
                                                  final prefs = await SharedPreferences.getInstance();
                                                  prefs.setString('backgroundImagePath', '');
                                                  backgroundImage = File('');
                                                  Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerFalse();
                                                  setState(() {});
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ]),
                  ),
                )),
          ),
        ],
      )),
      body: Column(
        children: [
          WindowTitleBarBox(
            child: Container(
              color: Theme.of(context).canvasColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: MoveWindow(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ModManTooltip(
                                  message: '${curLangText!.uiVersion}: $appVersion | ${curLangText!.uiMadeBy} キス★',
                                  child: const Text(
                                    'PSO2NGS Mod Manager',
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                  )),
                            ],
                          ),
                          if (versionToSkipUpdate == appVersion && curLangText != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 3),
                              child: ModManTooltip(
                                message: curLangText!.uiNewUpdateAvailableClickToDownload,
                                child: InkWell(
                                  onTap: () {
                                    launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 3),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.red : Colors.amber),
                                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      child: Text(curLangText!.uiUpdateNow, style: TextStyle(fontSize: 13, color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.red : Colors.amber))),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )),
                  ),

                  //Buttons
                  if (curLangText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1.5),
                      child: Row(
                        children: [
                          //Add Items/Mods
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: curLangText!.uiAddNewModsToMM,
                              child: SizedBox(
                                //width: curActiveLang == 'JP' ? 110 : 105,
                                child: MaterialButton(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                  //color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.tealAccent : Colors.blue,
                                  // onPressed: (() {
                                  //   Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                  //     element.deleteSync(recursive: true);
                                  //   });
                                  //   Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
                                  //     element.deleteSync(recursive: true);
                                  //   });
                                  //   modAddHandler(context);
                                  // }),
                                  onPressed: () {
                                    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                      element.deleteSync(recursive: true);
                                    });
                                    Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
                                      element.deleteSync(recursive: true);
                                    });
                                    Directory(modManModsAdderPath).listSync(recursive: false).forEach((element) {
                                      element.deleteSync(recursive: true);
                                    });
                                    modsAdderHomePage(context);
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2.5),
                                      Text(curLangText!.uiAddMods, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Vital gauge
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: curLangText!.uiCreateAndSwapVitalGaugeBackground,
                              child: SizedBox(
                                //width: 99,
                                child: MaterialButton(
                                  onPressed: (() {
                                    Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                      element.deleteSync(recursive: true);
                                    });
                                    vitalGaugeHomePage(context);
                                  }),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.horizontal_split,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2.5),
                                      Text(curLangText!.uiVitalGauge, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Item swapper
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: curLangText!.uiSwapAnItemToAnotherItem,
                              child: SizedBox(
                                //width: 99,
                                child: MaterialButton(
                                  onPressed: (() {
                                    itemsSwapperCategorySelect(context);
                                  }),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.swap_horizontal_circle_outlined,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 2.5),
                                      Text(curLangText!.uiSwapItems, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Mod sets
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: Provider.of<StateProvider>(context, listen: false).setsWindowVisible ? curLangText!.uiManageModList : curLangText!.uiManageModSets,
                              child: SizedBox(
                                //width: 99,
                                child: MaterialButton(
                                  onPressed: (() {
                                    if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) {
                                      isModViewListHidden = true;
                                      isModSetAdding = false;
                                      Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetFalse();
                                    } else {
                                      isModViewListHidden = true;
                                      isModSetAdding = false;
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
                                      if (!Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.uiModSets, style: const TextStyle(fontWeight: FontWeight.w400)),
                                      if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.uiModList, style: const TextStyle(fontWeight: FontWeight.w400))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //Refresh
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: curLangText!.uiRefreshMM,
                              child: MaterialButton(
                                //visualDensity: VisualDensity.compact,
                                onPressed: (() async {
                                  listsReloading = true;
                                  Provider.of<StateProvider>(context, listen: false).reloadSplashScreenTrue();
                                  Future.delayed(const Duration(milliseconds: 500), () {
                                    modFileStructureLoader(context, true).then((value) {
                                      moddedItemsList = value;
                                      listsReloading = false;
                                      modViewItem = null;
                                      Provider.of<StateProvider>(context, listen: false).reloadSplashScreenFalse();
                                    });
                                  });
                                }),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.refresh,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(curLangText!.uiRefresh, style: const TextStyle(fontWeight: FontWeight.w400)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          //Checksum
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: modManChecksumFilePath.isNotEmpty && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                  ? curLangText!.uiOpenChecksumFolder
                                  : curLangText!.uiChecksumDownloadSelect,
                              child: MaterialButton(
                                onLongPress: () async {
                                  if (modManChecksumFilePath.isEmpty || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                    final XFile? selectedFile = await openFile();
                                    if (selectedFile != null) {
                                      checksumLocation = selectedFile.path;
                                    }
                                    // await FilePicker.platform.pickFiles(
                                    //   dialogTitle: curLangText!.uiSelectLocalChecksum,
                                    //   allowMultiple: false,
                                    //   // type: FileType.custom,
                                    //   // allowedExtensions: ['\'\''],
                                    //   lockParentWindow: true,
                                    // );
                                    if (checksumLocation != null) {
                                      //String? checksumPath = checksumLocation!.paths.first;
                                      String? checksumPath = checksumLocation;
                                      if (checksumPath!.isNotEmpty) {
                                        File(checksumPath).copySync(Uri.file('$modManChecksumDirPath/${p.basename(checksumPath)}').toFilePath());
                                        modManChecksumFilePath = Uri.file('$modManChecksumDirPath/${p.basename(checksumPath)}').toFilePath();
                                        File(modManChecksumFilePath).copySync(Uri.file('$modManPso2binPath/data/win32/${p.basename(modManChecksumFilePath)}').toFilePath());
                                        if (Directory(Uri.file('$modManPso2binPath/data/win32_na').toFilePath()).existsSync()) {
                                          File(modManChecksumFilePath).copySync(Uri.file('$modManPso2binPath/data/win32_na/${p.basename(modManChecksumFilePath)}').toFilePath());
                                        }
                                        final prefs = await SharedPreferences.getInstance();
                                        prefs.setString('checksumFilePath', modManChecksumFilePath);
                                        Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
                                      }
                                      setState(() {});
                                    }
                                  } else {
                                    await launchUrl(Uri.parse('file:$modManChecksumDirPath'));
                                  }
                                },
                                onPressed: (() async {
                                  if (modManChecksumFilePath.isEmpty || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                    Provider.of<StateProvider>(context, listen: false).checksumDownloadingTrue();
                                    setState(() {});
                                    await Dio().download(netChecksumFileLink, Uri.file('$modManChecksumDirPath/$netChecksumFileName').toFilePath()).then((value) {
                                      Provider.of<StateProvider>(context, listen: false).checksumDownloadingFalse();
                                      modManChecksumFilePath = Uri.file('$modManChecksumDirPath/$netChecksumFileName').toFilePath();
                                      checksumChecker(context);
                                      Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
                                      setState(() {});
                                    });
                                  } else {
                                    await launchUrl(Uri.parse('file:$modManChecksumDirPath'));
                                  }
                                }),
                                child: modManChecksumFilePath.isNotEmpty && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                    ? Row(
                                        children: [
                                          const Icon(
                                            Icons.fingerprint,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 2.5),
                                          Text('${curLangText!.uiChecksum}: ', style: const TextStyle(fontWeight: FontWeight.w400)),
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
                                          !Provider.of<StateProvider>(context, listen: false).checksumDownloading && modManChecksumFilePath.isEmpty
                                              ? Text(curLangText!.uiChecksumMissingClick, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
                                              : !Provider.of<StateProvider>(context, listen: false).checksumDownloading && !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                                  ? Text(curLangText!.uiChecksumOutdatedClick, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
                                                  : Provider.of<StateProvider>(context, listen: false).checksumDownloading
                                                      ? Text(curLangText!.uiChecksumDownloading, style: const TextStyle(fontWeight: FontWeight.w400, color: Colors.red))
                                                      : Row(
                                                          children: [
                                                            Text('${curLangText!.uiChecksum}: ', style: const TextStyle(fontWeight: FontWeight.w400)),
                                                            Text('ERROR',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 13,
                                                                    color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Theme.of(context).iconTheme.color)),
                                                          ],
                                                        ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          //Preview
                          Visibility(
                            visible: context.watch<StateProvider>().showTitleBarButtons,
                            child: ModManTooltip(
                              message: curLangText!.uiPreviewShowHide,
                              child: MaterialButton(
                                //visualDensity: VisualDensity.compact,
                                onPressed: (() async {
                                  final prefs = await SharedPreferences.getInstance();
                                  if (Provider.of<StateProvider>(context, listen: false).previewWindowVisible) {
                                    Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetFalse();
                                    previewWindowVisible = false;
                                    prefs.setBool('previewWindowVisible', false);
                                    //previewPlayer.stop();
                                  } else {
                                    Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetTrue();
                                    previewWindowVisible = true;
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
                                    Text('${curLangText!.uiPreview}: ', style: const TextStyle(fontWeight: FontWeight.w400)),
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
                          ),

                          //Settings button
                          ModManTooltip(
                            message: curLangText!.uiOpenMMSettings,
                            child: SizedBox(
                              //width: 95,
                              child: MaterialButton(
                                onPressed: (() {
                                  _scaffoldKey.currentState!.openEndDrawer();
                                }),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.settings,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(curLangText!.uiSettings, style: const TextStyle(fontWeight: FontWeight.w400))
                                  ],
                                ),
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
                            curLangText!.uiNewMMUpdateAvailable,
                            style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text('${curLangText!.uiNewVersion}: $newVersion - ${curLangText!.uiCurrentVersion}: $appVersion'),
                          ),
                          TextButton(
                              onPressed: (() {
                                setState(() {
                                  patchNotesDialog(context);
                                });
                              }),
                              child: Text(curLangText!.uiPatchNote)),
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
                                child: Text(curLangText!.uiSkipMMUpdate)),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: ElevatedButton(
                                onPressed: (() {
                                  Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                  setState(() {});
                                }),
                                child: Text(curLangText!.uiDismiss)),
                          ),
                          ElevatedButton(
                              onPressed: (() {
                                Provider.of<StateProvider>(context, listen: false).isUpdateAvailableFalse();
                                launchUrl(Uri.parse('https://github.com/KizKizz/pso2_mod_manager/releases'));
                              }),
                              child: Text(curLangText!.uiUpdate)),
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
                          curLangText!.uiNewRefSheetsUpdate,
                          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                        ),
                      if (context.watch<StateProvider>().refSheetsCount > 0)
                        Text(
                          '${curLangText!.uiDownloading} ${context.watch<StateProvider>().refSheetsCount} ${curLangText!.uiOf} $totalSheetFilesCount ${curLangText!.uiRefSheetsDownloadingCount}',
                          style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                        ),
                      ElevatedButton(
                          onPressed: context.watch<StateProvider>().refSheetsCount < 1
                              ? (() {
                                  downloadNewRefSheets(context, File(modManRefSheetListFilePath)).then((_) async {
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setInt('refSheetsVersion', refSheetsNewVersion);
                                    //print('complete');
                                    Provider.of<StateProvider>(context, listen: false).refSheetsUpdateAvailableFalse();
                                    Provider.of<StateProvider>(context, listen: false).refSheetsCountReset();
                                  });

                                  setState(() {});
                                })
                              : null,
                          child: Text(curLangText!.uiDownloadUpdate)),
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          //First use Notice
          if (firstTimeUser)
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
                        curLangText!.uiNewUserNotice,
                        style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isFirstTimeLoadV2', false);
                            firstTimeUser = false;
                            setState(() {});
                          },
                          child: Text(curLangText!.uiDismiss)),
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          Divider(
            thickness: 1,
            height: 1,
            color: Theme.of(context).dividerColor,
          ),

          Expanded(child: isStartupModsLoad ? const ModsLoadingPage() : const HomePage())

          //Expanded(child: curLangText == null ? const LangLoadingPage() : const PathsLoadingPage())
        ],
      ),
    );
  }
}
