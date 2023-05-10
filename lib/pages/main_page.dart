// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pso2_mod_manager/application.dart';
import 'package:pso2_mod_manager/custom_window_button.dart';
import 'package:pso2_mod_manager/functions/color_picker.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/item_ref.dart';
import 'package:pso2_mod_manager/loaders/paths_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/mod_add_handler.dart';
import 'package:pso2_mod_manager/pages/mods_loading_page.dart';
import 'package:pso2_mod_manager/state_provider.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

bool firstTimeUser = false;
bool _checksumDownloading = false;
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
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
              'Settings',
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
                      Tooltip(
                        message: curLangText!.languageTooltipText,
                        height: 25,
                        textStyle: const TextStyle(fontSize: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor.withOpacity(0.8),
                          border: Border.all(color: Theme.of(context).primaryColorLight),
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                        ),
                        waitDuration: const Duration(milliseconds: 500),
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
                                            'Current language: $langDropDownSelected',
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
                            buttonHeight: 40,
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

                              topBtnMenuItems = [curLangText!.modsFolderBtnText, curLangText!.backupFolderBtnText, curLangText!.deletedItemsBtnText];
                              //sortTypeList = [curLangText!.sortCateByNameText, curLangText!.sortCateByNumItemsText];

                              //Json Write
                              const JsonEncoder encoder = JsonEncoder.withIndent('  ');
                              languageList.map((lang) => lang.toJson()).toList();
                              File(modManLanguageSettingsJsonPath).writeAsStringSync(encoder.convert(languageList));
                              Provider.of<StateProvider>(context, listen: false).languageReloadTrue();
                              setState(() {});
                              await Future.delayed(const Duration(seconds: 2));
                              Provider.of<StateProvider>(context, listen: false).languageReloadFalse();
                              setState(() {});
                            },
                          )),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //Path reselect
                      MaterialButton(
                        height: 40,
                        onPressed: (() {}),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Reselect pso2_bin path',
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),

                      //Path reselect
                      MaterialButton(
                        height: 40,
                        onPressed: (() {}),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Reselect Mod Manager folder path', style: TextStyle(fontWeight: FontWeight.normal)),
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

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        child: Text(
                          'Theme:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),

                      //Dark theme
                      if (MyApp.themeNotifier.value == ThemeMode.dark)
                        Tooltip(
                          message: curLangText!.darkModeTooltipText,
                          height: 25,
                          textStyle: const TextStyle(fontSize: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor.withOpacity(0.8),
                            border: Border.all(color: Theme.of(context).primaryColorLight),
                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                          ),
                          waitDuration: const Duration(milliseconds: 500),
                          child: MaterialButton(
                            height: 40,
                            onPressed: (() async {
                              MyApp.themeNotifier.value = ThemeMode.light;
                              final prefs = await SharedPreferences.getInstance();

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
                                Text('Appearance: ${curLangText!.darkModeBtnText}', style: const TextStyle(fontWeight: FontWeight.w400))
                              ],
                            ),
                          ),
                        ),
                      if (MyApp.themeNotifier.value == ThemeMode.light)
                        Tooltip(
                          message: curLangText!.lightModeTooltipText,
                          height: 25,
                          textStyle: const TextStyle(fontSize: 14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor.withOpacity(0.8),
                            border: Border.all(color: Theme.of(context).primaryColorLight),
                            borderRadius: const BorderRadius.all(Radius.circular(2)),
                          ),
                          waitDuration: const Duration(milliseconds: 500),
                          child: MaterialButton(
                            height: 40,
                            onPressed: (() async {
                              final prefs = await SharedPreferences.getInstance();
                              MyApp.themeNotifier.value = ThemeMode.dark;
                              prefs.setBool('isDarkModeOn', true);
                              //setState(() {});
                            }),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.light_mode,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text('Appearance: ${curLangText!.lightModeBtnText}', style: const TextStyle(fontWeight: FontWeight.w400))
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
                          children: const [
                            Icon(
                              Icons.opacity_outlined,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('UI Opacity:'),
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
                          children: const [
                            Icon(
                              Icons.color_lens,
                              size: 18,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Colors:'),
                          ],
                        ),
                      ),
                      SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0, top: 5, bottom: 2.5),
                                child: MaterialButton(
                                  minWidth: 242,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2.5),
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 2.5),
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
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5, bottom: 2.5),
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 2.5),
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
                                      lightModePrimarySwatch = Colors.blue;
                                      //Save to prefs
                                      prefs.setInt('lightModePrimaryColor', lightModePrimaryColor.value);
                                      prefs.setInt('lightModePrimaryColorLight', lightModePrimaryColorLight.value);
                                      prefs.setInt('lightModePrimaryColorDark', lightModePrimaryColorDark.value);
                                      prefs.setInt('lightModeCanvasColor', lightModeCanvasColor.value);
                                      prefs.setInt('lightModePrimarySwatch', Colors.blue.value);
                                    } else {
                                      darkModePrimaryColor = const Color(0xff000000);
                                      darkModePrimaryColorLight = const Color(0xff706f6f);
                                      darkModePrimaryColorDark = const Color(0xff000000);
                                      darkModeCanvasColor = const Color(0xff2e2d2d);
                                      darkModePrimarySwatch = Colors.blue;
                                      //Save to prefs
                                      prefs.setInt('darkModePrimaryColor', darkModePrimaryColor.value);
                                      prefs.setInt('darkModePrimaryColorLight', darkModePrimaryColorLight.value);
                                      prefs.setInt('darkModePrimaryColorDark', darkModePrimaryColorDark.value);
                                      prefs.setInt('darkModeCanvasColor', darkModeCanvasColor.value);
                                      prefs.setInt('darkModePrimarySwatch', Colors.blue.value);
                                    }
                                    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                    MyApp.themeNotifier.notifyListeners();
                                  },
                                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                  onPressed: () {},
                                  child: const Text('Hold to reset to default colors'),
                                ),
                              ),

                              //Background Image
                              Padding(
                                padding: const EdgeInsets.only(left: 7, right: 7, top: 10),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.image,
                                      size: 18,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Background Image:'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 7, right: 7, top: 5, bottom: 5),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        constraints: const BoxConstraints(maxWidth: 232),
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).hintColor), borderRadius: const BorderRadius.all(Radius.circular(2))),
                                        ),
                                        child: backgroundImage.path != ''
                                            ? Stack(
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  Image.file(
                                                    backgroundImage,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(width: double.infinity, color: Theme.of(context).canvasColor.withOpacity(0.5), child: const Center(child: Text('Click to change')))
                                                ],
                                              )
                                            : const Center(child: Text('No image found. Click!')),
                                      ),
                                      onTap: () async {
                                        await FilePicker.platform.pickFiles(dialogTitle: 'Select your image', lockParentWindow: true, type: FileType.image).then((value) async {
                                          if (value != null) {
                                            final prefs = await SharedPreferences.getInstance();
                                            backgroundImage = File(value.paths.first!);
                                            prefs.setString('backgroundImagePath', backgroundImage.path);
                                            Provider.of<StateProvider>(context, listen: false).backgroundImageTriggerTrue();
                                          }
                                        });
                                        setState(() {});
                                        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                                        MyApp.themeNotifier.notifyListeners();
                                      },
                                    ),
                                    if (Provider.of<StateProvider>(context, listen: false).backgroundImageTrigger)
                                      Tooltip(
                                        message: 'Hold to remove background image',
                                        height: 25,
                                        textStyle: const TextStyle(fontSize: 14),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).canvasColor.withOpacity(0.8),
                                          border: Border.all(color: Theme.of(context).primaryColorLight),
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                        ),
                                        waitDuration: const Duration(milliseconds: 500),
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
                              ),
                            ],
                          )),

                      // Tooltip(
                      //   message: curLangText!.pathsReselectTooltipText,
                      //   height: 25,
                      //   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                      //   waitDuration: const Duration(seconds: 1),
                      //   child: DropdownButtonHideUnderline(
                      //     child: DropdownButton2(
                      //       customButton: AbsorbPointer(
                      //         absorbing: true,
                      //         child: MaterialButton(
                      //           onPressed: (() {}),
                      //           child: Row(
                      //             children: [
                      //               const Icon(
                      //                 Icons.folder_open_outlined,
                      //                 size: 18,
                      //               ),
                      //               const SizedBox(width: 5),
                      //               Expanded(
                      //                 child: Row(
                      //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //                   children: [
                      //                     Text(curLangText!.pathsReselectBtnText, style: const TextStyle(fontWeight: FontWeight.w400)),
                      //                     const Icon(Icons.arrow_drop_down)
                      //                   ],
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       isDense: true,
                      //       items: [
                      //         ...MenuItems.pathMenuItems.map(
                      //           (item) => DropdownMenuItem<MenuItem>(
                      //             value: item,
                      //             alignment: AlignmentDirectional.center,
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //               MenuItems.buildItem(context, item)
                      //             ],),
                      //           ),
                      //         ),
                      //       ],
                      //       onChanged: (value) {
                      //         MenuItems.onChanged(context, value as MenuItem);
                      //       },
                      //       itemHeight: 35,
                      //       //dropdownWidth: 130,
                      //       itemPadding: const EdgeInsets.only(left: 5, right: 5),
                      //       dropdownPadding: const EdgeInsets.symmetric(vertical: 5),
                      //       dropdownDecoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(3),
                      //         color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                      //       ),

                      //       dropdownElevation: 8,
                      //       offset: const Offset(0, -3),
                      //     ),
                      //   ),
                      // ),
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
                children: [
                  Expanded(
                    child: MoveWindow(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Tooltip(
                                  message: 'Version: $appVersion | Made by キス★',
                                  height: 25,
                                  textStyle: const TextStyle(fontSize: 14),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).canvasColor.withOpacity(0.8),
                                    border: Border.all(color: Theme.of(context).primaryColorLight),
                                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  ),
                                  waitDuration: const Duration(milliseconds: 500),
                                  child: const Text(
                                    'PSO2NGS Mod Manager',
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                  )),
                            ],
                          ),
                          if (versionToSkipUpdate == appVersion && curLangText != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Tooltip(
                                message: curLangText!.titleNewUpdateToolTip,
                                height: 25,
                                textStyle: const TextStyle(fontSize: 14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).canvasColor.withOpacity(0.8),
                                  border: Border.all(color: Theme.of(context).primaryColorLight),
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                ),
                                waitDuration: const Duration(milliseconds: 500),
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
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Row(
                        children: [
                          //Add Items/Mods
                          Tooltip(
                            message: curLangText!.addModsTooltip,
                            height: 25,
                            textStyle: const TextStyle(fontSize: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.8),
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                            ),
                            waitDuration: const Duration(milliseconds: 500),
                            child: SizedBox(
                              width: curActiveLang == 'JP' ? 110 : 105,
                              child: MaterialButton(
                                color: MyApp.themeNotifier.value == ThemeMode.light ? Colors.tealAccent : Colors.blue,
                                onPressed: (() {
                                  Directory(modManAddModsTempDirPath).listSync(recursive: false).forEach((element) {
                                    element.deleteSync(recursive: true);
                                  });
                                  Directory(modManAddModsUnpackDirPath).listSync(recursive: false).forEach((element) {
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
                          // Tooltip(
                          //   message: curLangText!.modSetsTooltipText,
                          //   height: 25,
                          //   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          //   waitDuration: const Duration(seconds: 1),
                          //   child: SizedBox(
                          //     width: 99,
                          //     child: MaterialButton(
                          //       onPressed: (() {
                          //         if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) {
                          //           modFilesFromSetList.clear();
                          //           modFilesList.clear();
                          //           modsSetAppBarName = '';
                          //           modsViewAppBarName = '';
                          //           Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetFalse();
                          //         } else {
                          //           modFilesFromSetList.clear();
                          //           modFilesList.clear();
                          //           modsSetAppBarName = '';
                          //           modsViewAppBarName = '';
                          //           Provider.of<StateProvider>(context, listen: false).setsWindowVisibleSetTrue();
                          //         }
                          //       }),
                          //       child: Row(
                          //         children: [
                          //           if (!Provider.of<StateProvider>(context, listen: false).setsWindowVisible)
                          //             const Icon(
                          //               Icons.list_alt_outlined,
                          //               size: 18,
                          //             ),
                          //           if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible)
                          //             const Icon(
                          //               Icons.view_list_outlined,
                          //               size: 18,
                          //             ),
                          //           const SizedBox(width: 2.5),
                          //           if (!Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.modSetsBtnText, style: const TextStyle(fontWeight: FontWeight.w400)),
                          //           if (Provider.of<StateProvider>(context, listen: false).setsWindowVisible) Text(curLangText!.modListBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          //Checksum
                          Tooltip(
                            message: modManChecksumFilePath.isNotEmpty && Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match
                                ? curLangText!.checksumToolTipText
                                : curLangText!.checksumHoldBtnTooltip,
                            height: 25,
                            textStyle: const TextStyle(fontSize: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.8),
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                            ),
                            waitDuration: const Duration(milliseconds: 500),
                            child: MaterialButton(
                              onLongPress: () async {
                                if (modManChecksumFilePath.isEmpty || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                  checksumLocation = await FilePicker.platform.pickFiles(
                                    dialogTitle: curLangText!.checksumSelectPopupText,
                                    allowMultiple: false,
                                    // type: FileType.custom,
                                    // allowedExtensions: ['\'\''],
                                    lockParentWindow: true,
                                  );
                                  if (checksumLocation != null) {
                                    String? checksumPath = checksumLocation!.paths.first;
                                    File(checksumPath!).copySync(Uri.file('$modManChecksumDirPath/${p.basename(checksumPath)}').toFilePath());
                                    modManChecksumFilePath = Uri.file('$modManChecksumDirPath/${p.basename(checksumPath)}').toFilePath();
                                    File(modManChecksumFilePath).copySync(Uri.file('$modManPso2binPath/data/win32/${p.basename(modManChecksumFilePath)}').toFilePath());

                                    Provider.of<StateProvider>(context, listen: false).checksumMD5MatchTrue();
                                    setState(() {});
                                  }
                                } else {
                                  await launchUrl(Uri.parse('file:$modManChecksumDirPath'));
                                }
                              },
                              onPressed: (() async {
                                if (modManChecksumFilePath.isEmpty || !Provider.of<StateProvider>(context, listen: false).isChecksumMD5Match) {
                                  _checksumDownloading = true;
                                  setState(() {});
                                  await Dio().download(netChecksumFileLink, Uri.file('$modManChecksumDirPath/$netChecksumFileName').toFilePath()).then((value) {
                                    _checksumDownloading = false;
                                    modManChecksumFilePath = Uri.file('$modManChecksumDirPath/$netChecksumFileName').toFilePath();
                                    File(modManChecksumFilePath).copySync(Uri.file('$modManPso2binPath/data/win32/${p.basename(modManChecksumFilePath)}').toFilePath());
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
                                        if (!_checksumDownloading && modManChecksumFilePath.isEmpty)
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
                            textStyle: const TextStyle(fontSize: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.8),
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                            ),
                            waitDuration: const Duration(milliseconds: 500),
                            child: MaterialButton(
                              //visualDensity: VisualDensity.compact,
                              onPressed: (() async {
                                final prefs = await SharedPreferences.getInstance();
                                if (Provider.of<StateProvider>(context, listen: false).previewWindowVisible) {
                                  Provider.of<StateProvider>(context, listen: false).previewWindowVisibleSetFalse();
                                  prefs.setBool('previewWindowVisible', false);
                                  //previewPlayer.stop();
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
                          // Tooltip(
                          //   message: curLangText!.foldersTooltipText,
                          //   height: 25,
                          //   textStyle: TextStyle(fontSize: 15, color: Theme.of(context).canvasColor),
                          //   waitDuration: const Duration(seconds: 1),
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(right: 5),
                          //     child: DropdownButtonHideUnderline(
                          //       child: DropdownButton2(
                          //         customButton: AbsorbPointer(
                          //           absorbing: true,
                          //           child: MaterialButton(
                          //             onPressed: (() {}),
                          //             child: Row(
                          //               children: [
                          //                 const Icon(
                          //                   Icons.folder_copy_outlined,
                          //                   size: 18,
                          //                 ),
                          //                 const SizedBox(width: 2.5),
                          //                 Text(curLangText!.foldersBtnText, style: const TextStyle(fontWeight: FontWeight.w400))
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         isDense: true,
                          //         items: topBtnMenuItems
                          //             .map((item) => DropdownMenuItem<String>(
                          //                 value: item,
                          //                 child: Row(
                          //                   mainAxisAlignment: MainAxisAlignment.start,
                          //                   children: [
                          //                     if (item == curLangText!.modsFolderBtnText && item.isNotEmpty) const Icon(Icons.rule_folder_outlined),
                          //                     if (item == curLangText!.backupFolderBtnText && item.isNotEmpty) const Icon(Icons.backup_table),
                          //                     if (item == curLangText!.deletedItemsBtnText && item.isNotEmpty) const Icon(Icons.delete_rounded),
                          //                     const SizedBox(
                          //                       width: 5,
                          //                     ),
                          //                     Container(
                          //                       padding: const EdgeInsets.only(bottom: 3),
                          //                       child: Text(
                          //                         item,
                          //                         style: const TextStyle(
                          //                           fontSize: 14,
                          //                           //fontWeight: FontWeight.bold,
                          //                           //color: Colors.white,
                          //                         ),
                          //                         overflow: TextOverflow.ellipsis,
                          //                       ),
                          //                     )
                          //                   ],
                          //                 )))
                          //             .toList(),
                          //         onChanged: (value) async {
                          //           if (value == curLangText!.modsFolderBtnText) {
                          //             await launchUrl(Uri.parse('file:$modsDirPath'));
                          //           } else if (value == curLangText!.backupFolderBtnText) {
                          //             await launchUrl(Uri.parse('file:$backupDirPath'));
                          //           } else if (value == curLangText!.deletedItemsBtnText) {
                          //             await launchUrl(Uri.parse('file:$deletedItemsPath'));
                          //           }
                          //         },
                          //         itemHeight: 35,
                          //         dropdownWidth: 130,
                          //         itemPadding: const EdgeInsets.only(left: 5, right: 5),
                          //         dropdownPadding: const EdgeInsets.symmetric(vertical: 5),
                          //         dropdownDecoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(3),
                          //           color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).cardColor : Theme.of(context).primaryColor,
                          //         ),
                          //         dropdownElevation: 8,
                          //         offset: const Offset(0, -3),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          //Settings button
                          Tooltip(
                            message: curLangText!.darkModeTooltipText,
                            height: 25,
                            textStyle: const TextStyle(fontSize: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor.withOpacity(0.8),
                              border: Border.all(color: Theme.of(context).primaryColorLight),
                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                            ),
                            waitDuration: const Duration(milliseconds: 500),
                            child: SizedBox(
                              //width: 95,
                              child: MaterialButton(
                                onPressed: (() {
                                  _scaffoldKey.currentState!.openEndDrawer();
                                }),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.settings,
                                      size: 18,
                                    ),
                                    SizedBox(width: 2.5),
                                    Text('Settings', style: TextStyle(fontWeight: FontWeight.w400))
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
                                  //patchNotesDialog(context);
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

                                  for (var file
                                      in Directory(Uri.file('$modManRefSheetsDirPath/Player').toFilePath()).listSync(recursive: true).where((element) => p.extension(element.path) == '.csv')) {
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
                        curLangText!.newUserNoticeText,
                        style: TextStyle(color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColorDark : Colors.amberAccent, fontWeight: FontWeight.w500),
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setBool('isFirstTimeLoad', false);
                            firstTimeUser = false;
                            setState(() {});
                          },
                          child: Text(curLangText!.dismissBtnText)),
                    ],
                  ),
                  actions: const [SizedBox()],
                ),
              ),
            )),

          const Expanded(child: ModsLoadingPage())

          //Expanded(child: curLangText == null ? const LangLoadingPage() : const PathsLoadingPage())
        ],
      ),
    );
  }
}

//Menu items
class MenuItem {
  final String text;
  //final IconData icon;

  const MenuItem({
    required this.text,
    //required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> pathMenuItems = [_binFolder, modManFolder];
  static const _binFolder = MenuItem(text: 'pso2_bin');
  static const modManFolder = MenuItem(text: 'Mod Manager');

  static Widget buildItem(context, MenuItem item) {
    return Row(
      children: [
        // Icon(
        //   item.icon,
        //   color: MyApp.themeNotifier.value == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).iconTheme.color,
        //   size: 20,
        // ),
        // const SizedBox(
        //   width: 5,
        // ),
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
        //binDirDialog(context, curLangText!.pso2binReselectPopupText, '${curLangText!.curPathText}\n\'$binDirPath\'\n\n${curLangText!.chooseNewPathText}', true);
        break;
      case MenuItems.modManFolder:
        //mainModManDirDialog(context, curLangText!.modmanReselectPopupText, '${curLangText!.curPathText}\n\'$mainModDirPath\'\n\n${curLangText!.chooseNewPathText}', true);
        break;
    }
  }
}
