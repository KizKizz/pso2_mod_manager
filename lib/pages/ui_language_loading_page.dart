import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:pso2_mod_manager/global_variables.dart';
import 'package:pso2_mod_manager/loaders/language_loader.dart';
import 'package:pso2_mod_manager/main.dart';
import 'package:pso2_mod_manager/pages/paths_loading_page.dart';
import 'package:pso2_mod_manager/ui_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

Future textLangLoader = uiTextLoader();
String _selectedItemNameLang = '';

class UILanguageLoadingPage extends StatefulWidget {
  const UILanguageLoadingPage({super.key});

  @override
  State<UILanguageLoadingPage> createState() => _UILanguageLoadingPageState();
}

class _UILanguageLoadingPageState extends State<UILanguageLoadingPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: textLangLoader,
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Loading UI',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Error when loading UI',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(snapshot.error.toString(), softWrap: true, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          windowManager.destroy();
                        },
                        child: const Text('Exit'))
                  ],
                ),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Loading UI',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            } else {
              curLangText = snapshot.data;
              if (!firstTimeLanguageSet || modManCurActiveItemNameLanguage.isEmpty || curActiveLang.isEmpty) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Select UI Language - UI言語の選択',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),

                        SizedBox(
                          width: 70,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                            style: TextStyle(fontWeight: FontWeight.w400, color: Theme.of(context).textTheme.bodyMedium!.color),
                            buttonStyleData: ButtonStyleData(
                              height: 30,
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
                            iconStyleData: const IconStyleData(iconSize: 20),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 30,
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              //fontWeight: FontWeight.bold,
                                              color: Theme.of(context).textTheme.bodyMedium!.color,
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
                              setState(() {});
                            },
                          )),
                        ),

                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Select Item Name Language - 項目名の言語を選択',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(
                            '(Only applies to item names in lists when adding mods or swapping items)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            '(MODの追加やアイテムの交換時に、リスト内のアイテム名にのみ適用される)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
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
                                //color: Theme.of(context).primaryColorDark,
                                onPressed: _selectedItemNameLang == 'EN'
                                    ? null
                                    : () async {
                                        _selectedItemNameLang = 'EN';
                                        setState(() {});
                                      },
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedItemNameLang == 'EN'
                                            ? MyApp.themeNotifier.value == ThemeMode.light
                                                ? Color(lightModePrimarySwatch.value)
                                                : Color(darkModePrimarySwatch.value)
                                            : Theme.of(context).hintColor),
                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                child: Text('EN',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedItemNameLang == 'EN'
                                            ? MyApp.themeNotifier.value == ThemeMode.light
                                                ? Color(lightModePrimarySwatch.value)
                                                : Color(darkModePrimarySwatch.value)
                                            : Theme.of(context).hintColor)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, top: 5, bottom: 2.5),
                              child: MaterialButton(
                                minWidth: 120,
                                height: 30,
                                //color: Theme.of(context).primaryColorDark,
                                onPressed: _selectedItemNameLang == 'JP'
                                    ? null
                                    : () async {
                                        _selectedItemNameLang = 'JP';
                                        setState(() {});
                                      },
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: _selectedItemNameLang == 'JP'
                                            ? MyApp.themeNotifier.value == ThemeMode.light
                                                ? Color(lightModePrimarySwatch.value)
                                                : Color(darkModePrimarySwatch.value)
                                            : Theme.of(context).hintColor),
                                    borderRadius: const BorderRadius.all(Radius.circular(2))),
                                child: Text('JP',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedItemNameLang == 'JP'
                                            ? MyApp.themeNotifier.value == ThemeMode.light
                                                ? Color(lightModePrimarySwatch.value)
                                                : Color(darkModePrimarySwatch.value)
                                            : Theme.of(context).hintColor)),
                              ),
                            ),
                          ],
                        ),

                        //button
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ElevatedButton(
                              onPressed: _selectedItemNameLang.isEmpty || langDropDownSelected.isEmpty
                                  ? null
                                  : () async {
                                      final prefs = await SharedPreferences.getInstance();
                                      firstTimeLanguageSet = true;
                                      prefs.setString('curActiveLanguage', curActiveLang);
                                      modManCurActiveItemNameLanguage = _selectedItemNameLang;
                                      prefs.setString('modManCurActiveItemNameLanguage', _selectedItemNameLang);
                                      prefs.setBool('firstTimeLanguageSet', true);
                                      setState(() {});
                                    },
                              child: const Text('OK')),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const PathsLoadingPage();
              }
            }
          }
        });
  }
}
